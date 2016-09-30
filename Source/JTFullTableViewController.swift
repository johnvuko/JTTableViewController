//
//  JTFullTableViewController.swift
//  JTFullTableViewController
//
//  Created by Jonathan Tribouharet
//

import UIKit

public class JTFullTableViewController<T>: JTTableViewController<T>, UITableViewDelegate, UITableViewDataSource {

	public let refreshControl = UIRefreshControl()

	public override func loadView () {
		super.loadView()

		let tableView = UITableView()
		self.view = tableView
		self.tableView = tableView

		tableView.dataSource = self
		tableView.delegate = self

		refreshControl.addTarget(self, action: #selector(fetchResults), for: .valueChanged)
		tableView.addSubview(refreshControl)
	}

   public override func didEndFetching () {
        super.didEndFetching()
        refreshControl.endRefreshing()
    }

}