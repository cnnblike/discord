//
//  PacketTunnelProvider.swift
//  FilterProxy
//
//  Created by Ke Li on 4/19/18.
//  Copyright © 2018 Ke Li. All rights reserved.
//

import NetworkExtension


class PacketTunnelProvider: NEPacketTunnelProvider {
    var lastPath:NWPath?
    var started:Bool = false
    
    override func startTunnel(options: [String : NSObject]?, completionHandler: @escaping (Error?) -> Void) {
        // Use the build-in debug observer.
        // ObserverFactory.currentFactory = DebugObserverFactory()
        
        guard let conf = (protocolConfiguration as! NETunnelProviderProtocol).providerConfiguration else {
            NSLog("[ERROR] No ProtocolConfiguration Found")
            exit(EXIT_FAILURE)
        }
        
        //let settings = conf["settings"] as! [Proxy]

        // the `tunnelRemoteAddress` is meaningless because we are not creating a tunnel.
        let networkSettings = NEPacketTunnelNetworkSettings(tunnelRemoteAddress: "8.8.8.8")
        networkSettings.mtu = 1500
        networkSettings.ipv4Settings = NEIPv4Settings(addresses: ["192.169.89.1"], subnetMasks: ["255.255.255.0"])
        
        let proxySettings = NEProxySettings()
        proxySettings.autoProxyConfigurationEnabled = true
        proxySettings.proxyAutoConfigurationJavaScript = """
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

        """
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
            
            if !self.started {
                self.addObserver(self, forKeyPath: "defaultPath", options: .initial, context: nil)
            }
            completionHandler(nil)
            self.started = true
        }

    }
    
    override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
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
