//
//  AlbumViewControllerModel.swift
//  ExoUserMind
//
//  Created by Nicolas Moranny on 07/08/2020.
//  Copyright © 2020 Nicolas Moranny. All rights reserved.
//

import Foundation

class AlbumViewControllerModel: BaseViewModel<FullAlbum> {

    let userID: Int
    let userName: String

    init(userID: Int,
         userName: String) {
        self.userID = userID
        self.userName = userName
    }

    func fetchAlbums(fromRefresh: Bool = false) {

        fetchDatas(with: self.userID,
                   fromRefresh: fromRefresh,
                   FullAlbum.self)
    }

    func clearAlbums() {

        clearDatas(FullAlbum.self)
    }
}
