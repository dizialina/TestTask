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
        
        // Show author blog title in navigation item
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
                    } else {
                        // Show alert if image was not loaded
                        self.activityIndicator.stopAnimating()
                        let alertController = UIAlertController(title: nil, message: "Error loading photo", preferredStyle: UIAlertControllerStyle.alert)
                        let cancelAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
                        alertController.addAction(cancelAction)
                        self.present(alertController, animated: true, completion: nil)
                    }
                })
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

