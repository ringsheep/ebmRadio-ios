//
//  ViewController.swift
//  ebmRadio-ios
//
//  Created by George Zinyakov on 10/08/16.
//  Copyright © 2016 George Zinyakov. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var streamingService:StreamingService!

    override func viewDidLoad() {
        super.viewDidLoad()
        streamingService = StreamingServiceImpl()
        streamingService.startStreaming()
    }

}

