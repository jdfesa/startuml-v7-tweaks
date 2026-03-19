# Análisis de Validación de Licencia en StarUML v7.0.0 (PoC)

> [!CAUTION]
> **AVISO LEGAL Y DESCARGO DE RESPONSABILIDAD**
> Este repositorio tiene fines **estrictamente educativos y de investigación académica en ciberseguridad**. El contenido proporcionado sirve como una Prueba de Concepto (PoC - Proof of Concept) para analizar y demostrar debilidades lógicas en los sistemas de validación de licencias del lado del cliente en aplicaciones basadas en Electron (usando empaquetado `.asar`).
> 
> **NO** distribuimos código fuente original de StarUML, ni promovemos, fomentamos o apoyamos la piratería de software. El usuario no debe utilizar esta información para evadir sistemas DRM ni para evitar pagar una licencia comercial. Si utiliza StarUML para fines personales, profesionales o comerciales, por favor apoye a los desarrolladores (MKLabs) adquiriendo una licencia legítima en [staruml.io](https://staruml.io/).

---

## 🔍 Resumen del Proyecto

Este proyecto explora cómo StarUML v7.0.0 implementa su lógica de restricción de características y validación de licencias. Al analizar el paquete `.asar` de la aplicación, esta prueba de concepto demuestra cómo las verificaciones del lado del cliente pueden ser manipuladas localmente modificando la lógica de los archivos JavaScript en el entorno de ejecución.

<img src="https://64.media.tumblr.com/13d2c753eed929097cc13bbb1d3e482c/67441800327766fc-96/s1920x1080/fe67f6e7feaaf682aa84cd0280cbb4eed24e9dea.gif" alt="Educational PoC Demo" style="width:100%;">

---

## 🔬 Análisis Técnico

StarUML v7.0.0 introdujo nuevas medidas de seguridad en su sistema de licencias, pero debido a que depende del framework Electron (donde la lógica de la aplicación se distribuye como JavaScript compilado o en texto plano dentro de un archivo `.asar`), sigue siendo susceptible a modificaciones locales no autorizadas por el usuario.

El PoC implica la inspección y alteración de tres componentes clave:
- **`license-store.js`**: Se analiza el manejo de estados para períodos de prueba y validaciones asíncronas.
- **`diagram-export.js`**: Demuestra cómo las banderas de características (feature flags) que habilitan exportaciones en alta resolución o insertan marcas de agua son evaluadas localmente por el cliente en lugar de forma paralela en un contexto seguro.
- **`license-activation-dialog.js`**: Muestra cómo la interfaz de usuario UI/UX responde a los diferentes estados de la licencia y gatilla los eventos de solo lectura (Readonly Mode).

---

## ⚙️ Despliegue de la Prueba de Concepto (PoC)

Para replicar este entorno de investigación, se han creado scripts de automatización que extraen, inyectan los vectores modificados y reempaquetan la aplicación de forma segura en un entorno local.

### Configuración Automatizada

**Requisitos Previos:** Se requiere el runtime de [Node.js](https://nodejs.org/) instalado en la máquina anfitriona.

#### Entornos Windows (`patch.bat`)
1. Hacer **clic derecho** sobre el archivo `patch.bat`.
2. Seleccionar **"Ejecutar como administrador"**.
3. El script desempaquetará automáticamente los binarios base, inyectará las modificaciones del PoC y reempaquetará el entorno de ejecución.

#### Entornos Mac y Linux (`patch.sh`)
1. Abrir una sesión de terminal en el directorio de este repositorio.
2. Otorgar permisos de ejecución al script principal: `chmod +x patch.sh`
3. Ejecutar el entorno con privilegios elevados: `sudo ./patch.sh`

---

## 🛠️ Reproducción Manual del PoC

Si se desea estudiar la vulnerabilidad y el mecanismo paso a paso sin utilizar la automatización de los scripts investigativos:

### 1. Preparar el Entorno de Pruebas
Descargue la versión objetivo vulnerable (v7.0.0) desde el servidor [oficial](https://staruml.io/download).

### 2. Instalar la Utilidad ASAR
Instale el paquete `asar` de NPM de forma global para manipular arquitecturas de archivos Electron:

```bash
npm i asar -g
```
> [!NOTE]
> Se recomienda utilizar una versión **LTS** de Node.js para garantizar compatibilidad con librerías asíncronas usadas por el desempaquetador.

### 3. Deconstruir el Archivo de la Aplicación
Localice el volumen principal `app.asar` en el directorio de instalación por defecto del proveedor:
- **Windows**: `C:/Program Files/StarUML/resources`
- **MacOS**: `/Applications/StarUML.app/Contents/Resources`
- **Linux**: `/opt/staruml/resources`

Inicie la extracción controlada en la terminal administrativa:
```bash
asar e app.asar app
```

### 4. Inyectar Lógica Modificada (PoC)
Copie los módulos JavaScript estudiados y manipulados desde este repositorio al árbol de directorios de la carpeta `app` recién extraída en memoria:
- De `app/src/engine/license-store.js` a `app/src/engine/license-store.js`
- De `app/src/engine/diagram-export.js` a `app/src/engine/diagram-export.js`
- De `app/src/dialogs/license-activation-dialog.js` a `app/src/dialogs/license-activation-dialog.js`

### 5. Compilar Modificaciones
Navegue nuevamente al directorio raíz `resources` y recompile el empaquetado asar para acoplar la aplicación en su versión de prueba investigativa:
```bash
asar pack app app.asar
```
Se aconseja remover la carpeta `app` extraída una vez completado por seguridad.

---

## 📊 Efectos Observados en la Ejecución

Una vez aplicadas las modificaciones lógicas del PoC, el análisis en tiempo de ejecución de la instancia principal revela los siguientes comportamientos adversos a la seguridad diseñada:

- **Evasión de Validación de Subsistemas:** La aplicación registra de manera exitosa un estado paramétrico local de licencia válida, evadiendo la limitación de 30 días de prueba y engañando los procesos internos para no contactar a los servidores externos.
- **Desbordamiento de Permisos de Módulos (Feature Unlocking):** Varias funciones altamente restringidas (módulos SysML, BPMN, diagramas AWS/GCP) logran interceptar el falso estado de licencia procediendo con su renderizado total.
- **Ausencia Forense Visual:** El motor de renderizado gráfico de sistema y exportación (para formatos PNG, JPEG, SVG, PDF) procesa los resultados a máxima resolución y elude totalmente inyectar las marcas de agua incrustadas obligatorias (ej. "UNREGISTERED").

---

## 📋 Estructura Estudiada

El entorno de investigación del código y vulnerabilidades locales se organiza de la siguiente manera:
```
StarUML-7.0.0-License-Analysis-PoC/
├── README.md
├── patch.bat      <-- Script de automatización de inyección (Windows)
├── patch.sh       <-- Script de automatización de inyección (Mac/Linux)
└── app/
    └── src/
        ├── engine/
        │   ├── license-store.js
        │   └── diagram-export.js
        └── dialogs/
            └── license-activation-dialog.js
```