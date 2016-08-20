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
    
    var player:Player = Player()
    
    init(stationURL: String) {
        
        let newItem = AVPlayerItem(URL: NSURL(string: stationURL)!)
        player.radio = AVPlayer(playerItem: newItem)
        
    }
    
    func currentlyPlaying() -> Observable<Track> {
        return player.radio.currentItem!
            .rx_observe([AVMetadataItem].self, "timedMetadata")
            .map { $0 ?? [] }
            .map { $0.first ?? AVMetadataItem() }
            .map { $0.value as? String ?? "" }
            .map({ metaData in
                guard metaData.isEmpty == false else {
                    return Track(artist: "", title: "")
                }
                var stringParts = [String]()
                stringParts = metaData.componentsSeparatedByString(" - ")
                let newTrack = Track(artist: stringParts[0], title: stringParts[1])
                return newTrack
            })
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