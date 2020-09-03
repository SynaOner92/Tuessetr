//
//  BaseViewModel.swift
//  ExoUserMind
//
//  Created by Nicolas Moranny on 19/08/2020.
//  Copyright © 2020 Nicolas Moranny. All rights reserved.
//

import Foundation

class BaseViewModel<U: GenericConstructor> {

    var data = [U.T]()

    weak var delegate: BaseViewModelProtocol?

    init() {

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onDidReceiveNotification(_:)),
                                               name: .waitingForConnexion,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onDidReceiveNotification(_:)),
                                               name: .taskBeingExecuted,
                                               object: nil)
    }

    deinit {

        NotificationCenter.default.removeObserver(self)
    }

    func clearDatas(_ coreDataObject: U.Type) {

        CoreDataManagerService.shared.clear(U.self)
    }

    func fetchDatas(with userID: Int? = nil,
                    for albumID: Int? = nil,
                    fromRefresh: Bool = false,
                    _ coreDataObject: U.Type) {

        let datasFromCache = CoreDataManagerService.shared.retrieve(objects: U.T.self,
                                                                    for: albumID,
                                                                    coreDataObject: U.self)

        if datasFromCache.count > 0 {

            log("\(U.T.self) load from cache")
            self.data = datasFromCache
        } else {

            log("\(U.T.self) load from webservice")
            ApiService.shared.retrieveObjects(with: userID,
                                              for: albumID,
                                              coreDataObject) { [weak self] result in

                switch result {

                case .success(let newDatas):
                    DispatchQueue.main.async {
                        self?.data = newDatas
                        self?.delegate?.dataUpdated()
                    }

                case .failure(let error):
                    if let exception = error as? Exceptions {

                        switch exception {
                        case .badData:
                            self?.delegate?.setLabelInformation(type: .badDataFormat)
                        case .httpError:
                            self?.delegate?.setLabelInformation(type: .httpException)
                        default:
                            self?.delegate?.setLabelInformation(type: .unexpectedError)
                        }
                    } else {

                        self?.delegate?.setLabelInformation(type: .unexpectedError)
                    }
                }

            }
        }
    }

    @objc func onDidReceiveNotification(_ notification: Notification) {

        switch notification.name {

        case .taskBeingExecuted:

            delegate?.removeInformationView()
        case .waitingForConnexion:

            delegate?.displayInformationView()
        default:

            log("Notification has an unknown name")
        }

    }
}
