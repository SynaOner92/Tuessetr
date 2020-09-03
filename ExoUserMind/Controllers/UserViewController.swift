//
//  ViewController.swift
//  ExoUserMind
//
//  Created by Nicolas Moranny on 06/08/2020.
//  Copyright © 2020 Nicolas Moranny. All rights reserved.
//

import UIKit

class UserViewController: UIViewController, UITableViewDataSource {
    
    // MARK: IBOutlet
    @IBOutlet private var tableView: UITableView! {
        didSet {
            self.tableView.delegate = self
            self.tableView.dataSource = self
            self.tableView.estimatedRowHeight = 44.0
            self.tableView.rowHeight = UITableView.automaticDimension
            self.tableView.tableFooterView = UIView()
        }
    }

    // MARK: Properties
    private let searchController = UISearchController(searchResultsController: nil)
    private let refreshControl = UIRefreshControl()
    private let userViewControllerModel = UserViewControllerModel()

    private var filteredUsers: [User] = []
    private var informationView: InformationView?

    private var isSearchBarEmpty: Bool {
      return self.searchController.searchBar.text?.isEmpty ?? true
    }
    private var isFiltering: Bool {
      return self.searchController.isActive && !self.isSearchBarEmpty
    }

    // MARK: VC lifecycle
    override func viewDidLoad() {

        super.viewDidLoad()

        self.userViewControllerModel.delegate = self

        // Add Refresh Control to Table View
        if #available(iOS 10.0, *) {

            self.tableView.refreshControl = refreshControl
        } else {

            self.tableView.addSubview(refreshControl)
        }
        self.refreshControl.addTarget(self, action: #selector(refreshUsers), for: .valueChanged)

        self.searchController.searchResultsUpdater = self
        self.searchController.obscuresBackgroundDuringPresentation = false
        self.searchController.searchBar.placeholder = "Search someone"
        self.navigationItem.searchController = searchController
        self.navigationItem.hidesSearchBarWhenScrolling = false // Display refresh control when search enable
        self.definesPresentationContext = true

        self.userViewControllerModel.fetchUsers()
    }

    override func prepare(for segue: UIStoryboardSegue,
                          sender: Any?) {

        if segue.identifier == "showAlbums" {

            if let selectedUser = self.tableView.indexPathForSelectedRow?.row,
                let vc = segue.destination as? AlbumViewController {

                let userID: Int
                let userName: String

                if self.isFiltering {

                    userID = self.filteredUsers[selectedUser].id
                    userName = self.filteredUsers[selectedUser].name
                } else {

                    userID = self.userViewControllerModel.data[selectedUser].id
                    userName = self.userViewControllerModel.data[selectedUser].name
                }

                vc.albumViewControllerModel = AlbumViewControllerModel(userID: userID,
                                                                       userName: userName)
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {

        super.viewWillAppear(animated)

        if let index = self.tableView.indexPathForSelectedRow {

            self.tableView.deselectRow(at: index,
                                       animated: true)
        }
    }

    @objc private func refreshUsers(_ sender: Any) {

        self.userViewControllerModel.clearUsers()
        self.userViewControllerModel.fetchUsers(fromRefresh: true)
        self.refreshControl.endRefreshing()
    }
}

// MARK: Table view delegate
extension UserViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return self.isFiltering ? self.filteredUsers.count : self.userViewControllerModel.data.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if let cell = tableView.dequeueReusableCell(withIdentifier: UserCell.identifier) as? UserCell {

            if self.isFiltering && self.filteredUsers.count > indexPath.row {

                cell.configure(withUserViewModel: UserCellViewModel(user: self.filteredUsers[indexPath.row]))
            } else if !self.isFiltering && self.userViewControllerModel.data.count > indexPath.row {

                cell.configure(withUserViewModel: UserCellViewModel(user: self.userViewControllerModel.data[indexPath.row]))
            }

            return cell
        }

        return UITableViewCell()
    }

}

// MARK: Search result updating
extension UserViewController: UISearchResultsUpdating {

    func filterContentForSearchText(_ searchText: String) {

        self.filteredUsers = self.userViewControllerModel.data.filter { (user: User) -> Bool in
            return user.name.lowercased().contains(searchText.lowercased())
                || user.username.lowercased().contains(searchText.lowercased())
        }

        self.tableView.reloadData()
    }

    func updateSearchResults(for searchController: UISearchController) {

        if let searchBarText = searchController.searchBar.text {

            self.filterContentForSearchText(searchBarText)
        }
    }
}

// MARK: Base view model protocol
extension UserViewController: BaseViewModelProtocol {

    func setLabelInformation(type: InformationView.LabelInformationType) {

        if let informationView = self.informationView {

            informationView.setLabelInformation(type: type,
                                                from: "user")
        } else {

            self.informationView = InformationView()

            if let informationView = self.informationView {

                informationView.frame = self.view.bounds
                informationView.setLabelInformation(type: type,
                                                    from: "user")
                self.view.addSubview(informationView)
            }
        }
    }

    func removeInformationView() {

        self.informationView?.removeFromSuperview()
        self.informationView = nil
    }

    func displayInformationView() {

         if self.informationView == nil {

            self.informationView = InformationView()
            if let informationView = self.informationView {

                informationView.frame = self.view.bounds
                self.view.addSubview(informationView)
            }
        }
    }

    func dataUpdated() {
        self.tableView.reloadData()
    }

}
