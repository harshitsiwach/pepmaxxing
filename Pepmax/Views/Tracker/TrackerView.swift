import SwiftUI

struct TrackerView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.isDarkMode) private var isDarkMode
    @State private var showNewCycleSheet = false
    @State private var showLogSheet = false
    @State private var showAnalyticsSheet = false
    
    private var theme: LiquidGlassTheme { isDarkMode ? .dark : .light }
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Header
                    HStack {
                        Text("Tracker")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(theme.text)
                        Spacer()
                        
                        Button {
                            showAnalyticsSheet = true
                        } label: {
                            Image(systemName: "chart.bar.fill")
                                .font(.system(size: 20))
                                .foregroundStyle(theme.primary)
                                .frame(width: 44, height: 44)
                                .background {
                                    Circle().fill(theme.primary.opacity(0.12))
                                }
                        }
                        .buttonStyle(.plain)
                        
                        GlowButton(title: "New Cycle", icon: "plus", isSmall: true) {
                            showNewCycleSheet = true
                        }
                    }
                    
                    // Active cycle card
                    activeCycleSection
                    
                    // Quick log button
                    if store.activeCycle != nil {
                        GlowButton(title: "Log Injection", icon: "syringe.fill", color: theme.success) {
                            showLogSheet = true
                        }
                    }
                    
                    // Recent logs
                    recentLogsSection
                    
                    // Reminders
                    RemindersView()
                    
                    // Past cycles
                    pastCyclesSection
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 100)
            }
            .background(theme.background.ignoresSafeArea())
            .sheet(isPresented: $showNewCycleSheet) {
                NewCycleSheet()
                    .environmentObject(store)
                    .environment(\.isDarkMode, isDarkMode)
            }
            .sheet(isPresented: $showLogSheet) {
                LogInjectionSheet()
                    .environmentObject(store)
                    .environment(\.isDarkMode, isDarkMode)
            }
            .sheet(isPresented: $showAnalyticsSheet) {
                CycleAnalyticsView()
                    .environmentObject(store)
            }
        }
    }
    
    private var activeCycleSection: some View {
        Group {
            if let cycle = store.activeCycle {
                GlassCard {
                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            HStack(spacing: 6) {
                                Circle().fill(theme.success).frame(width: 8, height: 8)
                                Text(cycle.name)
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundStyle(theme.text)
                            }
                            Spacer()
                            Button {
                                store.endCycle(id: cycle.id)
                            } label: {
                                Text("End")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(theme.error)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background { Capsule().fill(theme.error.opacity(0.12)) }
                            }
                        }
                        
                        HStack(spacing: 20) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Day")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundStyle(theme.textMuted)
                                Text("\(cycle.durationDays)")
                                    .font(.system(size: 22, weight: .bold, design: .monospaced))
                                    .foregroundStyle(theme.text)
                            }
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Injections")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundStyle(theme.textMuted)
                                Text("\(cycle.totalInjections)")
                                    .font(.system(size: 22, weight: .bold, design: .monospaced))
                                    .foregroundStyle(theme.success)
                            }
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Compounds")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundStyle(theme.textMuted)
                                Text("\(cycle.peptides.count)")
                                    .font(.system(size: 22, weight: .bold, design: .monospaced))
                                    .foregroundStyle(theme.primary)
                            }
                        }
                        
                        // Peptide pills
                        FlowLayout(spacing: 6) {
                            ForEach(cycle.peptides, id: \.self) { name in
                                GlassPill(text: name, isSelected: false)
                            }
                        }
                    }
                }
            } else {
                GlassCard {
                    VStack(spacing: 12) {
                        Image(systemName: "syringe")
                            .font(.system(size: 32, weight: .light))
                            .foregroundStyle(theme.textMuted)
                        Text("No Active Cycle")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(theme.text)
                        Text("Create a new cycle to start tracking your peptide protocol")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundStyle(theme.textMuted)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                }
            }
        }
    }
    
    private var recentLogsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Logs")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(theme.text)
            
            if store.recentLogs.isEmpty {
                GlassCard {
                    Text("No injections logged yet")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(theme.textMuted)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
            } else {
                ForEach(store.recentLogs) { log in
                    GlassCard(padding: 12) {
                        HStack(spacing: 12) {
                            Circle()
                                .fill(theme.primary.opacity(0.15))
                                .frame(width: 36, height: 36)
                                .overlay {
                                    Image(systemName: "syringe.fill")
                                        .font(.system(size: 14))
                                        .foregroundStyle(theme.primary)
                                }
                            VStack(alignment: .leading, spacing: 2) {
                                Text(log.peptideName)
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(theme.text)
                                Text("\(log.dosage) • \(log.route)")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundStyle(theme.textMuted)
                            }
                            Spacer()
                            Text(log.date, style: .relative)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(theme.textMuted)
                        }
                    }
                }
            }
        }
    }
    
    private var pastCyclesSection: some View {
        let pastCycles = store.cycles.filter { !$0.isActive }
        return Group {
            if !pastCycles.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Past Cycles")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(theme.text)
                    ForEach(pastCycles) { cycle in
                        GlassCard(padding: 12) {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(cycle.name)
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundStyle(theme.text)
                                    Text("\(cycle.durationDays) days • \(cycle.totalInjections) injections")
                                        .font(.system(size: 12))
                                        .foregroundStyle(theme.textMuted)
                                }
                                Spacer()
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - New Cycle Sheet

struct NewCycleSheet: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.isDarkMode) private var isDarkMode
    @Environment(\.dismiss) private var dismiss
    @State private var cycleName = ""
    @State private var selectedPeptides: Set<String> = []
    @State private var searchText = ""
    
    enum CompoundMode: String, CaseIterable {
        case peptides = "Peptides"
        case steroids = "Steroids"
    }
    @State private var mode: CompoundMode = .peptides
    
    private var theme: LiquidGlassTheme { isDarkMode ? .dark : .light }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Cycle name
                    GlassCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Cycle Name")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(theme.text)
                            TextField("e.g. Healing Protocol", text: $cycleName)
                                .font(.system(size: 16))
                                .foregroundStyle(theme.text)
                                .tint(theme.primary)
                        }
                    }
                    
                    // Select peptides
                    GlassSearchBar(text: $searchText, placeholder: "Search peptides to add...")
                    
                    // Mode Picker
                    Picker("Compound Type", selection: $mode) {
                        ForEach(CompoundMode.allCases, id: \.self) { m in
                            Text(m.rawValue).tag(m)
                        }
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: mode) { _ in searchText = "" }
                    
                    Text("\(selectedPeptides.count) selected")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(theme.primary)
                    
                    let filteredPeptidesList = store.peptides.filter {
                        searchText.isEmpty || $0.name.localizedCaseInsensitiveContains(searchText)
                    }
                    let filteredSteroidsList = store.steroids.filter {
                        searchText.isEmpty || $0.name.localizedCaseInsensitiveContains(searchText)
                    }
                    
                    LazyVStack(spacing: 8) {
                        if mode == .peptides {
                            ForEach(filteredPeptidesList) { peptide in
                                compoundRow(name: peptide.name, category: peptide.category)
                            }
                        } else {
                            ForEach(filteredSteroidsList) { steroid in
                                compoundRow(name: steroid.name, category: steroid.steroidClass)
                            }
                        }
                    }
                }
                .padding(20)
            }
            .background(theme.background.ignoresSafeArea())
            .navigationTitle("New Cycle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(theme.textMuted)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        guard !cycleName.isEmpty, !selectedPeptides.isEmpty else { return }
                        store.createCycle(name: cycleName, peptides: Array(selectedPeptides))
                        dismiss()
                    }
                    .foregroundStyle(theme.primary)
                    .fontWeight(.bold)
                }
            }
        }
        .presentationDetents([.large])
    }
    
    private func compoundRow(name: String, category: String) -> some View {
        Button {
            if selectedPeptides.contains(name) {
                selectedPeptides.remove(name)
            } else {
                selectedPeptides.insert(name)
            }
        } label: {
            HStack {
                Image(systemName: selectedPeptides.contains(name) ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(selectedPeptides.contains(name) ? theme.primary : theme.textMuted)
                Text(name).font(.system(size: 14, weight: .medium)).foregroundStyle(theme.text)
                Spacer()
                Text(category).font(.system(size: 11)).foregroundStyle(theme.textMuted)
            }
            .padding(.horizontal, 16).padding(.vertical, 10)
            .background { RoundedRectangle(cornerRadius: 10).fill(selectedPeptides.contains(name) ? theme.primary.opacity(0.08) : .clear) }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Log Injection Sheet

struct LogInjectionSheet: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.isDarkMode) private var isDarkMode
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPeptide = ""
    @State private var dosage = ""
    @State private var route = "Subcutaneous"
    @State private var notes = ""
    @State private var site = ""
    
    private var theme: LiquidGlassTheme { isDarkMode ? .dark : .light }
    
    let routes = ["Subcutaneous", "Intramuscular", "Intravenous", "Oral", "Nasal", "Topical"]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    if let cycle = store.activeCycle {
                        // Peptide picker
                        GlassCard {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Compound")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(theme.text)
                                Picker("Compound", selection: $selectedPeptide) {
                                    Text("Select...").tag("")
                                    ForEach(cycle.peptides, id: \.self) { name in
                                        Text(name).tag(name)
                                    }
                                }
                                .pickerStyle(.menu)
                                .tint(theme.primary)
                            }
                        }
                        
                        // Dosage
                        GlassCard {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Dosage")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(theme.text)
                                TextField("e.g. 2.5 mg", text: $dosage)
                                    .font(.system(size: 16, design: .monospaced))
                                    .foregroundStyle(theme.text)
                                    .tint(theme.primary)
                            }
                        }
                        
                        // Route
                        GlassCard {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Route")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(theme.text)
                                Picker("Route", selection: $route) {
                                    ForEach(routes, id: \.self) { r in
                                        Text(r).tag(r)
                                    }
                                }
                                .pickerStyle(.menu)
                                .tint(theme.primary)
                            }
                        }
                        
                        // Notes
                        GlassCard {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Notes (optional)")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(theme.text)
                                TextField("Any observations...", text: $notes)
                                    .font(.system(size: 14))
                                    .foregroundStyle(theme.text)
                                    .tint(theme.primary)
                            }
                        }
                    }
                }
                .padding(20)
            }
            .background(theme.background.ignoresSafeArea())
            .navigationTitle("Log Injection")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(theme.textMuted)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Log") {
                        guard let cycle = store.activeCycle, !selectedPeptide.isEmpty, !dosage.isEmpty else { return }
                        let log = InjectionLog(peptideName: selectedPeptide, dosage: dosage, route: route, notes: notes, injectionSite: site)
                        store.addInjectionLog(cycleId: cycle.id, log: log)
                        dismiss()
                    }
                    .foregroundStyle(theme.primary)
                    .fontWeight(.bold)
                }
            }
        }
        .presentationDetents([.medium])
    }
}
