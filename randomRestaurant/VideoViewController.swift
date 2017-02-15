//
//  VideoViewController.swift
//  randomRestaurant
//
//  Created by Zhe Cui on 2/14/17.
//  Copyright © 2017 Zhe Cui. All rights reserved.
//

import AVKit
import AVFoundation

class VideoViewController {
    
    var playerVC: AVPlayerViewController!
    fileprivate var url: URL!
    fileprivate var player: AVPlayer!

    init(fileName: String, fileExt: String, directory: String) {
        self.url = Bundle.main.url(forResource: fileName, withExtension: fileExt, subdirectory: directory)
        player = AVPlayer(url: self.url)
        player.volume = 0
        player.actionAtItemEnd = .none
        
        playerVC = AVPlayerViewController()
        playerVC.player = player
        playerVC.videoGravity = AVLayerVideoGravityResizeAspectFill
        
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: nil) { _ in
            DispatchQueue.main.async {
                self.player.seek(to: kCMTimeZero)
                self.player.play()
            }
        }
    }
    
}
