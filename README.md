# ChallengMe! — iOS

**ChallengMe!** es una red social de retos diarios potenciada por inteligencia artificial.  
Este repositorio contiene la aplicación nativa de iOS, construida íntegramente con Swift y SwiftUI, sin dependencias de terceros.

![Swift](https://img.shields.io/badge/Swift-6-F05138?style=flat&logo=swift&logoColor=white)
![SwiftUI](https://img.shields.io/badge/SwiftUI-Framework-0071E3?style=flat&logo=swift&logoColor=white)
![iOS](https://img.shields.io/badge/iOS-26.4%2B-000000?style=flat&logo=apple&logoColor=white)
![Xcode](https://img.shields.io/badge/Xcode-16%2B-147EFB?style=flat&logo=xcode&logoColor=white)
![Licencia](https://img.shields.io/badge/Licencia-Propietaria-red?style=flat)

---

## Tabla de contenidos

1. [Descripción general](#descripción-general)
2. [Arquitectura](#arquitectura)
3. [Requisitos previos](#requisitos-previos)
4. [Instalación](#instalación)
5. [Configuración](#configuración)
6. [Ejecución](#ejecución)
7. [Distribución](#distribución)
8. [Licencia](#licencia)

---

## Descripción general

ChallengMe! permite a sus usuarios participar en retos diarios generados por IA, subir evidencias de su participación, consultar un ranking global y gestionar su perfil. La app se comunica con una API REST alojada en Azure y autentica a los usuarios mediante JWT almacenado de forma segura en el Keychain del dispositivo.

Funcionalidades implementadas:

- Registro e inicio de sesión con correo electrónico y contraseña
- Recuperación de contraseña
- Visualización y participación en retos diarios
- Historial de retos del usuario
- Ranking / leaderboard global
- Sistema de diseño propio con paleta oscura (modo oscuro nativo)

---

## Arquitectura

El proyecto sigue una arquitectura **MVVM** con separación por capas. El código fuente vive bajo `ChallengMe/ChallengMe/` y se organiza en cinco carpetas principales:

```
ChallengMe/
├── App/                        # Punto de entrada de la aplicación
│   └── ChallengMeApp.swift     # @main, inicializa AuthManager
│
├── Core/                       # Lógica de negocio y red, independiente de la UI
│   ├── Auth/
│   │   └── AuthManager.swift   # Gestión del JWT, Keychain, estado de sesión
│   ├── Models/
│   │   ├── Auth/
│   │   │   ├── Request/        # LoginRequest, RegisterRequest, RecuperarPasswordRequest
│   │   │   └── Shipment/       # AuthShipment (respuesta con token)
│   │   └── Network/
│   │       └── Constant/       # APIConfigConstant, EndpointConstant
│   ├── Network/
│   │   ├── APIClient.swift     # Cliente HTTP: peticiones, inyección de JWT, subida de archivos
│   │   ├── APIConfig.swift     # Factoría de URLRequest
│   │   └── APIError.swift      # Enumeración de errores (401, 409, rate-limit, servidor…)
│   └── Services/
│       └── AuthService.swift   # Llamadas a los endpoints de autenticación
│
├── Features/                   # Vistas y lógica de cada pantalla
│   ├── Auth/                   # WelcomeView, LoginView, RegisterView, RecuperarPasswordView, ContentView
│   ├── Dashboard/              # DashboardView
│   ├── Hitorial/               # MisRetosView (historial de retos)
│   ├── Layaou/                 # MainLayout (shell principal: barra superior y tab bar)
│   ├── Perfil/                 # (reservado)
│   ├── Ranking/                # RankingView
│   └── Reto/                   # RetoView (detalle del reto activo)
│
├── Recources/                  # Assets del proyecto
│   └── Assets.xcassets/        # AppIcon, AccentColor
│
└── ShareUI/                    # Sistema de diseño y componentes reutilizables
    ├── DesignSystem.swift       # Colores, tipografía, espaciado, radios, sombras, gradientes
    └── SharedComponents.swift  # DSTextField, DSSecureField, BackButton
```

### Decisiones de diseño destacadas

| Aspecto | Decisión |
|---|---|
| Dependencias externas | Ninguna — solo frameworks nativos de Apple (SwiftUI, Foundation, Combine, Security) |
| Autenticación | JWT en Keychain; Bearer token inyectado automáticamente en cada petición |
| Gestión de estado | `@StateObject` / `@ObservedObject` / `@EnvironmentObject` de SwiftUI |
| Backend | API REST en Azure (Spain Central) |
| Almacenamiento de evidencias | Azure Blob Storage (contenedor `evidencias`) |
| Base de datos de perfiles | Azure Cosmos DB (`challengeme-db` / `perfiles`) |

---

## Requisitos previos

| Requisito | Versión mínima |
|---|---|
| macOS | Compatible con Xcode 16 |
| Xcode | 16.0 o superior |
| iOS (simulador o dispositivo) | 26.4 o superior |
| Cuenta de desarrollador Apple | Necesaria para instalar en dispositivo físico |

> **Nota:** El target de despliegue configurado en el proyecto es **iOS 26.4**, por lo que solo es compatible con simuladores e instalación física de ese sistema operativo en adelante.

---

## Instalación

### 1. Clonar el repositorio

```bash
git clone https://github.com/Victorr501/ChallengMe-iOS.git
cd ChallengMe-iOS
```

### 2. Abrir en Xcode

```bash
open ChallengMe/ChallengMe.xcodeproj
```

O bien, desde Xcode: **File → Open** y selecciona `ChallengMe/ChallengMe.xcodeproj`.

No es necesario ejecutar ningún gestor de paquetes; el proyecto no tiene dependencias externas.

---

## Configuración

Toda la configuración de red se encuentra en:

```
ChallengMe/Core/Models/Network/Constant/APIConfigConstant.swift
ChallengMe/Core/Models/Network/Constant/EndpointConstant.swift
```

### Variables principales

| Constante | Valor actual | Descripción |
|---|---|---|
| `baseURL` | `https://api-challengeme-ddcpawg6ama0cncn.spaincentral-01.azurewebsites.net/api` | URL base de la API |
| `timeoutInterval` | `30` segundos | Timeout de cada petición HTTP |
| `jwtIssuer` | `"challengeme-api"` | Issuer esperado en el JWT |
| `jwtAudience` | `"challengeme-app"` | Audience esperada en el JWT |
| `jwtExpiration` | `24` horas | TTL del token |
| `blobContainer` | `"evidencias"` | Contenedor de Azure Blob Storage |

### Endpoints registrados

| Método | Ruta | Uso |
|---|---|---|
| POST | `/auth/login-email` | Inicio de sesión |
| POST | `/auth/registro` | Registro de usuario |
| POST | `/auth/refresh` | Renovación del token |
| POST | `/auth/logout` | Cierre de sesión |
| POST | `/auth/recuperar-password` | Recuperación de contraseña |
| POST | `/challenges/{challengeId}/evidence` | Subir evidencia de un reto |
| GET | `/leaderboard` | Obtener el ranking global |

Para cambiar el entorno (desarrollo, staging, producción) basta con modificar `baseURL` en `APIConfigConstant.swift`.

---

## Ejecución

### Simulador

1. En la barra de herramientas de Xcode, selecciona el esquema **ChallengMe** y elige un simulador con iOS 26.4+.
2. Pulsa **⌘ + R** o el botón ▶ para compilar y ejecutar.

### Dispositivo físico

1. Conecta el iPhone o iPad mediante cable USB.
2. En Xcode, ve a **Signing & Capabilities** del target `ChallengMe` y selecciona tu equipo de desarrollo.
3. Selecciona el dispositivo en la barra de herramientas.
4. Pulsa **⌘ + R**.

> Si es la primera vez que usas el dispositivo, será necesario confiar en el certificado desde **Ajustes → General → VPN y gestión del dispositivo**.

---

## Distribución

### Instalación directa desde Xcode (Ad Hoc / Development)

La forma más directa de instalar la app en un dispositivo sin pasar por el App Store es conectar el dispositivo y usar **Product → Run** tal como se describe en la sección anterior.

### Generar un archivo `.ipa`

Para generar un `.ipa` distribuible (TestFlight, App Store Connect o distribución Ad Hoc):

1. Selecciona **Any iOS Device (arm64)** como destino en la barra de herramientas.
2. Ve a **Product → Archive**. Xcode compilará y abrirá el Organizer.
3. En el Organizer, selecciona el archive creado y pulsa **Distribute App**.
4. Elige el método de distribución:
   - **App Store Connect** — para TestFlight o publicación en el App Store.
   - **Ad Hoc** — para instalar en dispositivos registrados con tu cuenta de desarrollador.
   - **Development** — para distribución interna de desarrollo.
5. Sigue el asistente para exportar el `.ipa` o subirlo directamente.

> Se requiere una cuenta de **Apple Developer Program** activa para firmar y distribuir.

---

## Licencia

**Copyright © 2025–2026 ChallengMe! / Victor Rubin. Todos los derechos reservados.**

Este software y su código fuente son propiedad exclusiva de sus autores. Queda expresamente prohibido, sin autorización previa y por escrito del titular:

- Copiar, reproducir o distribuir este software, total o parcialmente.
- Modificar, adaptar o crear obras derivadas.
- Utilizar el software con fines comerciales o no comerciales fuera del ámbito autorizado.
- Realizar ingeniería inversa, descompilar o desensamblar el código.

El incumplimiento de estas condiciones podrá dar lugar a acciones legales civiles y penales conforme a la legislación aplicable.

Para solicitar una licencia de uso, contacta con: **victor.rubin@agralamo.com**
