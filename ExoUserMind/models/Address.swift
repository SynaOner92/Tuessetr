//
//  Address.swift
//  ExoUserMind
//
//  Created by Nicolas Moranny on 06/08/2020.
//  Copyright © 2020 Nicolas Moranny. All rights reserved.
//

import Foundation

class Address: Codable {
    
    let street: String
    let suite: String
    let city: String
    let zipcode: String
    let geo: Coordinate
    
    init(street: String,
         suite: String,
         city: String,
         zipcode: String,
         geo: Coordinate) {
        self.street = street
        self.suite = suite
        self.city = city
        self.zipcode = zipcode
        self.geo = Coordinate(lat: geo.lat,
                              lng: geo.lng)
    }
}
