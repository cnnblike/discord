//
//  LabelWithInputTableViewCell.swift
//  discord
//
//  Created by Ke Li on 4/25/18.
//  Copyright © 2018 Ke Li. All rights reserved.
//

import UIKit

class LabelWithInputTableViewCell: UITableViewCell, UITextFieldDelegate {
    
    var textFieldCallback: ((UITextField) -> Void)?
    @IBOutlet weak var textField: UITextField!
    @IBAction func textFieldEditingChanged(_ sender: UITextField) {
        textFieldCallback?(sender)

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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.endEditing(false)
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textFieldCallback?(textField)
        return true
    }
}
