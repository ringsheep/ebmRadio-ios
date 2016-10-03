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
    
    @IBAction func stationButtonPressed(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string: station.websiteURL)!)
    }
    
    @IBAction func githubButtonPressed(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string: "https://github.com/zinyakov")!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpInfo()
    }

    func setUpInfo() {
        stationNameLabel.text = station.name
        stationInfoLabel.text = station.info
        let attributes = [NSForegroundColorAttributeName : UIColor.whiteColor(),
                          NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue]
        let attributedText = NSAttributedString(string: station.websiteURL, attributes: attributes)
        stationUrlButton.setAttributedTitle(attributedText, forState: .Normal)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }

}
