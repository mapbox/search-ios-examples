import UIKit
import MapboxSearch

class ViewController: UIViewController {

    var engine = SearchEngine(configuration: .init(limit: 10))
    
    override func viewDidLoad() {
        super.viewDidLoad()

        engine.delegate = self
        
        engine.search(query: "ATM")
    }

}

extension ViewController: SearchEngineDelegate {
    func resultsUpdated(searchEngine: SearchEngine) {
        print(#function, searchEngine.items)
        for item in searchEngine.items {
            print("\(item.name): \(item.descriptionText ?? "N/A")")
        }
    }
    
    func resolvedResult(result: SearchResult) {
        print(#function, result)
    }
    
    func searchErrorHappened(searchError: SearchError) {
        print(#function, searchError)
    }
    
}
