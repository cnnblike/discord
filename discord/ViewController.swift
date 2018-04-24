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
    var tableData: [String] = ["Proxy 1","Proxy 2","Proxy 3"]
    var editEnabled: Bool = false
    var hidden:[Bool] = [false, true]
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func onAddNewProxyButtonClicked(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "QR Code", style: .default) { _ in
            print("QR Code")
            self.performSegue(withIdentifier: "ShowQRView", sender: "ViewController")
        })
        
        alert.addAction(UIAlertAction(title: "Input Manually", style: .default) { _ in
            print("Input Manually")
            self.performSegue(withIdentifier: "ShowDetailView", sender: "ViewController")

        })
        alert.addAction(UIAlertAction(title: "Connect/Disconnect", style: .default, handler: { _ in
            if VpnManager.shared.vpnStatus == .off {
                VpnManager.shared.connect()
            } else {
                VpnManager.shared.disconnect()
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            print("Cancel")
        })

        present(alert, animated: true)
    }
    
    @IBAction func onEditButtonClicked(_ sender: UIBarButtonItem) {
        editEnabled = !editEnabled
        if editEnabled {
            self.tableView.setEditing(true, animated: true)
        } else {
            self.tableView.setEditing(false, animated: true)
        }
    }
    override func prepare(for segue:UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetailView"{
            let controller = segue.destination as! DetailViewController
            controller.itemString = sender as? String
        } else if segue.identifier == "ShowQRView" {
            print("prepare for QR View")
        }
    }
    
    func callbackFromOtherVC(){
        // process crud here
        print("Callback triggered")
        // TODO: fix it, fake add here, only trigger the following add process when it's actually new rule
        tableView.beginUpdates()
        if(tableData.count == 0){
            tableView.insertSections([1], with: .automatic)
        }
        tableData.append("Proxy x")
        tableView.insertRows(at: [IndexPath(row: tableData.count - 1, section: 1)], with: .automatic)
        tableView.endUpdates()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        // TODO: Load stored data here
        if Disk.exists("config.json", in: .applicationSupport) {
            print("exist, no need to create")
        } else {
            print("create file")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}



/// MARK: - UITableViewDelegate, UITableViewDataSource
extension ViewController {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableData.count == 0 {
            return 1
        }
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        }
        return tableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "EnableCell", for: indexPath) as! EnableUITableViewCell
                // TODO: add actual status here.
                cell.enableSwitch.isOn = false
                cell.switchCallback = { (switcher: UISwitch) -> Void in
                    print("enable switch clicked")
                    print(switcher.isOn)
                    // TODO: add change here.
                }
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "AboutCell", for: indexPath)
                return cell
            }
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProxyCell", for: indexPath) as! ProxyUITableViewCell
            // TODO: add actual status here
            cell.nameLabel.text = tableData[indexPath.row]
            cell.detailLabel.text = "detailLabel"
            cell.ruleImage.image = UIImage(named: "default")
            cell.proxySwitch.isOn = false
            cell.switchCallback = { (switcher: UISwitch) -> Void in
                print("proxy switch clicked")
                print(indexPath, switcher.isOn)
                // TODO: change it here
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Global"
        }
        return "Rules"
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if indexPath.section == 1 {
            let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { (uiTableViewRowAction, indexPath) in
                print("Delete Action")
                self.tableData.remove(at: indexPath.row)
                if self.tableData.count == 0 {
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
        if indexPath.section != 0 {
            return true
        }
        return false
    }
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section != 0{
            return true
        }
        return false
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        print(sourceIndexPath.row, destinationIndexPath.row)
        var itemToMove = tableData[sourceIndexPath.row]
        tableData.remove(at: sourceIndexPath.row)
        tableData.insert(itemToMove, at: destinationIndexPath.row)
        print(tableData)
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        if (indexPath.section != 0) || (indexPath.row != 0) {
            return true
        }
        return false
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.section != 0) || (indexPath.row != 0) {
            print(indexPath.row)
            tableView.deselectRow(at: indexPath, animated: true)
            // TODO: show a legal issue / About issue VC here
        }
    }
}
