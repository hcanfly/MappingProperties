//
//  ViewController.swift
//  MappingProperties
//
//  Created by Gary on 10/13/19.
//  Copyright © 2019 Gary Hanson. All rights reserved.
//

import UIKit
import MapKit


struct PinProperties {
    var properties = [Property]()
}


class ViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    var propertyData: [Property]?
    let locationManager = CLLocationManager()
    private var groupDistance: Double = 1100.0      // group properties within this distance of each other. hard-coded for demo
    private var mapScale = 1.33                     // initial value which will cause re-calc when first displayed
        
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Properties"
        self.mapView.delegate = self
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        //self.locationManager.requestLocation()        // don't need this for hard-coded data
        
        self.loadTestData()
        
        self.setInitialLocation()
    }
    
    private func loadTestData() {
        self.propertyData = Model.getTestData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.displayAnnotations()
    }
    
    private func setInitialLocation() {
        // this is hard-coded to center on SJC because that's where the hard-coded test data is
        let center = CLLocationCoordinate2D(latitude: CLLocationDegrees(37.360705), longitude: CLLocationDegrees(-121.929789))
        
        //let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))
        
        self.mapView.setRegion(region, animated: true)
    }
    
    // calculate the distance between items to consider them grouped based on map scaling
    private func setGroupingDistance() {
        let span = mapView.region.span
        let center = mapView.region.center
        
        let lat1 = CLLocation(latitude: center.latitude - span.latitudeDelta * 0.5, longitude: center.longitude)
        let lat2 = CLLocation(latitude: center.latitude + span.latitudeDelta * 0.5, longitude: center.longitude)
        let long1 = CLLocation(latitude: center.latitude, longitude: center.longitude - span.longitudeDelta * 0.5)
        let long2 = CLLocation(latitude: center.latitude, longitude: center.longitude + span.longitudeDelta * 0.5)
        
        let metersInLatitude = lat1.distance(from: lat2)
        let metersInLongitude = long1.distance(from: long2)
        
        self.groupDistance = metersInLatitude < metersInLongitude ? metersInLatitude : metersInLongitude
        self.groupDistance *= 0.08
    }
    
    private func setMapInfo() {
        self.setGroupingDistance()
        self.displayAnnotations()
        self.mapScale = self.mapView.scale
    }
    
    private func displayAnnotations() {
        let allAnnotations = self.mapView.annotations
        self.mapView.removeAnnotations(allAnnotations)
        
        if let props = self.propertyData {
            var pinProperties = [PinProperties]()
            
            for p in props {
                var addedToSubgroup = false
                var minDistance = self.groupDistance
                var minDistanceIndex: Int?
                
                // see if properties are close enough to be considered in a group
                for index in pinProperties.indices {
                    for l in pinProperties[index].properties {
                        let distance = p.location.distance(from: l.location)
                        if distance < minDistance {
                            minDistanceIndex = index
                            minDistance = distance
                            addedToSubgroup = true
                        }
                    }
                }
                
                if !addedToSubgroup {
                    // the property wasn't close enough to any other properties to be in a group
                    // add it as an individual pin
                    var pl = PinProperties()
                    
                    pl.properties.append(p)
                    pinProperties.append(pl)
                } else {
                    // property is close to another property. add it to existing group
                    pinProperties[minDistanceIndex!].properties.append(p)
                }
            }
            
            for p in pinProperties {
                let annotation = PropertyAnnotation(properties: p)
                
                annotation.coordinate = p.properties[0].coordinates
                self.mapView.addAnnotation(annotation)
            }
        }
    }
    
}

// MARK: MKMapViewDelegate
extension ViewController : MKMapViewDelegate, DisplayViewDelegate {
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        // the user interacted with the map. if the scale changed update the display of the annotations
        if self.mapScale != self.mapView.scale {
            self.setMapInfo()
            self.mapScale = self.mapView.scale
        }
    }
    
    // create the pin views
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let annotationIdentifier = "PropertyAnnotationIdentifier"
        var annotationView: PropertyAnnotationView?
        
        // note: don't use dequeueReusableAnnotationView to get the view for dynamic data. some or all will be stale.
        if let propertyAnnotation = annotation as? PropertyAnnotation {
            annotationView = PropertyAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier, properties: propertyAnnotation.properties)
            annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        
            if let annotationView = annotationView {
                annotationView.canShowCallout = false
                var image: UIImage
                // if there are multiple properties for this view display icon which shows number of properties in group
                if annotationView.properties.properties.count > 1 {
                    image = UIImage(named: "NumberIcons/\(annotationView.properties.properties.count)")!
                    annotationView.image = image
                } else {
                    // view only contains one property so show the appropriate icon for that
                    image = UIImage(named: "HomePin")!      //TODO: different pins for other property types
                }
                annotationView.image = image
            }
        }
        
        return annotationView
    }
    
    private var displayFrame: CGRect {
        let frameHeight = Int(self.view.frame.height / 2)
        
        return CGRect(x: 0, y: Int(mapView.frame.height) - frameHeight, width: Int(mapView.frame.width), height: frameHeight)
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        // display photo(s) for pin property(ies)
        if let propertyView = view as? PropertyAnnotationView {
            let calloutView = DisplayPropertiesView(frame: self.displayFrame, properties: propertyView.properties.properties)
            
            calloutView.delegate = self
            self.view.addSubview(calloutView)
        }
    }
    
    private func removeDisplayViews() {
        for view in self.view.subviews {
            
            if view.isKind(of: DisplayView.self) {
                view.removeFromSuperview()
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {

        self.removeDisplayViews()
    }
    
    // display info page for property selected in image view popup
    func selected(propertyId: Int) {
        self.removeDisplayViews()
        
        if let vc = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: "PropertyInfoViewController") as? PropertyInfoViewController {
            vc.property = self.propertyData![propertyId]
            self.navigationController?.pushViewController(vc, animated:true)
        }
    }
    
}


//MARK: CLLocationManagerDelegate
extension ViewController : CLLocationManagerDelegate {
    
//    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
//
//    }
//
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//
//    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("MapKit reported error:: (error)")
    }
}


//MARK: other classes
fileprivate class PropertyAnnotation: MKPointAnnotation {
    var properties: PinProperties!
    
    convenience init(properties: PinProperties) {
        
        self.init()
        self.properties = properties
        
    }
    
    override init() {
        
        super.init()
    }
}



fileprivate class PropertyAnnotationView: MKAnnotationView {
    var properties: PinProperties!
    
    convenience init(annotation: MKAnnotation?, reuseIdentifier: String?, properties: PinProperties) {
        
        self.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.properties = properties
    }
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate extension MKMapView {

    // get map's current scale
    var scale: Double {

        return self.scaleWithPrecision(precision: 1000)
    }

    func scaleWithPrecision(precision: Double) -> Double {

        let mapBoundsWidth = Double(self.bounds.size.width)
        let mapRectWidth = Double(self.visibleMapRect.size.width)

        let scale = round(precision * mapBoundsWidth / mapRectWidth) / precision

        return scale
    }
}
