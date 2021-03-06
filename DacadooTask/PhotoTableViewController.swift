//
//  PhotoTableViewController.swift
//  DacadooTask
//
//  Created by Alina Yehorova on 22.09.16.
//  Copyright © 2016 Alina Yehorova. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

class PhotoTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var searchedPhotoArray = [SearchedPhoto]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Methods for getting data
    
    func getPhotosFromServerResponse(itemsArray:[AnyObject]) {
        
        // Slice array to arrays with 10 items (for situation when response of items is too large)
        var arrayOfPhotosToSlice = itemsArray
        let arrayOfSubarrays = arrayOfPhotosToSlice.splitBy(numberOfElements: 10)
        
        print("Need to download \(arrayOfSubarrays.count) parts of response photos array")
        
        if arrayOfSubarrays.count > 0 {
            // Download images for every part
            for arrayOfPhotoItems in arrayOfSubarrays {
            
                // Parse server items to photo objects and add them to table view
                let receivedSearchedPhotoArray = PhotoItemsParser().parsePhotoItemsToModel(itemsArray: arrayOfPhotoItems)
                print("\(receivedSearchedPhotoArray.count) photos was added to table view")
                searchedPhotoArray += receivedSearchedPhotoArray
                // Now we have portion of photo objects and can set number of cells and cell height
                self.tableView.reloadData()
            
                // Download image from server for every photo objects and update table view, when every single photo is load
                let serverManager = ServerManager()
                serverManager.downloadImageFromURL(searchedPhotos: receivedSearchedPhotoArray, completionHandler: { (isSuccess) in
                    if isSuccess {
                        // Update table view on main thread
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                })
            }
        } else {
            // Show alert if there is no posts with selected tag
            let alertController = UIAlertController(title: nil, message: "No matches found", preferredStyle: UIAlertControllerStyle.alert)
            let cancelAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    // MARK: SearchBarDelegate
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        // Hide keyboard
        searchBar.endEditing(true)
        
        // Clear old search results
        self.searchedPhotoArray.removeAll()
        
        // Check if search bar text field isn't empty
        if (searchBar.text?.characters.count)! > 0 {
            let searchedTag = searchBar.text
            
            // Send request to server with typed tag
            let serverManager = ServerManager()
            serverManager.getTaggedPhotos(searchedTag!, success: { (response) in
                
                // Check if server returned full response
                if response != nil {
                    self.getPhotosFromServerResponse(itemsArray: response!)
                }
                
                }, failure: { (error) in
                    print("Error receiving tagged photos: " + error!.localizedDescription)
            })
        }
    }

    
    // MARK: TableView DataSource and Delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchedPhotoArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let photoCell = tableView.dequeueReusableCell(withIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
        
        // Clear image view for preventing view blink effect when changing image in reusable cell
        photoCell.imageView?.image = nil
        photoCell.activityIndicator.startAnimating()
        
        let searchedPhoto = searchedPhotoArray[indexPath.row]
        
        // Calculate height of image view
        if let cutSizeHeight = searchedPhoto.cutSizeHeight {
            let minimumImageHeight:CGFloat = 60.0
            if cutSizeHeight > minimumImageHeight {
                photoCell.heightPhotoImage.constant = cutSizeHeight
            }
        }
        
        // Check if image was loaded and show if it was
        if searchedPhoto.photoCutSize != nil {
            photoCell.activityIndicator.stopAnimating()
            photoCell.imageView?.image = searchedPhoto.photoCutSize
            photoCell.imageView?.layer.cornerRadius = 10.0
            photoCell.imageView?.layer.masksToBounds = true
        }
        
        return photoCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let searchedPhoto = searchedPhotoArray[indexPath.row]
        let minimumImageHeight:CGFloat = 60.0
        let minimumRowHeight:CGFloat = 79.0
        
        // Resize cell height according to image height in 300 px width
        if let cutPhotoSizeHeight = searchedPhoto.cutSizeHeight {
            guard cutPhotoSizeHeight > minimumImageHeight else { return minimumRowHeight }
            let delta = cutPhotoSizeHeight - minimumImageHeight
            return minimumRowHeight + delta
        } else {
            return minimumRowHeight
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "openPhoto") {
            let viewController = segue.destination as! SinglePhotoViewController
            let indexPath = tableView.indexPathForSelectedRow
            viewController.searchedPhoto = searchedPhotoArray[(indexPath?.row)!]
        }
    }
}
