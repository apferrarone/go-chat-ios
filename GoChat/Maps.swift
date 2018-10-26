//
//  Maps.swift
//  GoChat
//
//  Created by Andrew Ferrarone on 12/11/16.
//  Copyright © 2016 Andrew Ferrarone. All rights reserved.
//

import MapKit

private let CONVERT_METERS_MILES = 1 / CONVERT_MILES_METERS as Double
private let CONVERT_MILES_METERS = 1609.34 as Double

extension MKMapView
{
    func zoomToHumanLevel()
    {
        self.zoom(toMiles: 2)
    }
    
    func zoom(toMiles miles: Double)
    {
        let meters = miles * CONVERT_MILES_METERS
        let region = MKCoordinateRegionMakeWithDistance(self.centerCoordinate, meters, meters)
        self.region = self.regionThatFits(region)
    }
    
    func radiusInMeters() -> Double
    {
        let centerCoordinate = self.centerCoordinate
        let centerLocation = CLLocation(latitude: centerCoordinate.latitude, longitude: centerCoordinate.longitude)
        
        let leftEdgeMiddle = self.convert(CGPoint(x: 0, y: self.bounds.size.height / 2), toCoordinateFrom: self)
        let leftEdgeLocation = CLLocation(latitude: leftEdgeMiddle.latitude, longitude: leftEdgeMiddle.longitude)
        
        let radiusInMeters = centerLocation.distance(from: leftEdgeLocation)
        return radiusInMeters
    }
    
    func radiusInMiles() -> Double
    {
        let radius = self.radiusInMeters() * CONVERT_METERS_MILES
        return radius
    }
}
