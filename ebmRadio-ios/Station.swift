//
//  Station.swift
//  ebmRadio-ios
//
//  Created by George Zinyakov on 10/2/16.
//  Copyright © 2016 George Zinyakov. All rights reserved.
//

import Foundation
import UIKit

class Station {
    var name: String
    var info: String
    var websiteURL: String
    var streamURL: String
    var cover: UIImage
    var logo: UIImage
    
    init(name: String, info: String, websiteURL: String, streamURL: String, cover: String, logo: String) {
        self.cover = UIImage(named: cover)!
        self.logo = UIImage(named: logo)!
        self.name = name
        self.info = info
        self.websiteURL = websiteURL
        self.streamURL = streamURL
    }
}
