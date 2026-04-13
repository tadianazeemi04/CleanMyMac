import SwiftUI
import AppKit

/// BrandColors: Centralized design system tokens for ZenClean.
/// Includes premium gradients, translucent backgrounds, and accent colors.
struct BrandColors {
    /// The primary background color that adapts to system light/dark mode.
    static let primaryBackground = Color(NSColor.windowBackgroundColor)
    
    /// Vibrant accent colors used for priority buttons and alerts.
    static let accent = Color.orange
    static let secondaryAccent = Color.purple
    
    /// Glassmorphism tokens for translucent layers.
    static let glassBackground = Color.white.opacity(0.1)
    static let cardBackground = Color.black.opacity(0.2)
    
    /// ZenClean Signature Gradient (Vibrant Energy).
    static let gradientStart = Color(hex: "FF512F")
    static let gradientEnd = Color(hex: "DD2476")
    
    /// Liquid Pro Gradient (Deep Ocean/Calm).
    static let liquidStart = Color(hex: "4facfe")
    static let liquidEnd = Color(hex: "00f2fe")
}

extension Color {
    /// Initializes a Color from a Hexadecimal string.
    /// - Parameter hex: A 3, 6, or 8 character hex string (e.g., "FFF", "FFFFFF").
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

/// GlassModifier: A ViewModifier that applies a frosted glass effect with high-end shadows and borders.
struct GlassModifier: ViewModifier {
    let cornerRadius: CGFloat
    
    func body(content: Content) -> some View {
        content
            .background(
                VisualEffectView(material: .hudWindow, blendingMode: .withinWindow)
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.white.opacity(0.15), lineWidth: 0.5)
            )
            .shadow(color: Color.black.opacity(0.15), radius: 15, x: 0, y: 8)
    }
}

/// VisualEffectView: A SwiftUI wrapper for NSVisualEffectView to enable native macOS blur effects.
struct VisualEffectView: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode
    
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        return view
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}

extension View {
    /// Applies the standard ZenClean glassmorphic card style.
    func glassCard(radius: CGFloat = 16) -> some View {
        self.modifier(GlassModifier(cornerRadius: radius))
    }
    
    /// Applies a liquid-style inner glow effect.
    func liquidGlow(color: Color, radius: CGFloat = 10) -> some View {
        self.overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(color.opacity(0.5), lineWidth: 2)
                .blur(radius: radius)
        )
    }
}

/// MeshBackground: A dynamic background view that uses animated gradients to provide a "Liquid" feel.
struct MeshBackground: View {
    @State private var animate = false
    
    var body: some View {
        ZStack {
            BrandColors.primaryBackground
            
            TimelineView(.animation) { timeline in
                Canvas { context, size in
                    // Simplified mesh-like behavior using rotating gradients
                }
            }
            
            LinearGradient(colors: [
                BrandColors.gradientStart.opacity(0.1),
                BrandColors.gradientEnd.opacity(0.05)
            ], startPoint: animate ? .topLeading : .bottomTrailing, endPoint: animate ? .bottomTrailing : .topLeading)
            .animation(.easeInOut(duration: 5).repeatForever(autoreverses: true), value: animate)
        }
        .onAppear { animate = true }
    }
}
