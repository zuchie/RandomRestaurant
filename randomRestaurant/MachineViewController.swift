//
//  MachineViewController.swift
//  randomRestaurant
//
//  Created by Zhe Cui on 9/8/16.
//  Copyright © 2016 Zhe Cui. All rights reserved.
//

import UIKit

class MachineViewController: UIViewController {
    
    var imageView: UIImageView!
    
    private let animationImages = [
        UIImage(named: "image0")!,
        UIImage(named: "image1")!,
        UIImage(named: "image2")!,
        UIImage(named: "image3")!,
        UIImage(named: "image4")!,
        UIImage(named: "image5")!,
        UIImage(named: "image6")!
    ]
    
    var imageViews = [UIImageView]()
    
    private var imageViewFrameWidth: CGFloat = 0.0
    private var imageViewFrameHeight: CGFloat = 0.0
    private var imageViewFrameX: CGFloat = 0.0
    private var imageViewFrameY: CGFloat = 0.0
    
    var imagesFrameY = [CGFloat]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*
        print("machine view did load")
        imageViewFrameWidth = view.frame.width
        imageViewFrameHeight = view.frame.height
        imageViewFrameX = view.frame.origin.x
        imageViewFrameY = view.frame.origin.y
        
        print("frame origin: \(view.frame.origin.x), \(view.frame.origin.y)")
        
        // Init image views.
        for index in 0..<animationImages.count {
            imageView = UIImageView()
            imageView.image = self.animationImages[index]
            
            imageView.frame = CGRect(x: imageViewFrameX, y: imageViewFrameY - CGFloat(index) * imageViewFrameHeight, width: imageViewFrameWidth, height: imageViewFrameHeight)
            
            imagesFrameY.append(imageView.frame.origin.y)
            
            view.addSubview(imageView)
            
            // Don't allow images block button.
            //view.sendSubviewToBack(imageView)
            imageViews.append(imageView)
            
            print("image view x: \(imageView.frame.origin.x), y: \(imageView.frame.origin.y), height: \(imageView.frame.height), width: \(imageView.frame.width)")
        }
        */
        //view.addObserver(self, forKeyPath: "frame.width", options: NSKeyValueObservingOptions.New, context: nil)
    }

    override func viewDidAppear(animated: Bool) {
        
        print("machine view did load")
        imageViewFrameWidth = view.frame.width
        imageViewFrameHeight = view.frame.height
        imageViewFrameX = view.frame.origin.x
        imageViewFrameY = view.frame.origin.y
        
        // Init image views.
        for index in 0..<animationImages.count {
            imageView = UIImageView()
            imageView.image = self.animationImages[index]
            
            imageView.frame = CGRect(x: imageViewFrameX, y: imageViewFrameY - CGFloat(index) * imageViewFrameHeight, width: imageViewFrameWidth, height: imageViewFrameHeight)
            
            imagesFrameY.append(imageView.frame.origin.y)
            
            view.addSubview(imageView)
            
            // Don't allow images block button.
            //view.sendSubviewToBack(imageView)
            imageViews.append(imageView)
            
            print("image view x: \(imageView.frame.origin.x), y: \(imageView.frame.origin.y), height: \(imageView.frame.height), width: \(imageView.frame.width)")
        }

    }
    
    /*
    override func viewWillAppear(animated: Bool) {
        view.addObserver(self, forKeyPath: "frame.width", options: NSKeyValueObservingOptions.New, context: nil)
    }
    */
    /*
    override func viewDidLayoutSubviews() {
        

    }
    */
    
    /*
     // Deregister observer.
     override func viewWillDisappear(animated: Bool) {
     view.removeObserver(self, forKeyPath: "myLocation")
     }
     */
    /*
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        print("key path changed")
        if keyPath == "frame.width" && (object?.isKindOfClass(UIView))! {
            
            imageViewFrameWidth = view.frame.width
            imageViewFrameHeight = view.frame.height
            imageViewFrameX = view.frame.origin.x
            imageViewFrameY = view.frame.origin.y
            
            // Init image views.
            for (index, view) in imageViews.enumerate() {
                
                imageView.frame = CGRect(x: imageViewFrameX, y: imageViewFrameY - CGFloat(index) * imageViewFrameHeight, width: imageViewFrameWidth, height: imageViewFrameHeight)
                
                imagesFrameY.append(imageView.frame.origin.y)
                
                //view.addSubview(imageView)
                view.layoutIfNeeded()
                
                // Don't allow images block button.
                //view.sendSubviewToBack(imageView)
                //imageViews.append(imageView)
                
                print("image view x: \(imageView.frame.origin.x), y: \(imageView.frame.origin.y), height: \(imageView.frame.height), width: \(imageView.frame.width)")
            }

        }
        view.removeObserver(self, forKeyPath: "frame.width")
    }
    */
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
