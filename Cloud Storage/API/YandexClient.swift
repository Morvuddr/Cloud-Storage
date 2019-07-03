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
    
    func downloadMetaInfo(at path: String, for parent: Resource?, downloadSuccess: @escaping ()->(), downloadFailure: ((String)->())? = nil){
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
                    if parent == nil {
                        let name = json["name"].stringValue
                        let path = json["path"].stringValue
                        let type = json["type"].stringValue
                        let mimeType = json["mime_type"].stringValue
                        let size = json["size"].intValue
                        let created = json["created"].stringValue
                        let modified = json["modified"].stringValue
                        let resource = Resource(name: name, path: path, type: type, mimeType: mimeType, size: size, created: created, modified: modified, parent: parent)
                        ResourceFunctions.shared.createResource(resource: resource, parent: nil)
                        parent = resource
                    }
                    
                    let childrenCount = json["_embedded"]["total"].intValue
                    if childrenCount != 0 {
                        let children  = json["_embedded"]["items"]
                        for (_,subJson):(String, JSON) in children {
                            let name = subJson["name"].stringValue
                            let path = subJson["path"].stringValue
                            let type = subJson["type"].stringValue
                            let mimeType = subJson["mime_Type"].stringValue
                            let size = subJson["size"].intValue
                            let created = subJson["created"].stringValue
                            let modified = subJson["modified"].stringValue
                            
                            let subResource = Resource(name: name, path: path, type: type, mimeType: mimeType, size: size, created: created, modified: modified, parent: parent)
                            ResourceFunctions.shared.createResource(resource: subResource, parent: parent)
                        }
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
    
}
