//
//  RadiusViewController.swift
//  randomRestaurant
//
//  Created by Zhe Cui on 5/30/17.
//  Copyright © 2017 Zhe Cui. All rights reserved.
//

import UIKit


class RadiusViewController: UIViewController {
    
    private(set) var radius: Int? = 0
    private(set) var selectedButtonIndex: Int?
    lazy var buttons: [UIButton] = {
        return self.view.subviews.filter({ $0 is UIButton }) as! [UIButton]
    }()
    
    //private(set) var firstSelectedButtonIndex: Int?
    /*
    private var numberOfButtons: Int {
        return view.subviews.count
    }
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setButtonsStatus(selectedButtonIndex: selectedButtonIndex, buttons: buttons)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func halfMile(_ sender: UIButton) {
        radius = 800
        selectedButtonIndex = 1
        setButtonsStatus(selectedButtonIndex: selectedButtonIndex, buttons: buttons)
    }

    @IBAction func oneMile(_ sender: UIButton) {
        radius = 3200
        selectedButtonIndex = 0
        setButtonsStatus(selectedButtonIndex: selectedButtonIndex, buttons: buttons)
    }
    
    func getSelectedButtonIndex(_ index: Int?) {
        selectedButtonIndex = index
    }
    
    private func setButtonsStatus(selectedButtonIndex: Int?, buttons: [UIButton]) {
        if let selectedIndex = selectedButtonIndex {
            for (index, button) in buttons.enumerated() {
                if index == selectedIndex {
                    button.isSelected = true
                    button.backgroundColor = UIColor.gray
                } else {
                    button.isSelected = false
                    button.backgroundColor = UIColor.clear
                }
            }
        } else {
            for button in buttons {
                button.isSelected = false
                button.backgroundColor = UIColor.clear
            }
        }
    }
    
    /*
    func getSelectedButtonIndices(from firstSelectedIndex: Int?) -> [Int]? {
        var indices: [Int]?
        
        
    }
    
    func getFirstSelectedButtonIndex(buttons: [UIButton]) -> Int? {
        for (index, button) in buttons.enumerated() {
            if button.isSelected {
                return index
            }
        }
        return nil
    }
    */
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension CALayer {
    var borderUIColor: UIColor {
        get {
            return UIColor(cgColor: borderColor!)
        }
        set {
            borderColor = newValue.cgColor
        }
    }
}

/*
extension UIView {
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
}
*/
