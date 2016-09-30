//
//  JTTableViewController.swift
//  JTTableViewController
//
//  Created by Jonathan Tribouharet
//

import UIKit

public class JTTableViewController<T>: UIViewController {
    
    var tableView: UITableView?
    var nextPageLoaderCell: UITableViewCell?
    
    var noResultsView: UIView? {
        didSet {
            noResultsView?.isHidden = true
            noResultsView?.isUserInteractionEnabled = false
        }
    }
    
    var noResultsLoadingView: UIView? {
        didSet {
            noResultsLoadingView?.isHidden = true
            noResultsLoadingView?.isUserInteractionEnabled = false
        }
    }
    
    var errorView: UIView? {
        didSet {
            errorView?.isHidden = true
            errorView?.isUserInteractionEnabled = false
        }
    }
    
    var nextPageLoaderOffset = 3
    
    private(set) var results = [T]()
    private(set) var haveMoreResults = false
    private(set) var isFetching = false
    
    // Use to directly have access to results
    var unsafeResults: [T] {
        get {
            return results
        }
        set (value) {
            results = value
        }
    }
    
    // Used to ignore invalid / older requests
    private(set) var lastRequestId = 0
    
    func resetResults (scrollTop: Bool = false, scrollAnimated: Bool = true) {
        results.removeAll()
        haveMoreResults = false
        isFetching = false
        lastRequestId = 0
        
        hideNoResultsView()
        hideNoResultsLoadingView()
        hideErrorView()
        
        tableView?.reloadData()
        
        if scrollTop {
            tableView?.setContentOffset(CGPoint(), animated: scrollAnimated)
        }
    }
    
    func fetchResults () {
        isFetching = true
        lastRequestId += 1
        
        hideNoResultsView()
        hideErrorView()
        
        if results.isEmpty {
            showNoResultsLoadingView()
        }
    }
    
    func fetchNextResults () {
        isFetching = true
        lastRequestId += 1
        
        hideErrorView()
    }
    
    func didFetchResults (results: [T], haveMoreResults: Bool? = nil, lastRequestId: Int? = nil, completion: (()->())? = nil) {
        if let lastRequestId = lastRequestId {
            if self.lastRequestId != lastRequestId {
                return
            }
        }
        
        self.results.removeAll()
        self.results.append(contentsOf: results)
        
        if let haveMoreResults = haveMoreResults {
            self.haveMoreResults = haveMoreResults
        }
        else {
            self.haveMoreResults = results.count > 0
        }

        isFetching = false
        
        tableView?.reloadData()
        
        hideNoResultsLoadingView()
        
        if results.isEmpty {
            showNoResultsView()
        }
        
        if let completion = completion {
            completion()
        }

        didEndFetching()
    }
    
    func didFetchNextResults (results: [T], haveMoreResults: Bool? = nil, lastRequestId: Int? = nil, completion: (()->())? = nil) {
        if let lastRequestId = lastRequestId {
            if self.lastRequestId != lastRequestId {
                return
            }
        }
        
        isFetching = false
        
        self.results.append(contentsOf: results)
        
        if let haveMoreResults = haveMoreResults {
            self.haveMoreResults = haveMoreResults
        }
        else {
            self.haveMoreResults = results.count > 0
        }
        
        tableView?.reloadData()
                
        if let completion = completion {
            completion()
        }

        didEndFetching()
    }
    
    
    func didFailedToFetchResults (error: Error? = nil) {
        isFetching = false
        
        hideNoResultsLoadingView()
        showErrorView(error: error)

        didEndFetching()
    }
    
    func showNoResultsLoadingView () {
        noResultsLoadingView?.isHidden = false
    }
    
    func hideNoResultsLoadingView () {
        noResultsLoadingView?.isHidden = true
    }
    
    func showNoResultsView () {
        noResultsView?.isHidden = false
    }
    
    func hideNoResultsView () {
        noResultsView?.isHidden = true
    }
    
    func showErrorView (error: Error? = nil) {
        errorView?.isHidden = false
    }
    
    func hideErrorView () {
        errorView?.isHidden = true
    }
    
    func didEndFetching () {
        
    }
    
    //MARK: TableView delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (nextPageLoaderCell != nil) && haveMoreResults {
            return results.count + 1
        }
        
        return results.count
    }
    
    @objc(tableView:heightForRowAtIndexPath:)
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let nextPageLoaderCell = nextPageLoaderCell, haveMoreResults && indexPath.row >= results.count {
            return nextPageLoaderCell.frame.height
        }
        
        return jt_tableView(tableView, heightForRowAt: indexPath)
    }
    
    func jt_tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    @objc(tableView:cellForRowAtIndexPath:)
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let nextPageLoaderCell = nextPageLoaderCell, haveMoreResults && indexPath.row >= results.count {
            return nextPageLoaderCell
        }
        else if(!self.isFetching && indexPath.row >= self.results.count - self.nextPageLoaderOffset && self.haveMoreResults){
            fetchNextResults()
        }

        return jt_tableView(tableView, cellForRowAt: indexPath)
    }

    func jt_tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
        
}
