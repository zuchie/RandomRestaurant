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
    private var rating = 0.0
    private var ratingButtons = [UIButton]()
    private var spacing = 5
    private var starCount = 5
    private var filledStarImage: UIImage?
    private var emptyStarImage: UIImage?
    private var halfFilledStarImage: UIImage?


    // MARK: Initialization
    override func layoutSubviews() {
        let buttonSize = Int(frame.size.height)
        var buttonFrame = CGRect(x: 0, y: 0, width: buttonSize, height: buttonSize)
        
        for (index, button) in ratingButtons.enumerate() {
            buttonFrame.origin.x = CGFloat(index * (buttonSize + spacing))
            button.frame = buttonFrame
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        filledStarImage = UIImage(named: "filledStar")
        emptyStarImage = UIImage(named: "emptyStar")
        halfFilledStarImage = UIImage(named: "halfFilledStar")
    }

    override func intrinsicContentSize() -> CGSize {
        let buttonSize = Int(frame.size.height)
        let width = buttonSize * starCount + spacing * (starCount - 1)
        return CGSize(width: width, height: buttonSize)
    }
    
    // MARK: Helper functions
    
    private func getImage(rating: Double) -> UIImage? {
        if rating >= 1 {
            return filledStarImage
        } else if rating > 0 && rating < 1 {
            return halfFilledStarImage
        } else {
            return emptyStarImage
        }
    }
    
    private func setImages() {
        
        for _ in 0..<starCount {
            let button = UIButton()
            if let image = getImage(rating) {
                button.setImage(image, forState: .Normal)
                rating -= 1
            }
            
            button.adjustsImageWhenHighlighted = false
            
            ratingButtons += [button]
            addSubview(button)
        }
    }
    
    func setRating(myRating: Double) {
        rating = myRating
        print("rating: \(rating)")
        // Load stars after rating has been got.
        setImages()
    }
}
