//
//  PhotoViewController.swift
//  ExoUserMind
//
//  Created by Nicolas Moranny on 06/08/2020.
//  Copyright © 2020 Nicolas Moranny. All rights reserved.
//

import UIKit

class PhotoViewController: UIViewController {
    
    // MARK: IBOutlet
    @IBOutlet private var collectionView: UICollectionView!
    
    // MARK: Properties
    var photoViewControllerModel: PhotoViewControllerModel!

    private let cellReuseIdentifier = "cell"
    private var photos: [Photo] = [] {
        didSet {
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    private var informationView: InformationView?
    
    // MARK: IBAction
    @IBAction func refreshClicked(_ sender: UIBarButtonItem) {
        CoreDataManagerService.shared.clearPhotosData(forAlbum: photoViewControllerModel.albumID)
        self.retrievePhotosFromWebservice()
    }
    
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
        
        title = photoViewControllerModel.albumName
        
        CoreDataManagerService.shared.retrievePhotos(albumId: self.photoViewControllerModel.albumID) { photosFromCache in
            
            if photosFromCache.count > 0 {
                print("from cache")
                self.photos = photosFromCache
            } else {
                print("from WS")
                self.retrievePhotosFromWebservice()
            }
        }
    }
    
    // MARK: Private function
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
    
    private func retrievePhotosFromWebservice() {
        ApiService.shared.retrievePhotos(forUserID: self.photoViewControllerModel.userID,
                                         forAlbumID: self.photoViewControllerModel.albumID) { result in
            switch result {
            case .success(let photosRetrieved):
                self.photos = photosRetrieved
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
        }
    }
    
    // MARK: objc function
    @objc func onDidReceiveNotification(_ notification:Notification) {
        switch notification.name {
        case .taskBeingExecuted:
            informationView?.removeFromSuperview()
            informationView = nil
        case .waitingForConnexion:
            if informationView == nil && photos.count == 0 {
                informationView = InformationView()
                if let noConnexionView = informationView {
                    noConnexionView.frame = self.view.bounds
                    self.view.addSubview(noConnexionView)
                }
            }
        default:
            print("unexpected")
        }
    }
}

// MARK: Collection view data source & delegate
extension PhotoViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
        
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier,
                                                         for: indexPath) as? PhotoCell {
            if photos.count > indexPath.row {
                cell.configure(withPhotoViewModel: PhotoCellViewModel(photo: photos[indexPath.row]))
            }
            return cell
        }

        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let noOfCellsInRow = UIScreen.main.bounds.width / 180 
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        let totalSpace = flowLayout.sectionInset.left
            + flowLayout.sectionInset.right
            + (flowLayout.minimumInteritemSpacing * CGFloat(noOfCellsInRow - 1))

        let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(noOfCellsInRow))

        return CGSize(width: size, height: size)
    }

}
