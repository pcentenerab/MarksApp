//
//  LoadingViewController.swift
//  MarksApp
//
//  Created by Patricia on 18/05/2020.
//  Copyright © 2020 IWEB. All rights reserved.
//

import UIKit

class LoadingViewController: UIViewController {
    
    let subjectModel = (UIApplication.shared.delegate as! AppDelegate).subjectModel
    var subject: Subject!
    var userAccount: String!
    var isRegistered: Bool!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var stateLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(self.subject)
        self.getMatriculas()
        
    }
    
    func getMatriculas() {
        if self.subject.matriculasLength == nil {
            print(self.subject.matriculasLength)
            self.subjectModel.call(asignatura: self.subject.acronimo, atributo: "matriculasLength", account: self.userAccount!)
            Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { timer in
                self.stateLabel.text = self.subjectModel.loadSubjectState
                if (self.subjectModel.loadSubjectState == "Cargando evaluaciones...") {
                    timer.invalidate()
                    let index = self.subjectModel.subjectsAcronyms.firstIndex(of: self.subject.acronimo)
                    self.subject = self.subjectModel.availableSubjects[index!]
                    self.getEvaluaciones()
                }
            }
        } else {
            self.subjectModel.loadSubjectState = "Cargando evaluaciones..."
            self.getEvaluaciones()
        }
    }
    
    func getEvaluaciones() {
        if self.subject.evaluacionesLength == nil {
            self.subjectModel.call(asignatura: self.subject.acronimo, atributo: "evaluacionesLength", account: self.userAccount!)
            Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { timer in
                self.stateLabel.text = self.subjectModel.loadSubjectState
                if (self.subjectModel.loadSubjectState == "Cargando calificaciones...") {
                    timer.invalidate()
                    let index = self.subjectModel.subjectsAcronyms.firstIndex(of: self.subject.acronimo)
                    self.subject = self.subjectModel.availableSubjects[index!]
                    self.getNotas()
                }
            }
        } else {
            self.subjectModel.loadSubjectState = "Cargando calificaciones..."
            self.getNotas()
        }
    }
    
    func getNotas() {
        if self.subject.matriculasLength != 0 {
            //Hay algún matriculado
            if (self.subject.matriculas?.contains(self.userAccount))! {
                //Está matriculado
                self.isRegistered = true
                if self.subject.evaluacionesLength != 0 {
                    //Hay evaluaciones, pido las notas
                    let calificaciones = self.subject.calificaciones
                    if let calificacionesAlumno = calificaciones?[self.userAccount] {
                        if self.subject.evaluacionesLength != calificacionesAlumno.keys.count {
                            for i in 0...self.subject.evaluacionesLength!-1 {
                                self.subjectModel.callWithParam(asignatura: self.subject.acronimo, atributo: "getNota", param: "\(i)", account: self.userAccount!)
                            }
                            Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { timer in
                                self.stateLabel.text = self.subjectModel.loadSubjectState
                                if (self.subjectModel.loadSubjectState == "Fin.") {
                                    timer.invalidate()
                                    let index = self.subjectModel.subjectsAcronyms.firstIndex(of: self.subject.acronimo)
                                    self.subject = self.subjectModel.availableSubjects[index!]
                                    self.performSegue(withIdentifier: "Show Subject", sender: self)
                                }
                            }
                        } else {
                            self.subjectModel.loadSubjectState = "Fin."
                            self.performSegue(withIdentifier: "Show Subject", sender: self)
                        }
                    } else {
                        for i in 0...self.subject.evaluacionesLength!-1 {
                            self.subjectModel.callWithParam(asignatura: self.subject.acronimo, atributo: "getNota", param: "\(i)", account: self.userAccount!)
                        }
                        Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { timer in
                            self.stateLabel.text = self.subjectModel.loadSubjectState
                            if (self.subjectModel.loadSubjectState == "Fin.") {
                                timer.invalidate()
                                let index = self.subjectModel.subjectsAcronyms.firstIndex(of: self.subject.acronimo)
                                self.subject = self.subjectModel.availableSubjects[index!]
                                self.performSegue(withIdentifier: "Show Subject", sender: self)
                            }
                        }
                    }
                    
                } else {
                    //No hay evaluaciones, avanzo
                    self.performSegue(withIdentifier: "Show Subject", sender: self)
                }
            } else {
                //No está matriculado, avanzo
                self.isRegistered = false
                self.performSegue(withIdentifier: "Show Subject", sender: self)
            }
        } else {
            //No hay matriculados, avanzo
            self.isRegistered = false
            self.performSegue(withIdentifier: "Show Subject", sender: self)
        }
    }

    @IBSegueAction func showSubject(_ coder: NSCoder) -> SubjectViewController? {
        self.activityIndicatorView.stopAnimating()
        let svc = SubjectViewController(coder: coder)
        svc?.subject = self.subject
        svc?.userAccount = self.userAccount
        svc?.isRegistered = self.isRegistered
        return svc
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backItem = UIBarButtonItem()
        backItem.title = "Volver"
        navigationItem.backBarButtonItem = backItem
    }
    

}
