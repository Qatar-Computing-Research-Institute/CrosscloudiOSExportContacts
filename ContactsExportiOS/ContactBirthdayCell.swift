//
//  ContactBirthdayCell.swift
//  Birthdays
//
//  Created by Gabriel Theodoropoulos on 27/9/15.
//  Copyright © 2015 Appcoda. All rights reserved.
//

import UIKit

class ContactTableViewCell: UITableViewCell {

    @IBOutlet weak var lblFullname: UILabel!
    
    @IBOutlet weak var lblBirthday: UILabel!
    
    @IBOutlet weak var imgContactImage: UIImageView!
    
    @IBOutlet weak var lblEmail: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    class func instanceFromNib() -> ContactTableViewCell {
        return UINib(nibName: "ContactTableViewCell", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! ContactTableViewCell
    }

}
