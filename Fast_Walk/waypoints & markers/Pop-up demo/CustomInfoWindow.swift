//
//  CustomInfoWindoe.swift
//  Fast_Walk
//
//  Created by Jianjun Zhao on 2023/12/26.
//

import Foundation
import UIKit

class CustomInfoWindow: UIView {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var snippetLabel: UILabel!
    @IBOutlet weak var pictureView: UIImageView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var star1: UIImageView!
    @IBOutlet weak var star2: UIImageView!
    @IBOutlet weak var star3: UIImageView!
    @IBOutlet weak var star4: UIImageView!
    @IBOutlet weak var star5: UIImageView!
//    @IBOutlet var heart: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
        contentView.isUserInteractionEnabled = true
//        heart.isUserInteractionEnabled = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
        contentView.isUserInteractionEnabled = true
    }
    
    private func commonInit() {
        // Load the view from the XIB
        Bundle.main.loadNibNamed("PlaceDetails", owner: self, options: nil)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        setupStyle()
        
        addSubview(contentView)
    }
    
    func requiredSize(view: UIView?) -> CGSize {
        guard let view = view else {
            print ("error in requiredSize")
            return CGSize(width: 0.0, height: 0.0)
        }
        //view.translatesAutoresizingMaskIntoConstraints = false
        view.setNeedsLayout()
        view.layoutIfNeeded() // Force layout pass
        print(view.bounds.size.height, view.bounds.size.width)
        return view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
    }
    
    private func setupStyle() {
        contentView.layer.cornerRadius = 40
        contentView.backgroundColor = #colorLiteral(red: 0.8862745098, green: 0.9411764706, blue: 0.9882352941, alpha: 0.868413862)
        pictureView.layer.cornerRadius = 20
        pictureView.layer.opacity = 1
        
        
    }
}