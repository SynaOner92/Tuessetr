//
//  Photo.swift
//  ExoUserMind
//
//  Created by Nicolas Moranny on 06/08/2020.
//  Copyright © 2020 Nicolas Moranny. All rights reserved.
//

import Foundation

struct Photo: Codable, MandatoryID {

    let id: Int
    let albumId: Int
    let title: String
    let url: String
    let thumbnailUrl: String

    var urlData: Data?
    var thumbnailUrlData: Data?
    var date: Date?

    init(albumId: Int,
         id: Int,
         title: String,
         url: String,
         thumbnailUrl: String,
         urlData: Data?,
         thumbnailUrlData: Data?,
         date: Date?) {

        self.albumId = albumId
        self.id = id
        self.url = url
        self.title = title
        self.thumbnailUrl = thumbnailUrl
        self.urlData = urlData
        self.thumbnailUrlData = thumbnailUrlData
        self.date = date
    }

    func loadImage(for imageType: ImageType,
                   completion: @escaping (Result<Data>) -> Void) {

        if imageIsLoaded(imageType: imageType) {

            switch imageType {

            case .normal:

                if let urlData = urlData {

                    completion(.success(urlData))
                }

            case .thumb:

                if let thumbnailUrlData = thumbnailUrlData {

                    completion(.success(thumbnailUrlData))
                }
            }

            completion(.failure(Exceptions.unexpectedError))

        } else {

            let image = imageType == .normal ? url : thumbnailUrl

            ApiService.shared.loadImage(downloadUrl: image,
                                        photoId: id,
                                        imageType: imageType) { result in

                switch result {

                case .success(let datas):

                    completion(.success(datas))

                case .failure:

                    completion(.failure(Exceptions.unexpectedError))
                }
            }
        }
    }

    private func imageIsLoaded(imageType: ImageType) -> Bool {

        switch imageType {

        case .normal:

            return urlData != nil
        case .thumb:

            return thumbnailUrlData != nil
        }
    }

    enum ImageType {

        case normal
        case thumb
    }
}
