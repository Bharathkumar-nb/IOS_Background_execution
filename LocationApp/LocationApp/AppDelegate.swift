//
//  AppDelegate.swift
//  LocationApp
//
//  Created by Bharath on 5/16/17.
//  Copyright © 2017 Bharath. All rights reserved.
//

import UIKit
import CoreLocation
import CoreMotion


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    var window: UIWindow?
    var locationManager = CLLocationManager()
    var motionManager = CMMotionManager()
    let UPDATE_FREQUENCY:TimeInterval = 30
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        print("customization after application launch")
        
        /*
            Logging: Below code is to log all the NSLog statements into a file.
            This is helpful for collecting logs when the mobile is not connected to computer.
         
        */
        // BEGIN
        var paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        let fileName = "\(Date()).log"
        let logFilePath = (documentsDirectory as NSString).appendingPathComponent(fileName)
        freopen(logFilePath.cString(using: String.Encoding.ascii)!, "a+", stderr)
        // END
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        print("applicationWillResignActive")
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        /*
         Below block of code starts location updates with high accuracy
         */
        print("Entered Background mode")
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.allowsBackgroundLocationUpdates = true
        //locationManager.pausesLocationUpdatesAutomatically = false
        
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        print(locationManager.activityType)
        
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        print("applicationWillEnterForeground")
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        print("applicationDidBecomeActive")
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        print("applicationWillTerminate")
    }

    
    /*
        Callback function of timer
        Update location accuracy setting
    */
    func updateLocationAccuracy() {
        print("Setting accuracy level to best")
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    /*
        Callback function of timer
        Record accelerometer data.
        This function records accelerometer data and sends it along with location data to the server.
    */
    func recordAccelerometerDataAndTransmit(sender: Timer) {
        
        print("Accelerometer Data: " + String(describing: motionManager.accelerometerData))
        NSLog("Accelerometer Data=" + String(describing: motionManager.accelerometerData))
        
        // Below block of code sends data to the server.
        //BEGIN
        var request = URLRequest(url: URL(string: "http://10.111.75.62/welcome.php")!)
        request.httpMethod = "POST"
        let userInfo = sender.userInfo as! NSDictionary
        let location = userInfo["location"] as! String
        let postString = "AccelerometerData=" + String(describing: motionManager.accelerometerData) + "&"  + location
        request.httpBody = postString.data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(String(describing: error))")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(String(describing: response))")
            }
            
            let responseString = String(data: data, encoding: .utf8)
            print("responseString = \(String(describing: responseString))")
        }
        task.resume()
        // END
        
        // Stop recording accelerometer data
        motionManager.stopAccelerometerUpdates()
    }
    
    //MARK: CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // If accuracy is high perform desired task, set the accuracy back to low and start a timer to set the accuracy high again
        if locationManager.desiredAccuracy == kCLLocationAccuracyBest {
            print("Printing Best accuracy locations")
            print(locations)
            NSLog("Locations: " + String(describing: locations))
            
            // Start accelerometer update
            motionManager.startAccelerometerUpdates()
            
            // accelerometerUpdateInterval could be set as needed
            //motionManager.accelerometerUpdateInterval = 0.01
            
            // The below timer is to wait for sometime before we access accelerometer data just to make sure the accelerometerData has some value.
            // Maybe we can remove this timer and perform all the task present in its callback here. I haven't checked!!
            // The timer callback takes locations as string in this example.
            Timer.scheduledTimer(timeInterval: TimeInterval(1), target: self, selector: #selector(self.recordAccelerometerDataAndTransmit(sender:)), userInfo: ["location":"Locations=" + String(describing: locations)], repeats: false)
            
            // Setting accuracy to low
            locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
            
            // Start timer to change the accuracy back to high
            Timer.scheduledTimer(timeInterval: UPDATE_FREQUENCY, target: self, selector: #selector(self.updateLocationAccuracy), userInfo: nil, repeats: false)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("Inside didChangeAuthorization")
        print(manager.location ?? "Something went wrong: No value in location object")
        if status == .authorizedAlways{
            print("Authorized")
        }
    }
}
