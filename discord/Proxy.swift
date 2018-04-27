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

class Proxy: NSObject, NSCoding, Codable {
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
    init(enable:Bool, isAutomatic: Bool, needAuthenticate: Bool, username: String, host: String, port: Int, password: String, pacUrl: String, name: String, descriptor: String, imageUrl: String, cachedImage: String, pacContent: String) {
        super.init()
        self.enable = enable
        self.isAutomatic = isAutomatic
        self.needAuthenticate = needAuthenticate
        self.username = username
        self.host = host
        self.port = port
        self.password = password
        self.pacUrl = pacUrl
        self.name = name
        self.descriptor = descriptor
        self.imageUrl = imageUrl
        self.cachedImage = cachedImage
        self.pacContent = pacContent
        print(self)
    }
    required convenience init(coder aDecoder: NSCoder){
        self.init(enable: aDecoder.decodeObject(forKey: "enable") as! Bool, isAutomatic: aDecoder.decodeObject(forKey: "isAutomatic") as! Bool, needAuthenticate: aDecoder.decodeObject(forKey: "needAuthenticate") as! Bool, username: aDecoder.decodeObject(forKey: "username") as! String, host: aDecoder.decodeObject(forKey: "host") as! String, port: aDecoder.decodeObject(forKey: "port") as! Int, password: aDecoder.decodeObject(forKey: "password") as! String, pacUrl: aDecoder.decodeObject(forKey: "pacUrl") as! String, name: aDecoder.decodeObject(forKey: "name") as! String, descriptor: aDecoder.decodeObject(forKey: "descriptor") as! String, imageUrl: aDecoder.decodeObject(forKey: "imageUrl") as! String, cachedImage: aDecoder.decodeObject(forKey: "cachedImage") as! String, pacContent: aDecoder.decodeObject(forKey: "pacContent") as! String)
    }
    func encode(with aCoder: NSCoder) {
        aCoder.encode(enable, forKey: "enable")
        aCoder.encode(isAutomatic, forKey: "isAutomatic")
        aCoder.encode(needAuthenticate, forKey: "needAuthenticate")
        aCoder.encode(username, forKey: "username")
        aCoder.encode(host, forKey: "host")
        aCoder.encode(port, forKey: "port")
        aCoder.encode(password, forKey: "password")
        aCoder.encode(pacUrl, forKey: "pacUrl")
        aCoder.encode(name, forKey: "name")
        aCoder.encode(descriptor, forKey: "descriptor")
        aCoder.encode(imageUrl, forKey: "imageUrl")
        aCoder.encode(cachedImage, forKey: "cachedImage")
        aCoder.encode(pacContent, forKey: "pacContent")
    }
}
