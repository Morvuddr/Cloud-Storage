//
//  YandexClient.swift
//  Cloud Storage
//
//  Created by Игорь Бопп on 01/07/2019.
//  Copyright © 2019 Igor. All rights reserved.
//

import Foundation
import OAuthSwift
import Alamofire
import SwiftyJSON

class YandexClient {
    
    static let shared = YandexClient()
    
    let oauthswift = OAuth2Swift(
        consumerKey:    "aa970f1b0a264f0da2b4a6087d2c1b1d",
        consumerSecret: "",
        authorizeUrl:   "https://oauth.yandex.ru/authorize?",
        responseType:   "token"
    )
    
    weak var delegate: YandexLoginDelegate?
    
    var loginSuccess: ((Bool)->())?
    var loginFailure: ((OAuthSwiftError)->())?
    
    func doLogin(_ userName: String, _ vc: UIViewController, success: @escaping (Bool)->(), failure:  @escaping (OAuthSwiftError)->()){
        loginSuccess = success
        loginFailure = failure
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.splashDelay = true
        
        oauthswift.allowMissingStateCheck = true
        oauthswift.authorizeURLHandler = SafariURLHandler(viewController: vc, oauthSwift: oauthswift)
        
        guard let cbURL = URL(string: "cloudstorage://token") else { return }
        
        oauthswift.authorize(withCallbackURL: cbURL, scope: "", state: "", parameters: ["login_hint":userName, "force_confirm":true], success: {
            (credential, response, parameters) in
            User.currentUser = User(userName: userName, accessToken: credential.oauthToken)
            self.loginSuccess?(false)
        }, failure: { (error) in
            self.loginFailure?(error)
        })
        
    }
    
    func logout(){
        User.currentUser = nil
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: User.userDidLogoutNotification), object: nil)
    }
    
    func downloadMetaInfo(at path: String, for parent: Resource?, isCreating: Bool = false, isMoving: Bool = false, downloadSuccess: @escaping ()->(), downloadFailure: ((String)->())? = nil){
        let URL = "https://cloud-api.yandex.net/v1/disk/resources"
        request(URL , method: .get,
                parameters: ["path" : path],
                headers: ["Authorization" : User.currentUser!.accessToken!])
            .validate()
            .responseJSON { (response) in
                switch response.result {
                case .success(let value):
                    
                    let json = JSON(value)
                    var parent = parent
                    let name = json["name"].stringValue
                    let path = json["path"].stringValue
                    let type = json["type"].stringValue
                    let mimeType = json["mime_type"].stringValue
                    let size = json["size"].intValue
                    let created = json["created"].stringValue
                    let modified = json["modified"].stringValue
                    let resource = Resource(name: name, path: path, type: type, mimeType: mimeType, size: size, created: created, modified: modified, parent: parent)
                    if !isCreating {
                        if parent == nil || isMoving {
                            ResourceFunctions.shared.createResource(resource: resource, parent: parent)
                            parent = resource
                        }
                        
                        let childrenCount = json["_embedded"]["total"].intValue
                        if childrenCount != 0 {
                            let children  = json["_embedded"]["items"]
                            for (_,subJson):(String, JSON) in children {
                                let name = subJson["name"].stringValue
                                let path = subJson["path"].stringValue
                                let type = subJson["type"].stringValue
                                let mimeType = subJson["mime_type"].stringValue
                                let size = subJson["size"].intValue
                                let created = subJson["created"].stringValue
                                let modified = subJson["modified"].stringValue
                                
                                let subResource = Resource(name: name, path: path, type: type, mimeType: mimeType, size: size, created: created, modified: modified, parent: parent)
                                ResourceFunctions.shared.createResource(resource: subResource, parent: parent)
                            }
                        }
                    } else {
                        ResourceFunctions.shared.createResource(resource: resource, parent: parent)
                    }
                    
                    downloadSuccess()
                    
                case .failure(let error):
                    print(error)
                    if let downloadFailure = downloadFailure {
                        if error.localizedDescription.contains("401") {
                            downloadFailure("401")
                        } else {
                            downloadFailure("other")
                        }
                        
                    }
                }
        }
    }
    
    func createResource(currentResource: Resource, newResourceName: String){
        let URL = "https://cloud-api.yandex.net/v1/disk/resources"
        var newResourcePath = ""
        if (currentResource.name == "disk"){
            newResourcePath = "\(currentResource.path)\(newResourceName)"
        } else {
            newResourcePath = "\(currentResource.path)/\(newResourceName)"
        }
        request(URL , method: .put,
                parameters: ["path" : newResourcePath], encoding: URLEncoding.queryString,
                headers: ["Authorization" : User.currentUser!.accessToken!])
            .validate()
            .responseJSON { (response) in
                switch response.result {
                case .success(_):
                    self.downloadMetaInfo(at: newResourcePath, for: currentResource, isCreating: true, downloadSuccess: {})
                case .failure(let error):
                    print(error.localizedDescription)
                }
        }
    }
    
    
    func downloadResource(path: String, fileName: String, completion: @escaping (URL)->()){
        let URL = "https://cloud-api.yandex.net/v1/disk/resources/download"
        request(URL , method: .get,
                parameters: ["path" : path], encoding: URLEncoding.queryString,
                headers: ["Authorization" : User.currentUser!.accessToken!])
            .validate()
            .responseJSON { (response) in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    let urlToDownload = json["href"].stringValue
                    self.beginDownload(url: urlToDownload, fileName: fileName){ (fileURL) in
                        completion(fileURL)
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
        }
    }
    
    func beginDownload(url: String, fileName: String, completion: @escaping (URL)->()){
        request(url , method: .get,
                headers: ["Authorization" : User.currentUser!.accessToken!])
            .validate()
            .downloadProgress { progress in
                //print("totalUnitCount:\n", progress.totalUnitCount)
                //print("completedUnitCount:\n", progress.completedUnitCount)
                //print("fractionCompleted:\n", progress.fractionCompleted)
                //print("localizedDescription:\n", progress.localizedDescription!)
                //print("---------------------------------------------")
            }
            .response { (response) in
                if let data = response.data {
                    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                    let fileURL = documentsURL.appendingPathComponent(fileName)
                    do {
                        try data.write(to: fileURL)
                    } catch {
                        print("Something went wrong!")
                    }
                    completion(fileURL)
                }
        }
    }
    
    func moveResource(selectedResource: Resource, currentResource: Resource, completion: @escaping ()->()){
        let url = "https://cloud-api.yandex.net/v1/disk/resources/move"
        let from = selectedResource.path
        var path = ""
        if currentResource.name == "disk"{
            path = currentResource.path + selectedResource.name
        } else {
            path = currentResource.path + "/" + selectedResource.name
        }
        
        request(url, method: .post, parameters: ["from": from, "path": path ], encoding: URLEncoding.queryString, headers: ["Authorization" : User.currentUser!.accessToken!])
            .validate()
            .responseJSON { (response) in
                if response.response?.statusCode == 201 {
                    
                    ResourceFunctions.shared.deleteResource(selectedResource: selectedResource, currentResource: currentResource)
                    self.downloadMetaInfo(at: path, for: currentResource, isCreating: false, isMoving: true, downloadSuccess: {
                        completion()
                    })
                    
                } else if response.response?.statusCode == 202 {
                    let json = JSON(response.value!)
                    let url = json["href"].stringValue
                    self.checking(url: url, selectedResource: selectedResource, currentResource: currentResource) {
                        completion()
                    }
                } else {
                    print("Произошла ошибка при запросе на перемещение")
                }
            }
    }
    func checking(url: String, selectedResource: Resource, currentResource: Resource, completion: @escaping ()->()){
        
        var path = ""
        if currentResource.name == "disk"{
            path = currentResource.path + selectedResource.name
        } else {
            path = currentResource.path + "/" + selectedResource.name
        }
        
        request(url, method: .get, headers: ["Authorization" : User.currentUser!.accessToken!])
            .validate()
            .responseJSON { (response) in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    let status = json["status"].stringValue
                    switch status {
                    case "success":
                        ResourceFunctions.shared.deleteResource(selectedResource: selectedResource, currentResource: currentResource)
                        self.downloadMetaInfo(at: path, for: currentResource, isCreating: false, isMoving: true, downloadSuccess: {
                            completion()
                        })
                    case "in-progress":
                        delay(1.0, closure: {
                            self.checking(url: url, selectedResource: selectedResource, currentResource: currentResource) {
                                completion()
                            }
                        })
                    default:
                        print("Произошла ошибка при проверке перемещения")
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
        }
    }
}
