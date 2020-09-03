//
//  User.swift
//  ExoUserMind
//
//  Created by Nicolas Moranny on 06/08/2020.
//  Copyright © 2020 Nicolas Moranny. All rights reserved.
//

import Foundation

struct User: Codable, MandatoryID {

    typealias T = FullUser

    let id: Int
    let name: String
    let username: String
    let email: String
    let phone: String
    let website: String
    let address: Address
    let company: Company

    init(id: Int,
         name: String,
         username: String,
         email: String,
         phone: String,
         website: String,
         address: Address,
         compagny: Company) {

        self.id = id
        self.name = name
        self.username = username
        self.email = email
        self.phone = phone
        self.website = website
        self.address = Address(street: address.street,
                               suite: address.suite,
                               city: address.city,
                               zipcode: address.zipcode,
                               geo: Coordinate(lat: address.geo.lat,
                                               lng: address.geo.lng))
        self.company = Company(name: compagny.name,
                               catchPhrase: compagny.catchPhrase,
                               bs: compagny.bs)
    }
}
