//
//  StationInfoViewController.swift
//  ebmRadio-ios
//
//  Created by George Zinyakov on 10/2/16.
//  Copyright © 2016 George Zinyakov. All rights reserved.
//

import UIKit

class StationInfoViewController: UIViewController {
    
    var station: Station!

    @IBOutlet weak var stationNameLabel: UILabel!
    @IBOutlet weak var stationInfoLabel: UILabel!
    @IBOutlet weak var stationUrlButton: UIButton!
    
    @IBAction func closeButtonPressed(sender: AnyObject) {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func stationUrlButtonPressed(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(fileURLWithPath: station.websiteURL))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpInfo()
    }

    func setUpInfo() {
        stationNameLabel.text = station.name
        stationInfoLabel.text = station.info
        stationUrlButton.titleLabel?.text = station.websiteURL
    }

}
