//
//  UIMapsUtils.swift
//  DansMaRue
//
//  Created by xavier.noel on 28/03/2017.
//  Copyright © 2017 VilleDeParis. All rights reserved.
//

import Foundation
import UIKit

import GoogleMaps
import GooglePlaces

class MapsUtils : NSObject {
    
    // MARK: - Properties
    private static var currentLocation = CLLocationCoordinate2D()
    static var addressLabel = ""
    static var boroughLabel = ""
    static var postalCode = ""
    static var locality = ""
    static let villePC = ["L\'Île-Saint-Denis", "Aubervilliers","Épinay-sur-Seine","La Courneuve","Pierrefitte-sur-Seine","Saint-Denis","Saint-Ouen","Villetaneuse","Stains","Saint-Ouen-sur-Seine"]
        
    open class func filterToParis(resultsViewController: GMSAutocompleteResultsViewController) {
        
        // Set bounds to inner-west Paris.
        let neBoundsCorner = CLLocationCoordinate2D(latitude: 48.96172994133251,
                                                    longitude: 2.4158300515151954)
        let swBoundsCorner = CLLocationCoordinate2D(latitude: 48.89876690521168,
                                                    longitude: 2.3084427954436837)
        let bounds = GMSCoordinateBounds(coordinate: neBoundsCorner,
                                         coordinate: swBoundsCorner)
        
        resultsViewController.autocompleteBounds = bounds
        
        // Specify the place data types to return.
        let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.name.rawValue) | UInt(GMSPlaceField.placeID.rawValue) | UInt(GMSPlaceField.formattedAddress.rawValue) | UInt(GMSPlaceField.addressComponents.rawValue) | UInt(GMSPlaceField.coordinate.rawValue) )!
        resultsViewController.placeFields = fields
        
        // Set up the autocomplete filter.
        let filter = GMSAutocompleteFilter()
        filter.type = .address
        filter.country = "FR"
        
        resultsViewController.autocompleteFilter = filter

    }
    
    
    // MARK: - Other Methods
    open class func userLocation() -> CLLocationCoordinate2D? {
        if MapsUtils.currentLocation.latitude == 0 {
            return nil
        }
        return MapsUtils.currentLocation
    }
    
    open class func set(userLocation: CLLocationCoordinate2D) {
        MapsUtils.currentLocation = userLocation
    }
    
    // Retourne le numero d'arrondissement
    open class func boroughLabel(postalCode: String) -> String {
        var boroughLabel = postalCode
        if postalCode.hasPrefix(Constants.prefix93) {
            let cp = String(postalCode.suffix(2))
            if let cpint = Int(cp) {
                boroughLabel = (cpint==1 ? "\(cpint) er" : "\(cpint) ème")
            }
        }
        
        return boroughLabel
    }
    
    
    open class func fullAddress() -> String {
        return "\(MapsUtils.addressLabel), \(MapsUtils.postalCode) \(MapsUtils.locality)"
    }
    
    open class func fullAddress(gmsAddress: GMSAddress) -> String {
        return "\(gmsAddress.thoroughfare ?? ""), \(gmsAddress.postalCode ?? "") \(gmsAddress.locality ?? "")"
    }
    
    open class func getStreetAddress(address: String) -> String {
        
        let address = address
        let regexp = "93[0-9][0-9][0-9]"
        if let range = address.range(of:regexp, options: .regularExpression) {
            let rue = address.substring(to:range.lowerBound)
            return rue
        } else {
            print("##### Rue hors Paris")
        }
        return ""
    }
    
    
    open class func getPostalCode(address: String) -> String {
        
        let address = address
        let regexp = "93[0-9][0-9][0-9]"
        if let range = address.range(of:regexp, options: .regularExpression) {
            let cp = address.substring(with:range)
            return cp
        } else {
            print("##### Code postal hors Paris")
        }
        return ""
    }
    
    
    open class func addMarker(withName name: String, coordinate: CLLocationCoordinate2D, inMap mapView: GMSMapView) {
        // Suppression de tous les markers
        mapView.clear()
        
        let marker = GMSMarker()
        marker.position = coordinate
        marker.title = name
        marker.map = mapView
        
    }
    
    open class func getAddressFromCoordinate(lat: Double, long: Double, onCompletion: @escaping (GMSAddress) -> Void) {
        
        let geocoder = GMSGeocoder()
        
        geocoder.reverseGeocodeCoordinate(CLLocationCoordinate2D(latitude: lat, longitude: long)) {
            (response: GMSReverseGeocodeResponse?, error: Error?) in
            if let error = error {
                print("Nothing found: \(error.localizedDescription)")
                return
            }
            if let addressFound = response {
                let address = addressFound.firstResult()
                onCompletion(address!)
            }
            
        }
    }
    
    //Récupération des coordonnées via l'adresse
    open class func getCoordinateFromAddress(adresse: String, onCompletion: @escaping (CLLocationCoordinate2D) -> Void) {
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(adresse) { (placemarks, error) in
            guard
                let placemarks = placemarks,
                let location = placemarks.first?.location
            else {
                // no location found
                return
            }
            onCompletion(location.coordinate)
        }
    }
    
    //Vérifie que l'adresse est bien dans Plaine Commune
    open class func isInPC(locality: String)  -> Bool {
        return villePC.contains(locality)
    }
}





