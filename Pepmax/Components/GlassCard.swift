import SwiftUI

// MARK: - Glass Card Component

struct GlassCard<Content: View>: View {
    @Environment(\.isDarkMode) private var isDarkMode
    let content: Content
    var padding: CGFloat = 16
    var cornerRadius: CGFloat = 16
    
    init(padding: CGFloat = 16, cornerRadius: CGFloat = 16, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.padding = padding
        self.cornerRadius = cornerRadius
    }
    
    private var theme: LiquidGlassTheme {
        isDarkMode ? .dark : .light
    }
    
    var body: some View {
        content
            .padding(padding)
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(isDarkMode ? .ultraThinMaterial : .regularMaterial)
                    .overlay {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(isDarkMode ? 0.1 : 0.4),
                                        Color.white.opacity(isDarkMode ? 0.02 : 0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(theme.glassBorder, lineWidth: 1)
                    }
            }
            .shadow(color: Color.black.opacity(isDarkMode ? 0.4 : 0.08), radius: 16, x: 0, y: 8)
    }
}

// MARK: - Glass Pill / Badge

struct GlassPill: View {
    @Environment(\.isDarkMode) private var isDarkMode
    let text: String
    var color: Color = Color(hex: "FF2D55")
    var isSelected: Bool = false
    
    private var theme: LiquidGlassTheme {
        isDarkMode ? .dark : .light
    }
    
    var body: some View {
        Text(text)
            .font(.system(size: 13, weight: .medium))
            .foregroundStyle(isSelected ? .white : theme.text)
            .padding(.horizontal, 14)
            .padding(.vertical, 7)
            .background {
                Capsule()
                    .fill(isSelected ? color : (isDarkMode ? Color.white.opacity(0.08) : Color.black.opacity(0.05)))
                    .overlay {
                        Capsule()
                            .stroke(isSelected ? color.opacity(0.5) : theme.glassBorder, lineWidth: 1)
                    }
            }
            .shadow(color: isSelected ? color.opacity(0.3) : .clear, radius: 8, x: 0, y: 4)
    }
}

// MARK: - Glow Button

struct GlowButton: View {
    @Environment(\.isDarkMode) private var isDarkMode
    let title: String
    var icon: String? = nil
    var color: Color = Color(hex: "FF2D55")
    var isSmall: Bool = false
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.spring(response: 0.3)) {
                    isPressed = false
                }
            }
            action()
        }) {
            HStack(spacing: 8) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: isSmall ? 14 : 16, weight: .semibold))
                }
                Text(title)
                    .font(.system(size: isSmall ? 14 : 16, weight: .semibold))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, isSmall ? 16 : 24)
            .padding(.vertical, isSmall ? 10 : 14)
            .background {
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [color, color.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay {
                        Capsule()
                            .fill(Color.white.opacity(0.15))
                            .padding(1)
                    }
            }
            .shadow(color: color.opacity(0.5), radius: isPressed ? 20 : 12, x: 0, y: isPressed ? 8 : 6)
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Glass Search Bar

struct GlassSearchBar: View {
    @Environment(\.isDarkMode) private var isDarkMode
    @Binding var text: String
    var placeholder: String = "Search peptides..."
    
    private var theme: LiquidGlassTheme {
        isDarkMode ? .dark : .light
    }
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(theme.textMuted)
            
            TextField(placeholder, text: $text)
                .font(.system(size: 16))
                .foregroundStyle(theme.text)
                .tint(theme.primary)
            
            if !text.isEmpty {
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        text = ""
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(theme.textMuted)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(isDarkMode ? .ultraThinMaterial : .regularMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(theme.glassBorder, lineWidth: 1)
                }
        }
    }
}

// MARK: - Animated Glow Ring

struct GlowRing: View {
    let color: Color
    let progress: Double
    var lineWidth: CGFloat = 4
    
    @State private var animate = false
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.15), lineWidth: lineWidth)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    AngularGradient(
                        colors: [color, color.opacity(0.5), color],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .shadow(color: color.opacity(0.5), radius: 4)
        }
    }
}

// MARK: - Shimmer Effect

struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .overlay {
                LinearGradient(
                    colors: [
                        .clear,
                        Color.white.opacity(0.1),
                        .clear
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .offset(x: phase)
                .onAppear {
                    withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                        phase = 300
                    }
                }
            }
            .clipped()
    }
}

extension View {
    func shimmer() -> some View {
        modifier(ShimmerModifier())
    }
}
