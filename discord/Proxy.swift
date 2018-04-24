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


struct Proxy: Codable {
    var enable: Bool!
    var name: String!
    var description: String!
    var host: String!
    var port: Int!
    var password: String!
    // TODO: add rules and pac here.
    
    init(name: String, host: String, port: Int, password: String, enable: Bool, description: String) {
        self.name = name
        self.host = host
        self.port = port
        self.password = password
        self.enable = enable
        self.description = description
    }
}
