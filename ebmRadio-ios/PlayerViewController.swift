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

class PlayerViewController: UIViewController {
    
    var disposeBag = DisposeBag()
    
    @IBOutlet weak var logoButton: UIButton!
    @IBOutlet weak var trackArtistLabel: UILabel!
    @IBOutlet weak var trackTitleLabel: UILabel!
    @IBOutlet weak var trackSlider: UISlider!
    @IBOutlet weak var streamLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var waveformView: WaveformView!
    
    var streamingService:StreamingService!

    var timer:NSTimer?
    var change:CGFloat = 0.01
    
    override func viewDidLoad() {
        super.viewDidLoad()
        streamingService = StreamingServiceImpl(stationURL: "http://87.106.138.241:7000/")
        
        setUpLogoButton()
        setUpPlayButton()
        
//        streamingService.player.radio.currentItem?.rx_timedMetadata.subscribeNext({ (meta) in
//            print(meta)
//        })
        streamingService.currentlyPlaying().subscribeNext { (track) in
            self.trackArtistLabel.text = track.artist
            self.trackTitleLabel.text = track.title
        }
        
        self.waveformView.density = 1.0
        timer = NSTimer.scheduledTimerWithTimeInterval(0.009, target: self, selector: "refreshAudioView:", userInfo: nil, repeats: true)
        
        if NSClassFromString("MPNowPlayingInfoCenter") != nil {
            //            let image:UIImage = UIImage(named: "logo_player_background")!
            //            let albumArt = MPMediaItemArtwork(image: image)
            let songInfo = [
                MPMediaItemPropertyTitle: "EBM Radio",
                MPMediaItemPropertyArtist: "87,8fm",
                //                MPMediaItemPropertyArtwork: albumArt
            ]
            MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = songInfo
        }
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
            print("Receiving remote control events\n")
        } catch {
            print("Audio Session error.\n")
        }
    }
    
    internal func refreshAudioView(_:NSTimer) {
        if self.waveformView.amplitude <= self.waveformView.idleAmplitude || self.waveformView.amplitude > 1.0 {
            self.change *= -1.0
        }
        // Simply set the amplitude to whatever you need and the view will update itself.
        self.waveformView.amplitude += self.change
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
        let origPlayImage = UIImage(named: "Play-50");
        let tintedPlayImage = origPlayImage?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        let origStopImage = UIImage(named: "Stop-50");
        let tintedStopImage = origStopImage?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        playButton.setImage(tintedPlayImage, forState: UIControlState.Normal)
        playButton.setImage(tintedStopImage, forState: UIControlState.Selected)
        playButton.rx_tap
            .subscribeNext { [unowned self] x in
                self.streamingService.toggle()
                self.playButton.selected = !self.playButton.selected
            }
            .addDisposableTo(disposeBag)
    }

}
