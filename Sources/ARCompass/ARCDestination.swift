//
//  ARCDestination.swift
//  ARCompass
//
//  Created by Paolo Di Lorenzo on 8/26/18.
//

public struct ARCDestination {
  
  public var annotationTitle: String
  public var annotationSubtitle: String
  public var longitude: Double
  public var latitude: Double
  
  public init(annotationTitle: String, annotationSubtitle: String, longitude: Double, latitude: Double) {
    self.annotationTitle = annotationTitle
    self.annotationSubtitle = annotationSubtitle
    self.longitude = longitude
    self.latitude = latitude
  }
  
}
