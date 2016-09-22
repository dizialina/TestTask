//
//  SinglePhotoViewController.swift
//  DacadooTask
//
//  Created by Alina Yehorova on 22.09.16.
//  Copyright © 2016 Alina Yehorova. All rights reserved.
//

import Foundation
import UIKit

class SinglePhotoViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var searchedPhoto:SearchedPhoto?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Show blog title in navigation item
        if let authorBlogName = searchedPhoto?.authorBlogName {
            self.navigationItem.title = authorBlogName
        }
        
        // Check if photo object has loaded image, if not then load image from server
        if let fullSizePhoto = searchedPhoto?.photoFullSize {
            self.imageView.image = fullSizePhoto
        } else {
            if searchedPhoto != nil {
                self.activityIndicator.startAnimating()
                let serverManager = ServerManager()
                serverManager.downloadImageFromURL(searchedPhotos: [searchedPhoto!], completionHandler: { (isSuccess) in
                    if isSuccess {
                        // Update image view on main thread
                        DispatchQueue.main.async {
                            self.activityIndicator.stopAnimating()
                            self.imageView.image = self.searchedPhoto?.photoFullSize
                        }
                    }
                })
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

