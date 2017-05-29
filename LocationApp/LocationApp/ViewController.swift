//
//  ViewController.swift
//  LocationApp
//
//  Created by Bharath on 5/16/17.
//  Copyright © 2017 Bharath. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    // MARK: Properties
    @IBOutlet weak var latitude: UILabel!
    @IBOutlet weak var longitude: UILabel!
    
    var toggle = true
    var locationManager = CLLocationManager()
    var startLocation:CLLocation!
    var isStartUpdateLocationcalled:Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // initialize location manager
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        isStartUpdateLocationcalled = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print(locationManager.location ?? "Something went wrong: No value in location object")
        if status == .authorizedAlways{
            if manager.location != nil {
                latitude.text = String(manager.location!.coordinate.latitude)
                longitude.text = String(manager.location!.coordinate.longitude)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let latestLocation: CLLocation = locations[locations.count - 1]
        print("Entered location update")
        print(latestLocation)
        print("Number of locations")
        print(locations.count)
        latitude.text = String(latestLocation.coordinate.latitude)
        longitude.text = String(latestLocation.coordinate.longitude)
        locationManager.stopUpdatingLocation()
        isStartUpdateLocationcalled = false
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }

    // MARK: Actions
    @IBAction func refreshButton(_ sender: UIButton) {
        
        if !isStartUpdateLocationcalled {
            locationManager.startUpdatingLocation()
            isStartUpdateLocationcalled = true
        }
        else{
            print("Already recording location")
        }
    }
}

