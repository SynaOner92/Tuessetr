//
//  Album.swift
//  ExoUserMind
//
//  Created by Nicolas Moranny on 06/08/2020.
//  Copyright © 2020 Nicolas Moranny. All rights reserved.
//

import Foundation

struct Album: Codable, MandatoryID {

    let userId: Int
    let id: Int
    let title: String

    init(userId: Int,
         id: Int,
         title: String) {

        self.userId = userId
        self.id = id
        self.title = title
    }
}
