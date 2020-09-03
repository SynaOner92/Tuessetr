//
//  PhotoViewController.swift
//  ExoUserMind
//
//  Created by Nicolas Moranny on 06/08/2020.
//  Copyright © 2020 Nicolas Moranny. All rights reserved.
//

import UIKit
import Foundation
import CoreData

class PhotoViewController: UIViewController {

    // MARK: IBOutlet
    @IBOutlet private var collectionView: UICollectionView!

    // MARK: Properties
    var photoViewControllerModel: PhotoViewControllerModel!

    private var informationView: InformationView?

    // MARK: IBAction
    @IBAction func refreshClicked(_ sender: UIBarButtonItem) {

        CoreDataManagerService.shared.clearPhotosData(forAlbum: photoViewControllerModel.albumID)
        self.photoViewControllerModel.fetchPhotos()
    }

    // MARK: VC Lifecycle
    override func viewDidLoad() {

        super.viewDidLoad()

        self.photoViewControllerModel.delegate = self

        self.title = self.photoViewControllerModel.albumName

        self.photoViewControllerModel.fetchPhotos()
    }
}

// MARK: Collection view data source & delegate
extension PhotoViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {

        return self.photoViewControllerModel.data.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCell.identifier,
                                                         for: indexPath) as? PhotoCell {

            if self.photoViewControllerModel.data.count > indexPath.row {

                cell.configure(with: PhotoCellViewModel(photo: self.photoViewControllerModel.data[indexPath.row]))
            }
            return cell
        }

        return UICollectionViewCell()
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        guard let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout
            else { return CGSize.zero }

        let noOfCellsInRow = UIScreen.main.bounds.width / 180
        let totalSpace = flowLayout.sectionInset.left
            + flowLayout.sectionInset.right
            + (flowLayout.minimumInteritemSpacing * CGFloat(noOfCellsInRow - 1))

        let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(noOfCellsInRow))

        return CGSize(width: size, height: size)
    }

}

// MARK: Base view model protocol
extension PhotoViewController: BaseViewModelProtocol {

    func setLabelInformation(type: InformationView.LabelInformationType) {

        if let informationView = self.informationView {

            informationView.setLabelInformation(type: type,
                                                from: "photo")
        } else {

            self.informationView = InformationView()

            if let informationView = self.informationView {

                informationView.frame = self.view.bounds
                informationView.setLabelInformation(type: type,
                                                    from: "photo")
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

        self.collectionView.reloadData()
    }

}
