//
//  VPNManager.swift
//  discord
//
//  Created by Ke Li on 4/23/18.
//  Copyright © 2018 Ke Li. All rights reserved.
//
// ref: basically from https://github.com/yichengchen/RabbitVpnDemo/blob/master/rabbit/Model/VpnManager.swift
// but with some modification, to store information of rules

import Foundation
import NetworkExtension


enum VPNStatus {
    case off
    case connecting
    case on
    case disconnecting
}


class VpnManager{
    static let shared = VpnManager()
    var observerAdded: Bool = false
    var proxies: [Proxy] = []
    fileprivate(set) var vpnStatus = VPNStatus.off {
        didSet {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "kProxyServiceVPNStatusNotification"), object: nil)
        }
    }
    
    init() {
        loadProviderManager{
            guard let manager = $0 else{return}
            self.updateVPNStatus(manager)
        }
        addVPNStatusObserver()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func addVPNStatusObserver() {
        guard !observerAdded else{
            return
        }
        loadProviderManager { [unowned self] (manager) -> Void in
            if let manager = manager {
                self.observerAdded = true
                NotificationCenter.default.addObserver(forName: NSNotification.Name.NEVPNStatusDidChange, object: manager.connection, queue: OperationQueue.main, using: { [unowned self] (notification) -> Void in
                    self.updateVPNStatus(manager)
                })
            }
        }
    }
    
    
    func updateVPNStatus(_ manager: NEVPNManager) {
        switch manager.connection.status {
        case .connected:
            self.vpnStatus = .on
        case .connecting, .reasserting:
            self.vpnStatus = .connecting
        case .disconnecting:
            self.vpnStatus = .disconnecting
        case .disconnected, .invalid:
            self.vpnStatus = .off
        }
        print(self.vpnStatus)
    }
}

// load VPN Profiles
extension VpnManager{
    
    fileprivate func createProviderManager() -> NETunnelProviderManager {
        let manager = NETunnelProviderManager()
        let conf = NETunnelProviderProtocol()
        conf.serverAddress = "N/A"
        manager.protocolConfiguration = conf
        manager.localizedDescription = "PAC HTTP Proxy on 4G/LTE"
        return manager
    }
    
    func loadAndCreateProviderManager(_ complete: @escaping (NETunnelProviderManager?) -> Void ){
        NETunnelProviderManager.loadAllFromPreferences{ (managers, error) in
            guard let managers = managers else{return}
            let manager: NETunnelProviderManager
            if managers.count > 0 {
                manager = managers[0]
                self.delDupConfig(managers)
            } else {
                manager = self.createProviderManager()
            }
            
            manager.isEnabled = true
            self.setRulerConfig(manager)
            manager.saveToPreferences {
                if $0 != nil{complete(nil);return;}
                manager.loadFromPreferences {
                    if $0 != nil {
                        print($0.debugDescription)
                        complete(nil);return;
                    }
                    self.addVPNStatusObserver()
                    complete(manager)
                }
            }
        }
    }
    
    func loadProviderManager(_ complete: @escaping (NETunnelProviderManager?) -> Void){
        NETunnelProviderManager.loadAllFromPreferences { (managers, error) in
            if let managers = managers {
                if managers.count > 0 {
                    let manager = managers[0]
                    complete(manager)
                    return
                }
            }
            complete(nil)
        }
    }
    
    
    func delDupConfig(_ arrays:[NETunnelProviderManager]){
        if (arrays.count)>1 {
            for i in 0 ..< arrays.count{
                print("Del DUP Profiles")
                arrays[i].removeFromPreferences(completionHandler: { (error) in
                    if(error != nil){print(error.debugDescription)}
                })
            }
        }
    }
}

// Actions
extension VpnManager{
    func connect(){
        self.loadAndCreateProviderManager { (manager) in
            guard let manager = manager else{return}
            do {
                try manager.connection.startVPNTunnel(options: [:])
            } catch let err{
                print(err)
            }
        }
    }
    
    func disconnect(){
        loadProviderManager{$0?.connection.stopVPNTunnel()}
    }
}

// Generate and Load ConfigFile
extension VpnManager{

    fileprivate func setRulerConfig(_ manager:NETunnelProviderManager){
        var conf = [String:AnyObject]()
        let data = try! JSONEncoder().encode(VpnManager.shared.proxies)
        conf["settings"] = String(data: data, encoding: .utf8)! as AnyObject?
        let orignConf = manager.protocolConfiguration as! NETunnelProviderProtocol
        orignConf.providerConfiguration = conf
        manager.protocolConfiguration = orignConf
    }
}
