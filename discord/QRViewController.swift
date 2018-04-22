//
//  QRViewController.swift
//  discord
//
//  Created by Ke Li on 4/21/18.
//  Copyright © 2018 Ke Li. All rights reserved.
//

import UIKit

class QRViewController: ViewController {

    @IBAction func onBackButtonClicked(_ sender: Any) {
        if let _ = self.presentingViewController {
            if let tempViewController = self.presentingViewController as? ViewController {
                tempViewController.callbackFromOtherVC()
            }
            self.presentingViewController!.dismiss(animated: true, completion: nil)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

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
