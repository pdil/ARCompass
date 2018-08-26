//
//  CLLocationDegrees+Conversions.swift
//  ARCompass
//
//  Created by Paolo Di Lorenzo on 8/26/18.
//

import CoreLocation

extension CLLocationDegrees {
  var degreesToRadians: Double { return self * .pi / 180 }
  var radiansToDegrees: Double { return self * 180 / .pi }
}
