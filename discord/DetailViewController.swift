//
//  DetailViewController.swift
//  discord
//
//  Created by Ke Li on 4/20/18.
//  Copyright © 2018 Ke Li. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    var proxy: Proxy!
    var itemString: String?
    @IBAction func onBackButtonClicked(_ sender: Any) {
        if let _ = self.presentingViewController {
            // simply discard any change
            self.presentingViewController!.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func onSaveButtonClicked(_ sender: UIBarButtonItem) {
        print(self.proxy)
        if let _ = self.presentingViewController {
            if let tempViewController = self.presentingViewController as? ViewController {
                // pass back change from here.
                tempViewController.callbackFromOtherVC()
            }
            self.presentingViewController!.dismiss(animated: true, completion: nil)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        if let itemStringExists = itemString {
            print(itemStringExists)
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

/// MARK: - UITableViewDelegate, UITableViewDataSource
extension DetailViewController {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 5 : 6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                // name for proxy
                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath) as! LabelWithInputTableViewCell
                cell.textFieldCallback = {(textField: UITextField) -> Void in
                    self.proxy.name = textField.text
                }
                cell.hintLabel.text = "Name"
                cell.textField.text = proxy.name
                return cell
            } else if indexPath.row == 1 {
                // description for proxy
                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath) as! LabelWithInputTableViewCell
                cell.textFieldCallback = {(textField: UITextField) -> Void in
                    self.proxy.description = textField.text
                }
                cell.hintLabel.text = "Description"
                cell.textField.text = proxy.description
                return cell
            } else if indexPath.row == 2 {
                // image url for proxy
                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath) as! LabelWithInputTableViewCell
                cell.textFieldCallback = {(textField: UITextField) -> Void in
                    self.proxy.imageUrl = textField.text
                }
                cell.hintLabel.text = "Image URL"
                cell.textField.text = proxy.imageUrl
                return cell
            } else if indexPath.row == 3 {
                // enable cell here
                let cell = tableView.dequeueReusableCell(withIdentifier: "AuthCell", for: indexPath) as! AuthenticateTableViewCell
                cell.switchCallback = { (switcher: UISwitch) -> Void in
                    self.proxy.enable = switcher.isOn
                }
                cell.hintLabel.text = "Enable"
                cell.switcher.isOn = proxy.enable
                return cell
            } else {
                // automatic or manual cell
                let cell = tableView.dequeueReusableCell(withIdentifier: "AutoCell", for: indexPath) as! AutomaticOrManualUITableViewCell
                cell.segmentCallback = { (segment: UISegmentedControl) -> Void in
                    self.proxy.isAutomatic = (segment.selectedSegmentIndex == 1)
                    tableView.reloadData()
                }
                cell.segmentControl.selectedSegmentIndex = self.proxy.isAutomatic ? 1 : 0
                return cell
            }
        } else {
            if indexPath.row == 0 {
                // pacUrl cell here
                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath) as! LabelWithInputTableViewCell
                cell.textFieldCallback = { (textField: UITextField) -> Void in
                    self.proxy.pacUrl = textField.text
                }
                cell.hintLabel.text = "PAC URL"
                cell.textField.isEnabled = proxy.isAutomatic
                cell.hintLabel.isEnabled = proxy.isAutomatic
                return cell
            } else if indexPath.row == 1 {
                // server here
                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath) as! LabelWithInputTableViewCell
                cell.textFieldCallback = { (textField: UITextField) -> Void in
                    self.proxy.host = textField.text
                }
                cell.hintLabel.text = "Server"
                cell.textField.text = proxy.host
                cell.textField.isEnabled = !proxy.isAutomatic
                cell.hintLabel.isEnabled = !proxy.isAutomatic
                return cell
            } else if indexPath.row == 2 {
                // port here
                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath) as! LabelWithInputTableViewCell
                cell.textFieldCallback = { (textField: UITextField) -> Void in
                    if let number = Int(textField.text!) {
                        self.proxy.port = number
                    } else {
                        self.proxy.port = 0
                    }
                }
                cell.hintLabel.text = "Port"
                cell.textField.text = String(proxy.port)
                cell.textField.isEnabled = !proxy.isAutomatic
                cell.hintLabel.isEnabled = !proxy.isAutomatic
                return cell
            } else if indexPath.row == 3 {
                // authenticate ?
                // enable cell here
                let cell = tableView.dequeueReusableCell(withIdentifier: "AuthCell", for: indexPath) as! AuthenticateTableViewCell
                cell.switchCallback = { (switcher: UISwitch) -> Void in
                    self.proxy.needAuthenticate = switcher.isOn
                    tableView.reloadData()
                }
                cell.switcher.isOn = proxy.needAuthenticate
                cell.hintLabel.isEnabled = !proxy.isAutomatic
                cell.switcher.isEnabled = !proxy.isAutomatic
                return cell
            } else if indexPath.row == 4 {
                // server here
                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath) as! LabelWithInputTableViewCell
                cell.textFieldCallback = { (textField: UITextField) -> Void in
                    self.proxy.username = textField.text
                }
                cell.hintLabel.text = "Username"
                cell.textField.text = proxy.username
                cell.textField.isEnabled = (!proxy.isAutomatic) && (proxy.needAuthenticate)
                cell.hintLabel.isEnabled = (!proxy.isAutomatic) && (proxy.needAuthenticate)
                return cell
            } else  {
                // password here
                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath) as! LabelWithInputTableViewCell
                cell.textFieldCallback = { (textField: UITextField) -> Void in
                    self.proxy.password = textField.text
                }
                cell.hintLabel.text = "Password"
                cell.textField.text = proxy.password
                cell.textField.isEnabled = (!proxy.isAutomatic) && (proxy.needAuthenticate)
                cell.hintLabel.isEnabled = (!proxy.isAutomatic) && (proxy.needAuthenticate)
                return cell
            }
        }
    }
}
