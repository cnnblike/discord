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
    var isAutomatic: Bool!
    var needAuthenticate: Bool!
    var username: String!
    var host: String!
    var port: Int!
    var password: String!
    var pacUrl: String!
    
    var name: String!
    var description: String!
    var imageUrl: String!
    
    var cachedImage: String!
    var pacContent: String!
    
    init(){
        self.enable = false
        self.isAutomatic = false
        self.needAuthenticate = false
        self.username = ""
        self.host = ""
        self.port = 0
        self.password = ""
        self.pacUrl = ""
        self.name = ""
        self.description = ""
        self.imageUrl = ""
        self.cachedImage = ""
        self.pacContent = ""
        
    }
    init(name: String, host: String, port: Int, password: String, enable: Bool, description: String, username: String) {
        self.name = name
        self.host = host
        self.port = port
        self.password = password
        self.enable = enable
        self.description = description
    }
}
