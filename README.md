# MarksApp

## Secciones

- [General](#general)
- [Primeros pasos](#primeros_pasos)
- [Uso](#uso)
- [Contribución](#contribucion)

## General <a name = "general"></a>

Este repositorio forma parte del proyecto correspondiente a mi Trabajo de Fin de Grado del Grado en Ingeniería de Tecnologías y Servicios de la Telecomunicación en la Universidad Politécnica de Madrid: Desarrollo de un servicio de gestión de asignaturas basado en Blockchain e implementación de clientes nativos para dispositivos iOS. Mi tutor durante el desarrollo del trabajo, defendido en junio de 2020, ha sido Santiago Pavón.

En concreto, MarksApp es una aplicación iOS de gestión de asignaturas desarrollada con Xcode que permite la comunicación con una red de tipo Blockchain con Ganache. Esta aplicación es híbrida entre Swift y Javascript, que se comunican por medio de un elemento WKWebView del paquete Webkit de Swift. Javascript utiliza la librería Drizzle para acceder al nodo de Ganache. Dicha aplicación es el resultado del desarrollo del Trabajo Fin de Grado. La prueba a menor escala de este caso se encuentra en el repositorio [Case1-WKWebView-Drizzle](https://github.com/pcentenerab/Case1-WKWebView-Drizzle).

## Primeros pasos <a name = "primeros_pasos"></a>

Se debe clonar el repositorio e instalar las dependencias necesarias para que este caso tenga todos los recursos necesarios para su correcta ejecución.

### Prerrequisitos

Se debe haber instalado y configurado el proyecto MarksApp-Contracts disponible en [este repositorio](https://github.com/pcentenerab/MarksApp-Contracts).

### Instalación

Para instalar el proyecto en el entorno, hay que ejecutar los siguientes comandos desde un terminal.

```
$ git clone https://github.com/pcentenerab/MarksApp 
$ cd MarksApp/MarksApp/JavascriptCode
$ npm update
$ npm install
$ browserify requireDrizzle.js -o packedDrizzle.js
```

Además, tras haber desplegado los contratos en Ganache por medio del proyecto Truffle, se debe recoger el contenido de los ficheros del directorio build/contracts. Dicho contenido se debe asignar a las variables FTEL, PROG, CORE e IWEB de los ficheros FTEL.js, PROG.js, CORE.js e IWEB.js, respectivamente, en el directorio JavascriptCode del proyecto Xcode.


## Uso <a name = "uso"></a>

A partir de aquí, ya se tiene la aplicación instalada. Se abre el proyecto Xcode y se ejecuta.


## Contribución <a name = "contribucion"></a>

Este repositorio se enmarca en el proyecto ya mencionado, que proporciona una guía de desarrollo disponible para toda la comunidad de desarrolladores. Estaré encantada de recibir contribuciones al respecto para poder mejorar el potencial de la investigación.