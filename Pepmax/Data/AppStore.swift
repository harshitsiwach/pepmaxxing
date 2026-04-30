import Foundation

class AppStore: ObservableObject {
    @Published var profile: UserProfile { didSet { saveProfile() } }
    @Published var cycles: [Cycle] { didSet { saveCycles() } }
    @Published var peptides: [Peptide] = []
    
    init() {
        self.profile = Self.loadProfile()
        self.cycles = Self.loadCycles()
        self.peptides = PeptideDatabase.all
    }
    
    var activeCycle: Cycle? { cycles.first(where: { $0.isActive }) }
    
    func createCycle(name: String, peptides: [String]) {
        cycles.append(Cycle(name: name, peptides: peptides))
    }
    
    func endCycle(id: UUID) {
        if let idx = cycles.firstIndex(where: { $0.id == id }) {
            cycles[idx].isActive = false
            cycles[idx].endDate = Date()
        }
    }
    
    func addInjectionLog(cycleId: UUID, log: InjectionLog) {
        if let idx = cycles.firstIndex(where: { $0.id == cycleId }) {
            cycles[idx].logs.append(log)
        }
    }
    
    var featuredPeptides: [Peptide] {
        let names = ["BPC-157", "Ipamorelin", "Semaglutide", "TB-500 (Thymosin Beta-4)", "Semax", "Melanotan II"]
        return peptides.filter { names.contains($0.name) }
    }
    
    var uniqueCategories: [String] {
        Array(Set(peptides.map { $0.category })).sorted()
    }
    
    var recentLogs: [InjectionLog] {
        cycles.flatMap { $0.logs }.sorted { $0.date > $1.date }.prefix(10).map { $0 }
    }
    
    var totalInjections: Int { cycles.reduce(0) { $0 + $1.totalInjections } }
    
    private static func loadProfile() -> UserProfile {
        guard let data = UserDefaults.standard.data(forKey: "user_profile"),
              let p = try? JSONDecoder().decode(UserProfile.self, from: data) else { return .default }
        return p
    }
    
    private func saveProfile() {
        if let data = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(data, forKey: "user_profile")
        }
    }
    
    private static func loadCycles() -> [Cycle] {
        guard let data = UserDefaults.standard.data(forKey: "cycles"),
              let c = try? JSONDecoder().decode([Cycle].self, from: data) else { return [] }
        return c
    }
    
    private func saveCycles() {
        if let data = try? JSONEncoder().encode(cycles) {
            UserDefaults.standard.set(data, forKey: "cycles")
        }
    }
}
