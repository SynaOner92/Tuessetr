//
//  UserViewModel.swift
//  ExoUserMind
//
//  Created by Nicolas Moranny on 19/08/2020.
//  Copyright © 2020 Nicolas Moranny. All rights reserved.
//

import Foundation
import CoreData

class UserViewControllerModel: BaseViewModel<FullUser> {

    func fetchUsers(fromRefresh: Bool = false) {

        fetchDatas(fromRefresh: fromRefresh,
                   FullUser.self)
    }

    func clearUsers() {

        clearDatas(FullUser.self)
    }
}
