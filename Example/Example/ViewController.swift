//
//  ViewController.swift
//  Example
//
//  Created by Jonathan on 30/10/16.
//  Copyright © 2016 EIVO. All rights reserved.
//

import UIKit
import JTTableViewController

class ViewController: JTFullTableViewController<String> {

    var lastIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Optional
        // Don't display empty cells
        self.tableView?.tableFooterView = UIView()
        
        // One of the many way to determine the cell for a tableView
        // The tableView is bind to the controller directly in the storyboard, no need to set the delegate and the dataSource
        self.tableView?.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        // Optional
        // Load nextPageLoaderCell, this view is bind to the controller directly in the nib
        Bundle.main.loadNibNamed("NextPageLoaderCell", owner: self, options: nil)
        
        // Optional
        // Load noResultsView, this view is bind to the controller directly in the nib
        Bundle.main.loadNibNamed("NoResultsView", owner: self, options: nil)
        
        // Optional
        // Load noResultsLoadingView, this view is bind to the controller directly in the nib
        Bundle.main.loadNibNamed("NoResultsLoadingView", owner: self, options: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !self.isFetching {
            fetchResults()
        }
    }
    
    override func fetchResults() {
        self.resetResults()
        
        super.fetchResults()
        
        lastIndex = 0
        
        let lastRequestId = self.lastRequestId
        
        FakeService.retrieve { (error, results) in
            if let error = error {
                self.didFailedToFetchResults(error: error, lastRequestId: lastRequestId)
            }
            else if let results = results {
                self.didFetchResults(results: results, lastRequestId: lastRequestId) {
                    self.lastIndex += results.count
                }
            }
        }
    }
    
    override func fetchNextResults() {
        super.fetchNextResults()
        
        let lastRequestId = self.lastRequestId
        
        FakeService.retrieve(offset: lastIndex) { (error, results) in
            if let error = error {
                self.didFailedToFetchResults(error: error, lastRequestId: lastRequestId)
            }
            else if let results = results {
                self.didFetchNextResults(results: results, lastRequestId: lastRequestId) {
                    self.lastIndex += results.count
                }
            }
        }
    }

    override func jt_tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = self.results[indexPath.row]
        return cell
    }
    
}

