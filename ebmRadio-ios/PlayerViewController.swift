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
    
    var station: Station!
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
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.navigationBar.barStyle = .BlackTranslucent
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        self.navigationController?.navigationBar.backgroundColor = UIColor.blackColor()
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
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
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    private func setUpLogoButton() {
        let logoImage = station.logo
        self.logoButtonTopSpace.constant = self.view.frame.height/2 - 100
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
            .filter({ state -> Bool in
                switch state {
                case .FsAudioStreamBuffering, .FsAudioStreamRetrievingURL, .FsAudioStreamSeeking, .FsAudioStreamStopped, .FsAudioStreamFailed:
                    return true
                default:
                    return false
                }
            })
            .map({ state -> Bool in
                switch state {
                case .FsAudioStreamBuffering, .FsAudioStreamRetrievingURL, .FsAudioStreamSeeking:
                    return true
                case .FsAudioStreamStopped, .FsAudioStreamFailed:
                    return false
                default:
                    return false
                }
            })
            .subscribeNext({ [unowned self] active in
                if active {
                    self.playButton.selected = true
                    self.logoButtonTopSpace.constant = 20
                    UIView.animateWithDuration(0.5) {
                        self.frequencyPlotView.alpha = 1.0
                        self.trackArtistLabel.alpha = 1.0
                        self.trackTitleLabel.alpha = 1.0
                        self.view.layoutIfNeeded()
                    }
                } else {
                    self.playButton.selected = false
                    self.logoButtonTopSpace.constant = self.view.frame.height/2 - 100
                    UIView.animateWithDuration(0.5) {
                        self.frequencyPlotView.alpha = 0.0
                        self.trackArtistLabel.alpha = 0.0
                        self.trackTitleLabel.alpha = 0.0
                        self.view.layoutIfNeeded()
                    }
                }
                }).addDisposableTo(disposeBag)
    }
}

