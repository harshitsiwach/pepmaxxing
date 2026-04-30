import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.isDarkMode) private var isDarkMode
    
    private var theme: LiquidGlassTheme { isDarkMode ? .dark : .light }
    
    let countries = ["United States", "United Kingdom", "Canada", "Australia", "Germany", "India", "Japan", "Brazil", "Other"]
    
    @State private var showShareSheet = false
    @State private var exportURL: URL?
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {

                VStack(spacing: 20) {
                    // Header
                    HStack {
                        Text("Settings")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(theme.text)
                        Spacer()
                    }
                    
                    // Appearance & Security
                    GlassCard {
                        VStack(alignment: .leading, spacing: 16) {
                            sectionHeader(title: "Appearance", icon: "paintbrush.fill")
                            
                            HStack {
                                HStack(spacing: 10) {
                                    Image(systemName: store.profile.isDarkMode ? "moon.fill" : "sun.max.fill")
                                        .font(.system(size: 18))
                                        .foregroundStyle(store.profile.isDarkMode ? Color(hex: "6C5CE7") : Color(hex: "FFB800"))
                                    Text(store.profile.isDarkMode ? "Dark Mode" : "Light Mode")
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundStyle(theme.text)
                                }
                                Spacer()
                                Toggle("", isOn: $store.profile.isDarkMode)
                                    .tint(theme.primary)
                                    .labelsHidden()
                            }
                            
                            Divider().foregroundStyle(theme.border)
                            
                            HStack {
                                HStack(spacing: 10) {
                                    Image(systemName: "faceid")
                                        .font(.system(size: 18))
                                        .foregroundStyle(Color(hex: "00B894"))
                                    Text("App Lock")
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundStyle(theme.text)
                                }
                                Spacer()
                                Toggle("", isOn: $store.profile.isAppLockEnabled)
                                    .tint(theme.primary)
                                    .labelsHidden()
                            }
                        }
                    }
                    
                    // Profile
                    GlassCard {
                        VStack(alignment: .leading, spacing: 16) {
                            sectionHeader(title: "Profile", icon: "person.fill")
                            
                            // Gender
                            HStack {
                                Text("Gender")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundStyle(theme.text)
                                Spacer()
                                HStack(spacing: 0) {
                                    ForEach(UserProfile.Gender.allCases, id: \.self) { g in
                                        Button {
                                            withAnimation { store.profile.gender = g }
                                        } label: {
                                            HStack(spacing: 4) {
                                                Image(systemName: g.icon)
                                                    .font(.system(size: 12))
                                                Text(g.rawValue)
                                                    .font(.system(size: 13, weight: .medium))
                                            }
                                            .foregroundStyle(store.profile.gender == g ? .white : theme.textMuted)
                                            .padding(.horizontal, 14)
                                            .padding(.vertical, 8)
                                            .background {
                                                if store.profile.gender == g {
                                                    Capsule().fill(theme.primary)
                                                }
                                            }
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                .padding(3)
                                .background { Capsule().fill(isDarkMode ? Color.white.opacity(0.06) : Color.black.opacity(0.04)) }
                            }
                            
                            Divider().foregroundStyle(theme.border)
                            
                            // Age
                            HStack {
                                Text("Age")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundStyle(theme.text)
                                Spacer()
                                HStack(spacing: 4) {
                                    TextField("30", value: $store.profile.age, format: .number)
                                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                                        .foregroundStyle(theme.text)
                                        .multilineTextAlignment(.trailing)
                                        .keyboardType(.numberPad)
                                        .frame(width: 50)
                                    Text("yrs")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundStyle(theme.textMuted)
                                }
                            }
                            
                            Divider().foregroundStyle(theme.border)
                            
                            // Height
                            HStack {
                                Text("Height")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundStyle(theme.text)
                                Spacer()
                                HStack(spacing: 4) {
                                    TextField("175", value: $store.profile.height, format: .number)
                                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                                        .foregroundStyle(theme.text)
                                        .multilineTextAlignment(.trailing)
                                        .keyboardType(.decimalPad)
                                        .frame(width: 60)
                                    Text("cm")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundStyle(theme.textMuted)
                                }
                            }
                            
                            Divider().foregroundStyle(theme.border)
                            
                            // Weight
                            HStack {
                                Text("Weight")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundStyle(theme.text)
                                Spacer()
                                HStack(spacing: 4) {
                                    TextField("75", value: $store.profile.weight, format: .number)
                                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                                        .foregroundStyle(theme.text)
                                        .multilineTextAlignment(.trailing)
                                        .keyboardType(.decimalPad)
                                        .frame(width: 60)
                                    Text("kg")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundStyle(theme.textMuted)
                                }
                            }
                            
                            Divider().foregroundStyle(theme.border)
                            
                            // BMI (read-only)
                            HStack {
                                Text("BMI")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundStyle(theme.text)
                                Spacer()
                                HStack(spacing: 6) {
                                    Text(String(format: "%.1f", store.profile.bmi))
                                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                                        .foregroundStyle(Color(hex: store.profile.bmiColor))
                                    Text(store.profile.bmiCategory)
                                        .font(.system(size: 11, weight: .semibold))
                                        .foregroundStyle(Color(hex: store.profile.bmiColor))
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 3)
                                        .background { Capsule().fill(Color(hex: store.profile.bmiColor).opacity(0.12)) }
                                }
                            }
                            
                            Divider().foregroundStyle(theme.border)
                            
                            // Activity Level
                            HStack {
                                Text("Activity")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundStyle(theme.text)
                                Spacer()
                                Picker("", selection: $store.profile.activityLevel) {
                                    ForEach(UserProfile.ActivityLevel.allCases, id: \.self) { a in
                                        Text(a.rawValue).tag(a)
                                    }
                                }
                                .tint(theme.primary)
                            }
                            
                            Divider().foregroundStyle(theme.border)
                            
                            // Country
                            HStack {
                                Text("Country")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundStyle(theme.text)
                                Spacer()
                                Picker("", selection: $store.profile.country) {
                                    ForEach(countries, id: \.self) { c in
                                        Text(c).tag(c)
                                    }
                                }
                                .tint(theme.primary)
                            }
                        }
                    }
                    
                    // Units
                    GlassCard {
                        VStack(alignment: .leading, spacing: 16) {
                            sectionHeader(title: "Units", icon: "ruler.fill")
                            
                            HStack {
                                Text("Measurement System")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundStyle(theme.text)
                                Spacer()
                                Picker("", selection: $store.profile.unitSystem) {
                                    ForEach(UserProfile.UnitSystem.allCases, id: \.self) { u in
                                        Text(u.rawValue).tag(u)
                                    }
                                }
                                .pickerStyle(.segmented)
                                .frame(width: 160)
                            }
                        }
                    }
                    
                    // Data & Backup
                    GlassCard {
                        VStack(alignment: .leading, spacing: 16) {
                            sectionHeader(title: "Data & Backup", icon: "externaldrive.fill")
                            
                            Button {
                                exportData()
                            } label: {
                                HStack {
                                    Text("Export Injection Logs")
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundStyle(theme.text)
                                    Spacer()
                                    HStack(spacing: 6) {
                                        Text("CSV")
                                            .font(.system(size: 12, weight: .semibold))
                                            .foregroundStyle(theme.textMuted)
                                        Image(systemName: "square.and.arrow.up")
                                            .font(.system(size: 14))
                                            .foregroundStyle(theme.primary)
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    
                    // About
                    GlassCard {
                        VStack(alignment: .leading, spacing: 16) {
                            sectionHeader(title: "About", icon: "info.circle.fill")
                            
                            aboutRow(title: "Version", value: "1.0.0")
                            Divider().foregroundStyle(theme.border)
                            aboutRow(title: "Peptides", value: "\(store.peptides.count)")
                            Divider().foregroundStyle(theme.border)
                            aboutRow(title: "Categories", value: "\(store.uniqueCategories.count)")
                        }
                    }
                    
                    // Disclaimer
                    GlassCard {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 6) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundStyle(theme.warning)
                                Text("Disclaimer")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(theme.warning)
                            }
                            Text("This app is for educational and informational purposes only. It is not medical advice. Always consult a qualified healthcare professional before using any peptides or medications.")
                                .font(.system(size: 12, weight: .regular))
                                .foregroundStyle(theme.textMuted)
                                .lineSpacing(3)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 100)
            }
            .background(theme.background.ignoresSafeArea())
            .sheet(isPresented: $showShareSheet) {
                if let url = exportURL {
                    ShareSheet(items: [url])
                }
            }
        }
    }
    
    private func sectionHeader(title: String, icon: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(theme.primary)
            Text(title)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(theme.text)
        }
    }
    
    private func aboutRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(theme.text)
            Spacer()
            Text(value)
                .font(.system(size: 14, weight: .semibold, design: .monospaced))
                .foregroundStyle(theme.textMuted)
        }
    }
    
    private func exportData() {
        if let url = DataExporter.shared.exportLogsToCSV(cycles: store.cycles) {
            exportURL = url
            showShareSheet = true
            Haptics.notification(.success)
        } else {
            Haptics.notification(.error)
        }
    }
}

// MARK: - Share Sheet Wrapper

struct ShareSheet: UIViewControllerRepresentable {
    var items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
