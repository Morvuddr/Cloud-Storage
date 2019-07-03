//
//  File.swift
//  Cloud Storage
//
//  Created by Игорь Бопп on 03/07/2019.
//  Copyright © 2019 Igor. All rights reserved.
//

import Foundation
import Alamofire

class Connectivity {
    
    static var connectionDidChanged = "connectionDidChanged"
    
    
    static var isConnectedToInternet : Bool {
        return NetworkReachabilityManager()!.isReachable
    }
    
    static func configureConnectionListener() -> NetworkReachabilityManager {
        let manager = NetworkReachabilityManager()
        manager?.listener = { status in
            switch status {
            case .notReachable:
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Connectivity.connectionDidChanged), object: nil)
            case .unknown:
                print("")
            default:
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Connectivity.connectionDidChanged), object: nil)
            }
        }
        return manager!
    }
    
}
