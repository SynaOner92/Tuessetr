//
//  GenericConstructor.swift
//  ExoUserMind
//
//  Created by Nicolas Moranny on 19/08/2020.
//  Copyright © 2020 Nicolas Moranny. All rights reserved.
//

import CoreData

protocol GenericConstructor: NSManagedObject {
    
    associatedtype T: Decodable, MandatoryID

    func genericConstructor(constructorObject: T)
    func convertToModel() -> T
}
