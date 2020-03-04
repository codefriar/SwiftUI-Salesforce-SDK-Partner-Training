//
//  MapView.swift
//  RedwoodsInsurance
//
//  Created by Kevin Poorman on 1/13/20.
//  Copyright © 2020 RedwoodsInsuranceOrganizationName. All rights reserved.
//

import Foundation
import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
  @EnvironmentObject var env: Env
  @Binding var mapView: MKMapView
  let address: String
  let contactName: String

  func makeUIView(context: Context) -> MKMapView {
    mapView.delegate = context.coordinator
    return mapView
  }

  func updateUIView(_ view: MKMapView, context: Context) {

  }

  func makeCoordinator() -> MapView.Coordinator {
    Coordinator(self, contactName: contactName)
  }

  class Coordinator: NSObject, MKMapViewDelegate {
    var parent: MapView
    let locationManager = CLLocationManager()
    var mkMapView: MKMapView!
    let regionRadius = 150.0
    let contactName: String
    var firstPlacemark: CLPlacemark?

    init(_ parent: MapView, contactName:String) {
      self.parent = parent
      self.contactName = contactName
      self.mkMapView = self.parent.mapView
      super.init()

      locationManager.desiredAccuracy = kCLLocationAccuracyBest

      if checkLocationAuthorizationStatus() == true {
        centerMap(on: coordinates(from: self.parent.address))
      }

      mkMapView.mapType = .standard
      mkMapView.isZoomEnabled = true
      mkMapView.isScrollEnabled = true
      mkMapView.clipsToBounds = true
      mkMapView.layer.cornerRadius = 6
    }

    func checkLocationAuthorizationStatus() -> Bool? {
      if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
        locationManager.startUpdatingLocation()
        return true
      } else {
        locationManager.requestWhenInUseAuthorization()
        return nil
      }
    }

    func coordinates(from address: String) -> CLLocation {
      let geoCoder = CLGeocoder()
      var location: CLLocation = CLLocation()
      geoCoder.geocodeAddressString(address) { (placemarks, _) in
        guard let placemarks = placemarks,
          let firstLocation = placemarks.first?.location
          else {
            return
        }

        self.firstPlacemark = placemarks.first
        location = firstLocation
        self.centerMap(on: firstLocation)
        let annotation = MKPointAnnotation()
        annotation.coordinate = firstLocation.coordinate
        annotation.title = self.contactName
        annotation.subtitle = address

        self.mkMapView.addAnnotation(annotation)
      }
      return location
    }

    private func centerMap(on location: CLLocation) {
      let coordinateRegion = MKCoordinateRegion.init(center: location.coordinate,
                                                     latitudinalMeters: regionRadius,
                                                     longitudinalMeters: regionRadius)
      self.mkMapView?.setRegion(coordinateRegion, animated: true)
    }

    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
      _ = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
    }

    func mapView(_ mapView: MKMapView,
                 viewFor annotation: MKAnnotation) -> MKAnnotationView? {

      if annotation is MKUserLocation {
        return nil
      }

      let reuseId = "ContactLocation"
      let button = UIButton()
//      button.setTitle("Open", for: .normal)
      button.setImage(UIImage(systemName: "map.fill"), for: .normal)
      button.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
      var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
      if pinView == nil {
        pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        pinView!.canShowCallout = true
        pinView!.animatesDrop = true
        pinView!.pinTintColor = .purple
        pinView!.rightCalloutAccessoryView = button
      } else {
        pinView!.annotation = annotation
      }

      return pinView
    }

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
      guard let location = self.firstPlacemark?.location else {return}
      let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: location.coordinate, addressDictionary: ["name":self.contactName]))
      mapItem.name = self.contactName

      let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
      mapItem.openInMaps(launchOptions: launchOptions)
    }
  }

}
