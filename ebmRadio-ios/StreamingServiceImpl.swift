//
//  StreamingServiceImpl.swift
//  ebmRadio-ios
//
//  Created by George Zinyakov on 10/08/16.
//  Copyright © 2016 George Zinyakov. All rights reserved.
//

import Foundation
import StreamingKit

class StreamingServiceImpl: StreamingService {
    
    func startStreaming() {
        let audioPlayer = STKAudioPlayer()
        
        audioPlayer.play("http://ebm-radio.org:7000/listen.pls")
    }
    
}