//
//  Photo.swift
//  ExoUserMind
//
//  Created by Nicolas Moranny on 06/08/2020.
//  Copyright © 2020 Nicolas Moranny. All rights reserved.
//

import Foundation

class Photo : Codable {
    
    let albumId: Int
    let id: Int
    let title: String
    let url: String
    let thumbnailUrl: String
    
    var urlData: Data? = nil
    var thumbnailUrlData: Data? = nil
    var date: Date? = nil
    
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
            completion(imageType == .Normal ? .success(urlData!) : .success(thumbnailUrlData!))
        } else {
            let image = imageType == .Normal ? url : thumbnailUrl
          
            ApiService.shared.loadImage(downloadUrl: image,
                                        photoId: id,
                                        imageType: imageType) { result in
                switch result {
                case .success(let datas):
                    if imageType == .Normal {
                        self.urlData = datas
                    } else {
                        self.thumbnailUrlData = datas
                    }
                    completion(.success(datas))
                case .failure( _):
                    completion(.failure(Exceptions.unexpectedError))
                }
            }
        }
    }
    
    private func imageIsLoaded(imageType: ImageType) -> Bool {
        
        switch imageType {
        case .Normal:
            return urlData != nil
        case .Thumb:
            return thumbnailUrlData != nil
        }
    }
    
    enum ImageType {
        case Normal
        case Thumb
    }
}
