//
//  Logs.swift
//  ExoUserMind
//
//  Created by Nicolas Moranny on 02/09/2020.
//  Copyright © 2020 Nicolas Moranny. All rights reserved.
//

func log(_ value: String) {
    #if DEBUG
    print(value)
    #endif
}
