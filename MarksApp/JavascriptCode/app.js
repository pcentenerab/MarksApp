var globalObject;

function setup() {
    globalObject = {
    drizzle:{},
        drizzleState: {},
        account: ''
    }
    // let drizzle know what contract we want
    const options = {
        contracts: [ FTEL, PROG, CORE, IWEB ],
        web3: {
            fallback: {
                type: "ws",
                url: "ws://127.0.0.1:7545"
            }
        }
    };

    // setup the drizzle store and drizzle
    globalObject.drizzle = new Drizzle.Drizzle(options);
    
    globalObject.drizzle.store.subscribe(() => {
        const drizzleState = globalObject.drizzle.store.getState();
        if (globalObject.drizzle.store.getState().drizzleStatus.initialized) {
            //cada vez que cambia algo, actualizo el objeto con el estado
            globalObject.drizzleState = drizzleState;
            webkit.messageHandlers.didFetchValue.postMessage("Estado actualizado");
        }
    });
}

function getKeyWithParam(asignatura, atributo, param, account) {
    if (globalObject.drizzleState.drizzleStatus.initialized) {
        try {
            if (atributo == "getNota") {
                let key = globalObject.drizzle.contracts[asignatura].methods[atributo].cacheCall(parseInt(param, 10), {from: account});
                webkit.messageHandlers.didFetchValue.postMessage("Asignatura: "+asignatura+" Atributo: "+atributo+" Parámetro/s: "+param+" Clave: "+key);
            } else {
                let key = globalObject.drizzle.contracts[asignatura].methods[atributo].cacheCall(param, {from: account});
                webkit.messageHandlers.didFetchValue.postMessage("Asignatura: "+asignatura+" Atributo: "+atributo+" Parámetro/s: "+param+" Clave: "+key);
            }        
        } catch (error) {
            webkit.messageHandlers.didFetchValue.postMessage(""+error);
        }
    } else {
        let string = JSON.stringify(globalObject.drizzleState)
        webkit.messageHandlers.didFetchValue.postMessage("No inicializado. Drizzle state: "+string);
    }
}

function getKey(asignatura, atributo, account) {
    if (globalObject.drizzleState.drizzleStatus.initialized) {
        try {
            let key = globalObject.drizzle.contracts[asignatura].methods[atributo].cacheCall({from: account});
            webkit.messageHandlers.didFetchValue.postMessage("Asignatura: "+asignatura+" Atributo: "+atributo+" Clave: "+key);
        } catch (error) {
            webkit.messageHandlers.didFetchValue.postMessage(""+error);
        }
    } else {
        let string = JSON.stringify(globalObject.drizzleState)
        webkit.messageHandlers.didFetchValue.postMessage("No inicializado. Drizzle state: "+string);
    }
}

function getValue(asignatura, atributo, key) {
    if (globalObject.drizzleState.drizzleStatus.initialized) {
        try {
            var datos = ""
            if (atributo === "datosAlumno") {
                let object = globalObject.drizzleState.contracts[asignatura][atributo][key];
                datos = JSON.stringify(object);
            } else if (atributo == "matriculasLength" || atributo == "evaluacionesLength" || atributo == "matriculas") {
                if (globalObject.drizzleState.contracts[asignatura][atributo].hasOwnProperty(key)) {
                    datos = globalObject.drizzleState.contracts[asignatura][atributo][key].value;
                } else {
                    datos = "undefined"
                }
            } else if (atributo == "evaluaciones") {
                if (globalObject.drizzleState.contracts[asignatura][atributo].hasOwnProperty(key)) {
                    let object = globalObject.drizzleState.contracts[asignatura][atributo][key].value
                    datos = object.nombre+" "+object.fecha+" "+object.puntos;
                } else {
                    datos = "undefined undefined undefined"
                }
            } else if (atributo == "getNota") {
                if (globalObject.drizzleState.contracts[asignatura][atributo].hasOwnProperty(key)) {
                    let object = globalObject.drizzleState.contracts[asignatura][atributo][key].value
                    datos = object.tipo+" "+object.calificacion;
                } else {
                    datos = "undefined undefined"
                }
            } else {
                datos = globalObject.drizzleState.contracts[asignatura][atributo][key];
            }
            webkit.messageHandlers.didFetchValue.postMessage("Asignatura: "+asignatura+" Atributo: "+atributo+" Datos: "+ datos);
        } catch (error) {
            webkit.messageHandlers.didFetchValue.postMessage(""+error);
        }
    } else {
        let string = JSON.stringify(globalObject.drizzleState)
        webkit.messageHandlers.didFetchValue.postMessage("No inicializado. Drizzle state: "+string);
    }
}

function setMatricula(asignatura, account, nombre, email) {
    if (globalObject.drizzleState.drizzleStatus.initialized) {
        try {
            const stackId = globalObject.drizzle.contracts[asignatura].methods.setMatricula.cacheSend(nombre, email, {from: account, gas: 200000, gasPrice: 20000000000});
            webkit.messageHandlers.didFetchValue.postMessage("Transacción de matriculación enviada. stackId: "+stackId);
        } catch (error) {
            webkit.messageHandlers.didFetchValue.postMessage("Errrroorrrrrr: "+error);
        }
    } else {
        let string = JSON.stringify(globalObject.drizzleState)
        webkit.messageHandlers.didFetchValue.postMessage("No inicializado. Drizzle state: "+string);
    }
}

function readTransactionTxHash(stackId) {
    if (globalObject.drizzleState.drizzleStatus.initialized) {
        try {
            if (globalObject.drizzleState.transactionStack[stackId].includes("TEMP")) {
                //Aún no está el txHash bueno
                webkit.messageHandlers.didFetchValue.postMessage("Aún no está el txHash");
            } else {
                //Ya está el txHash bueno
                webkit.messageHandlers.didFetchValue.postMessage("Transacción con txHash: "+globalObject.drizzleState.transactionStack[stackId]);
            }
        } catch (error) {
            webkit.messageHandlers.didFetchValue.postMessage("Errrroorrrrrr: "+error);
        }
    } else {
        let string = JSON.stringify(globalObject.drizzleState)
        webkit.messageHandlers.didFetchValue.postMessage("No inicializado. Drizzle state: "+string);
    }
}

function readTransactionState(txHash) {
    if (globalObject.drizzleState.drizzleStatus.initialized) {
        try {
            if (globalObject.drizzleState.transactions.hasOwnProperty(txHash)) {
                if (globalObject.drizzleState.transactions[txHash].status == "error") {
                    let string = JSON.stringify(globalObject.drizzleState.transactions[txHash]);
                    webkit.messageHandlers.didFetchValue.postMessage("Error en la transacción: "+string);
                } else {
                    webkit.messageHandlers.didFetchValue.postMessage("Transacción actualizada: "+globalObject.drizzleState.transactions[txHash].status);
                }
            } else {
                webkit.messageHandlers.didFetchValue.postMessage("La transacción aún no está en el estado de Drizzle")
                let string = JSON.stringify(globalObject.drizzleState.transactions)
                webkit.messageHandlers.didFetchValue.postMessage("Drizzle transactions: "+string);
            }
        } catch (error) {
            webkit.messageHandlers.didFetchValue.postMessage("Errrroorrrrrr: "+error);
        }
    } else {
        let string = JSON.stringify(globalObject.drizzleState)
        webkit.messageHandlers.didFetchValue.postMessage("No inicializado. Drizzle state: "+string);
    }
}