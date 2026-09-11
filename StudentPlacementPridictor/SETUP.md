# Student Placement Predictor — Xcode Setup Guide

## Project Structure
```
StudentPlacementPredictor/
├── DesignSystem.swift        (430 lines)  — Colors, Gradients, Modifiers, UI Primitives
├── Models.swift              (479 lines)  — All Structs, Enums (Codable/Identifiable)
├── ViewModels.swift          (714 lines)  — AppStateManager, AuthVM, ProfileVM, PredictorVM
├── AuthViews.swift           (797 lines)  — Login, Register, Captcha, OTP Overlay
├── MainDashboardView.swift   (753 lines)  — Dashboard Hub, Profile Edit, History
├── MainFormView.swift       (1382 lines)  — 13-Step Prediction Form Wizard
├── ResultDashboardView.swift (715 lines)  — Analytics, Ring Charts, Skill Gaps
└── AppMain.swift             (579 lines)  — @main Entry, Routing, Splash, Guest Mode
                              ─────────────
TOTAL                        5,849 lines
```

## Quick Xcode Setup

### 1. Create New Project
- Open Xcode → File → New → Project
- Choose **iOS App**
- Product Name: `StudentPlacementPredictor`
- Interface: **SwiftUI**
- Language: **Swift**
- Minimum Deployment Target: **iOS 16.0**

### 2. Add Files
- Delete the default `ContentView.swift` 
- Right-click the project navigator → "Add Files to..."
- Add all 8 `.swift` files from this folder
- Make sure "Copy items if needed" is checked and target is ticked

### 3. Resolve the @main Conflict
- Select the auto-generated `StudentPlacementPredictorApp.swift` created by Xcode
- **Delete it** (Move to Trash) — `AppMain.swift` already contains `@main`

### 4. Build Settings
- Set **iOS Deployment Target** to 16.0
- Under **Build Phases → Compile Sources**, confirm all 8 files are listed
- No third-party packages required — 100% native SwiftUI + Foundation

### 5. Run
- Select any iOS 16+ Simulator (iPhone 14 / 15 / 15 Pro)
- Press ⌘R to Build & Run
- Demo login: username `alex123` / password `demo`

---

## Feature Map

| Feature | File | Key Type |
|---------|------|----------|
| Splash Screen | AppMain.swift | `SplashScreenView` |
| Route State Machine | ViewModels.swift | `AppStateManager` |
| Login + Captcha | AuthViews.swift | `LoginView`, `CaptchaView` |
| Register + OTP | AuthViews.swift | `RegisterView`, `OTPOverlayView` |
| Guest Mode (1 run) | AppMain.swift | `GuestPredictionView` |
| Dashboard Hub | MainDashboardView.swift | `MainDashboardView` |
| Inline Profile Edit | MainDashboardView.swift | `ProfileTabContent` |
| OTP on field change | MainDashboardView.swift + ViewModels | `ProfileViewModel.saveProfile` |
| 13-Step Form | MainFormView.swift | `MainFormView`, `FormStepPage` |
| Prediction Engine | ViewModels.swift | `PlacementPredictorViewModel.computePrediction` |
| Circular Score Ring | ResultDashboardView.swift | `ResultHeroCard`, `CircularProgressRing` |
| Role Match Cards | ResultDashboardView.swift | `RoleMatchCard` |
| Company Tier Cards | ResultDashboardView.swift | `CompanyTierCard` |
| Skill Gap Accordion | ResultDashboardView.swift | `SkillGapCard` |
| Glass UI System | DesignSystem.swift | `GlassCardModifier`, `AppGradients` |

---

## Prediction Engine Logic

The mock AI engine (`computePrediction()`) scores 8 weighted dimensions:

| Dimension | Weight | Key Inputs |
|-----------|--------|-----------|
| Education | 25 pts | CGPA, 10th%, 12th% |
| DSA | 20 pts | Problems solved, topics, profiles |
| Technical Skills | 15 pts | Languages, frameworks, DBs, cloud |
| Projects | 10 pts | Count, type, portfolio |
| Internships | 10 pts | Count, ATS resume |
| Soft Skills | 8 pts | Communication rating, aptitude % |
| Certifications | 7 pts | Count, portfolio, hackathons |
| Social Presence | 5 pts | LinkedIn, GitHub, tools count |

**Placement Tier:** ≥70% → High · 45–69% → Medium · <45% → Low

---

## Design System Usage

```swift
// Glass Card
YourView().glassCard()

// Neon Border
YourView().neonBorder(color: .brandPrimary)

// Primary Button
Button("Action") { }.buttonStyle(PrimaryButtonStyle())

// Gradient
AppGradients.brandPrimary  // purple → violet
AppGradients.brandSuccess  // green → teal
AppGradients.brandGold     // gold → orange

// Typography
AppFont.display(34)    // Hero numbers
AppFont.headline(22)   // Section titles
AppFont.subheadline()  // Card titles
AppFont.body()         // Body text
AppFont.caption()      // Labels & hints
AppFont.mono()         // Code / OTP
```

---

## Known Mock Behaviours
- **OTP**: Generated 4-digit code is printed to Xcode console (`🔐 MOCK OTP`) and shown in the overlay as a blue hint for demo purposes. Remove the hint text before production.
- **Resume / Image Upload**: Mock toggle — no actual file picker is wired (PHPicker / DocumentPicker would be added for production).
- **User Store**: In-memory dictionary in `AuthViewModel`. Replace with Keychain + backend API for production.
- **Prediction**: Pure algorithmic scoring. Replace `computePrediction()` with a real ML model or API call.

