import Foundation

// MARK: - Peptide Model

struct Peptide: Identifiable, Codable, Hashable {
    var id: String { name }
    let name: String
    let category: String
    let mechanism: String
    let dosageRange: String
    let genderNotes: String
    let route: String
    let clinicalStatus: String
    let references: String
    
    // Computed properties
    var isFDAApproved: Bool {
        clinicalStatus.lowercased().contains("fda-approved") ||
        clinicalStatus.lowercased().contains("ema-approved")
    }
    
    var isInvestigational: Bool {
        clinicalStatus.lowercased().contains("investigational")
    }
    
    var isExperimental: Bool {
        clinicalStatus.lowercased().contains("experimental")
    }
    
    var statusColor: String {
        if isFDAApproved { return "00FF87" }
        if clinicalStatus.lowercased().contains("phase") { return "FFB800" }
        if isExperimental { return "FF9500" }
        return "A29BFE"
    }
    
    var statusIcon: String {
        if isFDAApproved { return "checkmark.shield.fill" }
        if isExperimental { return "flask.fill" }
        if clinicalStatus.lowercased().contains("phase") { return "clock.fill" }
        return "magnifyingglass"
    }
    
    var routes: [String] {
        route.components(separatedBy: "/").map { $0.trimmingCharacters(in: .whitespaces) }
    }
    
    var primaryEffects: [String] {
        mechanism.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
    }
}

// MARK: - Peptide Categories

enum PeptideCategory: String, CaseIterable {
    case all = "All"
    case ghSecretagogue = "GH Secretagogue"
    case ghrhAnalog = "GHRH Analog"
    case glp1 = "GLP-1 Agonist"
    case glp1gip = "GLP-1/GIP Agonist"
    case gutRepair = "Gut/Repair Peptide"
    case tissueRepair = "Tissue Repair"
    case neuroendocrine = "Neuroendocrine"
    case immuneModulator = "Immune Modulator"
    case neurotropic = "Neurotropic Peptide"
    case pomcAgonist = "POMC Agonist"
    case ghFragment = "GH Fragment"
    case mitochondrial = "Mitochondrial Peptide"
    case metabolic = "Metabolic Peptide"
    case boneMusculoskeletal = "Bone/Musculoskeletal"
    case metabolicGrowth = "Metabolic/Growth"
    case antimicrobial = "Antimicrobial Peptide"
    case reproductive = "Reproductive Peptide"
    case opioid = "Opioid Peptide Analogue"
    case neuropeptideY = "Neuropeptide Y Analog"
    case peptideMixture = "Peptide Mixture"
    case telomerase = "Telomerase Activator Peptide"
    case copperPeptide = "Copper Peptide Complex"
    case hematopoietic = "Hematopoietic Peptide"
    case cardiovascular = "Cardiovascular"
    
    var icon: String {
        switch self {
        case .all: return "square.grid.2x2.fill"
        case .ghSecretagogue, .ghrhAnalog: return "arrow.up.circle.fill"
        case .glp1, .glp1gip: return "scalemass.fill"
        case .gutRepair, .tissueRepair: return "bandage.fill"
        case .neuroendocrine: return "brain.fill"
        case .immuneModulator: return "shield.checkered"
        case .neurotropic: return "brain.head.profile"
        case .pomcAgonist: return "heart.fill"
        case .ghFragment: return "flame.fill"
        case .mitochondrial: return "bolt.fill"
        case .metabolic, .metabolicGrowth: return "chart.line.uptrend.xyaxis"
        case .boneMusculoskeletal: return "figure.strengthtraining.traditional"
        case .antimicrobial: return "allergens.fill"
        case .reproductive: return "leaf.fill"
        case .opioid: return "cross.case.fill"
        case .neuropeptideY: return "waveform.path.ecg"
        case .peptideMixture: return "testtube.2"
        case .telomerase: return "hourglass"
        case .copperPeptide: return "sparkles"
        case .hematopoietic: return "drop.fill"
        case .cardiovascular: return "heart.circle.fill"
        }
    }
}
