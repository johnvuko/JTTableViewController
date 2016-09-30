//
//  JTFullTableViewController.swift
//  JTFullTableViewController
//
//  Created by Jonathan Tribouharet
//

import UIKit

open class JTFullTableViewController<T>: JTTableViewController<T>, UITableViewDelegate, UITableViewDataSource {

	open let refreshControl = UIRefreshControl()

	open override func loadView () {
		super.loadView()

		let tableView = UITableView()
		self.view.addSubview(tableView)
		self.tableView = tableView

		self.view.addConstraint(NSLayoutConstraint(item: tableView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1.0, constant: 0.0))
		self.view.addConstraint(NSLayoutConstraint(item: tableView, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1.0, constant: 0.0))
		self.view.addConstraint(NSLayoutConstraint(item: self.view, attribute: .bottom, relatedBy: .equal, toItem: tableView, attribute: .bottom, multiplier: 1.0, constant: 0.0))
		self.view.addConstraint(NSLayoutConstraint(item: self.view, attribute: .trailing, relatedBy: .equal, toItem: tableView, attribute: .trailing, multiplier: 1.0, constant: 0.0))

		tableView.dataSource = self
		tableView.delegate = self

		refreshControl.addTarget(self, action: #selector(fetchResults), for: .valueChanged)
		tableView.addSubview(refreshControl)
	}

   open override func didEndFetching () {
        super.didEndFetching()
        refreshControl.endRefreshing()
    }

}