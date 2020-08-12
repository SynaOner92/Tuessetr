//
//  Coordinates.swift
//  ExoUserMind
//
//  Created by Nicolas Moranny on 06/08/2020.
//  Copyright © 2020 Nicolas Moranny. All rights reserved.
//

import Foundation

class Coordinate: Codable {
    
    let lat: Double
    let lng: Double
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        guard
            let lattitude = Double(try container.decode(String.self, forKey: .lat)),
            let longitude = Double(try container.decode(String.self, forKey: .lng))
            else { throw Exceptions.invalidGPSCoordinates }
        
        lat = lattitude
        lng = longitude
    }
    
    init(lat: Double,
         lng: Double) {
        self.lat = lat
        self.lng = lat
    }
}
