//
//  JTTableViewController.swift
//  JTTableViewController
//
//  Created by Jonathan Tribouharet
//

import UIKit

open class JTTableViewController<T>: UIViewController {
    
    open var tableView: UITableView?
    open var nextPageLoaderCell: UITableViewCell?
    
    open var noResultsView: UIView? {
        didSet {
            noResultsView?.isHidden = true
            noResultsView?.isUserInteractionEnabled = false
        }
    }
    
    open var noResultsLoadingView: UIView? {
        didSet {
            noResultsLoadingView?.isHidden = true
            noResultsLoadingView?.isUserInteractionEnabled = false
        }
    }
    
    open var errorView: UIView? {
        didSet {
            errorView?.isHidden = true
            errorView?.isUserInteractionEnabled = false
        }
    }
    
    open var nextPageLoaderOffset = 3
    
    open private(set) var results = [T]()
    open private(set) var haveMoreResults = false
    open private(set) var isFetching = false
    
    // Use to directly have access to results
    open var unsafeResults: [T] {
        get {
            return results
        }
        set (value) {
            results = value
        }
    }
    
    // Used to ignore invalid / older requests
    open private(set) var lastRequestId = 0
    
    open func resetResults (scrollTop: Bool = false, scrollAnimated: Bool = true) {
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
    
    open func fetchResults () {
        isFetching = true
        lastRequestId += 1
        
        hideNoResultsView()
        hideErrorView()
        
        if results.isEmpty {
            showNoResultsLoadingView()
        }
    }
    
    open func fetchNextResults () {
        isFetching = true
        lastRequestId += 1
        
        hideErrorView()
    }
    
    open func didFetchResults (results: [T], haveMoreResults: Bool? = nil, lastRequestId: Int? = nil, completion: (()->())? = nil) {
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
    
    open func didFetchNextResults (results: [T], haveMoreResults: Bool? = nil, lastRequestId: Int? = nil, completion: (()->())? = nil) {
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
    
    
    open func didFailedToFetchResults (error: Error? = nil) {
        isFetching = false
        
        hideNoResultsLoadingView()
        showErrorView(error: error)

        didEndFetching()
    }
    
    open func showNoResultsLoadingView () {
        noResultsLoadingView?.isHidden = false
    }
    
    open func hideNoResultsLoadingView () {
        noResultsLoadingView?.isHidden = true
    }
    
    open func showNoResultsView () {
        noResultsView?.isHidden = false
    }
    
    open func hideNoResultsView () {
        noResultsView?.isHidden = true
    }
    
    open func showErrorView (error: Error? = nil) {
        errorView?.isHidden = false
    }
    
    open func hideErrorView () {
        errorView?.isHidden = true
    }
    
    open func didEndFetching () {
        
    }
    
    //MARK: TableView delegate
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (nextPageLoaderCell != nil) && haveMoreResults {
            return results.count + 1
        }
        
        return results.count
    }
    
    @objc(tableView:heightForRowAtIndexPath:)
    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let nextPageLoaderCell = nextPageLoaderCell, haveMoreResults && indexPath.row >= results.count {
            return nextPageLoaderCell.frame.height
        }
        
        return jt_tableView(tableView, heightForRowAt: indexPath)
    }
    
    open func jt_tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    @objc(tableView:cellForRowAtIndexPath:)
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let nextPageLoaderCell = nextPageLoaderCell, haveMoreResults && indexPath.row >= results.count {
            return nextPageLoaderCell
        }
        else if(!self.isFetching && indexPath.row >= self.results.count - self.nextPageLoaderOffset && self.haveMoreResults){
            fetchNextResults()
        }

        return jt_tableView(tableView, cellForRowAt: indexPath)
    }

    open func jt_tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
        
}
