//
//  FSAudioStreamState+ebmRadio.swift
//  ebmRadio-ios
//
//  Created by George Zinyakov on 9/27/16.
//  Copyright © 2016 George Zinyakov. All rights reserved.
//

import Foundation
import FreeStreamer

extension FSAudioStreamState {
    func stringMessage() -> String {
        var newString = ""
        switch self {
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
            newString += "connecting"
        case .FSAudioStreamEndOfFile, .FsAudioStreamPlaybackCompleted:
            newString += "radio is offline"
        case .FsAudioStreamSeeking:
            newString += "seeking"
        case .FsAudioStreamRetryingStarted:
            newString += "retrying started"
        case .FsAudioStreamRetryingFailed:
            newString += "no internet"
        case .FsAudioStreamRetryingSucceeded:
            newString += "playing"
        case .FsAudioStreamUnknownState:
            newString += "wtf?!"
        }
        print(newString)
        return newString
    }
}
