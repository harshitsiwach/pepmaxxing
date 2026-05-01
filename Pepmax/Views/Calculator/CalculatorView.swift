import SwiftUI

struct CalculatorView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.isDarkMode) private var isDarkMode
    @State private var selectedPeptide: Peptide?
    @State private var selectedSteroid: Steroid?
    @State private var showCompoundPicker = false
    @State private var mode: EncyclopediaView.CompoundMode = .peptides
    
    private var theme: LiquidGlassTheme { isDarkMode ? .dark : .light }
    
    @State private var bodyWeight: String = ""
    
    private var calculatedDosage: String {
        guard let weight = Double(bodyWeight), weight > 0 else {
            if mode == .peptides {
                return selectedPeptide?.dosageRange ?? "—"
            } else {
                return (store.profile.gender == .female ? selectedSteroid?.dosageWomen : selectedSteroid?.dosageMen) ?? "—"
            }
        }
        
        let isFemale = store.profile.gender == .female
        
        if mode == .peptides, let peptide = selectedPeptide {
            let range = peptide.dosageRange
            let modifier = isFemale ? 0.8 : 1.0
            let numbers = range.components(separatedBy: CharacterSet.decimalDigits.inverted).compactMap { Double($0) }.filter { $0 > 0 }
            if let low = numbers.first, let high = numbers.count > 1 ? numbers[1] : nil {
                return String(format: "%.1f – %.1f", low * modifier, high * modifier)
            }
            return range
        } else if mode == .steroids, let steroid = selectedSteroid {
            let range = isFemale ? steroid.dosageWomen : steroid.dosageMen
            let numbers = range.components(separatedBy: CharacterSet.decimalDigits.inverted).compactMap { Double($0) }.filter { $0 > 0 }
            if let low = numbers.first, let high = numbers.count > 1 ? numbers[1] : nil {
                // simple weight adjustment assuming average weight 75kg
                let ratio = weight / 75.0
                return String(format: "%.1f – %.1f", low * ratio, high * ratio)
            }
            return range
        }
        
        return "—"
    }
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Header
                    HStack {
                        Text("Calculator")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(theme.text)
                        Spacer()
                    }
                    
                    // Mode Picker
                    Picker("Compound Type", selection: $mode) {
                        ForEach(EncyclopediaView.CompoundMode.allCases, id: \.self) { m in
                            Text(m.rawValue).tag(m)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    // Select Compound
                    GlassCard {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 8) {
                                Image(systemName: "flask.fill")
                                    .foregroundStyle(theme.primary)
                                Text("Select Compound")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundStyle(theme.text)
                            }
                            
                            Button {
                                showCompoundPicker = true
                            } label: {
                                HStack {
                                    let name = mode == .peptides ? selectedPeptide?.name : selectedSteroid?.name
                                    Text(name ?? "Tap to select...")
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundStyle(name != nil ? theme.text : theme.textMuted)
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundStyle(theme.textMuted)
                                }
                                .padding(12)
                                .background {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(isDarkMode ? Color.white.opacity(0.05) : Color.black.opacity(0.03))
                                        .overlay {
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(theme.glassBorder, lineWidth: 1)
                                        }
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    
                    // Body Weight Input
                    GlassCard {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 8) {
                                Image(systemName: "scalemass.fill")
                                    .foregroundStyle(Color(hex: "6C5CE7"))
                                Text("Body Weight")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundStyle(theme.text)
                            }
                            
                            HStack {
                                TextField("Enter weight", text: $bodyWeight)
                                    .font(.system(size: 20, weight: .bold, design: .monospaced))
                                    .foregroundStyle(theme.text)
                                    .keyboardType(.decimalPad)
                                    .tint(theme.primary)
                                
                                Text(store.profile.unitSystem == .metric ? "kg" : "lbs")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(theme.textMuted)
                            }
                        }
                    }
                    
                    // Gender
                    GlassCard {
                        HStack {
                            HStack(spacing: 8) {
                                Image(systemName: "person.fill")
                                    .foregroundStyle(Color(hex: "E056A0"))
                                Text("Gender")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundStyle(theme.text)
                            }
                            
                            Spacer()
                            
                            HStack(spacing: 0) {
                                genderBtn(.male)
                                genderBtn(.female)
                            }
                            .padding(3)
                            .background { Capsule().fill(isDarkMode ? Color.white.opacity(0.06) : Color.black.opacity(0.04)) }
                        }
                    }
                    
                    // Result Card
                    if (mode == .peptides && selectedPeptide != nil) || (mode == .steroids && selectedSteroid != nil) {
                        resultCard
                    }
                    
                    // Info about selected compound
                    if mode == .peptides, let peptide = selectedPeptide {
                        compoundInfoCard(notes: peptide.genderNotes)
                    } else if mode == .steroids, let steroid = selectedSteroid {
                        compoundInfoCard(notes: steroid.genderNotes)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 100)
            }
            .background(theme.background.ignoresSafeArea())
            .sheet(isPresented: $showCompoundPicker) {
                compoundPickerSheet
            }
        }
    }
    
    private func genderBtn(_ gender: UserProfile.Gender) -> some View {
        Button {
            withAnimation { store.profile.gender = gender }
        } label: {
            Text(gender.rawValue)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(store.profile.gender == gender ? .white : theme.textMuted)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background {
                    if store.profile.gender == gender {
                        Capsule().fill(theme.primary)
                    }
                }
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Result Card
    
    private var resultCard: some View {
        GlassCard(padding: 20) {
            VStack(spacing: 16) {
                HStack(spacing: 8) {
                    Image(systemName: "function")
                        .foregroundStyle(theme.success)
                    Text("Calculated Dosage")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(theme.text)
                }
                
                Text(calculatedDosage)
                    .font(.system(size: 28, weight: .bold, design: .monospaced))
                    .foregroundStyle(theme.success)
                    .shadow(color: theme.success.opacity(0.3), radius: 8)
                
                if mode == .peptides, let peptide = selectedPeptide {
                    Text("Original range: \(peptide.dosageRange)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(theme.textMuted)
                    
                    if store.profile.gender == .female {
                        HStack(spacing: 4) {
                            Image(systemName: "info.circle.fill").font(.system(size: 11))
                            Text("Adjusted 20% lower for female dosing").font(.system(size: 11, weight: .medium))
                        }
                        .foregroundStyle(theme.warning)
                        .padding(.horizontal, 12).padding(.vertical, 6)
                        .background { Capsule().fill(theme.warning.opacity(0.12)) }
                    }
                } else if mode == .steroids, let steroid = selectedSteroid {
                    Text("Original range: \(store.profile.gender == .female ? steroid.dosageWomen : steroid.dosageMen)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(theme.textMuted)
                        
                    HStack(spacing: 4) {
                        Image(systemName: "info.circle.fill").font(.system(size: 11))
                        Text("Weight adjusted based on 75kg avg").font(.system(size: 11, weight: .medium))
                    }
                    .foregroundStyle(theme.primary)
                    .padding(.horizontal, 12).padding(.vertical, 6)
                    .background { Capsule().fill(theme.primary.opacity(0.12)) }
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    // MARK: - Compound Info
    
    private func compoundInfoCard(notes: String) -> some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    Image(systemName: "info.circle.fill")
                        .foregroundStyle(theme.primary)
                    Text("Gender Notes")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(theme.text)
                }
                Text(notes)
                    .font(.system(size: 13))
                    .foregroundStyle(theme.textMuted)
                    .lineSpacing(3)
            }
        }
    }
    
    // MARK: - Compound Picker
    
    private var compoundPickerSheet: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 6) {
                    if mode == .peptides {
                        ForEach(store.peptides) { peptide in
                            Button {
                                selectedPeptide = peptide
                                showCompoundPicker = false
                            } label: { pickerRow(name: peptide.name, detail: peptide.dosageRange) }
                            .buttonStyle(.plain)
                            Divider().foregroundStyle(theme.border)
                        }
                    } else {
                        ForEach(store.steroids) { steroid in
                            Button {
                                selectedSteroid = steroid
                                showCompoundPicker = false
                            } label: { pickerRow(name: steroid.name, detail: store.profile.gender == .female ? steroid.dosageWomen : steroid.dosageMen) }
                            .buttonStyle(.plain)
                            Divider().foregroundStyle(theme.border)
                        }
                    }
                }
                .padding(.vertical, 8)
            }
            .background(theme.background.ignoresSafeArea())
            .navigationTitle(mode == .peptides ? "Select Peptide" : "Select Steroid")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { showCompoundPicker = false }
                        .foregroundStyle(theme.textMuted)
                }
            }
        }
        .presentationDetents([.large])
    }
    
    private func pickerRow(name: String, detail: String) -> some View {
        HStack {
            Text(name)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(theme.text)
            Spacer()
            Text(detail)
                .font(.system(size: 11, design: .monospaced))
                .foregroundStyle(theme.textMuted)
                .lineLimit(1)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}
