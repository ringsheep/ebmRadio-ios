//
//  PlayerViewController.swift
//  ebmRadio-ios
//
//  Created by George Zinyakov on 10/08/16.
//  Copyright © 2016 George Zinyakov. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import AVFoundation
import MediaPlayer
import FreeStreamer

class PlayerViewController: UIViewController {
    
    var streamingService: StreamingService!
    var isActive: Observable<Bool>!
    var disposeBag = DisposeBag()
    
    @IBOutlet weak var logoButton: UIButton!
    @IBOutlet weak var trackArtistLabel: UILabel!
    @IBOutlet weak var trackTitleLabel: UILabel!
    @IBOutlet weak var trackSlider: UISlider!
    @IBOutlet weak var streamLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var frequencyPlotView: FrequencyPlotView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        streamingService = StreamingServiceImpl(stationURL: "http://87.106.138.241:7000/")
        streamingService.analyser.delegate = self.frequencyPlotView
        
        setUpLogoButton()
        setUpPlayButton()
        
        trackSlider.rx_value
            .subscribeNext { [unowned self] (value) in
            self.streamingService.changeVolume(withValue: value)
        }
            .addDisposableTo(disposeBag)
        
        self.trackArtistLabel.text = ""
        self.trackTitleLabel.text = ""
        streamingService.currentlyPlaying { [unowned self] track in
            self.trackArtistLabel.text = track.artist
            self.trackTitleLabel.text = track.title
        }
        
        let currentState = streamingService.currentState().shareReplay(1)
        
        // setting up the stream status label
        Observable.combineLatest(currentState, streamingService.currentBitrate())
            { self.convertStatusDataToStirng($0, bitrate: $1) }
            .bindTo(self.streamLabel.rx_text)
            .addDisposableTo(disposeBag)
        
        // using the player activity state
        self.isActive = currentState.map{ $0 == .FsAudioStreamPlaying }.shareReplay(1)
        
        self.isActive
            .bindTo(self.playButton.rx_selected)
            .addDisposableTo(self.disposeBag)
        self.isActive
            .map{ !$0 }
            .bindTo(self.trackArtistLabel.rx_hidden)
            .addDisposableTo(self.disposeBag)
        self.isActive
            .map{ !$0 }
            .bindTo(self.trackTitleLabel.rx_hidden)
            .addDisposableTo(self.disposeBag)

    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    private func setUpLogoButton() {
        let origLogoImage = UIImage(named: "EBM");
        let tintedLogoImage = origLogoImage?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        logoButton.setImage(tintedLogoImage, forState: UIControlState.Normal)
    }
    
    private func setUpPlayButton() {
        // icons created by NAS from the Noun Project
        let playImage = UIImage(named: "play");
        let pauseImage = UIImage(named: "pause");
        playButton.setImage(playImage, forState: UIControlState.Normal)
        playButton.setImage(pauseImage, forState: UIControlState.Selected)
        playButton.rx_tap
            .subscribeNext { [unowned self] x in
                self.streamingService.toggle()
//                self.playButton.selected = !self.playButton.selected
            }
            .addDisposableTo(disposeBag)
    }
    
    func convertStatusDataToStirng(status: FSAudioStreamState, bitrate:Float?) -> String {
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

}

