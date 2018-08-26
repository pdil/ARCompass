//
//  ARCNavigationViewController.swift
//  ARCompass
//
//  Created by Paolo Di Lorenzo on 8/26/18.
//

import MapKit

public protocol ARCNavigationViewControllerDelegate: class {
  func didDismiss(_ viewController: ARCNavigationViewController)
}

public class ARCNavigationViewController: UIViewController {
  
  private struct LocalConstants {
    static let padding: CGFloat = 16
    static let altitude: CLLocationDistance = 10
  }
  
  // MARK: - Properties
  
  public weak var delegate: ARCNavigationViewControllerDelegate?
  
  var destination: ARCDestination
  var route: MKRoute
  var routeColor: UIColor
  
//  var routeNodes: [ARCLocationNode]?
  
  // MARK: - Subviews
  
  let locationSceneView = UIView() // ARCLocationSceneView()
  
  let closeButton: UIButton = {
    let button = UIButton()
    button.setTitle("Close", for: .normal)
    return button
  }()
  
  let loadingLabel: UILabel = {
    let label = UILabel()
    label.text = "Augmenting reality..."
    label.textColor = .gray
    label.textAlignment = .center
    label.font = .boldSystemFont(ofSize: 20)
    label.numberOfLines = 0
    return label
  }()
  
  //  let distanceLabel = FDZDistanceLabel()
  
  var miniMap: ARCMiniMapViewController?
  var miniMapConstraintX: NSLayoutConstraint?
  var miniMapConstraintY: NSLayoutConstraint?
  
  // MARK: - Initializer
  
  public init(destination: ARCDestination, route: MKRoute, routeColor: UIColor) {
    self.destination = destination
    self.route = route
    self.routeColor = routeColor
    
    super.init(nibName: nil, bundle: nil)
  }
  
  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MAKR: - Life Cycle
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = .black
    view.addSubview(loadingLabel)
    loadingLabel.anchorFill()
    
    view.addSubview(locationSceneView)
    locationSceneView.anchorFill(safely: false)
    
    closeButton.addTarget(self, action: #selector(closeTapped(_:)), for: .touchUpInside)
    
    miniMap = ARCMiniMapViewController(polyline: route.polyline, destination: destination, routeColor: routeColor)
    let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(miniMapPanned(_:)))
    miniMap?.view.addGestureRecognizer(panGestureRecognizer)
    
    view.addSubview(miniMap!.view)
    miniMap?.view.anchor(height: 180, width: 120)
    miniMapConstraintX = NSLayoutConstraint(item: miniMap!.view, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: 120 / 2 + LocalConstants.padding)
    miniMapConstraintY = NSLayoutConstraint(item: miniMap!.view, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .bottomMargin, multiplier: 1, constant: -180 / 2 - LocalConstants.padding)
    
    view.addConstraints([miniMapConstraintX!, miniMapConstraintY!])
    
    //    view.addSubview(distanceLabel)
    //    distanceLabel.anchor(right: view.rightAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, rightConstant: LocalConstants.padding, bottomConstant: LocalConstants.padding)
    
    view.addSubview(closeButton)
    closeButton.anchor(right: view.rightAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, rightConstant: LocalConstants.padding, bottomConstant: LocalConstants.padding)
  }
  
  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    UIApplication.shared.isIdleTimerDisabled = true
    
//    locationSceneView.run()
    
    //    let pinLocation = CLLocation(latitude: destination.latitude, longitude: destination.longitude)
    //    let pinLocationNode = ARCLocationAnnotationNode(location: pinLocation, image: #imageLiteral(resourceName: "ar-map-pin"))
    //    locationSceneView.add(locationNode: pinLocationNode)
    
    //    update(route: route, routeColor: routeColor)
  }
  
  public override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    UIApplication.shared.isIdleTimerDisabled = false
    
//    locationSceneView.pause()
  }
  
  // MARK: - Targets
  
  @objc private func closeTapped(_ sender: UIButton) {
    dismiss(animated: false) { self.delegate?.didDismiss(self) }
  }
  
  @objc private func miniMapPanned(_ recognizer: UIPanGestureRecognizer) {
    switch recognizer.state {
    case .began:
      UIView.animate(withDuration: 0.1) { self.miniMap?.view.alpha = 0.4 }
    case .changed:
      let translation = recognizer.translation(in: view)
      
      miniMapConstraintX?.constant += translation.x
      miniMapConstraintY?.constant += translation.y
      
      recognizer.setTranslation(.zero, in: view)
      
      view.layoutIfNeeded()
    case .ended:
      UIView.animate(withDuration: 0.25) { self.miniMap?.view.alpha = 1.0 }
      sendMiniMapToNearestCorner()
    default:
      break
    }
  }
  
  private func sendMiniMapToNearestCorner() {
    guard let miniMapConstraintX = miniMapConstraintX, let miniMapConstraintY = miniMapConstraintY else { return }
    
    if miniMapConstraintX.constant < view.bounds.width / 2 {
      miniMapConstraintX.constant = 120 / 2 + LocalConstants.padding
    } else {
      miniMapConstraintX.constant = view.bounds.width - 120 / 2 - LocalConstants.padding
    }
    
    if miniMapConstraintY.constant < -(view.bounds.height - view.safeAreaInsets.bottom - view.safeAreaInsets.top) / 2 {
      let insetHeight = view.bounds.height - view.safeAreaInsets.bottom - view.safeAreaInsets.top
      miniMapConstraintY.constant = -insetHeight + 180 / 2 + LocalConstants.padding
    } else {
      miniMapConstraintY.constant = -180 / 2 - LocalConstants.padding
    }
    
    UIView.animate(withDuration: 0.25) {
      self.view.layoutIfNeeded()
    }
  }
  
  // MARK: - Update
  
  //  func update(route: MKRoute, routeColor: UIColor) {
  //    guard let currentLocation = locationSceneView.currentLocation() else { return }
  //    routeNodes?.forEach { $0.removeFromParentNode() }
  //
  //    self.route = route
  //
  //    routeNodes = ARCLocationRouteNode(location: currentLocation, polyline: route.polyline, routeColor: routeColor).routeNodes()
  //    routeNodes?.forEach(locationSceneView.add)
  //
  //    miniMap?.update(polyline: route.polyline, routeColor: routeColor)
  //
  //    distanceLabel.update(route: FDZRoute(route: route), for: trackingMode)
  //    distanceLabel.appear()
  //  }
  //
  //  func update(destination: ARCDestination) {
  //    miniMap?.update(destination: destination)
  //  }
  
}
