//
//  NSManagedObject+Extension.swift
//  ExoUserMind
//
//  Created by Nicolas Moranny on 19/08/2020.
//  Copyright © 2020 Nicolas Moranny. All rights reserved.
//

import CoreData

extension NSManagedObject {
    
    static var entityName: String { String(describing: self) }
}
