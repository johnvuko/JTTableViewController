//
//  JTTableViewController.swift
//  JTTableViewController
//
//  Created by Jonathan Tribouharet
//

import UIKit

open class JTTableViewController<T>: UIViewController {
    
    @IBOutlet open var tableView: UITableView?
    @IBOutlet open var nextPageLoaderCell: UITableViewCell?
    
    @IBOutlet open var noResultsView: UIView? {
        didSet {
            noResultsView?.isHidden = true
            noResultsView?.isUserInteractionEnabled = false
        }
    }
    
    @IBOutlet open var noResultsLoadingView: UIView? {
        didSet {
            noResultsLoadingView?.isHidden = true
            noResultsLoadingView?.isUserInteractionEnabled = false
        }
    }
    
    @IBOutlet open var errorView: UIView? {
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
        lastRequestId += 1
        
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
        
        didEndFetching()
        
        if let completion = completion {
            completion()
        }
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
        
        didEndFetching()
        
        if let completion = completion {
            completion()
        }
    }
    
    open func didFailedToFetchResults (error: Error? = nil, lastRequestId: Int? = nil, completion: (()->())? = nil) {
        if let lastRequestId = lastRequestId {
            if self.lastRequestId != lastRequestId {
                return
            }
        }
        
        isFetching = false
        
        hideNoResultsLoadingView()
        showErrorView(error: error)
        
        didEndFetching()
        
        if let completion = completion {
            completion()
        }
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
    
    open func canShowNextPageLoaderCell (tableView: UITableView? = nil, section: Int? = nil, row: Int? = nil) -> Bool {
        if nextPageLoaderCell != nil, haveMoreResults {
            if let tableView = tableView, let section = section {
                // if not last section
                if self.numberOfSections(in: tableView) != section + 1 {
                    return false
                }
                
                if let row = row {
                    // if not last row => nextPageLoaderCell
                    if self.tableView(tableView, numberOfRowsInSection: section) != row + 1 {
                        return false
                    }
                }
            }
            
            return true
        }
        
        return false
    }
    
    open func shouldFetchNextResults(tableView: UITableView, indexPath: IndexPath) -> Bool {
        if self.isFetching || !self.haveMoreResults || self.nextPageLoaderCell == nil {
            return false
        }
        
        // if not last section
        if self.numberOfSections(in: tableView) != indexPath.section + 1 {
            return false
        }
        
        if indexPath.row >= self.tableView(tableView, numberOfRowsInSection: indexPath.section) - (self.nextPageLoaderOffset + 1) {
            return true
        }
        
        return false
    }
    
    @objc(numberOfSectionsInTableView:)
    open func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    @objc(tableView:numberOfRowsInSection:)
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if canShowNextPageLoaderCell(tableView: tableView, section: section) {
            return jt_tableView(tableView, numberOfRowsInSection: section) + 1
        }
        
        return jt_tableView(tableView, numberOfRowsInSection: section)
    }
    
    open func jt_tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    @objc(tableView:heightForRowAtIndexPath:)
    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if canShowNextPageLoaderCell(tableView: tableView, section: indexPath.section, row: indexPath.row), let nextPageLoaderCell = nextPageLoaderCell {
            return nextPageLoaderCell.frame.height
        }
        
        return jt_tableView(tableView, heightForRowAt: indexPath)
    }
    
    open func jt_tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    @objc(tableView:cellForRowAtIndexPath:)
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if canShowNextPageLoaderCell(tableView: tableView, section: indexPath.section, row: indexPath.row), let nextPageLoaderCell = nextPageLoaderCell {
            if !self.isFetching {
                fetchNextResults()
            }
            return nextPageLoaderCell
        }
        
        if shouldFetchNextResults(tableView: tableView, indexPath: indexPath) {
            fetchNextResults()
        }
        
        return jt_tableView(tableView, cellForRowAt: indexPath)
    }
    
    open func jt_tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
}
