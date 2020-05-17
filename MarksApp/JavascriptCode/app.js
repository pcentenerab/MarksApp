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

function getKeyWithParam(asignatura, atributo, param) {
    if (globalObject.drizzleState.drizzleStatus.initialized) {
        try {
            let key = globalObject.drizzle.contracts[asignatura].methods[atributo].cacheCall(param);
            webkit.messageHandlers.didFetchValue.postMessage("Asignatura: "+asignatura+" Atributo: "+atributo+" Parámetro/s: "+param+" Clave: "+key);
        } catch (error) {
            webkit.messageHandlers.didFetchValue.postMessage(""+error);
        }
    } else {
        let string = JSON.stringify(globalObject.drizzleState)
        webkit.messageHandlers.didFetchValue.postMessage("No inicializado. Drizzle state: "+string);
    }
}

function getKey(asignatura, atributo) {
    if (globalObject.drizzleState.drizzleStatus.initialized) {
        try {
            let key = globalObject.drizzle.contracts[asignatura].methods[atributo].cacheCall();
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
/*
function setMatricula(asignatura, senderIndex, nombre, email) {
    if (globalObject.drizzleState.drizzleStatus.initialized) {
        const stackId = globalObject.drizzle.contracts[asignatura].methods.setEvaluacion.cacheSend(nombre, email, {from: globalObject.drizzleState.accounts[senderIndex]});
        if (globalObject.drizzleState.transactionStack[stackId]) {
            const txHash = globalObject.drizzleState.transactionStack[stackId]
            webkit.messageHandlers.didFetchValue.postMessage("Asignatura: "+asignatura+" Método: setMatricula; TxHash: "+globalObject.drizzleState.transactions[txHash].status)
        }
    } else {
        let string = JSON.stringify(globalObject.drizzleState)
        webkit.messageHandlers.didFetchValue.postMessage("No inicializado. Drizzle state: "+string);
    }
}
*/

function matriculasLength(asignatura, account) {
    if (globalObject.drizzleState.drizzleStatus.initialized) {
        try {
            webkit.messageHandlers.didFetchValue.postMessage("hola");
            const stackId = globalObject.drizzle.contracts.FTEL.methods.matriculasLength.cacheSend({from: globalObject.drizzleState.accounts[0]});
            webkit.messageHandlers.didFetchValue.postMessage(""+stackId);
            let string = JSON.stringify(globalObject.drizzleState);
            webkit.messageHandlers.didFetchValue.postMessage("Drizzle state: "+string);
            // Use the dataKey to display the transaction status.
            if (globalObject.drizzleState.transactionStack[stackId]) {
                const txHash = globalObject.drizzleState.transactionStack[stackId]
                var state = globalObject.drizzleState.transactions[txHash].status
                webkit.messageHandlers.didFetchValue.postMessage("Asignatura: "+asignatura+" Método: matriculasLength Estado: "+state)
            }
        }catch {
            webkit.messageHandlers.didFetchValue.postMessage("ERRORSITO: "+error)
        }
    } else {
        let string = JSON.stringify(globalObject.drizzleState)
        webkit.messageHandlers.didFetchValue.postMessage("No inicializado. Drizzle state: "+string);
    }
}

// LAS DEMAS FUNCIONES
//matriculas[...]
//evalaucionesLength
//evaluaciones[...]
//getNota
