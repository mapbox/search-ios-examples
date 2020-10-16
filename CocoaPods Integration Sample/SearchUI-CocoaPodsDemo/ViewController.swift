import UIKit
import CoreLocation
import MapKit

import MapboxSearch
import MapboxSearchUI

class ViewController: UIViewController {
    @IBOutlet private weak var mapView: MKMapView!
    let searchController = MapboxSearchController(accessToken: "<#Your API token get from https://account.mapbox.com/access-tokens#>")
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let panelController = MapboxPanelController(rootViewController: searchController)
        searchController.delegate = self
        addChild(panelController)
        
        // That's it. No need to call `panelController.didMove(toParent: self)`
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Optional. Request location to improve search results
        // Search SDK will receive location updates in very energy efficient way
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func showAnnotation(_ annotations: [MKAnnotation], isPOI: Bool) {
        guard !annotations.isEmpty else { return }
        
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotations(annotations)
        
        if annotations.count == 1, let annotation = annotations.first {
            let delta = isPOI ? 0.005 : 0.5
            let span = MKCoordinateSpan(latitudeDelta: delta, longitudeDelta: delta)
            let region = MKCoordinateRegion(center: annotation.coordinate, span: span)
            mapView.setRegion(region, animated: true)
        } else {
            mapView.showAnnotations(annotations, animated: true)
        }
    }
}

extension ViewController: SearchControllerDelegate {
    func categorySearchResultsReceived(results: [SearchResult]) {
        let annotations = results.map { searchResult -> MKPointAnnotation in
            let annotation = MKPointAnnotation()
            annotation.coordinate = searchResult.coordinate
            annotation.title = searchResult.name
            annotation.subtitle = searchResult.address?.formattedAddress(style: .medium)
            return annotation
        }
        
        showAnnotation(annotations, isPOI: false)
    }
    
    func searchResultSelected(_ searchResult: SearchResult) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = searchResult.coordinate
        annotation.title = searchResult.name
        annotation.subtitle = searchResult.address?.formattedAddress(style: .medium)
        
        showAnnotation([annotation], isPOI: searchResult.type == .POI)
    }
    
    func userFavoriteSelected(_ favorite: FavoriteRecord) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = favorite.coordinate
        annotation.title = favorite.name
        annotation.subtitle = favorite.address?.formattedAddress(style: .medium)
        
        showAnnotation([annotation], isPOI: true)
    }
}
