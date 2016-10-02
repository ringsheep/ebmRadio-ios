//
//  StationsViewController.swift
//  ebmRadio-ios
//
//  Created by George Zinyakov on 10/2/16.
//  Copyright © 2016 George Zinyakov. All rights reserved.
//

import UIKit

class StationsViewController: UIViewController {
    
    var stations: [Station] = [Station]()
    var selectedStation: Station!
    
    @IBOutlet weak var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()

        let station = Station(name: "EBM Radio", info: "c/o Matze Watzke \nFritz-Reuter-Str. 69 \n18057 Rostock", websiteURL: "http://ebm-radio.de/", streamURL: "http://87.106.138.241:7000/", cover: "cover.png", logo: "EBM")
        stations = [station, station, station, station, station]
        self.collectionView.scrollsToTop = false
        self.automaticallyAdjustsScrollViewInsets = false
        self.collectionView.reloadData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == SegueNames.fromStationsToPlayer {
            let playerViewController = segue.destinationViewController as! PlayerViewController
            playerViewController.station = selectedStation
        }
    }

}

extension StationsViewController : UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return stations.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("StationCollectionViewCell", forIndexPath: indexPath) as! StationCollectionViewCell
        cell.stationCover.image = stations[indexPath.row].cover
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        return CGSizeMake(145, 145)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(10, 10, 10, 10)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)
        self.selectedStation = stations[indexPath.row]
        self.performSegueWithIdentifier(SegueNames.fromStationsToPlayer, sender: nil)
    }
}
