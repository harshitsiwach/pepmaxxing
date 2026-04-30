import SwiftUI

struct CalculatorView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.isDarkMode) private var isDarkMode
    @State private var selectedPeptide: Peptide?
    @State private var bodyWeight: String = ""
    @State private var showPeptidePicker = false
    
    private var theme: LiquidGlassTheme { isDarkMode ? .dark : .light }
    
    private var calculatedDosage: String {
        guard let peptide = selectedPeptide else { return "—" }
        guard let weight = Double(bodyWeight), weight > 0 else { return peptide.dosageRange }
        
        // Simple dose calculation based on weight category
        let range = peptide.dosageRange
        let isFemale = store.profile.gender == .female
        let modifier = isFemale ? 0.8 : 1.0
        
        // Extract numeric values from dosage range
        let numbers = range.components(separatedBy: CharacterSet.decimalDigits.inverted)
            .compactMap { Double($0) }
            .filter { $0 > 0 }
        
        if let low = numbers.first, let high = numbers.count > 1 ? numbers[1] : nil {
            let adjusted_low = low * modifier
            let adjusted_high = high * modifier
            return String(format: "%.1f – %.1f", adjusted_low, adjusted_high)
        }
        
        return range
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
                    
                    // Select Peptide
                    GlassCard {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 8) {
                                Image(systemName: "pills.fill")
                                    .foregroundStyle(theme.primary)
                                Text("Select Peptide")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundStyle(theme.text)
                            }
                            
                            Button {
                                showPeptidePicker = true
                            } label: {
                                HStack {
                                    Text(selectedPeptide?.name ?? "Tap to select...")
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundStyle(selectedPeptide != nil ? theme.text : theme.textMuted)
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
                    if selectedPeptide != nil {
                        resultCard
                    }
                    
                    // Info about selected peptide
                    if let peptide = selectedPeptide {
                        peptideInfoCard(peptide)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 100)
            }
            .background(theme.background.ignoresSafeArea())
            .sheet(isPresented: $showPeptidePicker) {
                peptidePickerSheet
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
                
                if let peptide = selectedPeptide {
                    Text("Original range: \(peptide.dosageRange)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(theme.textMuted)
                    
                    if store.profile.gender == .female {
                        HStack(spacing: 4) {
                            Image(systemName: "info.circle.fill")
                                .font(.system(size: 11))
                            Text("Adjusted 20% lower for female dosing")
                                .font(.system(size: 11, weight: .medium))
                        }
                        .foregroundStyle(theme.warning)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background { Capsule().fill(theme.warning.opacity(0.12)) }
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    // MARK: - Peptide Info
    
    private func peptideInfoCard(_ peptide: Peptide) -> some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    Image(systemName: "info.circle.fill")
                        .foregroundStyle(theme.primary)
                    Text("Gender Notes")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(theme.text)
                }
                Text(peptide.genderNotes)
                    .font(.system(size: 13))
                    .foregroundStyle(theme.textMuted)
                    .lineSpacing(3)
            }
        }
    }
    
    // MARK: - Peptide Picker
    
    private var peptidePickerSheet: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 6) {
                    ForEach(store.peptides) { peptide in
                        Button {
                            selectedPeptide = peptide
                            showPeptidePicker = false
                        } label: {
                            HStack {
                                Text(peptide.name)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundStyle(theme.text)
                                Spacer()
                                Text(peptide.dosageRange)
                                    .font(.system(size: 11, design: .monospaced))
                                    .foregroundStyle(theme.textMuted)
                                    .lineLimit(1)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                        }
                        .buttonStyle(.plain)
                        Divider().foregroundStyle(theme.border)
                    }
                }
                .padding(.vertical, 8)
            }
            .background(theme.background.ignoresSafeArea())
            .navigationTitle("Select Peptide")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { showPeptidePicker = false }
                        .foregroundStyle(theme.textMuted)
                }
            }
        }
        .presentationDetents([.large])
    }
}
