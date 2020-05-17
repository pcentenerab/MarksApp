//
//  RegistrationViewController.swift
//  MarksApp
//
//  Created by Belén on 14/05/2020.
//  Copyright © 2020 IWEB. All rights reserved.
//

import UIKit

class RegistrationViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var availableSubjects: [Subject]!
    var registeredSubjects: [Subject]!
    var notRegisteredSubjects: [Subject]! = []
    var pickerData: [String]! = []
    @IBOutlet weak var subjectPickerView: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Connect data:
        self.subjectPickerView.delegate = self
        self.subjectPickerView.dataSource = self
        
        for i in 0...self.availableSubjects.count-1 {
            let subject = self.availableSubjects[i]
            let isContained = self.registeredSubjects.contains { element in
                return element.acronimo == subject.acronimo ? true : false
            }
            if !isContained {
                self.notRegisteredSubjects.append(subject)
                self.pickerData.append(subject.acronimo)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
           super.didReceiveMemoryWarning()
           // Dispose of any resources that can be recreated.
       }

       // Number of columns of data
       func numberOfComponents(in pickerView: UIPickerView) -> Int {
           return 1
       }
       
       // The number of rows of data
       func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.pickerData.count
       }
       
       // The data to return fopr the row and component (column) that's being passed in
       func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
           return self.pickerData[row]
       }
    
    @IBAction func send(_ sender: Any) {
        let i = self.subjectPickerView.selectedRow(inComponent: 0)
        // Añadir alumno a esa asignatura
        self.registeredSubjects.append(self.notRegisteredSubjects[i])
        performSegue(withIdentifier: "Unwind To Subjects", sender: self)
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
