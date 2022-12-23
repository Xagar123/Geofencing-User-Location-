//
//  ViewController.swift
//  mapKit POC2
//
//  Created by Admin on 22/12/22.
//

import UIKit
import MapKit
import CoreLocation


class ViewController: UIViewController {
    
    
    @IBOutlet weak var addressLable: UILabel!
    var previousLocation: CLLocation?
    
    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()
    
    let regionInMeter:Double = 10000
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkLocationServices()
    }
    
    func setUpLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func centerViewOnUserLocation() {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionInMeter, longitudinalMeters: regionInMeter)
            mapView.setRegion(region, animated: true)
            
        }
    }
    
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            // set up the loation
            setUpLocationManager()
            checkLocationAuthorization()
        }else {
            //show alert
        }
        
    }
    
    func checkLocationAuthorization() {
        
        switch locationManager.authorizationStatus {
            
        case .authorizedWhenInUse:
            startTrackingUserLocation()
        case .notDetermined:
            //request when user hit allow
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            //show alert
            break
        case .denied:
            //show alert how to turn on permission
            break
        case .authorizedAlways:
            //            mapView.showsUserLocation = true
            //            centerViewOnUserLocation()
            break
        }
    }
        
        func startTrackingUserLocation() {
            mapView.showsUserLocation = true
            centerViewOnUserLocation()
            locationManager.startUpdatingLocation()
            previousLocation = getCenterLocation(for: mapView)
        }
        
        func getCenterLocation(for mapView: MKMapView) -> CLLocation {
            let latitude = mapView.centerCoordinate.latitude
            let longitude = mapView.centerCoordinate.longitude
            
            return CLLocation(latitude: latitude, longitude: longitude)
        }
        
    }

        
    
    extension ViewController: CLLocationManagerDelegate {
        
        
        func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
            checkLocationAuthorization()
        }
    }
    
    //reverse geocode
    extension ViewController: MKMapViewDelegate {
        
        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            let center = getCenterLocation(for: mapView)
            let geoCoder = CLGeocoder()
            
            guard let previousLocation = self.previousLocation else { return }
            
            guard center.distance(from: previousLocation) > 50 else { return }
            self.previousLocation = center
            
            geoCoder.reverseGeocodeLocation(center) { [weak self] (placemarks, error) in
                guard let self = self else { return }
                
                if let error = error {
                    // show alert
                    return
                }
                
                guard let placemark = placemarks?.first else {
                    // show data
                    return
                }
                
                let streetNumber = placemark.subThoroughfare ?? ""
                let streetName = placemark.thoroughfare ?? ""
                
                DispatchQueue.main.async {
                    self.addressLable.text = "\(streetNumber) \(streetName)"
                }
            }
        }
    }
