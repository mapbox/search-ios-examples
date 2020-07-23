import UIKit
import MapKit
import MapboxSearch

class AppleBoundingBoxController: UIViewController {
    let searchEngine = CategorySearchEngine()
    
    let mapView = MKMapView()
    
    let mapboxSFOfficeCoordinate = CLLocationCoordinate2D(latitude: 37.7911551, longitude: -122.3966103)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        mapView.frame = view.bounds
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        mapView.setCenter(mapboxSFOfficeCoordinate, animated: false)
        view.addSubview(mapView)
    }
    
    var draggingRefreshTimer: Timer?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        /// Configure RequestOptions to perform search near the Mapbox Office in San Francisco
        let requestOptions = CategorySearchEngine.RequestOptions(proximity: mapboxSFOfficeCoordinate)
        
        searchEngine.search(categoryName: "cafe", options: requestOptions) { response in
            do {
                let results = try response.get()
                self.displaySearchResults(results)
            } catch {
                self.displaySearchError(error)
            }
        }
    }
    
    func displaySearchResults(_ results: [SearchResult]) {
        let annotations = results.map({ result -> MKAnnotation in
            let pointAnnotation = MKPointAnnotation()
            pointAnnotation.title = result.name
            pointAnnotation.subtitle = result.address?.formattedAddress(style: .medium)
            pointAnnotation.coordinate = result.coordinate
            
            return pointAnnotation
        })
        
        mapView.addAnnotations(annotations)
        mapView.showAnnotations(annotations, animated: true)
    }
    
    func displaySearchError(_ error: Error) {
        let alertController = UIAlertController(title: nil, message: error.localizedDescription, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        present(alertController, animated: true, completion: nil)
    }
    
    @objc
    func reloadResultInMapBounds() {
        let region = mapView.region
        
        let boundingBox = BoundingBox(.init(latitude: region.center.latitude - region.span.latitudeDelta / 2,
                                            longitude: region.center.longitude - region.span.longitudeDelta / 2),
                                      .init(latitude: region.center.latitude + region.span.latitudeDelta / 2,
                                            longitude: region.center.longitude + region.span.longitudeDelta / 2))
        
        let requestOptions = CategorySearchEngine.RequestOptions(proximity: mapboxSFOfficeCoordinate, boundingBox: boundingBox)
        
        searchEngine.search(categoryName: "cafe", options: requestOptions) { response in
            do {
                let results = try response.get()
                self.displaySearchResults(results)
            } catch {
                self.displaySearchError(error)
            }
        }
    }
}

extension AppleBoundingBoxController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        draggingRefreshTimer?.invalidate()
        draggingRefreshTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(reloadResultInMapBounds), userInfo: nil, repeats: false)
    }
}
