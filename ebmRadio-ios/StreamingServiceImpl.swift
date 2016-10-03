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

class StreamingServiceImpl: NSObject, StreamingService {
    
    var player:FSAudioController
    unowned var analyser:FSFrequencyDomainAnalyzer
    var url:NSURL!
    var launched = false
    
    init(stationURL: String) {
        player = FSAudioController(url: NSURL(string: stationURL))
        url = NSURL(string: stationURL)
        analyser = FSFrequencyDomainAnalyzer()
        analyser.enabled = true
        super.init()
        
        setUpCommandCenter()
    }
    
    // MARK: Private
    
    private func setUpCommandCenter() {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
            let commandCenter = MPRemoteCommandCenter.sharedCommandCenter()
            commandCenter.nextTrackCommand.enabled = false
            commandCenter.previousTrackCommand.enabled = false
            commandCenter.pauseCommand.addTarget(self, action: #selector(StreamingServiceImpl.toggle))
            commandCenter.playCommand.addTarget(self, action: #selector(StreamingServiceImpl.toggle))
            print("Receiving remote control events\n")
        } catch {
            print("Audio Session error.\n")
        }
    }
    
    // MARK: Public
    
    func currentlyPlaying(trackFound : (Track -> Void)) {
        self.player.onMetaDataAvailable = { metaData in
            let newTrack = Track(metaData: metaData)
            MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = newTrack.info
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
    
    func toggle() {
        if player.isPlaying() {
            player.stop()
        } else {
            player.play()
        }
    }
    
}
