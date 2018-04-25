//
//  ViewController.swift
//  discord
//
//  Created by Ke Li on 4/19/18.
//  Copyright © 2018 Ke Li. All rights reserved.
//

import UIKit
import Disk

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var editEnabled: Bool = false
    var enableCell: EnableUITableViewCell!
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func onAddNewProxyButtonClicked(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "QR Code", style: .default) { _ in
            self.performSegue(withIdentifier: "ShowQRView", sender: nil)
        })
        
        alert.addAction(UIAlertAction(title: "Input Manually", style: .default) { _ in
            self.performSegue(withIdentifier: "ShowDetailView", sender: nil)
        })

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
        })

        present(alert, animated: true)
    }
    
    @IBAction func onEditButtonClicked(_ sender: UIBarButtonItem) {
        editEnabled = !editEnabled
        self.tableView.setEditing(editEnabled, animated: true)
    }
    
    override func prepare(for segue:UIStoryboardSegue, sender: Any?) {
        if sender == nil {
            // we know it's just "Create" need.
            if segue.identifier == "ShowDetailView"{
                let controller = segue.destination as! DetailViewController
                controller.proxy = Proxy()
                //controller.proxy = Proxy(name: <#T##String#>, host: <#T##String#>, port: <#T##Int#>, password: <#T##String#>, enable: <#T##Bool#>, description: <#T##String#>) // so we just need a empty proxy
            }
        }
    }
    
    func callbackFromOtherVC(){
        // process crud here
        print("Callback triggered")
        // TODO: fix it, fake add here, only trigger the following add process when it's actually new rule
        VpnManager.shared.disconnect()
        tableView.beginUpdates()
        if(VpnManager.shared.proxies.count == 0){
            tableView.insertSections([1], with: .automatic)
        }
//        VpnManager.shared.proxies.append(Proxy(name: "new proxy", host: "ss", port: 80, password: "5052", enable: true, description: "Some description"))
        tableView.insertRows(at: [IndexPath(row: VpnManager.shared.proxies.count - 1, section: 1)], with: .automatic)
        tableView.endUpdates()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        VpnManager.shared.proxies = []
        // Do any additional setup after loading the view, typically from a nib.
        // TODO: Load stored data here
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "kProxyServiceVPNStatusNotification"), object: nil, queue: nil) { (x: Notification) in
            if self.enableCell != nil {
                self.enableCell?.enableSwitch.isOn = (VpnManager.shared.vpnStatus == .connecting) || (VpnManager.shared.vpnStatus == .on)
            }
        }
        if Disk.exists("config.json", in: .applicationSupport) {
            print("exist, no need to create")
        } else {
            print("create file")
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}



/// MARK: - UITableViewDelegate, UITableViewDataSource
extension ViewController {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if VpnManager.shared.proxies.count == 0 {
            return 1
        }
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        }
        return VpnManager.shared.proxies.count
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
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "AboutCell", for: indexPath)
                return cell
            }
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProxyCell", for: indexPath) as! ProxyUITableViewCell
            // TODO: add actual status here
            cell.proxy = VpnManager.shared.proxies[indexPath.row]
            cell.nameLabel.text = cell.proxy.name
            cell.detailLabel.text = cell.proxy.description
            cell.ruleImage.image = UIImage(named: "default")
            cell.proxySwitch.isOn = cell.proxy.enable
            cell.switchCallback = { (switcher: UISwitch) -> Void in
                cell.proxy.enable = switcher.isOn
                VpnManager.shared.disconnect()
                // disconnect here so user have to update the proxy setting above.
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Global" : "Rules"
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
                // TODO: updateStored()
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
                // TODO: show a legal issue / About issue VC here
            } else {
                // we are now handling the rules part. so we need to modify the items
                performSegue(withIdentifier: "ShowDetailView", sender: indexPath)
            }
        }
        
    }
}
