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
import FreeStreamer
import MediaPlayer

class StreamingServiceImpl: StreamingService {
    
    var player:FSAudioController
    unowned var analyser:FSFrequencyDomainAnalyzer
    var url:NSURL!
    var launched = false
    
    init(stationURL: String) {
        player = FSAudioController(url: NSURL(string: stationURL))
        self.url = NSURL(string: stationURL)
        analyser = FSFrequencyDomainAnalyzer()
        analyser.enabled = true
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
            let commandCenter = MPRemoteCommandCenter.sharedCommandCenter()
            commandCenter.nextTrackCommand.enabled = false
            commandCenter.previousTrackCommand.enabled = false
            commandCenter.togglePlayPauseCommand.enabled = true
            commandCenter.togglePlayPauseCommand.addTarget(self, action: #selector(StreamingServiceImpl.toggle))
            print("Receiving remote control events\n")
        } catch {
            print("Audio Session error.\n")
        }
    }
    
    func currentlyPlaying(trackFound : (Track -> Void)) {
        self.player.onMetaDataAvailable = { [unowned self] metaData in
            let newTrack = self.trackFromMetadata(metaData)
            MPNowPlayingInfoCenter.defaultCenter().setValuesForKeysWithDictionary(newTrack.info)
            trackFound(newTrack)
        }
    }
    
    func currentState() -> Observable<FSAudioStreamState> {
        return Observable<FSAudioStreamState>.create { [unowned self] observer in
            self.player.onStateChange = { newState in
                if newState == .FsAudioStreamPlaying && self.player.activeStream.delegate == nil {
                    self.player.activeStream.delegate = self.analyser
                }
                observer.onNext(newState)
            }
            return NopDisposable.instance
        }
    }
    
    func trackFromMetadata( metaData:[NSObject : AnyObject]? ) -> Track {
        guard metaData != nil else {
            return Track(artist: "", title: "")
        }
        var songInfo = [String : String]()
        if (metaData!["MPMediaItemPropertyTitle"] != nil) {
            songInfo[MPMediaItemPropertyTitle] = metaData!["MPMediaItemPropertyTitle"] as? String ?? ""
        }
        else if (metaData!["StreamTitle"] != nil) {
            songInfo[MPMediaItemPropertyTitle] = metaData!["StreamTitle"] as? String ?? ""
        }
        if (metaData!["MPMediaItemPropertyArtist"] != nil) {
            songInfo[MPMediaItemPropertyArtist] = metaData!["MPMediaItemPropertyArtist"] as? String ?? ""
        }
        MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = songInfo
        var streamTrack:Track?
        if songInfo[MPMediaItemPropertyArtist] != nil && songInfo[MPMediaItemPropertyTitle] != nil {
            streamTrack = Track(artist: songInfo[MPMediaItemPropertyArtist]!, title: songInfo[MPMediaItemPropertyTitle]!)
        }
        else if songInfo[MPMediaItemPropertyTitle] != nil {
            var stringParts = [String]()
            stringParts = songInfo[MPMediaItemPropertyTitle]!.componentsSeparatedByString(" - ")
            if stringParts.count > 0 {
                streamTrack = Track(artist: stringParts[0], title: stringParts[1])
            }
        }
        return streamTrack ?? Track(artist: "", title: "")
    }
    
    @objc func toggle() {
        if player.isPlaying() {
            player.stop()
        } else {
            player.play()
        }
    }
    
}
