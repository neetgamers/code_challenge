//
//  VenuesVM.swift
//  TEG_Code_Challenge
//
//  Created by Ray on 5/8/25.
//

import Foundation
import RxSwift
import UIKit
import CoreLocation

class VenuesVM:NSObject {
    
    var location = BehaviorSubject<CLLocation?>(value: nil)
    var presentState = PublishSubject<UIViewController>()
    var pushNavState = PublishSubject<UIViewController>()
    
    var venues = BehaviorSubject<[VenueModel]>(value: [])
    
    private let venuesService = TEGVenueService(client: SecureAPIClient())
    
    private let manager = CLLocationManager()
    private var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    override init() {
        super.init()
    }
    
    func beginLocationService() {
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    
    func beginSearchVenue() {
        guard let loc = try? location.value() else { return }
        Task {
            guard let result = try? await venuesService.fetchVenues(lat: loc.coordinate.latitude, lng: loc.coordinate.longitude) else { return }
            
            switch result {
            case .success(let venues):
                await MainActor.run {
                    self.venues.onNext(venues)
                }
                
            case .failure(let error):
                await MainActor.run {
                    self.showErrorAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }
    }
    
    func openScanTicket(item:VenueModel) {
        let scanner = ScanTicketVC()
        scanner.viewModel.venue.onNext(item)
        pushNavState.onNext(scanner)
    }
}

// MARK: - Error Alert
extension VenuesVM {
    private func showErrorAlert(title:String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: { action in
            self.beginSearchVenue()
        }))
        presentState.onNext(alert)
    }
}

extension VenuesVM: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let loc = locations.first {
            guard let _ = try? location.value() else {
                location.onNext(loc)
                self.beginSearchVenue()
                return
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            manager.startUpdatingLocation()
        } else if status == .denied {
            locationPermissionDenied()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        print("❌ Location update failed: \(error.localizedDescription)")
        locationPermissionDenied()
    }
}

extension VenuesVM {
    private func locationPermissionDenied() {
        let alert = UIAlertController(title: "Location Permission Denied", message: "Enable location permission in Settings to use this feature.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Open Settings", style: .default, handler: { action in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        presentState.onNext(alert)
    }
}

extension Reactive where Base: VenuesVM {
    
}
