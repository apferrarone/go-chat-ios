//
//  PostsMap.swift
//  GoChat
//
//  Created by Andrew Ferrarone on 12/11/16.
//  Copyright © 2016 Andrew Ferrarone. All rights reserved.
//

import UIKit
import MapKit

@objc protocol PostsMapDelegate: class
{
    func postsMapView(_ mapView: PostsMap, didMoveToCenterCoordinate centerCoordinate: CLLocationCoordinate2D)
    @objc optional func postsMap(_ mapView: PostsMap, willMoveFromCenterCoordinate centerCoordinate: CLLocationCoordinate2D)
    @objc optional func postsMapView(_ mapView: PostsMap, didSelectPost post: Post)
}

// change this class to a mapService that doesn't subclass MKMapView
// try setting showsBuildings to true and showsUserLocation
class PostsMap: MKMapView, MKMapViewDelegate
{
    //setter is private, getter is public :)
    fileprivate(set) var posts = [Post]()
    
    weak var postDelegate: PostsMapDelegate? {
        didSet {
            self.delegate = self
        }
    }
    
    var isDragging = false
    
    // MARK: Public
    
    func setPins(forPosts posts: [Post])
    {
        // empty posts and remove all annotations
        self.posts = []
        for annotation in self.annotations {
            self.removeAnnotation(annotation)
        }
        
        // add new ones for every post in posts[] arg
        for post in posts {
            self.addPin(forPost: post, canShowCallout: true)
        }
    }
    
    func addPin(forPost post: Post, canShowCallout: Bool)
    {
        self.posts.append(post)
        
        let annotation = PostAnnotation()
        annotation.post = post
        annotation.canShowCallout = canShowCallout
        self.addAnnotation(annotation)
        
        self.delegate = self
    }
    
    func centerOnCurrentUser()
    {
        self.setCenter(self.userLocation.coordinate, animated: true)
    }
    
    // MARK: MKMapViewDelegate
    
    fileprivate struct MapConstants {
        static let MAP_VIEW_ID = "Pin"
    }
    
    internal func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?
    {
        if let annotation = annotation as? PostAnnotation {
            var view = self.dequeueReusableAnnotationView(withIdentifier: MapConstants.MAP_VIEW_ID) as? PostAnnotationView
      
            if view == nil {
                view = PostAnnotationView(annotation: annotation, reuseIdentifier: MapConstants.MAP_VIEW_ID)
                view?.canShowCallout = annotation.canShowCallout
                view?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
                view?.annotation = annotation
            }
            
            //clear out previous accessory views since we reuse these views and reset them accordingly
            //this is not really necessary here since they all will have this one right view
            //but each view could have certain accessory views conditionally and this would be necessary
            //view.rightCalloutAccessoryView = nil
            //view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            
            if let post = annotation.post {
                view?.post = post
                let pinImage: UIImage! = self.pinImage(forPost: post)
                view?.image = pinImage
                
                #if DEBUG
                view?.tintColor = UIColor(hex: Constants.ColorHexValues.CRYPTO_PINK)
                #endif
                
                //default means pin center is on coordinate, but we want the bottom of the pin there
                view?.centerOffset = CGPoint(x: 0, y: -(pinImage.size.height / 2))
            }
            
            return view
            
        } else {
            
            // for the case when the annotation is MKUserLocation
            return nil
        }
    }
    
    internal func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl)
    {
        //asks delegate to show detail
        if let annotationView = view as? PostAnnotationView, let post = annotationView.post {
            self.postDelegate?.postsMapView?(self, didSelectPost: post)
        }
    }
    
    //inform delegate that the map is about to move
    internal func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool)
    {
        print("regionWillChange")
        self.isDragging = true
        self.postDelegate?.postsMap?(self, willMoveFromCenterCoordinate: self.centerCoordinate)
    }
    
    //inform delegate that the map just moved
    internal func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool)
    {
        print("regionDidChange")
        self.isDragging = false
        self.postDelegate?.postsMapView(self, didMoveToCenterCoordinate: mapView.centerCoordinate)
    }
    
    internal func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView])
    {
        var animationDelay = Double(0.0)
        
        for annotationView in views {
            let endFrame = annotationView.frame
            annotationView.frame.origin.y = -(annotationView.frame.size.height) // move to just above the screen
            annotationView.frame.size.height = annotationView.frame.size.height * (2 / 3)
            
            UIView.animate(withDuration: 0.22, delay: animationDelay, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: { 
                
                annotationView.frame = endFrame
                
            }, completion: nil)
            
            animationDelay += 0.02
        }
    }
    
    // MARK: Utilities
    
    fileprivate func pinImage(forPost post: Post) -> UIImage!
    {
        #if DEBUG
        let image = UIImage(named: Constants.ImageNames.PIN_BLUE)?.withRenderingMode(.alwaysTemplate)
        return image
        #endif
        
        switch post.team {
        case .some(Team.yellow): return UIImage(named: Constants.ImageNames.PIN_YELLOW)
        case .some(Team.blue): return UIImage(named: Constants.ImageNames.PIN_BLUE)
        case .some(Team.red): return UIImage(named: Constants.ImageNames.PIN_RED)
        default: return UIImage(named: Constants.ImageNames.PIN_RED)
        }
    }
    
}

//MKAnnotation can be anything so long as you can provide a coordinate and title
//very easy to take any old object and extend it to conform to MKAnnotation
class PostAnnotation: NSObject, MKAnnotation
{
    var title: String?
    var subtitle: String?
    var coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var canShowCallout = false
    
    var post: Post? {
        didSet {
            self.title = self.post?.content
            self.subtitle = self.post?.username
            if let lat = self.post?.latitude, let long = self.post?.longitude {
                self.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            }
        }
    }
}

class PostAnnotationView: MKAnnotationView
{
    var post: Post?
}
