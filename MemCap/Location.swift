//
//  Location.swift
//  MemCap
//
//  Created by Jahan Cherian on 5/19/16.
//  Copyright © 2016 Jahan Cherian. All rights reserved.
//

import Foundation
import CoreLocation
import GoogleMaps

//Singleton Class to rule over Locations

class Location : NSObject, CLLocationManagerDelegate
{
    var locationManager: CLLocationManager?
    var currLocation: CLLocation?
    var mapView: GMSMapView?
    var shouldThrowAlert = false
    
    override init() {
        super.init()
        self.locationManager = CLLocationManager()
        self.locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager?.delegate = self
    }
    
    class var sharedInstance : Location
    {
        struct Singleton
        {
            static let instance = Location()
        }
        return Singleton.instance
    }
    
    func requestLocation()
    {
        self.requestAuth()
        self.locationManager?.requestLocation()
    }
    
    func startUpdatingLocation()
    {
        self.locationManager?.startUpdatingLocation()
    }
    
    func requestAuth()
    {
        self.locationManager?.requestWhenInUseAuthorization()
    }
    
    func stopUpdatingLocation()
    {
        self.locationManager?.stopUpdatingLocation()
    }
    
    
    //Location Retrieval Error
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        self.locationManager?.stopUpdatingLocation()
        print("Location Retrieval Error")
        self.shouldThrowAlert = true
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        //If authorized to be used, then start getting location
        if status == .AuthorizedWhenInUse
        {
            Location.sharedInstance.requestLocation()
            Location.sharedInstance.startUpdatingLocation()
        }
    }
    
    //Get user's location
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        mapView?.myLocationEnabled = true
        self.currLocation = mapView?.myLocation
        
        if let location = locations.first
        {
            self.mapView?.animateToCameraPosition(GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0))
        }
        
    }
}
