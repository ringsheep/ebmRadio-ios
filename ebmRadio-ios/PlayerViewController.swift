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
    @IBOutlet weak var frequencyPlotView: FSFrequencyPlotView!
    
    var streamingService:StreamingService!

    var timer:NSTimer?
    var change:CGFloat = 0.01
    
    override func viewDidLoad() {
        super.viewDidLoad()
        streamingService = StreamingServiceImpl(stationURL: "http://87.106.138.241:7000/")
        streamingService.analyser.delegate = self.frequencyPlotView
        
        setUpLogoButton()
        setUpPlayButton()
        
        streamingService.currentlyPlaying { [unowned self] track in
            self.trackArtistLabel.text = track.artist
            self.trackTitleLabel.text = track.title
        }
        
        streamingService.currentStatus { [unowned self] status in
            self.streamLabel.text = status
        }
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
                self.playButton.selected = !self.playButton.selected
            }
            .addDisposableTo(disposeBag)
    }

}

