//
//  ApiService.swift
//  ExoUserMind
//
//  Created by Nicolas Moranny on 06/08/2020.
//  Copyright © 2020 Nicolas Moranny. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class ApiService: NSObject {

    // MARK: Init
    private override init() {}

    // MARK: Static properties
    static let shared = ApiService()

    // MARK: Private properties
    private let baseApiUrl = "https://jsonplaceholder.typicode.com/users"
    private lazy var session: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        configuration.waitsForConnectivity = true
        configuration.timeoutIntervalForResource = 15
        return URLSession(configuration: configuration,
                          delegate: self,
                          delegateQueue: .main)
    }()

    // GENERIC
    func retrieveObjects<U: GenericConstructor>(with userID: Int? = nil,
                                                for albumID: Int? = nil,
                                                _ coreDataObject: U.Type,
                                                completion: @escaping (Result<[U.T]>) -> Void) {

        let stringURL: String

        if let userID = userID,
            let albumID = albumID {

            stringURL = baseApiUrl + "/\(String(userID))/photos?albumId=\(albumID)"

        } else if let userID = userID {

            stringURL = baseApiUrl + "/\(String(userID))/albums"

        } else {

            stringURL = baseApiUrl
        }

        guard let url = URL(string: stringURL)
            else { return }

        let request = URLRequest(url: url)

        session.dataTask(with: request) { (data, _, error) in

            NotificationCenter.default.post(name: .taskBeingExecuted,
                                            object: nil)

            if let _ = error {

                // Handle HTTP request error
                completion(.failure(Exceptions.httpError))

            } else if let data = data {

                // Handle HTTP request response
                do {

                    let objects = try JSONDecoder().decode([U.T].self,
                                                           from: data)
                    DispatchQueue.main.async {
                        CoreDataManagerService.shared.save(objects: objects,
                                                           coreDataObject)
                        completion(.success(objects))
                    }

                } catch {

                    completion(.failure(Exceptions.badData))

                }
            } else {

                // Handle unexpected error
                completion(.failure(Exceptions.unexpectedError))

            }
        }.resume()
    }

    func loadImage(downloadUrl: String,
                   photoId: Int,
                   imageType: Photo.ImageType,
                   completion: @escaping (Result<Data>) -> Void) {

        guard let url = URL(string: downloadUrl)
            else { return }

        let request = URLRequest(url: url)

        let task = session.dataTask(with: request) { (data, _, error) in

            NotificationCenter.default.post(name: .taskBeingExecuted,
                                            object: nil)
            if error != nil {

                // Handle HTTP request error
                completion(.failure(Exceptions.httpError))

            } else if let data = data {

                // Handle HTTP request response
                DispatchQueue.main.async {
                    CoreDataManagerService.shared.savePhotoData(data: data,
                                                                photoId: photoId,
                                                                imageType: imageType)
                }
                completion(.success(data))

            } else {

                // Handle unexpected error
                completion(.failure(Exceptions.unexpectedError))

            }
        }

        task.resume()
    }
}

extension ApiService: URLSessionTaskDelegate {

    func urlSession(_ session: URLSession,
                    taskIsWaitingForConnectivity task: URLSessionTask) {

        NotificationCenter.default.post(name: .waitingForConnexion,
                                        object: nil)
    }

}
