//
//  UserTableViewCell.swift
//  Fast_Walk
//
//  Created by Tom  on 2024/01/19.
//

import UIKit
import RealmSwift

class UserTableViewCell: UITableViewCell {
    
    @IBOutlet var userEmail: UILabel!
    @IBOutlet var signinMethod: UIImageView!
    @IBOutlet var userID: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setCell(email: String, method: String, id: String) {
        userEmail.text = email
        userID.text = id
    }
}
