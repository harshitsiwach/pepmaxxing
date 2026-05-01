import SwiftUI

struct CompareView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.isDarkMode) private var isDarkMode
    @State private var selectedPeptides: [Peptide] = []
    @State private var selectedSteroids: [Steroid] = []
    @State private var showPicker = false
    @State private var mode: EncyclopediaView.CompoundMode = .peptides
    
    private var theme: LiquidGlassTheme { isDarkMode ? .dark : .light }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Compare")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(theme.text)
                        Text("Side-by-side compound comparison")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(theme.textMuted)
                    }
                    Spacer()
                }
                
                // Mode Picker
                Picker("Compound Type", selection: $mode) {
                    ForEach(EncyclopediaView.CompoundMode.allCases, id: \.self) { m in
                        Text(m.rawValue).tag(m)
                    }
                }
                .pickerStyle(.segmented)
                
                // Selected chips
                HStack(spacing: 10) {
                    ForEach(0..<3, id: \.self) { index in
                        if mode == .peptides {
                            if index < selectedPeptides.count {
                                selectedChip(selectedPeptides[index], index: index)
                            } else {
                                addSlot(index: index)
                            }
                        } else {
                            if index < selectedSteroids.count {
                                selectedSteroidChip(selectedSteroids[index], index: index)
                            } else {
                                addSlot(index: index)
                            }
                        }
                    }
                }
                
                // Comparison table
                if mode == .peptides && selectedPeptides.count >= 2 {
                    comparisonTable
                } else if mode == .steroids && selectedSteroids.count >= 2 {
                    comparisonSteroidTable
                } else {
                    emptyState
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 100)
        }
        .background(theme.background.ignoresSafeArea())
        .sheet(isPresented: $showPicker) {
            ComparePicker(mode: mode, selectedPeptides: $selectedPeptides, selectedSteroids: $selectedSteroids, maxSelection: 3)
                .environmentObject(store)
        }
    }
    
    // MARK: - Slots
    
    private func selectedChip(_ peptide: Peptide, index: Int) -> some View {
        let colors: [Color] = [theme.primary, Color(hex: "6C5CE7"), Color(hex: "00B894")]
        let color = colors[index % colors.count]
        
        return HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(peptide.name)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(theme.text)
                .lineLimit(1)
            Button {
                withAnimation(.spring(response: 0.3)) {
                    selectedPeptides.removeAll { $0.id == peptide.id }
                    Haptics.impact(.light)
                }
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(theme.textMuted)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background {
            Capsule()
                .fill(color.opacity(0.12))
                .overlay { Capsule().stroke(color.opacity(0.3), lineWidth: 1) }
        }
    }
    
    private func selectedSteroidChip(_ steroid: Steroid, index: Int) -> some View {
        let colors: [Color] = [Color(hex: "FF3B30"), Color(hex: "FF9500"), Color(hex: "FF2D55")]
        let color = colors[index % colors.count]
        
        return HStack(spacing: 6) {
            Circle().fill(color).frame(width: 8, height: 8)
            Text(steroid.name).font(.system(size: 12, weight: .semibold)).foregroundStyle(theme.text).lineLimit(1)
            Button {
                withAnimation(.spring(response: 0.3)) {
                    selectedSteroids.removeAll { $0.id == steroid.id }
                    Haptics.impact(.light)
                }
            } label: { Image(systemName: "xmark.circle.fill").font(.system(size: 12)).foregroundStyle(theme.textMuted) }
        }
        .padding(.horizontal, 12).padding(.vertical, 8)
        .background { Capsule().fill(color.opacity(0.12)).overlay { Capsule().stroke(color.opacity(0.3), lineWidth: 1) } }
    }
    
    private func addSlot(index: Int) -> some View {
        Button {
            showPicker = true
            Haptics.selection()
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "plus")
                    .font(.system(size: 12, weight: .semibold))
                Text(index == 0 ? "Add Peptide" : "Add")
                    .font(.system(size: 12, weight: .medium))
            }
            .foregroundStyle(theme.textMuted)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background {
                Capsule()
                    .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [4]))
                    .foregroundStyle(theme.glassBorder)
            }
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        GlassCard {
            VStack(spacing: 14) {
                Image(systemName: "square.stack.3d.up")
                    .font(.system(size: 32, weight: .light))
                    .foregroundStyle(theme.textMuted)
                Text(mode == .peptides ? "Select 2-3 Peptides" : "Select 2-3 Steroids")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(theme.text)
                Text("Compare dosage, routes, status, and mechanisms side by side")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(theme.textMuted)
                    .multilineTextAlignment(.center)
                GlowButton(title: mode == .peptides ? "Choose Peptides" : "Choose Steroids", icon: "plus.circle.fill", isSmall: true) {
                    showPicker = true
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
        }
    }
    
    // MARK: - Comparison Table
    
    private var comparisonTable: some View {
        let colors: [Color] = [theme.primary, Color(hex: "6C5CE7"), Color(hex: "00B894")]
        
        return VStack(spacing: 12) {
            comparisonRow(title: "Category", values: selectedPeptides.map { $0.category }, colors: colors)
            comparisonRow(title: "Status", values: selectedPeptides.map { $0.clinicalStatus }, colors: colors, statusColors: selectedPeptides.map { Color(hex: $0.statusColor) })
            comparisonRow(title: "Dosage", values: selectedPeptides.map { $0.dosageRange }, colors: colors)
            comparisonRow(title: "Route", values: selectedPeptides.map { $0.route }, colors: colors)
            comparisonRow(title: "Mechanism", values: selectedPeptides.map {
                $0.mechanism.components(separatedBy: ";").first?.trimmingCharacters(in: .whitespaces) ?? $0.mechanism
            }, colors: colors)
            comparisonRow(title: "Gender Notes", values: selectedPeptides.map {
                String($0.genderNotes.prefix(80)) + ($0.genderNotes.count > 80 ? "..." : "")
            }, colors: colors)
            comparisonRow(title: "References", values: selectedPeptides.map { $0.references }, colors: colors)
        }
    }
    
    private var comparisonSteroidTable: some View {
        let colors: [Color] = [Color(hex: "FF3B30"), Color(hex: "FF9500"), Color(hex: "FF2D55")]
        return VStack(spacing: 12) {
            comparisonRow(title: "Class", values: selectedSteroids.map { $0.steroidClass }, colors: colors)
            comparisonRow(title: "Status", values: selectedSteroids.map { $0.clinicalStatus }, colors: colors, statusColors: selectedSteroids.map { Color(hex: $0.statusColor) })
            comparisonRow(title: "Dosage (Men)", values: selectedSteroids.map { $0.dosageMen }, colors: colors)
            comparisonRow(title: "Dosage (Women)", values: selectedSteroids.map { $0.dosageWomen }, colors: colors)
            comparisonRow(title: "Route", values: selectedSteroids.map { $0.route }, colors: colors)
            comparisonRow(title: "Mechanism", values: selectedSteroids.map {
                $0.mechanism.components(separatedBy: ";").first?.trimmingCharacters(in: .whitespaces) ?? $0.mechanism
            }, colors: colors)
            comparisonRow(title: "Adverse Effects", values: selectedSteroids.map { String($0.adverseEffects.prefix(80)) + ($0.adverseEffects.count > 80 ? "..." : "") }, colors: colors)
            comparisonRow(title: "References", values: selectedSteroids.map { $0.references }, colors: colors)
        }
    }
    
    private func comparisonRow(title: String, values: [String], colors: [Color], statusColors: [Color]? = nil) -> some View {
        GlassCard(padding: 14) {
            VStack(alignment: .leading, spacing: 10) {
                Text(title)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(theme.textMuted)
                
                ForEach(Array(values.enumerated()), id: \.offset) { index, value in
                    HStack(alignment: .top, spacing: 8) {
                        Circle()
                            .fill(colors[index % colors.count])
                            .frame(width: 6, height: 6)
                            .padding(.top, 5)
                        
                        Text(value)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(statusColors?[index] ?? theme.text)
                            .lineSpacing(2)
                    }
                    
                    if index < values.count - 1 {
                        Divider().foregroundStyle(theme.border.opacity(0.5))
                    }
                }
            }
        }
    }
}

// MARK: - Compare Picker

struct ComparePicker: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.isDarkMode) private var isDarkMode
    @Environment(\.dismiss) private var dismiss
    let mode: EncyclopediaView.CompoundMode
    @Binding var selectedPeptides: [Peptide]
    @Binding var selectedSteroids: [Steroid]
    let maxSelection: Int
    @State private var searchText = ""
    
    private var theme: LiquidGlassTheme { isDarkMode ? .dark : .light }
    
    private var filteredPeptides: [Peptide] {
        if searchText.isEmpty { return store.peptides }
        return store.peptides.filter { $0.name.localizedCaseInsensitiveContains(searchText) || $0.category.localizedCaseInsensitiveContains(searchText) }
    }
    
    private var filteredSteroids: [Steroid] {
        if searchText.isEmpty { return store.steroids }
        return store.steroids.filter { $0.name.localizedCaseInsensitiveContains(searchText) || $0.steroidClass.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 12) {
                    GlassSearchBar(text: $searchText, placeholder: mode == .peptides ? "Search peptides..." : "Search steroids...")
                        .padding(.horizontal, 20)
                    
                    let count = mode == .peptides ? selectedPeptides.count : selectedSteroids.count
                    Text("\(count)/\(maxSelection) selected")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(theme.primary)
                        .padding(.horizontal, 20)
                    
                    LazyVStack(spacing: 6) {
                        if mode == .peptides {
                            ForEach(filteredPeptides) { peptide in
                                let isSelected = selectedPeptides.contains(where: { $0.id == peptide.id })
                                Button {
                                    withAnimation(.spring(response: 0.3)) {
                                        if isSelected { selectedPeptides.removeAll { $0.id == peptide.id } }
                                        else if selectedPeptides.count < maxSelection { selectedPeptides.append(peptide) }
                                        Haptics.selection()
                                    }
                                } label: { pickerRow(name: peptide.name, category: peptide.category, status: peptide.clinicalStatus, color: peptide.statusColor, isSelected: isSelected, isFull: selectedPeptides.count >= maxSelection) }
                                .buttonStyle(.plain)
                                .disabled(!isSelected && selectedPeptides.count >= maxSelection)
                                .opacity(!isSelected && selectedPeptides.count >= maxSelection ? 0.4 : 1)
                            }
                        } else {
                            ForEach(filteredSteroids) { steroid in
                                let isSelected = selectedSteroids.contains(where: { $0.id == steroid.id })
                                Button {
                                    withAnimation(.spring(response: 0.3)) {
                                        if isSelected { selectedSteroids.removeAll { $0.id == steroid.id } }
                                        else if selectedSteroids.count < maxSelection { selectedSteroids.append(steroid) }
                                        Haptics.selection()
                                    }
                                } label: { pickerRow(name: steroid.name, category: steroid.steroidClass, status: steroid.clinicalStatus, color: steroid.statusColor, isSelected: isSelected, isFull: selectedSteroids.count >= maxSelection) }
                                .buttonStyle(.plain)
                                .disabled(!isSelected && selectedSteroids.count >= maxSelection)
                                .opacity(!isSelected && selectedSteroids.count >= maxSelection ? 0.4 : 1)
                            }
                        }
                    }
                }
                .padding(.bottom, 40)
            }
            .background(theme.background.ignoresSafeArea())
            .navigationTitle(mode == .peptides ? "Select Peptides" : "Select Steroids")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(theme.textMuted)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(theme.primary)
                        .fontWeight(.bold)
                }
            }
        }
        .presentationDetents([.large])
    }
    
    private func pickerRow(name: String, category: String, status: String, color: String, isSelected: Bool, isFull: Bool) -> some View {
        HStack(spacing: 12) {
            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 20))
                .foregroundStyle(isSelected ? theme.primary : theme.textMuted)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(name).font(.system(size: 15, weight: .semibold)).foregroundStyle(theme.text)
                Text(category).font(.system(size: 12, weight: .medium)).foregroundStyle(theme.textMuted)
            }
            Spacer()
            
            Text(status)
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(Color(hex: color))
                .padding(.horizontal, 6).padding(.vertical, 2)
                .background { Capsule().fill(Color(hex: color).opacity(0.12)) }
        }
        .padding(.horizontal, 20).padding(.vertical, 10)
        .background { RoundedRectangle(cornerRadius: 10).fill(isSelected ? theme.primary.opacity(0.06) : .clear) }
    }
}
