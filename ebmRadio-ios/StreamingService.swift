//
//  StreamingService.swift
//  ebmRadio-ios
//
//  Created by George Zinyakov on 10/08/16.
//  Copyright © 2016 George Zinyakov. All rights reserved.
//

import Foundation
import RxSwift

protocol StreamingService {
    var player:Player { get set }
    func play()
    func pause()
    func toggle()
    func currentlyPlaying() -> Observable<Track>
}