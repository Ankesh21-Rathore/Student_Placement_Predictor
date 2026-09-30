import SwiftUI

// MARK: - Main Form Container
struct MainFormView: View {
    @StateObject private var vm = PlacementPredictorViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var showExitAlert = false

    var body: some View {
        ZStack {
            AmbientGlowBackground(color1: .brandPrimary, color2: Color(hex: "#4DA8FF"))

            VStack(spacing: 0) {
                // Top Navigation Bar
                FormNavBar(vm: vm, showExitAlert: $showExitAlert)

                // Step Progress Indicator
                StepProgressHeader(vm: vm)

                // Page Content
                TabView(selection: $vm.currentStep) {
                    ForEach(0..<vm.totalSteps, id: \.self) { step in
                        FormStepPage(vm: vm, step: step)
                            .tag(step)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.spring(response: 0.5, dampingFraction: 0.85), value: vm.currentStep)

                // Bottom Navigation
                FormBottomNavigation(vm: vm)
            }

            // Analysis Overlay
            if vm.isAnalyzing {
                AnalysisLoadingOverlay(vm: vm)
                    .transition(.opacity)
                    .zIndex(10)
            }
        }
        .fullScreenCover(isPresented: $vm.showResult) {
            if let result = vm.result {
                ResultDashboardView(result: result)
            }
        }
        .alert("Exit Form?", isPresented: $showExitAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Exit", role: .destructive) { dismiss() }
        } message: {
            Text("Your progress will be lost. Are you sure you want to exit?")
        }
    }
}


// MARK: - Step Progress Header
struct StepProgressHeader: View {
    @ObservedObject var vm: PlacementPredictorViewModel

    var body: some View {
        VStack(spacing: 12) {
            // Linear Progress
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.08))
                    RoundedRectangle(cornerRadius: 4)
                        .fill(AppGradients.brandPrimary)
                        .frame(width: geo.size.width * vm.progressPercent)
                        .animation(.spring(response: 0.5, dampingFraction: 0.85), value: vm.progressPercent)
                }
            }
            .frame(height: 4)
            .padding(.horizontal, 20)

            // Step Dots
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(FormStep.allSteps) { step in
                        Button { vm.jumpToStep(step.id) } label: {
                            VStack(spacing: 4) {
                                ZStack {
                                    Circle()
                                        .fill(
                                            vm.currentStep == step.id
                                            ? AnyShapeStyle(AppGradients.brandPrimary)
                                            : vm.currentStep > step.id
                                            ? AnyShapeStyle(AppGradients.brandSuccess)
                                            : AnyShapeStyle(Color.white.opacity(0.08))
                                        )
                                        .frame(width: 32, height: 32)
                                    if vm.currentStep > step.id {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(.white)
                                    } else {
                                        Image(systemName: step.icon)
                                            .font(.system(size: 13, weight: .semibold))
                                            .foregroundColor(vm.currentStep == step.id ? .white : .textMuted)
                                    }
                                }
                                Text(step.title)
                                    .font(AppFont.caption(9))
                                    .foregroundColor(vm.currentStep == step.id ? .textPrimary : .textMuted)
                                    .lineLimit(1)
                                    .frame(width: 50)
                            }
                        }
                        .animation(.spring(response: 0.3, dampingFraction: 0.75), value: vm.currentStep)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 8)
            }
        }
    }
}

// MARK: - Bottom Navigation
struct FormBottomNavigation: View {
    @ObservedObject var vm: PlacementPredictorViewModel
    let isLastStep: Bool

    init(vm: PlacementPredictorViewModel) {
        self.vm = vm
        self.isLastStep = vm.currentStep == vm.totalSteps - 1
    }

    var body: some View {
        HStack(spacing: 14) {
            if vm.currentStep > 0 {
                Button { vm.goToPreviousStep() } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                }
                .buttonStyle(SecondaryButtonStyle())
                .frame(maxWidth: 120)
            }

            if isLastStep {
                Button { vm.submitForm() } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "sparkles")
                        Text("Analyse My Profile")
                    }
                }
                .buttonStyle(PrimaryButtonStyle())
            } else {
                Button { vm.goToNextStep() } label: {
                    HStack(spacing: 6) {
                        Text("Next")
                        Image(systemName: "chevron.right")
                    }
                }
                .buttonStyle(PrimaryButtonStyle())
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            Rectangle()
                .fill(.ultraThinMaterial)
                .overlay(Rectangle().fill(Color.white.opacity(0.04)))
                .ignoresSafeArea(edges: .bottom)
        )
    }
}

// MARK: - Step Page Router
struct FormStepPage: View {
    @ObservedObject var vm: PlacementPredictorViewModel
    let step: Int

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                // Step Hero Header
                FormStepHero(step: FormStep.allSteps[step])

                Group {
                    switch step {
                    case 0:  EducationStepView(data: $vm.formData.education)
                    case 1:  InternshipsStepView(data: $vm.formData.internships)
                    case 2:  ProjectsStepView(data: $vm.formData.projects)
                    case 3:  DSAStepView(data: $vm.formData.dsa)
                    case 4:  CertificationsStepView(data: $vm.formData.certifications)
                    case 5:  SoftSkillsStepView(data: $vm.formData.softSkills)
                    case 6:  TechnicalSkillsStepView(data: $vm.formData.technicalSkills)
                    case 7:  ResumeStepView(data: $vm.formData.resume)
                    case 8:  PortfolioStepView(data: $vm.formData.portfolio)
                    case 9:  AchievementsStepView(data: $vm.formData.achievements)
                    case 10: CompetitiveExamsStepView(data: $vm.formData.competitiveExams)
                    case 11: SocialHandlesStepView(data: $vm.formData.socialHandles)
                    case 12: ToolsStepView(data: $vm.formData.tools)
                    default: EmptyView()
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 100)
            }
        }
    }
}

// MARK: - Step Hero
struct FormStepHero: View {
    let step: FormStep
    @State private var appear = false

    var body: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(step.accentColor.opacity(0.15))
                    .frame(width: 72, height: 72)
                    .blur(radius: 8)
                Circle()
                    .fill(step.accentColor.opacity(0.2))
                    .frame(width: 60, height: 60)
                Image(systemName: step.icon)
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundColor(step.accentColor)
            }
            .scaleEffect(appear ? 1 : 0.6)
            .opacity(appear ? 1 : 0)

            VStack(spacing: 4) {
                Text(step.title)
                    .font(AppFont.headline(24))
                    .foregroundColor(.textPrimary)
                Text(step.subtitle)
                    .font(AppFont.body())
                    .foregroundColor(.textSecondary)
            }
            .opacity(appear ? 1 : 0)
            .offset(y: appear ? 0 : 10)
        }
        .padding(.top, 24)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.05)) {
                appear = true
            }
        }
        .onDisappear { appear = false }
    }
}

// MARK: - Premium Academic Score Input Card
struct AcademicScoreInputCard: View {
    let label: String
    let subtitle: String
    let icon: String
    let color: Color
    let unit: String
    let range: ClosedRange<Double>
    let step: Double
    @Binding var value: Double

    @State private var isEditing = false
    @State private var editText  = ""
    @FocusState private var focused: Bool

    private var normalised: Double {
        guard range.upperBound > range.lowerBound else { return 0 }
        return (value - range.lowerBound) / (range.upperBound - range.lowerBound)
    }

    private var grade: (label: String, color: Color) {
        switch normalised {
        case 0.85...: return ("Excellent", Color(hex: "#43E97B"))
        case 0.70...: return ("Good",      Color(hex: "#4DA8FF"))
        case 0.55...: return ("Average",   Color(hex: "#F7C948"))
        default:      return ("Low",       Color(hex: "#FF6584"))
        }
    }

    private var displayText: String {
        step < 1 ? String(format: "%.1f", value) : "\(Int(value))"
    }

    var body: some View {
        HStack(spacing: 16) {
            // Left: icon + labels
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(color.opacity(0.15))
                        .frame(width: 44, height: 44)
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(color)
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text(label)
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(.textPrimary)
                    Text(subtitle)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.textMuted)
                }
            }

            Spacer()

            // Right: grade pill + value tappable badge
            VStack(alignment: .trailing, spacing: 5) {
                Text(grade.label)
                    .font(.system(size: 10, weight: .black))
                    .foregroundColor(grade.color)
                    .padding(.horizontal, 8).padding(.vertical, 3)
                    .background(grade.color.opacity(0.14))
                    .clipShape(Capsule())
                    .animation(.spring(response: 0.3), value: grade.label)

                // Tappable value badge → opens inline editor
                Button {
                    editText = displayText
                    isEditing = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { focused = true }
                } label: {
                    HStack(spacing: 3) {
                        if isEditing {
                            TextField("", text: $editText)
                                .focused($focused)
                                .keyboardType(.decimalPad)
                                .font(.system(size: 20, weight: .black, design: .rounded))
                                .foregroundColor(color)
                                .frame(width: 56)
                                .multilineTextAlignment(.trailing)
                                .onSubmit { commitEdit() }
                        } else {
                            Text(displayText)
                                .font(.system(size: 20, weight: .black, design: .rounded))
                                .foregroundColor(color)
                                .contentTransition(.numericText())
                                .animation(.spring(response: 0.3), value: value)
                        }
                        Text(unit)
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundColor(color.opacity(0.7))
                    }
                    .padding(.horizontal, 12).padding(.vertical, 7)
                    .background(color.opacity(0.10))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(color.opacity(isEditing ? 0.6 : 0.25), lineWidth: 1.5))
                }
                .buttonStyle(.plain)
            }

            // Stepper buttons
            VStack(spacing: 6) {
                Button {
                    withAnimation(.spring(response: 0.2)) {
                        value = min(range.upperBound, snapToStep(value + step))
                    }
                } label: {
                    Image(systemName: "chevron.up")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.textSecondary)
                        .frame(width: 28, height: 24)
                        .background(Color.white.opacity(0.06))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                .buttonStyle(.plain)

                Button {
                    withAnimation(.spring(response: 0.2)) {
                        value = max(range.lowerBound, snapToStep(value - step))
                    }
                } label: {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.textSecondary)
                        .frame(width: 28, height: 24)
                        .background(Color.white.opacity(0.06))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.04))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            // Thin progress underline
            VStack {
                Spacer()
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(color.opacity(0.08)).frame(height: 3)
                        Capsule().fill(color.opacity(0.6))
                            .frame(width: geo.size.width * normalised, height: 3)
                            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: value)
                    }
                }
                .frame(height: 3)
                .padding(.horizontal, 16)
                .padding(.bottom, 0)
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
        )
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.08), lineWidth: 1))
        .onChange(of: focused) { isFocused in
            if !isFocused { commitEdit() }
        }
    }

    private func snapToStep(_ raw: Double) -> Double {
        let steps = round((raw - range.lowerBound) / step)
        return range.lowerBound + steps * step
    }

    private func commitEdit() {
        if let parsed = Double(editText.replacingOccurrences(of: ",", with: ".")) {
            let clamped = max(range.lowerBound, min(range.upperBound, snapToStep(parsed)))
            withAnimation(.spring(response: 0.3)) { value = clamped }
        }
        isEditing = false
    }
}

// MARK: - Step 0: Education
struct EducationStepView: View {
    @Binding var data: EducationInfo

    var body: some View {
        VStack(spacing: 20) {

            // ── Academic Scores ────────────────────────────────────
            FormCard {
                VStack(spacing: 4) {
                    SectionHeader(title: "Academic Scores", icon: "graduationcap.fill")
                        .padding(.bottom, 10)

                    AcademicScoreInputCard(
                        label: "10th Board",
                        subtitle: "Secondary school percentage",
                        icon: "building.columns",
                        color: .brandPrimary,
                        unit: "%",
                        range: 0...100,
                        step: 0.5,
                        value: $data.tenthPercent
                    )
                    Divider().background(Color.white.opacity(0.06))

                    AcademicScoreInputCard(
                        label: "12th Board",
                        subtitle: "Senior secondary percentage",
                        icon: "building.columns.fill",
                        color: Color(hex: "#4DA8FF"),
                        unit: "%",
                        range: 0...100,
                        step: 0.5,
                        value: $data.twelfthPercent
                    )
                    Divider().background(Color.white.opacity(0.06))

                    AcademicScoreInputCard(
                        label: "B.Tech CGPA",
                        subtitle: "Current cumulative GPA",
                        icon: "graduationcap.fill",
                        color: Color(hex: "#43E97B"),
                        unit: "/10",
                        range: 0...10,
                        step: 0.1,
                        value: $data.btechCGPA
                    )
                }
            }

            // ── Degree Details ─────────────────────────────────────
            FormCard {
                VStack(spacing: 14) {
                    SectionHeader(title: "Degree Details", icon: "building.columns.fill")

                    // Branch + Year side by side
                    HStack(spacing: 12) {
                        // Branch picker
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Branch")
                                .font(AppFont.caption(11))
                                .foregroundColor(.textMuted)
                            Menu {
                                ForEach(BTechBranch.allCases) { branch in
                                    Button(branch.rawValue) { data.btechBranch = branch }
                                }
                            } label: {
                                HStack(spacing: 6) {
                                    Text(data.btechBranch.shortName)
                                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                                        .foregroundColor(.textPrimary)
                                        .lineLimit(1)
                                    Spacer(minLength: 0)
                                    Image(systemName: "chevron.up.chevron.down")
                                        .font(.system(size: 10, weight: .semibold))
                                        .foregroundColor(.brandPrimary)
                                }
                                .padding(.horizontal, 12).padding(.vertical, 11)
                                .background(Color.white.opacity(0.06))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.brandPrimary.opacity(0.25), lineWidth: 1))
                            }
                        }
                        .frame(maxWidth: .infinity)

                        // Graduation Year picker
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Grad Year")
                                .font(AppFont.caption(11))
                                .foregroundColor(.textMuted)
                            Menu {
                                ForEach(2020...2030, id: \.self) { year in
                                    Button(String(year)) { data.graduationYear = year }
                                }
                            } label: {
                                HStack(spacing: 6) {
                                    Text(String(data.graduationYear))
                                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                                        .foregroundColor(.textPrimary)
                                    Spacer(minLength: 0)
                                    Image(systemName: "chevron.up.chevron.down")
                                        .font(.system(size: 10, weight: .semibold))
                                        .foregroundColor(.brandPrimary)
                                }
                                .padding(.horizontal, 12).padding(.vertical, 11)
                                .background(Color.white.opacity(0.06))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.brandPrimary.opacity(0.25), lineWidth: 1))
                            }
                        }
                        .frame(maxWidth: 110)
                    }

                    // Full branch name info row
                    HStack(spacing: 8) {
                        Image(systemName: "info.circle")
                            .font(.system(size: 11))
                            .foregroundColor(.textMuted)
                        Text(data.btechBranch.rawValue)
                            .font(AppFont.caption(11))
                            .foregroundColor(.textMuted)
                            .lineLimit(1)
                    }
                }
            }
        }
    }
}

// MARK: - Step 1: Internships
struct InternshipsStepView: View {
    @Binding var data: [InternshipInfo]

    var body: some View {
        VStack(spacing: 16) {
            if data.isEmpty {
                EmptyStateCard(
                    icon: "briefcase",
                    title: "No internships added",
                    subtitle: "Add your work experience to boost your prediction score."
                )
            }

            ForEach($data) { $internship in
                InternshipCard(data: $internship) {
                    withAnimation(.spring(response: 0.4)) {
                        data.removeAll { $0.id == internship.id }
                    }
                }
            }

            Button {
                withAnimation(.spring(response: 0.4)) {
                    data.append(InternshipInfo())
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                    Text("Add Internship")
                }
            }
            .buttonStyle(SecondaryButtonStyle())
        }
    }
}

struct InternshipCard: View {
    @Binding var data: InternshipInfo
    let onDelete: () -> Void

    var body: some View {
        FormCard {
            VStack(spacing: 16) {
                HStack {
                    Label("Internship Details", systemImage: "briefcase.fill")
                        .font(AppFont.subheadline(14))
                        .foregroundColor(.textPrimary)
                    Spacer()
                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .foregroundColor(.dangerRed)
                            .padding(8)
                            .background(Color.dangerRed.opacity(0.1))
                            .clipShape(Circle())
                    }
                }

                FormTextField(label: "Company Name", placeholder: "e.g. Google, Infosys", icon: "building.2", text: $data.companyName)
                FormTextField(label: "Role / Designation", placeholder: "e.g. SDE Intern, Data Analyst", icon: "person.text.rectangle", text: $data.techRole)
                FormTextField(label: "Duration", placeholder: "e.g. 3 months, 6 weeks", icon: "calendar", text: $data.duration)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Internship Type").font(AppFont.caption()).foregroundColor(.textSecondary)
                    HStack(spacing: 10) {
                        ForEach(InternshipType.allCases, id: \.self) { type in
                            Button {
                                withAnimation(.spring(response: 0.25)) { data.type = type }
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: type.icon).font(.system(size: 12))
                                    Text(type.rawValue).font(AppFont.caption(13))
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(data.type == type ? Color.brandPrimary.opacity(0.85) : Color.white.opacity(0.08))
                                .foregroundColor(data.type == type ? .white : .textSecondary)
                                .clipShape(Capsule())
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Step 2: Projects
struct ProjectsStepView: View {
    @Binding var data: [ProjectInfo]

    var body: some View {
        VStack(spacing: 16) {
            if data.isEmpty {
                EmptyStateCard(icon: "hammer", title: "No projects added", subtitle: "Projects demonstrate your practical skills to recruiters.")
            }
            ForEach($data) { $project in
                ProjectCard(data: $project) {
                    withAnimation(.spring(response: 0.4)) {
                        data.removeAll { $0.id == project.id }
                    }
                }
            }
            Button {
                withAnimation(.spring(response: 0.4)) { data.append(ProjectInfo()) }
            } label: {
                HStack(spacing: 8) { Image(systemName: "plus.circle.fill"); Text("Add Project") }
            }
            .buttonStyle(SecondaryButtonStyle())
        }
    }
}

struct ProjectCard: View {
    @Binding var data: ProjectInfo
    let onDelete: () -> Void
    
    var body: some View {
        FormCard {
            VStack(spacing: 14) {
                HStack {
                    Label("Project Details", systemImage: "hammer.fill")
                        .font(AppFont.subheadline(14)).foregroundColor(.textPrimary)
                    Spacer()
                    Button(action: onDelete) {
                        Image(systemName: "trash").foregroundColor(.dangerRed)
                            .padding(8).background(Color.dangerRed.opacity(0.1)).clipShape(Circle())
                    }
                }
                FormTextField(label: "Project Name", placeholder: "e.g. PlacementAI App", icon: "text.cursor", text: $data.name)
                FormTextField(label: "GitHub Link", placeholder: "https://github.com/...", icon: "link", text: $data.githubLink)
                FormTextField(label: "Tech Stack / Tools", placeholder: "e.g. Swift, Firebase, CoreML", icon: "iphone.gen3", text: $data.techStack)
                Toggle(isOn: $data.isDeployed) {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.icloud.fill")
                        Text("Live / Deployed").font(.system(size: 13, weight: .semibold))
                    }
                }
                VStack(alignment: .leading, spacing: 8) {
                    Text("Real-life Use Case").font(AppFont.caption()).foregroundColor(.textSecondary)
                    ZStack(alignment: .topLeading) {
                        if data.realLifeUseCase.isEmpty {
                            Text("Describe the problem it solves...")
                                .font(AppFont.body()).foregroundColor(.textMuted).padding(.top, 12).padding(.leading, 4)
                        }
                        TextEditor(text: $data.realLifeUseCase)
                            .font(AppFont.body()).foregroundColor(.textPrimary)
                            .frame(minHeight: 70).scrollContentBackground(.hidden)
                        
                            .padding(12).background(Color.white.opacity(0.06))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.12), lineWidth: 1))
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Project Type").font(AppFont.caption()).foregroundColor(.textSecondary)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(ProjectType.allCases, id: \.self) { type in
                                    Button {
                                        withAnimation(.spring(response: 0.25)) { data.type = type }
                                    } label: {
                                        HStack(spacing: 5) {
                                            Image(systemName: type.icon).font(.system(size: 11))
                                            Text(type.rawValue).font(AppFont.caption(12))
                                        }
                                        .padding(.horizontal, 12).padding(.vertical, 7)
                                        .background(data.type == type ? Color.brandOrange.opacity(0.85) : Color.white.opacity(0.08))
                                        .foregroundColor(data.type == type ? .white : .textSecondary)
                                        .clipShape(Capsule())
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Step 3: DSA
struct DSAStepView: View {
    @Binding var data: DSAInfo
    let columns = [GridItem(.adaptive(minimum: 100))]
    @State private var showDSAPopup = false
    var body: some View {
        VStack(spacing: 20) {
            FormCard {
                // 1. The Trigger Button (Styled like a LabeledPicker)
                Button(action: {
                    showDSAPopup = true
                }) {
                    HStack {
                        SectionHeader(title: "DSA Topics Known", icon: "list.bullet.clipboard.fill")
                        
                        Spacer()
                        
                        // Shows how many are currently selected
                        Text("\(data.topicsKnown.count) Selected")
                            .font(AppFont.caption())
                            .foregroundColor(.secondary)
                        
                        Image(systemName: "chevron.up.chevron.down") // Native picker icon
                            .foregroundColor(.secondary)
                            .font(.system(size: 14))
                    }
                }
            }
            // 2. The Popup View
            .sheet(isPresented: $showDSAPopup) {
                NavigationView {
                    ScrollView {
                        VStack(spacing: 16) {
                            LazyVGrid(columns: columns, spacing: 8) {
                                ForEach(DSATopic.allCases, id: \.self) { topic in
                                    ChipTag(
                                        label: topic.rawValue,
                                        isSelected: data.topicsKnown.contains(topic),
                                        color: .successGreen
                                    ) {
                                        withAnimation(.spring(response: 0.25)) {
                                            if data.topicsKnown.contains(topic) {
                                                data.topicsKnown.remove(topic)
                                            } else {
                                                data.topicsKnown.insert(topic)
                                            }
                                        }
                                    }
                                }
                            }
                            
                            HStack {
                                Text("\(data.topicsKnown.count) / \(DSATopic.allCases.count) selected")
                                    .font(AppFont.caption())
                                    .foregroundColor(.textMuted)
                                Spacer()
                            }
                        }
                        .padding()
                    }
                    .navigationTitle("DSA Topics")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Done") {
                                showDSAPopup = false
                            }
                            .fontWeight(.bold)
                        }
                    }
                }
                .presentationDetents([.medium, .large]) // Makes it a nice half-screen popup on iOS 16+
            }

            FormCard {
                VStack(spacing: 16) {
                    SectionHeader(title: "Proficiency", icon: "chart.bar.fill")

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Expertise Level").font(AppFont.caption()).foregroundColor(.textSecondary)
                        ForEach(DSAExpertise.allCases, id: \.self) { level in
                            Button {
                                withAnimation(.spring(response: 0.25)) { data.expertiseLevel = level }
                            } label: {
                                HStack(spacing: 12) {
                                    ZStack {
                                        Circle().fill(data.expertiseLevel == level ? Color.brandPrimary : Color.white.opacity(0.08))
                                            .frame(width: 22, height: 22)
                                        if data.expertiseLevel == level {
                                            Circle().fill(Color.white).frame(width: 8, height: 8)
                                        }
                                    }
                                    Text(level.rawValue).font(AppFont.body()).foregroundColor(.textPrimary)
                                    Spacer()
                                }
                                .padding(.horizontal, 14).padding(.vertical, 10)
                                .background(data.expertiseLevel == level ? Color.brandPrimary.opacity(0.12) : Color.white.opacity(0.04))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                        }
                    }

                    Text("Number of solved problems")
                        .foregroundStyle(.secondary)
                    TextField("0", value: $data.problemsSolved, format: .number)
                        .padding(.horizontal, 14).padding(.vertical, 10)
                        .background(Color.white.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }

            FormCard {
                VStack(spacing: 14) {
                    SectionHeader(title: "Coding Profiles", icon: "link.circle.fill")
                    FormTextField(label: "LeetCode", placeholder: "leetcode.com/username", icon: "chevron.left.forwardslash.chevron.right", text: $data.leetcodeProfile)
                    FormTextField(label: "HackerRank", placeholder: "hackerrank.com/username", icon: "h.circle", text: $data.hackerrankProfile)
                    FormTextField(label: "Codeforces", placeholder: "codeforces.com/profile/...", icon: "c.circle", text: $data.codeforcesProfile)
                    FormTextField(label: "CodeChef", placeholder: "codechef.com/users/...", icon: "fork.knife", text: $data.codechefProfile)
                }
            }
        }
    }
}

// MARK: - Step 4: Certifications
struct CertificationsStepView: View {
    @Binding var data: [CertificationInfo]

    var body: some View {
        VStack(spacing: 16) {
            if data.isEmpty {
                EmptyStateCard(icon: "rosette", title: "No certifications added", subtitle: "Certifications validate your skills and boost credibility.")
            }
            ForEach($data) { $cert in
                CertificationCard(data: $cert) {
                    withAnimation(.spring(response: 0.4)) { data.removeAll { $0.id == cert.id } }
                }
            }
            Button {
                withAnimation(.spring(response: 0.4)) { data.append(CertificationInfo()) }
            } label: {
                HStack(spacing: 8) { Image(systemName: "plus.circle.fill"); Text("Add Certification") }
            }
            .buttonStyle(SecondaryButtonStyle())
        }
    }
}

struct CertificationCard: View {
    @Binding var data: CertificationInfo
    let onDelete: () -> Void

    var body: some View {
        FormCard {
            VStack(spacing: 14) {
                HStack {
                    Label("Certification", systemImage: "rosette").font(AppFont.subheadline(14)).foregroundColor(.textPrimary)
                    Spacer()
                    Button(action: onDelete) {
                        Image(systemName: "trash").foregroundColor(.dangerRed)
                            .padding(8).background(Color.dangerRed.opacity(0.1)).clipShape(Circle())
                    }
                }
                FormTextField(label: "Certification Name", placeholder: "e.g. AWS Solutions Architect", icon: "rosette", text: $data.name)
                FormTextField(label: "Issuing Provider", placeholder: "e.g. Amazon, Google, Coursera", icon: "building.2", text: $data.provider)
                FormTextField(label: "Certificate Link", placeholder: "https://...", icon: "link", text: $data.certificationLink)

                // Mock Image Attachment
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        data.hasImageAttached.toggle()
                        data.imageAttachmentName = data.hasImageAttached ? "certificate_\(data.name.lowercased().replacingOccurrences(of: " ", with: "_")).pdf" : ""
                    }
                } label: {
                    HStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(data.hasImageAttached ? Color.successGreen.opacity(0.15) : Color.white.opacity(0.06))
                                .frame(width: 44, height: 44)
                            Image(systemName: data.hasImageAttached ? "checkmark.circle.fill" : "paperclip")
                                .foregroundColor(data.hasImageAttached ? .successGreen : .textMuted)
                                .font(.system(size: 18))
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text(data.hasImageAttached ? "Certificate Attached" : "Attach Certificate Image")
                                .font(AppFont.body(14)).foregroundColor(data.hasImageAttached ? .successGreen : .textSecondary)
                            if data.hasImageAttached {
                                Text(data.imageAttachmentName).font(AppFont.caption(11)).foregroundColor(.textMuted).lineLimit(1)
                            } else {
                                Text("PDF, JPG or PNG • Max 5MB").font(AppFont.caption(11)).foregroundColor(.textMuted)
                            }
                        }
                        Spacer()
                        Image(systemName: "chevron.right").foregroundColor(.textMuted)
                    }
                    .padding(14).background(Color.white.opacity(0.04))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(
                        data.hasImageAttached ? Color.successGreen.opacity(0.4) : Color.white.opacity(0.08),
                        lineWidth: 1
                    ))
                }
            }
        }
    }
}

// MARK: - Step 5: Soft Skills
struct SoftSkillsStepView: View {
    @Binding var data: SoftSkillsInfo

    var body: some View {
        VStack(spacing: 20) {
            FormCard {
                VStack(spacing: 20) {
                    SectionHeader(title: "Communication Skills", icon: "bubble.left.and.bubble.right.fill")

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Communication Rating (1–5)")
                            .font(AppFont.caption()).foregroundColor(.textSecondary)
                        StarRatingView(rating: $data.communicationRating, color: .brandGold)
                        Text(communicationLabel(data.communicationRating))
                            .font(AppFont.caption(12)).foregroundColor(.textMuted)
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Teamwork Rating (1–5)")
                            .font(AppFont.caption()).foregroundColor(.textSecondary)
                        StarRatingView(rating: $data.teamworkRating, color: .infoBlue)
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Leadership Rating (1–5)")
                            .font(AppFont.caption()).foregroundColor(.textSecondary)
                        StarRatingView(rating: $data.leadershipRating, color: .brandSecondary)
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Problem Solving Rating (1–5)")
                            .font(AppFont.caption()).foregroundColor(.textSecondary)
                        StarRatingView(rating: $data.problemSolvingRating, color: .successGreen)
                    }
                }
            }

            FormCard {
                VStack(spacing: 16) {
                    SectionHeader(title: "Aptitude Test Score", icon: "brain")
                    LabeledSlider(label: "Your Score", value: $data.aptitudeScore, range: 0...data.aptitudeMaxScore, step: 1, unit: " pts", color: Color(hex: "#F7C948"))

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Maximum Marks").font(AppFont.caption()).foregroundColor(.textSecondary)
                        Stepper("\(Int(data.aptitudeMaxScore)) marks", value: $data.aptitudeMaxScore, in: 10...500, step: 10)
                            .font(AppFont.body()).foregroundColor(.textPrimary)
                            .padding(14).background(Color.white.opacity(0.06))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    if data.aptitudeMaxScore > 0 {
                        let percentage = (data.aptitudeScore / data.aptitudeMaxScore) * 100
                        HStack {
                            Text("Percentage: \(String(format: "%.1f", percentage))%")
                                .font(AppFont.subheadline(14)).foregroundColor(.textPrimary)
                            Spacer()
                            Text(percentage >= 70 ? "Good" : percentage >= 50 ? "Average" : "Needs Work")
                                .font(AppFont.caption(12))
                                .foregroundColor(percentage >= 70 ? .successGreen : percentage >= 50 ? .warningAmber : .dangerRed)
                                .padding(.horizontal, 10).padding(.vertical, 4)
                                .background((percentage >= 70 ? Color.successGreen : percentage >= 50 ? Color.warningAmber : Color.dangerRed).opacity(0.12))
                                .clipShape(Capsule())
                        }
                    }
                }
            }
        }
    }

    private func communicationLabel(_ rating: Int) -> String {
        switch rating {
        case 1: return "Needs significant improvement"
        case 2: return "Below average — work on clarity"
        case 3: return "Average — room to improve"
        case 4: return "Good — can express ideas well"
        case 5: return "Excellent communicator"
        default: return ""
        }
    }
}

// MARK: - Step 6: Technical Skills
struct TechnicalSkillsStepView: View {
    @Binding var data: TechnicalSkillsInfo
    let columns = [GridItem(.adaptive(minimum: 95))]
    @State private var showLanguagesPopup = false
    @State private var showFrameworksPopup = false
    @State private var showCloudPopup = false
    @State private var showDatabasesPopup = false
    
    var body: some View {
        VStack(spacing: 20) {
            FormCard {
                // 1. The Trigger Button
                Button(action: {
                    showLanguagesPopup = true
                }) {
                    HStack {
                        SectionHeader(title: "Programming Languages", icon: "chevron.left.forwardslash.chevron.right")
                        
                        Spacer()
                        
                        Text("\(data.languages.count) Selected")
                            .font(AppFont.caption())
                            .foregroundColor(.secondary)
                        
                        Image(systemName: "chevron.up.chevron.down")
                            .foregroundColor(.secondary)
                            .font(.system(size: 14))
                    }
                }
            }
            // 2. The Popup View
            .sheet(isPresented: $showLanguagesPopup) {
                NavigationView {
                    ScrollView {
                        VStack(spacing: 16) {
                            LazyVGrid(columns: columns, spacing: 8) {
                                ForEach(ProgrammingLanguage.allCases, id: \.self) { lang in
                                    ChipTag(
                                        label: lang.rawValue,
                                        isSelected: data.languages.contains(lang),
                                        color: .brandPrimary
                                    ) {
                                        withAnimation(.spring(response: 0.25)) {
                                            if data.languages.contains(lang) {
                                                data.languages.remove(lang)
                                            } else {
                                                data.languages.insert(lang)
                                            }
                                        }
                                    }
                                }
                            }
                            
                            Text("\(data.languages.count) selected")
                                .font(AppFont.caption())
                                .foregroundColor(.textMuted)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding()
                    }
                    .navigationTitle("Languages")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Done") {
                                showLanguagesPopup = false
                            }
                            .fontWeight(.bold)
                        }
                    }
                }
                .presentationDetents([.medium, .large]) // Supports drag-to-resize on iOS 16+
            }

            FormCard {
                // 1. The Trigger Button
                Button(action: {
                    showFrameworksPopup = true
                }) {
                    HStack {
                        SectionHeader(title: "Frameworks & Libraries", icon: "rectangle.3.group.fill")
                        
                        Spacer()
                        
                        Text("\(data.frameworks.count) Selected")
                            .font(AppFont.caption())
                            .foregroundColor(.secondary)
                        
                        Image(systemName: "chevron.up.chevron.down")
                            .foregroundColor(.secondary)
                            .font(.system(size: 14))
                    }
                }
            }
            // 2. The Popup View
            .sheet(isPresented: $showFrameworksPopup) {
                NavigationView {
                    ScrollView {
                        VStack(spacing: 16) {
                            LazyVGrid(columns: columns, spacing: 8) {
                                ForEach(Framework.allCases, id: \.self) { fw in
                                    ChipTag(
                                        label: fw.rawValue,
                                        isSelected: data.frameworks.contains(fw),
                                        color: Color(hex: "#4DA8FF")
                                    ) {
                                        withAnimation(.spring(response: 0.25)) {
                                            if data.frameworks.contains(fw) {
                                                data.frameworks.remove(fw)
                                            } else {
                                                data.frameworks.insert(fw)
                                            }
                                        }
                                    }
                                }
                            }
                            
                            HStack {
                                Text("\(data.frameworks.count) / \(Framework.allCases.count) selected")
                                    .font(AppFont.caption())
                                    .foregroundColor(.textMuted)
                                Spacer()
                            }
                        }
                        .padding()
                    }
                    .navigationTitle("Frameworks")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Done") {
                                showFrameworksPopup = false
                            }
                            .fontWeight(.bold)
                        }
                    }
                }
                .presentationDetents([.medium, .large])
            }

            FormCard {
                // 1. The Trigger Button
                Button(action: {
                    showDatabasesPopup = true
                }) {
                    HStack {
                        SectionHeader(title: "Databases", icon: "cylinder.split.1x2.fill")
                        
                        Spacer()
                        
                        Text("\(data.databases.count) Selected")
                            .font(AppFont.caption())
                            .foregroundColor(.secondary)
                        
                        Image(systemName: "chevron.up.chevron.down")
                            .foregroundColor(.secondary)
                            .font(.system(size: 14))
                    }
                }
            }
            // 2. The Popup View
            .sheet(isPresented: $showDatabasesPopup) {
                NavigationView {
                    ScrollView {
                        VStack(spacing: 16) {
                            LazyVGrid(columns: columns, spacing: 8) {
                                ForEach(Database.allCases, id: \.self) { db in
                                    ChipTag(
                                        label: db.rawValue,
                                        isSelected: data.databases.contains(db),
                                        color: Color(hex: "#43E97B")
                                    ) {
                                        withAnimation(.spring(response: 0.25)) {
                                            if data.databases.contains(db) {
                                                data.databases.remove(db)
                                            } else {
                                                data.databases.insert(db)
                                            }
                                        }
                                    }
                                }
                            }
                            
                            HStack {
                                Text("\(data.databases.count) / \(Database.allCases.count) selected")
                                    .font(AppFont.caption())
                                    .foregroundColor(.textMuted)
                                Spacer()
                            }
                        }
                        .padding()
                    }
                    .navigationTitle("Databases")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Done") {
                                showDatabasesPopup = false
                            }
                            .fontWeight(.bold)
                        }
                    }
                }
                .presentationDetents([.medium, .large])
            }

            FormCard {
                // 1. The Trigger Button
                Button(action: {
                    showCloudPopup = true
                }) {
                    HStack {
                        SectionHeader(title: "Cloud Platforms", icon: "cloud.fill")
                        
                        Spacer()
                        
                        Text("\(data.cloudPlatforms.count) Selected")
                            .font(AppFont.caption())
                            .foregroundColor(.secondary)
                        
                        Image(systemName: "chevron.up.chevron.down")
                            .foregroundColor(.secondary)
                            .font(.system(size: 14))
                    }
                }
            }
            // 2. The Popup View
            .sheet(isPresented: $showCloudPopup) {
                NavigationView {
                    ScrollView {
                        VStack(spacing: 16) {
                            LazyVGrid(columns: columns, spacing: 8) {
                                ForEach(CloudPlatform.allCases, id: \.self) { cp in
                                    ChipTag(
                                        label: cp.rawValue,
                                        isSelected: data.cloudPlatforms.contains(cp),
                                        color: .brandOrange
                                    ) {
                                        withAnimation(.spring(response: 0.25)) {
                                            if data.cloudPlatforms.contains(cp) {
                                                data.cloudPlatforms.remove(cp)
                                            } else {
                                                data.cloudPlatforms.insert(cp)
                                            }
                                        }
                                    }
                                }
                            }
                            
                            HStack {
                                Text("\(data.cloudPlatforms.count) / \(CloudPlatform.allCases.count) selected")
                                    .font(AppFont.caption())
                                    .foregroundColor(.textMuted)
                                Spacer()
                            }
                        }
                        .padding()
                    }
                    .navigationTitle("Cloud Platforms")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Done") {
                                showCloudPopup = false
                            }
                            .fontWeight(.bold)
                        }
                    }
                }
                .presentationDetents([.medium, .large])
            }
        }
    }
}

// MARK: - Step 7: Resume
struct ResumeStepView: View {
    @Binding var data: ResumeInfo

    var body: some View {
        VStack(spacing: 20) {
            FormCard {
                VStack(spacing: 20) {
                    SectionHeader(title: "Resume Upload", icon: "doc.fill")

                    // Mock Document Picker
                    Button {
                        withAnimation(.spring(response: 0.4)) {
                            data.hasUploadedResume.toggle()
                            if data.hasUploadedResume {
                                data.fileName = "Resume_\(Date().formatted(.dateTime.year().month().day())).pdf"
                                data.fileSize = "\(Int.random(in: 150...900)) KB"
                                data.lastUpdated = Date()
                            } else {
                                data.fileName = ""
                                data.fileSize = ""
                            }
                        }
                    } label: {
                        VStack(spacing: 16) {
                            if data.hasUploadedResume {
                                ZStack {
                                    Circle().fill(Color.successGreen.opacity(0.15)).frame(width: 70, height: 70)
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 32)).foregroundColor(.successGreen)
                                }
                                VStack(spacing: 4) {
                                    Text(data.fileName).font(AppFont.subheadline(14)).foregroundColor(.textPrimary)
                                    Text(data.fileSize).font(AppFont.caption()).foregroundColor(.textMuted)
                                    Text("Tap to replace").font(AppFont.caption(11)).foregroundColor(.textMuted)
                                }
                            } else {
                                ZStack {
                                    Circle().fill(Color.brandPrimary.opacity(0.1)).frame(width: 70, height: 70)
                                    Image(systemName: "arrow.up.doc.fill")
                                        .font(.system(size: 30)).foregroundColor(.brandPrimary)
                                }
                                VStack(spacing: 4) {
                                    Text("Upload Your Resume").font(AppFont.subheadline()).foregroundColor(.textPrimary)
                                    Text("PDF, DOC, DOCX • Max 10MB").font(AppFont.caption()).foregroundColor(.textMuted)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(24)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .strokeBorder(
                                    data.hasUploadedResume ? Color.successGreen.opacity(0.5) : Color.brandPrimary.opacity(0.3),
                                    style: StrokeStyle(lineWidth: 2, dash: [8, 4])
                                )
                        )
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(data.hasUploadedResume ? Color.successGreen.opacity(0.05) : Color.brandPrimary.opacity(0.04))
                        )
                    }

                    if data.hasUploadedResume {
                        Toggle(isOn: $data.isATSOptimized) {
                            VStack(alignment: .leading, spacing: 3) {
                                Text("ATS Optimized Resume")
                                    .font(AppFont.body(14)).foregroundColor(.textPrimary)
                                Text("Uses standard formatting and keywords")
                                    .font(AppFont.caption(11)).foregroundColor(.textMuted)
                            }
                        }
                        .tint(.brandPrimary)
                        .padding(.horizontal, 16).padding(.vertical, 12)
                        .background(Color.white.opacity(0.06)).clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }

            // ATS Tips
            FormCard {
                VStack(alignment: .leading, spacing: 12) {
                    SectionHeader(title: "ATS Resume Tips", icon: "lightbulb.fill", accent: .brandGold)
                    ForEach([
                        "Use standard section headings: Work Experience, Education, Skills.",
                        "Avoid tables, graphics, headers/footers that ATS can't parse.",
                        "Tailor keywords from the job description.",
                        "Use action verbs: developed, built, optimised, deployed.",
                        "Keep to one page if under 2 years of experience."
                    ], id: \.self) { tip in
                        HStack(alignment: .top, spacing: 10) {
                            Circle().fill(Color.brandGold).frame(width: 5, height: 5).offset(y: 6)
                            Text(tip).font(AppFont.body(13)).foregroundColor(.textSecondary).fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Step 8: Portfolio
struct PortfolioStepView: View {
    @Binding var data: PortfolioInfo

    var body: some View {
        VStack(spacing: 20) {
            FormCard {
                VStack(spacing: 16) {
                    SectionHeader(title: "Personal Portfolio", icon: "globe")

                    Toggle(isOn: $data.hasPortfolio) {
                        VStack(alignment: .leading, spacing: 3) {
                            Text("I have a portfolio website").font(AppFont.body(14)).foregroundColor(.textPrimary)
                            Text("Personal or hosted page showcasing your work").font(AppFont.caption(11)).foregroundColor(.textMuted)
                        }
                    }
                    .tint(.brandPrimary)
                    .padding(14).background(Color.white.opacity(0.06)).clipShape(RoundedRectangle(cornerRadius: 12))

                    if data.hasPortfolio {
                        FormTextField(label: "Portfolio URL", placeholder: "https://yourname.dev", icon: "link", text: $data.websiteURL)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
            }

            // Why Portfolio Matters
            FormCard {
                VStack(alignment: .leading, spacing: 12) {
                    SectionHeader(title: "Why Portfolio Matters", icon: "star.fill", accent: .brandGold)
                    VStack(spacing: 10) {
                        PortfolioTipRow(icon: "eye.fill", text: "Shows real work beyond the resume.", color: .brandPrimary)
                        PortfolioTipRow(icon: "chart.line.uptrend.xyaxis", text: "Sets you apart in competitive rounds.", color: .successGreen)
                        PortfolioTipRow(icon: "globe", text: "Demonstrates initiative and branding.", color: .infoBlue)
                    }
                }
            }
        }
    }
}

struct PortfolioTipRow: View {
    let icon: String
    let text: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon).font(.system(size: 13)).foregroundColor(color)
                .frame(width: 28, height: 28).background(color.opacity(0.12)).clipShape(Circle())
            Text(text).font(AppFont.body(13)).foregroundColor(.textSecondary)
            Spacer()
        }
    }
}

// MARK: - Step 9: Achievements
struct AchievementsStepView: View {
    @Binding var data: AchievementsInfo

    var body: some View {
        VStack(spacing: 20) {
            FormCard {
                VStack(spacing: 16) {
                    SectionHeader(title: "Hackathons & Competitions", icon: "trophy.fill")
                    LargeTextEditor(
                        label: "Hackathons, Contests, Competitions",
                        placeholder: "e.g. Won 1st place at HackIndia 2024, Top 10 in Smart India Hackathon...",
                        text: $data.hackathons
                    )
                }
            }

            FormCard {
                VStack(spacing: 16) {
                    SectionHeader(title: "Extra-Curriculars", icon: "figure.mixed.cardio.circle.fill")
                    LargeTextEditor(
                        label: "Clubs, Sports, Leadership Roles",
                        placeholder: "e.g. President of Coding Club, NSS Volunteer, Chess Team Captain...",
                        text: $data.extraCurriculars
                    )
                }
            }

            FormCard {
                VStack(spacing: 16) {
                    SectionHeader(title: "Publications & Research", icon: "doc.text.magnifyingglass")
                    LargeTextEditor(
                        label: "Papers, Articles, Patents",
                        placeholder: "e.g. Published paper in IEEE ICSE 2024 on ML Optimization...",
                        text: $data.publications
                    )
                }
            }

            FormCard {
                VStack(spacing: 16) {
                    SectionHeader(title: "Awards & Recognition", icon: "rosette")
                    LargeTextEditor(
                        label: "Scholarships, Merit Awards, Recognitions",
                        placeholder: "e.g. Received National Merit Scholarship, Dean's List 2023...",
                        text: $data.awards
                    )
                }
            }
        }
    }
}

// MARK: - Step 10: Competitive Exams
struct CompetitiveExamsStepView: View {
    @Binding var data: CompetitiveExamsInfo

    var body: some View {
        VStack(spacing: 20) {
            FormCard {
                VStack(spacing: 16) {
                    SectionHeader(title: "GATE Score", icon: "function")
                    ExamToggleRow(title: "I appeared for GATE", isOn: $data.hasGATEScore)
                    
                    if data.hasGATEScore {
                        VStack(spacing: 12) {
                            LabeledSlider(label: "GATE Score", value: $data.gateScore, range: 0...1000, step: 1, unit: " pts", color: Color(hex: "#6C63FF"))
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("GATE Year").font(AppFont.caption()).foregroundColor(.textSecondary)
                                Stepper("\(data.gateYear)", value: $data.gateYear, in: 2018...2026)
                                    .font(AppFont.body()).foregroundColor(.textPrimary)
                                    .padding(14).background(Color.white.opacity(0.06)).clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("All India Rank (optional)").font(AppFont.caption()).foregroundColor(.textSecondary)
                                Stepper(data.gateRank > 0 ? "AIR \(data.gateRank)" : "Not specified", value: $data.gateRank, in: 0...500000, step: 100)
                                    .font(AppFont.body()).foregroundColor(.textPrimary)
                                    .padding(14).background(Color.white.opacity(0.06)).clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
            }
            
            FormCard {
                VStack(spacing: 16) {
                    SectionHeader(title: "JEE Advanced", icon: "atom")
                    ExamToggleRow(title: "I appeared for JEE Advanced", isOn: $data.hasJEEAdvanced)
                    if data.hasJEEAdvanced {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("JEE Advanced Rank").font(AppFont.caption()).foregroundColor(.textSecondary)
                            Stepper(data.jeeAdvancedRank > 0 ? "AIR \(data.jeeAdvancedRank)" : "Not specified", value: $data.jeeAdvancedRank, in: 0...200000, step: 100)
                                .font(AppFont.body()).foregroundColor(.textPrimary)
                                .padding(14).background(Color.white.opacity(0.06)).clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
            }
        }
            .animation(.spring(response: 0.4, dampingFraction: 0.85), value: data.hasGATEScore)
            .animation(.spring(response: 0.4, dampingFraction: 0.85), value: data.hasJEEAdvanced)
        
    }
}

struct ExamToggleRow: View {
    let title: String
    @Binding var isOn: Bool

    var body: some View {
        Toggle(isOn: $isOn) {
            Text(title).font(AppFont.body(14)).foregroundColor(.textPrimary)
        }
        .tint(.brandPrimary)
        .padding(14).background(Color.white.opacity(0.06)).clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Step 11: Social Handles
struct SocialHandlesStepView: View {
    @Binding var data: SocialHandlesInfo

    var body: some View {
        FormCard {
            VStack(spacing: 16) {
                SectionHeader(title: "Professional Presence", icon: "link")
                FormTextField(label: "LinkedIn", placeholder: "linkedin.com/in/yourname", icon: "person.crop.square.filled.and.at.rectangle", text: $data.linkedIn)
                FormTextField(label: "GitHub", placeholder: "github.com/yourname", icon: "chevron.left.forwardslash.chevron.right", text: $data.github)
                FormTextField(label: "Naukri.com", placeholder: "naukri.com/profile/...", icon: "briefcase.fill", text: $data.naukri)
                FormTextField(label: "Twitter / X", placeholder: "twitter.com/handle", icon: "bird.fill", text: $data.twitter)
                FormTextField(label: "Personal Blog", placeholder: "yourblog.medium.com", icon: "pencil.and.outline", text: $data.personalBlog)
            }
        }
    }
}

// MARK: - Step 12: Tools & IDEs
struct ToolsStepView: View {
    @Binding var data: ToolsInfo
    let columns = [GridItem(.adaptive(minimum: 90))]
    @State private var showDevToolsPopup = false
    var body: some View {
        FormCard {
            VStack(spacing: 16) {
                SectionHeader(title: "Tools & IDEs", icon: "wrench.and.screwdriver.fill")
                Text("Select all tools you're comfortable working with.")
                    .font(AppFont.body(13)).foregroundColor(.textSecondary)

                FormCard {
                    // 1. The Trigger Button
                    Button(action: {
                        showDevToolsPopup = true
                    }) {
                        HStack {
                            SectionHeader(title: "Developer Tools", icon: "hammer.fill")
                            
                            Spacer()
                            
                            Text("\(data.selectedTools.count) Selected")
                                .font(AppFont.caption())
                                .foregroundColor(.secondary)
                            
                            Image(systemName: "chevron.up.chevron.down")
                                .foregroundColor(.secondary)
                                .font(.system(size: 14))
                        }
                    }
                }
                // 2. The Popup View
                .sheet(isPresented: $showDevToolsPopup) {
                    NavigationView {
                        ScrollView {
                            VStack(spacing: 16) {
                                LazyVGrid(columns: columns, spacing: 10) {
                                    ForEach(DevTool.allCases, id: \.self) { tool in
                                        Button {
                                            withAnimation(.spring(response: 0.25)) {
                                                if data.selectedTools.contains(tool) {
                                                    data.selectedTools.remove(tool)
                                                } else {
                                                    data.selectedTools.insert(tool)
                                                }
                                            }
                                        } label: {
                                            VStack(spacing: 8) {
                                                ZStack {
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .fill(data.selectedTools.contains(tool) ? Color.brandPrimary.opacity(0.85) : Color.white.opacity(0.06))
                                                        .frame(width: 44, height: 44)
                                                    
                                                    Image(systemName: tool.icon)
                                                        .font(.system(size: 18, weight: .semibold))
                                                        .foregroundColor(data.selectedTools.contains(tool) ? .white : .textMuted)
                                                }
                                                
                                                Text(tool.rawValue)
                                                    .font(AppFont.caption(11))
                                                    .foregroundColor(data.selectedTools.contains(tool) ? .textPrimary : .textMuted)
                                                    .multilineTextAlignment(.center)
                                                    .lineLimit(2)
                                                    .fixedSize(horizontal: false, vertical: true)
                                            }
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 10)
                                            .background(
                                                RoundedRectangle(cornerRadius: 14)
                                                    .fill(data.selectedTools.contains(tool) ? Color.brandPrimary.opacity(0.12) : Color.clear)
                                            )
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 14)
                                                    .stroke(data.selectedTools.contains(tool) ? Color.brandPrimary.opacity(0.5) : Color.white.opacity(0.06), lineWidth: 1)
                                            )
                                        }
                                    }
                                }
                                
                                HStack {
                                    Text("\(data.selectedTools.count) / \(DevTool.allCases.count) selected")
                                        .font(AppFont.caption())
                                        .foregroundColor(.textMuted)
                                    Spacer()
                                }
                            }
                            .padding()
                        }
                        .navigationTitle("Developer Tools")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button("Done") {
                                    showDevToolsPopup = false
                                }
                                .fontWeight(.bold)
                            }
                        }
                    }
                    .presentationDetents([.medium, .large])
                }

                HStack {
                    Text("\(data.selectedTools.count) tools selected")
                        .font(AppFont.caption()).foregroundColor(.textMuted)
                    Spacer()
                    if !data.selectedTools.isEmpty {
                        Button("Clear All") {
                            withAnimation(.spring(response: 0.3)) { data.selectedTools.removeAll() }
                        }
                        .font(AppFont.caption()).foregroundColor(.dangerRed)
                    }
                }
            }
        }
    }
}

// MARK: - Analysis Loading Overlay
struct AnalysisLoadingOverlay: View {
    @ObservedObject var vm: PlacementPredictorViewModel
    @State private var rotation: Double = 0

    var body: some View {
        ZStack {
            Color.black.opacity(0.85).ignoresSafeArea()
            VStack(spacing: 32) {
                ZStack {
                    // Outer ring
                    Circle().stroke(Color.white.opacity(0.05), lineWidth: 10).frame(width: 130, height: 130)
                    Circle()
                        .trim(from: 0, to: vm.analysisProgress)
                        .stroke(AppGradients.brandPrimary, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                        .frame(width: 130, height: 130)
                        .rotationEffect(.degrees(-90))
                        .animation(.spring(response: 0.6, dampingFraction: 0.85), value: vm.analysisProgress)

                    // Rotating sparkle
                    Image(systemName: "sparkles")
                        .font(.system(size: 36))
                        .foregroundStyle(AppGradients.brandPrimary)
                        .rotationEffect(.degrees(rotation))
                        .onAppear {
                            withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                                rotation = 360
                            }
                        }
                }

                VStack(spacing: 10) {
                    Text("Analysing Your Profile")
                        .font(AppFont.headline(22)).foregroundColor(.textPrimary)
                    Text(vm.analysisStage)
                        .font(AppFont.body()).foregroundColor(.textSecondary)
                        .animation(.easeInOut(duration: 0.3), value: vm.analysisStage)
                    Text("\(Int(vm.analysisProgress * 100))% complete")
                        .font(AppFont.caption()).foregroundColor(.textMuted)
                }
                .multilineTextAlignment(.center)
            }
        }
    }
}

// MARK: - Shared Form UI Components
struct FormCard<Content: View>: View {
    @ViewBuilder let content: Content
    var body: some View {
        content.padding(20).glassCard()
    }
}

struct FormTextField: View {
    let label: String
    let placeholder: String
    let icon: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label).font(AppFont.caption()).foregroundColor(.textSecondary)
            HStack(spacing: 10) {
                Image(systemName: icon).foregroundColor(.textMuted).frame(width: 18)
                TextField(placeholder, text: $text)
                    .font(AppFont.body()).foregroundColor(.textPrimary)
                    .autocorrectionDisabled()
            }
            .glassTextField()
        }
    }
}

struct LargeTextEditor: View {
    let label: String
    let placeholder: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label).font(AppFont.caption()).foregroundColor(.textSecondary)
            ZStack(alignment: .topLeading) {
                if text.isEmpty {
                    Text(placeholder).font(AppFont.body()).foregroundColor(.textMuted)
                        .padding(.top, 12).padding(.leading, 4)
                }
                TextEditor(text: $text)
                    .font(AppFont.body()).foregroundColor(.textPrimary)
                    .frame(minHeight: 100).scrollContentBackground(.hidden)
            }
            .padding(14).background(Color.white.opacity(0.06))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.12), lineWidth: 1))
        }
    }
}

struct LabeledSlider: View {
    let label: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double
    let unit: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(label).font(AppFont.caption()).foregroundColor(.textSecondary)
                Spacer()
                Text("\(formatValue(value))\(unit)")
                    .font(AppFont.mono(13)).foregroundColor(color)
                    .padding(.horizontal, 10).padding(.vertical, 4)
                    .background(color.opacity(0.12)).clipShape(Capsule())
            }
            Slider(value: $value, in: range, step: step)
                .tint(color)
        }
    }

    private func formatValue(_ v: Double) -> String {
        if step < 1 { return String(format: "%.1f", v) }
        return "\(Int(v))"
    }
}

struct EmptyStateCard: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 36)).foregroundColor(.textMuted)
            Text(title).font(AppFont.subheadline()).foregroundColor(.textSecondary)
            Text(subtitle).font(AppFont.caption()).foregroundColor(.textMuted).multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(28).glassCard()
    }
}

#Preview {
    MainFormView()
}
