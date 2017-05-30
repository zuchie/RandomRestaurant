//
//  NavItemTitleViewController.swift
//  randomRestaurant
//
//  Created by Zhe Cui on 5/23/17.
//  Copyright © 2017 Zhe Cui. All rights reserved.
//

import UIKit

class NavItemTitleViewController: UIViewController {

    @IBOutlet weak var chooseCategory: UIStackView!
    var completionForCategoryChoose: (() -> Void)!
    var completionForRadiusChoose: (() -> Void)!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleStackTap(_:)))
        chooseCategory.addGestureRecognizer(tap)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc private func handleStackTap(_ sender: UITapGestureRecognizer) {
        guard (sender.view != nil) else {
            fatalError("Unexpected view: \(String(describing: sender.view))")
        }
        completionForCategoryChoose()
    }
    
    @IBAction func chooseRadius(_ sender: UIButton) {
        completionForRadiusChoose()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
