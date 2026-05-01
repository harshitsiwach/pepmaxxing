import Foundation
import UIKit

class AppStore: ObservableObject {
    @Published var profile: UserProfile { didSet { saveProfile() } }
    @Published var cycles: [Cycle] { didSet { saveCycles() } }
    @Published var peptides: [Peptide] = []
    @Published var favoritePeptideNames: Set<String> { didSet { saveFavorites() } }
    @Published var recentlyViewedNames: [String] { didSet { saveRecents() } }
    
    @Published var steroids: [Steroid] = []
    @Published var favoriteSteroidNames: Set<String> { didSet { saveFavoriteSteroids() } }
    @Published var recentlyViewedSteroidNames: [String] { didSet { saveRecentSteroids() } }
    
    init() {
        self.profile = Self.loadProfile()
        self.cycles = Self.loadCycles()
        self.favoritePeptideNames = Self.loadFavorites()
        self.recentlyViewedNames = Self.loadRecents()
        self.peptides = PeptideDatabase.all
        
        self.favoriteSteroidNames = Self.loadFavoriteSteroids()
        self.recentlyViewedSteroidNames = Self.loadRecentSteroids()
        self.steroids = SteroidDatabase.shared.steroids
    }
    
    // MARK: - Favorites
    
    func isFavorite(_ peptide: Peptide) -> Bool {
        favoritePeptideNames.contains(peptide.name)
    }
    
    func toggleFavorite(_ peptide: Peptide) {
        if favoritePeptideNames.contains(peptide.name) {
            favoritePeptideNames.remove(peptide.name)
            Haptics.impact(.light)
        } else {
            favoritePeptideNames.insert(peptide.name)
            Haptics.impact(.medium)
        }
    }
    
    var favoritePeptides: [Peptide] {
        peptides.filter { favoritePeptideNames.contains($0.name) }
    }
    
    func isFavorite(_ steroid: Steroid) -> Bool {
        favoriteSteroidNames.contains(steroid.name)
    }
    
    func toggleFavorite(_ steroid: Steroid) {
        if favoriteSteroidNames.contains(steroid.name) {
            favoriteSteroidNames.remove(steroid.name)
            Haptics.impact(.light)
        } else {
            favoriteSteroidNames.insert(steroid.name)
            Haptics.impact(.medium)
        }
    }
    
    var favoriteSteroids: [Steroid] {
        steroids.filter { favoriteSteroidNames.contains($0.name) }
    }
    
    // MARK: - Recently Viewed
    
    func markViewed(_ peptide: Peptide) {
        recentlyViewedNames.removeAll { $0 == peptide.name }
        recentlyViewedNames.insert(peptide.name, at: 0)
        if recentlyViewedNames.count > 10 {
            recentlyViewedNames = Array(recentlyViewedNames.prefix(10))
        }
    }
    
    var recentlyViewedPeptides: [Peptide] {
        recentlyViewedNames.compactMap { name in
            peptides.first { $0.name == name }
        }
    }
    
    func markViewed(_ steroid: Steroid) {
        recentlyViewedSteroidNames.removeAll { $0 == steroid.name }
        recentlyViewedSteroidNames.insert(steroid.name, at: 0)
        if recentlyViewedSteroidNames.count > 10 {
            recentlyViewedSteroidNames = Array(recentlyViewedSteroidNames.prefix(10))
        }
    }
    
    var recentlyViewedSteroids: [Steroid] {
        recentlyViewedSteroidNames.compactMap { name in
            steroids.first { $0.name == name }
        }
    }
    
    // MARK: - Cycles
    
    var activeCycle: Cycle? { cycles.first(where: { $0.isActive }) }
    
    func createCycle(name: String, peptides: [String]) {
        cycles.append(Cycle(name: name, peptides: peptides))
        Haptics.notification(.success)
    }
    
    func endCycle(id: UUID) {
        if let idx = cycles.firstIndex(where: { $0.id == id }) {
            cycles[idx].isActive = false
            cycles[idx].endDate = Date()
            Haptics.notification(.warning)
        }
    }
    
    func addInjectionLog(cycleId: UUID, log: InjectionLog) {
        if let idx = cycles.firstIndex(where: { $0.id == cycleId }) {
            cycles[idx].logs.append(log)
            Haptics.notification(.success)
        }
    }
    
    var featuredPeptides: [Peptide] {
        let names = ["BPC-157", "Ipamorelin", "Semaglutide", "TB-500 (Thymosin Beta-4)", "Semax", "Melanotan II"]
        return peptides.filter { names.contains($0.name) }
    }
    
    var featuredSteroids: [Steroid] {
        let names = ["Testosterone (Cypionate/Enanthate)", "Oxandrolone", "Prednisone/Prednisolone", "Dexamethasone"]
        return steroids.filter { names.contains($0.name) }
    }
    
    var uniqueCategories: [String] {
        Array(Set(peptides.map { $0.category })).sorted()
    }
    
    var uniqueSteroidCategories: [String] {
        Array(Set(steroids.map { $0.steroidClass })).sorted()
    }
    
    var recentLogs: [InjectionLog] {
        cycles.flatMap { $0.logs }.sorted { $0.date > $1.date }.prefix(10).map { $0 }
    }
    
    var totalInjections: Int { cycles.reduce(0) { $0 + $1.totalInjections } }
    
    // MARK: - Persistence
    
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
    
    private static func loadFavorites() -> Set<String> {
        guard let arr = UserDefaults.standard.array(forKey: "favorite_peptides") as? [String] else { return [] }
        return Set(arr)
    }
    
    private func saveFavorites() {
        UserDefaults.standard.set(Array(favoritePeptideNames), forKey: "favorite_peptides")
    }
    
    private static func loadRecents() -> [String] {
        UserDefaults.standard.stringArray(forKey: "recent_peptides") ?? []
    }
    
    private func saveRecents() {
        UserDefaults.standard.set(recentlyViewedNames, forKey: "recent_peptides")
    }
    
    private static func loadFavoriteSteroids() -> Set<String> {
        guard let arr = UserDefaults.standard.array(forKey: "favorite_steroids") as? [String] else { return [] }
        return Set(arr)
    }
    
    private func saveFavoriteSteroids() {
        UserDefaults.standard.set(Array(favoriteSteroidNames), forKey: "favorite_steroids")
    }
    
    private static func loadRecentSteroids() -> [String] {
        UserDefaults.standard.stringArray(forKey: "recent_steroids") ?? []
    }
    
    private func saveRecentSteroids() {
        UserDefaults.standard.set(recentlyViewedSteroidNames, forKey: "recent_steroids")
    }
}

// MARK: - Haptics Engine

enum Haptics {
    static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }
    
    static func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        UINotificationFeedbackGenerator().notificationOccurred(type)
    }
    
    static func selection() {
        UISelectionFeedbackGenerator().selectionChanged()
    }
}
