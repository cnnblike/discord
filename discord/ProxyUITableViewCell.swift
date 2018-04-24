//
//  ProxyUITableViewCell.swift
//  discord
//
//  Created by Ke Li on 4/22/18.
//  Copyright © 2018 Ke Li. All rights reserved.
//

import UIKit

class ProxyUITableViewCell: UITableViewCell {

    var switchCallback: ((UISwitch) -> Void)?
    var proxy: Proxy!
    @IBOutlet weak var ruleImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var proxySwitch: UISwitch!
    @IBAction func switchChanged(_ sender: UISwitch) {
        switchCallback?(sender)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
