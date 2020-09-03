//
//  PhotoViewControllerModel.swift
//  ExoUserMind
//
//  Created by Nicolas Moranny on 07/08/2020.
//  Copyright © 2020 Nicolas Moranny. All rights reserved.
//

import Foundation

class PhotoViewControllerModel: BaseViewModel<FullPhoto> {

    let userID: Int
    let albumID: Int
    let albumName: String

    init(userID: Int,
         albumID: Int,
         albumName: String) {
        self.userID = userID
        self.albumID = albumID
        self.albumName = albumName
    }

    func fetchPhotos(fromRefresh: Bool = false) {

        fetchDatas(with: self.userID,
                   for: self.albumID,
                   fromRefresh: fromRefresh,
                   FullPhoto.self)
    }
}
