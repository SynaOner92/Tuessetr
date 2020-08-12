//
//  AlbumViewControllerModel.swift
//  ExoUserMind
//
//  Created by Nicolas Moranny on 07/08/2020.
//  Copyright © 2020 Nicolas Moranny. All rights reserved.
//

import Foundation

public class AlbumViewControllerModel {
    
    let userID: Int
    let userName: String
    
    init(userID: Int,
         userName: String) {
        self.userID = userID
        self.userName = userName
    }
}
