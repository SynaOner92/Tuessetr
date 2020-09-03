//
//  FullAlbum+Extension.swift
//  ExoUserMind
//
//  Created by Nicolas Moranny on 19/08/2020.
//  Copyright © 2020 Nicolas Moranny. All rights reserved.
//

extension FullAlbum: GenericConstructor {

    typealias T = Album

    func genericConstructor(constructorObject: Album) {

        self.id = Int32(constructorObject.id)
        self.title = constructorObject.title
        self.userId = Int32(constructorObject.userId)

    }

    func convertToModel() -> Album {
        return Album(userId: Int(self.userId),
                     id: Int(self.id),
                     title: self.title!)
    }

}
