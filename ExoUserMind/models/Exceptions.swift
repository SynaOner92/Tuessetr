//
//  Exceptions.swift
//  ExoUserMind
//
//  Created by Nicolas Moranny on 06/08/2020.
//  Copyright © 2020 Nicolas Moranny. All rights reserved.
//

import Foundation

enum Exceptions: Error {
    case invalidGPSCoordinates
    case httpError
    case badData
    case unexpectedError
}
