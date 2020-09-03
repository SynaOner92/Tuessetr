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
    
    private var managedContext: NSManagedObjectContext = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }()

    func savePhotoData(data: Data,
                       photoId: Int,
                       imageType: Photo.ImageType) {

        let photosRetrieved = NSFetchRequest<NSFetchRequestResult>(entityName: "FullPhoto")
        photosRetrieved.predicate = NSPredicate(format: "id == %d", photoId)
        photosRetrieved.returnsObjectsAsFaults = false

        do {
            let res = try managedContext.fetch(photosRetrieved).first as? FullPhoto

            if imageType == .normal {
                res?.urlData = data
            } else {
                res?.thumbnailUrlData = data
            }

            res?.downloadDate = Date()

           try managedContext.save()
           log("Saving photo data ok")
        } catch {
            log("Saving photo data ko")
        }
    }

    func retrieve<U: GenericConstructor>(objects: U.T.Type,
                                         for albumID: Int? = nil,
                                         coreDataObject: U.Type) -> [U.T] {

        let retrievedObjects = NSFetchRequest<NSFetchRequestResult>(entityName: U.entityName)
        retrievedObjects.returnsObjectsAsFaults = false

        var objectsRetrieved = [U.T]()

        do {

            let result = try managedContext.fetch(retrievedObjects) as! [U]

            switch type(of: result) {

            // Handling FullPhoto type
            case is [FullPhoto].Type:

                if let fullPhotos = result as? [FullPhoto] {

                    for fullPhoto in fullPhotos where Int(fullPhoto.albumId) == albumID {

                        objectsRetrieved.append(fullPhoto.convertToModel() as! U.T)

                    }
                }

            default:

                for object in result {
                    objectsRetrieved.append(object.convertToModel())
                }
            }
        } catch {
            log("There is an unexpected error")
        }

        return objectsRetrieved.sorted { $0.id < $1.id }
    }

    func save<U: GenericConstructor>(objects: [U.T], _ coreDataObject: U.Type) {

        for object in objects {

            if !AppDelegate.shared.isEntityAttributeExist(id: object.id,
                                                          entityName: U.entityName) {
                let newCoreDataObject = U(context: managedContext)
                newCoreDataObject.genericConstructor(constructorObject: object)

            } else {
                log("\(U.entityName) already exists")
            }
        }
    }

    func clear<U: GenericConstructor>(_ coreDataObject: U.Type) {

        let retrievedObjects = NSFetchRequest<NSFetchRequestResult>(entityName: U.entityName)
        retrievedObjects.returnsObjectsAsFaults = false

        do {

            let result = try managedContext.fetch(retrievedObjects) as! [U]

            for object in result {
                managedContext.delete(object)
            }

            try managedContext.save()

            log("\(U.entityName) cleared")

        } catch {

            log("\(U.entityName) clear fails")

        }

    }

    func clearPhotosData(forAlbum albumID: Int) {

        let photosRetrieved = NSFetchRequest<NSFetchRequestResult>(entityName: "FullPhoto")
        photosRetrieved.predicate = NSPredicate(format: "albumId == %d", albumID)
        photosRetrieved.returnsObjectsAsFaults = false

        do {

            let result = try managedContext.fetch(photosRetrieved) as! [FullPhoto]

            for image in result {

                image.urlData = nil
                image.thumbnailUrlData = nil
                image.downloadDate = nil

               try managedContext.save()
               log("Clear image data OK")

            }
        } catch {

            log("Failed saving")
        }
    }

}
