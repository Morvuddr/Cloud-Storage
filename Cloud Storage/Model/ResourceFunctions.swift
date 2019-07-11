//
//  ResourceFunctions.swift
//  Cloud Storage
//
//  Created by Игорь Бопп on 03/07/2019.
//  Copyright © 2019 Igor. All rights reserved.
//

import Foundation
import RealmSwift

class ResourceFunctions {
    
    private init(){}
    static let shared = ResourceFunctions()
    
    lazy var realm: Realm = {
        return try! Realm()
    }()
    
    var currentSchemaVersion: UInt64 = 1
    
    func createResource(resource: Resource, parent: Resource?){
        
        do {
            
            try realm.write{
                realm.add(resource)
                //print("Добавлен ресурс \(resource.name)")
                if let parent = parent {
                    //print("Ресурсу \(parent.name) добавлен ресурс \(resource.name)")
                    parent.children.append(resource)
                }
            }
            
        } catch {
            print(error)
        }
        
    }
    
    func deleteAll(){
        do {
            try realm.write{
                //print("Удаление всех объектов")
                realm.deleteAll()
            }
        } catch {
            print(error)
        }
    }
    
    func deleteChildren(for resource: Resource){
        if resource.type == "dir"{
            if resource.children.count > 0 {
                for child in resource.children{
                    deleteChildren(for: child)
                }
            }
            do {
                try realm.write {
                    realm.delete(resource.children)
                    //print("Удаление завершено для \(resource.name)")
                }
            } catch {
                print(error)
            }
        }
    }
    
    func deleteResource(selectedResource: Resource, currentResource: Resource){
        deleteChildren(for: selectedResource)
        do {
            try realm.write {
                realm.delete(selectedResource)
            }
        } catch {
            print(error)
        }
    }
    
}
