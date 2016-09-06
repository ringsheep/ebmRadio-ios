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
        analyser = FSFrequencyDomainAnalyzer()
        analyser.enabled = true
    }
    
    func currentlyPlaying(trackFound : (Track -> Void)) {
        self.player.onMetaDataAvailable = { [unowned self] metaData in
            trackFound(self.doOnMetadata(metaData))
        }
    }
    
    func currentStatus(newStatus: (String -> Void)) {
        self.player.onStateChange = { [unowned self] status in
            var bitrate:Float?
            if status == .FsAudioStreamPlaying {
                self.player.activeStream.delegate = self.analyser
                bitrate = self.player.activeStream.bitRate
            }
            let statusString = self.convertStatusDataToStirng(bitrate, status: status)
            newStatus(statusString)
        }
    }
    
    func convertStatusDataToStirng(bitrate:Float?, status: FSAudioStreamState) -> String {
        var newString = ""
        if bitrate != nil {
            newString += "\(round(bitrate!/1000)) kbps, "
        }
        switch status {
        case .FsAudioStreamBuffering:
            newString += "buffering"
        case .FsAudioStreamPaused:
            newString += "paused"
        case .FsAudioStreamFailed:
            newString += "failed"
        case .FsAudioStreamPlaying:
            newString += "playing"
        case .FsAudioStreamStopped:
            newString += "stopped"
        case .FsAudioStreamRetrievingURL:
            newString += "retrieving URL"
        case .FSAudioStreamEndOfFile, .FsAudioStreamPlaybackCompleted:
            newString += "end of stream"
        case .FsAudioStreamSeeking:
            newString += "seeking"
        case .FsAudioStreamRetryingStarted:
            newString += "retrying started"
        case .FsAudioStreamRetryingFailed:
            newString += "retrying failed"
        case .FsAudioStreamRetryingSucceeded:
            newString += "retrying succeeded"
        case .FsAudioStreamUnknownState:
            newString += "wtf?!"
        }
        return newString
    }
    
    func currentBitrate() {
        self.player.activeStream.rx_observe(Float.self, "bitRate")
    }
    
    func doOnMetadata( metaData:[NSObject : AnyObject]? ) -> Track {
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
            streamTrack = Track(artist: stringParts[0], title: stringParts[1])
        }
        return streamTrack ?? Track(artist: "", title: "")
    }
    
    func play() {
        player.play()
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
            print("Receiving remote control events\n")
        } catch {
            print("Audio Session error.\n")
        }
    }
    
    func pause() {
        player.pause()
    }
    
    func toggle() {
        if launched {
            pause()
        } else {
            play()
            launched = true
        }
    }
    
    func changeVolume(withValue value: Float) {
        self.player.volume = value
    }
    
}