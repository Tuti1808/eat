//
//  MapScreenController.swift
//  Eat
//
//  Created by Yonni Luu on 2018-03-03.
//  Copyright © 2018 launchpad. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps

class MapScreenController: UIViewController{
  var locationManager = CLLocationManager()
  var currentLocation = CLLocation?.self
  var zoomLevel: Float = 15.0

  let searchQuery = SearchQuery()

  @IBOutlet var mapView: GMSMapView!
  @IBOutlet weak var nextView: UIButton!
  @IBOutlet weak var headerView: UIView!
  @IBOutlet weak var questionLabel: UILabel!
  @IBOutlet weak var instructionLabel: UILabel!

  static func viewController() -> UINavigationController {
    let storyboard = UIStoryboard(name: "MapScreen", bundle: nil)
    guard let navigationVC = storyboard.instantiateInitialViewController() as? UINavigationController else { fatalError() }
    return navigationVC
  }

  // Whether a user has selected a location other than their current location.
  // If this value is true, then the map should not recenter when the user's location
  // changes.
  // This value is reset to false when a user clicks on the current location icon where
  // the map recenters at that location
  var didSelect: Bool = false

  // A default location to use when location permission is not granted.
  let defaultLocation = CLLocation(latitude: 49.2827, longitude: 123.1207)

  override func viewDidLoad() {
    super.viewDidLoad()

    // Initialize location manager
    locationManager = CLLocationManager()
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    locationManager.requestWhenInUseAuthorization()
    locationManager.distanceFilter = 50

    // Location manager should start fetching current location
    locationManager.startUpdatingLocation()
    locationManager.delegate = self


    // Create a map.
    let camera = GMSCameraPosition.camera(withLatitude: defaultLocation.coordinate.latitude,
                                          longitude: defaultLocation.coordinate.longitude,
                                          zoom: zoomLevel)
    self.mapView.camera = camera

    self.mapView.settings.setAllGesturesEnabled(true)
    self.mapView.isUserInteractionEnabled = true
    self.mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    self.mapView.padding = UIEdgeInsetsMake(0, 0, 100, 0)
    self.mapView.delegate = self

    // Add title to the navigation bar
    navigationItem.title = "Where do you want to eat?"
    // Add a next button to the navigation bar
    navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(MapScreenController.next(_:)))
  }


  @objc func next(_ sender:UIBarButtonItem!) {
    print("Next has been click")
    // TODO: create a search query object when this button is clicked and move onto the next
    //       screen
    let searchQuery = buildQueryFromMap()
    let peopleCountVc = PeopleCountViewController.viewController(searchQuery: searchQuery)
    navigationController?.pushViewController(peopleCountVc, animated: true)
  }
  @IBAction func nextTapped(_ sender: Any) {
    let searchQuery = buildQueryFromMap()
    let peopleCountVc = PeopleCountViewController.viewController(searchQuery: searchQuery)
    navigationController?.pushViewController(peopleCountVc, animated: true)
  }

  /*
   * Using the center of the map to the North East point on the map view, Build a radius for the search query
   * from the difference in longatide of the two positions
   */
  private func buildQueryFromMap()->SearchQuery {
    let center = self.mapView.camera.target

    let projection = mapView.projection.visibleRegion()
    //        print("Top left", proection.farLeft)
    //        print("Bottom Right", proection.nearRight)

    let radius = getLongatudeRadius(center: self.mapView.camera.target.longitude, outerCoord: projection.farRight.longitude)

    searchQuery.latitude = Float(center.latitude)
    searchQuery.longitude = Float(center.longitude)
    searchQuery.radius = radius
    return searchQuery
  }

  /*
   * At the equator, one degree of longitude and latitude both cover about 111 kilometers
   * Using this calculation, find the difference of the two and calculate the rough distance
   */
  private func getLongatudeRadius(center:Double, outerCoord:Double)->Int {
    let latDifference = abs(outerCoord - center)
    let radius = latDifference * (111 * 1000) //degree * (111km * 1000m/km)
    print("lat diff:", latDifference, "radius", radius)
    return Int(radius)
  }
}

extension MapScreenController : CLLocationManagerDelegate {

  // Handle incoming location events.
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

    // get the most recent location of the last locations
    let location: CLLocation = locations.last!
    print("Last Location: \(location)")

    let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude, longitude: location.coordinate.longitude, zoom: zoomLevel)

    // Check if the map should recenter for that incoming location change
    if (!didSelect){
      if self.mapView.isHidden {
        self.mapView.isHidden = false
        self.mapView.camera = camera
      } else {
        self.mapView.animate(to: camera)
      }
    }
  }

  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    switch status {
    case .authorizedAlways, .authorizedWhenInUse:
      self.mapView.settings.myLocationButton = true
      self.mapView.isMyLocationEnabled = true
    default:
      break
    }
  }
}

extension MapScreenController : GMSMapViewDelegate {
//  func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D)
//  {
//    print("You tapped at \(coordinate.latitude), \(coordinate.longitude)")
//
//    // Set didSelect to true as map should not recenter if the user's current location
//    // changes
//    didSelect = true
//
//    // There should only be one pin on the map max
//    self.mapView.clear()
//    let marker = GMSMarker(position: coordinate)
//    marker.map = self.mapView
//
//    let camera = GMSCameraPosition.camera(withLatitude: coordinate.latitude, longitude: coordinate.longitude, zoom: zoomLevel)
//    if self.mapView.isHidden {
//      self.mapView.isHidden = false
//      self.mapView.camera = camera
//    } else {
//      self.mapView.animate(to: camera)
//    }
//  }
//  func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
//    didSelect = false
//
//    // Default behaviour for false is for the map to recenter at the user's current location
//    return false
//  }
}


