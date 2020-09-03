//
//  FullUser+Extension.swift
//  ExoUserMind
//
//  Created by Nicolas Moranny on 19/08/2020.
//  Copyright © 2020 Nicolas Moranny. All rights reserved.
//

import Foundation

extension FullUser: GenericConstructor {

    typealias T = User

    func genericConstructor(constructorObject: User) {

        self.id = Int32(constructorObject.id)
        self.email = constructorObject.email
        self.name = constructorObject.name
        self.phone = constructorObject.phone
        self.username = constructorObject.username
        self.website = constructorObject.website
        self.city = constructorObject.address.city
        self.street = constructorObject.address.street
        self.suite = constructorObject.address.suite
        self.zipcode = constructorObject.address.zipcode
        self.lat = constructorObject.address.geo.lat
        self.lng = constructorObject.address.geo.lng
        self.companyBs = constructorObject.company.bs
        self.companyCatchPhrase = constructorObject.company.catchPhrase
        self.companyName = constructorObject.company.name
    }

    func convertToModel() -> User {
        return User(id: Int(self.id),
                    name: self.name!,
                    username: self.username!,
                    email: self.email!,
                    phone: self.phone!,
                    website: self.website!,
                    address: Address(street: self.street!,
                                     suite: self.suite!,
                                     city: self.city!,
                                     zipcode: self.zipcode!,
                                     geo: Coordinate(lat: self.lat,
                                                     lng: self.lng)),
                    compagny: Company(name: self.companyName!,
                                      catchPhrase: self.companyCatchPhrase!,
                                      bs: self.companyBs!))
    }

}
