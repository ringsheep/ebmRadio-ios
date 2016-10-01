//
//  Track.swift
//  ebmRadio-ios
//
//  Created by George Zinyakov on 19/08/16.
//  Copyright © 2016 George Zinyakov. All rights reserved.
//

import Foundation
import UIKit
import MediaPlayer

class Track {
    var title: String = ""
    var artist: String = ""
    var artworkURL: String = "cover.png"
    var info:[String:String] {
        return [MPMediaItemPropertyTitle : self.title,
                MPMediaItemPropertyArtist : self.artist,
                MPMediaItemPropertyArtwork : self.artworkURL]
    }
    
    init( artist: String, title: String ) {
        self.artist = artist
        self.title = title
    }
}
