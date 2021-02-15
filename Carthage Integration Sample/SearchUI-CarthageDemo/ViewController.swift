import UIKit
import MapboxSearch
import CoreLocation

class ViewController: UIViewController {
    
    let searchEngine = CategorySearchEngine()
    
    let sfCoordinates = CLLocationCoordinate2D(latitude: 37.7749273970744, longitude: -122.43297311016988)

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        searchEngine.search(categoryName: "cafe", options: .init(proximity: sfCoordinates)) { (response) in
            do {
                let results = try response.get()
                print("Number of category search results: \(results.count)")
                
                for result in results {
                    print("\tResult: '\(result.name)' coordinate: \(result.coordinate)")
                }
            } catch {
                print("Error during category search: \(error)")
            }
        }
    }
}

