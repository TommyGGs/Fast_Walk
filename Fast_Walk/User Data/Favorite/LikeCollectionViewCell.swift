//
//  LikeCollectionViewCell.swift
//  Fast_Walk
//
//  Created by visitor on 2024/01/24.
//

import UIKit
import RealmSwift

class LikeCollectionViewCell: UICollectionViewCell {
    static let identifier = "LikeCollectionViewCell"

    var onDeleteTapped: ((IndexPath) -> Void)?
    var favorites: [FavoriteSpot] = []
    var indexPath: IndexPath?
    
    
    let imageView = UIImageView()
    let titleLabel = UILabel()
    let descriptionLabel = UILabel()
    let typeLabel = UILabel()
    let deleteButton = UIButton()
    let star1 = UIImageView()
    let star2 = UIImageView()
    let star3 = UIImageView()
    let star4 = UIImageView()
    let star5 = UIImageView()
    
    
    let realm = try! Realm()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        deleteButton.layer.cornerRadius = deleteButton.frame.height / 8
        imageView.layer.cornerRadius = imageView.frame.size.width / 10

        // Set corner radius for other subviews if needed
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func deleteButtonTapped() {
        guard let indexPath = indexPath else { return }
        onDeleteTapped?(indexPath)
    }

    private func setupViews() {
        // Image View
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true

        // Title Label
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)

        // Description Label
        descriptionLabel.font = UIFont.systemFont(ofSize: 14)
        descriptionLabel.numberOfLines = 2
        
        typeLabel.font = UIFont.systemFont(ofSize: 14)
        typeLabel.numberOfLines = 2
        

        // Add subviews
        [imageView, titleLabel, descriptionLabel, typeLabel, star1, star2, star3, star4, star5].forEach {
            addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        if let trashImage = UIImage(systemName: "trash")?.withRenderingMode(.alwaysTemplate) {
            deleteButton.setImage(trashImage, for: .normal)
            deleteButton.tintColor = .white // Set the tint color to white
        }
        
        deleteButton.setImage(UIImage(systemName: "trash"), for: .normal)
        deleteButton.backgroundColor = .red
        deleteButton.layer.borderColor = UIColor.red.cgColor // Use a darker red color if necessary
        deleteButton.layer.borderWidth = 1
        deleteButton.setTitleColor(.white, for: .normal)
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)

        addSubview(deleteButton)
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        

        // Set constraints for subviews
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20), // Move 20 points to the right
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 100), // Set width to 100
            imageView.heightAnchor.constraint(equalToConstant: 100), // Set height to 100
            
            titleLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            titleLabel.topAnchor.constraint(equalTo: topAnchor),

            descriptionLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 10),
            descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            
            typeLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 10),
            typeLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            typeLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 5),
            
            deleteButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            deleteButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            deleteButton.widthAnchor.constraint(equalToConstant: 80),
            deleteButton.heightAnchor.constraint(equalToConstant: 30),
            
        ])
    }
}

