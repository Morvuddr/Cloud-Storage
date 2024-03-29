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

class ResourcesCollectionViewController: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet var navBar: UINavigationItem!
    @IBOutlet weak var errorViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var inputButton: UIButton!
    
    var currentResource: Resource?
    var selectedResource: Resource? {
        didSet {
            updateButtons()
        }
    }
    
    var notificationToken: NotificationToken?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        navigationController?.navigationBar.barTintColor = UIColor.white
        cancelButton.layer.cornerRadius = cancelButton.frame.height / 2
        inputButton.layer.cornerRadius = 15
        
        configureConnectionObserver()
        configureResourcesCollectionViewController()
        if !Connectivity.isConnectedToInternet {
            configureErrorView()
        }
        configureLongPressGestureRecognizer()
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
                
            case .update(_, _, let insertions,_):

                self!.collectionView.insertItems(at: insertions.map({ IndexPath(row: $0, section: 0) }))
                
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
            UIView.animate(withDuration: 0.5, animations: {
                self.errorViewTopConstraint.constant = -44
                self.view.layoutIfNeeded()
            })
        } else {
            UIView.animate(withDuration: 0.5, animations: {
                self.errorViewTopConstraint.constant = 0
                self.view.layoutIfNeeded()
            })
        }
    }

    func configureConnectionObserver(){
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: Connectivity.connectionDidChanged), object: nil, queue: OperationQueue.main) { (notification) in
            if Connectivity.isConnectedToInternet {
                DispatchQueue.main.async {
                    self.configureErrorView()
                    self.showAlert(title: "Соединение восстановлено", message: "Вы будете перенаправлены в корневую папку.", handler: { action in
                        self.notificationToken?.invalidate()
                        ResourceFunctions.shared.deleteAll()
                        YandexClient.shared.downloadMetaInfo(at: "/", for: nil, downloadSuccess: {
                            self.configureResourcesCollectionViewController()
                        }, downloadFailure: nil)
                    })
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
            for child in currentResource!.children.filter({$0.type == "dir"}) {
                YandexClient.shared.downloadMetaInfo(at: child.path, for: child, downloadSuccess: {
                    let last = self.currentResource!.children.last(where: { (resource) -> Bool in
                        return resource.type == "dir"
                    })
                    if child.name == last!.name {
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ProcessCompleted"), object: nil)
                    }
                }, downloadFailure: nil)
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
    
    func configureLongPressGestureRecognizer(){
        let longPressGR = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(longPressGR:)))
        longPressGR.minimumPressDuration = 0.3
        longPressGR.delegate = self
        longPressGR.delaysTouchesBegan = true
        self.collectionView.addGestureRecognizer(longPressGR)
    }
    
    @objc func handleLongPress(longPressGR: UILongPressGestureRecognizer) {
        if longPressGR.state != .began {
            return
        }
        
        let point = longPressGR.location(in: self.collectionView)
        let indexPath = self.collectionView.indexPathForItem(at: point)
        
        if let indexPath = indexPath {
            let cell = self.collectionView.cellForItem(at: indexPath) as! ResourceCollectionViewCell
            let actionSheetController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
            let downloadAction = UIAlertAction(title: "Скачать", style: .default) { (action) in
                self.downloadResource(resourceName: cell.resource!.name, resourcePath: cell.resource!.path)
            }
            let cutAction = UIAlertAction(title: "Вырезать", style: .default) { (action) in
                //Cut file
                self.selectResource(resource: cell.resource!)
            }
            let showPropertiesAction = UIAlertAction(title: "Свойства", style: .default) { (action) in
                // Show resource properties
                let vc = ResourcePropertiesViewController.getInstance() as! ResourcePropertiesViewController
                vc.resource = cell.resource
                self.tabBarController?.present(vc, animated: true, completion: nil)
            }
            
            if cell.resource?.type == "file"{
                actionSheetController.addAction(downloadAction)
            }
            actionSheetController.addAction(cutAction)
            actionSheetController.addAction(showPropertiesAction)
            actionSheetController.addAction(cancelAction)
            actionSheetController.view.tintColor = UIColor.black
            DispatchQueue.main.async {
                self.present(actionSheetController, animated: true, completion: nil)
            }
            
        } else {
            print("Could not find index path")
        }
    }
    
    @IBAction func addBarItemTapped(_ sender: Any) {
        if Connectivity.isConnectedToInternet{
            let vc = AddResourceViewController.getInstance() as! AddResourceViewController
            vc.resource = currentResource
            vc.completion = { (resource, newResourceName) in
                let check = resource.children.first(where: { (resource) -> Bool in
                    if resource.name == newResourceName {
                        return true
                    }
                    return false
                })
                if check == nil {
                    YandexClient.shared.createResource(currentResource: resource, newResourceName: newResourceName)
                } else {
                    self.showAlert(title: "Ошибка создания новой папки", message: "Папка с именем \(newResourceName) уже существует.", handler: nil)
                }
            }
            self.tabBarController?.present(vc, animated: true, completion: nil)
        } else {
            showAlert(title: "Отсутствует соединение", message: "Проверьте ваше интернет-соединение и повторите попытку.", handler: nil)
        }
    }
    
    func showAlert(title: String, message: String, handler: ((UIAlertAction)->())?){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Понятно", style: .cancel, handler: handler)
        alert.addAction(action)
        self.tabBarController?.present(alert, animated: true, completion: nil)
    }
    
    func showLoadingView(reason: String){
        if Connectivity.isConnectedToInternet {
            let vc = LoadingViewController.getInstance() as! LoadingViewController
            vc.reason = reason
            self.tabBarController?.present(vc, animated: true, completion: nil)
        }
    }
    
    func downloadResource(resourceName: String, resourcePath: String) {
        //Download file
        if Connectivity.isConnectedToInternet {
            YandexClient.shared.downloadResource(path: resourcePath, fileName: resourceName){ fileURL in
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ProcessCompleted"), object: nil)
                let activityVC = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
                activityVC.excludedActivityTypes = [.airDrop, .postToTwitter, .markupAsPDF, .mail, .message, .postToVimeo, .openInIBooks, .postToFacebook, .copyToPasteboard, .addToReadingList, .assignToContact, .print]
                activityVC.accessibilityLanguage = "ru"
                activityVC.completionWithItemsHandler = { (activityType, completed, returnedItems, activityError) in
                    do {
                        try FileManager.default.removeItem(at: fileURL)
                    } catch (let error) {
                        print(error)
                    }
                    if completed {
                        self.showAlert(title: "Успех", message: "Файл сохранен.", handler: nil)
                    } else {
                        self.showAlert(title: "Отмена действия", message: "Файл удален.", handler: nil)
                    }
                }
                DispatchQueue.main.async {
                    self.tabBarController?.present(activityVC, animated: true, completion: nil)
                }
            }
            
            DispatchQueue.main.async {
                self.showLoadingView(reason: "Загрузка файла \"\(resourceName)\"...")
            }
        } else {
            showAlert(title: "Отсутствует соединение", message: "Проверьте ваше интернет-соединение и повторите попытку.", handler: nil)
        }
    }
    
    func selectResource(resource: Resource){
        self.selectedResource = resource
    }
    
    func updateButtons(){
        if selectedResource == nil {
            UIView.animate(withDuration: 0.3) {
                self.cancelButton.backgroundColor = .white
                self.cancelButton.isEnabled = false
                self.inputButton.backgroundColor = .white
                self.inputButton.isEnabled = false
            }
        } else {
            UIView.animate(withDuration: 0.3) {
                self.cancelButton.backgroundColor = .red
                self.cancelButton.isEnabled = true
                self.inputButton.backgroundColor = .black
                self.inputButton.isEnabled = true
            }
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Отмена действия", message: "Вы действительно хотите отменить выбор объекта \"\(selectedResource!.name)\"", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Нет", style: .cancel, handler: nil)
        let action = UIAlertAction(title: "Да", style: .default) { (UIAlertAction) in
            self.selectedResource = nil
        }
        alert.addAction(cancel)
        alert.addAction(action)
        self.tabBarController?.present(alert, animated: true, completion: nil)
    }
    @IBAction func inputButtonTapped(_ sender: Any) {
        if Connectivity.isConnectedToInternet {
            if !((currentResource?.path.contains(selectedResource!.name))!){
                YandexClient.shared.moveResource(selectedResource: selectedResource!, currentResource: currentResource!) {
                     NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ProcessCompleted"), object: nil)
                    self.selectedResource = nil
                }
                self.showLoadingView(reason: "Идёт синхронизация...")
            } else {
                showAlert(title: "Ошибка", message: "Невозможно переместить папку внутрь себя.", handler: nil)
            }
        } else {
            showAlert(title: "Отсутствует соединение", message: "Проверьте ваше интернет-соединение и повторите попытку.", handler: nil)
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
                if (self.currentResource!.children.filter({$0.type == "dir"}).count) > 0 {
                    self.deleteChildren(for: self.currentResource!, completion: {
                        self.downloadMetaInfoForChildren()
                    })
                    self.showLoadingView(reason: "Загрузка данных...")
                }
            }
        } else {
            return
        }
    }
    
}
