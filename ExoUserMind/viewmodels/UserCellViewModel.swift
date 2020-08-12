//
//  UserCellViewModel.swift
//  ExoUserMind
//
//  Created by Nicolas Moranny on 06/08/2020.
//  Copyright © 2020 Nicolas Moranny. All rights reserved.
//

import Foundation

public class UserCellViewModel {
    
    private let user: User
    
    init(user: User) {
        self.user = user
    }
    
    var displayNameAndUsername: String {
        return user.name + " (" + user.username + ")"
    }
    
    var displayMail: String {
        return "Mail: \(user.email)"
    }
    
    var valueMail: String {
        return user.email
    }
    
    var displayPhone: String {
        return "Phone: \(user.phone)"
    }
    
    var valuePhone: String {
        return user.phone
    }
    
    var displayWebsite: String {
        return "Website: \(user.website)"
    }
    
    var valueWebsite: String {
        return "http://www." + user.website
    }
    
    var valueLatitude: Double {
        return user.address.geo.lat
    }
    
    var valueLongitude: Double {
        return user.address.geo.lng
    }
    
    var displayStreetSuite: String {
        return "\(user.address.street), \(user.address.suite)"
    }
    
    var displayCityZipcode: String {
        return "\(user.address.city), \(user.address.zipcode)"
    }
    
    var displayCompanyName: String {
        return "Company: \(user.company.name)"
    }
    
    var displayCompanyBs: String {
        return "\"" + user.company.bs + "\""
    }
    
    var displayCompanyCatchPhrase: String {
        return "\"" + user.company.catchPhrase + "\""
    }
}
