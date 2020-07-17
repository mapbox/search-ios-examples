# Getting Started

## SDK Interation
To integrate Search SDK for iOS into your project you may choose CocoaPods or Carthage (coming soon) dependency manager.

For CocoaPods integration add the following line into your `Podfile`:


```ruby
# For MapboxSearch support without built-in UI components
pod 'MapboxSearch'

# To use MapboxSearch with prebaked UI. CocoaPods will add "MapboxSearch" pod automatically
pod 'MapboxSearchUI
```


## Access Token
To make Search SDK work you have to retrieve Access Token at Mapbox Access Tokens [page](https://account.mapbox.com/access-tokens/). There is high free tier limit so you don't have to pay to start working with Search SDK.

Press "Create a token" button and choose `DOWNLOADS:READ` scope for your secret token. 

### Access token storage
We recommend to store secret token outside of source control management and use script on Build Phase to inject access token into application's `Info.plist` file. 

For example, you may store access token at the `~/.mapbox` path or inside `mapbox_access_token` in the root of your project. Template of injection script.


```bash
# Version: 1.0
token_file=$SRCROOT/mapbox_access_token

# First check the above path, then the user directory.
# Ignore exit codes from `cat.`
token="$(cat $token_file 2> /dev/null)" || token="$(cat ~/.mapbox 2> /dev/null)"
if [ "$token" ]; then
  plutil -replace MGLMapboxAccessToken -string $token "$TARGET_BUILD_DIR/$INFOPLIST_PATH"
else
  echo 'error: Missing Mapbox access token'
  open 'https://www.mapbox.com/studio/account/tokens/'
  echo "error: Get an access token from <https://www.mapbox.com/studio/account/tokens/>, then create a new file at $token_file that contains the access token."
  exit 1
fi
```

To make this script work, add the new "Run Script" phase on Build Phases tab of your application target. Copy script content into text view and add `$(TARGET_BUILD_DIR)/$(INFOPLIST_PATH)` to "Input Files" section.

## Make your first request
### Theory
When SDK integration ready and you get a brand new access token, you are ready to make your first search request. There are two types of searches:
1. List-based search (`SearchEngine` class). Ideally suitable for lists search with a multiple items, category suggestions, autocomplete functionality and frequently changing query. Due to category suggestions functionality, SDK would not return search results with coordinate and address information initially. To get access to this fields, developer have to callback to `SearchEngine` choosen search suggestion. If this suggestion suitable for retrieving coordinate and address information, `SearchEngine` will pass the resolved `SearchResult` via delegate mechanism.
2. Category-based search (`CategorySearchEngine` class). If you would like to display multiple search results on the map by simple category selection, this is your choise. There are few caveats regarding category search:
    1. Category search would cost more than a list-based one.
    2. This search type doesn't support auxiliary category suggestion step
    3. Delegate would return all results asap

### Samples
#### List-based search
In this list-based example we choose random suggestion from the list and dump resolve result to the console:
```swift
import UIKit
import MapboxSearch

class SimpleListSearchViewController: UIViewController {
    let searchEngine = SearchEngine()
//    let searchEngine = SearchEngine(accessToken: "<#You can pass access token manually#>")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchEngine.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        searchEngine.query = "Mapbox" /// You also can call `searchEngine.search(query: "Mapbox")`
    }
}

extension SimpleListSearchViewController: SearchEngineDelegate {
    func resultsUpdated(searchEngine: SearchEngine) {
        print("Number of search results: \(searchEngine.items.count)")
        
        /// Simulate user selection with random algorithm
        guard let randomSuggestion: SearchSuggestion = searchEngine.items.randomElement() else {
            print("No available suggestions to select")
            return
        }
        
        /// Callback to SearchEngine with choosen `SearchSuggestion`
        searchEngine.select(suggestion: randomSuggestion)
        
        /// We may expect `resolvedResult(result:)` to be called next
        /// or the new round of `resultsUpdated(searchEngine:)` in case if randomSuggestion represents category suggestion (like a 'bar' or 'cafe')
    }
    
    func resolvedResult(result: SearchResult) {
        /// WooHoo, we retrieved the resolved `SearchResult`
        print("Resolved result: coordinate: \(result.coordinate), address: \(result.address?.formattedAddress(style: .medium) ?? "N/A")")
        
        print("Dumping resolved result:", dump(result))
        
    }
    
    func searchErrorHappened(searchError: SearchError) {
        print("Error during search: \(searchError)")
    }
}
```

### Category-based search
The basic example of Category search usage. Search for "cafe" category then print result coordinats to the console:
```swift
import UIKit
import MapboxSearch

class SimpleCategorySearchViewController: UIViewController {
    let searchEngine = CategorySearchEngine()
//    let searchEngine = CategorySearchEngine(accessToken: "<#You can pass access token manually#>")
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        searchEngine.search(categoryName: "cafe") { (response) in
            do {
                let results = try response.get()
                print("Number of category search results: \(results.count)")
                
                for result in results {
                    print("\tResult coordinate: \(result.coordinate)")
                }
            } catch {
                print("Error during category search: \(error)")
            }
        }
    }
}

```