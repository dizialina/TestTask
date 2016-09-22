//
//  SearchedPhoto.swift
//  DacadooTask
//
//  Created by Alina Yehorova on 22.09.16.
//  Copyright © 2016 Alina Yehorova. All rights reserved.
//

import Foundation
import UIKit

class SearchedPhoto: NSObject {
    
    var photoStringURL:URL?
    var photoFullSize:UIImage?
    var photoCutSize:UIImage?
    var cutSizeHeight:CGFloat?
    var authorBlogName:String?
    
    init(photoStringURL:String, cutSizeHeight:CGFloat) {
        self.cutSizeHeight = cutSizeHeight
        if let photoURL = URL(string: photoStringURL) {
            self.photoStringURL = photoURL
        }
    }    
}
