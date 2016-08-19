//
//  StreamingServiceImpl.swift
//  ebmRadio-ios
//
//  Created by George Zinyakov on 10/08/16.
//  Copyright © 2016 George Zinyakov. All rights reserved.
//

import Foundation
import AVFoundation
import RxSwift

class StreamingServiceImpl: StreamingService {
    
    let player = Player()
    
    init(stationURL: String) {
        
        let newItem = AVPlayerItem(URL: NSURL(string: stationURL)!)
        player.radio = AVPlayer(playerItem: newItem)
        player.radio
            .rx_observe(AnyObject.self, "timedMetadata", options: [.Initial, .New], retainSelf: false)
            .subscribeNext { (object) in
            
            let data: AVPlayerItem = object as! AVPlayerItem
            for item in data.timedMetadata! as [AVMetadataItem] {
                print(item.value)
            }
            
        }.dispose()
    }
    
    func play() {
        player.radio.play()
        player.isPlaying = true
    }
    
    func pause() {
        player.radio.pause()
        player.isPlaying = false
    }
    
    func toggle() {
        if player.isPlaying == true {
            pause()
        } else {
            play()
        }
    }
    
    func currentlyPlaying() -> Bool {
        return player.isPlaying
    }
    
}