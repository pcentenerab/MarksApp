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
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
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
    
    @IBSegueAction func showSubject(_ coder: NSCoder) -> SubjectViewController? {
        let svc = SubjectViewController(coder: coder)
        let row = tableView.indexPathForSelectedRow!.row
        svc?.subject = subjectModel.availableSubjects[row]
        svc?.userAccount = self.userAccount
        return svc
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backItem = UIBarButtonItem()
        backItem.title = "Volver"
        navigationItem.backBarButtonItem = backItem // This will show in the next view controller being pushed
    }
    
    //@IBAction func unwind(_ segue: UIStoryboardSegue) {
        //if let sourcevc = segue.source as? SubjectViewController {
            // DIRIA QUE NO HACE FALTA self.subjectModel = sourcevc.subjectModel
          //  tableView.reloadData()
        //}
    //}
}
