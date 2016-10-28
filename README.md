# JTTableViewController

[![CI Status](http://img.shields.io/travis/jonathantribouharet/JTTableViewController.svg)](https://travis-ci.org/jonathantribouharet/JTTableViewController)
![Version](https://img.shields.io/cocoapods/v/JTTableViewController.svg)
![License](https://img.shields.io/cocoapods/l/JTTableViewController.svg)
![Platform](https://img.shields.io/cocoapods/p/JTTableViewController.svg)

A ViewController with a tableView which manage pagination and loaders for iOS.

## Installation

With [CocoaPods](http://cocoapods.org/), add this line to your Podfile.

    pod 'JTTableViewController', '~> 2.0'

## What's in it?

- avoid parallel requests problem (you start two requests and the first one finish after the second), last request is the only one we want to use
- easily manage pagination 
- display a view for the first loading (when your `tableView` is empty)
- display a view when there is no results to your first request
- display a loader view (an `UITableViewCell`) for indicate the next page is loading
- display a view for errors

## Screenshots

![Example](./Screens/example.gif "Example View")

## Usage

### Minimum usage

You have to create an `UITableView` and assign it to `self.tableView`, add it to the `self.view` and set the `delegate` and `dataSource` yourself.
Or you can inherit from `JTFullTableViewController` instead of `JTTableViewController`.

```swift
import JTTableViewController

class ViewController: JTTableViewController<YourModel>, UITableViewDelegate, UITableViewDataSource {
    
    // Used in this example to manage your pagingation
    private var currentPage = 1
    
    // Must be implemented
    override func jt_tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        let anInstanceOfYourModel = self.results[indexPath.row]
        /*
            whatever you wanna do with `anInstanceOfYourModel` and your `cell`
        */
        return cell
    }

    // Must be implemented
    override func fetchResults() {
        super.fetchResults()
        
        currentPage = 1
        
        // `lastRequestId` is used to avoid problem with parallel requests
        let lastRequestId = self.lastRequestId
        
        YourService.retrieveData(page: currentPage) { (error, results) -> () in
            if let error = error {
                self.didFailedToFetchResults(error: error, lastRequestId: lastRequestId)
                return
            }
            self.didFetchResults(results, lastRequestId: lastRequestId) {
                // this block is executed if `lastRequestId` matched with `self.lastRequestId`
                self.currentPage += 1
            }
        })
    }

    // Must be implemented
    override func fetchNextResults() {
        super.fetchNextResults()
        
        // `lastRequestId` is used to avoid problem with parallel requests
        let lastRequestId = self.lastRequestId
        
        YourService.retrieveData(page: currentPage) { (error, results) -> () in
            if let error = error {
                self.didFailedToFetchResults(error: error, lastRequestId: lastRequestId)
            }
            else {
                self.didFetchNextResults(results, lastRequestId: lastRequestId) {
                    // this block is executed if `lastRequestId` matched with `self.lastRequestId`
                    self.currentPage += 1
                }
            }
        })
    }
    
}
```

### Advanced usage

```swift
import JTTableViewController

class ViewController: JTTableViewController<YourModel>, UITableViewDelegate, UITableViewDataSource {
    
    // Used in this example to manage your pagingation
    private var currentPage = 1
    
    private let refreshControl = UIRefreshControl()
    
    override func viewDidLoad () {
        super.viewDidLoad()
        
        // `nextPageLoaderCell` is an `UITableViewCell`
        self.nextPageLoaderCell = MyNextPageLoadCell()
        
        // `fecthResults` is call 5 cells before `nextPageLoaderCell` become visible
        self.nextPageLoaderOffset = 5
        
        // `noResultsView` is display when `didFetchResults` is called with an `results` empty
        let noResultsView = NoResultsView()
        self.noResultsView = noResultsView
        self.view.addSubview(noResultsView)
        // something better than frame with Constraints but not relevant here
        noResultsView.frame = self.view.bounds

        // `noResultsLoadingView` is display when `fetchResults` is called and `results` is empty
        let noResultsLoadingView = NoResultsLoadingView()
        self.noResultsLoadingView = noResultsLoadingView
        self.view.addSubview(noResultsLoadingView)
        // something better than frame with Constraints but not relevant here
        noResultsLoadingView.frame = self.view.bounds

        // `errorView` is display when `didFailedToFetchResults` is called
        let errorView = ErrorView()
        self.errorView = errorView
        self.view.addSubview(errorView)
        // something better than frame with Constraints but not relevant here
        errorView.frame = self.view.bounds
        
        refreshControl.addTarget(self, action: #selector(fetchResults), for: .valueChanged)
        self.tableView?.addSubview(refreshControl)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchResults()
    }
    
    // Must be implemented
    override func jt_tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        let anInstanceOfYourModel = self.results[indexPath.row]
        /*
            whatever you wanna do with `anInstanceOfYourModel` and your `cell`
        */
        return cell
    }

    // Must be implemented
    override func fetchResults() {
        self.resetResults()
    
        super.fetchResults()
        
        currentPage = 1
        
        // `lastRequestId` is used to avoid problem with parallel requests
        let lastRequestId = self.lastRequestId
        
        YourService.retrieveData(page: currentPage) { (error, results) -> () in
            if let error = error {
                self.didFailedToFetchResults(error: error, lastRequestId: lastRequestId)
                return
            }
            self.didFetchResults(results, lastRequestId: lastRequestId) {
                // this block is executed if `lastRequestId` matched with `self.lastRequestId`
                self.currentPage += 1
            }
        })
    }

    // Must be implemented
    override func fetchNextResults() {
        super.fetchNextResults()
        
        // `lastRequestId` is used to avoid problem with parallel requests
        let lastRequestId = self.lastRequestId
        
        YourService.retrieveData(page: currentPage) { (error, results) -> () in
            if let error = error {
                self.didFailedToFetchResults(error: error, lastRequestId: lastRequestId)
            }
            else {
                self.didFetchNextResults(results, lastRequestId: lastRequestId) {
                    // this block is executed if `lastRequestId` matched with `self.lastRequestId`
                    self.currentPage += 1
                }
            }
        })
    }
    
    override func didEndFetching () {
        super.didEndFetching()
        refreshControl.endRefreshing()
    }
    
}
```

You have to implement `fetchResults` and `fetchNextResults` methods. They are used to load data (from your web service for example). These methods must call `super`.

`fetchResults` is used to retrieve new data (erase all previous data) whereas `fetchNextResults` is used for get more data (the pagination).

`didFetchResults` must be call when `fetchResults` have successfuly retrieve data.
`didFetchNextResults` must be call when `fetchNextResults` have successfuly retrieve data.
`didFailedToFetchResults` must be call if `didFetchResults` or `didFetchNextResults` have failed to retrieve data.

`didEndFetching` is called after `didFetchResults`, `didFetchNextResults` or `didFailedToFetchResults`

The data are stored in `results`. Just use `self.results` to access to them.
If you want to remove some elements in `results` you can use `self.unsafeResults`, only in specific case (ex: removing one cell).

There are some properties you can customize:
- `nextPageLoaderCell` is the loader use for the pagination, it's a `UITableViewCell`
- `noResultsView` is the view display when the results get from your service are empty
- `noResultsLoadingView` is the view display when there is no results and you start fetching new data, used for the first load
- `errorView` is the view display `didFailedToFetchResults` is called
- `nextPageLoaderOffset` is the number of cells require before the last cell for calling `fetchNextResults`, by default it's 3

You can also override some methods:
- `didEndFetching`
- `showNoResultsLoadingView`
- `hideNoResultsLoadingView`
- `showNoResultsView`
- `hideNoResultsView`
- `showErrorView`
- `hideErrorView`

## Subclassing notes

If you want to subclass `JTTableViewController` or `JTFullTableViewController`, the methods from `UITableViewDelegate` and `UITableViewDataSource` must have an `@objc` annotation.

```swift
class XXTableViewController<T>: JTTableViewController<T> {
    /*
    ... Here you add whatever you want to add
    */
}

class MyViewController: XXTableViewController<YourModel> {

    // if you don't add `@objc(tableView:didSelectRowAtIndexPath:)` this method is not called
    @objc(tableView:didSelectRowAtIndexPath:)
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        /*
        ...
        /*
    }

}
```

## Requirements

- iOS 8.0 or higher
- Swift 3.0

## Author

- [Jonathan Tribouharet](https://github.com/jonathantribouharet) ([@johntribouharet](https://twitter.com/johntribouharet))

## License

JTTableViewController is released under the MIT license. See the LICENSE file for more info.
