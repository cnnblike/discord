//
//  DetailViewController.swift
//  discord
//
//  Created by Ke Li on 4/20/18.
//  Copyright © 2018 Ke Li. All rights reserved.
//

import UIKit

class DetailViewController: ViewController {

    var itemString:String?
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
