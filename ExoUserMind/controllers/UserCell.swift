//
//  UserCell.swift
//  ExoUserMind
//
//  Created by Nicolas Moranny on 06/08/2020.
//  Copyright © 2020 Nicolas Moranny. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class UserCell: UITableViewCell {
    
    // MARK: IBOutlet
    @IBOutlet private weak var labelName: UILabel!
    @IBOutlet private weak var labelMail: UILabel!
    @IBOutlet private weak var labelPhone: UILabel!
    @IBOutlet private weak var labelWebsite: UILabel!
    @IBOutlet private weak var labelSendMail: UILabel!
    @IBOutlet private weak var labelCallPhone: UILabel!
    @IBOutlet private weak var labelVisitWebsite: UILabel!
    @IBOutlet private weak var mapViewCompany: MKMapView!
    @IBOutlet private weak var labelStreetSuite: UILabel!
    @IBOutlet private weak var labelCityZipcode: UILabel!
    @IBOutlet private weak var labelCompanyName: UILabel!
    @IBOutlet private weak var labelCompanyCatchPhrase: UILabel!
    @IBOutlet private weak var labelCompanyBs: UILabel!
    
    // MARK: Properties
    private var userViewModel: UserCellViewModel?
    
    // MARK: Public function
    func configure(withUserViewModel _userViewModel: UserCellViewModel) {
        
        userViewModel = _userViewModel
        
        labelName.text = userViewModel!.displayNameAndUsername
        labelMail.text = userViewModel!.displayMail
        labelPhone.text = userViewModel!.displayPhone
        labelWebsite.text = userViewModel!.displayWebsite
        
        mapViewCompany.isUserInteractionEnabled = false
        let location = CLLocation(latitude: userViewModel!.valueLatitude,
                                  longitude: userViewModel!.valueLongitude)
        let region = MKCoordinateRegion( center: location.coordinate,
                                         latitudinalMeters: CLLocationDistance(exactly: 50000)!,
                                         longitudinalMeters: CLLocationDistance(exactly: 50000)!)
        mapViewCompany.setRegion(mapViewCompany.regionThatFits(region),
                                 animated: true)
        labelStreetSuite.text = userViewModel!.displayStreetSuite
        labelCityZipcode.text = userViewModel!.displayCityZipcode
        
        labelCompanyName.text = userViewModel!.displayCompanyName
        labelCompanyBs.text = userViewModel!.displayCompanyBs
        labelCompanyCatchPhrase.text = userViewModel!.displayCompanyCatchPhrase
        
        let mailGesture = UITapGestureRecognizer(target: self, action: #selector(UserCell.mailGesture))
        labelSendMail.isUserInteractionEnabled = true
        labelSendMail.addGestureRecognizer(mailGesture)
        
        let phoneGesture = UITapGestureRecognizer(target: self, action: #selector(UserCell.phoneGesture))
        labelCallPhone.isUserInteractionEnabled = true
        labelCallPhone.addGestureRecognizer(phoneGesture)
        
        let websiteGesture = UITapGestureRecognizer(target: self, action: #selector(UserCell.websiteGesture))
        labelVisitWebsite.isUserInteractionEnabled = true
        labelVisitWebsite.addGestureRecognizer(websiteGesture)
    }
    
    // MARK: objc function
    @objc
    func mailGesture(sender: UITapGestureRecognizer) {

        if let mail = userViewModel?.valueMail,
            let url = URL(string: "mailto:\(mail)") {
          if #available(iOS 10.0, *) {
            UIApplication.shared.open(url)
          } else {
            UIApplication.shared.openURL(url)
          }
        }
    }
    
    @objc
    func phoneGesture(sender: UITapGestureRecognizer) {
        
        if let number = userViewModel?.valuePhone,
            let url = URL(string: "tel://" + number) {
            UIApplication.shared.open(url)
        }
    }
    
    @objc
    func websiteGesture(sender: UITapGestureRecognizer) {
      
        if let website = userViewModel?.valueWebsite,
            let url = URL(string: website) {
            UIApplication.shared.open(url)
        }
    }
    
    
}
