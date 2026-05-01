import SwiftUI
import Charts

struct TrackerView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.isDarkMode) private var isDarkMode
    @State private var showNewCycleSheet = false
    @State private var showLogSheet = false
    @State private var showAnalyticsSheet = false
    @State private var showBloodworkSheet = false
    
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
                            showBloodworkSheet = true
                        } label: {
                            Image(systemName: "drop.fill")
                                .font(.system(size: 20))
                                .foregroundStyle(Color(hex: "FF2D55"))
                                .frame(width: 44, height: 44)
                                .background { Circle().fill(Color(hex: "FF2D55").opacity(0.12)) }
                        }
                        .buttonStyle(.plain)
                        
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
            .sheet(isPresented: $showBloodworkSheet) {
                BloodworkView()
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
