//
//  AlbumViewController.swift
//  ExoUserMind
//
//  Created by Nicolas Moranny on 06/08/2020.
//  Copyright © 2020 Nicolas Moranny. All rights reserved.
//

import UIKit

class AlbumViewController: UIViewController, UITableViewDataSource {
    
    // MARK: IBOutlet
    @IBOutlet private var tableView: UITableView!
    
    // MARK: Properties
    var albumViewControllerModel: AlbumViewControllerModel!
    
    private let cellReuseIdentifier = "cell"
    private var albums: [Album] = [] {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    private var informationView: InformationView?
    private let refreshControl = UIRefreshControl()
    
    // MARK: VC Lifecycle
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
        
        title = albumViewControllerModel.userName
        
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
        refreshControl.addTarget(self, action: #selector(refreshAlbums), for: .valueChanged)
        
        fetchAlbums()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        if let index = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: index,
                                  animated: true)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue,
                          sender: Any?) {
        
        if segue.identifier == "showPhotos" {
            
            if let selectedAlbum = tableView.indexPathForSelectedRow?.row {
                let vc = segue.destination as! PhotoViewController
                let backItem = UIBarButtonItem()
                backItem.title = "Back"
                navigationItem.backBarButtonItem = backItem
                vc.photoViewControllerModel = PhotoViewControllerModel(userID: albumViewControllerModel.userID,
                                                                       albumID: albums[selectedAlbum].id,
                                                                       albumName: albums[selectedAlbum].title)
            }
        }
    }
    
    // MARK: private function
    private func fetchAlbums(fromRefresh: Bool = false) {
        let albumsFromCache = CoreDataManagerService.shared.retrieveAlbums()
            .filter { $0.userId == albumViewControllerModel.userID }
        if albumsFromCache.count > 0 {
            print("from cache")
            self.albums = albumsFromCache
        } else {
            print("from WS")
            if fromRefresh {
                albums = []
            }
            
            ApiService.shared.retrieveAlbums(forUserID: albumViewControllerModel.userID,
                                             completion: { result in
                switch result {
                case .success(let albumsRetrieved):
                    self.albums = albumsRetrieved
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
                                                from: "album")
        } else {
            informationView = InformationView()
            if let informationView = informationView {
                informationView.frame = self.view.bounds
                informationView.setLabelInformation(type: type,
                                                    from: "album")
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
            setLabelInformation(type: .noInternet)
        default:
            print("unexpected")
        }
    }
    
    @objc private func refreshAlbums(_ sender: Any) {
        
        CoreDataManagerService.shared.clearAlbums()
        self.fetchAlbums(fromRefresh: true)
        self.refreshControl.endRefreshing()
    }
}

// MARK: Table view delegate
extension AlbumViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albums.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as? AlbumCell {
            if albums.count > indexPath.row {
                cell.configure(withAlbumViewModel: AlbumCellViewModel(album: albums[indexPath.row]))
            }
            return cell
        }

        return UITableViewCell() 
    }
}
