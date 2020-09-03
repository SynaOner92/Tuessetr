//
//  NoConnexionView.swift
//  ExoUserMind
//
//  Created by Nicolas Moranny on 11/08/2020.
//  Copyright © 2020 Nicolas Moranny. All rights reserved.
//

import Foundation
import UIKit

public class InformationView: UIView {

    @IBOutlet private weak var labelInformation: UILabel!

    public override init(frame: CGRect) {

        super.init(frame: frame)

        commonInit()
    }
    public required init?(coder: NSCoder) {

        super.init(coder: coder)

        commonInit()
    }

    private func commonInit() {

        let bundle = Bundle.init(for: InformationView.self)
        if let viewsToAdd = bundle.loadNibNamed("InformationView", owner: self, options: nil),
            let contentView = viewsToAdd.first as? UIView {

            addSubview(contentView)
            contentView.frame = self.bounds
            contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        }
    }

    func setLabelInformation(type: LabelInformationType, from: String) {

        labelInformation.text = type.rawValue
    }

    enum LabelInformationType: String {

        case noInternet = "There is no internet connexion"
        case unexpectedError = "There is an unexpected error"
        case httpException = "There is an http exception"
        case badDataFormat = "Data recieve are misformed"
    }
}
