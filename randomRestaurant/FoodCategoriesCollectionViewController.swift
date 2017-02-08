//
//  FoodCategoriesCollectionViewController.swift
//  randomRestaurant
//
//  Created by Zhe Cui on 11/29/16.
//  Copyright © 2016 Zhe Cui. All rights reserved.
//

import UIKit


class FoodCategoriesCollectionViewController: UICollectionViewController {
    
    // MARK: - Properties
    fileprivate let sectionInsets = UIEdgeInsets(top: 5.0, left: 5.0, bottom: 5.0, right: 5.0)
    fileprivate let itemsPerRow = 3

    fileprivate var foodCategories = [FoodCategories]()
    
    fileprivate var foodCategoriesName = ["Chinese", "Mexican", "Italian", "NewAmerican", "TradAmerican", "French"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print("categories category: \(YelpUrlQueryParameters.category), coordinates: \(YelpUrlQueryParameters.coordinates), radius: \(YelpUrlQueryParameters.radius), limit: \(YelpUrlQueryParameters.limit), time: \(YelpUrlQueryParameters.openAt)")
        
        for categoryName in foodCategoriesName.enumerated() {
            loadFoodCategories(categoryName.element)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Preserve selection between presentations.
        // Only false can make didDeselectItemAt work.
        // When select a different cell, the previously selected cell will be deselected first.
        self.clearsSelectionOnViewWillAppear = false
    }

    // Restore.
    override func viewWillDisappear(_ animated: Bool) {
        self.clearsSelectionOnViewWillAppear = true
    }
    
    func loadFoodCategories(_ name: String) {
        let photo = UIImage(named: name.lowercased())!
        let food = FoodCategories(name: name, photo: photo)!
        foodCategories += [food]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return foodCategories.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FoodCategoriesCell", for: indexPath) as! FoodCategoriesCollectionViewCell
    
        // Configure the cell
        let foodCategory = foodCategories[(indexPath as NSIndexPath).row]
        
        cell.nameLabel.text = foodCategory.name
        cell.photoImageView.image = foodCategory.photo
        
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        
        return true
    }
    */
    
    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        
        let cell = collectionView.cellForItem(at: indexPath) as! FoodCategoriesCollectionViewCell
        
        cell.layer.borderWidth = 2
        cell.layer.borderColor = UIColor.darkGray.cgColor
        
        return true
    }
    */
    
    // Highlight selected cell & pass data.
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedCell = collectionView.cellForItem(at: indexPath) as! FoodCategoriesCollectionViewCell
        
        selectedCell.layer.borderWidth = 2.0
        selectedCell.layer.borderColor = UIColor.brown.cgColor
        
        YelpUrlQueryParameters.category = selectedCell.nameLabel.text?.lowercased()
    }
    
    // Clear highlight.
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let deselectedCell = collectionView.cellForItem(at: indexPath) {
            deselectedCell.layer.borderColor = UIColor.clear.cgColor
        }
    }
 
    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}

// Flow Layout.
extension FoodCategoriesCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    // Calculate Cell size.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding = sectionInsets.left * CGFloat(itemsPerRow + 1)
        let availableWidth = view.frame.width - padding
        let itemWidth = availableWidth / CGFloat(itemsPerRow)
        
        return CGSize(width: itemWidth, height: itemWidth * 1.5)
    }
    
    /*
    // Space between cells.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
 
    // Space between each line.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
    */
}
