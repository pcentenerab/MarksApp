//
//  SubjectModel.swift
//  MarksApp
//
//  Created by Patricia on 14/05/2020.
//  Copyright © 2020 IWEB. All rights reserved.
//

import Foundation
import WebKit

struct Subject: Codable {
    // address del contrato desplegado
    var address: String?
    
    // address del profesor que ha desplegado el contrato
    var profesor: String?
    
    var acronimo: String
    var nombre: String
    var curso: String?
    
    struct Evaluacion: Codable, Equatable {
        var nombre: String
        var fecha: Int
        var puntos: Int
    }
    
    var evaluaciones: [Evaluacion?]?
    var evaluacionesLength: Int?
    
    struct DatosAlumno: Codable {
        var nombre: String
        var email: String
        var password: String
    }
    // le doy la dirección del alumno y me devuelve sus datos
    var datosAlumno: [String: DatosAlumno?]?
    // direcciones de los alumnos matriculados
    var matriculas: [String]?
    var matriculasLength: Int?
    
    enum TipoNota: String, Codable {
        case NP
        case Normal
        case MH
    }
    
    struct Nota: Codable, Equatable {
        var tipo: TipoNota
        var calificacion: Int
    }
    // le doy la dirección del alumno y el índice de la evaluación y me devuelve la nota
    var calificaciones: [String: [Int:Nota]]?
}
/*
struct DatosAlumnoResponse: Codable {
    var args: [String:String]
    var fnIndex: Int
    var value: [String: String]
}
*/
let MessageHandler = "didFetchValue"

class SubjectModel: UIViewController {
    
    var setupState: String!
    var loadSubjectState: String!
    var registeringState: String!
    var availableSubjects = [Subject]()
    var registeredSubjects = [Subject]()
    var subjectsAcronyms: [String] = ["FTEL", "PROG", "CORE", "IWEB"]
    var subjectNames: [String] = ["Fundamentos de los Sistemas Telemáticos", "Programación", "Computación en Red", "Ingeniería Web"]
    var webView: WKWebView!
    var script: String!
    var lastMessages: [String]!
    // asignatura -> atributo -> clave o array/dicc
    var keys: [String:[String:Any]]!
    var pending: [String:Any]!
    var actualUserAccount: String!
    var registerCount: Int!
    var stackId: Int!
    var registeringTxHash: String!
    
    func setup() -> Bool {
        //Importo todos los ficheros necesarios
        self.setupState = "Importando contratos..."
        let config = WKWebViewConfiguration()
        
        let contentController = WKUserContentController()
        
        let drizzleScriptPath = Bundle.main.path(forResource: "packedDrizzle", ofType: "js", inDirectory: "JavascriptCode")
        let drizzleScriptString = try! String(contentsOfFile: drizzleScriptPath!, encoding: .utf8)
        let drizzleFetchValueScript = WKUserScript(source: drizzleScriptString, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        contentController.addUserScript(drizzleFetchValueScript)
        print("Drizzle importado")
        
        let FTELScriptPath = Bundle.main.path(forResource: "FTEL", ofType: "js", inDirectory: "JavascriptCode")
        let FTELScriptString = try! String(contentsOfFile: FTELScriptPath!, encoding: .utf8)
        let FTELFetchValueScript = WKUserScript(source: FTELScriptString, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        contentController.addUserScript(FTELFetchValueScript)
        print("Contrato FTEL importado")
        
        let PROGScriptPath = Bundle.main.path(forResource: "PROG", ofType: "js", inDirectory: "JavascriptCode")
        let PROGScriptString = try! String(contentsOfFile: PROGScriptPath!, encoding: .utf8)
        let PROGFetchValueScript = WKUserScript(source: PROGScriptString, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        contentController.addUserScript(PROGFetchValueScript)
        print("Contrato PROG importado")
        
        let COREScriptPath = Bundle.main.path(forResource: "CORE", ofType: "js", inDirectory: "JavascriptCode")
        let COREScriptString = try! String(contentsOfFile: COREScriptPath!, encoding: .utf8)
        let COREFetchValueScript = WKUserScript(source: COREScriptString, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        contentController.addUserScript(COREFetchValueScript)
        print("Contrato CORE importado")
        
        let IWEBScriptPath = Bundle.main.path(forResource: "IWEB", ofType: "js", inDirectory: "JavascriptCode")
        let IWEBScriptString = try! String(contentsOfFile: IWEBScriptPath!, encoding: .utf8)
        let IWEBFetchValueScript = WKUserScript(source: IWEBScriptString, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        contentController.addUserScript(IWEBFetchValueScript)
        print("Contrato IWEB importado")

        contentController.add(self, name: MessageHandler)
        config.userContentController = contentController
        
        self.webView = WKWebView(frame: CGRect.init(), configuration: config)
        
        let scriptPath = Bundle.main.path(forResource: "app", ofType: "js", inDirectory: "JavascriptCode")!
        self.script = try! String(contentsOfFile: scriptPath, encoding: .utf8)
        self.webView.load(URLRequest(url: URL(fileURLWithPath: scriptPath)))
        
        self.setupState = "Importando lógica Javascript..."

        print("¿Cargando app.js?")
        print(self.webView.isLoading ? "Sí. Hay que esperar" : "Ya he terminado!")
        while (self.webView.isLoading) {
            CFRunLoopRunInMode(CFRunLoopMode.defaultMode, 0.1, false)
        }
        print(self.webView.isLoading ? "Sí. Hay que esperar" : "Ya he terminado!")
        print("")
        
        self.setupState = "Configurando Drizzle..."

        self.webView.evaluateJavaScript(self.script+"setup()", completionHandler: nil)
        self.lastMessages = ["Primer mensaje"]
        self.loadSubjectState = "Consultando matrículas..."
        self.registeringState = ""
        self.actualUserAccount = ""
        self.stackId = 0
        self.registeringTxHash = ""
        self.keys = [
            "FTEL": [
                "profesor":"",
                "acronimo":"",
                "nombre":"",
                "curso":"",
                "evaluaciones":[],
                "datosAlumno":[],
                "matriculas":[],
                "getNota":[:],
                "matriculasLength":"",
                "evaluacionesLength":""
            ],
            "PROG": [
                "profesor":"",
                "acronimo":"",
                "nombre":"",
                "curso":"",
                "evaluaciones":[],
                "datosAlumno":[],
                "matriculas":[],
                "getNota":[:],
                "matriculasLength":"",
                "evaluacionesLength":""
            ],
            "CORE": [
                "profesor":"",
                "acronimo":"",
                "nombre":"",
                "curso":"",
                "evaluaciones":[],
                "datosAlumno":[],
                "matriculas":[],
                "getNota":[:],
                "matriculasLength":"",
                "evaluacionesLength":""
            ],
            "IWEB": [
                "profesor":"",
                "acronimo":"",
                "nombre":"",
                "curso":"",
                "evaluaciones":[],
                "datosAlumno":[],
                "matriculas":[],
                "getNota":[:],
                "matriculasLength":"",
                "evaluacionesLength":""
            ]
        ]
        self.pending = [
            "Any": -1,
            "FTEL": [],
            "PROG": [],
            "CORE": [],
            "IWEB": []
        ]

        //añado subjects por defecto
        for i in 0...(self.subjectsAcronyms.count-1) {
            self.availableSubjects.append(Subject(acronimo: subjectsAcronyms[i], nombre: subjectNames[i]))
        }
        return true
    }
    
    func resetToDefault() {
        self.lastMessages = ["Primer mensaje"]
        self.loadSubjectState = "Consultando matrículas..."
        self.registeringState = ""
        self.actualUserAccount = ""
        self.stackId = 0
        self.registeringTxHash = ""
        self.keys = [
            "FTEL": [
                "profesor":"",
                "acronimo":"",
                "nombre":"",
                "curso":"",
                "evaluaciones":[],
                "datosAlumno":[],
                "matriculas":[],
                "getNota":[:],
                "matriculasLength":"",
                "evaluacionesLength":""
            ],
            "PROG": [
                "profesor":"",
                "acronimo":"",
                "nombre":"",
                "curso":"",
                "evaluaciones":[],
                "datosAlumno":[],
                "matriculas":[],
                "getNota":[:],
                "matriculasLength":"",
                "evaluacionesLength":""
            ],
            "CORE": [
                "profesor":"",
                "acronimo":"",
                "nombre":"",
                "curso":"",
                "evaluaciones":[],
                "datosAlumno":[],
                "matriculas":[],
                "getNota":[:],
                "matriculasLength":"",
                "evaluacionesLength":""
            ],
            "IWEB": [
                "profesor":"",
                "acronimo":"",
                "nombre":"",
                "curso":"",
                "evaluaciones":[],
                "datosAlumno":[],
                "matriculas":[],
                "getNota":[:],
                "matriculasLength":"",
                "evaluacionesLength":""
            ]
        ]
        self.pending = [
            "Any": -1,
            "FTEL": [],
            "PROG": [],
            "CORE": [],
            "IWEB": []
        ]
        self.availableSubjects = []
        //añado subjects por defecto
        for i in 0...(self.subjectsAcronyms.count-1) {
            self.availableSubjects.append(Subject(acronimo: subjectsAcronyms[i], nombre: subjectNames[i]))
        }
    }
    
    func callWithParam(asignatura: String, atributo: String, param: String, account: String) {
        self.pending["Any"] = 0
        self.webView.evaluateJavaScript(self.script+"getKeyWithParam(\"\(asignatura)\", \"\(atributo)\", \"\(param)\", \"\(account)\")", completionHandler: nil)
    }
    
    func call(asignatura: String, atributo: String, account: String) {
        self.pending["Any"] = 0
        self.webView.evaluateJavaScript(self.script+"getKey(\"\(asignatura)\", \"\(atributo)\", \"\(account)\")", completionHandler: nil)
    }
    
    func setMatricula(asignatura: String, account: String, nombre: String, email: String) {
        self.pending["Any"] = -1
        self.registerCount = 0
        self.registeringState = "Solicitando matriculación..."
        self.webView.evaluateJavaScript(self.script+"setMatricula(\"\(asignatura)\", \"\(account)\", \"\(nombre)\", \"\(email)\")", completionHandler: nil)
    }
    //No usado
    func getValue(asignatura: String, atributo: String, clave: String) {
        self.webView.evaluateJavaScript(self.script+"getValue(\"\(asignatura)\", \"\(atributo)\", \"\(clave)\")", completionHandler: nil)
    }
    
    func readTransactionTxHash(stackId: Int) {
        self.webView.evaluateJavaScript(self.script+"readTransactionTxHash(\(stackId))", completionHandler: nil)
    }
    
    func readTransactionState(txHash: String) {
        self.webView.evaluateJavaScript(self.script+"readTransactionState(\"\(txHash)\")", completionHandler: nil)
    }
}

extension SubjectModel: WKScriptMessageHandler, WKNavigationDelegate {
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        let body = message.body as! String

        if self.lastMessages.count == 1 && body.localizedStandardContains("Estado actualizado") {
            //Primer mensaje de Estado actualizado. Solo ocurre una vez.
            self.lastMessages.append(body)
            self.setupState = "Fin de la configuración."
            print(body)
        } else if body.localizedStandardContains("Clave") {
            print(body)
            //He hecho cacheCall y me llega la clave
            let array = body.split(separator: " ")
            let asignatura = String(array[1])
            let atributo = String(array[3])
            var clave = ""
            var param = ""
            if body.localizedStandardContains("Parámetro/s") {
                //Llamada con parámetros
                param = String(array[5])
                clave = String(array[7])
            } else {
                //Llamada sin parámetros
                clave = String(array[5])
            }
            var pending = (self.pending[asignatura] as? [Int])
            pending?.append(self.lastMessages.count)
            self.pending[asignatura] = pending
            self.lastMessages.append(body)
            if atributo == "evaluaciones" || atributo == "matriculas" || atributo == "datosAlumno" {
                //Almacenan arrays
                let count = (self.keys![asignatura]![atributo] as! [String]).count
                if count == Int(param)! {
                    //Aún no tengo la clave, la almaceno
                    var array = (self.keys![asignatura]![atributo] as! [String])
                    array.insert(clave, at: (Int(param))!)
                    self.keys![asignatura]![atributo] = array
                } else {
                    //Ya tengo la clave
                    print("especiales")
                    print(self.pending["Any"] as Any)
                    print(self.pending[asignatura] as Any)
                    let array = (self.keys![asignatura]![atributo] as! [String])
                    print(array)
                }
            } else if atributo == "getNota" {
                //Almacena diccionario
                let account = self.actualUserAccount
                if let count = (self.keys![asignatura]![atributo] as! [String:[String]])[account!]?.count {
                    if count == Int(param)! {
                        //Aún no tengo la clave, la almaceno
                        var dict = (self.keys![asignatura]![atributo] as! [String:[String]])
                        dict[account!]?.append(clave)
                        self.keys![asignatura]![atributo] = dict
                    } else {
                        //Ya tengo la clave
                        print("especiales")
                        print(self.pending["Any"] as Any)
                        print(self.pending[asignatura] as Any)
                        let array = (self.keys![asignatura]![atributo] as! [String:[String]])
                        print(array)
                    }
                } else {
                    //Inicaliazo y añado
                    var dict: Dictionary<String,[String]> = [:]
                    dict[account!] = []
                    dict[account!]?.insert(clave, at: Int(param)!)
                    self.keys![asignatura]![atributo] = dict
                }
            } else {
                //Almacenan strings
                if (self.keys![asignatura]![atributo] as? String) == "" {
                    //Aún no tengo la clave, la almaceno
                    self.keys![asignatura]![atributo] = clave
                } else {
                    //Ya tengo la clave, por lo que no hago nada
                    print("normales")
                    print(self.pending["Any"] as Any)
                    print(self.pending[asignatura] as Any)
                    let array = self.keys![asignatura]![atributo]
                    print(array as Any)
                }
            }
        } else if body.localizedStandardContains("Datos") {
            print(body)
            self.lastMessages.append(body)
            let array = body.split(separator: " ")
            let asignatura = String(array[1])
            let atributo = String(array[3])
            let datos = String(array[5])
            if datos == "undefined" {
                //No quito el pending para que siga pidiendo
            } else {
                //Ya me ha llegado
                var pending = self.pending[asignatura] as? [Int]
                if pending?.count != 0 {
                    let pendingIndex = (pending?.first)!
                    let pendingMessage = self.lastMessages[pendingIndex]
                    let arrayEsperado = pendingMessage.split(separator: " ")
                    let atributoEsperado = String(arrayEsperado[3])
                    if atributo == atributoEsperado {
                        if atributo == "matriculasLength" {
                            pending?.removeFirst()
                            self.pending[asignatura] = pending
                            let long = Int(datos)!
                            let index = self.subjectsAcronyms.firstIndex(of: asignatura)
                            self.availableSubjects[index!].matriculasLength = long
                            if long != 0 {
                                for i in 0...long-1 {
                                    self.callWithParam(asignatura: asignatura, atributo: "matriculas", param: String(i), account: self.actualUserAccount)
                                }
                            } else {
                                self.availableSubjects[index!].matriculasLength = long
                                self.pending[asignatura] = []
                                self.loadSubjectState = "Cargando evaluaciones..."
                            }
                        } else if atributo == "evaluacionesLength" {
                            pending?.removeFirst()
                            self.pending[asignatura] = pending
                            let long = Int(datos)!
                            let index = self.subjectsAcronyms.firstIndex(of: asignatura)
                            self.availableSubjects[index!].evaluacionesLength = long
                            if long != 0 {
                                for i in 0...long-1 {
                                    self.callWithParam(asignatura: asignatura, atributo: "evaluaciones", param: String(i), account: self.actualUserAccount)
                                }
                            } else {
                                self.availableSubjects[index!].evaluacionesLength = long
                                self.pending[asignatura] = []
                                self.loadSubjectState = "Cargando calificaciones..."
                            }
                        } else if atributo == "matriculas" {
                            //Habia parametro y es un número
                            let index = self.subjectsAcronyms.firstIndex(of: asignatura)
                            if self.availableSubjects[index!].matriculas == nil {
                                //Inicializo y añado
                                //print("He inicializado y añadido")
                                self.availableSubjects[index!].matriculas = []
                                self.availableSubjects[index!].matriculas?.append(datos)
                                pending?.removeFirst()
                                self.pending[asignatura] = pending
                            } else {
                                //Ya está creado, compruebo que no me haya llegado ya ese dato y añado
                                let param = Int(arrayEsperado[5])
                                if self.availableSubjects[index!].matriculas?.count == param && !(self.availableSubjects[index!].matriculas?.contains(datos))! {
                                    //Aún no lo tenía, lo meto
                                    self.availableSubjects[index!].matriculas?.append(datos)
                                    pending?.removeFirst()
                                    self.pending[asignatura] = pending
                                    if pending?.count != 0 {
                                        
                                    } else {
                                        //print("Ya no quedan más")
                                    }
                                    //Miro si era el último dato que me faltaba
                                    if self.availableSubjects[index!].matriculas?.count == self.availableSubjects[index!].matriculasLength {
                                        print("Fin de las matriculas")
                                        print(self.availableSubjects[index!].matriculas!)
                                        self.loadSubjectState = "Cargando evaluaciones..."
                                    }
                                } else {
                                    //print("Ya me había llegado antes")
                                    self.webView.evaluateJavaScript(self.script+"getValue(\"\(asignatura)\", \"\(atributo)\", \"\((self.keys[asignatura]![atributo] as! [String])[param!])\")", completionHandler: nil)
                                }
                            }
                            if self.availableSubjects[index!].matriculas?.count == self.availableSubjects[index!].matriculasLength {
                                print("Fin de las matriculas")
                                print(self.availableSubjects[index!].matriculas!)
                                self.loadSubjectState = "Cargando evaluaciones..."
                            }
                        } else if atributo == "evaluaciones" {
                            //Había parámetro y son los datos de la evaluación consultada
                            var nombre = datos
                            var fecha = Int(array[6])
                            var puntos = Int(array[7])
                            if nombre == "Parcial" {
                                //Sobrescribo con los valores reales
                                nombre = datos+" "+String(array[6])
                                fecha = Int(array[7])
                                puntos = Int(array[8])
                            }
                            let evalObject = Subject.Evaluacion(nombre: nombre, fecha: fecha!, puntos: puntos!)
                            let index = self.subjectsAcronyms.firstIndex(of: asignatura)
                            if self.availableSubjects[index!].evaluaciones == nil {
                                //Inicializo y añado
                                self.availableSubjects[index!].evaluaciones = []
                                self.availableSubjects[index!].evaluaciones?.append(evalObject)
                                pending?.removeFirst()
                                self.pending[asignatura] = pending
                            } else {
                                //Ya está creado, compruebo que no me haya llegado ya ese dato y añado
                                let param = Int(arrayEsperado[5])
                                if self.availableSubjects[index!].evaluaciones?.count == param && !(self.availableSubjects[index!].evaluaciones?.contains(evalObject))! {
                                    //Aún no lo tenía, lo meto
                                    self.availableSubjects[index!].evaluaciones?.append(evalObject)
                                    pending?.removeFirst()
                                    self.pending[asignatura] = pending
                                    if pending?.count != 0 {
                                    } else {
                                        //print("Ya no quedan más")
                                    }
                                    //Miro si era el último dato que me faltaba
                                    if self.availableSubjects[index!].evaluaciones?.count == self.availableSubjects[index!].evaluacionesLength {
                                        print("Fin de las evaluaciones")
                                        print(self.availableSubjects[index!].evaluaciones!)
                                        self.loadSubjectState = "Cargando calificaciones..."
                                    }
                                } else {
                                    //print("Ya me había llegado antes")
                                    self.webView.evaluateJavaScript(self.script+"getValue(\"\(asignatura)\", \"\(atributo)\", \"\((self.keys[asignatura]![atributo] as! [String])[param!])\")", completionHandler: nil)
                                }
                            }
                        } else if atributo == "getNota" {
                            //Había parámetro y son los datos de una evaluación
                            let tipo = Int(datos)
                            let calificacion = Int(array[6])
                            var tipoNota = Subject.TipoNota.NP
                            switch tipo {
                            case 0:
                                tipoNota = Subject.TipoNota.NP
                            case 1:
                                tipoNota = Subject.TipoNota.Normal
                            case 2:
                                tipoNota = Subject.TipoNota.MH
                            default:
                                tipoNota = Subject.TipoNota.NP
                            }
                            let claveObtenida = String(array[8])
                            let clavesGetNota = (self.keys![asignatura]![atributo] as! [String:[String]])[self.actualUserAccount]
                            let evalObtenida = clavesGetNota?.firstIndex(of: claveObtenida)
                            let notaObject = Subject.Nota(tipo: tipoNota, calificacion: calificacion!)
                            let index = self.subjectsAcronyms.firstIndex(of: asignatura)
                            let account = self.actualUserAccount
                            let evalIndex = Int(arrayEsperado[5])
                            
                            if self.availableSubjects[index!].calificaciones == nil {
                                //No hay notas de nadie
                                //Inicializo y añado
                                self.availableSubjects[index!].calificaciones = [:]
                                self.availableSubjects[index!].calificaciones![account!] = [evalIndex!:notaObject]
                                pending?.removeFirst()
                                self.pending[asignatura] = pending
                            } else {
                                //Ya hay algo pero puede que de otro alumno, compruebo
                                if (self.availableSubjects[index!].calificaciones?.keys.contains(account!))! {
                                    //Hay alguna nota ya del alumno
                                    //Compruebo que no me haya llegado la misma
                                    if evalIndex != evalObtenida {
                                        //No era la que esperaba
                                        print("Me ha llegado repetido")
                                        self.webView.evaluateJavaScript(self.script+"getValue(\"\(asignatura)\", \"\(atributo)\", \"\(String(describing: (self.keys[asignatura]![atributo] as! [String:[String]])[account!]![evalIndex!]))\")", completionHandler: nil)
                                    } else {
                                        //ERA ESA. No tengo dato para esa evaluación, la guardo
                                        self.availableSubjects[index!].calificaciones![account!]![evalIndex!] = notaObject
                                        pending?.removeFirst()
                                        self.pending[asignatura] = pending
                                    }
                                } else {
                                    //Solo hay notas de otros alumnos. Inicializo y añado
                                    self.availableSubjects[index!].calificaciones![account!] = [:]
                                    self.availableSubjects[index!].calificaciones![account!]![evalIndex!] = notaObject
                                    pending?.removeFirst()
                                    self.pending[asignatura] = pending
                                }
                            }
                            if self.availableSubjects[index!].evaluacionesLength == self.availableSubjects[index!].calificaciones?[account!]!.keys.count {
                                print("Fin de las notas")
                                print(self.availableSubjects[index!].calificaciones as Any)
                                self.loadSubjectState = "Fin."
                            }
                        } else {
                            print("No sé de qué me hablas bro")
                        }
                        if (self.pending["FTEL"] as! [Int]).count == 0 && (self.pending["PROG"] as! [Int]).count == 0 && (self.pending["CORE"] as! [Int]).count == 0 && (self.pending["IWEB"] as! [Int]).count == 0 {
                            self.pending["Any"] = -1
                        }
                    }
                } else {
                    print("No hay mensajes pendientes")
                    if atributo ==  "matriculasLength" {
                        let long = Int(datos)!
                        let index = self.subjectsAcronyms.firstIndex(of: asignatura)
                        self.availableSubjects[index!].matriculasLength = long
                        self.pending[asignatura] = []
                        self.loadSubjectState = "Cargando evaluaciones..."
                    } else if atributo == "evaluacionesLength" {
                        let long = Int(datos)!
                        let index = self.subjectsAcronyms.firstIndex(of: asignatura)
                        self.availableSubjects[index!].evaluacionesLength = long
                        self.pending[asignatura] = []
                        self.loadSubjectState = "Cargando calificaciones..."
                    }
                    if (self.pending["FTEL"] as! [Int]).count == 0 && (self.pending["PROG"] as! [Int]).count == 0 && (self.pending["CORE"] as! [Int]).count == 0 && (self.pending["IWEB"] as! [Int]).count == 0 {
                        self.pending["Any"] = -1
                    }
                }
            }
        } else if body.localizedStandardContains("Estado actualizado") && (self.pending["Any"] as! Int) == 0 {
            //Tengo operaciones pendientes por terminar
            self.lastMessages.append(body)
            print(body)
            for asignatura in self.subjectsAcronyms {
                let pending = self.pending[asignatura] as! [Int]
                if pending.count != 0 {
                    let index = pending.first
                    if index != -1 {
                        //Esa asignatura tiene pendiente obtener el valor
                        //print("viendo "+asignatura+" con index "+String(describing: index))
                        let array = self.lastMessages[index!].split(separator: " ")
                        let asignatura = String(array[1])
                        let atributo = String(array[3])
                        if atributo == "evaluaciones" || atributo == "matriculas" || atributo == "datosAlumno" {
                            //Almacenan arrays
                            let param = String(array[5])
                            self.webView.evaluateJavaScript(self.script+"getValue(\"\(asignatura)\", \"\(atributo)\", \"\((self.keys[asignatura]![atributo] as! [String])[Int(param)!])\")", completionHandler: nil)
                        } else if atributo == "getNota" {
                            //Almacena diccionario
                            let param = Int(array[5])!
                            self.webView.evaluateJavaScript(self.script+"getValue(\"\(asignatura)\", \"\(atributo)\", \"\(String(describing: (self.keys[asignatura]![atributo] as! [String:[String]])[self.actualUserAccount!]![param]))\")", completionHandler: nil)
                        } else {
                            //Almacenan strings
                            self.webView.evaluateJavaScript(self.script+"getValue(\"\(asignatura)\", \"\(atributo)\", \"\(self.keys[asignatura]![atributo]!)\")", completionHandler: nil)
                        }
                    }
                }
            }
        } else if body.localizedStandardContains("stackId") {
            if self.stackId == 0 {
                self.stackId = Int(body.split(separator: " ")[5])
                print("StackId almacenado: \(String(describing: self.stackId))")
                self.readTransactionTxHash(stackId: self.stackId)
            }
        } else if body.localizedStandardContains("txHash") {
            if body.localizedStandardContains("Aún no está") {
                self.readTransactionTxHash(stackId: self.stackId)
            } else if body.localizedStandardContains("Transacción con") {
                self.registeringTxHash = String(body.split(separator: " ")[3])
            }
        } else if body.localizedStandardContains("Transacción actualizada") {
            let state = String(body.split(separator: " ")[2])
            if state == "success" {
                self.registeringState = "Fin."
                self.stackId = 0
                self.registeringTxHash = ""
            }
        } else if body.localizedStandardContains("Estado actualizado") && self.registeringState == "Solicitando matriculación..." {
            if self.registeringTxHash != "" {
                self.readTransactionState(txHash: self.registeringTxHash)
            }
        } else if body.localizedStandardContains("Estado actualizado") {
            print("--"+body)
            self.pending["Any"] = 0
            //print(self.pending)
            self.lastMessages.append(body)
        } else {
            print("random")
            print(body)
            self.lastMessages.append(body)
        }
        
        // Para mandar varios parametros y recogerlos
        // https://medium.com/john-lewis-software-engineering/ios-wkwebview-communication-using-javascript-and-swift-ee077e0127eb
    }
}
