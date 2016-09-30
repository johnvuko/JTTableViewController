//
//  JTTableViewController.swift
//  JTTableViewController
//
//  Created by Jonathan Tribouharet
//

import UIKit

public class JTTableViewController<T>: UIViewController {
    
    public var tableView: UITableView?
    public var nextPageLoaderCell: UITableViewCell?
    
    public var noResultsView: UIView? {
        didSet {
            noResultsView?.isHidden = true
            noResultsView?.isUserInteractionEnabled = false
        }
    }
    
    public var noResultsLoadingView: UIView? {
        didSet {
            noResultsLoadingView?.isHidden = true
            noResultsLoadingView?.isUserInteractionEnabled = false
        }
    }
    
    public var errorView: UIView? {
        didSet {
            errorView?.isHidden = true
            errorView?.isUserInteractionEnabled = false
        }
    }
    
    public var nextPageLoaderOffset = 3
    
    public private(set) var results = [T]()
    public private(set) var haveMoreResults = false
    public private(set) var isFetching = false
    
    // Use to directly have access to results
    public var unsafeResults: [T] {
        get {
            return results
        }
        set (value) {
            results = value
        }
    }
    
    // Used to ignore invalid / older requests
    public private(set) var lastRequestId = 0
    
    public func resetResults (scrollTop: Bool = false, scrollAnimated: Bool = true) {
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
    
    public func fetchResults () {
        isFetching = true
        lastRequestId += 1
        
        hideNoResultsView()
        hideErrorView()
        
        if results.isEmpty {
            showNoResultsLoadingView()
        }
    }
    
    public func fetchNextResults () {
        isFetching = true
        lastRequestId += 1
        
        hideErrorView()
    }
    
    public func didFetchResults (results: [T], haveMoreResults: Bool? = nil, lastRequestId: Int? = nil, completion: (()->())? = nil) {
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
    
    public func didFetchNextResults (results: [T], haveMoreResults: Bool? = nil, lastRequestId: Int? = nil, completion: (()->())? = nil) {
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
    
    
    public func didFailedToFetchResults (error: Error? = nil) {
        isFetching = false
        
        hideNoResultsLoadingView()
        showErrorView(error: error)

        didEndFetching()
    }
    
    public func showNoResultsLoadingView () {
        noResultsLoadingView?.isHidden = false
    }
    
    public func hideNoResultsLoadingView () {
        noResultsLoadingView?.isHidden = true
    }
    
    public func showNoResultsView () {
        noResultsView?.isHidden = false
    }
    
    public func hideNoResultsView () {
        noResultsView?.isHidden = true
    }
    
    public func showErrorView (error: Error? = nil) {
        errorView?.isHidden = false
    }
    
    public func hideErrorView () {
        errorView?.isHidden = true
    }
    
    public func didEndFetching () {
        
    }
    
    //MARK: TableView delegate
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (nextPageLoaderCell != nil) && haveMoreResults {
            return results.count + 1
        }
        
        return results.count
    }
    
    @objc(tableView:heightForRowAtIndexPath:)
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let nextPageLoaderCell = nextPageLoaderCell, haveMoreResults && indexPath.row >= results.count {
            return nextPageLoaderCell.frame.height
        }
        
        return jt_tableView(tableView, heightForRowAt: indexPath)
    }
    
    public func jt_tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    @objc(tableView:cellForRowAtIndexPath:)
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let nextPageLoaderCell = nextPageLoaderCell, haveMoreResults && indexPath.row >= results.count {
            return nextPageLoaderCell
        }
        else if(!self.isFetching && indexPath.row >= self.results.count - self.nextPageLoaderOffset && self.haveMoreResults){
            fetchNextResults()
        }

        return jt_tableView(tableView, cellForRowAt: indexPath)
    }

    public func jt_tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
        
}
