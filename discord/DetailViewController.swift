//
//  DetailViewController.swift
//  discord
//
//  Created by Ke Li on 4/20/18.
//  Copyright © 2018 Ke Li. All rights reserved.
//

import UIKit
import Alamofire

class DetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    var proxy: Proxy!
    var index: Int!
    var initialTVHeight: CGFloat!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func onBackButtonClicked(_ sender: Any) {
        if let _ = self.presentingViewController {
            // simply discard any change
            self.presentingViewController!.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func onSaveButtonClicked(_ sender: UIBarButtonItem) {
        if let _ = self.presentingViewController {
            let activityView: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
            activityView.transform = CGAffineTransform(scaleX: 2.0, y: 2.0)
            activityView.center = self.view.center
            activityView.startAnimating()
            self.view.addSubview(activityView)
            self.view.isUserInteractionEnabled = false
            // download image and pac file -> and process here.
            validateAndDownload(item: self.proxy) { res in
                self.tableView.reloadData()
                self.view.isUserInteractionEnabled = true
                self.view.willRemoveSubview(activityView)
                activityView.stopAnimating()
                switch res {
                case .warning:
                    // since we know warning won't be a problem of usage, we just alert user and told them the pac image isn't working well and go on.
                    let alert = UIAlertController(title: "Opps, something went wrong", message: "but that won't affect your use", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (alertAction) in
                        self.goback()
                    }))
                    self.present(alert, animated: true, completion: nil)
                case .ok:
                    self.goback()
                case .error:
                    let alert = UIAlertController(title: "Opps, something went wrong", message: "check your input please", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (alertAction) in
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    func goback(){
        if let tempViewController = self.presentingViewController as? ViewController {
            // pass back change from here.
            tempViewController.callbackFromOtherVC(index: self.index, item: self.proxy)
            self.presentingViewController!.dismiss(animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver( self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver( self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    
    @objc func adjustForKeyboard( notification:Notification ) {
        // ref: https://www.hackingwithswift.com/example-code/uikit/how-to-adjust-a-uiscrollview-to-fit-the-keyboard
        let userInfo = notification.userInfo!
        let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        if notification.name == Notification.Name.UIKeyboardWillHide {
            self.tableView.contentInset = UIEdgeInsets.zero
        } else {
            self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height + 15.0, right: 0)
            // TODO: 15.0 here is a magic number, just enough to make sure the editing line isn't too close to the keyboard, providing some extra space for reading
        }
        self.tableView.scrollIndicatorInsets = self.tableView.contentInset
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
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
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "CONFIG" : "NETWORK"
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
                    self.proxy.descriptor = textField.text
                }
                cell.hintLabel.text = "Description"
                cell.textField.text = proxy.descriptor
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
                cell.textField.text = self.proxy.pacUrl
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
                        textField.text = String(number)
                    } else {
                        self.proxy.port = 0
                        textField.text = "0"
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
