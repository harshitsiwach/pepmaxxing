import Foundation

// MARK: - Steroid Model

struct Steroid: Identifiable, Codable, Hashable {
    var id: String { name }
    let name: String
    let steroidClass: String
    let mechanism: String
    let clinicalEffects: String
    let dosageMen: String
    let dosageWomen: String
    let genderNotes: String
    let route: String
    let clinicalStatus: String
    let pharmacokinetics: String
    let adverseEffects: String
    let monitoringParameters: String
    let references: String
    
    // Computed properties
    var isFDAApproved: Bool {
        clinicalStatus.lowercased().contains("fda-approved") ||
        clinicalStatus.lowercased().contains("ema-approved")
    }
    
    var isInvestigational: Bool {
        clinicalStatus.lowercased().contains("investigational")
    }
    
    var statusColor: String {
        if isFDAApproved { return "00FF87" }
        if isInvestigational { return "FF9500" }
        return "A29BFE"
    }
    
    var statusIcon: String {
        if isFDAApproved { return "checkmark.shield.fill" }
        if isInvestigational { return "flask.fill" }
        return "magnifyingglass"
    }
    
    var routes: [String] {
        route.components(separatedBy: "/").map { $0.trimmingCharacters(in: .whitespaces) }
    }
    
    var primaryEffectsList: [String] {
        clinicalEffects.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
    }
}

// MARK: - Steroid Categories

enum SteroidCategory: String, CaseIterable {
    case all = "All"
    case glucocorticoid = "Glucocorticoid"
    case mineralocorticoid = "Mineralocorticoid"
    case androgenAAS = "Androgen/AAS"
    
    var icon: String {
        switch self {
        case .all: return "square.grid.2x2.fill"
        case .glucocorticoid: return "shield.lefthalf.filled"
        case .mineralocorticoid: return "drop.triangle.fill"
        case .androgenAAS: return "figure.strengthtraining.traditional"
        }
    }
}
