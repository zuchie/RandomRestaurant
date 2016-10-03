//
//  RatingControl.swift
//  randomRestaurant
//
//  Created by Zhe Cui on 8/23/16.
//  Copyright © 2016 Zhe Cui. All rights reserved.
//

import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


class RatingControl: UIView {
    
    // MARK: Properties
    fileprivate var rating: Double? {
        didSet {
            setNeedsLayout()
            //setNeedsDisplay()
            //layoutIfNeeded()
        }
    }
    
    fileprivate var ratingButtons = [UIButton]()
    fileprivate var spacing = 5
    fileprivate var starCount = 5
    
    fileprivate var buttonConsecutiveTapCount = 0
    fileprivate var tappedButtonIndex: Int?

    fileprivate let filledStarImage = UIImage(named: "filledStar")
    fileprivate let emptyStarImage = UIImage(named: "emptyStar")
    fileprivate let halfFilledStarImage = UIImage(named: "halfFilledStar")

    // MARK: Initialization
    override func layoutSubviews() {
        
        let buttonSize = Int(frame.size.height)

        print("layout subviews buttonSize: \(buttonSize)")
        
        var buttonFrame = CGRect(x: 0, y: 0, width: buttonSize, height: buttonSize)
        
        for (index, button) in ratingButtons.enumerated() {
            buttonFrame.origin.x = CGFloat(index * (buttonSize + spacing))
            button.frame = buttonFrame
        }
        
        updateButtonSelectionStates()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        for _ in 0..<starCount {
            let button = UIButton()
            
            button.setImage(emptyStarImage, for: UIControlState())
            button.setImage(filledStarImage, for: .selected)
            button.setImage(filledStarImage, for: [.highlighted, .selected])
            
            button.adjustsImageWhenHighlighted = false
            
            button.addTarget(self, action: #selector(ratingButtonTapped(_:)), for: .touchDown)
            ratingButtons += [button]
            addSubview(button)
        }
    }

    override var intrinsicContentSize : CGSize {
        
        let buttonSize = Int(frame.size.height)
        print("intrinsic size button size: \(buttonSize)")
        let width = buttonSize * starCount + spacing * (starCount - 1)
        return CGSize(width: width, height: buttonSize)
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
            button.isSelected = Double(index) < rating
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
}
