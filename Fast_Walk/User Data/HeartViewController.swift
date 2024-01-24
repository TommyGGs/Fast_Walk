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


class HeartViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var favorites: [FavoriteSpot] = []
    var collectionView: UICollectionView!

    
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        favorites = readFavorites()
        listFavorites()
        closeButton()
    }
    
    func readFavorites() -> [FavoriteSpot] {
        return Array(realm.objects(FavoriteSpot.self))
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return favorites.count // Replace with the actual number of items
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LikeCollectionViewCell.identifier, for: indexPath) as? LikeCollectionViewCell else {
            fatalError("Unable to dequeue CustomCollectionViewCell")
        }

        // Configure the cell
        cell.imageView.image = UIImage(named: "yourImageName") // Replace with your image
        cell.titleLabel.text = "Title \(indexPath.row)"
        cell.descriptionLabel.text = "Description for item \(indexPath.row)"

        return cell
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
