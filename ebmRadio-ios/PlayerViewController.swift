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
    
    var station = Station(name: "EBM Radio",
                          info: "c/o Matze Watzke \nFritz-Reuter-Str. 69 \n18057 Rostock",
                          websiteURL: "http://ebm-radio.de/",
                          streamURL: "http://87.106.138.241:7000/",
                          cover: "cover.png",
                          logo: "EBM")
    var streamingService: StreamingService!
    var isActive: Bool = false
    var disposeBag = DisposeBag()
    
    @IBOutlet weak var logoButton: UIButton!
    @IBOutlet weak var trackArtistLabel: UILabel!
    @IBOutlet weak var trackTitleLabel: UILabel!
    @IBOutlet weak var volumeSlider: MPVolumeView!
    @IBOutlet weak var streamLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var frequencyPlotView: FrequencyPlotView!
    @IBOutlet weak var logoButtonTopSpace: NSLayoutConstraint!
    
    @IBAction func logoButtonPressed(sender: AnyObject) {
        self.performSegueWithIdentifier(SegueNames.fromPlayerToStationInfo, sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == SegueNames.fromPlayerToStationInfo {
            let nc = segue.destinationViewController as! UINavigationController
            let stationInfoViewController = nc.viewControllers.first! as! StationInfoViewController
            stationInfoViewController.station = station
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        streamingService = StreamingServiceImpl(stationURL: station.streamURL)
        streamingService.analyser.delegate = self.frequencyPlotView
        
        setUpLogoButton()
        setUpPlayButton()
        setUpVolumeSlider()
        
        self.trackArtistLabel.text = ""
        self.trackTitleLabel.text = ""
        streamingService.currentlyPlaying { [unowned self] track in
            self.trackArtistLabel.text = track.artist
            self.trackTitleLabel.text = track.title
        }
        
        subscribeOnPlayerState()
    }
    
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        super.willRotateToInterfaceOrientation(toInterfaceOrientation, duration: duration)
        
        if !isActive {
            self.logoButtonTopSpace.constant = self.view.frame.width/2 - 46
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    private func setUpLogoButton() {
        let logoImage = station.logo
        self.logoButtonTopSpace.constant = self.view.frame.height/2 - 46
        logoButton.setImage(logoImage, forState: UIControlState.Normal)
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
    
    private func setUpVolumeSlider() {
        volumeSlider.backgroundColor = UIColor.clearColor()
        volumeSlider.showsVolumeSlider = true
        volumeSlider.showsRouteButton = false
        volumeSlider.tintColor = UIColor.whiteColor()
    }
    
    private func subscribeOnPlayerState() {
        let currentState = streamingService.currentState().shareReplay(1)
        
        // setting up the stream status label
        currentState
            .map{ $0.stringMessage() }
            .bindTo(self.streamLabel.rx_text)
            .addDisposableTo(disposeBag)
        
        // using the player activity state
        currentState
            .subscribeNext({ [unowned self] state in
                switch state {
                case .FsAudioStreamBuffering, .FsAudioStreamRetrievingURL, .FsAudioStreamSeeking:
                    self.isActive = true
                    self.playButton.selected = true
                    self.logoButtonTopSpace.constant = 20
                    UIView.animateWithDuration(0.5) {
                        self.frequencyPlotView.alpha = 1.0
                        self.trackArtistLabel.alpha = 1.0
                        self.trackTitleLabel.alpha = 1.0
                        self.view.layoutIfNeeded()
                    }
                case .FsAudioStreamStopped, .FsAudioStreamRetryingFailed:
                    self.isActive = false
                    self.playButton.selected = false
                    self.logoButtonTopSpace.constant = self.view.frame.height/2 - 46
                    UIView.animateWithDuration(0.5) {
                        self.frequencyPlotView.alpha = 0.0
                        self.trackArtistLabel.alpha = 0.0
                        self.trackTitleLabel.alpha = 0.0
                        self.view.layoutIfNeeded()
                    }
                case .FsAudioStreamFailed:
                    self.streamingService.toggle()
                default:
                    break
                }
                }).addDisposableTo(disposeBag)
    }
}

