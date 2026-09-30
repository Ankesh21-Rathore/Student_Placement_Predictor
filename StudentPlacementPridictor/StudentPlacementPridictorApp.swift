import SwiftUI
                
    // MARK: - App Entry Point
@main
struct StudentPlacementPredictorApp: App {
    @StateObject private var appState = AppStateManager.shared
    
    var body: some Scene {
        WindowGroup {
            RootNavigationView()
                .environmentObject(appState)
                .preferredColorScheme(.dark)
        }
    }
}

// MARK: - Root Navigation View
struct RootNavigationView: View {
    @EnvironmentObject var appState: AppStateManager
    
    var body: some View {
        ZStack {
            switch appState.currentRoute {
            case .splash:
                SplashScreenView()
                    .transition(.opacity)
                
            case .auth:
                AuthRootView()
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
                
            case .dashboard:
                if let user = appState.currentUser {
                    MainDashboardView(user: user)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                } else {
                    AuthRootView()
                        .transition(.opacity)
                }
                
            case .guest, .predictionForm:
                GuestPredictionView()
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom).combined(with: .opacity),
                        removal: .move(edge: .bottom).combined(with: .opacity)
                    ))
                
            case .results(let result):
                ResultDashboardView(result: result)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
            }
        }
        .animation(.spring(response: 0.55, dampingFraction: 0.85), value: appState.currentRoute)
    }
}

                // MARK: - Splash Screen
struct SplashScreenView: View {
    @State private var logoScale: CGFloat = 0.4
    @State private var logoOpacity: Double = 0
    @State private var titleOpacity: Double = 0
    @State private var titleOffset: CGFloat = 20
    @State private var subtitleOpacity: Double = 0
    @State private var ringProgress: Double = 0
    @State private var particleOpacity: Double = 0
    @State private var shimmerPhase: CGFloat = -300
    
    var body: some View {
        ZStack {
            // Deep background
            AppGradients.heroBackground.ignoresSafeArea()
            
            // Ambient glow orbs
            Circle()
                .fill(Color.brandPrimary.opacity(0.2))
                .frame(width: 400, height: 400)
                .blur(radius: 100)
                .offset(x: -100, y: -200)
            
            Circle()
                .fill(Color.brandSecondary.opacity(0.15))
                .frame(width: 350, height: 350)
                .blur(radius: 100)
                .offset(x: 140, y: 280)
            
            Circle()
                .fill(Color.brandAccent.opacity(0.08))
                .frame(width: 250, height: 250)
                .blur(radius: 80)
                .offset(x: 60, y: 100)
            
            // Floating particles
            ZStack {
                ForEach(0..<12, id: \.self) { i in
                    FloatingParticle(
                        size: CGFloat.random(in: 3...7),
                        color: [Color.brandPrimary, Color.brandAccent, Color.brandSecondary][i % 3]
                    )
                    .offset(
                        x: CGFloat.random(in: -160...160),
                        y: CGFloat.random(in: -300...300)
                    )
                }
            }
            .opacity(particleOpacity)
            
            VStack(spacing: 32) {
                Spacer()
                
                // Logo Assembly
                ZStack {
                    // Outer ring animation
                    Circle()
                        .trim(from: 0, to: ringProgress)
                        .stroke(
                            AppGradients.brandPrimary,
                            style: StrokeStyle(lineWidth: 3, lineCap: .round, dash: [4, 3])
                        )
                        .frame(width: 130, height: 130)
                        .rotationEffect(.degrees(-90))
                        .animation(.spring(response: 1.8, dampingFraction: 0.75).delay(0.3), value: ringProgress)
                    
                    // Second ring counter-rotating
                    Circle()
                        .trim(from: 0, to: ringProgress * 0.6)
                        .stroke(Color.brandAccent.opacity(0.5), lineWidth: 2)
                        .frame(width: 108, height: 108)
                        .rotationEffect(.degrees(90))
                        .animation(.spring(response: 2.0, dampingFraction: 0.7).delay(0.5), value: ringProgress)
                    
                    // Glow backing
                    Circle()
                        .fill(AppGradients.brandPrimary)
                        .frame(width: 88, height: 88)
                        .shadow(color: Color.brandPrimary.opacity(0.6), radius: 30)
                        .scaleEffect(logoScale)
                        .opacity(logoOpacity)
                    
                    // Icon
                    Image(systemName: "chart.bar.xaxis.ascending.badge.clock")
                        .font(.system(size: 38, weight: .semibold))
                        .foregroundColor(.white)
                        .scaleEffect(logoScale)
                        .opacity(logoOpacity)
                    
                    // Shimmer overlay on logo
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.clear, .white.opacity(0.25), .clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 88, height: 88)
                        .offset(x: shimmerPhase)
                        .mask(Circle().frame(width: 88, height: 88))
                        .opacity(logoOpacity)
                }
                
                // App Name & Subtitle
                VStack(spacing: 10) {
                    Text("Placement\(Text(" Predictor").font(.system(size: 38, weight: .black, design: .rounded)).foregroundStyle(AppGradients.brandPrimary))")
                        .font(.system(size: 38, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.textPrimary, Color.brandPrimary.opacity(0.9)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    Text("AI-Powered Career Intelligence")
                        .font(AppFont.subheadline())
                        .foregroundColor(.textSecondary)
                        .opacity(subtitleOpacity)
                }
                .opacity(titleOpacity)
                .offset(y: titleOffset)
                
                Spacer()
                
                // Version tag
                VStack(spacing: 6) {
                    PulsatingDot(color: .brandAccent)
                    Text("Initialising...")
                        .font(AppFont.caption(12))
                        .foregroundColor(.textMuted)
                }
                .opacity(subtitleOpacity)
                .padding(.bottom, 48)
            }
        }
        .onAppear {
            runSplashSequence()
        }
    }
    
    private func runSplashSequence() {
        // Logo pop-in
        withAnimation(.spring(response: 0.6, dampingFraction: 0.55).delay(0.2)) {
            logoScale = 1.0
            logoOpacity = 1.0
        }
        
        // Ring draw
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            ringProgress = 1.0
        }
        
        // Shimmer sweep
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            withAnimation(.easeInOut(duration: 0.6)) {
                shimmerPhase = 300
            }
        }
        
        // Title slide-up
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.5)) {
            titleOpacity = 1.0
            titleOffset = 0
        }
        
        // Subtitle + particles fade-in
        withAnimation(.easeInOut(duration: 0.5).delay(0.85)) {
            subtitleOpacity = 1.0
            particleOpacity = 1.0
        }
        
        // Navigate to Auth after 2.6 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.6) {
            AppStateManager.shared.navigate(to: .auth)
        }
    }
}

                // MARK: - Guest Prediction View (wrapper)
struct GuestPredictionView: View {
    @StateObject private var vm = PlacementPredictorViewModel()
    @State private var showExitAlert = false
    @EnvironmentObject var appState: AppStateManager
    
    var body: some View {
        ZStack {
            AmbientGlowBackground(color1: Color(hex: "#FF6584"), color2: Color(hex: "#6C63FF"))
            
            VStack(spacing: 0) {
                // Guest Banner
                GuestModeBanner(showExitAlert: $showExitAlert)
                
                // Form Navigation Bar
                FormNavBar(vm: vm, showExitAlert: $showExitAlert)
                
                // Step Progress
                StepProgressHeader(vm: vm)
                
                // Pages
                TabView(selection: $vm.currentStep) {
                    ForEach(0..<vm.totalSteps, id: \.self) { step in
                        FormStepPage(vm: vm, step: step)
                            .tag(step)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.spring(response: 0.5, dampingFraction: 0.85), value: vm.currentStep)
                
                // Bottom nav
                FormBottomNavigation(vm: vm)
            }
            
            // Analysis overlay
            if vm.isAnalyzing {
                AnalysisLoadingOverlay(vm: vm)
                    .transition(.opacity)
                    .zIndex(10)
            }
        }
        .fullScreenCover(isPresented: $vm.showResult) {
            if let result = vm.result {
                GuestResultWrapper(result: result, formData: vm.formData)
            }
        }
        .alert("Exit Prediction?", isPresented: $showExitAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Exit to Sign In", role: .destructive) {
                appState.navigate(to: .auth)
            }
        } message: {
            Text("As a guest you get one free prediction. Exiting will not save your data.")
        }
    }
}

                // MARK: - Guest Mode Banner
struct GuestModeBanner: View {
    @Binding var showExitAlert: Bool
    @State private var bannerVisible = false
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "person.crop.circle.badge.questionmark")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.brandGold)
            
            Text("Guest Mode · 1 Free Prediction")
                .font(AppFont.caption(13))
                .foregroundColor(.brandGold)
            
            Spacer()
            
            Button {
                AppStateManager.shared.navigate(to: .auth)
            } label: {
                Text("Sign In")
                    .font(AppFont.caption(12))
                    .foregroundColor(.brandPrimary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 5)
                    .background(Color.brandPrimary.opacity(0.15))
                    .clipShape(Capsule())
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(Color.brandGold.opacity(0.08))
        .overlay(
            Rectangle()
                .fill(Color.brandGold.opacity(0.2))
                .frame(height: 1),
            alignment: .bottom
        )
        .offset(y: bannerVisible ? 0 : -40)
        .opacity(bannerVisible ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.85).delay(0.2)) {
                bannerVisible = true
            }
        }
    }
}

                // MARK: - Guest Result Wrapper
struct GuestResultWrapper: View {
    let result: PlacementResult
    var formData: PredictionFormData = PredictionFormData()
    @Environment(\.dismiss) private var dismiss
    @State private var showSignUpPrompt = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ResultDashboardView(result: result, formData: formData)
            
            if showSignUpPrompt {
                GuestUpsellBanner()
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .zIndex(20)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
                    showSignUpPrompt = true
                }
            }
        }
    }
}

                // MARK: - Guest Upsell Banner
struct GuestUpsellBanner: View {
    var body: some View {
        VStack(spacing: 16) {
            // Handle bar
            RoundedRectangle(cornerRadius: 3)
                .fill(Color.white.opacity(0.3))
                .frame(width: 36, height: 4)
            
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(AppGradients.brandPrimary)
                        .frame(width: 48, height: 48)
                    Image(systemName: "lock.open.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Unlock Full Features")
                        .font(AppFont.headline(16))
                        .foregroundColor(.textPrimary)
                    Text("Save results, track history, and run unlimited predictions.")
                        .font(AppFont.caption(12))
                        .foregroundColor(.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
            }
            
            HStack(spacing: 12) {
                Button {
                    AppStateManager.shared.navigate(to: .auth)
                } label: {
                    Text("Create Free Account")
                        .font(AppFont.subheadline(15))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(AppGradients.brandPrimary)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                Button {
                    AppStateManager.shared.navigate(to: .auth)
                } label: {
                    Text("Sign In")
                        .font(AppFont.subheadline(15))
                        .foregroundColor(.brandPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.brandPrimary.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.brandPrimary.opacity(0.4), lineWidth: 1))
                }
            }
            
            // Feature bullets
            VStack(spacing: 8) {
                GuestFeatureRow(icon: "infinity", text: "Unlimited prediction runs")
                GuestFeatureRow(icon: "clock.arrow.circlepath", text: "Full prediction history & tracking")
                GuestFeatureRow(icon: "person.crop.circle.fill", text: "Personalised career recommendations")
                GuestFeatureRow(icon: "chart.line.uptrend.xyaxis", text: "Progress tracking over time")
            }
            .padding(.top, 4)
        }
        .padding(24)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 28)
                    .fill(.ultraThinMaterial)
                RoundedRectangle(cornerRadius: 28)
                    .fill(AppGradients.deepPurple.opacity(0.92))
                RoundedRectangle(cornerRadius: 28)
                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
            }
        )
        .shadow(color: Color.black.opacity(0.5), radius: 30, y: -10)
        .padding(.horizontal, 12)
        .padding(.bottom, 24)
    }
}

struct GuestFeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.brandPrimary)
                .frame(width: 24, height: 24)
                .background(Color.brandPrimary.opacity(0.12))
                .clipShape(Circle())
            Text(text)
                .font(AppFont.body(13))
                .foregroundColor(.textSecondary)
            Spacer()
        }
    }
}

                // MARK: - App Lifecycle & State Persistence
extension AppStateManager {
    /// Attempt to restore a saved session from UserDefaults
    func attemptSessionRestore() {
        // In a real app, decode a stored auth token or user object
        // For this demo, always start at auth unless navigated elsewhere
        if currentRoute == .splash { return }
    }
}

                // MARK: - Preview Provider
#if DEBUG
struct RootNavigationView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Splash Preview
            SplashScreenView()
                .previewDisplayName("Splash Screen")
            
            // Auth Preview
            AuthRootView()
                .previewDisplayName("Auth Flow")
            
            // Dashboard Preview
            MainDashboardView(user: User(
                fullName: "Alex Johnson",
                email: "alex@example.com",
                mobile: "9876543210",
                dateOfBirth: Calendar.current.date(byAdding: .year, value: -22, to: Date())!,
                username: "alex123",
                passwordHash: "demo"
            ))
            .previewDisplayName("Dashboard")
            
            // Form Preview
            MainFormView()
                .previewDisplayName("Prediction Form")
            
            // Result Preview
            ResultDashboardView(result: PlacementResult(
                overallProbability: 78.5,
                tier: .high,
                matchedRoles: [
                    JobRoleMatch(
                        roleName: "iOS Engineer",
                        matchPercentage: 92,
                        averagePackageLPA: 14,
                        requiredSkills: ["Swift", "SwiftUI", "CoreData"],
                        icon: "apple.logo"
                    ),
                    JobRoleMatch(
                        roleName: "Backend Developer",
                        matchPercentage: 78,
                        averagePackageLPA: 12,
                        requiredSkills: ["Python", "Django", "REST"],
                        icon: "server.rack"
                    )
                ],
                companyTierChances: CompanyTierChances(
                    tier1Percent: 48,
                    tier2Percent: 72,
                    serviceBasedPercent: 95,
                    tier1Examples: ["Google", "Amazon", "Microsoft"],
                    tier2Examples: ["Razorpay", "CRED", "Swiggy"],
                    serviceBasedExamples: ["TCS", "Infosys", "Wipro"]
                ),
                skillGaps: [
                    SkillGap(
                        area: "System Design",
                        description: "No system design experience mentioned.",
                        priority: .critical,
                        actionItem: "Study Grokking the System Design Interview. Practice designing YouTube, Uber, WhatsApp."
                    ),
                    SkillGap(
                        area: "Cloud Platform",
                        description: "No cloud certifications or experience.",
                        priority: .moderate,
                        actionItem: "Complete AWS Cloud Practitioner or Google Cloud ACE certification."
                    )
                ],
                strengths: [
                    "Strong academic foundation with high CGPA.",
                    "Diverse technical stack spanning multiple frameworks.",
                    "Active online presence with GitHub and LinkedIn."
                ],
                recommendedPath: "You are well-positioned for top-tier placements. Focus on system design and behavioural interview rounds for FAANG-level companies.",
                estimatedPackageLPA: 14.0...28.0
            ))
            .previewDisplayName("Results Dashboard")
        }
        .preferredColorScheme(.dark)
        .environmentObject(AppStateManager.shared)
    }
}
#endif
