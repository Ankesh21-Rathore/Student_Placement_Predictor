import SwiftUI
import Combine

// MARK: - App State Manager
final class AppStateManager: ObservableObject {
    @Published var currentRoute: AppRoute = .splash
    @Published var currentUser: User? = nil
    @Published var isGuestMode: Bool = false
    @Published var guestPredictionUsed: Bool = false
    @Published var isAnimatingTransition: Bool = false

    static let shared = AppStateManager()

    func navigate(to route: AppRoute, animated: Bool = true) {
        if animated {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                currentRoute = route
            }
        } else {
            currentRoute = route
        }
    }

    func enterGuestMode() {
        isGuestMode = true
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            currentRoute = .predictionForm
        }
    }

    func loginUser(_ user: User) {
        currentUser = user
        isGuestMode = false
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            currentRoute = .dashboard
        }
    }

    func logout() {
        currentUser = nil
        isGuestMode = false
        guestPredictionUsed = false
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            currentRoute = .auth
        }
    }

    func useGuestPrediction() {
        guestPredictionUsed = true
    }
}

// MARK: - Auth ViewModel
final class AuthViewModel: ObservableObject {
    // MARK: Login State
    @Published var loginUsername: String = ""
    @Published var loginPassword: String = ""
    @Published var captchaInput: String = ""
    @Published var generatedCaptcha: String = ""
    @Published var isCaptchaValid: Bool = false
    @Published var isLoginPasswordVisible: Bool = false

    // MARK: Register State
    @Published var regFullName: String = ""
    @Published var regEmail: String = ""
    @Published var regMobile: String = ""
    @Published var regDOB: Date = Calendar.current.date(byAdding: .year, value: -20, to: Date()) ?? Date()
    @Published var regUsername: String = ""
    @Published var regPassword: String = ""
    @Published var regConfirmPassword: String = ""
    @Published var isRegPasswordVisible: Bool = false
    @Published var isRegConfirmPasswordVisible: Bool = false

    // MARK: OTP State
    @Published var showOTPOverlay: Bool = false
    @Published var otpInput: String = ""
    @Published var activeOTPSession: OTPSession? = nil
    @Published var otpVerified: Bool = false
    @Published var otpErrorMessage: String = ""
    @Published var otpCountdown: Int = 300

    // MARK: Alert / Error
    @Published var errorMessage: String = ""
    @Published var showError: Bool = false
    @Published var isLoading: Bool = false
    @Published var loginSuccess: Bool = false

    // MARK: In-memory mock user store
    private var mockUserStore: [String: User] = [:]
    private var mockPasswordStore: [String: String] = [:]
    private var otpTimer: AnyCancellable?
    private var appState = AppStateManager.shared

    // Computed
    var isCaptchaCorrect: Bool { captchaInput.uppercased() == generatedCaptcha.uppercased() }
    var canLogin: Bool { !loginUsername.isEmpty && !loginPassword.isEmpty && isCaptchaCorrect }
    var passwordsMatch: Bool { regPassword == regConfirmPassword && !regPassword.isEmpty }
    var regFormValid: Bool {
        !regFullName.isEmpty && !regEmail.isEmpty && !regMobile.isEmpty &&
        !regUsername.isEmpty && passwordsMatch && regEmail.contains("@")
    }

    init() {
        generateCaptcha()
        setupDemoUser()
    }

    private func setupDemoUser() {
        var demo = User(
            fullName: "Alex Johnson",
            email: "alex@example.com",
            mobile: "9876543210",
            dateOfBirth: Calendar.current.date(byAdding: .year, value: -22, to: Date()) ?? Date(),
            username: "alex123",
            passwordHash: "demo"
        )
        demo.predictionCount = 3
        demo.lastPredictionScore = 78.5
        mockUserStore["alex123"] = demo
        mockPasswordStore["alex123"] = "demo"
    }

    func generateCaptcha() {
        let chars = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
        generatedCaptcha = String((0..<6).compactMap { _ in chars.randomElement() })
        captchaInput = ""
        isCaptchaValid = false
    }

    func validateCaptchaInput(_ input: String) {
        captchaInput = input
        isCaptchaValid = input.uppercased() == generatedCaptcha.uppercased()
    }

    func attemptLogin() {
        guard canLogin else { return }
        isLoading = true
        errorMessage = ""

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { [weak self] in
            guard let self else { return }
            self.isLoading = false

            if let storedPassword = self.mockPasswordStore[self.loginUsername],
               storedPassword == self.loginPassword,
               let user = self.mockUserStore[self.loginUsername] {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    self.loginSuccess = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    self.appState.loginUser(user)
                }
            } else {
                self.errorMessage = "Invalid username or password. Try 'alex123' / 'demo'."
                self.showError = true
                self.generateCaptcha()
            }
        }
    }

    func sendOTP(for purpose: OTPPurpose, target: String) {
        let otp = String((0..<4).map { _ in String(Int.random(in: 0...9)) }.joined())
        activeOTPSession = OTPSession(otp: otp, purpose: purpose, target: target)
        showOTPOverlay = true
        otpInput = ""
        otpErrorMessage = ""
        otpCountdown = 300

        print("🔐 MOCK OTP for \(purpose.rawValue): \(otp)")

        startOTPCountdown()
    }

    func verifyOTP(completion: @escaping (Bool) -> Void) {
        guard let session = activeOTPSession else {
            otpErrorMessage = "No active OTP session."
            completion(false)
            return
        }
        if session.isExpired {
            otpErrorMessage = "OTP has expired. Please request a new one."
            completion(false)
            return
        }
        if otpInput == session.otp {
            otpVerified = true
            otpErrorMessage = ""
            showOTPOverlay = false
            otpTimer?.cancel()
            completion(true)
        } else {
            otpErrorMessage = "Incorrect OTP. Please try again."
            withAnimation(.default) { }
            completion(false)
        }
    }

    func resendOTP() {
        guard let session = activeOTPSession else { return }
        sendOTP(for: session.purpose, target: session.target)
    }

    private func startOTPCountdown() {
        otpTimer?.cancel()
        otpTimer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else { return }
                if self.otpCountdown > 0 {
                    self.otpCountdown -= 1
                } else {
                    self.otpTimer?.cancel()
                }
            }
    }

    func submitRegistration() {
        guard regFormValid else { return }
        sendOTP(for: .registration, target: regMobile)
    }

    func completeRegistration() {
        verifyOTP { [weak self] success in
            guard let self, success else { return }
            let newUser = User(
                fullName: self.regFullName,
                email: self.regEmail,
                mobile: self.regMobile,
                dateOfBirth: self.regDOB,
                username: self.regUsername,
                passwordHash: self.regPassword
            )
            self.mockUserStore[self.regUsername] = newUser
            self.mockPasswordStore[self.regUsername] = self.regPassword
            self.appState.loginUser(newUser)
        }
    }

    var formattedOTPCountdown: String {
        let minutes = otpCountdown / 60
        let seconds = otpCountdown % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// MARK: - Profile Edit ViewModel
final class ProfileViewModel: ObservableObject {
    @Published var user: User
    @Published var isEditing: Bool = false
    @Published var editFullName: String = ""
    @Published var editEmail: String = ""
    @Published var editMobile: String = ""
    @Published var showOTPForEmail: Bool = false
    @Published var showOTPForMobile: Bool = false
    @Published var isSaving: Bool = false
    @Published var saveSuccess: Bool = false

    private var originalEmail: String = ""
    private var originalMobile: String = ""

    init(user: User) {
        self.user = user
        syncEditFields()
    }

    func syncEditFields() {
        editFullName = user.fullName
        editEmail = user.email
        editMobile = user.mobile
        originalEmail = user.email
        originalMobile = user.mobile
    }

    func startEditing() {
        syncEditFields()
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            isEditing = true
        }
    }

    func cancelEditing() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            isEditing = false
        }
        syncEditFields()
    }

    func saveProfile(authVM: AuthViewModel) {
        let emailChanged = editEmail != originalEmail
        let mobileChanged = editMobile != originalMobile

        if emailChanged {
            authVM.sendOTP(for: .emailChange, target: editEmail)
        } else if mobileChanged {
            authVM.sendOTP(for: .mobileChange, target: editMobile)
        } else {
            commitSave()
        }
    }

    func commitSave() {
        isSaving = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
            guard let self else { return }
            self.user.fullName = self.editFullName
            self.user.email = self.editEmail
            self.user.mobile = self.editMobile
            self.originalEmail = self.editEmail
            self.originalMobile = self.editMobile
            AppStateManager.shared.currentUser = self.user
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                self.isSaving = false
                self.isEditing = false
                self.saveSuccess = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.saveSuccess = false
            }
        }
    }

    var stats: UserStats {
        UserStats(
            totalPredictions: user.predictionCount,
            highestScore: user.lastPredictionScore ?? 0,
            latestScore: user.lastPredictionScore ?? 0,
            streakDays: Int.random(in: 1...14),
            profileCompletion: calculateProfileCompletion()
        )
    }

    private func calculateProfileCompletion() -> Double {
        var score = 0.0
        if !user.fullName.isEmpty { score += 20 }
        if !user.email.isEmpty { score += 20 }
        if !user.mobile.isEmpty { score += 20 }
        if user.predictionCount > 0 { score += 25 }
        if user.lastPredictionScore != nil { score += 15 }
        return score
    }
}

// MARK: - Placement Predictor ViewModel
final class PlacementPredictorViewModel: ObservableObject {
    @Published var formData: PredictionFormData = PredictionFormData()
    @Published var currentStep: Int = 0
    @Published var isAnalyzing: Bool = false
    @Published var analysisProgress: Double = 0
    @Published var result: PlacementResult? = nil
    @Published var showResult: Bool = false
    @Published var analysisStage: String = ""

    let totalSteps = 13

    var progressPercent: Double {
        Double(currentStep) / Double(totalSteps - 1)
    }

    func goToNextStep() {
        guard currentStep < totalSteps - 1 else { return }
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            currentStep += 1
        }
    }

    func goToPreviousStep() {
        guard currentStep > 0 else { return }
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            currentStep -= 1
        }
    }

    func jumpToStep(_ step: Int) {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            currentStep = step
        }
    }

    func submitForm() {
        isAnalyzing = true
        analysisProgress = 0
        let stages = [
            "Parsing academic profile...",
            "Evaluating DSA proficiency...",
            "Scanning technical skills...",
            "Assessing project portfolio...",
            "Computing market alignment...",
            "Generating placement report..."
        ]
        var idx = 0
        Timer.scheduledTimer(withTimeInterval: 0.6, repeats: true) { [weak self] timer in
            guard let self else { timer.invalidate(); return }
            if idx < stages.count {
                self.analysisStage = stages[idx]
                withAnimation(.easeInOut(duration: 0.5)) {
                    self.analysisProgress = Double(idx + 1) / Double(stages.count)
                }
                idx += 1
            } else {
                timer.invalidate()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    self.result = self.computePrediction()
                    withAnimation(.spring(response: 0.7, dampingFraction: 0.8)) {
                        self.isAnalyzing = false
                        self.showResult = true
                    }
                    if let user = AppStateManager.shared.currentUser {
                        var updated = user
                        updated.predictionCount += 1
                        updated.lastPredictionScore = self.result?.overallProbability
                        AppStateManager.shared.currentUser = updated
                    }
                    if AppStateManager.shared.isGuestMode {
                        AppStateManager.shared.useGuestPrediction()
                    }
                }
            }
        }
    }

    // MARK: - Core Mock Prediction Engine
    private func computePrediction() -> PlacementResult {
        var score: Double = 0

        // Education scoring (25 points)
        let educationScore = scoreEducation()
        score += educationScore

        // DSA scoring (20 points)
        let dsaScore = scoreDSA()
        score += dsaScore

        // Tech Skills scoring (15 points)
        let techScore = scoreTechnicalSkills()
        score += techScore

        // Projects scoring (10 points)
        let projectScore = scoreProjects()
        score += projectScore

        // Internship scoring (10 points)
        let internScore = scoreInternships()
        score += internScore

        // Soft skills (8 points)
        let softScore = scoreSoftSkills()
        score += softScore

        // Certs & portfolio (7 points)
        let extraScore = scoreExtras()
        score += extraScore

        // Social & tools (5 points)
        let presenceScore = scorePresence()
        score += presenceScore

        let probability = min(max(score, 20), 97)
        let tier: PlacementTier = probability >= 70 ? .high : (probability >= 45 ? .medium : .low)

        return PlacementResult(
            overallProbability: probability,
            tier: tier,
            matchedRoles: generateRoleMatches(techSkills: formData.technicalSkills, dsa: formData.dsa, score: probability),
            companyTierChances: generateTierChances(probability: probability),
            skillGaps: identifyGaps(score: probability, education: educationScore, dsa: dsaScore, tech: techScore),
            strengths: identifyStrengths(education: educationScore, dsa: dsaScore, tech: techScore, projects: projectScore, internships: internScore),
            recommendedPath: generateRecommendation(tier: tier, probability: probability),
            estimatedPackageLPA: estimatePackage(probability: probability)
        )
    }

    private func scoreEducation() -> Double {
        var score: Double = 0
        let cgpa = formData.education.btechCGPA
        if cgpa >= 9.0 { score += 12 }
        else if cgpa >= 8.0 { score += 10 }
        else if cgpa >= 7.5 { score += 8 }
        else if cgpa >= 7.0 { score += 6 }
        else if cgpa >= 6.0 { score += 4 }
        else { score += 2 }

        let twelfth = formData.education.twelfthPercent
        if twelfth >= 90 { score += 8 }
        else if twelfth >= 80 { score += 6 }
        else if twelfth >= 70 { score += 4 }
        else { score += 2 }

        let tenth = formData.education.tenthPercent
        if tenth >= 90 { score += 5 }
        else if tenth >= 80 { score += 4 }
        else { score += 2 }

        return score
    }

    private func scoreDSA() -> Double {
        var score: Double = 0
        let problems = formData.dsa.problemsSolved
        if problems >= 800 { score += 10 }
        else if problems >= 400 { score += 8 }
        else if problems >= 200 { score += 6 }
        else if problems >= 100 { score += 4 }
        else if problems >= 50  { score += 2 }
        else { score += 1 }

        score += Double(formData.dsa.topicsKnown.count) * 0.4
        score += Double(formData.dsa.expertiseLevel.level) * 1.5

        let profilesLinked = [
            formData.dsa.leetcodeProfile,
            formData.dsa.hackerrankProfile,
            formData.dsa.codeforcesProfile,
            formData.dsa.codechefProfile
        ].filter { !$0.isEmpty }.count
        score += Double(profilesLinked) * 0.5

        return min(score, 20)
    }

    private func scoreTechnicalSkills() -> Double {
        var score: Double = 0
        let langCount = formData.technicalSkills.languages.count
        let fwkCount = formData.technicalSkills.frameworks.count
        let dbCount = formData.technicalSkills.databases.count
        let cloudCount = formData.technicalSkills.cloudPlatforms.count

        score += min(Double(langCount) * 1.2, 5)
        score += min(Double(fwkCount) * 1.0, 5)
        score += min(Double(dbCount) * 0.8, 3)
        score += min(Double(cloudCount) * 0.5, 2)
        return min(score, 15)
    }

    private func scoreProjects() -> Double {
        let count = formData.projects.count
        var score = min(Double(count) * 2.0, 8)
        if formData.projects.contains(where: { $0.type == .openSource }) { score += 1 }
        if formData.portfolio.hasPortfolio { score += 1 }
        return min(score, 10)
    }

    private func scoreInternships() -> Double {
        let count = formData.internships.count
        var score = min(Double(count) * 3.0, 9)
        if formData.resume.isATSOptimized { score += 1 }
        return min(score, 10)
    }

    private func scoreSoftSkills() -> Double {
        var score: Double = 0
        score += Double(formData.softSkills.communicationRating) * 0.8
        let aptitudeRatio = formData.softSkills.aptitudeMaxScore > 0
            ? formData.softSkills.aptitudeScore / formData.softSkills.aptitudeMaxScore
            : 0
        score += aptitudeRatio * 4
        return min(score, 8)
    }

    private func scoreExtras() -> Double {
        var score: Double = 0
        score += min(Double(formData.certifications.count) * 1.5, 4)
        if formData.portfolio.hasPortfolio { score += 1 }
        if !formData.achievements.hackathons.isEmpty { score += 1 }
        if formData.competitiveExams.hasGATEScore && formData.competitiveExams.gateScore > 400 { score += 1 }
        return min(score, 7)
    }

    private func scorePresence() -> Double {
        var score: Double = 0
        let handles = formData.socialHandles
        if !handles.linkedIn.isEmpty { score += 1.5 }
        if !handles.github.isEmpty { score += 1.5 }
        if !handles.naukri.isEmpty { score += 0.5 }
        score += min(Double(formData.tools.selectedTools.count) * 0.15, 1.5)
        return min(score, 5)
    }

    private func generateRoleMatches(techSkills: TechnicalSkillsInfo, dsa: DSAInfo, score: Double) -> [JobRoleMatch] {
        var roles: [JobRoleMatch] = []

        if techSkills.languages.contains(.swift) || techSkills.frameworks.contains(.swiftUI) {
            roles.append(JobRoleMatch(
                roleName: "iOS Engineer",
                matchPercentage: min(score + 10, 96),
                averagePackageLPA: 14.0,
                requiredSkills: ["Swift", "SwiftUI", "UIKit", "CoreData"],
                icon: "apple.logo"
            ))
        }
        if techSkills.languages.contains(.python) || techSkills.frameworks.contains(.django) || techSkills.frameworks.contains(.fastAPI) {
            roles.append(JobRoleMatch(
                roleName: "Backend Developer",
                matchPercentage: min(score + 5, 94),
                averagePackageLPA: 12.0,
                requiredSkills: ["Python", "REST APIs", "SQL", "Docker"],
                icon: "server.rack"
            ))
        }
        if techSkills.languages.contains(.javascript) || techSkills.frameworks.contains(.react) {
            roles.append(JobRoleMatch(
                roleName: "Frontend Developer",
                matchPercentage: min(score + 2, 92),
                averagePackageLPA: 11.0,
                requiredSkills: ["React", "JavaScript", "HTML/CSS", "TypeScript"],
                icon: "rectangle.on.rectangle"
            ))
        }
        if dsa.topicsKnown.count >= 8 && dsa.problemsSolved >= 300 {
            roles.append(JobRoleMatch(
                roleName: "Software Engineer (SDE)",
                matchPercentage: min(score + 8, 95),
                averagePackageLPA: 18.0,
                requiredSkills: ["DSA", "System Design", "OOP", "SQL"],
                icon: "chevron.left.forwardslash.chevron.right"
            ))
        }
        if techSkills.languages.contains(.python) && (techSkills.frameworks.contains(.tensorflow) || techSkills.frameworks.contains(.pytorch)) {
            roles.append(JobRoleMatch(
                roleName: "ML / AI Engineer",
                matchPercentage: min(score - 5, 88),
                averagePackageLPA: 16.0,
                requiredSkills: ["Python", "TensorFlow/PyTorch", "Pandas", "Math"],
                icon: "brain.head.profile"
            ))
        }
        if roles.isEmpty {
            roles = [
                JobRoleMatch(roleName: "Associate Software Engineer", matchPercentage: max(score - 5, 40), averagePackageLPA: 6.0, requiredSkills: ["Any Language", "Logic", "SQL"], icon: "person.badge.plus"),
                JobRoleMatch(roleName: "IT Analyst", matchPercentage: max(score - 2, 45), averagePackageLPA: 5.5, requiredSkills: ["Communication", "Documentation", "SQL"], icon: "chart.bar")
            ]
        }
        return roles.sorted { $0.matchPercentage > $1.matchPercentage }
    }

    private func generateTierChances(probability: Double) -> CompanyTierChances {
        let tier1 = max(probability - 30, 5)
        let tier2 = min(probability + 10, 85)
        let serviceBase = min(probability + 25, 95)
        return CompanyTierChances(
            tier1Percent: tier1,
            tier2Percent: tier2,
            serviceBasedPercent: serviceBase,
            tier1Examples: ["Google", "Amazon", "Microsoft", "Apple", "Meta"],
            tier2Examples: ["Paytm", "Swiggy", "Razorpay", "Zomato", "CRED"],
            serviceBasedExamples: ["TCS", "Infosys", "Wipro", "HCL", "Cognizant"]
        )
    }

    private func identifyGaps(score: Double, education: Double, dsa: Double, tech: Double) -> [SkillGap] {
        var gaps: [SkillGap] = []

        if dsa < 10 {
            gaps.append(SkillGap(area: "DSA Proficiency", description: "Low number of problems solved and limited topic coverage.", priority: .critical, actionItem: "Solve at least 300 problems on LeetCode, focusing on Arrays, Trees, and DP."))
        }
        if education < 15 {
            gaps.append(SkillGap(area: "Academic Score", description: "CGPA below competitive threshold for top-tier companies.", priority: .moderate, actionItem: "Aim for a CGPA above 7.5 and highlight relevant coursework."))
        }
        if tech < 8 {
            gaps.append(SkillGap(area: "Technical Breadth", description: "Limited programming language and framework exposure.", priority: .critical, actionItem: "Learn one backend and one frontend framework in addition to your primary language."))
        }
        if formData.internships.isEmpty {
            gaps.append(SkillGap(area: "Industry Experience", description: "No internship experience found.", priority: .critical, actionItem: "Apply for at least one internship (even virtual) to demonstrate real-world exposure."))
        }
        if formData.projects.count < 2 {
            gaps.append(SkillGap(area: "Project Portfolio", description: "Fewer than 2 substantial projects showcased.", priority: .moderate, actionItem: "Build and document 2-3 end-to-end projects with live demos or GitHub links."))
        }
        if formData.certifications.isEmpty {
            gaps.append(SkillGap(area: "Certifications", description: "No verified certifications present.", priority: .suggested, actionItem: "Complete free certifications from Google, AWS, or Coursera to validate skills."))
        }
        if formData.socialHandles.linkedIn.isEmpty {
            gaps.append(SkillGap(area: "LinkedIn Presence", description: "No LinkedIn profile linked.", priority: .moderate, actionItem: "Create a complete LinkedIn profile and connect with professionals in your target domain."))
        }
        if formData.softSkills.communicationRating < 3 {
            gaps.append(SkillGap(area: "Communication Skills", description: "Self-assessed communication below average.", priority: .moderate, actionItem: "Join a Toastmasters club or practice mock interviews with peers."))
        }
        if !formData.portfolio.hasPortfolio {
            gaps.append(SkillGap(area: "Portfolio Website", description: "No personal portfolio website.", priority: .suggested, actionItem: "Create a portfolio using GitHub Pages or Vercel to showcase your projects."))
        }

        return gaps.sorted { $0.priority == .critical && $1.priority != .critical }
    }

    private func identifyStrengths(education: Double, dsa: Double, tech: Double, projects: Double, internships: Double) -> [String] {
        var strengths: [String] = []
        if education >= 18 { strengths.append("Strong academic foundation with high CGPA and board scores.") }
        if dsa >= 14 { strengths.append("Excellent DSA skills with broad topic coverage and high problem count.") }
        if tech >= 10 { strengths.append("Diverse and modern technical stack spanning multiple frameworks.") }
        if projects >= 7 { strengths.append("Rich project portfolio demonstrating practical application skills.") }
        if internships >= 6 { strengths.append("Solid industry exposure through multiple internship roles.") }
        if formData.softSkills.communicationRating >= 4 { strengths.append("Strong communication and soft skill profile.") }
        if formData.certifications.count >= 2 { strengths.append("Well-certified with multiple validated credentials.") }
        if formData.socialHandles.github != "" && formData.socialHandles.linkedIn != "" { strengths.append("Active and professional online presence across platforms.") }
        if strengths.isEmpty { strengths.append("You've taken the first step by completing the assessment!") }
        return strengths
    }

    private func generateRecommendation(tier: PlacementTier, probability: Double) -> String {
        switch tier {
        case .high:
            return "You are well-positioned for top-tier placements. Focus on cracking system design interviews and behavioural rounds for FAANG/MAANG companies. Polish your communication and target companies early in their hiring season."
        case .medium:
            return "You have a solid foundation with room for targeted improvement. Prioritize solving 200+ LeetCode problems (medium difficulty), build one full-stack project, and apply for internships to gain industry exposure. Product-based companies in the 12-20 LPA range are your sweet spot."
        case .low:
            return "Start with service-based companies while actively upskilling. Dedicate 3-4 hours daily to DSA, complete one backend framework course, and build your GitHub profile with consistent contributions. You can significantly improve your profile within 3-6 months."
        }
    }

    private func estimatePackage(probability: Double) -> ClosedRange<Double> {
        if probability >= 80 { return 18.0...45.0 }
        else if probability >= 65 { return 12.0...22.0 }
        else if probability >= 50 { return 6.0...12.0 }
        else { return 3.5...7.0 }
    }
}
