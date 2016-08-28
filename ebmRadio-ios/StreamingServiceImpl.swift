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

class StreamingServiceImpl: NSObject, StreamingService {
    
    var player:STKAudioPlayer
    var url:NSURL!
    
    init(stationURL: String) {
        player = STKAudioPlayer()
        url = NSURL(string: stationURL)
    }
    
    
//    func currentlyPlaying() -> Observable<Track> {
//        return player.audioFile.avAsset
//            .rx_observe([AVMetadataItem].self, "metadata")
//            .map { $0 ?? [] }
//            .map { $0.first ?? AVMetadataItem() }
//            .map { $0.value as? String ?? "" }
//            .map({ metaData in
//                guard metaData.isEmpty == false else {
//                    return Track(artist: "", title: "")
//                }
//                
////                print(self.player.radio.currentItem?.tracks.first?.assetTrack.asset?.tracks)
////                let ass = self.player.radio.currentItem?.tracks.first?.assetTrack.asset
////                let read = try! AVAssetReader(asset: ass!)
////                print(read)
//                
//                var stringParts = [String]()
//                stringParts = metaData.componentsSeparatedByString(" - ")
//                let newTrack = Track(artist: stringParts[0], title: stringParts[1])
//                return newTrack
//            })
//    }
    
    func play() {
        player.delegate = self
        player.playURL(url)
    }
    
    func stop() {
        player.stop()
    }
    
    func toggle() {
        print(player.state)
        switch player.state {
        case STKAudioPlayerState.Stopped:
            play()
        default:
            stop()
        }
    }
    
}