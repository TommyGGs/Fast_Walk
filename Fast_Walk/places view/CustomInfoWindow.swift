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

    var contentView: UIView!
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
}
