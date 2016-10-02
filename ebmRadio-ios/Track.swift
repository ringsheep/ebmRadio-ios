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
    var artwork: UIImage = UIImage(named: "cover.png")!
    var info: [String : AnyObject] {
        return [MPMediaItemPropertyTitle : self.title,
                MPMediaItemPropertyArtist : self.artist,
                MPMediaItemPropertyArtwork : MPMediaItemArtwork(image: artwork)]
    }
    
    init( artist: String, title: String ) {
        self.artist = artist
        self.title = title
    }
    
    convenience init(metaData: [NSObject : AnyObject]?) {
        guard metaData != nil else {
            self.init(artist: "", title: "")
            return
        }
        var songInfo = [String : String]()
        if (metaData!["MPMediaItemPropertyTitle"] != nil) {
            songInfo[MPMediaItemPropertyTitle] = metaData!["MPMediaItemPropertyTitle"] as? String ?? ""
        }
        else if (metaData!["StreamTitle"] != nil) {
            songInfo[MPMediaItemPropertyTitle] = metaData!["StreamTitle"] as? String ?? ""
        }
        if (metaData!["MPMediaItemPropertyArtist"] != nil) {
            songInfo[MPMediaItemPropertyArtist] = metaData!["MPMediaItemPropertyArtist"] as? String ?? ""
        }
        MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = songInfo
        if songInfo[MPMediaItemPropertyArtist] != nil && songInfo[MPMediaItemPropertyTitle] != nil {
            self.init(artist: songInfo[MPMediaItemPropertyArtist]!, title: songInfo[MPMediaItemPropertyTitle]!)
        }
        else if songInfo[MPMediaItemPropertyTitle] != nil {
            var stringParts = [String]()
            stringParts = songInfo[MPMediaItemPropertyTitle]!.componentsSeparatedByString(" - ")
            if stringParts.count > 0 {
                self.init(artist: stringParts[0], title: stringParts[1])
            } else {
                self.init(artist: "", title: "")
            }
        }
        else {
            self.init(artist: "", title: "")
        }
    }
}
