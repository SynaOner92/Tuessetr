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
    
    static let shared = ApiService()
    private override init() {}
    
    private let decoder = NSCoder()
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
    
    func retrieveUsers(completion: @escaping (Result<[User]>) -> Void) {
        
        let url = URL(string: baseApiUrl)!
        let request = URLRequest(url: url)

        let task = session.dataTask(with: request) { (data, response, error) in

            NotificationCenter.default.post(name: .taskBeingExecuted,
                                            object: nil)
            if error != nil {
                // Handle HTTP request error
                completion(.failure(Exceptions.httpError))
            } else if let data = data {
                // Handle HTTP request response
                do {
                    let users = try JSONDecoder().decode([User].self,
                                                         from: data)

                    DispatchQueue.main.async {
                        CoreDataManagerService.shared.saveUsers(users: users)
                    }
                    completion(.success(users))
                } catch {
                    completion(.failure(Exceptions.badData))
                }
            } else {
                // Handle unexpected error
                completion(.failure(Exceptions.unexpectedError))
            }
        }

        task.resume()
    }
    
    func retrieveAlbums(forUserID id: Int,
                        completion: @escaping (Result<[Album]>) -> Void) {
        
        let url = URL(string: baseApiUrl + "/\(String(id))/albums")!
        let request = URLRequest(url: url)
        
        let task = session.dataTask(with: request) { (data, response, error) in

            NotificationCenter.default.post(name: .taskBeingExecuted,
                                            object: nil)
            if error != nil {
                // Handle HTTP request error
                completion(.failure(Exceptions.httpError))
            } else if let data = data {
                // Handle HTTP request response
                do {
                    let albums = try JSONDecoder().decode([Album].self,
                                                         from: data)
                    
                    DispatchQueue.main.async {
                        CoreDataManagerService.shared.saveAlbums(albums: albums)
                    }
                    
                    print("\(albums.count) albums for this user")
                    completion(.success(albums))
                    
                } catch {
                    completion(.failure(Exceptions.badData))
                }
            } else {
                // Handle unexpected error
                completion(.failure(Exceptions.unexpectedError))
            }
        }
        task.resume()
    }
    
    func retrievePhotos(forUserID userID: Int,
                        forAlbumID albumID: Int,
                        completion: @escaping (Result<[Photo]>) -> Void) {
        
        let url = URL(string: baseApiUrl + "/\(String(userID))/photos?albumId=\(albumID)")!
        let request = URLRequest(url: url)
        
        let task = session.dataTask(with: request) { (data, response, error) in

            NotificationCenter.default.post(name: .taskBeingExecuted,
                                            object: nil)
            if error != nil {
                // Handle HTTP request error
                completion(.failure(Exceptions.httpError))
            } else if let data = data {
                // Handle HTTP request response
                do {
                    let photos = try JSONDecoder().decode([Photo].self,
                                                         from: data)
                    
                    DispatchQueue.main.async {
                        CoreDataManagerService.shared.savePhotos(photos: photos)
                    }
                    
                    print("\(photos.count) photos in this album")
                    completion(.success(photos))
                    
                } catch {
                    completion(.failure(Exceptions.badData))
                }
            } else {
                // Handle unexpected error
                completion(.failure(Exceptions.unexpectedError))
            }
        }
        task.resume()
    }
    
    func loadImage(downloadUrl: String,
                   photoId: Int,
                   imageType: Photo.ImageType,
                   completion: @escaping (Result<Data>) -> Void) {
        
        let url = URL(string: downloadUrl)!
        let request = URLRequest(url: url)
        
        let task = session.dataTask(with: request) { (data, response, error) in

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
