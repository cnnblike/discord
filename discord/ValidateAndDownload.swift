//
//  Download.swift
//  discord
//
//  Created by Ke Li on 4/26/18.
//  Copyright © 2018 Ke Li. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireImage
import UIKit
enum result {
    case ok
    case warning
    case error
}
func isValidUrl (urlString: String) -> Bool {
    if let _ = URL(string: urlString) {
        return true
    }
    return false
}
class NetworkManager {
    static let sharedInstance: Alamofire.SessionManager = {
        // work
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 2
        configuration.timeoutIntervalForResource = 2
        configuration.httpAdditionalHeaders = Alamofire.SessionManager.defaultHTTPHeaders
        return Alamofire.SessionManager(configuration: configuration)
    }()
}
func validateAndDownload (item: Proxy, callback: @escaping (_ res:result)->()) -> Void{
    if item.name == "" {
        item.name = item.isAutomatic ? "Automatic Proxy": "Manual Proxy"
    }
    if item.descriptor == "" {
        item.descriptor = item.isAutomatic ? item.pacUrl: (item.host + ":" + String(item.port))
    }
    if (item.port > 65535) || (item.port < 0) {
        callback(.error)
    } else {
        // pacUrl -> pacContent
        if item.isAutomatic && (!isValidUrl(urlString: item.pacUrl)){
            callback(.error)
        } else if isValidUrl(urlString: item.pacUrl){
            NetworkManager.sharedInstance.request(item.pacUrl).validate(statusCode: 200..<300).response { (response) in
                if response.error == nil {
                    if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                        item.pacContent = utf8Text
                    }
                    validateAndDownloadImage(item: item, callback: callback)
                } else {
                    callback(.error)
                }
            }
        } else {
            validateAndDownloadImage(item: item, callback: callback)
        }

    }
}

func validateAndDownloadImage( item:Proxy, callback: @escaping(_ res:result)-> ()) -> Void {
    // imageurl -> cachedImage
    if !isValidUrl(urlString: item.imageUrl) {
        callback(.warning)
    } else {
        NetworkManager.sharedInstance.request(item.imageUrl).validate(statusCode: 200..<300).responseImage { (response) in
            if response.error == nil && response.data != nil {
                guard let image = response.result.value else {
                    callback(.warning)
                    return
                }
                guard let _ = image.cgImage else {
                    callback(.warning)
                    return
                }
                if (image.cgImage!.width != 48) || (image.cgImage!.height != 48) {
                    callback(.warning)
                    return
                } else {
                    do {
                        let timestamp = Int64(Date().timeIntervalSince1970 * 1000.0)
                        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("\(timestamp).png")
                        if let pngImageData = UIImagePNGRepresentation(image) {
                            try pngImageData.write(to: fileURL, options: .atomic)
                        }
                        item.cachedImage = "\(timestamp).png"
                        callback(.ok)
                    } catch {
                        callback(.warning)
                        return
                    }
                }
            } else {
                callback(.warning)
            }
        }
    }
}
