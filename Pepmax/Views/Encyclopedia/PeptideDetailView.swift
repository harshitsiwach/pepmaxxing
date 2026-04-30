import SwiftUI

struct PeptideDetailView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.isDarkMode) private var isDarkMode
    @Environment(\.dismiss) private var dismiss
    let peptide: Peptide
    
    private var theme: LiquidGlassTheme { isDarkMode ? .dark : .light }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                // Hero header
                heroHeader
                
                // Quick info row
                quickInfoRow
                
                // Smart Insights
                if hasSmartInsights {
                    smartInsightsSection
                }
                
                // Mechanism / Effects
                mechanismSection
                
                // Dosage
                dosageSection
                
                // Gender Notes
                genderSection
                
                // Routes
                routeSection
                
                // References
                referencesSection
                
                // Actions
                actionsSection
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 100)
        }
        .background(theme.background.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { store.markViewed(peptide) }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(peptide.name)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(theme.text)
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        store.toggleFavorite(peptide)
                    }
                } label: {
                    Image(systemName: store.isFavorite(peptide) ? "heart.fill" : "heart")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(store.isFavorite(peptide) ? theme.primary : theme.textMuted)
                        .scaleEffect(store.isFavorite(peptide) ? 1.15 : 1.0)
                }
            }
        }
    }
    
    // MARK: - Hero Header
    
    private var heroHeader: some View {
        GlassCard(padding: 20) {
            VStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [CategoryColors.color(for: peptide.category).opacity(0.3), .clear],
                                center: .center,
                                startRadius: 0,
                                endRadius: 50
                            )
                        )
                        .frame(width: 80, height: 80)
                    
                    Circle()
                        .fill(CategoryColors.color(for: peptide.category).opacity(0.15))
                        .frame(width: 64, height: 64)
                    
                    Image(systemName: CategoryColors.icon(for: peptide.category))
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(CategoryColors.color(for: peptide.category))
                }
                
                Text(peptide.name)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(theme.text)
                    .multilineTextAlignment(.center)
                
                Text(peptide.category)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(CategoryColors.color(for: peptide.category))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background {
                        Capsule().fill(CategoryColors.color(for: peptide.category).opacity(0.12))
                    }
                
                // Status badge
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color(hex: peptide.statusColor))
                        .frame(width: 8, height: 8)
                    Text(peptide.clinicalStatus)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color(hex: peptide.statusColor))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background {
                    Capsule().fill(Color(hex: peptide.statusColor).opacity(0.1))
                        .overlay {
                            Capsule().stroke(Color(hex: peptide.statusColor).opacity(0.2), lineWidth: 1)
                        }
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    // MARK: - Quick Info Row
    
    private var quickInfoRow: some View {
        HStack(spacing: 12) {
            infoChip(title: "Route", value: peptide.route, icon: "syringe.fill")
            infoChip(title: "Status", value: peptide.isFDAApproved ? "Approved" : "Research", icon: peptide.isFDAApproved ? "checkmark.shield.fill" : "flask.fill")
        }
    }
    
    private func infoChip(title: String, value: String, icon: String) -> some View {
        GlassCard(padding: 12) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(theme.primary)
                Text(title)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(theme.textMuted)
                Text(value)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(theme.text)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    // MARK: - Smart Insights
    
    private var hasSmartInsights: Bool {
        return !smartInsights.isEmpty
    }
    
    private var smartInsights: [(icon: String, title: String, message: String, color: Color)] {
        var insights: [(String, String, String, Color)] = []
        
        // Investigational Warning
        if peptide.isInvestigational {
            insights.append(("flask.fill", "Investigational Use", "This peptide is largely investigational and lacks long-term human safety data.", theme.warning))
        }
        
        // Gender specific
        if store.profile.gender == .female && peptide.genderNotes.lowercased().contains("women") {
            insights.append(("person.2.fill", "Gender Note", "Contains specific contraindications or dosing adjustments for females.", Color(hex: "E056A0")))
        }
        
        // BMI warning
        if store.profile.bmi < 18.5 && peptide.category.lowercased().contains("weight loss") {
            insights.append(("exclamationmark.triangle.fill", "Low BMI Alert", "Your BMI is underweight. Use of weight loss peptides is strongly discouraged.", theme.error))
        }
        
        return insights
    }
    
    private var smartInsightsSection: some View {
        VStack(spacing: 12) {
            ForEach(smartInsights.indices, id: \.self) { index in
                let insight = smartInsights[index]
                GlassCard {
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: insight.icon)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(insight.color)
                            .padding(.top, 2)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(insight.title)
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(insight.color)
                            Text(insight.message)
                                .font(.system(size: 13, weight: .regular))
                                .foregroundStyle(theme.textMuted)
                                .lineSpacing(2)
                        }
                        Spacer()
                    }
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(insight.color.opacity(0.3), lineWidth: 1)
                }
            }
        }
    }
    
    // MARK: - Mechanism
    
    private var mechanismSection: some View {
        detailSection(title: "Mechanism & Effects", icon: "waveform.path.ecg") {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(peptide.primaryEffects, id: \.self) { effect in
                    HStack(alignment: .top, spacing: 10) {
                        Circle()
                            .fill(theme.primary)
                            .frame(width: 6, height: 6)
                            .padding(.top, 6)
                        Text(effect)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundStyle(theme.text)
                    }
                }
            }
        }
    }
    
    // MARK: - Dosage
    
    private var dosageSection: some View {
        detailSection(title: "Dosage Range", icon: "scalemass.fill") {
            HStack {
                Text(peptide.dosageRange)
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                    .foregroundStyle(theme.success)
                Spacer()
            }
        }
    }
    
    // MARK: - Gender
    
    private var genderSection: some View {
        detailSection(title: "Gender-Specific Notes", icon: "person.2.fill") {
            Text(peptide.genderNotes)
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(theme.text.opacity(0.8))
                .lineSpacing(4)
        }
    }
    
    // MARK: - Route
    
    private var routeSection: some View {
        detailSection(title: "Administration Routes", icon: "arrow.right.circle.fill") {
            FlowLayout(spacing: 8) {
                ForEach(peptide.routes, id: \.self) { route in
                    GlassPill(text: route, color: Color(hex: "6C5CE7"), isSelected: false)
                }
            }
        }
    }
    
    // MARK: - References
    
    private var referencesSection: some View {
        detailSection(title: "Key References", icon: "book.fill") {
            Text(peptide.references)
                .font(.system(size: 13, weight: .regular))
                .foregroundStyle(theme.textMuted)
                .lineSpacing(3)
        }
    }
    
    // MARK: - Actions
    
    private var actionsSection: some View {
        VStack(spacing: 12) {
            GlowButton(title: "Add to Tracker", icon: "plus.circle.fill", color: theme.primary) {
                // Will add to tracker
            }
        }
        .padding(.top, 8)
    }
    
    // MARK: - Helper
    
    private func detailSection<Content: View>(title: String, icon: String, @ViewBuilder content: () -> Content) -> some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(theme.primary)
                    Text(title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(theme.text)
                }
                content()
            }
        }
    }
}

// MARK: - Flow Layout

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, subview) in subviews.enumerated() {
            let point = CGPoint(x: bounds.minX + result.positions[index].x, y: bounds.minY + result.positions[index].y)
            subview.place(at: point, anchor: .topLeading, proposal: .unspecified)
        }
    }
    
    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (positions: [CGPoint], size: CGSize) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth && x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
        }
        
        return (positions, CGSize(width: maxWidth, height: y + rowHeight))
    }
}
