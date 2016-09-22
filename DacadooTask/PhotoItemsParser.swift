//
//  PhotoItemsParser.swift
//  DacadooTask
//
//  Created by Alina Yehorova on 22.09.16.
//  Copyright © 2016 Alina Yehorova. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

class PhotoItemsParser: NSObject {
    
    func parsePhotoItemsToModel(itemsArray:[AnyObject]) -> [SearchedPhoto] {
        
        var searchedPhotoArray = [SearchedPhoto]()
        
        for item in itemsArray {
            if item is [String:AnyObject] {
                
                // Check if item has field with photos
                if let postPhotos = item["photos"] as? [AnyObject] {
                    for photo in postPhotos {
                        if let originalSizePhoto = photo["original_size"] as? [String:AnyObject] {
                            
                            let stringURL = originalSizePhoto["url"] as! String
                            // Clear path from unnessessary symbols
                            let formattedStringURL = stringURL.replacingOccurrences(of: "\\/", with: "\\")
                            
                            // Calculate height of photo if it's width will be 300 px (for calculating height  of table row)
                            let photoOriginalWidth = originalSizePhoto["width"] as! Int
                            let photoOriginalHeight = originalSizePhoto["height"] as! Int
                            let photoOriginalSize = CGSize(width: photoOriginalWidth, height: photoOriginalHeight)
                            let boundingRect = CGRect(x: 0, y: 0, width: 300, height: CGFloat(MAXFLOAT))
                            let cutSizeRect  = AVMakeRect(aspectRatio: photoOriginalSize, insideRect: boundingRect)
                            
                            // Create searched photo object
                            let searchedPhoto = SearchedPhoto(photoStringURL: formattedStringURL, cutSizeHeight: cutSizeRect.height)
                            
                            // Write author blog name if it exists in response
                            if let authorBlogName = item["blog_name"] as? String {
                                searchedPhoto.authorBlogName = authorBlogName
                            }
                            
                            searchedPhotoArray.append(searchedPhoto)
                        }
                    }
                }
            }
        }
        return searchedPhotoArray
    }
    
}
