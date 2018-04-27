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

class Proxy: NSObject {
    var enable: Bool!
    var isAutomatic: Bool!
    var needAuthenticate: Bool!
    var username: String!
    var host: String!
    var port: Int!
    var password: String!
    var pacUrl: String!
    
    var name: String!
    var descriptor: String!
    var imageUrl: String!
    
    var cachedImage: String!
    var pacContent: String!
    
    override init(){
        super.init()
        self.enable = false
        self.isAutomatic = true
        self.needAuthenticate = false
        self.username = ""
        self.host = ""
        self.port = 0
        self.password = ""
        self.pacUrl = "http://discord.cnnblike.com:3000/WSGun.pac"
        self.name = ""
        self.descriptor = ""
        self.imageUrl = "https://cdn4.iconfinder.com/data/icons/48x48-free-object-icons/48/Butterfly.png"
        self.cachedImage = ""
        self.pacContent = ""
        
    }
    init(name: String, host: String, port: Int, password: String, enable: Bool, description: String, username: String) {
        super.init()
        self.name = name
        self.host = host
        self.port = port
        self.password = password
        self.enable = enable
        self.descriptor = description
    }
}
