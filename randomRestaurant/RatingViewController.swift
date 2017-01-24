//
//  RatingViewController.swift
//  randomRestaurant
//
//  Created by Zhe Cui on 8/27/16.
//  Copyright © 2016 Zhe Cui. All rights reserved.
//

import UIKit

class RatingViewController: UIViewController {

    // MARK: Properties
    @IBOutlet weak var button0: UIButton!
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button3: UIButton!
    @IBOutlet weak var button4: UIButton!
    
    fileprivate var ratingButtons = [UIButton]()

    fileprivate let filledStarImage = UIImage(named: "filledStar")
    //fileprivate let emptyStarImage = UIImage(named: "emptyStar")
    fileprivate let halfFilledStarImage = UIImage(named: "halfFilledStar")
    
    fileprivate var buttonConsecutiveTapCount = 0
    fileprivate var tappedButtonIndex: Int?
    
    fileprivate var rating: Double?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("rating category: \(YelpUrlQueryParameters.category), coordinates: \(YelpUrlQueryParameters.coordinates), radius: \(YelpUrlQueryParameters.radius), limit: \(YelpUrlQueryParameters.limit), time: \(YelpUrlQueryParameters.openAt)")
        
        ratingButtons += [button0, button1, button2, button3, button4]
        
        for button in ratingButtons {
            //button.setImage(emptyStarImage, for: UIControlState())
            button.setImage(filledStarImage, for: .selected)
            button.setImage(filledStarImage, for: [.highlighted, .selected])
            button.addTarget(self, action: #selector(ratingButtonTapped(_:)), for: .touchDown)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Button Action
    func ratingButtonTapped(_ button: UIButton) {
        
        let buttonIndex = ratingButtons.index(of: button)!
        var ratingMinusPointFive = false
        
        // Not fist time tapping.
        if tappedButtonIndex != nil {
            // If same button got consecutively tapped, toggle button image; else restore to the default image.
            if tappedButtonIndex == buttonIndex {
                buttonConsecutiveTapCount += 1
                // Toggle button image when consecutive tap.
                if buttonConsecutiveTapCount % 2 == 1 {
                    button.setImage(halfFilledStarImage, for: .selected)
                    ratingMinusPointFive = true
                } else {
                    button.setImage(filledStarImage, for: .selected)
                }
            } else {
                buttonConsecutiveTapCount = 0
                ratingButtons[tappedButtonIndex!].setImage(filledStarImage, for: .selected)
            }
        }
        tappedButtonIndex = buttonIndex
        rating = Double(buttonIndex) + 1.0
        if ratingMinusPointFive {
            rating! -= 0.5
        }
        print("rating: \(rating!)")
        
        updateButtonSelectionStates()
    }
    
    fileprivate func updateButtonSelectionStates() {
        for (index, button) in ratingButtons.enumerated() {
            // If the index of a button is less than the rating, that button should be selected.
            button.isSelected = Double(index) < rating!
        }
    }
    
    func getRating() -> Double {
        // When no rating has been chosen, use 0.5 as default value.
        if rating != nil {
            return rating!
        } else {
            return 0.5
        }
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destinationVC = segue.destination
        
        if let slotMachineVC = destinationVC as? SlotMachineViewController {
            if let id = segue.identifier, id == "slotMachine" {
                slotMachineVC.getRatingBar(getRating())
                
                /*
                //print("url params: \(urlQueryParameters!)")
                print("category: \(urlQueryParameters!.category), location: \(urlQueryParameters!.coordinates), radius: \(urlQueryParameters!.radius), limit: \(urlQueryParameters!.limit), time: \(urlQueryParameters!.openAt)")
                slotMachineVC.setYelpUrlQueryParameters(urlQueryParameters!)
                */
            }
        }
    }
    

}
