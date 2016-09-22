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
        
        // Download images for every part
        for arrayOfPhotoItems in arrayOfSubarrays {
            
            // Parse server items to photo objects and add them to table view
            let receivedSearchedPhotoArray = PhotoItemsParser().parsePhotoItemsToModel(itemsArray: arrayOfPhotoItems)
            searchedPhotoArray += receivedSearchedPhotoArray
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
        
        // Check if image was loaded and show if it is
        if searchedPhoto.photoCutSize != nil {
            photoCell.activityIndicator.stopAnimating()
            photoCell.imageView?.image = searchedPhoto.photoCutSize
        }
        
        return photoCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let searchedPhoto = searchedPhotoArray[indexPath.row]
        let minimumImageHeight:CGFloat = 60.0
        let minimumRowHeight:CGFloat = 79.0
        
        if let cutSizeHeight = searchedPhoto.cutSizeHeight {
            guard cutSizeHeight > minimumImageHeight else { return minimumRowHeight }
            let delta = cutSizeHeight - minimumImageHeight
            return minimumRowHeight + delta
        } else {
            return minimumRowHeight
        }
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
