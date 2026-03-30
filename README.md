# Cuenta

Aplicación iOS 18 con SwiftUI y Swift 6.

## Requisitos

- **Xcode 16.0** o superior
- **iOS 18.0** como target mínimo
- **macOS Sonoma 14.0** o superior

## Configuración del Proyecto

### Opción 1: Usar XcodeGen (Recomendado)

1. Instala XcodeGen si no lo tienes:
   ```bash
   brew install xcodegen
   ```

2. Genera el proyecto Xcode:
   ```bash
   cd Cuenta
   xcodegen generate
   ```

3. Abre el proyecto generado:
   ```bash
   open Cuenta.xcodeproj
   ```

### Opción 2: Crear proyecto manualmente en Xcode

1. Abre Xcode 16
2. File → New → Project
3. Selecciona "App" bajo iOS
4. Configura:
   - Product Name: Cuenta
   - Organization Identifier: com.tuempresa
   - Interface: SwiftUI
   - Language: Swift
   - Minimum Deployments: iOS 18.0
5. Reemplaza los archivos generados con los de esta plantilla

## Estructura del Proyecto

```
Cuenta/
├── project.yml              # Configuración XcodeGen
├── Cuenta/
│   ├── CuentaApp.swift      # Entry point de la app
│   ├── ContentView.swift    # Vista principal
│   ├── Info.plist           # Configuración de la app
│   └── Assets.xcassets/     # Assets (iconos, colores)
├── CuentaTests/             # Tests unitarios (Swift Testing)
└── CuentaUITests/           # Tests de UI
```

## Características iOS 18

Esta plantilla incluye soporte para:

- ✅ Swift 6.0 con strict concurrency
- ✅ Swift Testing framework (nuevo en Xcode 16)
- ✅ NavigationStack
- ✅ Symbol Effects (animaciones SF Symbols)
- ✅ App Icon con soporte Dark Mode y Tinted
- ✅ Múltiples escenas (multi-window en iPad)

## Compilar y Ejecutar

```bash
# Compilar
xcodebuild -project Cuenta.xcodeproj -scheme Cuenta -sdk iphonesimulator build

# Ejecutar tests
xcodebuild -project Cuenta.xcodeproj -scheme Cuenta -sdk iphonesimulator test
```

## Personalización

1. **Bundle Identifier**: Modifica `com.tuempresa` en `project.yml`
2. **Development Team**: Agrega tu Team ID en `project.yml`
3. **App Icon**: Agrega tu icono de 1024x1024 en `Assets.xcassets/AppIcon.appiconset/`
