//
//  ViewController.swift
//  MarksApp
//
//  Created by Patricia on 14/05/2020.
//  Copyright © 2020 IWEB. All rights reserved.
//

import UIKit
import WebKit

class LoginViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var addressPickerView: UIPickerView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    let subjectModel = (UIApplication.shared.delegate as! AppDelegate).subjectModel
    var webView: WKWebView!
    
    var accounts = [
        "0xc8b3c04f40aDBb94FeD606B185fcBDD87180Fc8F",
        "0xF511e9DB20963cA9CCd7C3b2464A5CCF53B6f64d",
        "0x7F8a9e883664144d0F574a2b8b446d4cf3E29Ef2",
        "0xdb289442441c73e82c3509F327cBF0aDa12656Be",
        "0xd20bD57C18017615E8bFf55B8a45e228c6767315",
        "0xCE1751C4eB421F026Fc638ECd8516cF18B7D5BaF",
        "0x1eb7612e113Ed3eEa5C2259681df793f229cE273",
        "0x8e7A26F2Af136DcA0fdbEdB9613D713879Ec6fC8",
        "0xC3F9FA004066aeE9129d2c44cB35CB25Eb4e7249"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addressPickerView.dataSource = self
        self.addressPickerView.delegate = self
        //self.activityIndicatorView.stopAnimating()
    }
    
    // Number of columns of data
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
     return self.accounts.count
    }
    
    // The data to return for the row that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.accounts[row]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.addressPickerView.selectRow(0, inComponent: 0, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backItem = UIBarButtonItem()
        backItem.title = "Cerrar sesión"
        navigationItem.backBarButtonItem = backItem // This will show in the next view controller being pushed
    }
    
    @IBSegueAction func login(_ coder: NSCoder) -> SubjectsTableViewController? {
        let stvc = SubjectsTableViewController(coder: coder)
        stvc?.userAccount = accounts[self.addressPickerView.selectedRow(inComponent: 0)]
        return stvc
    }
}
