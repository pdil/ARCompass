//
//  ARCMiniMapViewController.swift
//  ARCompass
//
//  Created by Paolo Di Lorenzo on 8/26/18.
//

import MapKit
import AVFoundation

class ARCMiniMapViewController: UIViewController {
  
  var didSetTrackingMode = false
  
  lazy var mapView: MKMapView = {
    let mapView = MKMapView()
    mapView.isUserInteractionEnabled = false
    mapView.showsCompass = false
    mapView.delegate = self
    return mapView
  }()
  
  lazy var cameraFieldOfView: Double = {
    let camera = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: nil, position: .back)
    return Double(camera.devices[0].activeFormat.videoFieldOfView)
  }()
  
  var polyline: MKPolyline?
  var destination: ARCDestination
  var routeColor: UIColor
  
  // MARK: - Initializer
  
  init(polyline: MKPolyline? = nil, destination: ARCDestination, routeColor: UIColor = .blue) {
    self.polyline = polyline
    self.destination = destination
    self.routeColor = routeColor
    
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Life Cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.addSubview(mapView)
    mapView.anchorFill()
    
    view.layer.cornerRadius = 10
    view.layer.masksToBounds = true
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    // Set up user tracking
    mapView.showsUserLocation = true
    
    let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
    let region = MKCoordinateRegion(center: mapView.userLocation.coordinate, span: span)
    
    mapView.setRegion(region, animated: false)
    
    // Add route polyline
    update(polyline: polyline, routeColor: routeColor)
    
    // Add place annotation
    update(destination: destination)
  }
  
  // MARK: - Update
  
  func update(polyline: MKPolyline?, routeColor: UIColor) {
    self.polyline = polyline
    self.routeColor = routeColor
    
    if let polyline = polyline {
      mapView.addOverlay(polyline, level: .aboveRoads)
    }
  }
  
  func update(destination: ARCDestination) {
    self.destination = destination
    
    let annotation = MKPointAnnotation()
    annotation.coordinate = CLLocationCoordinate2D(latitude: destination.latitude, longitude: destination.longitude)
    annotation.title = destination.annotationTitle
    annotation.subtitle = destination.annotationSubtitle
    
    DispatchQueue.main.async {
      self.mapView.removeAnnotations(self.mapView.annotations)
      self.mapView.addAnnotation(annotation)
    }
  }
  
}

// MARK: - MKMapViewDelegate
extension ARCMiniMapViewController: MKMapViewDelegate {
  func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    let renderer = MKPolylineRenderer(overlay: overlay)
    
    renderer.strokeColor = routeColor
    renderer.alpha = 0.75
    
    return renderer
  }
  
  func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
    if !didSetTrackingMode {
      mapView.setUserTrackingMode(.followWithHeading, animated: false)
      didSetTrackingMode = true
    }
  }
  
  func mapView(_ mapView: MKMapView, didChange mode: MKUserTrackingMode, animated: Bool) {
    mapView.setUserTrackingMode(.followWithHeading, animated: false)
  }
  
  func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
    //    guard let placeCoordinates = place?.location.clCoords else { return }
    //    guard let currentLocation = userLocation.location else { return }
    //    guard let currentHeading = userLocation.heading?.trueHeading else { return }
    //
    //    let placeLocation = CLLocation(latitude: placeCoordinates.latitude, longitude: placeCoordinates.longitude)
    //
    //    let placeBearing = bearing(between: currentLocation, and: placeLocation)
    //    let userHeading = Double(currentHeading)
    //
    //    print("\(placeBearing) ; \(userHeading)")
    //
    //    enum DirectionToTurn {
    //      case left, right, none
    //    }
    //
    //    let direction = DirectionToTurn.none
    //
    //
  }
  
  private func bearing(between first: CLLocation, and second: CLLocation) -> Double {
    let latA = first.coordinate.latitude.degreesToRadians
    let lonA = first.coordinate.longitude.degreesToRadians
    
    let latB = second.coordinate.longitude.degreesToRadians
    let lonB = second.coordinate.longitude.degreesToRadians
    
    let x = cos(latB) * sin(lonB - lonA)
    let y = cos(latA) * sin(latB) - sin(latA) * cos(latB) * cos(lonB - lonA)
    var theta = atan2(x, y)
    
    if theta < 0 {
      theta += 2 * .pi
    }
    
    return theta.radiansToDegrees
  }
}

