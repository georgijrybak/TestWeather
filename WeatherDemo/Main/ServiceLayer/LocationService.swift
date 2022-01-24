//
//  LocationService.swift
//  WeatherDemo
//
//  Created by Георгий Рыбак on 20.01.22.
//

import Foundation
import CoreLocation

struct Location {
    let lat: Double
    let lon: Double
}

protocol LocationServiceDelegate: AnyObject {
    func didUpdateLocation(location: Location)
    func didntUpdateLocation()
    func locationIsDisabled()
}

class LocationService: NSObject, CLLocationManagerDelegate {
    weak var delegate: LocationServiceDelegate?

    private let locationManager = CLLocationManager()
    private var location: Location?  // Location(lat: Double, lon: Double)

    override init() {
        super.init()

        self.locationManager.requestWhenInUseAuthorization()

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func requestLocation() { // Request called from current VC presenter
        locationManager.requestLocation()
    }

    func startUpdatingLocation() { // Start updating called from forecast VC presenter
        locationManager.startUpdatingLocation()
    }

    func stopUpdatingLocation() { // Stop updating called from forecast VC presenter
        locationManager.stopUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let locValue = locations.last {
            let location = Location(lat: locValue.coordinate.latitude, lon: locValue.coordinate.longitude)
            self.delegate?.didUpdateLocation(location: location)
            self.stopUpdatingLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if CLLocationManager.locationServicesEnabled() {
            delayWithSeconds(15) {
                if self.location == nil {
                    self.delegate?.didntUpdateLocation()
                }
            }
        } else {
            self.delegate?.locationIsDisabled()
        }
        print(error.localizedDescription)
    }
}
