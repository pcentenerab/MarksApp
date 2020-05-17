//
//  FirstViewController.swift
//  MarksApp
//
//  Created by Belén on 17/05/2020.
//  Copyright © 2020 IWEB. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {
    
    let subjectModel = (UIApplication.shared.delegate as! AppDelegate).subjectModel
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var restartButton: UIButton!
    @IBOutlet weak var stateLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { timer in
            self.stateLabel.text = self.subjectModel.state
            if (self.subjectModel.state == "Fin de la configuración.") {
                timer.invalidate()
                self.performSegue(withIdentifier: "Start App", sender: self)
            }
        }
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.activityIndicatorView.stopAnimating()
        exit(0)
    }
    
    @IBAction func restart(_ sender: Any) {
        self.activityIndicatorView.stopAnimating()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "FirstViewController")
        self.present(vc, animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
