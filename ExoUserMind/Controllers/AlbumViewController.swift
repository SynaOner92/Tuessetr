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
    var albumViewControllerModel: AlbumViewControllerModel!

    private let refreshControl = UIRefreshControl()
    private var informationView: InformationView?

    // MARK: VC Lifecycle
    override func viewDidLoad() {

        super.viewDidLoad()

        self.albumViewControllerModel.delegate = self

        self.title = self.albumViewControllerModel.userName

        // Add Refresh Control to Table View
        if #available(iOS 10.0, *) {

            self.tableView.refreshControl = refreshControl
        } else {

            self.tableView.addSubview(refreshControl)
        }
        self.refreshControl.addTarget(self, action: #selector(refreshAlbums), for: .valueChanged)

        self.albumViewControllerModel.fetchAlbums()

    }

    override func viewWillAppear(_ animated: Bool) {

        super.viewWillAppear(animated)

        if let index = self.tableView.indexPathForSelectedRow {

            self.tableView.deselectRow(at: index,
                                       animated: true)
        }
    }

    override func prepare(for segue: UIStoryboardSegue,
                          sender: Any?) {

        if segue.identifier == "showPhotos" {

            if let selectedAlbum = self.tableView.indexPathForSelectedRow?.row,
                let vc = segue.destination as? PhotoViewController {

                vc.photoViewControllerModel = PhotoViewControllerModel(userID: self.albumViewControllerModel.userID,
                                                                       albumID: self.albumViewControllerModel.data[selectedAlbum].id,
                                                                       albumName: self.albumViewControllerModel.data[selectedAlbum].title)
            }
        }
    }

    @objc private func refreshAlbums(_ sender: Any) {

        self.albumViewControllerModel.clearAlbums()
        self.albumViewControllerModel.fetchAlbums(fromRefresh: true)
        self.refreshControl.endRefreshing()
    }
}

// MARK: Table view delegate
extension AlbumViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return self.albumViewControllerModel.data.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if let cell = tableView.dequeueReusableCell(withIdentifier: AlbumCell.identifier) as? AlbumCell {

            if self.albumViewControllerModel.data.count > indexPath.row {

                cell.configure(with: AlbumCellViewModel(album: self.albumViewControllerModel.data[indexPath.row]))
            }

            return cell
        }

        return UITableViewCell()
    }
}

// MARK: Base view model protocol
extension AlbumViewController: BaseViewModelProtocol {

    func setLabelInformation(type: InformationView.LabelInformationType) {

        if let informationView = self.informationView {

            informationView.setLabelInformation(type: type,
                                                from: "album")
        } else {

            self.informationView = InformationView()
            if let informationView = self.informationView {

                informationView.frame = self.view.bounds
                informationView.setLabelInformation(type: type,
                                                    from: "album")
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
