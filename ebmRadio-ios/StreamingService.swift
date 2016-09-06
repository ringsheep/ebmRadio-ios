//
//  StreamingService.swift
//  ebmRadio-ios
//
//  Created by George Zinyakov on 10/08/16.
//  Copyright © 2016 George Zinyakov. All rights reserved.
//

import Foundation
import FreeStreamer
import RxSwift

protocol StreamingService {
    var analyser:FSFrequencyDomainAnalyzer {get set}
    func play()
    func pause()
    func toggle()
    func currentlyPlaying(trackFound : (Track -> Void))
    func currentStatus(newStatus: (String -> Void))
    func changeVolume(withValue value: Float)
}