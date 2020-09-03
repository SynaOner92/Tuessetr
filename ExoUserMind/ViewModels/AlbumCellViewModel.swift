//
//  AlbumCellViewModel.swift
//  ExoUserMind
//
//  Created by Nicolas Moranny on 06/08/2020.
//  Copyright © 2020 Nicolas Moranny. All rights reserved.
//

import Foundation

public class AlbumCellViewModel {

    private let album: Album

    init(album: Album) {
        self.album = album
    }

    var valueTitle: String {
        return album.title
    }

}
