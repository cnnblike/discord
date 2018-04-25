//
//  AutomaticUITableViewCell.swift
//  discord
//
//  Created by Ke Li on 4/25/18.
//  Copyright © 2018 Ke Li. All rights reserved.
//

import UIKit

class AutomaticOrManualUITableViewCell: UITableViewCell {

    var segmentCallback: ((UISegmentedControl) -> Void)?
    @IBAction func segmentControlValueChanged(_ sender: UISegmentedControl) {
        segmentCallback?(sender)
    }
    @IBOutlet weak var segmentControl: UISegmentedControl!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
