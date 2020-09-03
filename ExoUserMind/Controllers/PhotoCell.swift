//
//  PhotoCell.swift
//  ExoUserMind
//
//  Created by Nicolas Moranny on 06/08/2020.
//  Copyright © 2020 Nicolas Moranny. All rights reserved.
//

import Foundation
import UIKit

class PhotoCell: UICollectionViewCell {

    // MARK: IBOutlet
    @IBOutlet private weak var labelTitle: UILabel!
    @IBOutlet private weak var imageViewPhoto: UIImageView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!

    // MARK: Constructor
    override func awakeFromNib() {

        super.awakeFromNib()

        self.contentView.layer.cornerRadius = 2.0
        self.contentView.layer.borderWidth = 1.0
        self.contentView.layer.borderColor = UIColor.clear.cgColor
        self.contentView.layer.masksToBounds = true

        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        self.layer.shadowRadius = 2.0
        self.layer.shadowOpacity = 0.5
        self.layer.masksToBounds = false
    }

    override func prepareForReuse() {

        super.prepareForReuse()

        imageViewPhoto.image = nil
        activityIndicator.startAnimating()
    }

    // MARK: Public function
    func configure(with photoViewModel: PhotoCellViewModel) {

        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds,
                                             cornerRadius: self.contentView.layer.cornerRadius).cgPath

        labelTitle.text = photoViewModel.valueTitle
        photoViewModel.retrieveImage(imageType: .normal) { [weak self] uiImage in

            guard let strongSelf = self else { return }

            DispatchQueue.main.async {
                strongSelf.activityIndicator.stopAnimating()
                strongSelf.imageViewPhoto.image = uiImage
            }
        }
    }

}
