//
//  CoreManagerService.swift
//  ExoUserMind
//
//  Created by Nicolas Moranny on 06/08/2020.
//  Copyright © 2020 Nicolas Moranny. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class CoreDataManagerService {
    
    static let shared = CoreDataManagerService()
    private init() {}

    private var appDelegate: AppDelegate = {
        return (UIApplication.shared.delegate as! AppDelegate)
    }()
    
    private var managedContext: NSManagedObjectContext = {
        let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
        return appDelegate.persistentContainer.viewContext
    }()
    
    func retrieveUsers() -> [User] {

        let usersRetrieved = NSFetchRequest<NSFetchRequestResult>(entityName: "FullUser")
        usersRetrieved.returnsObjectsAsFaults = false
        var users = [User]()
        do {
            let result = try managedContext.fetch(usersRetrieved)
            for user in result as! [FullUser] {
                
                users.append(
                    User(
                        id: Int(user.id),
                        name: user.name!,
                        username: user.username!,
                        email: user.email!,
                        phone: user.phone!,
                        website: user.website!,
                        address: Address(
                            street: user.street!,
                            suite: user.suite!,
                            city: user.city!,
                            zipcode: user.zipcode!,
                            geo: Coordinate(
                                lat: user.lat,
                                lng: user.lng)),
                        compagny: Company(
                            name: user.companyName!,
                            catchPhrase: user.companyCatchPhrase!,
                            bs: user.companyBs!)))
          }
        } catch {
            print("Failed")
        }
        
        return users.sorted {
            $0.id < $1.id
        }
    }
    
    func clearUsers() {
        let usersRetrieved = NSFetchRequest<NSFetchRequestResult>(entityName: "FullUser")
        usersRetrieved.returnsObjectsAsFaults = false
        do {
            let result = try managedContext.fetch(usersRetrieved)
            for user in result as! [FullUser] {
                managedContext.delete(user)
            }
        } catch {
            print("Failed")
        }
        
        do {
           try managedContext.save()
           print("Clear Users OK")
        } catch {
           print("Failed Users clearing")
        }
    }
    
    func clearAlbums() {
        let albumsRetrieved = NSFetchRequest<NSFetchRequestResult>(entityName: "FullAlbum")
        albumsRetrieved.returnsObjectsAsFaults = false
        do {
            let result = try managedContext.fetch(albumsRetrieved)
            for album in result as! [FullAlbum] {
                managedContext.delete(album)
            }
        } catch {
            print("Failed")
        }
        
        do {
           try managedContext.save()
           print("Clear Albums OK")
        } catch {
           print("Failed Album clearing")
        }
    }
    
    func retrieveAlbums() -> [Album] {
        
        let albumsRetrieved = NSFetchRequest<NSFetchRequestResult>(entityName: "FullAlbum")
        albumsRetrieved.returnsObjectsAsFaults = false
        var albums = [Album]()
        do {
            let result = try managedContext.fetch(albumsRetrieved)
            for album in result as! [FullAlbum] {
                albums.append(
                    Album(
                        userId: Int(album.userId),
                        id: Int(album.id),
                        title: album.title!))
          }
        } catch {
            print("Failed")
        }
        
        return albums.sorted {
            $0.id < $1.id
        }
    }
    
    func clearPhotosData(forAlbum albumID: Int) {
        
        let photosRetrieved = NSFetchRequest<NSFetchRequestResult>(entityName: "FullPhoto")
        photosRetrieved.predicate = NSPredicate(format: "albumId == %d", albumID)
        photosRetrieved.returnsObjectsAsFaults = false
        let result = try! managedContext.fetch(photosRetrieved) as! [FullPhoto]
        
        for image in result {
            image.urlData = nil
            image.thumbnailUrlData = nil
            image.downloadDate = nil
            
            do {
               try managedContext.save()
               print("Clear image data OK")
            } catch {
               print("Failed saving")
            }
        }
    }
    
    func saveUsers(users: [User]) {
        
        for user in users {
            if !(appDelegate.isEntityAttributeExist(id: user.id,
                                                    entityName: "FullUser")) {
                
                let newUser = FullUser(context: managedContext)
                newUser.id = Int32(user.id)
                newUser.email = user.email
                newUser.name = user.name
                newUser.phone = user.phone
                newUser.username = user.username
                newUser.website = user.website
                newUser.city = user.address.city
                newUser.street = user.address.street
                newUser.suite = user.address.suite
                newUser.zipcode = user.address.zipcode
                newUser.lat = user.address.geo.lat
                newUser.lng = user.address.geo.lng
                newUser.companyBs = user.company.bs
                newUser.companyCatchPhrase = user.company.catchPhrase
                newUser.companyName = user.company.name

            } else {
                print("User Already exists")
            }
        }

        do {
            try managedContext.save()
            print("Saving Users OK")
        } catch {
            print("Failed Users saving")
        }
    }
    
    func saveAlbums(albums: [Album]) {
        
        for album in albums {
            if !(appDelegate.isEntityAttributeExist(id: album.id,
                                                    entityName: "FullAlbum")) {
                
                let newAlbum = FullAlbum(context: managedContext)
                newAlbum.id = Int32(album.id)
                newAlbum.title = album.title
                newAlbum.userId = Int32(album.userId)

            } else {
                print("Album Already exists")
            }
        }

        do {
            try managedContext.save()
            print("Saving Albums OK")
        } catch {
            print("Failed Albums saving")
        }
    }
    
    func savePhotos(photos: [Photo]) {
        
        for photo in photos {
            if !(appDelegate.isEntityAttributeExist(id: photo.id,
                                                    entityName: "FullPhoto")) {
                
                let newPhoto = FullPhoto(context: managedContext)
                newPhoto.albumId = Int32(photo.albumId)
                newPhoto.id = Int32(photo.id)
                newPhoto.url = photo.url
                newPhoto.thumbnailUrl = photo.thumbnailUrl
                newPhoto.title = photo.title
                newPhoto.thumbnailUrlData = nil
                newPhoto.urlData = nil
                newPhoto.downloadDate = nil

            } else {
                print("Photo Already exists")
            }
        }

        do {
            try managedContext.save()
            print("Saving Photos OK")
        } catch {
            print("Failed Photos saving")
        }
    }
    
    func savePhotoData(data: Data,
                       photoId: Int,
                       imageType: Photo.ImageType) {
        
        let photosRetrieved = NSFetchRequest<NSFetchRequestResult>(entityName: "FullPhoto")
        photosRetrieved.predicate = NSPredicate(format: "id == %d", photoId)
        photosRetrieved.returnsObjectsAsFaults = false
        let res = try! managedContext.fetch(photosRetrieved).first as? FullPhoto
        
        if imageType == .Normal {
            res?.urlData = data
        } else {
            res?.thumbnailUrlData = data
        }

        res?.downloadDate = Date()
        
        do {
           try managedContext.save()
           print("Saving Photo Data OK")
        } catch {
           print("Failed saving")
        }
    }
    
    func retrievePhotos(albumId: Int,
                        completion: @escaping ([Photo]) -> Void) {

        let photosRetrieved = NSFetchRequest<NSFetchRequestResult>(entityName: "FullPhoto")
        photosRetrieved.returnsObjectsAsFaults = false
        var photos = [Photo]()
        do {
            let result = try managedContext.fetch(photosRetrieved)
            for data in result as! [FullPhoto] where data.albumId == albumId {
                
                if let date = data.downloadDate {
                    let calendar = Calendar.current
                    let dateNow = calendar.date(byAdding: .day, value: -1, to: Date())!
                    
                    if (dateNow > date) {
                        print("Photo needs to be redownload")
                        photos.append(
                            Photo(
                                albumId: Int(data.albumId),
                                id: Int(data.id),
                                title: data.title!,
                                url: data.url!,
                                thumbnailUrl: data.thumbnailUrl!,
                                urlData: nil,
                                thumbnailUrlData: nil,
                                date: nil
                            )
                        )
                    } else {
                        print("Photo doesn't need to be redownload")
                        photos.append(
                            Photo(
                                albumId: Int(data.albumId),
                                id: Int(data.id),
                                title: data.title!,
                                url: data.url!,
                                thumbnailUrl: data.thumbnailUrl!,
                                urlData: data.urlData,
                                thumbnailUrlData: data.thumbnailUrlData,
                                date: data.downloadDate
                            )
                        )
                    }
                } else {
                    print("Photo never been downloaded")
                    photos.append(
                        Photo(
                            albumId: Int(data.albumId),
                            id: Int(data.id),
                            title: data.title!,
                            url: data.url!,
                            thumbnailUrl: data.thumbnailUrl!,
                            urlData: nil,
                            thumbnailUrlData: nil,
                            date: nil
                        )
                    )
                }
            }
        } catch {
            print("Failed")
        }
        
        completion(photos.sorted {
            $0.id < $1.id
        })
    }
    
}
