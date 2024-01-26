//
//  LikeCollectionViewCell.swift
//  Fast_Walk
//
//  Created by visitor on 2024/01/24.
//

import UIKit

class LikeCollectionViewCell: UICollectionViewCell {
    static let identifier = "LikeCollectionViewCell"

    let imageView = UIImageView()
    let titleLabel = UILabel()
    let descriptionLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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

        // Add subviews
        [imageView, titleLabel, descriptionLabel].forEach {
            addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        // Set constraints for subviews
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20), // Move 20 points to the right
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 100), // Increase width to 100
            imageView.heightAnchor.constraint(equalToConstant: 100), // Increase height to 100

            titleLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            titleLabel.topAnchor.constraint(equalTo: topAnchor),

            descriptionLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 10),
            descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5)
        ])
    }

}

