//
//  ViewController.swift
//  discord
//
//  Created by Ke Li on 4/19/18.
//  Copyright © 2018 Ke Li. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var tableData: [String] = ["Proxy 1","Proxy 2","Proxy 3"]

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
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            print("Cancel")
        })
        
        present(alert, animated: true)
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
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        // TODO: Load stored data here
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
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
            let detailAction = UITableViewRowAction(style: .normal, title: "Detail") { (uiTableViewRowAction, indexPath) in
                print("Edit Action")
                self.tableData[indexPath.row] = "updated" // TODO: change it to switch here.
                tableView.reloadRows(at: [indexPath], with: .fade)
                // TODO: updateStored()
            }
            let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { (uiTableViewRowAction, indexPath) in
                print("Delete Action")
                self.tableData.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                // TODO: updateStored()
            }
            return [deleteAction, detailAction]
        }
        return []
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        if (indexPath.section == 0) && (indexPath.row != 0) {
            return true
        }
        return false
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.section == 0) || (indexPath.row != 0) {
            tableView.deselectRow(at: indexPath, animated: true)
            // TODO: show a legal issue / About issue VC here
        }
    }
}

