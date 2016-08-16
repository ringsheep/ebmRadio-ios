//
//  StreamingServiceImpl.swift
//  ebmRadio-ios
//
//  Created by George Zinyakov on 10/08/16.
//  Copyright © 2016 George Zinyakov. All rights reserved.
//

import Foundation
import AVFoundation

class StreamingServiceImpl: StreamingService {
    
    private var player = AVPlayer(URL: NSURL(string: "http://87.106.138.241:7000/")!)
    var isPlaying = false
    
    func play() {
        player.play()
        
        print(player.currentItem?.tracks)
        isPlaying = true
    }
    
    func pause() {
        player.pause()
        isPlaying = false
    }
    
    func toggle() {
        if isPlaying == true {
            pause()
        } else {
            play()
        }
    }
    
    func currentlyPlaying() -> Bool {
        return isPlaying
    }
    
}