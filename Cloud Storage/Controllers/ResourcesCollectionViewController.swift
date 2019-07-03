//
//  ResourcesCollectionViewController.swift
//  Cloud Storage
//
//  Created by Игорь Бопп on 01/07/2019.
//  Copyright © 2019 Igor. All rights reserved.
//

import UIKit
import RealmSwift
import Alamofire

class ResourcesCollectionViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet var navBar: UINavigationItem!
    @IBOutlet weak var errorViewTopConstraint: NSLayoutConstraint!
    
    var currentResource: Resource?
    var notificationToken: NotificationToken?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        navigationController?.navigationBar.barTintColor = UIColor.white
        
        configureConnectionObserver()
        configureResourcesCollectionViewController()
        configureErrorView()
        
    }
    
    func configureResourcesCollectionViewController(){
        let realm = ResourceFunctions.shared.realm
        currentResource = realm.objects(Resource.self).first!
        configureBackButton()
        configureNavBarTitle()
        configureNotificationToken()
        downloadMetaInfoForChildren()
    }
    
    func configureNotificationToken(){
        notificationToken = currentResource?.children.observe { [weak self] (changes) in
            guard let collectionView = self?.collectionView else { return }
            switch changes {
            case .initial:
                
                collectionView.reloadData()
                
            case .update(_, _, let insertions, _):
                
                collectionView.insertItems(at: insertions.map({ IndexPath(row: $0, section: 0) }))

            case .error(let error):
                // An error occurred while opening the Realm file on the background worker thread
                fatalError("\(error)")
            }
        }
    }
    
    deinit {
        notificationToken?.invalidate()
    }
    
    func configureBackButton(){
        if currentResource?.parent.first == nil {
            backButton.isEnabled = false
            backButton.tintColor = UIColor.clear
        } else {
            backButton.isEnabled = true
            backButton.tintColor = UIColor.black
        }
    }
    
    func configureNavBarTitle(){
        if currentResource?.parent.first == nil{
            navBar?.title = "Диск"
        } else {
            navBar?.title = currentResource?.name
        }
    }

    func configureErrorView(){
        if Connectivity.isConnectedToInternet {
            UIView.animate(withDuration: 1.0, animations: {
                self.errorViewTopConstraint.constant = -44
            })
        } else {
            UIView.animate(withDuration: 1.0, animations: {
                self.errorViewTopConstraint.constant = 0
            })
        }
    }

    func configureConnectionObserver(){
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: Connectivity.connectionDidChanged), object: nil, queue: OperationQueue.main) { (notification) in
            if Connectivity.isConnectedToInternet {
                DispatchQueue.main.async {
                    self.configureErrorView()
                    let actionAlertController = UIAlertController(title: "Соединение восстановлено", message: "Вы будете перенаправлены в корневую папку.", preferredStyle: .alert)
                    let action = UIAlertAction(title: "Понятно", style: .cancel, handler: { action in
                        self.notificationToken?.invalidate()
                        ResourceFunctions.shared.deleteAll()
                        YandexClient.shared.downloadMetaInfo(at: "/", for: nil, downloadSuccess: {
                            self.configureResourcesCollectionViewController()
                        }, downloadFailure: nil)
                    })
                    actionAlertController.addAction(action)
                    self.present(actionAlertController, animated: true, completion: nil)
                }
            } else {
                DispatchQueue.main.async {
                    self.configureErrorView()
                }
            }
        }
    }
    
    
    func downloadMetaInfoForChildren(){
        if Connectivity.isConnectedToInternet{
            for child in currentResource!.children {
                if child.type == "dir"{
                    YandexClient.shared.downloadMetaInfo(at: child.path, for: child, downloadSuccess: {
                        // nothing
                    }, downloadFailure: nil)
                }
            }
        }
    }
    
    func deleteChildren(for resource: Resource, completion: @escaping ()->()){
        if Connectivity.isConnectedToInternet{
            for child in resource.children {
                ResourceFunctions.shared.deleteChildren(for: child)
            }
            completion()
        }
    }

    @IBAction func backButtonTapped(_ sender: Any) {
        currentResource = currentResource?.parent.first
        notificationToken?.invalidate()
        collectionView.reloadData()
        configureBackButton()
        configureNavBarTitle()
        DispatchQueue.main.async {
            self.configureNotificationToken()
        }
    }
}

extension ResourcesCollectionViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentResource?.children.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ResourceCollectionViewCell.identifier, for: indexPath) as! ResourceCollectionViewCell
        cell.setup(currentResource?.children[indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if currentResource?.children[indexPath.row].type == "dir" {
            currentResource = currentResource?.children[indexPath.row]
            notificationToken?.invalidate()
            collectionView.reloadData()
            configureBackButton()
            configureNavBarTitle()
            DispatchQueue.main.async {
                self.configureNotificationToken()
                self.deleteChildren(for: self.currentResource!, completion: {
                    self.downloadMetaInfoForChildren()
                })
                
            }
        } else {
            return
        }
    }
    
}
