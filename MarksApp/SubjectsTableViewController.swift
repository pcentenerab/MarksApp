//
//  SubjectsTableViewController.swift
//  MarksApp
//
//  Created by Patricia on 14/05/2020.
//  Copyright © 2020 IWEB. All rights reserved.
//

import UIKit

class SubjectsTableViewController: UITableViewController {
    
    let subjectModel = (UIApplication.shared.delegate as! AppDelegate).subjectModel
    var userAccount: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.subjectModel.pending = [
            "Any": -1,
            "FTEL": [],
            "PROG": [],
            "CORE": [],
            "IWEB": []
        ]
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Solo se muestran las asignaturas en las que está matriculado el alumno
        return self.subjectModel.availableSubjects.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SubjectCell", for: indexPath) as! SubjectCell
        cell.acronym.text = self.subjectModel.availableSubjects[indexPath.row].acronimo
        cell.name.text = self.subjectModel.availableSubjects[indexPath.row].nombre
        return cell
    }
    
    @IBSegueAction func showSubject(_ coder: NSCoder) -> LoadingViewController? {
        let lvc = LoadingViewController(coder: coder)
        let row = tableView.indexPathForSelectedRow!.row
        lvc?.subject = subjectModel.availableSubjects[row]
        lvc?.userAccount = self.userAccount
        return lvc
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backItem = UIBarButtonItem()
        backItem.title = "Cancelar"
        navigationItem.backBarButtonItem = backItem
    }
    
    @IBAction func unwind(_ segue: UIStoryboardSegue) {

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if self.isMovingFromParent {
            print("Cierro sesión")
            self.subjectModel.resetToDefault()
        }
    }
}
