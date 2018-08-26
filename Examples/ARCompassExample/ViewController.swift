//
//  ViewController.swift
//  ARCompassExample
//
//  Created by Paolo Di Lorenzo on 8/26/18.
//  Copyright © 2018 Paolo Di Lorenzo. All rights reserved.
//

import MapKit
import CoreLocation

import ARCompass

class ViewController: UIViewController {
  
  // MARK: - Outlets
  
  @IBOutlet var mapView: MKMapView?
  
  // MARK: - Properties
  
  private let locationManager = CLLocationManager()
  private var firstCenteringCompleted = false
  
  private var currentAnnotation: MKPointAnnotation? {
    didSet {
      if let annotation = currentAnnotation {
        mapView?.addAnnotation(annotation)
      }
    }
  }
  
  private var currentAnnotationCoordinate: CLLocationCoordinate2D? {
    didSet {
      guard let userLocationCoordinate = mapView?.userLocation.coordinate else { return }
      guard let currentAnnotationCoordinate = currentAnnotationCoordinate else { return }
      
      currentAnnotation?.coordinate = currentAnnotationCoordinate
      
      let request = MKDirections.Request()
      request.source = MKMapItem(placemark: MKPlacemark(coordinate: userLocationCoordinate))
      request.destination = MKMapItem(placemark: MKPlacemark(coordinate: currentAnnotationCoordinate))
      request.transportType = .walking
      
      MKDirections(request: request).calculate { response, error in
        guard let route = response?.routes.first else { return }
        
        DispatchQueue.main.async {
          if let currentRoute = self.currentRoute {
            self.mapView?.removeOverlay(currentRoute.polyline)
          }
          
          self.currentRoute = route
        }
      }
    }
  }
  
  private var currentRoute: MKRoute? {
    didSet {
      guard let currentRoute = currentRoute else { return }
      self.mapView?.addOverlay(currentRoute.polyline)
    }
  }
  
  // MARK: - Life Cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    locationManager.delegate = self
    mapView?.showsUserLocation = true
    
    let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(mapViewPressed(_:)))
    mapView?.addGestureRecognizer(longPressGestureRecognizer)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
  
    locationManager.requestWhenInUseAuthorization()
    locationManager.startUpdatingLocation()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    locationManager.stopUpdatingLocation()
  }
  
  // MARK: - Targets
  
  @objc private func mapViewPressed(_ recognizer: UILongPressGestureRecognizer) {
    guard let mapView = recognizer.view as? MKMapView else { return }
    
    if let annotation = currentAnnotation {
      mapView.removeAnnotation(annotation)
      currentAnnotation = nil
      currentAnnotationCoordinate = nil
    }
    
    let point = recognizer.location(in: mapView)
    currentAnnotationCoordinate = mapView.convert(point, toCoordinateFrom: mapView)
  }
  
  // MARK: - Convenience
  
  private func zoomTo(location: CLLocation) {
    let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
    mapView?.setRegion(region, animated: true)
  }
}

// MARK: - CLLocationManagerDelegate
extension ViewController: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let location = locations.first else { return }
    
    if !firstCenteringCompleted {
      zoomTo(location: location)
      firstCenteringCompleted = true
    }
  }
  
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    manager.startUpdatingLocation()
  }
}

// MARK: - MKMapViewDelegate
extension ViewController: MKMapViewDelegate {
  func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    let renderer = MKPolylineRenderer(overlay: overlay)
    
    renderer.strokeColor = .purple
    renderer.lineWidth = 4
    
    return renderer
  }
}
