//
//  PlaceDetails.swift
//  Fast_Walk
//
//  Created by Jianjun Zhao on 2023/12/21.
//

import UIKit

class PlaceDetails: UIView {
    static let identifier = "PlaceDetails"
    @IBOutlet weak var placePictureView: UIImageView!
    @IBOutlet weak var placeDetailsLabel: UILabel!
    @IBOutlet weak var placeAddressLabel: UILabel!
    @IBOutlet weak var placeTypeLabel: UILabel!
    
    override init(frame: CGRect) {
            super.init(frame: frame)
        }

        required init?(coder: NSCoder) {
            super.init(coder: coder)
        }

    func loadViewFromNib() {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "PlaceDetails", bundle: bundle)
        if let view = nib.instantiate(withOwner: self, options: nil).first as? UIView {
            view.frame = self.bounds
            view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
            self.addSubview(view)
        }
    }
            /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
