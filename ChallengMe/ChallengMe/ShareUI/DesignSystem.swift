// ============================================================
//  ChallengMe! — DesignSystem.swift
//  Guía de Diseño v1.0
//
//  DÓNDE PONERLO: ChallengMe/ChallengMe/ShareUI/DesignSystem.swift
//
//  Cómo usarlo en cualquier vista:
//    Text("Hola").foregroundStyle(DS.Color.primary)
//    .font(DS.Font.heading1)
//    .padding(DS.Space.lg)
// ============================================================

import SwiftUI

// ── Namespace raíz del Design System ────────────────────────
// "DS" es el prefijo corto para usarlo en toda la app.
// Todo es un enum sin casos para que no puedas crear instancias
// por error: DS.Color.primary, DS.Space.md, etc.
enum DS {}

// ── 1. COLORES ───────────────────────────────────────────────
extension DS {
    enum Color {

        // Primarios
        /// Azul eléctrico — botones principales, enlaces, iconos activos
        static let primary       = SwiftUI.Color(hex: "#3B82F6")
        /// Azul oscuro — hover / estado pulsado de botones primarios
        static let primaryDark   = SwiftUI.Color(hex: "#1D4ED8")
        /// Azul claro — textos de énfasis sobre fondo oscuro
        static let primaryLight  = SwiftUI.Color(hex: "#93C5FD")
        /// Cyan — badges, etiquetas de categoría, detalles secundarios
        static let accent         = SwiftUI.Color(hex: "#06B6D4")

        // Fondos (Dark Mode)
        /// Fondo principal de toda la app
        static let background    = SwiftUI.Color(hex: "#0F172A")
        /// Tarjetas, paneles, sheets, modales
        static let card          = SwiftUI.Color(hex: "#1E293B")
        /// Inputs, dropdowns, hover de items en lista
        static let elevated      = SwiftUI.Color(hex: "#334155")
        /// Bordes de tarjetas y separadores
        static let border        = SwiftUI.Color(hex: "#334155")

        // Textos
        /// Texto principal, títulos
        static let textPrimary   = SwiftUI.Color(hex: "#F8FAFC")
        /// Texto secundario, subtítulos, placeholders
        static let textSecondary = SwiftUI.Color(hex: "#94A3B8")

        // Estados
        /// Reto completado, confirmaciones positivas
        static let success       = SwiftUI.Color(hex: "#22C55E")
        /// Menos de 2h para expirar, advertencias
        static let warning       = SwiftUI.Color(hex: "#F59E0B")
        /// Errores, racha perdida
        static let danger        = SwiftUI.Color(hex: "#EF4444")

        // Ranking — top 3
        /// Oro — posición #1
        static let rankGold      = SwiftUI.Color(hex: "#F59E0B")
        /// Plata — posición #2
        static let rankSilver    = SwiftUI.Color(hex: "#94A3B8")
        /// Bronce — posición #3
        static let rankBronze    = SwiftUI.Color(hex: "#CD7C2F")
    }
}

// ── 2. TIPOGRAFÍA ────────────────────────────────────────────
// En el CSS se usan Inter (body) y Syne (display).
// SwiftUI usa las fuentes del sistema o las que añadas al proyecto.
// Si registras Inter y Syne en Info.plist podrás usar
// Font.custom("Inter-Regular", size: ...) directamente.
// Por ahora usamos SF Pro que es la fuente nativa de Apple;
// si quieres Inter/Syne real, añade los .ttf al target y
// cambia las llamadas Font.custom() de abajo.

extension DS {
    enum Font {
        // Display / Hero — puntos totales, racha principal
        // CSS: 2.5rem / weight 800
        static let display   = SwiftUI.Font.system(size: 40, weight: .heavy, design: .rounded)

        // Heading 1 — título del reto del día
        // CSS: 1.75rem / weight 700
        static let heading1  = SwiftUI.Font.system(size: 28, weight: .bold, design: .rounded)

        // Heading 2 — títulos de sección
        // CSS: 1.25rem / weight 600
        static let heading2  = SwiftUI.Font.system(size: 20, weight: .semibold)

        // Heading 3
        // CSS: 1rem / weight 600
        static let heading3  = SwiftUI.Font.system(size: 16, weight: .semibold)

        // Body — descripción del reto, textos generales
        // CSS: 1rem / weight 400
        static let body      = SwiftUI.Font.system(size: 16, weight: .regular)

        // Small — metadatos, fechas, etiquetas
        // CSS: 0.875rem / weight 400
        static let small     = SwiftUI.Font.system(size: 14, weight: .regular)

        // Micro — badges, contadores, labels de input
        // CSS: 0.75rem / weight 500
        static let micro     = SwiftUI.Font.system(size: 12, weight: .medium)
    }
}

// ── 3. ESPACIADO ─────────────────────────────────────────────
// Sistema basado en múltiplos de 4pt (igual que el CSS de 4px).
// En iOS los puntos son equivalentes a los píxeles del CSS
// en un diseño base de 1x.

extension DS {
    enum Space {
        static let xs:   CGFloat = 4   // Separación mínima inline
        static let sm:   CGFloat = 8   // Padding interno de badges
        static let md:   CGFloat = 16  // Padding de botones, gaps
        static let lg:   CGFloat = 24  // Padding interno de tarjetas
        static let xl:   CGFloat = 32  // Separación entre secciones
        static let xxl:  CGFloat = 48  // Márgenes de página
    }
}

// ── 4. BORDER RADIUS ─────────────────────────────────────────
extension DS {
    enum Radius {
        static let sm:   CGFloat = 6    // Inputs, badges pequeños
        static let md:   CGFloat = 12   // Botones, chips de categoría
        static let lg:   CGFloat = 16   // Tarjetas del dashboard
        static let xl:   CGFloat = 24   // Modal del reto del día / sheets
        static let full: CGFloat = 9999 // Avatares, contador de racha
    }
}

// ── 5. SOMBRAS ───────────────────────────────────────────────
extension DS {
    enum Shadow {
        /// Sombra base de tarjetas
        static func card() -> some View {
            return EmptyView()
                .shadow(color: .black.opacity(0.4), radius: 24, x: 0, y: 4)
        }

        /// Resplandor azul suave — tarjetas en hover / activas
        static let glowColor   = DS.Color.primary.opacity(0.2)
        static let glowSmColor = DS.Color.primary.opacity(0.15)
        static let glowRadius: CGFloat  = 32
        static let glowSmRadius: CGFloat = 16
    }
}

// ── 6. GRADIENTES ────────────────────────────────────────────
extension DS {
    enum Gradient {
        /// Degradado del contador de racha (azul → cyan)
        static let racha = LinearGradient(
            colors: [DS.Color.primary, DS.Color.accent],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        /// Fondo sutil de la hero section
        static let heroBackground = RadialGradient(
            colors: [DS.Color.primary.opacity(0.08), .clear],
            center: .topLeading,
            startRadius: 0,
            endRadius: 400
        )
    }
}

// ── 7. ANIMACIONES ───────────────────────────────────────────
extension DS {
    enum Animation {
        /// Transición estándar (equivale a 0.2s ease del CSS)
        static let standard  = SwiftUI.Animation.easeInOut(duration: 0.2)
        /// Entrada de elementos (fadeInUp del CSS)
        static let fadeInUp  = SwiftUI.Animation.easeOut(duration: 0.4)
        /// Entrada con escala (scaleIn del CSS)
        static let scaleIn   = SwiftUI.Animation.easeOut(duration: 0.3)
        /// Animación de spinner (spin del CSS — 0.7s linear)
        static let spin      = SwiftUI.Animation.linear(duration: 0.7).repeatForever(autoreverses: false)
        /// Pulsación de peligro para el contador urgente
        static let pulseDanger = SwiftUI.Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true)
        /// Parpadeo de la llama de racha
        static let flicker   = SwiftUI.Animation.easeInOut(duration: 0.8).repeatForever(autoreverses: true)
    }
}

// ── 8. HELPER — Color desde Hex ──────────────────────────────
// SwiftUI no tiene init(hex:) de serie.
// Esta extensión permite escribir: Color(hex: "#3B82F6")
// y se usa en todo el Design System de arriba.

extension SwiftUI.Color {
    init(hex: String) {
        // Limpiamos el string: quitamos # y espacios
        let hex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
                     .replacingOccurrences(of: "#", with: "")

        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let r, g, b, a: UInt64
        switch hex.count {
        case 6: // RGB sin alpha
            (r, g, b, a) = ((int >> 16) & 0xFF,
                            (int >> 8)  & 0xFF,
                             int        & 0xFF,
                             255)
        case 8: // RGBA con alpha
            (r, g, b, a) = ((int >> 24) & 0xFF,
                            (int >> 16) & 0xFF,
                            (int >> 8)  & 0xFF,
                             int        & 0xFF)
        default:
            (r, g, b, a) = (0, 0, 0, 255)
        }

        self.init(
            .sRGB,
            red:     Double(r) / 255,
            green:   Double(g) / 255,
            blue:    Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
