//
//  ServerManager.swift
//  DacadooTask
//
//  Created by Alina Yehorova on 22.09.16.
//  Copyright © 2016 Alina Yehorova. All rights reserved.
//

import Foundation
import AFNetworking

class ServerManager: NSObject {
    
    var sessionManager = AFHTTPSessionManager()
    var apiKey = String()
    
    override init() {
        self.apiKey = "CcEqqSrYdQ5qTHFWssSMof4tPZ89sfx6AXYNQ4eoXHMgPJE03U"
        let serverURL = URL(string: "http://api.tumblr.com/v2/")
        self.sessionManager = AFHTTPSessionManager(baseURL: serverURL)
    }
    
    func getTaggedPhotos(_ searchedTag: String, success: @escaping (_ response: [AnyObject]?) -> Void, failure: @escaping (_ error: Error?) -> Void) {
        
        let parameters = ["tag": searchedTag,
                      "api_key": self.apiKey]
        
        sessionManager.get("tagged", parameters: parameters, success: { (task: URLSessionDataTask, responseObject: Any?) in
            //print(responseObject)
            if let response = responseObject as? [String:AnyObject] {
                if let itemsArray = response["response"] as? [AnyObject] {
                    print("Success. Server returned \(itemsArray.count) photos")
                    success(itemsArray)
                }
            } else {
                print("Server returned empty response")
                success(nil)
            }
            })
        { (task:URLSessionDataTask?, error:Error) in
            print("Error receiving tagged photos: " + error.localizedDescription)
            failure(error)
        }
    }
    
    func downloadImageFromURL(searchedPhotos:[SearchedPhoto], completionHandler: @escaping (_ isSuccess: Bool) -> Void) {
        
        for photo in searchedPhotos {
            
            // Async download image from url
            if let photoURL = photo.photoStringURL {
                let downloadImageTask = URLSession.shared.dataTask(with: photoURL) { (data, response, error) in
                    if data != nil {
                        // Get full size image
                        let fullSizeImage = UIImage(data: data!)
                        photo.photoFullSize = fullSizeImage
                        
                        // Resize image for width 300 px
                        let rect = CGRect(x: 0, y: 0, width: 300, height: photo.cutSizeHeight!)
                        UIGraphicsBeginImageContextWithOptions(rect.size, false, 1.0)
                        fullSizeImage?.draw(in: rect)
                        let cutImage = UIGraphicsGetImageFromCurrentImageContext()
                        UIGraphicsEndImageContext()
                        photo.photoCutSize = cutImage
                        
                        completionHandler(true)
                    } else {
                        completionHandler(false)
                    }
                }
                downloadImageTask.resume()
            }
        }
    }
    
    
    
}
