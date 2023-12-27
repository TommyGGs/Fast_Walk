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

    @IBOutlet weak var contentView: UIView!
    override init(frame: CGRect) {
            super.init(frame: frame)
            commonInit()
        }

        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            commonInit()
        }

    private func commonInit() {
            // Load the view from the XIB
            Bundle.main.loadNibNamed("PlaceDetails", owner: self, options: nil)
            addSubview(contentView)
            contentView.frame = self.bounds
            contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        }
    func requiredSize(view: UIView?) -> CGSize {
        guard let view = view else {
            print ("error in requiredSize")
            return CGSize(width: 0.0, height: 0.0)
               }
        view.setNeedsLayout()
            view.layoutIfNeeded() // Force layout pass
        print(view.bounds.size.height, view.bounds.size.width)
            return view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        }
}
