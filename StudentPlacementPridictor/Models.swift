import SwiftUI
import Foundation

// MARK: - App Session State
enum AppRoute: Equatable {
    case splash
    case auth
    case dashboard
    case guest
    case predictionForm
    case results(PlacementResult)
}

// MARK: - User Model
struct User: Codable, Identifiable {
    var id: UUID = UUID()
    var fullName: String
    var email: String
    var mobile: String
    var dateOfBirth: Date
    var username: String
    var passwordHash: String
    var profileInitial: String { String(fullName.prefix(1)).uppercased() }
    var avatarColor: String = "#6C63FF"
    var joinDate: Date = Date()
    var predictionCount: Int = 0
    var lastPredictionScore: Double? = nil
}

// MARK: - Auth Models
struct OTPSession: Identifiable {
    let id = UUID()
    let otp: String
    let purpose: OTPPurpose
    let target: String
    var expiresAt: Date = Calendar.current.date(byAdding: .minute, value: 5, to: Date()) ?? Date()

    var isExpired: Bool { Date() > expiresAt }
}

enum OTPPurpose: String, Codable {
    case registration = "Registration"
    case emailChange  = "Email Change"
    case mobileChange = "Mobile Change"
    case login        = "Login Verification"
}

// MARK: - Prediction Form Models
struct EducationInfo: Codable {
    var tenthPercent: Double = 0.0
    var twelfthPercent: Double = 0.0
    var btechCGPA: Double = 0.0
    var btechBranch: BTechBranch = .cse
    var graduationYear: Int = 2025
}

enum BTechBranch: String, CaseIterable, Codable, Identifiable {
    // 💻 Computer Science, IT & Mathematics
        case cse = "Computer Science and Engineering"
        case it = "Information Technology"
        case aiml = "Artificial Intelligence and Machine Learning"
        case aids = "Artificial Intelligence and Data Science"
        case ds = "Data Science"
        case csbs = "Computer Science and Business Systems"
        case mnc = "Mathematics and Computing"
        case cds = "Computational and Data Science"
        case cy = "Cyber Security"
        case iot = "Internet of Things"
        case se = "Software Engineering"
        case csi = "Computer Science and Information Technology"
        
        // 🔌 Electrical, Electronics & Communication
        case ece = "Electronics and Communication Engineering"
        case ee = "Electrical Engineering"
        case eee = "Electrical and Electronics Engineering"
        case eie = "Electronics and Instrumentation Engineering"
        case vlsi = "VLSI Design and Technology (Semiconductor)"
        case ice = "Instrumentation and Control Engineering"
        case el = "Electronics Engineering"
        case et = "Electronics and Telecommunication Engineering"
        
        // 🏗️ Civil, Mechanical & Infrastructure
        case me = "Mechanical Engineering"
        case ce = "Civil Engineering"
        case pie = "Production and Industrial Engineering"
        case manufacturing = "Manufacturing Technology / Engineering"
        case smartManufacturing = "Industry 4.0 Advanced Tech"
        case transportation = "Transportation Engineering"
        case building = "Building Engineering and Construction Technology"
        case bPlan = "Bachelor of Planning"
        
        // 🤖 Automation, Mobility & Aerospace
        case mechatronics = "Mechatronics Engineering"
        case robo = "Robotics and Automation Engineering"
        case aero = "Aerospace / Aeronautical Engineering"
        case auto = "Automobile / Electric Vehicle Engineering"
        case design = "Engineering Design / Product Design"
        
        // 🧪 Chemical, Materials & Bio Sciences
        case chemE = "Chemical Engineering"
        case mme = "Metallurgical and Materials Engineering"
        case ceramic = "Ceramic Engineering / Technology"
        case polymer = "Polymer / Plastics Engineering"
        case bt = "Biotechnology"
        case bme = "Biomedical Engineering / Bioengineering"
        case ft = "Food Technology / Food Engineering"
        case bc = "Biochemical Engineering"
        case pharmaceutical = "Pharmaceutical Technology"
        
        // 🌍 Earth, Energy & Natural Resources
        case mn = "Mining Engineering"
        case pe = "Petroleum Engineering"
        case enve = "Environmental Engineering"
        case agri = "Agricultural Engineering / Technology"
        case geo = "Geotechnical / Geoinformatics Engineering"
        case renewableEnergy = "Sustainable Systems"
        
        // 🌊 Marine, Textile & Niche Industries
        case naoe = "Naval Architecture and Ocean Engineering"
        case marine = "Marine Engineering"
        case ep = "Engineering Physics"
        case tt = "Textile Technology / Engineering"
        case textileChemistry = "Advanced Chemical Processing for Fabrics"
        case printing = "Printing and Packaging Technology"
        case safetyFire = "Safety and Fire Engineering"
        
        case other = "Other"

        var id: String { rawValue }

        var shortName: String {
            switch self {
            case .cse: return "CSE"
            case .it: return "IT"
            case .aiml: return "AI & ML"
            case .aids: return "AIDS"
            case .ds: return "DS"
            case .csbs: return "CSBS"
            case .mnc: return "MnC"
            case .cds: return "CDS"
            case .cy: return "CY"
            case .iot: return "IoT"
            case .se: return "SE"
            case .csi: return "CSI"
            case .ece: return "ECE"
            case .ee: return "EE"
            case .eee: return "EEE"
            case .eie: return "EIE"
            case .vlsi: return "VLSI"
            case .ice: return "ICE"
            case .el: return "EL"
            case .et: return "ET"
            case .me: return "ME"
            case .ce: return "CE"
            case .pie: return "PIE"
            case .manufacturing: return "Manufacturing"
            case .smartManufacturing: return "Smart Mfg"
            case .transportation: return "Transportation"
            case .building: return "Building"
            case .bPlan: return "B.Plan"
            case .mechatronics: return "Mechatronics"
            case .robo: return "ROBO"
            case .aero: return "Aero"
            case .auto: return "Auto"
            case .design: return "Design"
            case .chemE: return "ChemE"
            case .mme: return "MME"
            case .ceramic: return "Ceramic"
            case .polymer: return "Polymer"
            case .bt: return "BT"
            case .bme: return "BME"
            case .ft: return "FT"
            case .bc: return "BC"
            case .pharmaceutical: return "Pharma"
            case .mn: return "MN"
            case .pe: return "PE"
            case .enve: return "EnvE"
            case .agri: return "Agri"
            case .geo: return "Geo"
            case .renewableEnergy: return "Green Tech"
            case .naoe: return "NAOE"
            case .marine: return "Marine"
            case .ep: return "EP"
            case .tt: return "TT"
            case .textileChemistry: return "Textile Chem"
            case .printing: return "Printing"
            case .safetyFire: return "Safety & Fire"
            case .other: return "Other"
            }
        }
}

struct InternshipInfo: Codable, Identifiable {
    var id: UUID = UUID()
    var companyName: String = ""
    var type: InternshipType = .remote
    var techRole: String = ""
    var duration: String = ""
    var stipend: String = ""
}

enum InternshipType: String, CaseIterable, Codable {
    case remote  = "Remote"
    case onSite  = "On-site"
    case hybrid  = "Hybrid"
    var icon: String {
        switch self {
        case .remote: return "wifi"
        case .onSite: return "building.2"
        case .hybrid: return "arrow.triangle.2.circlepath"
        }
    }
}

struct ProjectInfo: Codable, Identifiable {
    var id: UUID = UUID()
    var name: String = ""
    var type: ProjectType = .personal
    var realLifeUseCase: String = ""
    var techStack: String = ""
    var githubLink: String = ""
    var isDeployed: Bool = false
    var description: String = ""
}

enum ProjectType: String, CaseIterable, Codable {
    case personal  = "Personal"
    case academic  = "Academic"
    case openSource = "Open Source"
    case freelance = "Freelance"
    var icon: String {
        switch self {
        case .personal:   return "person"
        case .academic:   return "graduationcap"
        case .openSource: return "globe"
        case .freelance:  return "briefcase"
        }
    }
}

struct DSAInfo: Codable {
    var topicsKnown: Set<DSATopic> = []
    var expertiseLevel: DSAExpertise = .beginner
    var problemsSolved: Int = 0
    var leetcodeProfile: String = ""
    var hackerrankProfile: String = ""
    var codeforcesProfile: String = ""
    var codechefProfile: String = ""
}

enum DSATopic: String, CaseIterable, Codable, Hashable {
    case array = "Array"
        case string = "String"
        case hashTable = "Hash Table"
        case math = "Math"
        case dynamicProgramming = "Dynamic Programming"
        case sorting = "Sorting"
        case greedy = "Greedy"
        case depthFirstSearch = "Depth-First Search"
        case binarySearch = "Binary Search"
        case database = "Database"
        case bitManipulation = "Bit Manipulation"
        case matrix = "Matrix"
        case tree = "Tree"
        case prefixSum = "Prefix Sum"
        case breadthFirstSearch = "Breadth-First Search"
        case twoPointers = "Two Pointers"
        case heapPriorityQueue = "Heap (Priority Queue)"
        case simulation = "Simulation"
        case counting = "Counting"
        case graphTheory = "Graph Theory"
        case binaryTree = "Binary Tree"
        case stack = "Stack"
        case slidingWindow = "Sliding Window"
        case enumeration = "Enumeration"
        case design = "Design"
        case backtracking = "Backtracking"
        case numberTheory = "Number Theory"
        case unionFind = "Union-Find"
        case linkedList = "Linked List"
        case segmentTree = "Segment Tree"
        case orderedSet = "Ordered Set"
        case monotonicStack = "Monotonic Stack"
        case divideAndConquer = "Divide and Conquer"
        case combinatorics = "Combinatorics"
        case trie = "Trie"
        case queue = "Queue"
        case bitmask = "Bitmask"
        case recursion = "Recursion"
        case geometry = "Geometry"
        case binaryIndexedTree = "Binary Indexed Tree"
        case hashFunction = "Hash Function"
        case memoization = "Memoization"
        case binarySearchTree = "Binary Search Tree"
        case shortestPath = "Shortest Path"
        case topologicalSort = "Topological Sort"
        case stringMatching = "String Matching"
        case rollingHash = "Rolling Hash"
        case gameTheory = "Game Theory"
        case monotonicQueue = "Monotonic Queue"
        case interactive = "Interactive"
        case dataStream = "Data Stream"
        case brainteaser = "Brainteaser"
        case doublyLinkedList = "Doubly-Linked List"
        case mergeSort = "Merge Sort"
        case randomized = "Randomized"
        case countingSort = "Counting Sort"
        case iterator = "Iterator"
        case concurrency = "Concurrency"
        case quickselect = "Quickselect"
        case suffixArray = "Suffix Array"
        case sweepLine = "Sweep Line"
        case probabilityAndStatistics = "Probability and Statistics"
        case minimumSpanningTree = "Minimum Spanning Tree"
        case bucketSort = "Bucket Sort"
        case shell = "Shell"
        case reservoirSampling = "Reservoir Sampling"
        case eulerianCircuit = "Eulerian Circuit"
        case radixSort = "Radix Sort"
        case stronglyConnectedComponent = "Strongly Connected Component"
        case rejectionSampling = "Rejection Sampling"
        case biconnectedComponent = "Biconnected Component"
}

enum DSAExpertise: String, CaseIterable, Codable {
    case beginner     = "Beginner (< 100 problems)"
    case intermediate = "Intermediate (100–400 problems)"
    case advanced     = "Advanced (400–800 problems)"
    case expert       = "Expert (800+ / CP Rated)"
    var level: Int {
        switch self {
        case .beginner: return 1
        case .intermediate: return 2
        case .advanced: return 3
        case .expert: return 4
        }
    }
}

struct CertificationInfo: Codable, Identifiable {
    var id: UUID = UUID()
    var name: String = ""
    var provider: String = ""
    var certificationLink: String = ""
    var hasImageAttached: Bool = false
    var imageAttachmentName: String = ""
}

struct SoftSkillsInfo: Codable {
    var communicationRating: Int = 3
    var aptitudeScore: Double = 0.0
    var aptitudeMaxScore: Double = 100.0
    var teamworkRating: Int = 3
    var leadershipRating: Int = 3
    var problemSolvingRating: Int = 3
}

struct TechnicalSkillsInfo: Codable {
    var languages: Set<ProgrammingLanguage> = []
    var frameworks: Set<Framework> = []
    var databases: Set<Database> = []
    var cloudPlatforms: Set<CloudPlatform> = []
}

enum ProgrammingLanguage: String, CaseIterable, Codable, Hashable {
    // 🌐 Tier 1: The Global Titans (Highest Demand / Universal)
        case python = "Python"
        case javascript = "JavaScript"
        case html = "HTML"
        case css = "CSS"
        case sql = "SQL"
        case typescript = "TypeScript"

        // 🏢 Tier 2: Corporate, Enterprise & Systems Core
        case java = "Java"
        case csharp = "C#"
        case cpp = "C++"
        case c = "C"
        case php = "PHP"
        case go = "Go"
        case rust = "Rust"

        // 📱 Tier 3: Native Mobile & Cross-Platform
        case swift = "Swift"
        case kotlin = "Kotlin"
        case dart = "Dart"

        // ⚙️ Tier 4: Scripting, DevOps & Automation
        case bash = "Bash / Shell"
        case powershell = "PowerShell"
        case ruby = "Ruby"

        // 📊 Tier 5: Data Science, Math & Analytics
        case r = "R"
        case matlab = "MATLAB"
        case scala = "Scala"
        case julia = "Julia"

        // 🕹️ Tier 6: Niche, Legacy & Specialized Environments
        case lua = "Lua"
        case objectiveC = "Objective-C"
        case assembly = "Assembly Language"
        case solidity = "Solidity"
        case elixir = "Elixir"
        case haskell = "Haskell"
        case gdscript = "GDScript"

        // 🚀 Tier 7: Emerging & High-Performance Future Tech
        case zig = "Zig"
        case mojo = "Mojo"
        case gleam = "Gleam"
}

enum Framework: String, CaseIterable, Codable, Hashable {
    // 🐍 Python
        case django = "Django"
        case flask = "Flask"
        case fastAPI = "FastAPI"
        case pytorch = "PyTorch"
        case tensorflow = "TensorFlow"
        case scikitLearn = "Scikit-Learn"
        case numpy = "NumPy"
        case pandas = "Pandas"
        case matplotlib = "Matplotlib"
        case seaborn = "Seaborn"

        // 🟨 JavaScript
        case react = "React"
        case angular = "Angular"
        case vue = "Vue.js"
        case nodejs = "Node.js"
        case bun = "Bun"
        case express = "Express.js"
        case threejs = "Three.js"
        case pixijs = "PixiJS"

        // 🟦 TypeScript
        case nextjs = "Next.js"
        case remix = "Remix"
        case nestjs = "NestJS"
        case deno = "Deno"
        case reactNative = "React Native"

        // 🎨 HTML & CSS
        case tailwind = "Tailwind CSS"
        case bootstrap = "Bootstrap"

        // 🗄️ SQL Databases
        case postgresql = "PostgreSQL"
        case mysql = "MySQL"
        case sqlite = "SQLite"

        // ☕ Java
        case springBoot = "Spring Boot"
        case jakartaEE = "Jakarta EE"
        case apacheSpark = "Apache Spark"
        case apacheKafka = "Apache Kafka"

        // 🎯 C# (C-Sharp)
        case aspNetCore = "ASP.NET Core"
        case unity = "Unity Engine"
        case maui = "MAUI"

        // 🐹 Go (Golang)
        case gin = "Gin"
        case fiber = "Fiber"
        case docker = "Docker"
        case kubernetes = "Kubernetes"

        // 🐘 PHP
        case laravel = "Laravel"
        case symfony = "Symfony"
        case wordpress = "WordPress"

        // ⚙️ C++
        case unrealEngine = "Unreal Engine"
        case opengl = "OpenGL"
        case vulkan = "Vulkan"
        case cuda = "CUDA"
        case qt = "Qt"

        // 🦀 Rust
        case actixWeb = "Actix-web"
        case axum = "Axum"
        case bevy = "Bevy"
        case drizzleOrm = "Drizzle ORM"

        // 🏛️ C & System Architectures
        case linuxKernel = "Linux Kernel"
        case windowsNT = "Windows NT Kernel"

        // 🍏 Swift
        case swiftUI = "SwiftUI"
        case uiKit = "UIKit"

        // 🤖 Kotlin
        case jetpackCompose = "Jetpack Compose"
        case kotlinMultiplatform = "Kotlin Multiplatform (KMP)"

        // 🎯 Dart
        case flutter = "Flutter"

        // 📊 R, MATLAB & Julia
        case shiny = "Shiny"
        case tidyverse = "Tidyverse"
        case ggplot2 = "ggplot2"
        case simulink = "Simulink"
        case fluxJl = "Flux.jl"

        // 🐧 DevOps & Automation
        case ansible = "Ansible Modules"
        case awsCli = "AWS CLI Core"

        // 💎 Ruby & 🌙 Lua
        case rubyOnRails = "Ruby on Rails"
        case robloxEngine = "Roblox Engine (Luau)"
        case defold = "Defold"
}

enum Database: String, CaseIterable, Codable, Hashable {
    // 🗄️ Relational Titans (SQL)
        case mysql = "MySQL"
        case postgresql = "PostgreSQL"
        case oracle = "Oracle Database"
        case sqlServer = "Microsoft SQL Server"
        case mariadb = "MariaDB"

        // 📄 Document & NoSQL Leaders
        case mongodb = "MongoDB"
        case cassandra = "Cassandra"
        case dynamoDB = "DynamoDB"
        case neo4j = "Neo4j (Graph)"

        // 📱 Native Mobile & Local Storage
        case sqlite = "SQLite"
        case room = "Room Database"
        case swiftData = "SwiftData"
        case coreData = "CoreData"
        
        // 🎮 Game Development & Local Cache
        case playerPrefs = "PlayerPrefs"
        case redis = "Redis"

        // ☁️ Cloud Sync, BaaS & Search
        case firebase = "Firebase / Firestore"
        case supabase = "Supabase"
        case elasticsearch = "Elasticsearch"
}

enum CloudPlatform: String, CaseIterable, Codable, Hashable {
    case aws = "AWS"
    case gcp = "Google Cloud"
    case azure = "Azure"
    case heroku = "Heroku"
    case vercel = "Vercel"
    case netlify = "Netlify"
}

struct ResumeInfo: Codable {
    var hasUploadedResume: Bool = false
    var fileName: String = ""
    var fileSize: String = ""
    var lastUpdated: Date = Date()
    var isATSOptimized: Bool = false
}

struct PortfolioInfo: Codable {
    var websiteURL: String = ""
    var hasPortfolio: Bool = false
}

struct AchievementsInfo: Codable {
    var hackathons: String = ""
    var extraCurriculars: String = ""
    var publications: String = ""
    var awards: String = ""
}

struct CompetitiveExamsInfo: Codable {
    var hasGATEScore: Bool = false
    var gateScore: Double = 0.0
    var gateYear: Int = 2024
    var gateRank: Int = 0
    var hasJEEAdvanced: Bool = false
    var jeeAdvancedRank: Int = 0
}

struct SocialHandlesInfo: Codable {
    var linkedIn: String = ""
    var github: String = ""
    var naukri: String = ""
    var twitter: String = ""
    var personalBlog: String = ""
}

struct ToolsInfo: Codable {
    var selectedTools: Set<DevTool> = []
}

enum DevTool: String, CaseIterable, Codable, Hashable {
    case xcode = "Xcode"
    case git = "Git"
    case docker = "Docker"
    case kubernetes = "Kubernetes"
    case jenkins = "Jenkins"
    case vscode = "VS Code"
    case intellij = "IntelliJ IDEA"
    case postman = "Postman"
    case figma = "Figma"
    case jira = "Jira"
    case linux = "Linux"
    case vim = "Vim"
    case androidStudio = "Android Studio"
    case tableau = "Tableau"
    case jupyter = "Jupyter"
    var icon: String {
        switch self {
        case .xcode: return "hammer"
        case .git: return "arrow.triangle.branch"
        case .docker: return "shippingbox"
        case .kubernetes: return "k.circle"
        case .jenkins: return "gearshape.2"
        case .vscode: return "curlybraces"
        case .intellij: return "j.circle"
        case .postman: return "paperplane"
        case .figma: return "paintbrush"
        case .jira: return "list.bullet.clipboard"
        case .linux: return "terminal"
        case .vim: return "keyboard"
        case .androidStudio: return "a.circle"
        case .tableau: return "chart.bar.xaxis"
        case .jupyter: return "book"
        }
    }
}

// MARK: - Master Form Data
struct PredictionFormData: Codable {
    var education: EducationInfo = EducationInfo()
    var internships: [InternshipInfo] = []
    var projects: [ProjectInfo] = []
    var dsa: DSAInfo = DSAInfo()
    var certifications: [CertificationInfo] = []
    var softSkills: SoftSkillsInfo = SoftSkillsInfo()
    var technicalSkills: TechnicalSkillsInfo = TechnicalSkillsInfo()
    var resume: ResumeInfo = ResumeInfo()
    var portfolio: PortfolioInfo = PortfolioInfo()
    var achievements: AchievementsInfo = AchievementsInfo()
    var competitiveExams: CompetitiveExamsInfo = CompetitiveExamsInfo()
    var socialHandles: SocialHandlesInfo = SocialHandlesInfo()
    var tools: ToolsInfo = ToolsInfo()
}

// MARK: - Result Models
struct PlacementResult: Codable, Equatable, Hashable {
    var overallProbability: Double
    var tier: PlacementTier
    var matchedRoles: [JobRoleMatch]
    var companyTierChances: CompanyTierChances
    var skillGaps: [SkillGap]
    var strengths: [String]
    var recommendedPath: String
    var estimatedPackageLPA: ClosedRange<Double>

    static func == (lhs: PlacementResult, rhs: PlacementResult) -> Bool {
        lhs.overallProbability == rhs.overallProbability
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(overallProbability)
    }
}

enum PlacementTier: String, Codable {
    case high   = "High"
    case medium = "Medium"
    case low    = "Low"
    var color: Color {
        switch self {
        case .high:   return .brandAccent
        case .medium: return .brandGold
        case .low:    return .brandSecondary
        }
    }
    var gradient: LinearGradient {
        switch self {
        case .high:   return AppGradients.brandSuccess
        case .medium: return AppGradients.brandGold
        case .low:    return AppGradients.brandDanger
        }
    }
    var icon: String {
        switch self {
        case .high:   return "star.fill"
        case .medium: return "chart.bar.fill"
        case .low:    return "arrow.up.circle"
        }
    }
}

struct JobRoleMatch: Codable, Identifiable {
    var id: UUID = UUID()
    var roleName: String
    var matchPercentage: Double
    var averagePackageLPA: Double
    var requiredSkills: [String]
    var icon: String
}

struct CompanyTierChances: Codable {
    var tier1Percent: Double
    var tier2Percent: Double
    var serviceBasedPercent: Double
    var tier1Examples: [String]
    var tier2Examples: [String]
    var serviceBasedExamples: [String]
}

struct SkillGap: Codable, Identifiable {
    var id: UUID = UUID()
    var area: String
    var description: String
    var priority: GapPriority
    var actionItem: String
}

enum GapPriority: String, Codable {
    case critical  = "Critical"
    case moderate  = "Moderate"
    case suggested = "Suggested"
    var color: Color {
        switch self {
        case .critical:  return .dangerRed
        case .moderate:  return .warningAmber
        case .suggested: return .infoBlue
        }
    }
    var icon: String {
        switch self {
        case .critical:  return "exclamationmark.triangle.fill"
        case .moderate:  return "exclamationmark.circle.fill"
        case .suggested: return "lightbulb.fill"
        }
    }
}

// MARK: - Dashboard Stats
struct UserStats {
    var totalPredictions: Int
    var highestScore: Double
    var latestScore: Double
    var streakDays: Int
    var profileCompletion: Double
}

// MARK: - Form Step Configuration
struct FormStep: Identifiable {
    let id: Int
    let title: String
    let subtitle: String
    let icon: String
    let accentColor: Color
}

extension FormStep {
    static let allSteps: [FormStep] = [
        FormStep(id: 0, title: "Education",          subtitle: "Academic background",          icon: "graduationcap.fill",      accentColor: .brandPrimary),
        FormStep(id: 1, title: "Internships",        subtitle: "Work experience",              icon: "briefcase.fill",          accentColor: Color(hex: "#4DA8FF")),
        FormStep(id: 2, title: "Projects",           subtitle: "What you've built",           icon: "hammer.fill",             accentColor: Color(hex: "#FF8C42")),
        FormStep(id: 3, title: "DSA & Coding",       subtitle: "Algorithmic skills",           icon: "chevron.left.forwardslash.chevron.right", accentColor: Color(hex: "#43E97B")),
        FormStep(id: 4, title: "Certifications",     subtitle: "Verified credentials",         icon: "rosette",                 accentColor: Color(hex: "#F7C948")),
        FormStep(id: 5, title: "Soft Skills",        subtitle: "Communication & aptitude",     icon: "person.2.fill",           accentColor: Color(hex: "#FF6584")),
        FormStep(id: 6, title: "Tech Stack",         subtitle: "Languages & frameworks",       icon: "cpu.fill",                accentColor: Color(hex: "#9B59B6")),
        FormStep(id: 7, title: "Resume",             subtitle: "Your document",                icon: "doc.fill",                accentColor: Color(hex: "#26C6DA")),
        FormStep(id: 8, title: "Portfolio",          subtitle: "Personal website",             icon: "globe",                   accentColor: Color(hex: "#66BB6A")),
        FormStep(id: 9, title: "Achievements",       subtitle: "Highlights & extras",          icon: "trophy.fill",             accentColor: Color(hex: "#FFA726")),
        FormStep(id: 10, title: "Competitive Exams", subtitle: "GATE, JEE, GRE scores",       icon: "list.clipboard.fill",     accentColor: Color(hex: "#EC407A")),
        FormStep(id: 11, title: "Social Handles",    subtitle: "Online presence",              icon: "link",                    accentColor: Color(hex: "#42A5F5")),
        FormStep(id: 12, title: "Tools & IDEs",      subtitle: "Your dev environment",         icon: "wrench.and.screwdriver.fill", accentColor: Color(hex: "#AB47BC"))
    ]
}
