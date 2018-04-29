//
//  ViewController.swift
//  discord
//
//  Created by Ke Li on 4/19/18.
//  Copyright © 2018 Ke Li. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var editEnabled: Bool = false
    var enableCell: EnableUITableViewCell!
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func onAddNewProxyButtonClicked(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: NSLocalizedString("QR Code", comment: ""), style: .default) { _ in
            self.performSegue(withIdentifier: "ShowQRView", sender: nil)
        })
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Input Manually", comment: ""), style: .default) { _ in
            self.performSegue(withIdentifier: "ShowDetailView", sender: nil)
        })

        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) { _ in
        })
        
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        present(alert, animated: true)
    }
    
    @IBAction func onEditButtonClicked(_ sender: UIBarButtonItem) {
        editEnabled = !editEnabled
        self.tableView.setEditing(editEnabled, animated: true)
    }
    
    override func prepare(for segue:UIStoryboardSegue, sender: Any?) {
        if sender == nil {
            // we know it's just "Create".
            if segue.identifier == "ShowDetailView"{
                let controller = segue.destination as! DetailViewController
                controller.proxy = Proxy() // so we just need a empty proxy
                controller.index = VpnManager.shared.proxies.count
            } else if segue.identifier == "ShowQRView"{
                let controller = segue.destination as! QRViewController
                controller.index = VpnManager.shared.proxies.count
            }
        } else {
            // it's update
            let controller = segue.destination as! DetailViewController
            let row = (sender as! IndexPath).row
            controller.proxy = VpnManager.shared.proxies[row]
            controller.index = row
        }
    }
    
    func callbackFromOtherVC(index: Int, item: Proxy){
        // process crud here
        VpnManager.shared.disconnect()
        // only trigger the following add process when it's actually new rule
        if index == VpnManager.shared.proxies.count {
            // insert here
            tableView.beginUpdates()
            if(VpnManager.shared.proxies.count == 0){
                tableView.insertSections([1], with: .automatic)
            }
            VpnManager.shared.proxies.append(item)
            tableView.insertRows(at: [IndexPath(row: VpnManager.shared.proxies.count - 1, section: 1)], with: .automatic)
            tableView.endUpdates()
        } else {
            VpnManager.shared.proxies[index] = item
            tableView.reloadData()
        }
        updateStored()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        if let decoded = UserDefaults.standard.object(forKey: "proxies") {
            let decoderresult = decoded as! Data
            VpnManager.shared.proxies = NSKeyedUnarchiver.unarchiveObject(with: decoderresult) as! [Proxy]
        } else {
            VpnManager.shared.proxies = []
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "kProxyServiceVPNStatusNotification"), object: nil, queue: nil) { (x: Notification) in
            if self.enableCell != nil {
                self.enableCell?.enableSwitch.isOn = (VpnManager.shared.vpnStatus == .connecting) || (VpnManager.shared.vpnStatus == .on)
            }
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateStored(){
        let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: VpnManager.shared.proxies)
        UserDefaults.standard.set(encodedData, forKey: "proxies")
        UserDefaults.standard.synchronize()
    }
}



/// MARK: - UITableViewDelegate, UITableViewDataSource
extension ViewController {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return VpnManager.shared.proxies.count == 0 ? 1 : 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 3 : VpnManager.shared.proxies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                enableCell = tableView.dequeueReusableCell(withIdentifier: "EnableCell", for: indexPath) as! EnableUITableViewCell
                enableCell.enableSwitch.isOn = (VpnManager.shared.vpnStatus == .on)
                enableCell.switchCallback = { (switcher: UISwitch) -> Void in
                    if switcher.isOn && (VpnManager.shared.vpnStatus == .off || VpnManager.shared.vpnStatus == .disconnecting) {
                        VpnManager.shared.connect()
                    }
                    if (!switcher.isOn) && (VpnManager.shared.vpnStatus == .on || VpnManager.shared.vpnStatus == .connecting) {
                        VpnManager.shared.disconnect()
                    }
                }
                return enableCell
            } else if indexPath.row == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ManualCell", for: indexPath)
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "AboutCell", for: indexPath)
                return cell
            }
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProxyCell", for: indexPath) as! ProxyUITableViewCell
            cell.proxy = VpnManager.shared.proxies[indexPath.row]
            cell.nameLabel.text = cell.proxy.name
            cell.detailLabel.text = cell.proxy.descriptor
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let filePath = documentsURL.appendingPathComponent(cell.proxy.cachedImage).path
            if cell.proxy.cachedImage != "" && FileManager.default.fileExists(atPath: filePath) {
                cell.ruleImage.image = UIImage(contentsOfFile: filePath)
            } else {
                cell.ruleImage.image = UIImage(named: "default")
            }
            cell.proxySwitch.isOn = cell.proxy.enable
            cell.switchCallback = { (switcher: UISwitch) -> Void in
                cell.proxy.enable = switcher.isOn
                VpnManager.shared.disconnect()
                self.updateStored()
                // disconnect here so user have to update the proxy setting above.
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? NSLocalizedString("Global", comment: ""): NSLocalizedString("Rules", comment: "")
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if indexPath.section == 1 {
            let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { (uiTableViewRowAction, indexPath) in
                VpnManager.shared.proxies.remove(at: indexPath.row)
                VpnManager.shared.disconnect()
                if VpnManager.shared.proxies.count == 0 {
                    tableView.deleteSections([1], with: .fade)
                }
                tableView.deleteRows(at: [indexPath], with: .fade)
                self.updateStored()
            }
            return [deleteAction]
        }
        return []
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section != 0
    }
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section != 0
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        VpnManager.shared.disconnect()
        let itemToMove = VpnManager.shared.proxies[sourceIndexPath.row]
        VpnManager.shared.proxies.remove(at: sourceIndexPath.row)
        VpnManager.shared.proxies.insert(itemToMove, at: destinationIndexPath.row)
        self.updateStored()
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        if (indexPath.section != 0) || (indexPath.row != 0) {
            return true
        }
        return false
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.section != 0) || (indexPath.row != 0) {
            tableView.deselectRow(at: indexPath, animated: true)
            if (indexPath.section == 0 ){
                if indexPath.row == 1{
                    performSegue(withIdentifier: "ShowManualView", sender: nil)
                } else if indexPath.row == 2 {
                    performSegue(withIdentifier: "ShowAboutView", sender: nil)
                }
            } else {
                // we are now handling the rules part. so we need to modify the items
                performSegue(withIdentifier: "ShowDetailView", sender: indexPath)
            }
        }
    }
}
