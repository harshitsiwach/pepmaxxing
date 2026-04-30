import SwiftUI

struct CompareView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.isDarkMode) private var isDarkMode
    @State private var selectedPeptides: [Peptide] = []
    @State private var showPicker = false
    
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
                        Text("Side-by-side peptide comparison")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(theme.textMuted)
                    }
                    Spacer()
                }
                
                // Selected peptides chips
                HStack(spacing: 10) {
                    ForEach(0..<3, id: \.self) { index in
                        if index < selectedPeptides.count {
                            selectedChip(selectedPeptides[index], index: index)
                        } else {
                            addSlot(index: index)
                        }
                    }
                }
                
                // Comparison table
                if selectedPeptides.count >= 2 {
                    comparisonTable
                } else {
                    emptyState
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 100)
        }
        .background(theme.background.ignoresSafeArea())
        .sheet(isPresented: $showPicker) {
            ComparePicker(selectedPeptides: $selectedPeptides, maxSelection: 3)
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
                Text("Select 2-3 Peptides")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(theme.text)
                Text("Compare dosage, routes, status, and mechanisms side by side")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(theme.textMuted)
                    .multilineTextAlignment(.center)
                GlowButton(title: "Choose Peptides", icon: "plus.circle.fill", isSmall: true) {
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
    @Binding var selectedPeptides: [Peptide]
    let maxSelection: Int
    @State private var searchText = ""
    
    private var theme: LiquidGlassTheme { isDarkMode ? .dark : .light }
    
    private var filteredPeptides: [Peptide] {
        if searchText.isEmpty { return store.peptides }
        return store.peptides.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.category.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 12) {
                    GlassSearchBar(text: $searchText, placeholder: "Search peptides...")
                        .padding(.horizontal, 20)
                    
                    Text("\(selectedPeptides.count)/\(maxSelection) selected")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(theme.primary)
                        .padding(.horizontal, 20)
                    
                    LazyVStack(spacing: 6) {
                        ForEach(filteredPeptides) { peptide in
                            let isSelected = selectedPeptides.contains(where: { $0.id == peptide.id })
                            Button {
                                withAnimation(.spring(response: 0.3)) {
                                    if isSelected {
                                        selectedPeptides.removeAll { $0.id == peptide.id }
                                    } else if selectedPeptides.count < maxSelection {
                                        selectedPeptides.append(peptide)
                                    }
                                    Haptics.selection()
                                }
                            } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                                        .font(.system(size: 20))
                                        .foregroundStyle(isSelected ? theme.primary : theme.textMuted)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(peptide.name)
                                            .font(.system(size: 15, weight: .semibold))
                                            .foregroundStyle(theme.text)
                                        Text(peptide.category)
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundStyle(theme.textMuted)
                                    }
                                    
                                    Spacer()
                                    
                                    Text(peptide.clinicalStatus)
                                        .font(.system(size: 10, weight: .semibold))
                                        .foregroundStyle(Color(hex: peptide.statusColor))
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background { Capsule().fill(Color(hex: peptide.statusColor).opacity(0.12)) }
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(isSelected ? theme.primary.opacity(0.06) : .clear)
                                }
                            }
                            .buttonStyle(.plain)
                            .disabled(!isSelected && selectedPeptides.count >= maxSelection)
                            .opacity(!isSelected && selectedPeptides.count >= maxSelection ? 0.4 : 1)
                        }
                    }
                }
                .padding(.bottom, 40)
            }
            .background(theme.background.ignoresSafeArea())
            .navigationTitle("Select Peptides")
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
}
