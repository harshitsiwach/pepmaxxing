import Foundation

// MARK: - Bloodwork Log Model

struct BloodworkLog: Identifiable, Codable {
    let id: UUID
    let date: Date
    var testosterone: Double?
    var freeTestosterone: Double?
    var estradiol: Double?
    var ast: Double?
    var alt: Double?
    var hdl: Double?
    var ldl: Double?
    var igf1: Double?
    var notes: String
    
    init(id: UUID = UUID(), date: Date = Date(), testosterone: Double? = nil, freeTestosterone: Double? = nil, estradiol: Double? = nil, ast: Double? = nil, alt: Double? = nil, hdl: Double? = nil, ldl: Double? = nil, igf1: Double? = nil, notes: String = "") {
        self.id = id
        self.date = date
        self.testosterone = testosterone
        self.freeTestosterone = freeTestosterone
        self.estradiol = estradiol
        self.ast = ast
        self.alt = alt
        self.hdl = hdl
        self.ldl = ldl
        self.igf1 = igf1
        self.notes = notes
    }
}

// MARK: - Injection Log Model

struct InjectionLog: Identifiable, Codable {
    let id: UUID
    let peptideName: String
    let dosage: String
    let route: String
    let date: Date
    let notes: String
    let injectionSite: String
    
    init(id: UUID = UUID(), peptideName: String, dosage: String, route: String, date: Date = Date(), notes: String = "", injectionSite: String = "") {
        self.id = id
        self.peptideName = peptideName
        self.dosage = dosage
        self.route = route
        self.date = date
        self.notes = notes
        self.injectionSite = injectionSite
    }
}

// MARK: - Cycle Model

struct Cycle: Identifiable, Codable {
    let id: UUID
    let name: String
    let peptides: [String]
    let startDate: Date
    var endDate: Date?
    var isActive: Bool
    var logs: [InjectionLog]
    
    init(id: UUID = UUID(), name: String, peptides: [String], startDate: Date = Date(), endDate: Date? = nil, isActive: Bool = true, logs: [InjectionLog] = []) {
        self.id = id
        self.name = name
        self.peptides = peptides
        self.startDate = startDate
        self.endDate = endDate
        self.isActive = isActive
        self.logs = logs
    }
    
    var durationDays: Int {
        let end = endDate ?? Date()
        return Calendar.current.dateComponents([.day], from: startDate, to: end).day ?? 0
    }
    
    var totalInjections: Int {
        logs.count
    }
}

// MARK: - User Profile

struct UserProfile: Codable {
    var gender: Gender
    var weight: Double // kg
    var height: Double // cm
    var age: Int
    var activityLevel: ActivityLevel
    var country: String
    var isDarkMode: Bool
    var unitSystem: UnitSystem
    var hasCompletedOnboarding: Bool
    var isAppLockEnabled: Bool
    
    enum Gender: String, Codable, CaseIterable {
        case male = "Male"
        case female = "Female"
        
        var icon: String {
            switch self {
            case .male: return "figure.stand"
            case .female: return "figure.stand.dress"
            }
        }
    }
    
    enum UnitSystem: String, Codable, CaseIterable {
        case metric = "Metric"
        case imperial = "Imperial"
    }
    
    enum ActivityLevel: String, Codable, CaseIterable {
        case sedentary = "Sedentary"
        case light = "Lightly Active"
        case moderate = "Moderately Active"
        case active = "Very Active"
        case extreme = "Extremely Active"
        
        var icon: String {
            switch self {
            case .sedentary: return "figure.seated.side"
            case .light: return "figure.walk"
            case .moderate: return "figure.run"
            case .active: return "figure.highintensity.intervaltraining"
            case .extreme: return "figure.strengthtraining.traditional"
            }
        }
        
        var multiplier: Double {
            switch self {
            case .sedentary: return 1.2
            case .light: return 1.375
            case .moderate: return 1.55
            case .active: return 1.725
            case .extreme: return 1.9
            }
        }
    }
    
    // BMI calculation
    var bmi: Double {
        guard height > 0 else { return 0 }
        let heightM = height / 100.0
        return weight / (heightM * heightM)
    }
    
    var bmiCategory: String {
        switch bmi {
        case ..<18.5: return "Underweight"
        case 18.5..<25: return "Normal"
        case 25..<30: return "Overweight"
        case 30...: return "Obese"
        default: return "Unknown"
        }
    }
    
    var bmiColor: String {
        switch bmi {
        case ..<18.5: return "FFB800"
        case 18.5..<25: return "00FF87"
        case 25..<30: return "FFB800"
        case 30...: return "FF2D55"
        default: return "A29BFE"
        }
    }
    
    // Weight in display unit
    var displayWeight: Double {
        unitSystem == .imperial ? weight * 2.20462 : weight
    }
    
    var displayHeight: Double {
        unitSystem == .imperial ? height / 2.54 : height
    }
    
    var weightUnit: String { unitSystem == .imperial ? "lbs" : "kg" }
    var heightUnit: String { unitSystem == .imperial ? "in" : "cm" }
    
    static let `default` = UserProfile(
        gender: .male,
        weight: 75,
        height: 175,
        age: 30,
        activityLevel: .moderate,
        country: "United States",
        isDarkMode: true,
        unitSystem: .metric,
        hasCompletedOnboarding: false,
        isAppLockEnabled: false
    )
}

// MARK: - PCT Models

struct PCTMedication: Identifiable, Codable {
    let id: UUID
    let name: String
    let protocolWeeks: [String] // e.g., ["40mg", "40mg", "20mg", "20mg"]
    
    init(id: UUID = UUID(), name: String, protocolWeeks: [String]) {
        self.id = id
        self.name = name
        self.protocolWeeks = protocolWeeks
    }
}

struct PCTProtocol: Identifiable, Codable {
    let id: UUID
    let cycleId: UUID?
    let name: String
    let startDate: Date
    let medications: [PCTMedication]
    var isActive: Bool
    
    init(id: UUID = UUID(), cycleId: UUID? = nil, name: String, startDate: Date, medications: [PCTMedication], isActive: Bool = true) {
        self.id = id
        self.cycleId = cycleId
        self.name = name
        self.startDate = startDate
        self.medications = medications
        self.isActive = isActive
    }
    
    var durationWeeks: Int {
        medications.map { $0.protocolWeeks.count }.max() ?? 0
    }
    
    var currentWeek: Int {
        let weeks = Calendar.current.dateComponents([.weekOfYear], from: startDate, to: Date()).weekOfYear ?? 0
        return max(1, weeks + 1)
    }
    
    var endDate: Date {
        Calendar.current.date(byAdding: .weekOfYear, value: durationWeeks, to: startDate) ?? Date()
    }
}

// MARK: - Photo Vault Models

struct PhotoLog: Identifiable, Codable {
    let id: UUID
    let date: Date
    let fileName: String
    var weight: Double?
    var notes: String
    
    init(id: UUID = UUID(), date: Date = Date(), fileName: String, weight: Double? = nil, notes: String = "") {
        self.id = id
        self.date = date
        self.fileName = fileName
        self.weight = weight
        self.notes = notes
    }
}

// MARK: - Support Meds & Oral Tracker Models

struct SupportMed: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var dosage: String
    var frequency: String // e.g., "Daily", "Weekly", "As Needed"
    var notes: String
    
    init(id: UUID = UUID(), name: String, dosage: String, frequency: String = "Daily", notes: String = "") {
        self.id = id
        self.name = name
        self.dosage = dosage
        self.frequency = frequency
        self.notes = notes
    }
}

struct DailySupportLog: Identifiable, Codable {
    let id: UUID
    let date: Date
    var completedMedIds: Set<UUID>
    
    init(id: UUID = UUID(), date: Date = Date(), completedMedIds: Set<UUID> = []) {
        self.id = id
        self.date = Calendar.current.startOfDay(for: date)
        self.completedMedIds = completedMedIds
    }
}
