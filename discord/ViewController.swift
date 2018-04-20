//
//  ViewController.swift
//  discord
//
//  Created by Ke Li on 4/19/18.
//  Copyright © 2018 Ke Li. All rights reserved.
//

import UIKit

class ViewController: UIViewController {


    @IBAction func onAddNewProxyButtonClicked(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "QR Code", style: .default) { _ in
            print("QR Code")
        })
        
        alert.addAction(UIAlertAction(title: "Input Manually", style: .default) { _ in
            print("Input Manually")
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            print("Cancel")
        })
        
        present(alert, animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

