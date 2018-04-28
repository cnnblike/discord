//
//  ManualViewController.swift
//  discord
//
//  Created by Ke Li on 4/27/18.
//  Copyright © 2018 Ke Li. All rights reserved.
//

import UIKit

class ManualViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    @IBAction func onBackButtonClicked(_ sender: Any) {
        if let _ = self.presentingViewController {
            self.presentingViewController!.dismiss(animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.textView.setContentOffset(CGPoint.zero, animated: false)
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
