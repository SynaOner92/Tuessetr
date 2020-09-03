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
    @IBOutlet private weak var mapViewCompany: MKMapView!
    @IBOutlet private weak var labelStreetSuite: UILabel!
    @IBOutlet private weak var labelCityZipcode: UILabel!
    @IBOutlet private weak var labelCompanyName: UILabel!
    @IBOutlet private weak var labelCompanyCatchPhrase: UILabel!
    @IBOutlet private weak var labelCompanyBs: UILabel!
    @IBOutlet private weak var labelSendMail: UILabel! {
        didSet {
            let mailGesture = UITapGestureRecognizer(target: self, action: #selector(UserCell.mailGesture))
            labelSendMail.isUserInteractionEnabled = true
            labelSendMail.addGestureRecognizer(mailGesture)
        }
    }
    @IBOutlet private weak var labelCallPhone: UILabel! {
        didSet {
            let phoneGesture = UITapGestureRecognizer(target: self, action: #selector(UserCell.phoneGesture))
            labelCallPhone.isUserInteractionEnabled = true
            labelCallPhone.addGestureRecognizer(phoneGesture)
        }
    }
    @IBOutlet private weak var labelVisitWebsite: UILabel! {
        didSet {
            let websiteGesture = UITapGestureRecognizer(target: self, action: #selector(UserCell.websiteGesture))
            labelVisitWebsite.isUserInteractionEnabled = true
            labelVisitWebsite.addGestureRecognizer(websiteGesture)
        }
    }

    // MARK: Properties
    private var userViewModel: UserCellViewModel?

    // MARK: Public function
    func configure(withUserViewModel userViewModel: UserCellViewModel) {

        labelName.text = userViewModel.displayNameAndUsername
        labelMail.text = userViewModel.displayMail
        labelPhone.text = userViewModel.displayPhone
        labelWebsite.text = userViewModel.displayWebsite

        mapViewCompany.isUserInteractionEnabled = false
        let location = CLLocation(latitude: userViewModel.valueLatitude,
                                  longitude: userViewModel.valueLongitude)
        if let latitudinalMeters = CLLocationDistance(exactly: 50000),
            let longitudinalMeters = CLLocationDistance(exactly: 50000) {

            let region = MKCoordinateRegion(center: location.coordinate,
                                            latitudinalMeters: latitudinalMeters,
                                            longitudinalMeters: longitudinalMeters)
            mapViewCompany.setRegion(mapViewCompany.regionThatFits(region),
                                     animated: true)
        }
        labelStreetSuite.text = userViewModel.displayStreetSuite
        labelCityZipcode.text = userViewModel.displayCityZipcode

        labelCompanyName.text = userViewModel.displayCompanyName
        labelCompanyBs.text = userViewModel.displayCompanyBs
        labelCompanyCatchPhrase.text = userViewModel.displayCompanyCatchPhrase

        self.userViewModel = userViewModel

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
