//
//  EnableUITableViewCell.swift
//  discord
//
//  Created by Ke Li on 4/22/18.
//  Copyright © 2018 Ke Li. All rights reserved.
//

import UIKit

class EnableUITableViewCell: UITableViewCell {

    var switchCallback: ((UISwitch) -> Void)?
    @IBAction func switchChanged(_ sender: UISwitch) {
        switchCallback?(sender)
    }
    @IBOutlet weak var enableSwitch: UISwitch!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
