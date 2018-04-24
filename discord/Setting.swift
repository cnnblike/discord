//
//  Proxy.swift
//  discord
//
//  Created by Ke Li on 4/23/18.
//  Copyright © 2018 Ke Li. All rights reserved.
//

import Foundation

private let KUserDefaultsProxys: String = {
    return "github.com/cnnblike/decensorship.git"
}()

class Setting: Codable {
    static let shared = loadConfig()
    var proxies: [Proxy] = []
    var enable: Bool!
    init(){
        self.enable = false
        self.proxies = []
    }
    static func loadConfig() -> Setting {
        if let _ = UserDefaults.standard.string(forKey: KUserDefaultsProxys) {} else {
            let tmpSetting = Setting()
            UserDefaults.standard.set(String(data: try! JSONEncoder().encode(tmpSetting), encoding: .utf8)!, forKey: KUserDefaultsProxys)
        }
        var newSetting: Setting!
        if let tmp = UserDefaults.standard.string(forKey: KUserDefaultsProxys) {
            let jsonData = tmp.data(using: .utf8)
            newSetting = try! JSONDecoder().decode(Setting.self, from: jsonData!)
        } else {
            newSetting = Setting() // wierd, we should not visit this party any situation, but just in case
        }
        return newSetting
    }
}

class Proxy: Codable {
    var enable: Bool?
    var name: String?
    var host: String?
    var port: Int?
    var password: String?
    // TODO: add rules and pac here.
    
    init(name: String, host: String, port: Int, password: String, enable: Bool) {
        self.name = name
        self.host = host
        self.port = port
        self.password = password
        self.enable = enable
    }
}
