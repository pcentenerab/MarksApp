//
//  SubjectModel.swift
//  MarksApp
//
//  Created by Belén on 14/05/2020.
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
    
    struct Evaluacion: Codable {
        var nombre: String
        var fecha: Int
        var puntos: Int
    }
    
    var evaluaciones: [Evaluacion?]?
    
    struct DatosAlumno: Codable {
        var nombre: String
        var email: String
        var password: String
    }
    // le doy la dirección del alumno y me devuelve sus datos
    var datosAlumno: [String: DatosAlumno?]?
    // direcciones de los alumnos matriculados
    var matriculas: [String]?
    
    enum TipoNota: String, Codable {
        case NP
        case Normal
        case MH
    }
    
    struct Nota: Codable {
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
    
    var state: String!
    var availableSubjects = [Subject]()
    var registeredSubjects = [Subject]()
    var subjectsAcronyms: [String] = ["FTEL", "PROG", "CORE", "IWEB"]
    var subjectNames: [String] = ["Fundamentos de los Sistemas Telemáticos", "Programación", "Computación en Red", "Ingeniería Web"]
    var webView: WKWebView!
    var script: String!
    var lastMessages: [String]!
    var subjectLoaded: Bool!
    // asignatura -> atributo -> clave
    var keys: [String:[String:String]]!
    var pending: [String:Int]!
    
    func setup() -> Bool {
        //Importo todos los ficheros necesarios
        self.state = "Importando contratos..."
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
        
        self.state = "Importando lógica Javascript..."

        print("¿Cargando app.js?")
        print(self.webView.isLoading ? "Sí. Hay que esperar" : "Ya he terminado!")
        while (self.webView.isLoading) {
            CFRunLoopRunInMode(CFRunLoopMode.defaultMode, 0.1, false)
        }
        print(self.webView.isLoading ? "Sí. Hay que esperar" : "Ya he terminado!")
        print("")
        
        self.state = "Configurando Drizzle..."

        self.webView.evaluateJavaScript(self.script+"setup()", completionHandler: nil)
        self.lastMessages = ["Primer mensaje"]
        self.subjectLoaded = false
        self.keys = [
            "FTEL": [
                "profesor":"",
                "acronimo":"",
                "nombre":"",
                "curso":"",
                "evaluaciones":"",
                "datosAlumno":"",
                "matriculas":"",
                "calificaciones":""
            ],
            "PROG": [
                "profesor":"",
                "acronimo":"",
                "nombre":"",
                "curso":"",
                "evaluaciones":"",
                "datosAlumno":"",
                "matriculas":"",
                "calificaciones":""
            ],
            "CORE": [
                "profesor":"",
                "acronimo":"",
                "nombre":"",
                "curso":"",
                "evaluaciones":"",
                "datosAlumno":"",
                "matriculas":"",
                "calificaciones":""
            ],
            "IWEB": [
                "profesor":"",
                "acronimo":"",
                "nombre":"",
                "curso":"",
                "evaluaciones":"",
                "datosAlumno":"",
                "matriculas":"",
                "calificaciones":""
            ]
        ]
        self.pending = [
            "Any": -1,
            "FTEL": -1,
            "PROG": -1,
            "CORE": -1,
            "IWEB": -1
        ]

        //añado subjects por defecto
        for i in 0...(subjectsAcronyms.count-1) {
            availableSubjects.append(Subject(acronimo: subjectsAcronyms[i], nombre: subjectNames[i]))
            //QUITAR ? DEL STRUCT SUBJECT
            if i == 0 || i == 1 {
                availableSubjects[i].matriculas = ["0xc8b3c04f40aDBb94FeD606B185fcBDD87180Fc8F"]
                availableSubjects[i].evaluaciones = []
                let evaluacion1 = Subject.Evaluacion(nombre: "Parcial 1", fecha: 10, puntos: 50)
                let evaluacion2 = Subject.Evaluacion(nombre: "Parcial 2", fecha: 1, puntos: 50)
                availableSubjects[i].evaluaciones = [evaluacion1, evaluacion2]
                availableSubjects[i].calificaciones = [:]
                let nota1 = Subject.Nota(tipo: Subject.TipoNota.Normal, calificacion: 7)
                let nota2 = Subject.Nota(tipo: Subject.TipoNota.MH, calificacion: 10)
                availableSubjects[i].calificaciones!["0xc8b3c04f40aDBb94FeD606B185fcBDD87180Fc8F"] = [0:nota1, 1:nota2]
            } else {
                availableSubjects[i].evaluaciones = []
                let evaluacion1 = Subject.Evaluacion(nombre: "Parcial 1", fecha: 10, puntos: 50)
                let evaluacion2 = Subject.Evaluacion(nombre: "Parcial 2", fecha: 1, puntos: 50)
                availableSubjects[i].evaluaciones = [evaluacion1, evaluacion2]
            }
        }
        //print(self.availableSubjects)
        return true
    }
  /*
    func logged(_ account: String) {
        //print(self.availableSubjects)
        for a in self.availableSubjects {
            if let contains = a.datosAlumno?.keys.contains(account) {
            //if (a.datosAlumno?.keys.contains(account))! {
                if contains {
                    self.registeredSubjects.append(a)
                }
            }
        }
    }*/
    
    /*
    func download() {
        for i in 0...(subjectsAcronyms.count-1) {
            //descargo info de asignatura
            //llamo a su jsonToSubject
            //añado la subject al array
            availableSubjects.append(Subject(acronimo: subjectsAcronyms[i], nombre: subjectNames[i]))
            if (i != 0 && i != 1) {
                //Fuerzo que no tenga FTEL ni PROG
                registeredSubjects.append(Subject(acronimo: subjectsAcronyms[i], nombre: subjectNames[i]))
            }
            //QUITAR ? DEL STRUCT SUBJECT
        }
    }*/
    
    func callWithParam(asignatura: String, atributo: String, param: String) {
        self.pending["Any"] = 0
        self.webView.evaluateJavaScript(self.script+"getKeyWithParam(\"\(asignatura)\", \"\(atributo)\", \"\(param)\")", completionHandler: nil)
    }
    
    func call(asignatura: String, atributo: String) {
        self.pending["Any"] = 0
        self.webView.evaluateJavaScript(self.script+"getKey(\"\(asignatura)\", \"\(atributo)\")", completionHandler: nil)
    }
    
    func matriculasLength(asignatura: String, account: String) {
        self.pending["Any"] = 0
        print("me han llamado")
        self.webView.evaluateJavaScript(self.script+"matriculasLength(\"\(asignatura)\", \"\(account)\")", completionHandler: nil)
    }
    
}

extension SubjectModel: WKScriptMessageHandler, WKNavigationDelegate {
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        let body = message.body as! String

        if self.lastMessages.count == 1 && body.localizedStandardContains("Estado actualizado") {
            //Drizzle configurado
            self.lastMessages.append(body)
            self.state = "Fin de la configuración."
            print(body)
        } else if body.localizedStandardContains("Clave") {
            print(body)
            //He hecho cacheCall y me llega la clave
            let array = body.split(separator: " ")
            let asignatura = String(array[1])
            let atributo = String(array[3])
            var clave = ""
            if body.localizedStandardContains("Parámetro/s") {
                //Llamada con parámetros
                clave = String(array[7])
            } else {
                //Llamada sin parámetros
                clave = String(array[5])
            }
            self.pending[asignatura] = self.lastMessages.count
            self.lastMessages.append(body)
            if self.keys![asignatura]![atributo] == "" {
                //Aún no tengo la clave, la almaceno
                self.keys![asignatura]![atributo] = clave
            } else {
                //Ya tengo la clave, por lo que no hago nada
            }
        } else if body.localizedStandardContains("Datos") {
            print(body)
            self.lastMessages.append(body)
            let array = body.split(separator: " ")
            let asignatura = String(array[1])
            let atributo = String(array[3])
            var datos = String(array[5])
            //let data = datos.data(using: .utf8)!
            
            if atributo == "matriculas" {
                let index = self.subjectsAcronyms.firstIndex(of: asignatura)
                datos.removeAll { char in
                    if char == "\\" || char == "\"" || char == "[" || char == "]" {
                        return true
                    }
                    return false
                }
                let array = datos.components(separatedBy: ",")
                self.availableSubjects[index!].matriculas = array
                self.subjectLoaded = true
                self.pending[asignatura] = -1
            }
        } else if body.localizedStandardContains("Estado actualizado") && self.pending["Any"] == 0 {
            //Tengo operaciones pendientes por terminar
            self.lastMessages.append(body)
            print("-"+body)
            for asignatura in self.subjectsAcronyms {
                let index = self.pending[asignatura]
                if index != -1 {
                    //Esa asignatura tiene pendiente obtener el valor
                    //print("viendo "+asignatura+" con index "+String(describing: index))
                    let array = self.lastMessages[index!].split(separator: " ")
                    let asignatura = String(array[1])
                    let atributo = String(array[3])
                    self.pending[asignatura] = -1
                    self.webView.evaluateJavaScript(self.script+"getValue(\"\(asignatura)\", \"\(atributo)\", \"\(self.keys[asignatura]![atributo]!)\")", completionHandler: nil)
                }
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
        /*
        if body.localizedStandardContains("Estado actualizado") && self.needRequest {
            self.needRequest = false
            self.webView.evaluateJavaScript(self.script+"getKey(\"FTEL\", \"matriculas\")", completionHandler: nil)
            self.webView.evaluateJavaScript(self.script+"getKey(\"PROG\", \"matriculas\")", completionHandler: nil)
            self.webView.evaluateJavaScript(self.script+"getKey(\"CORE\", \"matriculas\")", completionHandler: nil)
            self.webView.evaluateJavaScript(self.script+"getKey(\"IWEB\", \"matriculas\")", completionHandler: nil)
            self.lastMessage = body
        } else if body.localizedStandardContains("Clave") {
            let array = body.split(separator: " ")
            let asignatura = String(array[1])
            let atributo = String(array[3])
            let clave = String(array[5])
            self.keys![asignatura]![atributo] = clave
            self.lastMessage = body
        } else if body.localizedStandardContains("Estado actualizado") {
            print("caso espesial")
            self.lastMessage = body
            if self.keys["FTEL"]!["matriculas"] != "" {
                self.webView.evaluateJavaScript(self.script+"getValue(\"FTEL\", \"matriculas\", "+self.keys["FTEL"]!["matriculas"]!+")", completionHandler: nil)
            }
            if self.keys["PROG"]!["matriculas"] != "" {
                self.webView.evaluateJavaScript(self.script+"getValue(\"PROG\", \"matriculas\", "+self.keys["PROG"]!["matriculas"]!+")", completionHandler: nil)
            }
            if self.keys["CORE"]!["matriculas"] != "" {
                self.webView.evaluateJavaScript(self.script+"getValue(\"CORE\", \"matriculas\", "+self.keys["CORE"]!["matriculas"]!+")", completionHandler: nil)
            }
            if self.keys["IWEB"]!["matriculas"] != "" {
                self.webView.evaluateJavaScript(self.script+"getValue(\"IWEB\", \"matriculas\", "+self.keys["IWEB"]!["matriculas"]!+")", completionHandler: nil)
            }
        } else {
            self.lastMessage = body
        }
        */
        /*
        let body = message.body as! String
        if body.localizedStandardContains("Estado actualizado") && self.lastMessage == "Estado actualizado" {
            // No imprimo mensajes duplicados. Ya he tomado medidas en el primer mensaje.
        } else if (body.localizedStandardContains("clave") && self.valueKey.hasPrefix("0x")) {
            // Me han pasado la clave del atributo valor, pero ya la tengo guardada.
        } else if (body.localizedStandardContains("clave") && !self.valueKey.hasPrefix("0x")) {
            // Me han pasado la clave del atributo valor, la guardo porque aún no la tengo.
            print(body)
            self.valueKey = "\(String(describing: body.split(separator: " ").last!))"
        } else if (body.localizedStandardContains("valor") && String(body.last!) == self.label.text) {
            // Me llega el mismo valor, informo pero no lo actualizo.
            print("Mismo valor, aún no ha cambiado")
        } else if (body.localizedStandardContains("Estado actualizado") && !self.needRequest && self.valueKey.hasPrefix("0x")){
            // El estado se ha actualizado y ya he hecho cacheCall(). Ya tengo la clave almacenada. Hago getValue()
            print(body)
            let key: String! = self.valueKey
            self.webView.evaluateJavaScript(self.script+"getValue(\"\(key!)\")", completionHandler: nil)
        } else if (body.localizedStandardContains("Estado actualizado")){
            // El estado se ha actualizado y aun no he hecho cacheCall(). Pido la clave
            print(body)
            self.needRequest = false
            self.webView.evaluateJavaScript(self.script+"getKey()", completionHandler: nil)
        } else if (body.localizedStandardContains("valor")) {
            // Me han pasado el valor. A partir de aqui, cualquier actualizacion necesita hacer cacheCall() de nuevo
            print(body)
            self.label.text = "\(String(describing: body.split(separator: " ").last!))"
            self.needRequest = true
        } else {
            print(body)
        }
        self.lastMessage = body
*/
        
        
        // Para mandar varios parametros y recogerlos
        // https://medium.com/john-lewis-software-engineering/ios-wkwebview-communication-using-javascript-and-swift-ee077e0127eb
    }

}


/* LLAMADA CON PARAMETROS
 do {
     self.lastMessages.append(body)
     let array = body.split(separator: " ")
     let asignatura = String(array[1])
     let atributo = String(array[3])
     let datos = String(array[5])
     let data = datos.data(using: .utf8)!
     if atributo == "datosAlumno" {
         for i in 0...self.availableSubjects.count-1 {
             if self.availableSubjects[i].acronimo == asignatura {
                 //----------------SE QUEDA PARADO AQUI
                 var updated = self.availableSubjects[i]
                 //print("hola")
                 let dict = try JSONDecoder().decode(DatosAlumnoResponse.self, from: data)
                 let datosAlumno = Subject.DatosAlumno(nombre: dict.value["nombre"]!, email: dict.value["email"]!, password: dict.value["password"]!)
                 let param = dict.args["0"]
                 updated.datosAlumno? = [:]
                 updated.datosAlumno = [param!:datosAlumno]
                 //print(updated)
                 self.availableSubjects[i] = updated
                 //print(self.availableSubjects)
             }
         }
     }
 } catch {
     print("EEEERROR: \(error)")
 }
 
 
 */
