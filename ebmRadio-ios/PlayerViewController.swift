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
    @IBOutlet weak var volumeSlider: MPVolumeView!
    @IBOutlet weak var streamLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var frequencyPlotView: FrequencyPlotView!
    @IBOutlet weak var logoButtonTopSpace: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        streamingService = StreamingServiceImpl(stationURL: "http://87.106.138.241:7000/")
        streamingService.analyser.delegate = self.frequencyPlotView
        
        setUpLogoButton()
        setUpPlayButton()
        
        volumeSlider.backgroundColor = UIColor.clearColor()
        volumeSlider.showsVolumeSlider = true
        volumeSlider.showsRouteButton = false
        volumeSlider.tintColor = UIColor.whiteColor()
        
        self.trackArtistLabel.text = ""
        self.trackTitleLabel.text = ""
        self.logoButtonTopSpace.constant = self.view.frame.height/2 - 100
        streamingService.currentlyPlaying { [unowned self] track in
            self.trackArtistLabel.text = track.artist
            self.trackTitleLabel.text = track.title
        }
        
        let currentState = streamingService.currentState().shareReplay(1)
        
        // setting up the stream status label
        currentState
            .map{ $0.stringMessage() }
            .bindTo(self.streamLabel.rx_text)
            .addDisposableTo(disposeBag)
        
        // using the player activity state
        self.isActive = currentState.map{ $0 == .FsAudioStreamPlaying || $0 == .FsAudioStreamBuffering }.doOnNext({ [unowned self] isActive in
            if isActive {
                self.logoButtonTopSpace.constant = 20
                self.frequencyPlotView.alpha = 1.0
                self.trackArtistLabel.alpha = 1.0
                self.trackTitleLabel.alpha = 1.0
            } else {
                self.logoButtonTopSpace.constant = self.view.frame.height/2 - 100
                self.frequencyPlotView.alpha = 0.0
                self.trackArtistLabel.alpha = 0.0
                self.trackTitleLabel.alpha = 0.0
            }
            UIView.animateWithDuration(0.5) {
                self.view.layoutIfNeeded()
            }
        }).shareReplay(1)
        
        currentState
            .map({ status in
                switch status {
                case .FsAudioStreamFailed, .FsAudioStreamPaused, .FsAudioStreamPlaybackCompleted, .FSAudioStreamEndOfFile, .FsAudioStreamRetryingFailed, .FsAudioStreamStopped, .FsAudioStreamUnknownState:
                    return false
                default:
                    return true
                }
            })
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
            }
            .addDisposableTo(disposeBag)
    }
    
}

