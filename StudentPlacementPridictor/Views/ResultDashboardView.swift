import SwiftUI

// MARK: - Result Tab Enum
enum ResultTab: String, CaseIterable {
    case overview  = "Overview"
    case roles     = "Job Roles"
    case tiers     = "Companies"
    case gaps      = "Skill Gaps"
    case strengths = "Strengths"
    case feedback  = "Feedback"

    var icon: String {
        switch self {
        case .overview:  return "chart.pie.fill"
        case .roles:     return "person.badge.key.fill"
        case .tiers:     return "building.2.fill"
        case .gaps:      return "exclamationmark.triangle.fill"
        case .strengths: return "star.fill"
        case .feedback:  return "bubble.left.and.text.bubble.right.fill"
        }
    }
}

// MARK: - Design Tokens (scoped, no conflict with DesignSystem.swift)
private enum RD {
    // Surfaces
    static let bg       = Color.surfaceDark
    static let surface  = Color.surfaceCard
    static let elevated = Color.surfaceElevated
    static let border   = Color.white.opacity(0.10)
    // Text
    static let textPri  = Color.textPrimary
    static let textSec  = Color.textSecondary
    static let textTer  = Color.textMuted
    // Accent colours
    static let primary  = Color.brandPrimary
    static let secondary = Color.brandSecondary
    static let accent   = Color.brandOrange
    static let success  = Color.brandAccent
    static let gold     = Color.brandGold
    // Gradients
    static let grad     = AppGradients.brandPrimary
    static let gradGold = AppGradients.brandGold
    static let gradSuccess = AppGradients.brandSuccess
}

// MARK: - Placement Ring
struct PlacementRing: View {
    let percentage: Double
    let tier: PlacementTier
    @State private var animate = false

    private var progress: Double { animate ? min(percentage / 100.0, 1.0) : 0 }

    var body: some View {
        ZStack {
            // Track
            Circle()
                .stroke(RD.elevated, lineWidth: 20)
                .frame(width: 210, height: 210)

            // Glow halo
            Circle()
                .trim(from: 0, to: progress)
                .stroke(tier.color.opacity(0.22),
                        style: StrokeStyle(lineWidth: 34, lineCap: .round))
                .frame(width: 210, height: 210)
                .rotationEffect(.degrees(-90))
                .blur(radius: 10)
                .animation(.easeOut(duration: 1.4), value: progress)

            // Main ring
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    tier.gradient,
                    style: StrokeStyle(lineWidth: 20, lineCap: .round)
                )
                .frame(width: 210, height: 210)
                .rotationEffect(.degrees(-90))
                .animation(.easeOut(duration: 1.4), value: progress)

            // Centre label
            VStack(spacing: 4) {
                Text(animate ? "\(Int(percentage))%" : "0%")
                    .font(.system(size: 46, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .contentTransition(.numericText())
                    .animation(.easeOut(duration: 1.2), value: animate)

                Text(tier.rawValue.uppercased())
                    .font(.system(size: 11, weight: .black))
                    .tracking(2.5)
                    .foregroundColor(tier.color)

                Text("Chance")
                    .font(.system(size: 11))
                    .foregroundColor(RD.textTer)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                animate = true
            }
        }
    }
}

// MARK: - Chance Descriptor Badge
private struct ChanceDescriptorBadge: View {
    let tier: PlacementTier

    private var headline: String {
        switch tier {
        case .high:   return "Strong Profile 🚀"
        case .medium: return "Good Potential 📈"
        case .low:    return "Room to Grow 🌱"
        }
    }
    private var subtext: String {
        switch tier {
        case .high:   return "You're on track for Tier 1 & Tier 2 interviews."
        case .medium: return "A few focused improvements will move the needle significantly."
        case .low:    return "Act on the skill gaps below — progress will come quickly."
        }
    }

    var body: some View {
        VStack(spacing: 6) {
            Text(headline)
                .font(.system(size: 20, weight: .black, design: .rounded))
                .foregroundColor(.white)
            Text(subtext)
                .font(.system(size: 13))
                .foregroundColor(RD.textSec)
                .multilineTextAlignment(.center)
        }
    }
}

// MARK: - Quick Stat Row
private struct QuickStatRow: View {
    let result: PlacementResult

    var body: some View {
        HStack(spacing: 0) {
            ForEach([
                ("Roles",  "\(result.matchedRoles.count)",  "person.badge.key.fill", RD.primary),
                ("Gaps",   "\(result.skillGaps.count)",     "exclamationmark.triangle.fill", RD.accent),
                ("Wins",   "\(result.strengths.count)",     "star.fill", RD.gold)
            ], id: \.0) { item in
                VStack(spacing: 5) {
                    Image(systemName: item.2)
                        .font(.system(size: 14))
                        .foregroundColor(item.3)
                    Text(item.1)
                        .font(.system(size: 22, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                    Text(item.0)
                        .font(.system(size: 11))
                        .foregroundColor(RD.textSec)
                }
                .frame(maxWidth: .infinity)
                if item.0 != "Wins" {
                    Divider().frame(height: 38).background(RD.border)
                }
            }
        }
        .padding(.vertical, 16)
        .background(RD.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(RD.border))
    }
}

// MARK: - Priority Action Banner
private struct PriorityActionBanner: View {
    let text: String
    @State private var pulse = false

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                Circle()
                    .fill(RD.accent.opacity(0.2))
                    .frame(width: 44, height: 44)
                    .scaleEffect(pulse ? 1.18 : 1.0)
                    .animation(.easeInOut(duration: 1.1).repeatForever(autoreverses: true), value: pulse)
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(RD.gradGold)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text("TOP PRIORITY")
                    .font(.system(size: 10, weight: .black))
                    .tracking(2.0)
                    .foregroundColor(RD.accent)
                Text(text)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(RD.textPri)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(16)
        .background(RD.accent.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(RD.accent.opacity(0.28)))
        .onAppear { pulse = true }
    }
}

// MARK: - Section Title
private struct RDSectionTitle: View {
    let title: String
    let icon: String
    var color: Color = RD.primary

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(color)
            Text(title)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            Spacer()
        }
    }
}

// MARK: - Job Role Card (carousel item)
private struct JobRoleCard: View {
    let role: JobRoleMatch
    let rank: Int
    @State private var appeared = false

    private var matchColor: Color {
        role.matchPercentage >= 80 ? RD.success :
        role.matchPercentage >= 60 ? RD.primary : RD.secondary
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(RD.elevated)
                        .frame(width: 42, height: 42)
                    Image(systemName: role.icon)
                        .font(.system(size: 17))
                        .foregroundColor(.white.opacity(0.9))
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(role.roleName)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(2)
                    Text("₹\(String(format: "%.0f", role.averagePackageLPA)) LPA avg")
                        .font(.system(size: 11))
                        .foregroundColor(matchColor)
                }
                Spacer()
            }

            // Mini arc gauge
            ZStack {
                Circle()
                    .trim(from: 0, to: 0.75)
                    .stroke(RD.elevated, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .frame(width: 58, height: 58)
                    .rotationEffect(.degrees(135))
                Circle()
                    .trim(from: 0, to: 0.75 * (appeared ? min(role.matchPercentage / 100.0, 1.0) : 0))
                    .stroke(matchColor, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .frame(width: 58, height: 58)
                    .rotationEffect(.degrees(135))
                    .animation(.easeOut(duration: 1.0).delay(Double(rank) * 0.08), value: appeared)
                VStack(spacing: 0) {
                    Text("\(Int(role.matchPercentage))%")
                        .font(.system(size: 12, weight: .black, design: .rounded))
                        .foregroundColor(matchColor)
                    Text("match")
                        .font(.system(size: 9))
                        .foregroundColor(RD.textTer)
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)

            // Required skills
            VStack(alignment: .leading, spacing: 4) {
                Text("KEY SKILLS")
                    .font(.system(size: 9, weight: .black))
                    .tracking(1.2)
                    .foregroundColor(RD.textTer)
                RDFlowLayout(items: Array(role.requiredSkills.prefix(4))) { skill in
                    Text(skill)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(RD.textTer)
                        .padding(.horizontal, 7).padding(.vertical, 3)
                        .background(RD.elevated)
                        .clipShape(Capsule())
                }
            }
        }
        .padding(16)
        .frame(width: 200)
        .background(RD.surface)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(appeared ? matchColor.opacity(0.25) : RD.border, lineWidth: 1)
        )
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { appeared = true }
        }
    }
}

// MARK: - Role Detail Row
private struct RoleDetailRow: View {
    let role: JobRoleMatch
    let rank: Int
    @State private var appeared = false

    private var matchColor: Color {
        role.matchPercentage >= 80 ? RD.success :
        role.matchPercentage >= 60 ? RD.primary : RD.secondary
    }

    var body: some View {
        HStack(spacing: 12) {
            Text("#\(rank)")
                .font(.system(size: 13, weight: .black, design: .rounded))
                .foregroundColor(matchColor)
                .frame(width: 28)

            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(RD.elevated)
                    .frame(width: 36, height: 36)
                Image(systemName: role.icon)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.85))
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(role.roleName)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                Text("₹\(String(format: "%.0f", role.averagePackageLPA)) LPA avg")
                    .font(.system(size: 11))
                    .foregroundColor(RD.textTer)
            }

            Spacer()

            // Mini arc
            ZStack {
                Circle()
                    .trim(from: 0, to: 0.75)
                    .stroke(RD.elevated, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                    .frame(width: 46, height: 46)
                    .rotationEffect(.degrees(135))
                Circle()
                    .trim(from: 0, to: 0.75 * (appeared ? min(role.matchPercentage / 100.0, 1.0) : 0))
                    .stroke(matchColor, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                    .frame(width: 46, height: 46)
                    .rotationEffect(.degrees(135))
                    .animation(.easeOut(duration: 0.9).delay(Double(rank) * 0.1), value: appeared)
                Text("\(Int(role.matchPercentage))%")
                    .font(.system(size: 10, weight: .black, design: .rounded))
                    .foregroundColor(matchColor)
            }
        }
        .padding(12)
        .background(RD.surface)
        .clipShape(RoundedRectangle(cornerRadius: 13))
        .overlay(RoundedRectangle(cornerRadius: 13).stroke(matchColor.opacity(0.15)))
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { appeared = true }
        }
    }
}

// MARK: - Tier Bar Card
private struct TierBarCard: View {
    let label: String
    let subtitle: String
    let icon: String
    let chance: Double
    let color: Color
    let examples: [String]
    let insight: String
    let delay: Double
    @State private var appeared = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon).font(.system(size: 14)).foregroundColor(color)
                Text(label)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
                Text("\(Int(chance))%")
                    .font(.system(size: 18, weight: .black, design: .rounded))
                    .foregroundColor(color)
            }

            Text(subtitle)
                .font(.system(size: 11))
                .foregroundColor(RD.textSec)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(RD.elevated).frame(height: 8)
                    Capsule()
                        .fill(LinearGradient(colors: [color, color.opacity(0.55)],
                                             startPoint: .leading, endPoint: .trailing))
                        .frame(width: geo.size.width * (appeared ? min(chance / 100.0, 1.0) : 0), height: 8)
                        .animation(.easeOut(duration: 1.0).delay(delay), value: appeared)
                }
            }
            .frame(height: 8)

            Text(insight)
                .font(.system(size: 12))
                .foregroundColor(RD.textSec)
                .fixedSize(horizontal: false, vertical: true)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(examples, id: \.self) { company in
                        Text(company)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(RD.textTer)
                            .padding(.horizontal, 8).padding(.vertical, 3)
                            .background(RD.elevated)
                            .clipShape(Capsule())
                    }
                }
            }
        }
        .padding(16)
        .background(RD.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(color.opacity(0.2)))
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { appeared = true }
        }
    }
}

// MARK: - Score Breakdown Bar
private struct ScoreBreakdownBar: View {
    let label: String
    let icon: String
    let score: Double
    let maxScore: Double
    let color: Color
    @State private var appeared = false

    private var fraction: Double { maxScore > 0 ? min(score / maxScore, 1.0) : 0 }

    var body: some View {
        VStack(spacing: 6) {
            HStack {
                Image(systemName: icon).font(.system(size: 11)).foregroundColor(color)
                Text(label)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(RD.textSec)
                Spacer()
                Text("\(Int(score)) / \(Int(maxScore))")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(color)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(RD.elevated).frame(height: 6)
                    Capsule()
                        .fill(LinearGradient(colors: [color, color.opacity(0.55)],
                                             startPoint: .leading, endPoint: .trailing))
                        .frame(width: geo.size.width * (appeared ? fraction : 0), height: 6)
                        .animation(.easeOut(duration: 0.9).delay(Double.random(in: 0.1...0.5)), value: appeared)
                }
            }
            .frame(height: 6)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { appeared = true }
        }
    }
}

// MARK: - Skill Gap Row
private struct SkillGapRow: View {
    let gap: SkillGap
    let index: Int
    @State private var appeared = false

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 9)
                    .fill(gap.priority.color.opacity(0.15))
                    .frame(width: 36, height: 36)
                Image(systemName: gap.priority.icon)
                    .font(.system(size: 13))
                    .foregroundColor(gap.priority.color)
            }
            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 6) {
                    Text(gap.area)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                    Text(gap.priority.rawValue)
                        .font(.system(size: 9, weight: .black))
                        .tracking(0.6)
                        .foregroundColor(gap.priority.color)
                        .padding(.horizontal, 6).padding(.vertical, 2)
                        .background(gap.priority.color.opacity(0.15))
                        .clipShape(Capsule())
                }
                Text(gap.actionItem)
                    .font(.system(size: 12))
                    .foregroundColor(RD.textSec)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(14)
        .background(RD.surface)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(gap.priority.color.opacity(0.15)))
        .offset(x: appeared ? 0 : 50)
        .opacity(appeared ? 1 : 0)
        .animation(.spring(response: 0.5, dampingFraction: 0.78).delay(Double(index) * 0.06), value: appeared)
        .onAppear { appeared = true }
    }
}

// MARK: - Strength Item
private struct StrengthItem: View {
    let text: String
    let index: Int
    @State private var appeared = false

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Circle()
                .fill(RD.gradGold)
                .frame(width: 7, height: 7)
                .padding(.top, 5)
            Text(text)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(RD.textSec)
                .fixedSize(horizontal: false, vertical: true)
        }
        .offset(x: appeared ? 0 : -24)
        .opacity(appeared ? 1 : 0)
        .animation(.spring(response: 0.5, dampingFraction: 0.78).delay(Double(index) * 0.07), value: appeared)
        .onAppear { appeared = true }
    }
}

// MARK: - 30-Day Action Plan
private struct ThirtyDayActionPlan: View {
    let gaps: [SkillGap]

    private var planItems: [(String, String, String)] {
        var items: [(String, String, String)] = []
        let criticalGaps = gaps.filter { $0.priority == .critical }.prefix(2)
        let moderateGaps = gaps.filter { $0.priority == .moderate }.prefix(1)

        items.append(("Days 1–7",
                       "Set up all missing profiles (LinkedIn, GitHub, Naukri). Upload and ATS-check your resume.",
                       "person.crop.rectangle.stack.fill"))

        if let firstCritical = criticalGaps.first {
            items.append(("Days 8–21", firstCritical.actionItem, firstCritical.priority.icon))
        } else {
            items.append(("Days 8–21",
                           "Solve 3 LeetCode Medium problems daily. Focus on DP, Graphs, and Binary Search.",
                           "cpu.fill"))
        }

        if let firstModerate = moderateGaps.first {
            items.append(("Days 22–30", firstModerate.actionItem, firstModerate.priority.icon))
        } else {
            items.append(("Days 22–30",
                           "Deploy one project and enroll in a certification on Coursera or NPTEL.",
                           "hammer.fill"))
        }
        return items
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("30-Day Action Plan", systemImage: "calendar.badge.clock")
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(RD.primary)

            VStack(spacing: 0) {
                ForEach(planItems.indices, id: \.self) { idx in
                    let item = planItems[idx]
                    HStack(alignment: .top, spacing: 12) {
                        VStack(spacing: 0) {
                            ZStack {
                                Circle().fill(RD.primary.opacity(0.18)).frame(width: 30, height: 30)
                                Image(systemName: item.2)
                                    .font(.system(size: 11))
                                    .foregroundColor(RD.primary)
                            }
                            if idx < planItems.count - 1 {
                                Rectangle()
                                    .fill(RD.primary.opacity(0.18))
                                    .frame(width: 1.5, height: 36)
                            }
                        }
                        VStack(alignment: .leading, spacing: 3) {
                            Text(item.0)
                                .font(.system(size: 10, weight: .black))
                                .tracking(1.0)
                                .foregroundColor(RD.primary)
                            Text(item.1)
                                .font(.system(size: 12))
                                .foregroundColor(RD.textSec)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(.bottom, idx < planItems.count - 1 ? 22 : 0)
                    }
                }
            }
        }
        .padding(18)
        .background(RD.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(RD.primary.opacity(0.18)))
    }
}

// MARK: - Flow Layout (generic helper)
private struct RDFlowLayout<Item, Content: View>: View {
    let items: [Item]
    @ViewBuilder let content: (Item) -> Content

    var body: some View {
        var rows: [[Item]] = [[]]
        // Simple wrapping — layout engine handles actual sizing
        VStack(alignment: .leading, spacing: 4) {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))], alignment: .leading, spacing: 4) {
                ForEach(items.indices, id: \.self) { i in
                    content(items[i])
                }
            }
        }
    }
}

// MARK: ─────────────────────────────────────────────────────────────────
// MARK: - TAB VIEWS
// MARK: ─────────────────────────────────────────────────────────────────

// MARK: - Overview Tab
private struct OverviewResultTab: View {
    let result: PlacementResult

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 22) {
                // Ring hero
                VStack(spacing: 14) {
                    PlacementRing(percentage: result.overallProbability, tier: result.tier)
                        .frame(height: 230)
                    ChanceDescriptorBadge(tier: result.tier)
                }
                .padding(.top, 8)

                // Quick stats
                QuickStatRow(result: result)

                // Package range
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(RD.gold.opacity(0.18))
                            .frame(width: 44, height: 44)
                        Image(systemName: "indianrupeesign.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(RD.gold)
                    }
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Estimated CTC Range")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(RD.textSec)
                        Text("₹\(String(format: "%.0f", result.estimatedPackageLPA.lowerBound)) – ₹\(String(format: "%.0f", result.estimatedPackageLPA.upperBound)) LPA")
                            .font(.system(size: 22, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                    }
                    Spacer()
                    VStack(spacing: 4) {
                        Image(systemName: result.tier.icon)
                            .font(.system(size: 16))
                            .foregroundColor(result.tier.color)
                        Text(result.tier.rawValue)
                            .font(.system(size: 11, weight: .black))
                            .foregroundColor(result.tier.color)
                    }
                    .padding(.horizontal, 14).padding(.vertical, 10)
                    .background(result.tier.color.opacity(0.14))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(16)
                .background(RD.surface)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(RD.gold.opacity(0.20)))

                // Recommendation banner
                PriorityActionBanner(text: result.recommendedPath)

                // Top matched role quick preview
                if let topRole = result.matchedRoles.first {
                    VStack(alignment: .leading, spacing: 14) {
                        RDSectionTitle(title: "Best Role Match", icon: "person.badge.key.fill")
                        HStack(spacing: 14) {
                            ZStack {
                                Circle().fill(RD.primary.opacity(0.15)).frame(width: 48, height: 48)
                                Image(systemName: topRole.icon)
                                    .font(.system(size: 20)).foregroundColor(RD.primary)
                            }
                            VStack(alignment: .leading, spacing: 4) {
                                Text(topRole.roleName)
                                    .font(.system(size: 15, weight: .bold)).foregroundColor(.white)
                                Text("₹\(String(format: "%.0f", topRole.averagePackageLPA)) LPA avg")
                                    .font(.system(size: 12)).foregroundColor(RD.textSec)
                            }
                            Spacer()
                            Text("\(Int(topRole.matchPercentage))%")
                                .font(.system(size: 22, weight: .black, design: .rounded))
                                .foregroundColor(RD.success)
                        }
                    }
                    .padding(16)
                    .background(RD.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(RD.success.opacity(0.2)))
                }

                Spacer().frame(height: 30)
            }
            .padding(.horizontal, 20)
            .padding(.top, 14)
            .padding(.bottom, 30)
        }
    }
}

// MARK: - Roles Tab
private struct RolesResultTab: View {
    let result: PlacementResult
    @State private var selectedRole: JobRoleMatch? = nil

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                RDSectionTitle(title: "Matching Job Roles", icon: "person.badge.key.fill")

                if result.matchedRoles.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "person.badge.questionmark")
                            .font(.system(size: 36)).foregroundColor(RD.textTer)
                        Text("No role matches yet.")
                            .font(.system(size: 15, weight: .bold)).foregroundColor(RD.textSec)
                        Text("Select more technical skills to unlock role matches.")
                            .font(.system(size: 12)).foregroundColor(RD.textTer)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity).padding(36)
                    .background(RD.surface).clipShape(RoundedRectangle(cornerRadius: 16))
                } else {
                    // Horizontal carousel
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 14) {
                            ForEach(result.matchedRoles.indices, id: \.self) { idx in
                                JobRoleCard(role: result.matchedRoles[idx], rank: idx + 1)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 4)
                    }
                    .padding(.horizontal, -20)

                    // Ranked detail rows — tappable
                    VStack(spacing: 10) {
                        ForEach(result.matchedRoles.indices, id: \.self) { idx in
                            RoleDetailRow(role: result.matchedRoles[idx], rank: idx + 1)
                                .onTapGesture {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                                        selectedRole = result.matchedRoles[idx]
                                    }
                                }
                        }
                    }

                    // ── Per-role recommendations ──────────────────────
                    if let topRole = result.matchedRoles.first {
                        RoleRecommendationCard(role: topRole)
                    }

                    // ── Skill-to-role map ─────────────────────────────
                    VStack(alignment: .leading, spacing: 14) {
                        RDSectionTitle(title: "What Each Role Needs", icon: "map.fill", color: RD.gold)
                        VStack(spacing: 10) {
                            ForEach(result.matchedRoles.prefix(3).indices, id: \.self) { idx in
                                let role = result.matchedRoles[idx]
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack(spacing: 8) {
                                        Image(systemName: role.icon)
                                            .font(.system(size: 12, weight: .semibold))
                                            .foregroundColor(RD.gold)
                                        Text(role.roleName)
                                            .font(.system(size: 13, weight: .bold))
                                            .foregroundColor(.white)
                                    }
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 6) {
                                            ForEach(role.requiredSkills, id: \.self) { skill in
                                                Text(skill)
                                                    .font(.system(size: 10, weight: .semibold))
                                                    .foregroundColor(RD.textSec)
                                                    .padding(.horizontal, 9).padding(.vertical, 4)
                                                    .background(RD.elevated)
                                                    .clipShape(Capsule())
                                                    .overlay(Capsule().stroke(RD.border))
                                            }
                                        }
                                    }
                                }
                                if idx < result.matchedRoles.prefix(3).count - 1 {
                                    Divider().background(RD.border)
                                }
                            }
                        }
                        .padding(16)
                        .background(RD.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(RD.gold.opacity(0.18)))
                    }
                }

                Spacer().frame(height: 30)
            }
            .padding(.horizontal, 20)
            .padding(.top, 14)
        }
        .sheet(item: $selectedRole) { role in
            RoleDetailSheet(role: role)
        }
    }
}

// MARK: - Role Recommendation Card
private struct RoleRecommendationCard: View {
    let role: JobRoleMatch

    private var steps: [(String, String, String)] {
        switch role.icon {
        case "apple.logo":
            return [("Master SwiftUI & UIKit", "Build 2 portfolio apps with full source code on GitHub.", "hammer.fill"),
                    ("Learn Combine & async/await", "These are essential for modern iOS architecture patterns.", "cpu.fill"),
                    ("Practice iOS interview questions", "Focus on memory management, lifecycle, and design patterns.", "list.bullet.clipboard.fill")]
        case "server.rack":
            return [("Build REST APIs in your stack", "Deploy a production-grade API with auth and a database.", "server.rack"),
                    ("Learn Docker & CI/CD basics", "Containerise your project and set up a GitHub Actions pipeline.", "shippingbox"),
                    ("Study system design patterns", "Cover caching, load balancing, and database sharding.", "cpu.fill")]
        case "brain.head.profile":
            return [("Complete an ML course (fast.ai / Andrew Ng)", "Apply concepts to a Kaggle competition project.", "book.fill"),
                    ("Build a portfolio ML project", "Solve a real problem — NLP, CV, or tabular prediction.", "hammer.fill"),
                    ("Learn MLOps basics", "Deploy a model with Flask / FastAPI and host it on HuggingFace.", "cloud.fill")]
        default:
            return [("Deepen your primary tech stack", "Build an end-to-end project using it.", "hammer.fill"),
                    ("Solve 100+ LeetCode problems", "Focus on role-relevant patterns (arrays, graphs, DP).", "cpu.fill"),
                    ("Build a strong GitHub presence", "Consistent commits signal active development habit.", "chevron.left.forwardslash.chevron.right")]
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "lightbulb.max.fill")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(RD.gold)
                Text("Roadmap: \(role.roleName)")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }

            VStack(spacing: 0) {
                ForEach(steps.indices, id: \.self) { idx in
                    let step = steps[idx]
                    HStack(alignment: .top, spacing: 14) {
                        VStack(spacing: 0) {
                            ZStack {
                                Circle().fill(RD.gold.opacity(0.18)).frame(width: 32, height: 32)
                                Image(systemName: step.2)
                                    .font(.system(size: 12)).foregroundColor(RD.gold)
                            }
                            if idx < steps.count - 1 {
                                Rectangle().fill(RD.gold.opacity(0.15)).frame(width: 1.5, height: 32)
                            }
                        }
                        VStack(alignment: .leading, spacing: 3) {
                            Text(step.0)
                                .font(.system(size: 13, weight: .bold)).foregroundColor(.white)
                            Text(step.1)
                                .font(.system(size: 11)).foregroundColor(RD.textSec)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(.bottom, idx < steps.count - 1 ? 20 : 0)
                    }
                }
            }
        }
        .padding(18)
        .background(RD.surface)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(RD.gold.opacity(0.22)))
    }
}

// MARK: - Role Detail Sheet
private struct RoleDetailSheet: View {
    let role: JobRoleMatch
    @Environment(\.dismiss) private var dismiss

    private var matchColor: Color {
        role.matchPercentage >= 80 ? RD.success :
        role.matchPercentage >= 60 ? RD.primary  : RD.secondary
    }

    var body: some View {
        ZStack {
            RD.bg.ignoresSafeArea()
            RadialGradient(colors: [matchColor.opacity(0.12), .clear], center: .top, startRadius: 0, endRadius: 280).ignoresSafeArea()

            VStack(spacing: 0) {
                // Handle
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.white.opacity(0.25))
                    .frame(width: 40, height: 4)
                    .padding(.top, 14)
                    .padding(.bottom, 20)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Hero
                        VStack(spacing: 12) {
                            ZStack {
                                Circle().fill(matchColor.opacity(0.18)).frame(width: 72, height: 72)
                                Image(systemName: role.icon)
                                    .font(.system(size: 30, weight: .semibold)).foregroundColor(matchColor)
                            }
                            Text(role.roleName)
                                .font(.system(size: 24, weight: .black, design: .rounded)).foregroundColor(.white)
                            HStack(spacing: 16) {
                                Label("\(Int(role.matchPercentage))% Match", systemImage: "checkmark.seal.fill")
                                    .font(.system(size: 12, weight: .bold)).foregroundColor(matchColor)
                                Label("₹\(String(format: "%.0f", role.averagePackageLPA)) LPA avg", systemImage: "indianrupeesign.circle.fill")
                                    .font(.system(size: 12, weight: .bold)).foregroundColor(RD.gold)
                            }
                        }

                        // Match ring
                        ZStack {
                            Circle().trim(from: 0, to: 0.75)
                                .stroke(RD.elevated, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                                .frame(width: 100, height: 100).rotationEffect(.degrees(135))
                            Circle().trim(from: 0, to: 0.75 * min(role.matchPercentage / 100.0, 1.0))
                                .stroke(matchColor, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                                .frame(width: 100, height: 100).rotationEffect(.degrees(135))
                                .animation(.easeOut(duration: 1.0), value: role.matchPercentage)
                            VStack(spacing: 0) {
                                Text("\(Int(role.matchPercentage))%")
                                    .font(.system(size: 20, weight: .black, design: .rounded)).foregroundColor(matchColor)
                                Text("match").font(.system(size: 10)).foregroundColor(RD.textTer)
                            }
                        }

                        // Required skills
                        VStack(alignment: .leading, spacing: 10) {
                            Text("REQUIRED SKILLS")
                                .font(.system(size: 10, weight: .black)).tracking(1.5).foregroundColor(RD.textTer)
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 90))], spacing: 8) {
                                ForEach(role.requiredSkills, id: \.self) { skill in
                                    Text(skill)
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(matchColor)
                                        .padding(.horizontal, 12).padding(.vertical, 7)
                                        .background(matchColor.opacity(0.12))
                                        .clipShape(Capsule())
                                        .overlay(Capsule().stroke(matchColor.opacity(0.3), lineWidth: 1))
                                }
                            }
                        }
                        .padding(16).background(RD.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(RD.border))
                        .padding(.horizontal, 20)

                        Spacer().frame(height: 30)
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.hidden)
    }
}

// MARK: - Company Detail Sheet
private struct TierCompanySheet: View {
    let label: String
    let subtitle: String
    let color: Color
    let chance: Double
    let companies: [(name: String, packageLPA: Double, type: String)]
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            RD.bg.ignoresSafeArea()
            RadialGradient(colors: [color.opacity(0.12), .clear], center: .top, startRadius: 0, endRadius: 300).ignoresSafeArea()

            VStack(spacing: 0) {
                // Handle + header
                VStack(spacing: 16) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.white.opacity(0.25))
                        .frame(width: 40, height: 4)
                        .padding(.top, 12)

                    HStack(spacing: 14) {
                        ZStack {
                            Circle().fill(color.opacity(0.18)).frame(width: 52, height: 52)
                            Image(systemName: "building.2.fill")
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundColor(color)
                        }
                        VStack(alignment: .leading, spacing: 4) {
                            Text(label)
                                .font(.system(size: 20, weight: .black, design: .rounded))
                                .foregroundColor(.white)
                            Text(subtitle)
                                .font(.system(size: 12))
                                .foregroundColor(RD.textSec)
                        }
                        Spacer()
                        VStack(spacing: 2) {
                            Text("\(Int(chance))%")
                                .font(.system(size: 24, weight: .black, design: .rounded))
                                .foregroundColor(color)
                            Text("Your Chance")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(RD.textTer)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 4)

                    Divider().background(RD.border).padding(.horizontal, 20)
                }
                .background(RD.bg)

                // Company list
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        HStack {
                            Text("COMPANY")
                                .font(.system(size: 10, weight: .black)).tracking(1.2).foregroundColor(RD.textTer)
                            Spacer()
                            Text("AVG PACKAGE")
                                .font(.system(size: 10, weight: .black)).tracking(1.2).foregroundColor(RD.textTer)
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 16)
                        .padding(.bottom, 10)

                        ForEach(Array(companies.enumerated()), id: \.offset) { idx, company in
                            CompanyRow(company: company, color: color, index: idx)
                            if idx < companies.count - 1 {
                                Divider().background(RD.border).padding(.horizontal, 20)
                            }
                        }
                    }
                    .padding(.bottom, 40)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.hidden)
    }
}

private struct CompanyRow: View {
    let company: (name: String, packageLPA: Double, type: String)
    let color: Color
    let index: Int
    @State private var appeared = false

    var body: some View {
        HStack(spacing: 14) {
            // Rank
            Text("\(index + 1)")
                .font(.system(size: 13, weight: .black, design: .rounded))
                .foregroundColor(color.opacity(0.7))
                .frame(width: 24)

            // Company initial avatar
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(color.opacity(0.12))
                    .frame(width: 40, height: 40)
                Text(String(company.name.prefix(1)))
                    .font(.system(size: 16, weight: .black, design: .rounded))
                    .foregroundColor(color)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(company.name)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                Text(company.type)
                    .font(.system(size: 11))
                    .foregroundColor(RD.textSec)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("₹\(String(format: "%.0f", company.packageLPA)) LPA")
                    .font(.system(size: 14, weight: .black, design: .rounded))
                    .foregroundColor(color)
                Text("avg package")
                    .font(.system(size: 10))
                    .foregroundColor(RD.textTer)
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 14)
        .offset(x: appeared ? 0 : 40)
        .opacity(appeared ? 1 : 0)
        .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(Double(index) * 0.05), value: appeared)
        .onAppear { appeared = true }
    }
}

// MARK: - Tiers Tab (tappable cards → sheet)
private struct TiersResultTab: View {
    let result: PlacementResult
    let formData: PredictionFormData

    @State private var selectedTierLabel: String? = nil
    @State private var showTierSheet = false

    // Rich company data per tier
    private var tier1Companies: [(name: String, packageLPA: Double, type: String)] {
        [("Google", 45, "SDE / ML / PM"),
         ("Microsoft", 38, "SDE / Cloud"),
         ("Apple", 42, "iOS / Backend"),
         ("Meta", 40, "SDE / Research"),
         ("Amazon", 30, "SDE / Data"),
         ("Adobe", 28, "Frontend / Backend"),
         ("Salesforce", 26, "SDE / SRE"),
         ("Uber", 35, "SDE / Platform")]
    }
    private var tier2Companies: [(name: String, packageLPA: Double, type: String)] {
        [("Razorpay", 24, "SDE / Fintech"),
         ("CRED", 22, "SDE / Data"),
         ("Swiggy", 20, "SDE / ML"),
         ("Zomato", 19, "SDE / Platform"),
         ("Meesho", 18, "SDE / Growth"),
         ("Zepto", 20, "SDE / Backend"),
         ("PhonePe", 22, "SDE / Fintech"),
         ("Groww", 21, "SDE / Data")]
    }
    private var serviceCompanies: [(name: String, packageLPA: Double, type: String)] {
        [("TCS", 7, "Software Engineer"),
         ("Infosys", 6.5, "Systems Engineer"),
         ("Wipro", 6.5, "Software Engineer"),
         ("HCL", 7, "Technical Engineer"),
         ("Accenture", 8, "Associate SDE"),
         ("Cognizant", 7.5, "Programmer Analyst"),
         ("Capgemini", 7, "Analyst"),
         ("LTIMindtree", 8, "Software Engineer")]
    }

    private func companiesForLabel(_ label: String) -> [(name: String, packageLPA: Double, type: String)] {
        switch label {
        case "Tier 1 Product": return tier1Companies
        case "Tier 2 Product": return tier2Companies
        default: return serviceCompanies
        }
    }
    private func colorForLabel(_ label: String) -> Color {
        switch label {
        case "Tier 1 Product": return RD.primary
        case "Tier 2 Product": return RD.secondary
        default: return RD.success
        }
    }
    private func subtitleForLabel(_ label: String) -> String {
        switch label {
        case "Tier 1 Product": return "FAANG, MAANG & top unicorns"
        case "Tier 2 Product": return "Mid-cap product & funded startups"
        default: return "Large IT services & consulting firms"
        }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                RDSectionTitle(title: "Company Tier Breakdown", icon: "building.columns.fill", color: RD.secondary)

                Text("Tap a tier to explore companies with package details")
                    .font(.system(size: 12)).foregroundColor(RD.textTer)
                    .frame(maxWidth: .infinity, alignment: .leading)

                let t = result.companyTierChances

                // Clickable tier cards
                TierClickCard(label: "Tier 1 Product",
                              subtitle: "FAANG, MAANG & top unicorns",
                              icon: "1.circle.fill",
                              chance: t.tier1Percent,
                              color: RD.primary,
                              insight: "Requires strong DSA, system design, and 400+ problems.",
                              delay: 0.10) {
                    selectedTierLabel = "Tier 1 Product"
                    showTierSheet = true
                }

                TierClickCard(label: "Tier 2 Product",
                              subtitle: "Mid-cap product & funded startups",
                              icon: "2.circle.fill",
                              chance: t.tier2Percent,
                              color: RD.secondary,
                              insight: "Internship + projects are the key differentiators.",
                              delay: 0.18) {
                    selectedTierLabel = "Tier 2 Product"
                    showTierSheet = true
                }

                TierClickCard(label: "Service-Based",
                              subtitle: "Large IT services & consulting firms",
                              icon: "building.2.fill",
                              chance: t.serviceBasedPercent,
                              color: RD.success,
                              insight: "CGPA + aptitude score are the baseline filters here.",
                              delay: 0.26) {
                    selectedTierLabel = "Service-Based"
                    showTierSheet = true
                }

                // Score breakdown
                VStack(spacing: 14) {
                    RDSectionTitle(title: "Score Breakdown", icon: "chart.bar.fill", color: RD.accent)
                    VStack(spacing: 12) {
                        ScoreBreakdownBar(label: "Education",         icon: "graduationcap.fill",    score: min((formData.education.btechCGPA / 10.0) * 25.0, 25.0), maxScore: 25, color: RD.primary)
                        ScoreBreakdownBar(label: "DSA Core",          icon: "cpu.fill",              score: min(Double(formData.dsa.problemsSolved) / 100.0, 20.0), maxScore: 20, color: RD.success)
                        ScoreBreakdownBar(label: "Tech Skills",       icon: "chevron.left.forwardslash.chevron.right", score: min(Double(formData.technicalSkills.languages.count + formData.technicalSkills.frameworks.count) * 0.75, 15.0), maxScore: 15, color: RD.gold)
                        ScoreBreakdownBar(label: "Projects",          icon: "hammer.fill",           score: min(Double(formData.projects.count) * 2.5, 10.0), maxScore: 10, color: RD.accent)
                        ScoreBreakdownBar(label: "Internships",       icon: "briefcase.fill",        score: min(Double(formData.internships.count) * 3.5, 10.0), maxScore: 10, color: RD.secondary)
                        ScoreBreakdownBar(label: "Soft Skills",       icon: "person.2.fill",         score: min(Double(formData.softSkills.communicationRating) * 1.0 + (formData.softSkills.aptitudeMaxScore > 0 ? (formData.softSkills.aptitudeScore / formData.softSkills.aptitudeMaxScore) * 3 : 0), 8.0), maxScore: 8, color: Color(hex: "#EC407A"))
                        ScoreBreakdownBar(label: "Social & Tools",    icon: "link",                  score: (formData.socialHandles.linkedIn.isEmpty ? 0 : 1.5) + (formData.socialHandles.github.isEmpty ? 0 : 1.5) + (formData.socialHandles.naukri.isEmpty ? 0 : 0.5) + min(Double(formData.tools.selectedTools.count) * 0.1, 1.5), maxScore: 5, color: RD.primary)
                    }
                    .padding(18)
                    .background(RD.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(RD.border))
                }

                Spacer().frame(height: 30)
            }
            .padding(.horizontal, 20).padding(.top, 14)
        }
        .sheet(isPresented: $showTierSheet) {
            if let label = selectedTierLabel {
                TierCompanySheet(
                    label: label,
                    subtitle: subtitleForLabel(label),
                    color: colorForLabel(label),
                    chance: {
                        switch label {
                        case "Tier 1 Product": return result.companyTierChances.tier1Percent
                        case "Tier 2 Product": return result.companyTierChances.tier2Percent
                        default: return result.companyTierChances.serviceBasedPercent
                        }
                    }(),
                    companies: companiesForLabel(label)
                )
            }
        }
    }
}

// MARK: - Tier Click Card (replaces TierBarCard in Tiers tab)
private struct TierClickCard: View {
    let label: String
    let subtitle: String
    let icon: String
    let chance: Double
    let color: Color
    let insight: String
    let delay: Double
    let onTap: () -> Void

    @State private var appeared = false
    @State private var pressed  = false

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(color.opacity(0.18))
                            .frame(width: 40, height: 40)
                        Image(systemName: icon)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(color)
                    }
                    VStack(alignment: .leading, spacing: 3) {
                        Text(label)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)
                        Text(subtitle)
                            .font(.system(size: 11))
                            .foregroundColor(RD.textSec)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(Int(chance))%")
                            .font(.system(size: 22, weight: .black, design: .rounded))
                            .foregroundColor(color)
                        Text("chance")
                            .font(.system(size: 10))
                            .foregroundColor(RD.textTer)
                    }
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(RD.textTer)
                }

                // Animated progress bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(color.opacity(0.10)).frame(height: 6)
                        Capsule()
                            .fill(LinearGradient(colors: [color.opacity(0.7), color], startPoint: .leading, endPoint: .trailing))
                            .frame(width: geo.size.width * (appeared ? min(chance / 100.0, 1.0) : 0), height: 6)
                            .animation(.easeOut(duration: 1.0).delay(delay), value: appeared)
                    }
                }
                .frame(height: 6)

                HStack(spacing: 6) {
                    Image(systemName: "lightbulb.fill")
                        .font(.system(size: 10))
                        .foregroundColor(color.opacity(0.7))
                    Text(insight)
                        .font(.system(size: 11))
                        .foregroundColor(RD.textSec)
                }

                HStack {
                    Spacer()
                    Label("View Companies & Packages", systemImage: "arrow.right.circle.fill")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(color)
                }
            }
            .padding(16)
            .background(RD.surface)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .overlay(RoundedRectangle(cornerRadius: 18).stroke(color.opacity(appeared ? 0.25 : 0.1)))
            .scaleEffect(pressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: pressed)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(DragGesture(minimumDistance: 0)
            .onChanged { _ in pressed = true }
            .onEnded   { _ in pressed = false })
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(delay), value: appeared)
        .onAppear { appeared = true }
    }
}

// MARK: - Gaps Tab
private struct GapsResultTab: View {
    let result: PlacementResult

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                RDSectionTitle(title: "Skill Gap Analysis",
                               icon: "exclamationmark.triangle.fill", color: RD.accent)

                // Priority legend
                HStack(spacing: 16) {
                    ForEach([GapPriority.critical, .moderate, .suggested], id: \.rawValue) { p in
                        HStack(spacing: 5) {
                            Circle().fill(p.color).frame(width: 7, height: 7)
                            Text(p.rawValue)
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(p.color)
                        }
                    }
                    Spacer()
                    Text("\(result.skillGaps.count) items")
                        .font(.system(size: 11)).foregroundColor(RD.textTer)
                }

                if result.skillGaps.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 40)).foregroundColor(RD.success)
                        Text("No Critical Gaps Found!")
                            .font(.system(size: 18, weight: .bold)).foregroundColor(.white)
                        Text("Your profile is comprehensive. Refine and deepen your existing skills.")
                            .font(.system(size: 13)).foregroundColor(RD.textSec)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity).padding(36)
                    .background(RD.surface).clipShape(RoundedRectangle(cornerRadius: 16))
                } else {
                    ForEach(result.skillGaps.indices, id: \.self) { idx in
                        SkillGapRow(gap: result.skillGaps[idx], index: idx)
                    }
                }

                ThirtyDayActionPlan(gaps: result.skillGaps)

                Spacer().frame(height: 30)
            }
            .padding(.horizontal, 20).padding(.top, 14)
        }
    }
}

// MARK: - Strengths Tab
private struct StrengthsResultTab: View {
    let result: PlacementResult
    let onEditProfile: () -> Void

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                RDSectionTitle(title: "Profile Strengths", icon: "star.fill", color: RD.gold)

                // Strengths list
                VStack(alignment: .leading, spacing: 14) {
                    Label("What's Working For You", systemImage: "hand.thumbsup.fill")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(RD.gold)

                    if result.strengths.isEmpty {
                        Text("Fill in more profile sections to discover your key strengths.")
                            .font(.system(size: 13)).foregroundColor(RD.textTer)
                    } else {
                        ForEach(result.strengths.indices, id: \.self) { idx in
                            StrengthItem(text: result.strengths[idx], index: idx)
                        }
                    }
                }
                .padding(18)
                .background(RD.surface)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(RD.gold.opacity(0.18)))

                // Motivational close card
                VStack(spacing: 16) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 32))
                        .foregroundStyle(RD.grad)

                    Text("You've Got This!")
                        .font(.system(size: 22, weight: .black, design: .rounded))
                        .foregroundColor(.white)

                    Text("Every expert was once a beginner. Apply the 30-day plan consistently and revisit this analysis to track your growth.")
                        .font(.system(size: 13))
                        .foregroundColor(RD.textSec)
                        .multilineTextAlignment(.center)

                    Button(action: onEditProfile) {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.clockwise")
                            Text("Update My Profile")
                        }
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.vertical, 14)
                        .frame(maxWidth: .infinity)
                        .background(RD.grad)
                        .clipShape(RoundedRectangle(cornerRadius: 13))
                        .shadow(color: RD.primary.opacity(0.38), radius: 12, y: 5)
                    }
                }
                .padding(24)
                .background(RD.surface)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(RD.border))

                Spacer().frame(height: 30)
            }
            .padding(.horizontal, 20).padding(.top, 14)
        }
    }
}

// MARK: ─────────────────────────────────────────────────────────────────
// MARK: - Result Dashboard Root
// MARK: ─────────────────────────────────────────────────────────────────

struct ResultDashboardView: View {
    let result: PlacementResult
    /// Expose formData so the Tiers tab can render the score breakdown.
    /// Pass PlacementPredictorViewModel.formData from the call site.
    var formData: PredictionFormData = PredictionFormData()

    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab: ResultTab = .overview

    var body: some View {
        ZStack {
            RD.bg.ignoresSafeArea()

            // Tinted background glow matching placement tier
            RadialGradient(
                colors: [result.tier.color.opacity(0.14), .clear],
                center: .top, startRadius: 0, endRadius: 340
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {

                // ── Top bar ──────────────────────────────────────────
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        HStack(spacing: 5) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 12, weight: .bold))
                            Text("Edit")
                        }
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(RD.textSec)
                        .padding(.horizontal, 14).padding(.vertical, 8)
                        .background(RD.elevated)
                        .clipShape(Capsule())
                    }

                    Spacer()

                    VStack(spacing: 1) {
                        Text("Analysis Result")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)
                        Text(Date().formatted(.dateTime.day().month().year()))
                            .font(.system(size: 11))
                            .foregroundColor(RD.textTer)
                    }

                    Spacer()

                    Button {} label: {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(RD.textSec)
                            .padding(9)
                            .background(RD.elevated)
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 10)
                .background(RD.bg)

                // ── Tab pill bar ──────────────────────────────────────
                let isGuest = AppStateManager.shared.isGuestMode
                // Feedback tab only shown to signed-in users
                let visibleTabs = isGuest
                    ? ResultTab.allCases.filter { $0 != .feedback }
                    : ResultTab.allCases

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(visibleTabs, id: \.self) { tab in
                            let locked = isGuest && tab != .overview
                            Button {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                    selectedTab = tab
                                }
                            } label: {
                                HStack(spacing: 5) {
                                    Image(systemName: locked ? "lock.fill" : tab.icon)
                                        .font(.system(size: locked ? 10 : 11, weight: .semibold))
                                    Text(tab.rawValue)
                                        .font(.system(size: 12, weight: selectedTab == tab ? .bold : .medium))
                                }
                                .foregroundColor(
                                    locked ? RD.textTer :
                                    (selectedTab == tab ? .white : RD.textSec)
                                )
                                .padding(.horizontal, 13).padding(.vertical, 7)
                                .background(
                                    selectedTab == tab && !locked
                                    ? AnyView(Capsule().fill(RD.grad))
                                    : locked
                                    ? AnyView(Capsule().fill(RD.elevated.opacity(0.5)))
                                    : AnyView(Capsule().fill(RD.elevated))
                                )
                                .overlay(locked ? AnyView(Capsule().stroke(RD.border, lineWidth: 1)) : AnyView(EmptyView()))
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.vertical, 8)
                .background(RD.bg)

                // ── Paged content ────────────────────────────────────
                TabView(selection: $selectedTab) {
                    OverviewResultTab(result: result)
                        .tag(ResultTab.overview)

                    if isGuest {
                        GuestLockedTabView(tabName: "Job Roles",  icon: "person.badge.key.fill").tag(ResultTab.roles)
                        GuestLockedTabView(tabName: "Companies",  icon: "building.2.fill").tag(ResultTab.tiers)
                        GuestLockedTabView(tabName: "Skill Gaps", icon: "exclamationmark.triangle.fill").tag(ResultTab.gaps)
                        GuestLockedTabView(tabName: "Strengths",  icon: "star.fill").tag(ResultTab.strengths)
                    } else {
                        RolesResultTab(result: result).tag(ResultTab.roles)
                        TiersResultTab(result: result, formData: formData).tag(ResultTab.tiers)
                        GapsResultTab(result: result).tag(ResultTab.gaps)
                        StrengthsResultTab(result: result) { dismiss() }.tag(ResultTab.strengths)
                        FeedbackResultTab().tag(ResultTab.feedback)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.spring(response: 0.42, dampingFraction: 0.84), value: selectedTab)

                // ── Persistent guest upgrade strip ───────────────────
                if isGuest {
                    GuestUpgradeBannerRD()
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Guest Upgrade Banner
private struct GuestUpgradeBannerRD: View {
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Save this result forever")
                    .font(.system(size: 13, weight: .bold)).foregroundColor(.white)
                Text("Create a free account to track progress over time.")
                    .font(.system(size: 11)).foregroundColor(RD.textSec)
            }
            Spacer()
            Button {
                AppStateManager.shared.navigate(to: .auth)
            } label: {
                Text("Sign Up")
                    .font(.system(size: 13, weight: .bold)).foregroundColor(.white)
                    .padding(.horizontal, 14).padding(.vertical, 8)
                    .background(RD.grad)
                    .clipShape(Capsule())
            }
        }
        .padding(.horizontal, 20).padding(.vertical, 12)
        .background(RD.surface)
        .overlay(Rectangle().frame(height: 1).foregroundColor(RD.border), alignment: .top)
    }
}

// MARK: - Feedback Tab (signed-in users only)
struct FeedbackResultTab: View {
    @State private var overallRating: Int = 0
    @State private var accuracyRating: Int = 0
    @State private var usefulnessRating: Int = 0
    @State private var comments: String = ""
    @State private var submitted = false
    @State private var selectedTags: Set<String> = []

    private let feedbackTags = ["Very Accurate", "Needs Improvement", "Loved the UI",
                                 "Helpful Roadmap", "Too Generic", "Motivating",
                                 "Missing Skills", "Great Detail"]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                RDSectionTitle(title: "Rate Your Analysis", icon: "bubble.left.and.text.bubble.right.fill", color: RD.primary)

                if submitted {
                    // Thank-you state
                    VStack(spacing: 20) {
                        ZStack {
                            Circle()
                                .fill(LinearGradient(colors: [RD.success.opacity(0.3), RD.success.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing))
                                .frame(width: 90, height: 90)
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 40, weight: .semibold))
                                .foregroundStyle(AppGradients.brandSuccess)
                        }
                        Text("Thank You! 🙏")
                            .font(.system(size: 24, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                        Text("Your feedback helps us improve the prediction engine for every student.")
                            .font(.system(size: 13))
                            .foregroundColor(RD.textSec)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(36)
                    .background(RD.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(RD.success.opacity(0.25)))
                } else {
                    // Rating cards
                    VStack(spacing: 14) {
                        FeedbackRatingRow(label: "Overall Experience",
                                          icon: "star.fill",
                                          color: RD.gold,
                                          rating: $overallRating)
                        Divider().background(RD.border)
                        FeedbackRatingRow(label: "Prediction Accuracy",
                                          icon: "chart.bar.fill",
                                          color: RD.primary,
                                          rating: $accuracyRating)
                        Divider().background(RD.border)
                        FeedbackRatingRow(label: "Usefulness of Roadmap",
                                          icon: "map.fill",
                                          color: RD.success,
                                          rating: $usefulnessRating)
                    }
                    .padding(18)
                    .background(RD.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .overlay(RoundedRectangle(cornerRadius: 18).stroke(RD.border))

                    // Quick tag selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("QUICK TAGS")
                            .font(.system(size: 10, weight: .black))
                            .tracking(1.5)
                            .foregroundColor(RD.textTer)
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 110))], spacing: 8) {
                            ForEach(feedbackTags, id: \.self) { tag in
                                Button {
                                    withAnimation(.spring(response: 0.25)) {
                                        if selectedTags.contains(tag) { selectedTags.remove(tag) }
                                        else { selectedTags.insert(tag) }
                                    }
                                } label: {
                                    Text(tag)
                                        .font(.system(size: 11, weight: .semibold))
                                        .foregroundColor(selectedTags.contains(tag) ? .white : RD.textSec)
                                        .padding(.horizontal, 12).padding(.vertical, 7)
                                        .background(selectedTags.contains(tag) ? RD.primary.opacity(0.85) : RD.elevated)
                                        .clipShape(Capsule())
                                        .overlay(Capsule().stroke(selectedTags.contains(tag) ? RD.primary.opacity(0) : RD.border))
                                }
                            }
                        }
                    }
                    .padding(18)
                    .background(RD.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .overlay(RoundedRectangle(cornerRadius: 18).stroke(RD.border))

                    // Comments text editor
                    VStack(alignment: .leading, spacing: 10) {
                        Text("ADDITIONAL COMMENTS")
                            .font(.system(size: 10, weight: .black))
                            .tracking(1.5)
                            .foregroundColor(RD.textTer)
                        ZStack(alignment: .topLeading) {
                            if comments.isEmpty {
                                Text("Tell us what we got right, or what could be better…")
                                    .font(.system(size: 13))
                                    .foregroundColor(RD.textTer)
                                    .padding(.top, 12).padding(.leading, 4)
                            }
                            TextEditor(text: $comments)
                                .font(.system(size: 13))
                                .foregroundColor(.white)
                                .frame(minHeight: 90)
                                .scrollContentBackground(.hidden)
                        }
                        .padding(14)
                        .background(RD.elevated)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(RD.border))
                    }
                    .padding(18)
                    .background(RD.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .overlay(RoundedRectangle(cornerRadius: 18).stroke(RD.border))

                    // Submit button
                    Button {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            submitted = true
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "paperplane.fill")
                            Text("Submit Feedback")
                        }
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(overallRating > 0 ? AnyView(AppGradients.brandPrimary) : AnyView(Color.white.opacity(0.1)))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .shadow(color: overallRating > 0 ? RD.primary.opacity(0.4) : .clear, radius: 10, y: 4)
                    }
                    .disabled(overallRating == 0)
                }

                Spacer().frame(height: 30)
            }
            .padding(.horizontal, 20).padding(.top, 14)
        }
    }
}

// MARK: - Feedback Rating Row
private struct FeedbackRatingRow: View {
    let label: String
    let icon: String
    let color: Color
    @Binding var rating: Int

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(color)
                .frame(width: 30, height: 30)
                .background(color.opacity(0.12))
                .clipShape(Circle())

            Text(label)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.white)

            Spacer()

            // 5-dot selector
            HStack(spacing: 6) {
                ForEach(1...5, id: \.self) { i in
                    Circle()
                        .fill(i <= rating ? color : RD.elevated)
                        .frame(width: i <= rating ? 14 : 10, height: i <= rating ? 14 : 10)
                        .overlay(Circle().stroke(i <= rating ? color : RD.border, lineWidth: 1))
                        .animation(.spring(response: 0.25, dampingFraction: 0.6), value: rating)
                        .onTapGesture { withAnimation { rating = i } }
                }
            }
        }
    }
}

// MARK: - Guest Locked Tab Paywall
struct GuestLockedTabView: View {
    let tabName: String
    let icon: String

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 32) {
                Spacer().frame(height: 40)

                ZStack {
                    VStack(spacing: 10) {
                        ForEach(0..<3, id: \.self) { i in
                            RoundedRectangle(cornerRadius: 14)
                                .fill(RD.surface).frame(maxWidth: .infinity).frame(height: 64)
                                .overlay(RoundedRectangle(cornerRadius: 14).stroke(RD.border))
                                .opacity(0.55 - Double(i) * 0.15)
                        }
                    }
                    .blur(radius: 6).allowsHitTesting(false)

                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(LinearGradient(colors: [Color.brandPrimary.opacity(0.25), Color.brandPrimary.opacity(0.08)], startPoint: .topLeading, endPoint: .bottomTrailing))
                                .frame(width: 80, height: 80)
                            Circle().stroke(Color.brandPrimary.opacity(0.3), lineWidth: 1.5).frame(width: 80, height: 80)
                            Image(systemName: icon)
                                .font(.system(size: 28, weight: .semibold))
                                .foregroundStyle(AppGradients.brandPrimary).opacity(0.5)
                            Image(systemName: "lock.fill")
                                .font(.system(size: 14, weight: .black))
                                .foregroundColor(.white).offset(x: 22, y: -22)
                        }
                        VStack(spacing: 8) {
                            Text("\(tabName) is Locked")
                                .font(.system(size: 20, weight: .black, design: .rounded)).foregroundColor(.white)
                            Text("Sign in or create a free account to unlock\nyour full \(tabName) analysis.")
                                .font(.system(size: 13, weight: .medium)).foregroundColor(RD.textSec)
                                .multilineTextAlignment(.center).fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                .padding(.horizontal, 32)

                VStack(spacing: 10) {
                    ForEach(lockedFeatures, id: \.0) { feature in
                        HStack(spacing: 12) {
                            Image(systemName: feature.1).font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.brandPrimary).frame(width: 30, height: 30)
                                .background(Color.brandPrimary.opacity(0.12)).clipShape(Circle())
                            Text(feature.0).font(.system(size: 13, weight: .medium))
                                .foregroundColor(RD.textSec).fixedSize(horizontal: false, vertical: true)
                            Spacer()
                        }
                    }
                }
                .padding(18).background(RD.surface)
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .overlay(RoundedRectangle(cornerRadius: 18).stroke(RD.border))
                .padding(.horizontal, 20)

                VStack(spacing: 12) {
                    Button { AppStateManager.shared.navigate(to: .auth) } label: {
                        HStack(spacing: 8) { Image(systemName: "lock.open.fill"); Text("Sign In to Unlock") }
                            .font(.system(size: 15, weight: .bold)).foregroundColor(.white)
                            .frame(maxWidth: .infinity).padding(.vertical, 16)
                            .background(AppGradients.brandPrimary)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .shadow(color: Color.brandPrimary.opacity(0.45), radius: 12, y: 5)
                    }
                    Button { AppStateManager.shared.navigate(to: .auth) } label: {
                        Text("Create Free Account")
                            .font(.system(size: 15, weight: .semibold)).foregroundColor(.brandPrimary)
                            .frame(maxWidth: .infinity).padding(.vertical, 16)
                            .background(Color.brandPrimary.opacity(0.10))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.brandPrimary.opacity(0.35), lineWidth: 1))
                    }
                }
                .padding(.horizontal, 20)
                Spacer().frame(height: 40)
            }
        }
    }

    private var lockedFeatures: [(String, String)] {
        switch tabName {
        case "Job Roles":
            return [("Matched roles with % fit scores and arc gauges", "person.badge.key.fill"),
                    ("Per-role roadmap with step-by-step guidance",    "map.fill"),
                    ("Skill-to-role mapping for top 3 matches",        "circle.lefthalf.filled")]
        case "Companies":
            return [("Tap each tier to see real companies + packages", "building.2.fill"),
                    ("Animated chance bars with insight tips",          "chart.bar.fill"),
                    ("Live score breakdown across 7 profile areas",     "chart.pie.fill")]
        case "Skill Gaps":
            return [("Critical, Moderate & Suggested gap cards",  "exclamationmark.triangle.fill"),
                    ("Actionable fix for every identified gap",    "checkmark.circle.fill"),
                    ("Personalised 30-Day Action Plan timeline",   "calendar.badge.clock")]
        case "Strengths":
            return [("Full list of your profile strengths",        "star.fill"),
                    ("Motivational career guidance card",           "sparkles"),
                    ("'Update My Profile' quick re-analysis CTA",  "arrow.clockwise")]
        case "Feedback":
            return [("Rate prediction accuracy and usefulness",    "star.fill"),
                    ("Quick tag selection for fast feedback",       "tag.fill"),
                    ("Help improve results for every student",      "person.3.fill")]
        default:
            return [("Full analytics for your profile", "chart.pie.fill"),
                    ("Personalised recommendations",     "lightbulb.fill"),
                    ("Detailed breakdown & next steps",  "list.bullet.clipboard.fill")]
        }
    }
}

// MARK: - Preview
#if DEBUG
struct ResultDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        ResultDashboardView(
            result: PlacementResult(
                overallProbability: 74.5,
                tier: .high,
                matchedRoles: [
                    JobRoleMatch(roleName: "iOS Engineer", matchPercentage: 92,
                                 averagePackageLPA: 14, requiredSkills: ["Swift","SwiftUI","UIKit","Xcode"], icon: "apple.logo"),
                    JobRoleMatch(roleName: "Full Stack Developer", matchPercentage: 76,
                                 averagePackageLPA: 12, requiredSkills: ["React","Node.js","MongoDB"], icon: "rectangle.split.3x1.fill"),
                    JobRoleMatch(roleName: "Backend Engineer", matchPercentage: 68,
                                 averagePackageLPA: 11, requiredSkills: ["Python","Databases","APIs"], icon: "server.rack")
                ],
                companyTierChances: CompanyTierChances(
                    tier1Percent: 67, tier2Percent: 83, serviceBasedPercent: 96,
                    tier1Examples: ["Google","Microsoft","Apple","Meta"],
                    tier2Examples: ["Razorpay","CRED","Meesho","Zepto"],
                    serviceBasedExamples: ["TCS","Infosys","Wipro","Accenture"]
                ),
                skillGaps: [
                    SkillGap(area: "DSA Practice",
                             description: "Problem count below 200.",
                             priority: .critical,
                             actionItem: "Solve 3 LeetCode Medium problems daily — focus on DP and Graphs."),
                    SkillGap(area: "LinkedIn",
                             description: "No LinkedIn profile linked.",
                             priority: .moderate,
                             actionItem: "Set up a complete LinkedIn profile and request 3 recommendations."),
                    SkillGap(area: "Certifications",
                             description: "No verified certifications.",
                             priority: .suggested,
                             actionItem: "Complete an AWS Cloud Practitioner or Google Data Analytics cert.")
                ],
                strengths: [
                    "Solid CGPA — strong academic profile.",
                    "2 deployed projects demonstrating execution.",
                    "Proficient in Swift, Python, and JavaScript."
                ],
                recommendedPath: "Commit to 3 LeetCode Medium problems every morning. DSA is the single biggest lever for Tier 1 and Tier 2 companies.",
                estimatedPackageLPA: 14.0...28.0
            ),
            formData: PredictionFormData()
        )
        .preferredColorScheme(.dark)
    }
}
#endif
