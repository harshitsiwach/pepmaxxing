import SwiftUI
import Charts
import PhotosUI

struct TrackerView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.isDarkMode) private var isDarkMode
    @State private var showNewCycleSheet = false
    @State private var showLogSheet = false
    @State private var showAnalyticsSheet = false
    @State private var showBloodworkSheet = false
    @State private var showRotationMap = false
    @State private var showPCTWizard = false
    @State private var showPhotoVault = false
    
    private var theme: LiquidGlassTheme { isDarkMode ? .dark : .light }
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Tracker")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundStyle(theme.text)
                            Spacer()
                            
                            GlowButton(title: store.activeCycle == nil ? "New Cycle" : "Log Injection", icon: "plus", isSmall: true) {
                                if store.activeCycle != nil {
                                    showLogSheet = true
                                } else {
                                    showNewCycleSheet = true
                                }
                            }
                        }
                        
                        // Tools Row
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                toolButton(icon: "drop.fill", color: Color(hex: "FF2D55"), text: "Bloodwork") {
                                    showBloodworkSheet = true
                                }
                                
                                toolButton(icon: "shield.fill", color: Color(hex: "0984E3"), text: "PCT") {
                                    showPCTWizard = true
                                }
                                
                                toolButton(icon: "camera.fill", color: Color(hex: "6C5CE7"), text: "Photos") {
                                    showPhotoVault = true
                                }
                                
                                toolButton(icon: "figure.arms.open", color: theme.primary, text: "Map") {
                                    showRotationMap = true
                                }
                                
                                toolButton(icon: "chart.bar.fill", color: theme.primary, text: "Stats") {
                                    showAnalyticsSheet = true
                                }
                            }
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
            .sheet(isPresented: $showBloodworkSheet) {
                BloodworkView()
                    .environmentObject(store)
            }
            .sheet(isPresented: $showRotationMap) {
                SiteRotationView()
                    .environmentObject(store)
            }
            .sheet(isPresented: $showPCTWizard) {
                PCTDashboardView()
                    .environmentObject(store)
            }
            .sheet(isPresented: $showPhotoVault) {
                ProgressPhotoVaultView()
                    .environmentObject(store)
            }
        }
    }
    
    private func toolButton(icon: String, color: Color, text: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(color)
                Text(text)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(theme.text)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(Color.white.opacity(isDarkMode ? 0.05 : 0.4))
            )
            .overlay(
                Capsule()
                    .stroke(color.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
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
                        
                        // Compound pills
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
                        Text("Create a new cycle to start tracking your compound protocol")
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
                    
                    // Select compounds
                    GlassSearchBar(text: $searchText, placeholder: "Search compounds to add...")
                    
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
    @State private var isFront = true
    
    private var theme: LiquidGlassTheme { isDarkMode ? .dark : .light }
    
    let routes = ["Subcutaneous", "Intramuscular", "Intravenous", "Oral", "Nasal", "Topical"]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    if let cycle = store.activeCycle {
                        // Compound picker
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
                        
                        // Injection Site Map
                        if route == "Subcutaneous" || route == "Intramuscular" {
                            BodyMapView(selectedSite: $site, isFront: $isFront, filterRoute: route)
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

// MARK: - Bloodwork View

struct BloodworkView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.isDarkMode) private var isDarkMode
    @Environment(\.dismiss) private var dismiss
    
    @State private var showAddSheet = false
    
    private var theme: LiquidGlassTheme { isDarkMode ? .dark : .light }
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    if store.bloodworkLogs.isEmpty {
                        emptyState
                    } else {
                        trendsSection
                        logsSection
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
                .padding(.bottom, 60)
            }
            .background(theme.background.ignoresSafeArea())
            .navigationTitle("Bloodwork")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(theme.textMuted)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(theme.primary)
                    }
                }
            }
            .sheet(isPresented: $showAddSheet) {
                AddBloodworkSheet()
                    .environmentObject(store)
            }
        }
    }
    
    private var emptyState: some View {
        GlassCard {
            VStack(spacing: 16) {
                Image(systemName: "drop.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(Color(hex: "FF2D55"))
                
                Text("No Biomarkers Tracked")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(theme.text)
                
                Text("Log your bloodwork to visualize how compounds are impacting your testosterone, liver enzymes, and lipids over time.")
                    .font(.system(size: 14))
                    .foregroundStyle(theme.textMuted)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                GlowButton(title: "Log Bloodwork", icon: "plus", color: Color(hex: "FF2D55")) {
                    showAddSheet = true
                }
                .padding(.top, 10)
            }
            .padding(.vertical, 20)
        }
    }
    
    // MARK: - Trends
    private var trendsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Biomarker Trends")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(theme.text)
            
            // Testosterone Chart
            chartCard(title: "Total Testosterone", unit: "ng/dL", color: theme.primary) {
                Chart {
                    ForEach(store.bloodworkLogs.sorted(by: { $0.date < $1.date })) { log in
                        if let val = log.testosterone {
                            LineMark(
                                x: .value("Date", log.date),
                                y: .value("Level", val)
                            )
                            .foregroundStyle(theme.primary)
                            .symbol(Circle())
                            
                            PointMark(
                                x: .value("Date", log.date),
                                y: .value("Level", val)
                            )
                            .foregroundStyle(theme.primary)
                        }
                    }
                }
                .chartYScale(domain: .automatic(includesZero: false))
            }
            
            // Liver Enzymes
            chartCard(title: "Liver Enzymes (AST / ALT)", unit: "U/L", color: theme.warning) {
                Chart {
                    ForEach(store.bloodworkLogs.sorted(by: { $0.date < $1.date })) { log in
                        if let ast = log.ast {
                            LineMark(
                                x: .value("Date", log.date),
                                y: .value("AST", ast),
                                series: .value("Type", "AST")
                            )
                            .foregroundStyle(Color(hex: "FFB800"))
                            .symbol(Circle())
                        }
                        if let alt = log.alt {
                            LineMark(
                                x: .value("Date", log.date),
                                y: .value("ALT", alt),
                                series: .value("Type", "ALT")
                            )
                            .foregroundStyle(Color(hex: "FF2D55"))
                            .symbol(BasicChartSymbolShape.square)
                        }
                    }
                }
                .chartYScale(domain: .automatic(includesZero: true))
            }
        }
    }
    
    private func chartCard<Content: View>(title: String, unit: String, color: Color, @ViewBuilder content: () -> Content) -> some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(theme.text)
                    Spacer()
                    Text(unit)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(theme.textMuted)
                }
                
                content()
                    .frame(height: 150)
                    .padding(.top, 10)
            }
        }
    }
    
    // MARK: - Logs History
    private var logsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("History")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(theme.text)
            
            ForEach(store.bloodworkLogs.sorted(by: { $0.date > $1.date })) { log in
                GlassCard(padding: 16) {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "drop.fill")
                                .foregroundStyle(Color(hex: "FF2D55"))
                            Text(log.date.formatted(date: .abbreviated, time: .omitted))
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(theme.text)
                            Spacer()
                        }
                        
                        Divider().foregroundStyle(theme.border)
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            if let test = log.testosterone {
                                markerView(name: "Test", value: String(format: "%.0f", test))
                            }
                            if let e2 = log.estradiol {
                                markerView(name: "E2", value: String(format: "%.1f", e2))
                            }
                            if let ast = log.ast, let alt = log.alt {
                                markerView(name: "AST/ALT", value: "\(Int(ast))/\(Int(alt))")
                            }
                            if let hdl = log.hdl, let ldl = log.ldl {
                                markerView(name: "HDL/LDL", value: "\(Int(hdl))/\(Int(ldl))")
                            }
                            if let igf1 = log.igf1 {
                                markerView(name: "IGF-1", value: String(format: "%.0f", igf1))
                            }
                        }
                        
                        if !log.notes.isEmpty {
                            Text(log.notes)
                                .font(.system(size: 13))
                                .foregroundStyle(theme.textMuted)
                                .padding(.top, 4)
                        }
                    }
                }
            }
        }
    }
    
    private func markerView(name: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .foregroundStyle(theme.text)
            Text(name)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(theme.textMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background {
            RoundedRectangle(cornerRadius: 8)
                .fill(theme.primary.opacity(0.08))
        }
    }
}

// MARK: - Add Bloodwork Sheet

struct AddBloodworkSheet: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.isDarkMode) private var isDarkMode
    @Environment(\.dismiss) private var dismiss
    
    @State private var date = Date()
    @State private var testosterone = ""
    @State private var estradiol = ""
    @State private var ast = ""
    @State private var alt = ""
    @State private var hdl = ""
    @State private var ldl = ""
    @State private var notes = ""
    
    private var theme: LiquidGlassTheme { isDarkMode ? .dark : .light }
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    GlassCard {
                        DatePicker("Date of Draw", selection: $date, displayedComponents: .date)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(theme.text)
                            .tint(theme.primary)
                    }
                    
                    GlassCard {
                        VStack(spacing: 16) {
                            Text("Hormones").font(.system(size: 16, weight: .bold)).frame(maxWidth: .infinity, alignment: .leading).foregroundStyle(theme.text)
                            inputRow(title: "Total Test (ng/dL)", text: $testosterone)
                            inputRow(title: "Estradiol / E2 (pg/mL)", text: $estradiol)
                        }
                    }
                    
                    GlassCard {
                        VStack(spacing: 16) {
                            Text("Liver (CMP)").font(.system(size: 16, weight: .bold)).frame(maxWidth: .infinity, alignment: .leading).foregroundStyle(theme.text)
                            HStack(spacing: 16) {
                                inputRow(title: "AST (U/L)", text: $ast)
                                inputRow(title: "ALT (U/L)", text: $alt)
                            }
                        }
                    }
                    
                    GlassCard {
                        VStack(spacing: 16) {
                            Text("Lipids").font(.system(size: 16, weight: .bold)).frame(maxWidth: .infinity, alignment: .leading).foregroundStyle(theme.text)
                            HStack(spacing: 16) {
                                inputRow(title: "HDL (mg/dL)", text: $hdl)
                                inputRow(title: "LDL (mg/dL)", text: $ldl)
                            }
                        }
                    }
                    
                    GlassCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Notes")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(theme.text)
                            TextField("Any cycle notes...", text: $notes)
                                .font(.system(size: 14))
                                .foregroundStyle(theme.text)
                                .tint(theme.primary)
                        }
                    }
                }
                .padding(20)
            }
            .background(theme.background.ignoresSafeArea())
            .navigationTitle("Log Bloodwork")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(theme.textMuted)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                    }
                    .foregroundStyle(theme.primary)
                    .fontWeight(.bold)
                }
            }
        }
        .presentationDetents([.large])
    }
    
    private func inputRow(title: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(theme.textMuted)
            TextField("0.0", text: text)
                .font(.system(size: 18, weight: .bold, design: .monospaced))
                .foregroundStyle(theme.text)
                .keyboardType(.decimalPad)
                .tint(theme.primary)
        }
    }
    
    private func save() {
        let log = BloodworkLog(
            date: date,
            testosterone: Double(testosterone),
            estradiol: Double(estradiol),
            ast: Double(ast),
            alt: Double(alt),
            hdl: Double(hdl),
            ldl: Double(ldl),
            notes: notes
        )
        store.bloodworkLogs.append(log)
        Haptics.notification(.success)
        dismiss()
    }
}

// MARK: - Injection Site Map Data

struct BodyNode: Identifiable {
    let id: String
    let name: String
    let x: CGFloat // Percentage 0-1
    let y: CGFloat // Percentage 0-1
    let isFront: Bool
    let isSubq: Bool
    let isIM: Bool
}

struct InjectionSiteData {
    static let nodes: [BodyNode] = [
        // Front - SubQ / IM
        BodyNode(id: "L_Delt", name: "Left Deltoid", x: 0.25, y: 0.3, isFront: true, isSubq: false, isIM: true),
        BodyNode(id: "R_Delt", name: "Right Deltoid", x: 0.75, y: 0.3, isFront: true, isSubq: false, isIM: true),
        BodyNode(id: "L_Ab", name: "Left Abdomen", x: 0.4, y: 0.55, isFront: true, isSubq: true, isIM: false),
        BodyNode(id: "R_Ab", name: "Right Abdomen", x: 0.6, y: 0.55, isFront: true, isSubq: true, isIM: false),
        BodyNode(id: "L_Quad", name: "Left Quad", x: 0.35, y: 0.75, isFront: true, isSubq: true, isIM: true),
        BodyNode(id: "R_Quad", name: "Right Quad", x: 0.65, y: 0.75, isFront: true, isSubq: true, isIM: true),
        BodyNode(id: "L_Pec", name: "Left Pec", x: 0.35, y: 0.35, isFront: true, isSubq: false, isIM: true),
        BodyNode(id: "R_Pec", name: "Right Pec", x: 0.65, y: 0.35, isFront: true, isSubq: false, isIM: true),
        
        // Back - IM / SubQ
        BodyNode(id: "L_Glute", name: "Left Glute", x: 0.4, y: 0.6, isFront: false, isSubq: false, isIM: true),
        BodyNode(id: "R_Glute", name: "Right Glute", x: 0.6, y: 0.6, isFront: false, isSubq: false, isIM: true),
        BodyNode(id: "L_VGlute", name: "Left Ventrogluteal", x: 0.25, y: 0.55, isFront: false, isSubq: false, isIM: true),
        BodyNode(id: "R_VGlute", name: "Right Ventrogluteal", x: 0.75, y: 0.55, isFront: false, isSubq: false, isIM: true),
        BodyNode(id: "L_Lat", name: "Left Lat", x: 0.35, y: 0.4, isFront: false, isSubq: false, isIM: true),
        BodyNode(id: "R_Lat", name: "Right Lat", x: 0.65, y: 0.4, isFront: false, isSubq: false, isIM: true)
    ]
}

struct BodyMapView: View {
    @Binding var selectedSite: String
    @Binding var isFront: Bool
    var filterRoute: String? // "Subcutaneous" or "Intramuscular"
    
    @Environment(\.isDarkMode) private var isDarkMode
    private var theme: LiquidGlassTheme { isDarkMode ? .dark : .light }
    
    var body: some View {
        VStack(spacing: 16) {
            // Toggle Front/Back
            HStack {
                Text("Select Injection Site")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(theme.text)
                Spacer()
                Button {
                    withAnimation(.spring) { isFront.toggle() }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                        Text(isFront ? "Front" : "Back")
                    }
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(theme.primary)
                    .padding(.horizontal, 10).padding(.vertical, 6)
                    .background { Capsule().fill(theme.primary.opacity(0.15)) }
                }
                .buttonStyle(.plain)
            }
            
            // Map
            ZStack {
                // The Silhouette
                Image(systemName: isFront ? "figure.arms.open" : "figure.arms.open")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(isDarkMode ? Color.white.opacity(0.1) : Color.black.opacity(0.1))
                    .frame(height: 280)
                    .scaleEffect(x: isFront ? 1 : -1, y: 1) // mirror for back
                
                // Nodes
                GeometryReader { geo in
                    let w = geo.size.width
                    let h = geo.size.height
                    
                    let filteredNodes = InjectionSiteData.nodes.filter { node in
                        node.isFront == isFront &&
                        (filterRoute == "Subcutaneous" ? node.isSubq : (filterRoute == "Intramuscular" ? node.isIM : true))
                    }
                    
                    ForEach(filteredNodes) { node in
                        let isSelected = selectedSite == node.name
                        
                        Circle()
                            .fill(isSelected ? theme.primary : Color(hex: "00FF87").opacity(0.7))
                            .frame(width: isSelected ? 20 : 14, height: isSelected ? 20 : 14)
                            .overlay {
                                if isSelected {
                                    Circle().stroke(theme.primary, lineWidth: 4).scaleEffect(1.5).opacity(0.4)
                                }
                            }
                            .shadow(color: isSelected ? theme.primary.opacity(0.6) : .clear, radius: 4)
                            .position(x: node.x * w, y: node.y * h)
                            .onTapGesture {
                                withAnimation(.spring) {
                                    selectedSite = node.name
                                    Haptics.selection()
                                }
                            }
                    }
                }
                .frame(width: 140, height: 280) // Restrict width to overlay correctly over the figure
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background {
                RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(isDarkMode ? 0.03 : 0.4))
            }
            
            // Selected Site text
            if !selectedSite.isEmpty {
                Text("Selected: \(selectedSite)")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(theme.primary)
            } else {
                Text("Tap a glowing node on the body")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(theme.textMuted)
            }
        }
    }
}

// MARK: - Site Rotation Heatmap

struct SiteRotationView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.isDarkMode) private var isDarkMode
    @Environment(\.dismiss) private var dismiss
    
    @State private var isFront = true
    
    private var theme: LiquidGlassTheme { isDarkMode ? .dark : .light }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    GlassCard {
                        VStack(spacing: 20) {
                            Picker("View", selection: $isFront) {
                                Text("Front Body").tag(true)
                                Text("Back Body").tag(false)
                            }
                            .pickerStyle(.segmented)
                            
                            ZStack {
                                Image(systemName: "figure.arms.open")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundStyle(isDarkMode ? Color.white.opacity(0.1) : Color.black.opacity(0.1))
                                    .frame(height: 350)
                                    .scaleEffect(x: isFront ? 1 : -1, y: 1)
                                
                                GeometryReader { geo in
                                    let w = geo.size.width
                                    let h = geo.size.height
                                    
                                    ForEach(InjectionSiteData.nodes.filter { $0.isFront == isFront }) { node in
                                        let status = siteStatus(siteName: node.name)
                                        
                                        Circle()
                                            .fill(statusColor(status))
                                            .frame(width: 20, height: 20)
                                            .shadow(color: statusColor(status).opacity(0.6), radius: 6)
                                            .position(x: node.x * w, y: node.y * h)
                                            .overlay {
                                                if status > 0 {
                                                    Text("\(status)d")
                                                        .font(.system(size: 8, weight: .bold))
                                                        .foregroundStyle(.white)
                                                        .position(x: node.x * w, y: node.y * h)
                                                }
                                            }
                                    }
                                }
                                .frame(width: 175, height: 350)
                            }
                            .padding(.vertical, 20)
                            
                            // Legend
                            HStack(spacing: 16) {
                                legendItem(color: Color(hex: "FF2D55"), text: "Recent (0-3d)")
                                legendItem(color: theme.warning, text: "Healing (4-7d)")
                                legendItem(color: Color(hex: "00FF87"), text: "Safe (7d+)")
                            }
                            .padding(.top, 10)
                        }
                    }
                    
                    GlassCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Recent Injection Sites")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(theme.text)
                            
                            let recentLogs = store.cycles.flatMap { $0.logs }
                                .filter { !$0.injectionSite.isEmpty }
                                .sorted { $0.date > $1.date }
                                .prefix(10)
                            
                            if recentLogs.isEmpty {
                                Text("No sites logged yet")
                                    .font(.system(size: 14))
                                    .foregroundStyle(theme.textMuted)
                            } else {
                                ForEach(Array(recentLogs), id: \.id) { log in
                                    HStack {
                                        Text(log.injectionSite)
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundStyle(theme.text)
                                        Spacer()
                                        Text(log.date, style: .relative)
                                            .font(.system(size: 12))
                                            .foregroundStyle(theme.textMuted)
                                    }
                                    .padding(.vertical, 4)
                                    Divider().foregroundStyle(theme.border)
                                }
                            }
                        }
                    }
                }
                .padding(20)
            }
            .background(theme.background.ignoresSafeArea())
            .navigationTitle("Rotation Map")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(theme.primary)
                }
            }
        }
    }
    
    // Returns days since last injection at this site. -1 means never/safe.
    private func siteStatus(siteName: String) -> Int {
        let logs = store.cycles.flatMap { $0.logs }.filter { $0.injectionSite == siteName }
        guard let lastLog = logs.sorted(by: { $0.date > $1.date }).first else { return -1 }
        
        let components = Calendar.current.dateComponents([.day], from: lastLog.date, to: Date())
        return components.day ?? 0
    }
    
    private func statusColor(_ days: Int) -> Color {
        if days < 0 || days >= 7 { return Color(hex: "00FF87") } // Safe
        if days <= 3 { return Color(hex: "FF2D55") } // Recent/Hot
        return theme.warning // Healing
    }
    
    private func legendItem(color: Color, text: String) -> some View {
        HStack(spacing: 4) {
            Circle().fill(color).frame(width: 10, height: 10)
            Text(text).font(.system(size: 10, weight: .semibold)).foregroundStyle(theme.textMuted)
        }
    }
}

// MARK: - PCT Wizard View

struct PCTWizardView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.isDarkMode) private var isDarkMode
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedProtocol: ProtocolType = .nolvadex
    @State private var startDate = Date()
    @State private var customName = ""
    
    private var theme: LiquidGlassTheme { isDarkMode ? .dark : .light }
    
    enum ProtocolType: String, CaseIterable {
        case nolvadex = "Standard Nolvadex"
        case clomid = "Standard Clomid"
        case heavy = "Heavy (Clomid + Nolva)"
        
        var description: String {
            switch self {
            case .nolvadex: return "4 Weeks. Best for mild cycles. 40/40/20/20."
            case .clomid: return "4 Weeks. Stronger restart. 50/50/25/25."
            case .heavy: return "4 Weeks. For suppressive cycles."
            }
        }
        
        var meds: [PCTMedication] {
            switch self {
            case .nolvadex:
                return [PCTMedication(name: "Nolvadex (Tamoxifen)", protocolWeeks: ["40mg/day", "40mg/day", "20mg/day", "20mg/day"])]
            case .clomid:
                return [PCTMedication(name: "Clomid (Clomiphene)", protocolWeeks: ["50mg/day", "50mg/day", "25mg/day", "25mg/day"])]
            case .heavy:
                return [
                    PCTMedication(name: "Clomid", protocolWeeks: ["50mg/day", "50mg/day", "25mg/day", "25mg/day"]),
                    PCTMedication(name: "Nolvadex", protocolWeeks: ["40mg/day", "40mg/day", "20mg/day", "20mg/day"])
                ]
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "shield.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(Color(hex: "0984E3"))
                            .shadow(color: Color(hex: "0984E3").opacity(0.4), radius: 10)
                        
                        Text("Post Cycle Therapy")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(theme.text)
                        
                        Text("Restore your natural testosterone production safely.")
                            .font(.system(size: 14))
                            .foregroundStyle(theme.textMuted)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.top, 20)
                    
                    // Setup
                    GlassCard {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("When does PCT begin?")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(theme.text)
                            
                            DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                                .font(.system(size: 14, weight: .medium))
                                .tint(theme.primary)
                        }
                    }
                    
                    // Protocols
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Select Protocol")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(theme.text)
                        
                        ForEach(ProtocolType.allCases, id: \.self) { pt in
                            protocolCard(pt)
                        }
                    }
                    
                    GlowButton(title: "Start Recovery Protocol", icon: "play.fill", color: Color(hex: "0984E3")) {
                        startProtocol()
                    }
                    .padding(.top, 10)
                    .padding(.bottom, 40)
                }
                .padding(20)
            }
            .background(theme.background.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(theme.textMuted)
                }
            }
        }
        .presentationDetents([.large])
    }
    
    private func protocolCard(_ pt: ProtocolType) -> some View {
        Button {
            withAnimation(.spring) {
                selectedProtocol = pt
            }
        } label: {
            GlassCard(padding: 16) {
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(selectedProtocol == pt ? Color(hex: "0984E3") : Color.white.opacity(0.1))
                            .frame(width: 24, height: 24)
                        
                        if selectedProtocol == pt {
                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(.white)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(pt.rawValue)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(theme.text)
                        Text(pt.description)
                            .font(.system(size: 13))
                            .foregroundStyle(theme.textMuted)
                            .multilineTextAlignment(.leading)
                    }
                    Spacer()
                }
            }
            .overlay {
                if selectedProtocol == pt {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color(hex: "0984E3"), lineWidth: 2)
                }
            }
        }
        .buttonStyle(.plain)
    }
    
    private func startProtocol() {
        let pct = PCTProtocol(name: selectedProtocol.rawValue, startDate: startDate, medications: selectedProtocol.meds)
        store.startPCT(pct)
        dismiss()
    }
}

// MARK: - PCT Dashboard View

struct PCTDashboardView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.isDarkMode) private var isDarkMode
    @Environment(\.dismiss) private var dismiss
    
    @State private var showWizard = false
    
    private var theme: LiquidGlassTheme { isDarkMode ? .dark : .light }
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    if let pct = store.activePCT {
                        activeState(pct)
                    } else {
                        emptyState
                    }
                }
                .padding(20)
            }
            .background(theme.background.ignoresSafeArea())
            .navigationTitle("PCT Tracker")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(theme.primary)
                }
            }
            .sheet(isPresented: $showWizard) {
                PCTWizardView()
                    .environmentObject(store)
            }
        }
    }
    
    private var emptyState: some View {
        GlassCard {
            VStack(spacing: 16) {
                Image(systemName: "shield.slash.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(Color(hex: "0984E3").opacity(0.5))
                
                Text("No Active PCT")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(theme.text)
                
                Text("Post Cycle Therapy helps restore your natural hormone production after a cycle.")
                    .font(.system(size: 14))
                    .foregroundStyle(theme.textMuted)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                GlowButton(title: "Plan PCT", icon: "shield.fill", color: Color(hex: "0984E3")) {
                    showWizard = true
                }
                .padding(.top, 10)
            }
            .padding(.vertical, 20)
        }
    }
    
    private func activeState(_ pct: PCTProtocol) -> some View {
        VStack(spacing: 20) {
            // Status Header
            GlassCard {
                VStack(spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(pct.name)
                                .font(.system(size: 20, weight: .bold))
                                .foregroundStyle(theme.text)
                            Text("Week \(pct.currentWeek) of \(pct.durationWeeks)")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(Color(hex: "0984E3"))
                        }
                        Spacer()
                        Image(systemName: "shield.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(Color(hex: "0984E3"))
                    }
                    
                    // Progress Bar
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.white.opacity(0.1))
                                .frame(height: 12)
                            
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color(hex: "0984E3"))
                                .frame(width: max(0, min(geo.size.width, geo.size.width * CGFloat(pct.currentWeek) / CGFloat(pct.durationWeeks))), height: 12)
                                .shadow(color: Color(hex: "0984E3").opacity(0.5), radius: 6)
                        }
                    }
                    .frame(height: 12)
                    
                    HStack {
                        Text("Started \(pct.startDate, style: .date)")
                            .font(.system(size: 12))
                            .foregroundStyle(theme.textMuted)
                        Spacer()
                        Text("Ends \(pct.endDate, style: .date)")
                            .font(.system(size: 12))
                            .foregroundStyle(theme.textMuted)
                    }
                }
            }
            
            // Medication Protocol
            VStack(alignment: .leading, spacing: 16) {
                Text("This Week's Protocol")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(theme.text)
                
                ForEach(pct.medications) { med in
                    let weekIdx = min(max(0, pct.currentWeek - 1), med.protocolWeeks.count - 1)
                    let dosage = med.protocolWeeks[weekIdx]
                    
                    GlassCard(padding: 16) {
                        HStack {
                            Image(systemName: "pills.fill")
                                .font(.system(size: 18))
                                .foregroundStyle(Color(hex: "0984E3"))
                            
                            Text(med.name)
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(theme.text)
                            
                            Spacer()
                            
                            Text(dosage)
                                .font(.system(size: 16, weight: .bold, design: .monospaced))
                                .foregroundStyle(theme.text)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background { Capsule().fill(Color.white.opacity(0.1)) }
                        }
                    }
                }
            }
            
            Button {
                withAnimation {
                    store.endActivePCT()
                }
            } label: {
                Text("End PCT Early")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(theme.error)
                    .padding(.vertical, 12)
            }
            .padding(.top, 20)
        }
    }
}

// MARK: - Progress Photo Vault

struct ProgressPhotoVaultView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.isDarkMode) private var isDarkMode
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var showImagePicker = false
    @State private var fullScreenImageName: String? = nil
    
    private var theme: LiquidGlassTheme { isDarkMode ? .dark : .light }
    
    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    if store.photoLogs.isEmpty {
                        emptyState
                    } else {
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(store.photoLogs.sorted(by: { $0.date > $1.date })) { log in
                                photoThumbnail(log)
                            }
                        }
                        .padding(20)
                    }
                }
            }
            .background(theme.background.ignoresSafeArea())
            .navigationTitle("Progress Vault")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(theme.textMuted)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(Color(hex: "6C5CE7"))
                    }
                }
            }
            .onChange(of: selectedItem) { newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        saveImage(image)
                    }
                }
            }
            .fullScreenCover(item: Binding(
                get: { fullScreenImageName.map { FullScreenPhotoItem(fileName: $0) } },
                set: { fullScreenImageName = $0?.fileName }
            )) { item in
                FullScreenPhotoView(fileName: item.fileName)
            }
        }
    }
    
    private var emptyState: some View {
        GlassCard {
            VStack(spacing: 16) {
                Image(systemName: "camera.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(Color(hex: "6C5CE7"))
                
                Text("No Progress Photos")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(theme.text)
                
                Text("Securely save your physique updates to track muscle growth and fat loss alongside your cycles.")
                    .font(.system(size: 14))
                    .foregroundStyle(theme.textMuted)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                PhotosPicker(selection: $selectedItem, matching: .images) {
                    HStack {
                        Image(systemName: "plus")
                        Text("Add Photo")
                    }
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background {
                        Capsule().fill(Color(hex: "6C5CE7"))
                            .shadow(color: Color(hex: "6C5CE7").opacity(0.4), radius: 8)
                    }
                }
                .padding(.top, 10)
            }
            .padding(.vertical, 20)
        }
        .padding(20)
    }
    
    private func photoThumbnail(_ log: PhotoLog) -> some View {
        Button {
            fullScreenImageName = log.fileName
        } label: {
            ZStack(alignment: .bottomLeading) {
                if let uiImage = loadImage(fileName: log.fileName) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .aspectRatio(1, contentMode: .fill)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.1))
                        .aspectRatio(1, contentMode: .fit)
                        .overlay(Image(systemName: "photo").foregroundStyle(theme.textMuted))
                }
                
                // Date badge
                Text(log.date.formatted(date: .numeric, time: .omitted))
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 4)
                    .background(Color.black.opacity(0.6))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .padding(6)
            }
            .shadow(color: Color.black.opacity(0.1), radius: 4, y: 2)
        }
        .buttonStyle(.plain)
    }
    
    private func saveImage(_ image: UIImage) {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return }
        let fileName = UUID().uuidString + ".jpg"
        let url = getDocumentsDirectory().appendingPathComponent(fileName)
        
        do {
            try data.write(to: url)
            let log = PhotoLog(fileName: fileName, weight: store.profile.weight)
            DispatchQueue.main.async {
                store.photoLogs.append(log)
                Haptics.notification(.success)
            }
        } catch {
            print("Error saving image: \(error)")
        }
    }
    
    private func loadImage(fileName: String) -> UIImage? {
        let url = getDocumentsDirectory().appendingPathComponent(fileName)
        if let data = try? Data(contentsOf: url) {
            return UIImage(data: data)
        }
        return nil
    }
    
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}

struct FullScreenPhotoItem: Identifiable {
    let id = UUID()
    let fileName: String
}

struct FullScreenPhotoView: View {
    let fileName: String
    @Environment(\.dismiss) private var dismiss
    
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.black.ignoresSafeArea()
            
            if let uiImage = loadImage(fileName: fileName) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(scale)
                    .gesture(
                        MagnificationGesture()
                            .onChanged { val in scale = val }
                            .onEnded { _ in withAnimation { scale = 1.0 } }
                    )
            }
            
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 30))
                    .foregroundStyle(.white.opacity(0.7))
                    .padding()
            }
        }
    }
    
    private func loadImage(fileName: String) -> UIImage? {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(fileName)
        if let data = try? Data(contentsOf: url) {
            return UIImage(data: data)
        }
        return nil
    }
}
