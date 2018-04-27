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
    }
    static func containsAndTyped<T> (coder aDecoder:NSCoder, forKey key: String) -> T? {
        if aDecoder.containsValue(forKey: key), let tmp = aDecoder.decodeObject(forKey: key) as? T {
                return tmp
        }
        return nil
    }
    required init(coder aDecoder: NSCoder){
        super.init()
        self.enable = Proxy.containsAndTyped(coder: aDecoder, forKey: "enable") ?? true
        self.pacUrl = Proxy.containsAndTyped(coder: aDecoder, forKey: "pacUrl") ?? ""
        self.pacContent = Proxy.containsAndTyped(coder: aDecoder, forKey: "pacContent") ?? ""
        self.isAutomatic = Proxy.containsAndTyped(coder: aDecoder, forKey: "isAutomatic") ?? (!(self.pacUrl == "" && self.pacContent == "") )
        self.username = Proxy.containsAndTyped(coder: aDecoder, forKey: "username") ?? ""
        self.password = Proxy.containsAndTyped(coder: aDecoder, forKey: "password") ?? ""
        self.needAuthenticate = Proxy.containsAndTyped(coder: aDecoder, forKey: "needAuthenticate") ?? (self.username != "" && self.password != "")
        self.host = Proxy.containsAndTyped(coder: aDecoder, forKey: "host") ?? ""
        self.port = Proxy.containsAndTyped(coder: aDecoder, forKey: "port") ?? 0
        self.name = Proxy.containsAndTyped(coder: aDecoder, forKey: "name") ?? ""
        self.descriptor = Proxy.containsAndTyped(coder: aDecoder, forKey: "descriptor") ?? ""
        self.imageUrl = Proxy.containsAndTyped(coder: aDecoder, forKey: "imageUrl") ?? ""
        self.cachedImage = Proxy.containsAndTyped(coder: aDecoder, forKey: "cachedImage") ?? ""
    }
    required init(from aDecoder: Decoder){
        super.init()
        let container = try! aDecoder.container(keyedBy: CodingKeys.self)
        self.enable = try? container.decodeIfPresent(Bool.self, forKey: .enable) ?? true
        self.pacUrl = try? container.decodeIfPresent(String.self, forKey: .pacUrl) ?? ""
        self.pacContent = try? container.decodeIfPresent(String.self, forKey: .pacContent) ?? ""
        self.isAutomatic = try? container.decodeIfPresent(Bool.self, forKey: .isAutomatic) ?? (!(self.pacUrl == "" && self.pacContent == "") )
        self.username = try? container.decodeIfPresent(String.self, forKey: .username) ?? ""
        self.password = try? container.decodeIfPresent(String.self, forKey: .password) ?? ""
        self.needAuthenticate = try? container.decodeIfPresent(Bool.self, forKey: .needAuthenticate) ?? (self.username != "" && self.password != "")
        self.host = try? container.decodeIfPresent(String.self, forKey: .host) ?? ""
        self.port = try? container.decodeIfPresent(Int.self, forKey: .port) ?? 0
        self.name = try? container.decodeIfPresent(String.self, forKey: .name) ?? ""
        self.descriptor = try? container.decodeIfPresent(String.self, forKey: .descriptor) ?? ""
        self.imageUrl = try? container.decodeIfPresent(String.self, forKey: .imageUrl) ?? ""
        self.cachedImage = try? container.decodeIfPresent(String.self, forKey: .cachedImage) ?? ""
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
