//
//  Player.swift
//  ebmRadio-ios
//
//  Created by George Zinyakov on 19/08/16.
//  Copyright © 2016 George Zinyakov. All rights reserved.
//

import Foundation
import AVFoundation

class Player {
    
    var radio = AVPlayer()
    var track:Track?
    var isPlaying: Bool = false
}