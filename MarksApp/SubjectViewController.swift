//
//  SubjectViewController.swift
//  MarksApp
//
//  Created by Patricia on 14/05/2020.
//  Copyright © 2020 IWEB. All rights reserved.
//

import UIKit

class SubjectViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let subjectModel = (UIApplication.shared.delegate as! AppDelegate).subjectModel
    var subject: Subject!
    var userAccount: String!
    var isRegistered: Bool!
    var months: [String] = ["Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"]
    @IBOutlet weak var acronymLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var registeredLabel: UILabel!
    @IBOutlet weak var notRegisteredButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var registeringStateLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.acronymLabel.text = subject.acronimo
        self.nameLabel.text = "(\(subject.nombre))"
        if self.isRegistered {
            //Está matriculado
            self.notRegisteredButton.isHidden = true
            self.registeredLabel.isHidden = false
        } else {
            //No está matriculado
        }
        self.tableView.layer.masksToBounds = true
        self.tableView.layer.borderColor = UIColor( red: 35/255, green: 68/255, blue:93/255, alpha: 1.0 ).cgColor
        self.tableView.layer.borderWidth = 2.0
        
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let _ = self.subject.evaluaciones?.count {
            return self.subject.evaluaciones!.count
        }
        return 0
    }
     
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MarkCell", for: indexPath) as! MarkCell
        
        let evaluaciones = self.subject.evaluaciones
        let evaluacion = evaluaciones![indexPath.row]!
        cell.nameLabel.text = evaluacion.nombre
        cell.monthLabel.text = self.months[evaluacion.fecha-1]
        if self.isRegistered {
            let calificaciones = self.subject.calificaciones
            if calificaciones?[self.userAccount]?[indexPath.row]?.tipo != Subject.TipoNota.NP {
                //Ya tengo nota de esa prueba
                let nota = calificaciones?[self.userAccount]?[indexPath.row]
                cell.markLabel.text = String(describing: nota!.calificacion)
            } else {
                //Aún no hay nota de esa prueba
                cell.markLabel.text = "-"
            }
        } else {
            //No está matriculado
            cell.markLabel.text = "-"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let evaluaciones = self.subject.evaluaciones
        let evaluacion = evaluaciones![indexPath.row]!
        if self.isRegistered {
            let calificaciones = self.subject.calificaciones
            if calificaciones?.count != nil {
                if calificaciones?[self.userAccount]?[indexPath.row]?.tipo != Subject.TipoNota.NP {
                    //Ya tengo nota de esa prueba
                    let nota = calificaciones?[self.userAccount]?[indexPath.row]
                    let alert = UIAlertController(title: evaluacion.nombre, message: "El peso de esta prueba es del \(evaluacion.puntos)%. Tu nota es \(String(describing: nota!.calificacion)) (\(String(describing: nota!.tipo.rawValue))).", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    self.present(alert, animated: true)
                } else {
                    //Aún no hay nota de esa prueba
                    let alert = UIAlertController(title: evaluacion.nombre, message: "El peso de prueba parte es del \(evaluacion.puntos)%. Aún no has realizado la prueba.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    self.present(alert, animated: true)
                }
            } else {
                let alert = UIAlertController(title: evaluacion.nombre, message: "El peso de prueba parte es del \(evaluacion.puntos)%. Aún no has realizado la prueba.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true)
            }
        } else {
            let alert = UIAlertController(title: evaluacion.nombre, message: "El peso de prueba parte es del \(evaluacion.puntos)%. Matriculate para poder avanzar en la asignatura.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
    }
    @IBAction func register(_ sender: Any) {
        let alert = UIAlertController(title: "Introduce tus datos", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))

        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "Nombre(*)"
        })
        
        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "Correo electrónico(*)"
        })

        alert.addAction(UIAlertAction(title: "Matricularme", style: .default, handler: { action in

            if let name = alert.textFields?.first?.text, let email = alert.textFields?.last?.text {
                self.notRegisteredButton.isHidden = true
                self.registeringStateLabel.isHidden = false
                self.register(asignatura: self.acronymLabel.text!, account: self.userAccount, nombre: name, email: email)
            }
        }))

        self.present(alert, animated: true)
    }
    
    func register(asignatura: String, account: String, nombre: String, email: String) {
        self.subjectModel.pending["Any"] = -1
        self.subjectModel.setMatricula(asignatura: asignatura, account: account, nombre: nombre, email: email)
        Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { timer in
            self.registeringStateLabel.text = self.subjectModel.registeringState
            if (self.subjectModel.registeringState == "Fin.") {
                timer.invalidate()
                self.updateSubject()
            }
        }
    }
    
    func updateSubject() {
        let index = self.subjectModel.subjectsAcronyms.firstIndex(of: self.subject.acronimo)
        if (self.subjectModel.availableSubjects[index!].matriculas == nil && (self.subjectModel.availableSubjects[index!].matriculasLength == nil || self.subjectModel.availableSubjects[index!].matriculasLength == 0)) {
            //Aún no había alumnos. Inicializo y creo
            var matriculas: [String] = []
            matriculas.append(self.userAccount)
            self.subjectModel.availableSubjects[index!].matriculas = matriculas
            self.subjectModel.availableSubjects[index!].matriculasLength = 1
        } else {
            //Ya había algún alumno. Añado
            var matriculas = self.subjectModel.availableSubjects[index!].matriculas
            matriculas?.append(self.userAccount)
            self.subjectModel.availableSubjects[index!].matriculas = matriculas
            self.subjectModel.availableSubjects[index!].matriculasLength = matriculas?.count
        }
        self.subject = self.subjectModel.availableSubjects[index!]
        self.isRegistered = true
        self.registeringStateLabel.isHidden = true
        self.registeredLabel.isHidden = false
        self.subjectModel.registeringState = ""
        print("Fin de la actualización")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.subjectModel.loadSubjectState = "Consultando matrículas..."
        self.subjectModel.pending["Any"] = -1
        self.subjectModel.pending[self.acronymLabel.text!] = []
        performSegue(withIdentifier: "Unwind To Subjects", sender: self)
    }
}
