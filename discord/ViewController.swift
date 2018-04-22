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
                let cell = tableView.dequeueReusableCell(withIdentifier: "EnableCell", for: indexPath)
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "AboutCell", for: indexPath)
                return cell
            }
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProxyCell", for: indexPath) as! ProxyUITableViewCell
            cell.nameLabel.text = tableData[indexPath.row]
            cell.ruleImage.image = UIImage(named: "default")
            return cell
        }
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Config"
        }
        return "Rules"
    }
}

