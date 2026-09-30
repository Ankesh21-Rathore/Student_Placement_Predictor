import SwiftUI

// MARK: - Main Dashboard View
struct MainDashboardView: View {
    @StateObject private var profileVM: ProfileViewModel
    @StateObject private var authVM = AuthViewModel()
    @State private var showPredictionForm = false
    @State private var showLogoutAlert = false
    @State private var headerOffset: CGFloat = 0
    @State private var selectedTab: DashboardTab = .overview

    init(user: User) {
        _profileVM = StateObject(wrappedValue: ProfileViewModel(user: user))
    }

    var body: some View {
        ZStack {
            AmbientGlowBackground(color1: .brandPrimary, color2: Color(red: 0.2, green: 0.4, blue: 1.0))

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Hero Header
                    DashboardHeroHeader(profileVM: profileVM, showLogoutAlert: $showLogoutAlert)

                    // Tab Selector
                    DashboardTabSelector(selected: $selectedTab)
                        .padding(.horizontal, 20)
                        .padding(.top, 24)

                    // Tab Content
                    Group {
                        switch selectedTab {
                        case .overview:
                            OverviewTabContent(profileVM: profileVM, showPredictionForm: $showPredictionForm)
                        case .profile:
                            ProfileTabContent(profileVM: profileVM, authVM: authVM)
                        case .history:
                            HistoryTabContent(profileVM: profileVM)
                        }
                    }
                    .padding(.top, 20)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                    .animation(.spring(response: 0.4, dampingFraction: 0.85), value: selectedTab)
                }
            }

            // Floating Predict Button
            VStack {
                Spacer()
                Button {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        showPredictionForm = true
                    }
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "brain.head.profile")
                            .font(.system(size: 18, weight: .semibold))
                        Text("Run New Prediction")
                            .font(AppFont.subheadline())
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 28)
                    .padding(.vertical, 16)
                    .background(AppGradients.brandPrimary)
                    .clipShape(Capsule())
                    .shadow(color: .brandPrimary.opacity(0.5), radius: 16, y: 8)
                }
                .padding(.bottom, 32)
            }

            // OTP overlay for profile changes
            if authVM.showOTPOverlay, let session = authVM.activeOTPSession {
                OTPOverlayView(authVM: authVM, session: session) {
                    profileVM.commitSave()
                }
                .transition(.opacity.combined(with: .scale(scale: 0.9)))
                .zIndex(10)
            }
        }
        .fullScreenCover(isPresented: $showPredictionForm) {
            MainFormView()
        }
        .alert("Sign Out", isPresented: $showLogoutAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Sign Out", role: .destructive) {
                AppStateManager.shared.logout()
            }
        } message: {
            Text("Are you sure you want to sign out?")
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.85), value: authVM.showOTPOverlay)
    }
}

// MARK: - Dashboard Tab Enum
enum DashboardTab: String, CaseIterable {
    case overview = "Overview"
    case profile  = "Profile"
    case history  = "History"

    var icon: String {
        switch self {
        case .overview: return "square.grid.2x2.fill"
        case .profile:  return "person.fill"
        case .history:  return "clock.fill"
        }
    }
}

// MARK: - Tab Selector
struct DashboardTabSelector: View {
    @Binding var selected: DashboardTab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(DashboardTab.allCases, id: \.self) { tab in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                        selected = tab
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 13, weight: .semibold))
                        Text(tab.rawValue)
                            .font(AppFont.caption(13))
                    }
                    .foregroundColor(selected == tab ? .white : .textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        selected == tab
                        ? AnyView(Capsule().fill(AppGradients.brandPrimary))
                        : AnyView(Color.clear)
                    )
                }
            }
        }
        .padding(4)
        .background(Color.surfaceElevated.opacity(0.6))
        .clipShape(Capsule())
    }
}

// MARK: - Hero Header
struct DashboardHeroHeader: View {
    @ObservedObject var profileVM: ProfileViewModel
    @Binding var showLogoutAlert: Bool
    @State private var avatarScale: CGFloat = 0.8
    @State private var avatarOpacity: Double = 0

    var body: some View {
        ZStack {
            // Background gradient card
            LinearGradient(
                colors: [Color(red: 0.2, green: 0.4, blue: 1.0), Color(red: 0.2, green: 0.4, blue: 1.0)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: 280)

            // Decorative circles
            Circle()
                .fill(Color.brandPrimary.opacity(0.15))
                .frame(width: 200, height: 200)
                .blur(radius: 40)
                .offset(x: -60, y: -40)

            Circle()
                .fill(Color.brandSecondary.opacity(0.1))
                .frame(width: 160, height: 160)
                .blur(radius: 40)
                .offset(x: 80, y: 40)

            VStack(spacing: 16) {
                HStack {
                    Spacer()
                    Button { showLogoutAlert = true } label: {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.textSecondary)
                            .padding(10)
                            .background(Color.white.opacity(0.08))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 20)

                // Avatar
                ZStack {
                    Circle()
                        .fill(AppGradients.brandPrimary)
                        .frame(width: 86, height: 86)
                        .shadow(color: .brandPrimary.opacity(0.5), radius: 20)
                    Text(profileVM.user.profileInitial)
                        .font(.system(size: 36, weight: .black, design: .rounded))
                        .foregroundColor(.white)

                    // Online indicator
                    Circle()
                        .fill(Color.successGreen)
                        .frame(width: 16, height: 16)
                        .overlay(Circle().stroke(Color.surfaceDark, lineWidth: 2))
                        .offset(x: 30, y: 30)
                }
                .scaleEffect(avatarScale)
                .opacity(avatarOpacity)
                .onAppear {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.1)) {
                        avatarScale = 1.0
                        avatarOpacity = 1.0
                    }
                }

                VStack(spacing: 4) {
                    Text(profileVM.user.fullName)
                        .font(AppFont.headline(20))
                        .foregroundColor(.textPrimary)
                    Text("@\(profileVM.user.username)")
                        .font(AppFont.caption())
                        .foregroundColor(.textSecondary)
                }

                // Quick Stats Row
                HStack(spacing: 0) {
                    QuickStatPill(value: "\(profileVM.stats.totalPredictions)", label: "Predictions", icon: "brain")
                    Divider().frame(height: 30).background(Color.white.opacity(0.1))
                    QuickStatPill(
                        value: profileVM.stats.highestScore > 0 ? "\(Int(profileVM.stats.highestScore))%" : "—",
                        label: "Best Score",
                        icon: "star.fill"
                    )
                    Divider().frame(height: 30).background(Color.white.opacity(0.1))
                    QuickStatPill(value: "\(profileVM.stats.streakDays)d", label: "Streak", icon: "flame.fill")
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .ignoresSafeArea(edges: .top)
    }
}

struct QuickStatPill: View {
    let value: String
    let label: String
    let icon: String

    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 10))
                    .foregroundColor(.brandPrimary)
                Text(value)
                    .font(AppFont.headline(16))
                    .foregroundColor(.textPrimary)
            }
            Text(label)
                .font(AppFont.caption(11))
                .foregroundColor(.textMuted)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Overview Tab
struct OverviewTabContent: View {
    @ObservedObject var profileVM: ProfileViewModel
    @Binding var showPredictionForm: Bool

    var body: some View {
        VStack(spacing: 20) {
            // Profile Completion Card
            ProfileCompletionCard(completion: profileVM.stats.profileCompletion)
                .padding(.horizontal, 20)

            // Last Prediction Banner
            if let lastScore = profileVM.user.lastPredictionScore {
                LastPredictionBanner(score: lastScore)
                    .padding(.horizontal, 20)
            } else {
                FirstPredictionPrompt(showPredictionForm: $showPredictionForm)
                    .padding(.horizontal, 20)
            }

            // Quick Actions Grid
            QuickActionsGrid(showPredictionForm: $showPredictionForm)
                .padding(.horizontal, 20)

            // Tips Section
            PlacementTipsCard()
                .padding(.horizontal, 20)
                .padding(.bottom, 100)
        }
    }
}

struct ProfileCompletionCard: View {
    let completion: Double
    @State private var animatedProgress: Double = 0

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                SectionHeader(title: "Profile Completion", icon: "chart.pie.fill")
                Text("\(Int(completion))%")
                    .font(AppFont.headline())
                    .foregroundColor(completion >= 80 ? .successGreen : .warningAmber)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.white.opacity(0.08))
                        .frame(height: 10)
                    RoundedRectangle(cornerRadius: 6)
                        .fill(completion >= 80 ? AnyShapeStyle(AppGradients.brandSuccess) : AnyShapeStyle(AppGradients.brandGold))
                        .frame(width: geo.size.width * (animatedProgress / 100), height: 10)
                        .animation(.spring(response: 1.2, dampingFraction: 0.8).delay(0.3), value: animatedProgress)
                }
            }
            .frame(height: 10)
            .onAppear { animatedProgress = completion }

            Text("Complete your profile to unlock better prediction accuracy.")
                .font(AppFont.caption())
                .foregroundColor(.textMuted)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(20)
        .glassCard()
    }
}

struct LastPredictionBanner: View {
    let score: Double
    @State private var animatedScore: Double = 0

    private var tier: PlacementTier {
        score >= 70 ? .high : (score >= 45 ? .medium : .low)
    }

    var body: some View {
        HStack(spacing: 20) {
            ZStack {
                CircularProgressRing(
                    progress: animatedScore / 100,
                    lineWidth: 6,
                    gradient: tier.gradient,
                    label: "\(Int(animatedScore))%"
                )
                .frame(width: 80, height: 80)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Last Prediction")
                    .font(AppFont.caption())
                    .foregroundColor(.textMuted)
                Text("\(tier.rawValue) Placement Chance")
                    .font(AppFont.headline(17))
                    .foregroundColor(.textPrimary)
                HStack(spacing: 6) {
                    Image(systemName: tier.icon)
                        .font(.system(size: 11))
                    Text("Tap to view full report")
                        .font(AppFont.caption(12))
                }
                .foregroundColor(tier.color)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.textMuted)
        }
        .padding(20)
        .glassCard()
        .onAppear {
            withAnimation(.spring(response: 1.2, dampingFraction: 0.8).delay(0.4)) {
                animatedScore = score
            }
        }
    }
}

struct FirstPredictionPrompt: View {
    @Binding var showPredictionForm: Bool

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: "sparkles")
                .font(.system(size: 36))
                .foregroundStyle(AppGradients.brandPrimary)
            Text("Ready to predict your placement?")
                .font(AppFont.headline(17))
                .foregroundColor(.textPrimary)
                .multilineTextAlignment(.center)
            Text("Fill out the 13-step form and our AI engine will analyse your profile.")
                .font(AppFont.caption())
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
            Button { showPredictionForm = true } label: {
                Text("Start Prediction")
            }
            .buttonStyle(PrimaryButtonStyle())
        }
        .padding(24)
        .glassCard()
    }
}

struct QuickActionsGrid: View {
    @Binding var showPredictionForm: Bool

    private let actions: [(String, String, Color, () -> Void)] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(title: "Quick Actions", icon: "bolt.fill")
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                QuickActionCard(icon: "brain.head.profile", title: "New Prediction", subtitle: "Run analysis", color: .brandPrimary) {
                    showPredictionForm = true
                }
                QuickActionCard(icon: "book.fill", title: "DSA Practice", subtitle: "LeetCode tips", color: Color(hex: "#43E97B")) {}
                QuickActionCard(icon: "doc.text.fill", title: "Resume Tips", subtitle: "ATS checklist", color: Color(hex: "#F7C948")) {}
                QuickActionCard(icon: "person.2.fill", title: "Mock Interview", subtitle: "Coming soon", color: Color(hex: "#FF6584")) {}
            }
        }
    }
}

struct QuickActionCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void
    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 42, height: 42)
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(color)
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(AppFont.subheadline(14))
                        .foregroundColor(.textPrimary)
                    Text(subtitle)
                        .font(AppFont.caption(11))
                        .foregroundColor(.textMuted)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .glassCard(cornerRadius: 16)
        }
        .scaleEffect(isPressed ? 0.96 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

struct PlacementTipsCard: View {
    private let tips = [
        ("lightbulb.fill", "Solve at least 3 LeetCode problems daily.", Color.brandGold),
        ("star.fill", "Contribute to open-source for strong GitHub activity.", Color.brandPrimary),
        ("checkmark.seal.fill", "Complete AWS/Google cloud certifications.", Color.successGreen),
        ("person.2.fill", "Network actively on LinkedIn during hiring seasons.", Color.infoBlue)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(title: "Placement Tips", icon: "lightbulb.fill", accent: .brandGold)
            VStack(spacing: 10) {
                ForEach(Array(tips.enumerated()), id: \.offset) { _, tip in
                    HStack(spacing: 12) {
                        Image(systemName: tip.0)
                            .font(.system(size: 14))
                            .foregroundColor(tip.2)
                            .frame(width: 28, height: 28)
                            .background(tip.2.opacity(0.12))
                            .clipShape(Circle())
                        Text(tip.1)
                            .font(AppFont.body(14))
                            .foregroundColor(.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
        .padding(20)
        .glassCard()
    }
}

// MARK: - Profile Tab
struct ProfileTabContent: View {
    @ObservedObject var profileVM: ProfileViewModel
    @ObservedObject var authVM: AuthViewModel

    var body: some View {
        VStack(spacing: 20) {
            // Edit / View Header
            HStack {
                Text(profileVM.isEditing ? "Edit Profile" : "Profile Details")
                    .font(AppFont.headline())
                    .foregroundColor(.textPrimary)
                Spacer()
                if profileVM.isEditing {
                    Button("Cancel") { profileVM.cancelEditing() }
                        .font(AppFont.body())
                        .foregroundColor(.textSecondary)
                    Button("Save") {
                        profileVM.saveProfile(authVM: authVM)
                    }
                    .font(AppFont.subheadline())
                    .foregroundColor(.brandPrimary)
                } else {
                    Button { profileVM.startEditing() } label: {
                        Label("Edit", systemImage: "pencil")
                            .font(AppFont.body())
                            .foregroundColor(.brandPrimary)
                    }
                }
            }
            .padding(.horizontal, 20)

            if profileVM.saveSuccess {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                    Text("Profile saved successfully!")
                }
                .font(AppFont.body())
                .foregroundColor(.successGreen)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color.successGreen.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.horizontal, 20)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }

            // Profile Fields Card
            VStack(spacing: 0) {
                ProfileFieldRow(
                    icon: "person.fill",
                    label: "Full Name",
                    value: profileVM.isEditing ? nil : profileVM.user.fullName,
                    editBinding: profileVM.isEditing ? $profileVM.editFullName : nil
                )
                Divider().background(Color.white.opacity(0.08))
                ProfileFieldRow(
                    icon: "envelope.fill",
                    label: "Email",
                    value: profileVM.isEditing ? nil : profileVM.user.email,
                    editBinding: profileVM.isEditing ? $profileVM.editEmail : nil,
                    sensitiveNote: profileVM.isEditing ? "OTP required on change" : nil
                )
                Divider().background(Color.white.opacity(0.08))
                ProfileFieldRow(
                    icon: "phone.fill",
                    label: "Mobile",
                    value: profileVM.isEditing ? nil : profileVM.user.mobile,
                    editBinding: profileVM.isEditing ? $profileVM.editMobile : nil,
                    sensitiveNote: profileVM.isEditing ? "OTP required on change" : nil
                )
                Divider().background(Color.white.opacity(0.08))
                ProfileFieldRow(
                    icon: "at",
                    label: "Username",
                    value: "@\(profileVM.user.username)",
                    editBinding: nil
                )
                Divider().background(Color.white.opacity(0.08))
                ProfileFieldRow(
                    icon: "calendar",
                    label: "Member Since",
                    value: profileVM.user.joinDate.formatted(.dateTime.month(.wide).year()),
                    editBinding: nil
                )
            }
            .padding(.vertical, 8)
            .glassCard(cornerRadius: 20)
            .padding(.horizontal, 20)

            // Danger Zone
            VStack(spacing: 12) {
                SectionHeader(title: "Account", icon: "gearshape.fill")
                Button(role: .destructive) {
                    AppStateManager.shared.logout()
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                        Text("Sign Out")
                    }
                    .font(AppFont.subheadline())
                    .foregroundColor(.dangerRed)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.dangerRed.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.dangerRed.opacity(0.3), lineWidth: 1))
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 100)
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.85), value: profileVM.isEditing)
        .animation(.spring(response: 0.4, dampingFraction: 0.85), value: profileVM.saveSuccess)
    }
}

struct ProfileFieldRow: View {
    let icon: String
    let label: String
    var value: String?
    var editBinding: Binding<String>?
    var sensitiveNote: String? = nil

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(AppGradients.brandPrimary)
                .frame(width: 32, height: 32)
                .background(Color.brandPrimary.opacity(0.12))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 3) {
                Text(label)
                    .font(AppFont.caption(12))
                    .foregroundColor(.textMuted)
                if let binding = editBinding {
                    TextField(label, text: binding)
                        .font(AppFont.body())
                        .foregroundColor(.textPrimary)
                    if let note = sensitiveNote {
                        Text(note)
                            .font(AppFont.caption(10))
                            .foregroundColor(.warningAmber)
                    }
                } else {
                    Text(value ?? "—")
                        .font(AppFont.body())
                        .foregroundColor(.textPrimary)
                }
            }
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
    }
}

// MARK: - History Tab
struct HistoryTabContent: View {
    @ObservedObject var profileVM: ProfileViewModel

    private let mockHistory: [(String, Double, PlacementTier)] = [
        ("2 days ago", 78.5, .high),
        ("1 week ago", 62.0, .medium),
        ("3 weeks ago", 45.5, .medium)
    ]

    var body: some View {
        VStack(spacing: 20) {
            if profileVM.user.predictionCount == 0 {
                VStack(spacing: 14) {
                    Image(systemName: "clock.badge.questionmark")
                        .font(.system(size: 48))
                        .foregroundColor(.textMuted)
                    Text("No predictions yet")
                        .font(AppFont.headline())
                        .foregroundColor(.textPrimary)
                    Text("Your prediction history will appear here after your first run.")
                        .font(AppFont.body())
                        .foregroundColor(.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(40)
                .glassCard()
                .padding(.horizontal, 20)
            } else {
                VStack(alignment: .leading, spacing: 14) {
                    SectionHeader(title: "Past Predictions", icon: "clock.fill")
                        .padding(.horizontal, 20)
                    ForEach(Array(mockHistory.enumerated()), id: \.offset) { index, item in
                        HistoryRowCard(date: item.0, score: item.1, tier: item.2, index: index)
                            .padding(.horizontal, 20)
                    }
                }
                .padding(.bottom, 100)
            }
        }
    }
}

struct HistoryRowCard: View {
    let date: String
    let score: Double
    let tier: PlacementTier
    let index: Int
    @State private var appear = false

    var body: some View {
        HStack(spacing: 16) {
            // Score ring
            ZStack {
                CircularProgressRing(
                    progress: score / 100,
                    lineWidth: 5,
                    gradient: tier.gradient
                )
                Text("\(Int(score))%")
                    .font(AppFont.caption(11))
                    .foregroundColor(.textPrimary)
            }
            .frame(width: 56, height: 56)

            VStack(alignment: .leading, spacing: 4) {
                Text("\(tier.rawValue) Placement Probability")
                    .font(AppFont.subheadline(14))
                    .foregroundColor(.textPrimary)
                Text(date)
                    .font(AppFont.caption())
                    .foregroundColor(.textMuted)
            }
            Spacer()

            Image(systemName: tier.icon)
                .foregroundColor(tier.color)
                .font(.system(size: 20))
        }
        .padding(16)
        .glassCard(cornerRadius: 16)
        .opacity(appear ? 1 : 0)
        .offset(y: appear ? 0 : 20)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(Double(index) * 0.1)) {
                appear = true
            }
        }
    }
}
