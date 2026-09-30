import SwiftUI
// MARK: - Color Palette
extension Color {
    static let brandPrimary    = Color(hex: "#6C63FF")
    static let brandSecondary  = Color(hex: "#FF6584")
    static let brandAccent     = Color(hex: "#43E97B")
    static let brandGold       = Color(hex: "#F7C948")
    static let brandOrange     = Color(hex: "#FF8C42")

    static let surfaceDark     = Color(hex: "#0D0D1A")
    static let surfaceMid      = Color(hex: "#16162A")
    static let surfaceCard     = Color(hex: "#1E1E35")
    static let surfaceElevated = Color(hex: "#252540")

    static let textPrimary     = Color(hex: "#F0F0FF")
    static let textSecondary   = Color(hex: "#A0A0C0")
    static let textMuted       = Color(hex: "#60607A")

    static let successGreen    = Color(hex: "#43E97B")
    static let warningAmber    = Color(hex: "#F7C948")
    static let dangerRed       = Color(hex: "#FF4D6D")
    static let infoBlue        = Color(hex: "#4DA8FF")

    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Gradient Library
struct AppGradients {
    static let heroBackground = LinearGradient(
        colors: [Color(hex: "#0D0D1A"), Color(hex: "#1A1040"), Color(hex: "#0D0D1A")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    static let brandPrimary = LinearGradient(
        colors: [Color(hex: "#6C63FF"), Color(hex: "#9B59B6")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    static let brandSuccess = LinearGradient(
        colors: [Color(hex: "#43E97B"), Color(hex: "#38F9D7")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    static let brandDanger = LinearGradient(
        colors: [Color(hex: "#FF4D6D"), Color(hex: "#FF6584")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    static let brandGold = LinearGradient(
        colors: [Color(hex: "#F7C948"), Color(hex: "#FF8C42")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    static let cardGlass = LinearGradient(
        colors: [Color.white.opacity(0.08), Color.white.opacity(0.03)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    static let tier1 = LinearGradient(
        colors: [Color(hex: "#6C63FF"), Color(hex: "#43E97B")],
        startPoint: .leading,
        endPoint: .trailing
    )
    static let tier2 = LinearGradient(
        colors: [Color(hex: "#4DA8FF"), Color(hex: "#6C63FF")],
        startPoint: .leading,
        endPoint: .trailing
    )
    static let tier3 = LinearGradient(
        colors: [Color(hex: "#F7C948"), Color(hex: "#FF8C42")],
        startPoint: .leading,
        endPoint: .trailing
    )
    static let deepPurple = LinearGradient(
        colors: [Color(hex: "#1A0A4C"), Color(hex: "#2D0B6E")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// MARK: - Typography Scale
struct AppFont {
    static func display(_ size: CGFloat = 34) -> Font { .system(size: size, weight: .black, design: .rounded) }
    static func headline(_ size: CGFloat = 22) -> Font { .system(size: size, weight: .bold, design: .rounded) }
    static func subheadline(_ size: CGFloat = 17) -> Font { .system(size: size, weight: .semibold, design: .rounded) }
    static func body(_ size: CGFloat = 15) -> Font { .system(size: size, weight: .regular, design: .rounded) }
    static func caption(_ size: CGFloat = 12) -> Font { .system(size: size, weight: .medium, design: .rounded) }
    static func mono(_ size: CGFloat = 14) -> Font { .system(size: size, weight: .medium, design: .monospaced) }
}

// MARK: - Custom ViewModifiers
struct GlassCardModifier: ViewModifier {
    var cornerRadius: CGFloat = 20
    var shadowRadius: CGFloat = 12
    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(AppGradients.cardGlass)
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(Color.white.opacity(0.12), lineWidth: 1)
                }
            )
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.ultraThinMaterial)
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .shadow(color: Color.brandPrimary.opacity(0.15), radius: shadowRadius, x: 0, y: 6)
    }
}

struct NeonBorderModifier: ViewModifier {
    var color: Color = .brandPrimary
    var cornerRadius: CGFloat = 16
    var lineWidth: CGFloat = 1.5
    func body(content: Content) -> some View {
        content
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(color.opacity(0.7), lineWidth: lineWidth)
                    .blur(radius: 1)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(color.opacity(0.3), lineWidth: lineWidth * 2)
                    .blur(radius: 3)
            )
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    var gradient: LinearGradient = AppGradients.brandPrimary
    var isDisabled: Bool = false
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppFont.subheadline())
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(isDisabled ? AnyShapeStyle(Color.gray.opacity(0.3)) : AnyShapeStyle(gradient))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .shadow(color: isDisabled ? .clear : Color.brandPrimary.opacity(0.4), radius: 8, y: 4)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppFont.subheadline())
            .foregroundColor(.brandPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.brandPrimary.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.brandPrimary.opacity(0.4), lineWidth: 1))
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

struct GlassTextFieldStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(AppFont.body())
            .foregroundColor(.textPrimary)
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color.white.opacity(0.06))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.12), lineWidth: 1))
    }
}

// MARK: - Extension Helpers
extension View {
    func glassCard(cornerRadius: CGFloat = 20, shadowRadius: CGFloat = 12) -> some View {
        modifier(GlassCardModifier(cornerRadius: cornerRadius, shadowRadius: shadowRadius))
    }
    func neonBorder(color: Color = .brandPrimary, cornerRadius: CGFloat = 16) -> some View {
        modifier(NeonBorderModifier(color: color, cornerRadius: cornerRadius))
    }
    func glassTextField() -> some View {
        modifier(GlassTextFieldStyle())
    }
}

// MARK: - Ambient Glow Background
struct AmbientGlowBackground: View {
    var color1: Color = .brandPrimary
    var color2: Color = .brandSecondary
    var body: some View {
        ZStack {
            AppGradients.heroBackground
            Circle()
                .fill(color1.opacity(0.18))
                .frame(width: 320, height: 320)
                .blur(radius: 80)
                .offset(x: -80, y: -120)
            Circle()
                .fill(color2.opacity(0.12))
                .frame(width: 280, height: 280)
                .blur(radius: 80)
                .offset(x: 100, y: 200)
        }
        .ignoresSafeArea()
    }
}

// MARK: - Floating Particle Effect
struct FloatingParticle: View {
    let size: CGFloat
    let color: Color
    @State private var offsetY: CGFloat = 0
    @State private var opacity: Double = 0
    private let duration: Double

    init(size: CGFloat = 4, color: Color = .brandPrimary) {
        self.size = size
        self.color = color
        self.duration = Double.random(in: 3...7)
    }

    var body: some View {
        Circle()
            .fill(color.opacity(0.6))
            .frame(width: size, height: size)
            .blur(radius: 1)
            .offset(y: offsetY)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeInOut(duration: duration).repeatForever(autoreverses: true)) {
                    offsetY = CGFloat.random(in: -40...(-10))
                    opacity = Double.random(in: 0.3...0.8)
                }
            }
    }
}

// MARK: - Section Header
struct SectionHeader: View {
    let title: String
    let icon: String
    var accent: Color = .brandPrimary

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(AppGradients.brandPrimary)
            Text(title)
                .font(AppFont.headline(18))
                .foregroundColor(.textPrimary)
            Spacer()
        }
    }
}

// MARK: - Chip Tag
struct ChipTag: View {
    let label: String
    var isSelected: Bool = false
    var color: Color = .brandPrimary
    var action: (() -> Void)? = nil

    var body: some View {
        Button(action: { action?() }) {
            Text(label)
                .font(AppFont.caption(13))
                .foregroundColor(isSelected ? .white : color)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(isSelected ? color.opacity(0.85) : color.opacity(0.12))
                .clipShape(Capsule())
                .overlay(Capsule().stroke(color.opacity(isSelected ? 0 : 0.4), lineWidth: 1))
        }
        .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isSelected)
    }
}

// MARK: - Star Rating
struct StarRatingView: View {
    @Binding var rating: Int
    var maxStars: Int = 5
    var color: Color = .brandGold

    var body: some View {
        HStack(spacing: 6) {
            ForEach(1...maxStars, id: \.self) { star in
                Image(systemName: star <= rating ? "star.fill" : "star")
                    .font(.system(size: 24, weight: .regular))
                    .foregroundColor(star <= rating ? color : Color.textMuted)
                    .scaleEffect(star <= rating ? 1.1 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.5), value: rating)
                    .onTapGesture { rating = star }
            }
        }
    }
}

// MARK: - Progress Ring
struct CircularProgressRing: View {
    let progress: Double
    let lineWidth: CGFloat
    let gradient: LinearGradient
    var label: String = ""

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.08), lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: CGFloat(progress))
                .stroke(gradient, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 1.2, dampingFraction: 0.7), value: progress)
            if !label.isEmpty {
                Text(label)
                    .font(AppFont.display(28))
                    .foregroundColor(.textPrimary)
            }
        }
    }
}

// MARK: - Step Indicator
struct StepIndicator: View {
    let currentStep: Int
    let totalSteps: Int

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<totalSteps, id: \.self) { step in
                Capsule()
                    .fill(step == currentStep ? Color.brandPrimary : (step < currentStep ? Color.brandAccent : Color.white.opacity(0.2)))
                    .frame(width: step == currentStep ? 24 : 8, height: 6)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentStep)
            }
        }
    }
}

// MARK: - Shimmer Effect
struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    colors: [.clear, .white.opacity(0.12), .clear],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .offset(x: phase)
                .animation(.linear(duration: 1.5).repeatForever(autoreverses: false), value: phase)
            )
            .onAppear {
                let screenWidth = UIApplication.shared.connectedScenes
                    .compactMap { $0 as? UIWindowScene }
                    .first?
                    .screen
                    .bounds
                    .width ?? 375 // Fallback to a standard screen width if the scene isn't ready yet
                    
                phase = screenWidth * 2
            }
            .clipped()
    }
}

extension View {
    func shimmer() -> some View { modifier(ShimmerModifier()) }
}

// MARK: - Animated Number Counter
struct AnimatedCounter: View {
    let value: Double
    let suffix: String
    let font: Font

    @State private var displayValue: Double = 0

    var body: some View {
        Text("\(Int(displayValue))\(suffix)")
            .font(font)
            .foregroundColor(.textPrimary)
            .onAppear {
                withAnimation(.spring(response: 1.5, dampingFraction: 0.8)) {
                    displayValue = value
                }
            }
    }
}

// MARK: - Pulsating Dot
struct PulsatingDot: View {
    var color: Color = .brandAccent
    @State private var scale: CGFloat = 1.0

    var body: some View {
        Circle()
            .fill(color)
            .frame(width: 10, height: 10)
            .scaleEffect(scale)
            .opacity(2.0 - scale)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: false)) {
                    scale = 2.0
                }
            }
    }
}
