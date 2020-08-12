//
//  Companies.swift
//  ExoUserMind
//
//  Created by Nicolas Moranny on 06/08/2020.
//  Copyright © 2020 Nicolas Moranny. All rights reserved.
//

import Foundation

class Company: Codable {
    
    let name: String
    let catchPhrase: String
    let bs: String
    
    init(name: String,
         catchPhrase: String,
         bs: String) {
        self.name = name
        self.catchPhrase = catchPhrase
        self.bs = bs
    }
}
