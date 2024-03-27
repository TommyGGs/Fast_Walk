//
//  HeartViewController.swift
//  Fast_Walk
//
//  Created by visitor on 2024/01/24.
//

import UIKit
import RealmSwift
import GoogleSignIn
import LineSDK
import GooglePlaces



class HeartViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var favorites: [FavoriteSpot] = []
    var collectionView: UICollectionView!
    var placesClient: GMSPlacesClient! = GMSPlacesClient.shared()


    
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        favorites = readFavorites()
        listFavorites()
        closeButton()
        print(favorites)
        print(Current.user)
    }
    
    func deleteItemAt(_ indexPath: IndexPath) {
        let itemToDelete = favorites[indexPath.row]
        try! realm.write {
            realm.delete(itemToDelete)
        }
        favorites.remove(at: indexPath.row)
        collectionView.deleteItems(at: [indexPath])
    }
    
    func readFavorites() -> [FavoriteSpot] {
        let allFav = Array(realm.objects(FavoriteSpot.self))
        var userFav: [FavoriteSpot] = []
        for fav in allFav {
            if fav.userID == Current.user.userID {
                userFav.append(fav)
            }
        }
        return userFav
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return favorites.count // Replace with the actual number of items
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LikeCollectionViewCell.identifier, for: indexPath) as? LikeCollectionViewCell else {
            fatalError("Unable to dequeue CustomCollectionViewCell")
        }
        cell.indexPath = indexPath
        cell.onDeleteTapped = { [weak self] indexPath in
            self?.deleteItemAt(indexPath)
        }

        let placeID = favorites[indexPath.row].placeID

        print ("placeid favorites = \(placeID)")
        
        // Specify the place data types to return.
        let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt64(UInt(GMSPlaceField.name.rawValue) | UInt(GMSPlaceField.placeID.rawValue) | UInt(GMSPlaceField.photos.rawValue) | UInt(GMSPlaceField.rating.rawValue) | UInt(GMSPlaceField.types.rawValue)))

        
        placesClient?.fetchPlace(fromPlaceID: placeID, placeFields: fields, sessionToken: nil, callback: {
          (place: GMSPlace?, error: Error?) in
          if let error = error {
            print("An error occurred: \(error.localizedDescription)")
            return
          }
            if let place = place {
                print("place rating\(place.rating)")
                print("placetypes\(String(describing: place.types?.first))")
                print(place.rating)
                print("The selected place is: \(String(describing: place.name))")
                cell.titleLabel.text = place.name
                cell.descriptionLabel.text = "評価：" + String(Int(place.rating))
                
                //TODO: - connect star 
                cell.typeLabel.text = "ジャンル:"  + (place.types?.first ?? "nil")
                self.loadPhoto(place.photos?.first) {  placePhoto in
                    if let placePhoto = placePhoto {
                        DispatchQueue.main.async {
                            cell.imageView.image = placePhoto
                        }
                        print("marker loaded")
                    }
                }
            }
        })
        print("returning cell\(cell)")
        return cell
    }
    
    func loadPhoto(_ metadata: GMSPlacePhotoMetadata?, completion: @escaping (UIImage?) -> Void) {
        guard let metadata = metadata else {
            print("photo metadata is nil")
            completion(nil)
            return
        }
        placesClient.loadPlacePhoto(metadata, callback: { (photo, error) in
            if let error = error {
                print("Error loading photo metadata: \(error.localizedDescription)")
                completion(nil)
                return
            }
            if let photo = photo {
                print("photo metadata loaded")
                completion(photo)
            }
        })
    }
    
    func listFavorites() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: view.frame.size.width, height: 100)
        layout.scrollDirection = .vertical

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(LikeCollectionViewCell.self, forCellWithReuseIdentifier: LikeCollectionViewCell.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .white

        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: 40),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    
    
    func closeButton() {
        let close = UIButton(type: .system)
        close.setTitle("閉じる", for: .normal)
        close.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        close.addTarget(self , action: #selector(closeScreen), for: .touchUpInside)
        close.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(close)
        
        NSLayoutConstraint.activate([
            close.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            close.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10)
        ])
    }
    
    @objc func closeScreen() {
        print("button clicked")
        self.dismiss(animated: true, completion: nil)
    }
}