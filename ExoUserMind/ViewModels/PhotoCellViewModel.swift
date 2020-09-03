//
//  PhotoCellViewModel.swift
//  ExoUserMind
//
//  Created by Nicolas Moranny on 06/08/2020.
//  Copyright © 2020 Nicolas Moranny. All rights reserved.
//

import Foundation
import UIKit

public class PhotoCellViewModel {

    private let photo: Photo

    init(photo: Photo) {
        self.photo = photo
    }

    var valueTitle: String {
        return photo.title
    }

    func retrieveImage(imageType: Photo.ImageType,
                       completion: @escaping (UIImage?) -> Void) {

        photo.loadImage(for: imageType) { result in

            switch result {

            case .success(let datas):
                completion(UIImage(data: datas))
            case .failure:
                completion(nil)
            }
        }
    }
}
