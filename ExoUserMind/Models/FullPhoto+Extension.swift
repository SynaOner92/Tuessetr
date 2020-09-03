//
//  FullPhoto+Extension.swift
//  ExoUserMind
//
//  Created by Nicolas Moranny on 19/08/2020.
//  Copyright © 2020 Nicolas Moranny. All rights reserved.
//

import Foundation

extension FullPhoto: GenericConstructor {
    
    typealias T = Photo

    func genericConstructor(constructorObject: Photo) {

        self.thumbnailUrl = constructorObject.thumbnailUrl
        self.albumId = Int32(constructorObject.albumId)
        self.id = Int32(constructorObject.id)
        self.title = constructorObject.title
        self.url = constructorObject.url
        self.thumbnailUrlData = nil
        self.downloadDate = nil
        self.urlData = nil
    }

    func convertToModel() -> T {

        let calendar = Calendar.current

        if let downloadDate = self.downloadDate,
            let dateNow = calendar.date(byAdding: .day, value: -1, to: Date()),
            dateNow > downloadDate {

            log("Photo \(self.id) download is too old")
            return T(albumId: Int(self.albumId),
                     id: Int(self.id),
                     title: self.title!,
                     url: self.url!,
                     thumbnailUrl: self.thumbnailUrl!,
                     urlData: nil,
                     thumbnailUrlData: nil,
                     date: nil)

        } else {

            log("Photo \(self.id) download is valid or never been done")
            return T(albumId: Int(self.albumId),
                     id: Int(self.id),
                     title: self.title!,
                     url: self.url!,
                     thumbnailUrl: self.thumbnailUrl!,
                     urlData: self.urlData,
                     thumbnailUrlData: self.thumbnailUrlData,
                     date: self.downloadDate)
        }

    }
}
