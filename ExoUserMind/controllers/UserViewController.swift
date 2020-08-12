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
    @IBOutlet private var tableView: UITableView!
    
    // MARK: Properties
    private let cellReuseIdentifier = "cell"
    private let searchController = UISearchController(searchResultsController: nil)
    
    private var isSearchBarEmpty: Bool {
      return searchController.searchBar.text?.isEmpty ?? true
    }
    private var isFiltering: Bool {
      return searchController.isActive && !isSearchBarEmpty
    }
    private var users: [User] = [] {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    private var filteredUsers: [User] = []
    private var informationView: InformationView?
    private let refreshControl = UIRefreshControl()
    
    // MARK: VC lifecycle
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onDidReceiveNotification(_:)),
                                               name: .waitingForConnexion,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onDidReceiveNotification(_:)),
                                               name: .taskBeingExecuted,
                                               object: nil)

        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView()
        // Add Refresh Control to Table View
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
        refreshControl.addTarget(self, action: #selector(refreshUsers), for: .valueChanged)
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search someone"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false // Display refresh control when search enable
        definesPresentationContext = true
        
        fetchUsers()
    }
    
    override func prepare(for segue: UIStoryboardSegue,
                          sender: Any?) {
        
        if segue.identifier == "showAlbums" {
            
            if let selectedUser = tableView.indexPathForSelectedRow?.row {
                let vc = segue.destination as! AlbumViewController
                vc.albumViewControllerModel = AlbumViewControllerModel(userID: isFiltering ? filteredUsers[selectedUser].id : users[selectedUser].id,
                                                                       userName: isFiltering ? filteredUsers[selectedUser].name : users[selectedUser].name)
                let backItem = UIBarButtonItem()
                backItem.title = "Back"
                navigationItem.backBarButtonItem = backItem
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        if let index = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: index,
                                  animated: true)
        }
    }
    
    // MARK: private function
    private func fetchUsers(fromRefresh: Bool = false) {
        
        let usersFromCache = CoreDataManagerService.shared.retrieveUsers()

        if usersFromCache.count > 0 {
            print("from cache")
            self.users = usersFromCache
        } else {
            if fromRefresh {
                users = []
            }
            print("from WS")
            ApiService.shared.retrieveUsers(completion: { result in
                switch result {
                case .success(let usersRetrieved):
                    self.users = usersRetrieved
                case .failure(let error):
                    if let exception = error as? Exceptions {
                        switch exception {
                        case .badData:
                            self.setLabelInformation(type: .badDataFormat)
                        case .httpError:
                            self.setLabelInformation(type: .httpException)
                        default:
                            self.setLabelInformation(type: .unexpectedError)
                        }
                    } else {
                        self.setLabelInformation(type: .unexpectedError)
                    }
                }
            })
        }
    }
    
    private func setLabelInformation(type: InformationView.LabelInformationType) {
        if let informationView = informationView {
            informationView.setLabelInformation(type: type,
                                                from: "user")
        } else {
            informationView = InformationView()
            if let informationView = informationView {
                informationView.frame = self.view.bounds
                informationView.setLabelInformation(type: type,
                                                    from: "user")
                self.view.addSubview(informationView)
            }
        }
    }
    
    // MARK: objc function
    @objc func onDidReceiveNotification(_ notification:Notification) {
        switch notification.name {
        case .taskBeingExecuted:
            informationView?.removeFromSuperview()
            informationView = nil
        case .waitingForConnexion:
            if informationView == nil {
                informationView = InformationView()
                if let informationView = informationView {
                    informationView.frame = self.view.bounds
                    self.view.addSubview(informationView)
                }
            }
        default:
            print("unexpected")
        }
    }

    @objc private func refreshUsers(_ sender: Any) {

        CoreDataManagerService.shared.clearUsers()
        self.fetchUsers(fromRefresh: true)
        self.refreshControl.endRefreshing()
    }
}

// MARK: Table view delegate
extension UserViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isFiltering ? filteredUsers.count : users.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as? UserCell {

            if isFiltering && filteredUsers.count > indexPath.row {
                cell.configure(withUserViewModel: UserCellViewModel(user: filteredUsers[indexPath.row]))
            } else if !isFiltering && users.count > indexPath.row {
                cell.configure(withUserViewModel: UserCellViewModel(user: users[indexPath.row]))
            }
                
            return cell
        }

        return UITableViewCell()
    }
    
}

// MARK: Search result updating
extension UserViewController: UISearchResultsUpdating {
    func filterContentForSearchText(_ searchText: String) {
        
        filteredUsers = users.filter { (user: User) -> Bool in
            return user.name.lowercased().contains(searchText.lowercased())
                || user.username.lowercased().contains(searchText.lowercased())
        }
      
        tableView.reloadData()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        filterContentForSearchText(searchBar.text!)
    }
}

