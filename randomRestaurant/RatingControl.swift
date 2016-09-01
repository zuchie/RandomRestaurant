//
//  RatingControl.swift
//  randomRestaurant
//
//  Created by Zhe Cui on 8/23/16.
//  Copyright © 2016 Zhe Cui. All rights reserved.
//

import UIKit

class RatingControl: UIView {
    
    // MARK: Properties
    private var rating: Double? {
        didSet {
            setNeedsLayout()
        }
    }
    
    private var ratingButtons = [UIButton]()
    private var spacing = 5
    private var starCount = 5
    
    private var buttonConsecutiveTapCount = 0
    private var tappedButtonIndex: Int?

    private let filledStarImage = UIImage(named: "filledStar")
    private let emptyStarImage = UIImage(named: "emptyStar")
    private let halfFilledStarImage = UIImage(named: "halfFilledStar")

    // MARK: Initialization
    override func layoutSubviews() {
        let buttonSize = Int(frame.size.height)

        var buttonFrame = CGRect(x: 0, y: 0, width: buttonSize, height: buttonSize)
        
        for (index, button) in ratingButtons.enumerate() {
            buttonFrame.origin.x = CGFloat(index * (buttonSize + spacing))
            button.frame = buttonFrame
        }
        
        updateButtonSelectionStates()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        for _ in 0..<starCount {
            let button = UIButton()
            
            button.setImage(emptyStarImage, forState: .Normal)
            button.setImage(filledStarImage, forState: .Selected)
            button.setImage(filledStarImage, forState: [.Highlighted, .Selected])
            
            button.adjustsImageWhenHighlighted = false
            
            button.addTarget(self, action: #selector(ratingButtonTapped(_:)), forControlEvents: .TouchDown)
            ratingButtons += [button]
            addSubview(button)
        }
    }

    override func intrinsicContentSize() -> CGSize {
        let buttonSize = Int(frame.size.height)
        let width = buttonSize * starCount + spacing * (starCount - 1)
        return CGSize(width: width, height: buttonSize)
    }

    // MARK: Button Action
    func ratingButtonTapped(button: UIButton) {
        
        let buttonIndex = ratingButtons.indexOf(button)!
        var ratingMinusPointFive = false

        // Not fist time tapping.
        if tappedButtonIndex != nil {
            // If same button got consecutively tapped, toggle button image; else restore to the default image.
            if tappedButtonIndex == buttonIndex {
                buttonConsecutiveTapCount += 1
                // Toggle button image when consecutive tap.
                if buttonConsecutiveTapCount % 2 == 1 {
                    button.setImage(halfFilledStarImage, forState: .Selected)
                    ratingMinusPointFive = true
                } else {
                    button.setImage(filledStarImage, forState: .Selected)
                }
            } else {
                buttonConsecutiveTapCount = 0
                ratingButtons[tappedButtonIndex!].setImage(filledStarImage, forState: .Selected)
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
    
    private func updateButtonSelectionStates() {
        for (index, button) in ratingButtons.enumerate() {
            // If the index of a button is less than the rating, that button should be selected.
            button.selected = Double(index) < rating
        }
    }
    
    func getRating() -> Double {
        return rating!
    }
}
