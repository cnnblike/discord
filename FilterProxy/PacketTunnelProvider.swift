//
//  PacketTunnelProvider.swift
//  FilterProxy
//
//  Created by Ke Li on 4/19/18.
//  Copyright © 2018 Ke Li. All rights reserved.
//

import NetworkExtension
import NEKit

class PacketTunnelProvider: NEPacketTunnelProvider {
    var lastPath:NWPath?
    var started:Bool = false
    var enableLocalProxy: Bool = false
    var proxyServer: ProxyServer!
    var proxyPort: Int!
    override func startTunnel(options: [String : NSObject]?, completionHandler: @escaping (Error?) -> Void) {
        
        if self.proxyPort == nil {
            self.proxyPort = 9090
        }
        
        guard let conf = (protocolConfiguration as! NETunnelProviderProtocol).providerConfiguration else {
            NSLog("[ERROR] No ProtocolConfiguration Found")
            exit(EXIT_FAILURE)
        }
        let settingString = conf["settings"] as! String
        let settingData = settingString.data(using: .utf8)
        let settings: [Proxy] = try! JSONDecoder().decode([Proxy].self, from: settingData!)
        var pacFile: String  = ""
        var capsules: [String] = []
        for setting in settings {
            var capsule: String = "" // actually a closure but the swift seems to have use `closure` as a reserved word
            if setting.enable {
                if setting.isAutomatic {
                    capsule = "(function(){ \(String(setting.pacContent)); return FindProxyForURL })() "
                } else {
                    if setting.needAuthenticate {
                        capsule = "(function() { return function(){ return \"PROXY 127.0.0.1:\(String(self.proxyPort)); DIRECT\" }})()"
                        self.enableLocalProxy = true
                        let httpAdapterFactory = HTTPAdapterFactory(serverHost: setting.host, serverPort: setting.port, auth: HTTPAuthentication(username: setting.username, password: setting.password))
                        let allRule = AllRule(adapterFactory: httpAdapterFactory)
                        RuleManager.currentManager = RuleManager(fromRules: [allRule], appendDirect: true)
                    } else {
                        capsule = "(function() { return function(){ return \"PROXY \(String(setting.host)):\(String(setting.port)); DIRECT\" }})()"
                    }
                    capsules.append(capsule)
                    break
                }
                capsules.append(capsule)
            }
        }
        let tempRule:String = capsules.joined(separator: ",")
        pacFile =
        "function FindProxyForURL(url,host){ rules = [\(tempRule)]\n for(var i = 0; i < rules.length; i++) {var result = rules[i](url,host); if ( (result !== \"DIRECT\") && (result !== undefined) ) return result;} return \"DIRECT\" }"
        // the `tunnelRemoteAddress` is meaningless because we are not creating a tunnel.
        let networkSettings = NEPacketTunnelNetworkSettings(tunnelRemoteAddress: "8.8.8.8")
        networkSettings.mtu = 1500
        networkSettings.ipv4Settings = NEIPv4Settings(addresses: ["192.169.89.1"], subnetMasks: ["255.255.255.0"])
        
        let proxySettings = NEProxySettings()
        proxySettings.autoProxyConfigurationEnabled = true
        proxySettings.proxyAutoConfigurationJavaScript = pacFile
        /*"""
        function FindProxyForURL(url, host)
        {
        var xx = (function(){
        function FindProxyForURL(url, host)
        {
        proxy = "PROXY test.cnnblike.com:8001";
        if (shExpMatch(host, "*cnnblike.com"))
        return proxy;
        return "DIRECT";
        }
        return FindProxyForURL
        })()
        return xx(url, host)
        }

        """*/
        proxySettings.httpEnabled = false
        proxySettings.httpsEnabled = false
        proxySettings.excludeSimpleHostnames = true
        // This will match all domains, the filter function should based on merged PAC
        proxySettings.matchDomains = [""]
        proxySettings.exceptionList = ["api.smoot.apple.com","configuration.apple.com","xp.apple.com","smp-device-content.apple.com","guzzoni.apple.com","captive.apple.com","*.ess.apple.com","*.push.apple.com","*.push-apple.com.akadns.net"]
        networkSettings.proxySettings = proxySettings
        
        setTunnelNetworkSettings(networkSettings) {
            error in
            guard error == nil else {
                completionHandler(error)
                return
            }
            if self.enableLocalProxy {
                if !self.started {
                    self.proxyServer = GCDHTTPProxyServer(address: IPAddress(fromString: "127.0.0.1"), port: NEKit.Port(port: UInt16(self.proxyPort)))
                    try! self.proxyServer.start()
                    self.addObserver(self, forKeyPath: "defaultPath", options: .initial, context: nil)
                } else {
                    self.proxyServer.stop()
                    try! self.proxyServer.start()
                }
            } else {
                if !self.started {
                    self.addObserver(self, forKeyPath: "defaultPath", options: .initial, context: nil)
                }
            }

            completionHandler(nil)
            self.started = true
        }

    }
    
    override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        if(proxyServer != nil){
            proxyServer.stop()
            proxyServer = nil
            RawSocketFactory.TunnelProvider = nil
        }
        completionHandler()
        // don't know why, but the NEKit will continue to run for a small while, which make us unable to start another configuration instantly, so we manually cause a termination here.
        exit(EXIT_SUCCESS)
    }
    
    // listen to the change of network status, when switching between different network, we need to reconnect VPN
    // otherwise, the VPN will tend to connect via LTE while Wi-Fi is connected.
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if (keyPath == "defaultPath") {
            if self.defaultPath?.status == .satisfied && self.defaultPath != self.lastPath {
                if (self.lastPath == nil) {
                    self.lastPath = self.defaultPath
                } else {
                    NSLog("received network change notifcation")
                    let xSeconds = 1.0
                    DispatchQueue.main.asyncAfter(deadline: .now() + xSeconds) {
                        self.startTunnel(options: nil){ _ in }
                    }
                }
            } else {
                self.lastPath = defaultPath
            }
        }
        
    }
}
