import SwiftUI

struct SteroidDetailView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.isDarkMode) private var isDarkMode
    @Environment(\.dismiss) private var dismiss
    let steroid: Steroid
    
    private var theme: LiquidGlassTheme { isDarkMode ? .dark : .light }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                heroHeader
                quickInfoRow
                
                if hasSmartInsights {
                    smartInsightsSection
                }
                
                effectsSection
                dosageSection
                pharmacokineticsSection
                adverseEffectsSection
                monitoringSection
                genderSection
                routeSection
                referencesSection
                actionsSection
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 100)
        }
        .background(theme.background.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .onAppear { store.markViewed(steroid) }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(theme.textMuted)
                        .frame(width: 36, height: 36)
                        .background { Circle().fill(theme.textMuted.opacity(0.1)) }
                }
            }
            ToolbarItem(placement: .principal) {
                Text(steroid.name)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(theme.text)
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    withAnimation(.spring(response: 0.3)) { store.toggleFavorite(steroid) }
                } label: {
                    Image(systemName: store.isFavorite(steroid) ? "heart.fill" : "heart")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(store.isFavorite(steroid) ? theme.primary : theme.textMuted)
                        .scaleEffect(store.isFavorite(steroid) ? 1.15 : 1.0)
                }
            }
        }
    }
    
    private var heroHeader: some View {
        GlassCard(padding: 20) {
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(RadialGradient(colors: [Color(hex: "FF3B30").opacity(0.3), .clear], center: .center, startRadius: 0, endRadius: 50))
                        .frame(width: 80, height: 80)
                    Circle().fill(Color(hex: "FF3B30").opacity(0.15)).frame(width: 64, height: 64)
                    Image(systemName: "figure.strengthtraining.traditional")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(Color(hex: "FF3B30"))
                }
                
                Text(steroid.name)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(theme.text)
                    .multilineTextAlignment(.center)
                
                Text(steroid.steroidClass)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color(hex: "FF3B30"))
                    .padding(.horizontal, 14).padding(.vertical, 6)
                    .background { Capsule().fill(Color(hex: "FF3B30").opacity(0.12)) }
                
                HStack(spacing: 6) {
                    Circle().fill(Color(hex: steroid.statusColor)).frame(width: 8, height: 8)
                    Text(steroid.clinicalStatus)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color(hex: steroid.statusColor))
                }
                .padding(.horizontal, 12).padding(.vertical, 6)
                .background {
                    Capsule().fill(Color(hex: steroid.statusColor).opacity(0.1))
                        .overlay { Capsule().stroke(Color(hex: steroid.statusColor).opacity(0.2), lineWidth: 1) }
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    private var quickInfoRow: some View {
        HStack(spacing: 12) {
            infoChip(title: "Route", value: steroid.route, icon: "syringe.fill")
            infoChip(title: "Status", value: steroid.isFDAApproved ? "Approved" : "Research", icon: steroid.isFDAApproved ? "checkmark.shield.fill" : "flask.fill")
        }
    }
    
    private func infoChip(title: String, value: String, icon: String) -> some View {
        GlassCard(padding: 12) {
            VStack(spacing: 6) {
                Image(systemName: icon).font(.system(size: 16, weight: .semibold)).foregroundStyle(theme.primary)
                Text(title).font(.system(size: 11, weight: .medium)).foregroundStyle(theme.textMuted)
                Text(value).font(.system(size: 12, weight: .bold)).foregroundStyle(theme.text).multilineTextAlignment(.center).lineLimit(2)
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    private var hasSmartInsights: Bool { !smartInsights.isEmpty }
    
    private var smartInsights: [(icon: String, title: String, message: String, color: Color)] {
        var insights: [(String, String, String, Color)] = []
        if steroid.isInvestigational {
            insights.append(("flask.fill", "Investigational Use", "This compound is largely investigational and lacks long-term human safety data.", theme.warning))
        }
        if store.profile.gender == .female && steroid.genderNotes.lowercased().contains("women") {
            insights.append(("person.2.fill", "Gender Note", "Contains specific contraindications or dosing adjustments for females.", Color(hex: "E056A0")))
        }
        return insights
    }
    
    private var smartInsightsSection: some View {
        VStack(spacing: 12) {
            ForEach(smartInsights.indices, id: \.self) { index in
                let insight = smartInsights[index]
                GlassCard {
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: insight.icon).font(.system(size: 18, weight: .bold)).foregroundStyle(insight.color).padding(.top, 2)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(insight.title).font(.system(size: 14, weight: .bold)).foregroundStyle(insight.color)
                            Text(insight.message).font(.system(size: 13, weight: .regular)).foregroundStyle(theme.textMuted).lineSpacing(2)
                        }
                        Spacer()
                    }
                }
                .overlay { RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(insight.color.opacity(0.3), lineWidth: 1) }
            }
        }
    }
    
    private var effectsSection: some View {
        detailSection(title: "Mechanism & Effects", icon: "waveform.path.ecg") {
            VStack(alignment: .leading, spacing: 8) {
                Text(steroid.mechanism).font(.system(size: 14, weight: .medium)).foregroundStyle(theme.text).padding(.bottom, 4)
                ForEach(steroid.primaryEffectsList, id: \.self) { effect in
                    HStack(alignment: .top, spacing: 10) {
                        Circle().fill(theme.primary).frame(width: 6, height: 6).padding(.top, 6)
                        Text(effect).font(.system(size: 14, weight: .regular)).foregroundStyle(theme.text)
                    }
                }
            }
        }
    }
    
    private var dosageSection: some View {
        detailSection(title: "Typical Dosage", icon: "scalemass.fill") {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top) {
                    Text("Men:").font(.system(size: 14, weight: .bold)).foregroundStyle(theme.text).frame(width: 60, alignment: .leading)
                    Text(steroid.dosageMen).font(.system(size: 14, weight: .regular, design: .monospaced)).foregroundStyle(theme.success)
                }
                HStack(alignment: .top) {
                    Text("Women:").font(.system(size: 14, weight: .bold)).foregroundStyle(theme.text).frame(width: 60, alignment: .leading)
                    Text(steroid.dosageWomen).font(.system(size: 14, weight: .regular, design: .monospaced)).foregroundStyle(theme.success)
                }
            }
        }
    }
    
    private var pharmacokineticsSection: some View {
        detailSection(title: "Pharmacokinetics", icon: "clock.fill") {
            Text(steroid.pharmacokinetics).font(.system(size: 14, weight: .regular)).foregroundStyle(theme.text.opacity(0.8)).lineSpacing(4)
        }
    }
    
    private var adverseEffectsSection: some View {
        detailSection(title: "Key Adverse Effects", icon: "exclamationmark.triangle.fill") {
            Text(steroid.adverseEffects).font(.system(size: 14, weight: .regular)).foregroundStyle(theme.error).lineSpacing(4)
        }
    }
    
    private var monitoringSection: some View {
        detailSection(title: "Monitoring Parameters", icon: "eye.fill") {
            Text(steroid.monitoringParameters).font(.system(size: 14, weight: .regular)).foregroundStyle(theme.text.opacity(0.8)).lineSpacing(4)
        }
    }
    
    private var genderSection: some View {
        detailSection(title: "Gender-Specific Notes", icon: "person.2.fill") {
            Text(steroid.genderNotes).font(.system(size: 14, weight: .regular)).foregroundStyle(theme.text.opacity(0.8)).lineSpacing(4)
        }
    }
    
    private var routeSection: some View {
        detailSection(title: "Administration Routes", icon: "arrow.right.circle.fill") {
            FlowLayout(spacing: 8) {
                ForEach(steroid.routes, id: \.self) { route in
                    GlassPill(text: route, color: Color(hex: "6C5CE7"), isSelected: false)
                }
            }
        }
    }
    
    private var referencesSection: some View {
        detailSection(title: "Key References", icon: "book.fill") {
            Text(steroid.references).font(.system(size: 13, weight: .regular)).foregroundStyle(theme.textMuted).lineSpacing(3)
        }
    }
    
    private var actionsSection: some View {
        VStack(spacing: 12) {
            GlowButton(title: "Add to Tracker", icon: "plus.circle.fill", color: theme.primary) {
                // Add to tracker logic
            }
        }
        .padding(.top, 8)
    }
    
    private func detailSection<Content: View>(title: String, icon: String, @ViewBuilder content: () -> Content) -> some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: icon).font(.system(size: 14, weight: .semibold)).foregroundStyle(theme.primary)
                    Text(title).font(.system(size: 16, weight: .bold)).foregroundStyle(theme.text)
                }
                content()
            }
        }
    }
}
