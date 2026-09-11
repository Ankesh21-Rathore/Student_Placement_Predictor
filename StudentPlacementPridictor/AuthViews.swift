import SwiftUI

// MARK: - Root Auth Container
struct AuthRootView: View {
    @StateObject private var authVM = AuthViewModel()
    @State private var showRegister = false

    var body: some View {
        ZStack {
            AmbientGlowBackground(color1: .brandPrimary, color2: .brandSecondary)

            if showRegister {
                RegisterView(authVM: authVM, showRegister: $showRegister)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
            } else {
                LoginView(authVM: authVM, showRegister: $showRegister)
                    .transition(.asymmetric(
                        insertion: .move(edge: .leading).combined(with: .opacity),
                        removal: .move(edge: .trailing).combined(with: .opacity)
                    ))
            }

            if authVM.showOTPOverlay, let session = authVM.activeOTPSession {
                OTPOverlayView(authVM: authVM, session: session) {
                    if showRegister {
                        authVM.completeRegistration()
                    }
                }
                .transition(.opacity.combined(with: .scale(scale: 0.9)))
                .zIndex(10)
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.85), value: showRegister)
        .animation(.spring(response: 0.4, dampingFraction: 0.85), value: authVM.showOTPOverlay)
    }
}

// MARK: - Login View
struct LoginView: View {
    @ObservedObject var authVM: AuthViewModel
    @Binding var showRegister: Bool
    @State private var logoScale: CGFloat = 0.6
    @State private var contentOpacity: Double = 0

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 28) {
                // Header
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(AppGradients.brandPrimary)
                            .frame(width: 80, height: 80)
                            .shadow(color: .brandPrimary.opacity(0.5), radius: 20)
                        Image(systemName: "chart.bar.xaxis.ascending.badge.clock")
                            .font(.system(size: 36, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    .scaleEffect(logoScale)
                    .onAppear {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.1)) {
                            logoScale = 1.0
                        }
                        withAnimation(.easeInOut(duration: 0.5).delay(0.3)) {
                            contentOpacity = 1.0
                        }
                    }

                    Text("Placement Predictor")
                        .font(AppFont.display(28))
                        .foregroundColor(.textPrimary)
                    Text("Sign in to your account")
                        .font(AppFont.body())
                        .foregroundColor(.textSecondary)
                }
                .padding(.top, 60)
                .opacity(contentOpacity)

                // Login Card
                VStack(spacing: 20) {
                    // Username Field
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Username", systemImage: "person")
                            .font(AppFont.caption())
                            .foregroundColor(.textSecondary)
                        HStack {
                            Image(systemName: "person.fill")
                                .foregroundColor(.textMuted)
                                .frame(width: 20)
                            TextField("Enter your username", text: $authVM.loginUsername)
                                .autocapitalization(.none)
                                .autocorrectionDisabled()
                                .foregroundColor(.textPrimary)
                        }
                        .glassTextField()
                    }

                    // Password Field
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Password", systemImage: "lock")
                            .font(AppFont.caption())
                            .foregroundColor(.textSecondary)
                        HStack {
                            Image(systemName: "lock.fill")
                                .foregroundColor(.textMuted)
                                .frame(width: 20)
                            if authVM.isLoginPasswordVisible {
                                TextField("Enter your password", text: $authVM.loginPassword)
                                    .autocapitalization(.none)
                                    .autocorrectionDisabled()
                                    .foregroundColor(.textPrimary)
                            } else {
                                SecureField("Enter your password", text: $authVM.loginPassword)
                                    .foregroundColor(.textPrimary)
                            }
                            Button {
                                authVM.isLoginPasswordVisible.toggle()
                            } label: {
                                Image(systemName: authVM.isLoginPasswordVisible ? "eye.slash.fill" : "eye.fill")
                                    .foregroundColor(.textMuted)
                            }
                        }
                        .glassTextField()
                    }

                    // Captcha Component
                    CaptchaView(authVM: authVM)

                    // Error Message
                    if authVM.showError {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.dangerRed)
                            Text(authVM.errorMessage)
                                .font(AppFont.caption())
                                .foregroundColor(.dangerRed)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.dangerRed.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .transition(.opacity.combined(with: .scale))
                    }

                    // Login Button
                    Button {
                        authVM.attemptLogin()
                    } label: {
                        ZStack {
                            if authVM.isLoading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text(authVM.loginSuccess ? "✓ Welcome Back!" : "Sign In")
                                    .font(AppFont.subheadline())
                            }
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle(isDisabled: !authVM.canLogin))
                    .disabled(!authVM.canLogin || authVM.isLoading)

                    // Demo Hint
                    Text("Demo: username 'alex123' / password 'demo'")
                        .font(AppFont.caption(11))
                        .foregroundColor(.textMuted)
                        .multilineTextAlignment(.center)
                }
                .padding(24)
                .glassCard()
                .padding(.horizontal, 20)
                .opacity(contentOpacity)

                // Divider
                HStack {
                    Rectangle().fill(Color.white.opacity(0.1)).frame(height: 1)
                    Text("OR").font(AppFont.caption()).foregroundColor(.textMuted).padding(.horizontal, 12)
                    Rectangle().fill(Color.white.opacity(0.1)).frame(height: 1)
                }
                .padding(.horizontal, 20)

                // Guest Mode & Register Buttons
                VStack(spacing: 12) {
                    Button {
                        AppStateManager.shared.enterGuestMode()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "person.crop.circle.badge.questionmark")
                            Text("Continue as Guest (1 free prediction)")
                        }
                    }
                    .buttonStyle(SecondaryButtonStyle())
                    .padding(.horizontal, 20)

                    Button {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
                            showRegister = true
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text("Don't have an account?")
                                .foregroundColor(.textSecondary)
                            Text("Register")
                                .foregroundColor(.brandPrimary)
                                .fontWeight(.semibold)
                        }
                        .font(AppFont.body())
                    }
                }
                .padding(.bottom, 40)
                .opacity(contentOpacity)
            }
        }
    }
}

// MARK: - Captcha View
struct CaptchaView: View {
    @ObservedObject var authVM: AuthViewModel
    @State private var shakeTrigger: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Security Verification")
                .font(AppFont.caption())
                .foregroundColor(.textSecondary)

            HStack(spacing: 12) {
                // Captcha Display
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.surfaceElevated)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.brandPrimary.opacity(0.3), lineWidth: 1)
                        )
                    // Noise lines
                    ForEach(0..<3, id: \.self) { i in
                        Path { path in
                            path.move(to: CGPoint(x: CGFloat(i * 30), y: CGFloat.random(in: 10...30)))
                            path.addLine(to: CGPoint(x: CGFloat(i * 30 + 40), y: CGFloat.random(in: 10...30)))
                        }
                        .stroke(Color.brandPrimary.opacity(0.15), lineWidth: 1)
                    }
                    Text(authVM.generatedCaptcha)
                        .font(.system(size: 22, weight: .heavy, design: .monospaced))
                        .foregroundColor(.textPrimary)
                        .tracking(8)
                        .rotationEffect(.degrees(Double.random(in: -3...3)))
                        .shadow(color: .brandPrimary.opacity(0.5), radius: 4)
                }
                .frame(width: 150, height: 50)

                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                        authVM.generateCaptcha()
                    }
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.brandPrimary)
                        .rotationEffect(.degrees(shakeTrigger ? 360 : 0))
                }
                .onChange(of: authVM.generatedCaptcha) {                     withAnimation(.linear(duration: 0.4)) { shakeTrigger.toggle() }
                }

                Spacer()
            }

            // Captcha Input
            HStack {
                Image(systemName: "keyboard")
                    .foregroundColor(.textMuted)
                    .frame(width: 20)
                TextField("Type captcha here", text: Binding(
                    get: { authVM.captchaInput },
                    set: { authVM.validateCaptchaInput($0) }
                ))
                .autocapitalization(.allCharacters)
                .autocorrectionDisabled()
                .foregroundColor(.textPrimary)
                .font(AppFont.mono())

                if !authVM.captchaInput.isEmpty {
                    Image(systemName: authVM.isCaptchaValid ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundColor(authVM.isCaptchaValid ? .successGreen : .dangerRed)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .glassTextField()
            .neonBorder(color: authVM.isCaptchaValid ? .successGreen : (authVM.captchaInput.isEmpty ? .brandPrimary : .dangerRed))
            .animation(.spring(response: 0.3), value: authVM.isCaptchaValid)
        }
    }
}

// MARK: - Register View
struct RegisterView: View {
    @ObservedObject var authVM: AuthViewModel
    @Binding var showRegister: Bool
    @State private var contentOpacity: Double = 0
    @State private var currentPage = 0

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                // Header
                HStack {
                    Button {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
                            showRegister = false
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .font(AppFont.body())
                        .foregroundColor(.brandPrimary)
                    }
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 56)

                VStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(AppGradients.brandPrimary)
                            .frame(width: 70, height: 70)
                            .shadow(color: .brandPrimary.opacity(0.5), radius: 16)
                        Image(systemName: "person.badge.plus.fill")
                            .font(.system(size: 30, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    Text("Create Account")
                        .font(AppFont.display(26))
                        .foregroundColor(.textPrimary)
                    Text("Start your placement journey")
                        .font(AppFont.body())
                        .foregroundColor(.textSecondary)
                }

                // Form Card
                VStack(spacing: 20) {
                    // Full Name
                    RegisterFieldView(
                        icon: "person.fill",
                        label: "Full Name",
                        placeholder: "e.g. Rahul Sharma"
                    ) {
                        TextField("Full Name", text: $authVM.regFullName)
                            .foregroundColor(.textPrimary)
                            .autocorrectionDisabled()
                    }

                    // Email
                    RegisterFieldView(
                        icon: "envelope.fill",
                        label: "Email Address",
                        placeholder: "you@example.com",
                        validationState: authVM.regEmail.isEmpty ? .none : (authVM.regEmail.contains("@") ? .valid : .invalid)
                    ) {
                        TextField("Email", text: $authVM.regEmail)
                            .foregroundColor(.textPrimary)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .autocorrectionDisabled()
                    }

                    // Mobile
                    RegisterFieldView(
                        icon: "phone.fill",
                        label: "Mobile Number",
                        placeholder: "10-digit number",
                        validationState: authVM.regMobile.isEmpty ? .none : (authVM.regMobile.count == 10 ? .valid : .invalid)
                    ) {
                        TextField("Mobile", text: $authVM.regMobile)
                            .foregroundColor(.textPrimary)
                            .keyboardType(.phonePad)
                    }

                    // Date of Birth
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Date of Birth", systemImage: "calendar")
                            .font(AppFont.caption())
                            .foregroundColor(.textSecondary)
                        DatePicker(
                            "",
                            selection: $authVM.regDOB,
                            in: Calendar.current.date(byAdding: .year, value: -40, to: Date())!...Calendar.current.date(byAdding: .year, value: -16, to: Date())!,
                            displayedComponents: .date
                        )
                        .datePickerStyle(.compact)
                        .labelsHidden()
                        .colorScheme(.dark)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color.white.opacity(0.06))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.12), lineWidth: 1))
                    }

                    // Username
                    RegisterFieldView(
                        icon: "at",
                        label: "Username",
                        placeholder: "unique_username",
                        validationState: authVM.regUsername.isEmpty ? .none : (authVM.regUsername.count >= 4 ? .valid : .invalid)
                    ) {
                        TextField("Username", text: $authVM.regUsername)
                            .foregroundColor(.textPrimary)
                            .autocapitalization(.none)
                            .autocorrectionDisabled()
                    }

                    // Password
                    RegisterFieldView(icon: "lock.fill", label: "Password", placeholder: "Min 8 characters") {
                        HStack {
                            if authVM.isRegPasswordVisible {
                                TextField("Password", text: $authVM.regPassword)
                                    .autocapitalization(.none)
                                    .autocorrectionDisabled()
                                    .foregroundColor(.textPrimary)
                            } else {
                                SecureField("Password", text: $authVM.regPassword)
                                    .foregroundColor(.textPrimary)
                            }
                            Button { authVM.isRegPasswordVisible.toggle() } label: {
                                Image(systemName: authVM.isRegPasswordVisible ? "eye.slash.fill" : "eye.fill")
                                    .foregroundColor(.textMuted)
                            }
                        }
                    }

                    // Confirm Password
                    RegisterFieldView(
                        icon: "lock.rotation",
                        label: "Confirm Password",
                        placeholder: "Re-enter password",
                        validationState: authVM.regConfirmPassword.isEmpty ? .none : (authVM.passwordsMatch ? .valid : .invalid)
                    ) {
                        HStack {
                            if authVM.isRegConfirmPasswordVisible {
                                TextField("Confirm Password", text: $authVM.regConfirmPassword)
                                    .autocapitalization(.none)
                                    .autocorrectionDisabled()
                                    .foregroundColor(.textPrimary)
                            } else {
                                SecureField("Confirm Password", text: $authVM.regConfirmPassword)
                                    .foregroundColor(.textPrimary)
                            }
                            Button { authVM.isRegConfirmPasswordVisible.toggle() } label: {
                                Image(systemName: authVM.isRegConfirmPasswordVisible ? "eye.slash.fill" : "eye.fill")
                                    .foregroundColor(.textMuted)
                            }
                        }
                    }

                    if !authVM.regConfirmPassword.isEmpty && !authVM.passwordsMatch {
                        HStack(spacing: 6) {
                            Image(systemName: "xmark.circle.fill").foregroundColor(.dangerRed)
                            Text("Passwords do not match").font(AppFont.caption()).foregroundColor(.dangerRed)
                        }
                    }

                    // Password Strength Indicator
                    if !authVM.regPassword.isEmpty {
                        PasswordStrengthView(password: authVM.regPassword)
                    }

                    // Register Button
                    Button {
                        authVM.submitRegistration()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "person.badge.plus")
                            Text("Create Account & Verify OTP")
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle(isDisabled: !authVM.regFormValid))
                    .disabled(!authVM.regFormValid)
                }
                .padding(24)
                .glassCard()
                .padding(.horizontal, 20)

                Button {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
                        showRegister = false
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text("Already have an account?").foregroundColor(.textSecondary)
                        Text("Sign In").foregroundColor(.brandPrimary).fontWeight(.semibold)
                    }
                    .font(AppFont.body())
                }
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.4)) { contentOpacity = 1 }
        }
        .opacity(contentOpacity)
    }
}

// MARK: - Register Field Helper
enum FieldValidationState { case none, valid, invalid }

struct RegisterFieldView<Content: View>: View {
    let icon: String
    let label: String
    let placeholder: String
    var validationState: FieldValidationState = .none
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(label, systemImage: icon)
                .font(AppFont.caption())
                .foregroundColor(.textSecondary)
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.textMuted)
                    .frame(width: 20)
                content
                if validationState != .none {
                    Image(systemName: validationState == .valid ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundColor(validationState == .valid ? .successGreen : .dangerRed)
                        .transition(.scale.combined(with: .opacity))
                        .animation(.spring(response: 0.3), value: validationState == .valid)
                }
            }
            .glassTextField()
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        validationState == .valid ? Color.successGreen.opacity(0.5) :
                        validationState == .invalid ? Color.dangerRed.opacity(0.5) :
                        Color.clear,
                        lineWidth: 1.5
                    )
            )
        }
    }
}

// MARK: - Password Strength View
struct PasswordStrengthView: View {
    let password: String

    private var strength: (level: Int, label: String, color: Color) {
        var score = 0
        if password.count >= 8 { score += 1 }
        if password.count >= 12 { score += 1 }
        if password.range(of: "[A-Z]", options: .regularExpression) != nil { score += 1 }
        if password.range(of: "[0-9]", options: .regularExpression) != nil { score += 1 }
        if password.range(of: "[^A-Za-z0-9]", options: .regularExpression) != nil { score += 1 }
        switch score {
        case 0...1: return (1, "Weak", .dangerRed)
        case 2...3: return (2, "Moderate", .warningAmber)
        default:    return (3, "Strong", .successGreen)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 4) {
                ForEach(0..<3, id: \.self) { i in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(i < strength.level ? strength.color : Color.white.opacity(0.1))
                        .frame(height: 4)
                        .animation(.spring(response: 0.3), value: strength.level)
                }
            }
            Text("Password strength: \(strength.label)")
                .font(AppFont.caption(11))
                .foregroundColor(strength.color)
        }
    }
}

// MARK: - OTP Overlay View
struct OTPOverlayView: View {
    @ObservedObject var authVM: AuthViewModel
    let session: OTPSession
    var onVerified: () -> Void

    @State private var otpFields: [String] = ["", "", "", ""]
    @FocusState private var focusedIndex: Int?
    @State private var shakeOffset: CGFloat = 0

    private var combinedOTP: String { otpFields.joined() }

    var body: some View {
        ZStack {
            Color.black.opacity(0.75)
                .ignoresSafeArea()
                .onTapGesture { /* lock background */ }

            VStack(spacing: 28) {
                // Icon
                ZStack {
                    Circle()
                        .fill(AppGradients.brandPrimary)
                        .frame(width: 70, height: 70)
                        .shadow(color: .brandPrimary.opacity(0.5), radius: 20)
                    Image(systemName: "message.badge.filled.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.white)
                }

                // Title
                VStack(spacing: 8) {
                    Text("Verify Your \(session.purpose.rawValue)")
                        .font(AppFont.headline())
                        .foregroundColor(.textPrimary)
                    Text("A 4-digit OTP has been sent to")
                        .font(AppFont.body())
                        .foregroundColor(.textSecondary)
                    Text(session.target)
                        .font(AppFont.subheadline())
                        .foregroundColor(.brandPrimary)
                }
                .multilineTextAlignment(.center)

                // Debug hint
                if let otp = authVM.activeOTPSession?.otp {
                    HStack(spacing: 6) {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(.infoBlue)
                        Text("Demo OTP: \(otp)")
                            .font(AppFont.mono(13))
                            .foregroundColor(.infoBlue)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Color.infoBlue.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }

                // OTP Input Boxes
                HStack(spacing: 14) {
                    ForEach(0..<4, id: \.self) { index in
                        OTPDigitBox(
                            digit: $otpFields[index],
                            isFocused: focusedIndex == index
                        )
                        .focused($focusedIndex, equals: index)
                        .onChange(of: otpFields[index]) { _, newValue in
                            handleOTPInput(newValue: newValue, index: index)
                        }
                    }
                }
                .offset(x: shakeOffset)

                // Error
                if !authVM.otpErrorMessage.isEmpty {
                    Text(authVM.otpErrorMessage)
                        .font(AppFont.caption())
                        .foregroundColor(.dangerRed)
                        .transition(.opacity)
                }

                // Countdown
                HStack(spacing: 6) {
                    Image(systemName: "clock")
                        .foregroundColor(authVM.otpCountdown < 60 ? .dangerRed : .textMuted)
                    Text("Expires in \(authVM.formattedOTPCountdown)")
                        .font(AppFont.caption())
                        .foregroundColor(authVM.otpCountdown < 60 ? .dangerRed : .textMuted)
                }

                // Verify Button
                Button {
                    authVM.otpInput = combinedOTP
                    authVM.verifyOTP { success in
                        if success {
                            onVerified()
                        } else {
                            triggerShake()
                        }
                    }
                } label: {
                    Text("Verify OTP")
                }
                .buttonStyle(PrimaryButtonStyle(isDisabled: combinedOTP.count < 4))
                .disabled(combinedOTP.count < 4)
                .frame(maxWidth: .infinity)

                // Resend
                HStack(spacing: 4) {
                    Text("Didn't receive it?").foregroundColor(.textSecondary)
                    Button {
                        otpFields = ["", "", "", ""]
                        authVM.resendOTP()
                        focusedIndex = 0
                    } label: {
                        Text("Resend OTP").foregroundColor(.brandPrimary).fontWeight(.semibold)
                    }
                    .disabled(authVM.otpCountdown > 240)
                    .opacity(authVM.otpCountdown > 240 ? 0.4 : 1)
                }
                .font(AppFont.body())

                // Cancel
                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                        authVM.showOTPOverlay = false
                        authVM.otpInput = ""
                        authVM.otpErrorMessage = ""
                    }
                } label: {
                    Text("Cancel")
                        .font(AppFont.body())
                        .foregroundColor(.textMuted)
                }
            }
            .padding(28)
            .glassCard(cornerRadius: 28)
            .padding(.horizontal, 24)
            .onAppear { focusedIndex = 0 }
        }
    }

    private func handleOTPInput(newValue: String, index: Int) {
        if newValue.count > 1 {
            let digits = Array(newValue.filter { $0.isNumber })
            for i in 0..<min(digits.count, 4 - index) {
                if index + i < 4 {
                    otpFields[index + i] = String(digits[i])
                }
            }
            focusedIndex = min(index + digits.count, 3)
        } else if newValue.count == 1 && index < 3 {
            focusedIndex = index + 1
        } else if newValue.isEmpty && index > 0 {
            focusedIndex = index - 1
        }
    }

    private func triggerShake() {
        withAnimation(.spring(response: 0.1, dampingFraction: 0.2).repeatCount(4)) {
            shakeOffset = 10
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            shakeOffset = 0
        }
    }
}

// MARK: - OTP Digit Box
struct OTPDigitBox: View {
    @Binding var digit: String
    var isFocused: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.surfaceElevated)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(
                            isFocused ? Color.brandPrimary : (digit.isEmpty ? Color.white.opacity(0.12) : Color.successGreen.opacity(0.6)),
                            lineWidth: isFocused ? 2 : 1
                        )
                )
                .frame(width: 62, height: 70)
                .shadow(color: isFocused ? Color.brandPrimary.opacity(0.3) : .clear, radius: 8)

            if digit.isEmpty {
                Circle()
                    .fill(Color.textMuted.opacity(0.4))
                    .frame(width: 8, height: 8)
            } else {
                Text(digit)
                    .font(.system(size: 28, weight: .bold, design: .monospaced))
                    .foregroundColor(.textPrimary)
                    .transition(.scale.combined(with: .opacity))
            }

            // Hidden TextField for input capture
            TextField("", text: $digit)
                .keyboardType(.numberPad)
                .frame(width: 62, height: 70)
                .opacity(0.01)
        }
        .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isFocused)
        .animation(.spring(response: 0.25, dampingFraction: 0.7), value: digit)
        .scaleEffect(isFocused ? 1.05 : 1.0)
    }
}
