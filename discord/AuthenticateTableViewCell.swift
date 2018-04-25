//
//  AuthenticateTableViewCell.swift
//  discord
//
//  Created by Ke Li on 4/25/18.
//  Copyright © 2018 Ke Li. All rights reserved.
//

import UIKit

class AuthenticateTableViewCell: UITableViewCell {

    var switchCallback: ((UISwitch) -> Void)?
    @IBOutlet weak var switcher: UISwitch!
    @IBAction func switchChanged(_ sender: UISwitch) {
        switchCallback?(sender)
    }
    @IBOutlet weak var hintLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
