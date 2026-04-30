import SwiftUI

struct HomeView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.isDarkMode) private var isDarkMode
    
    private var theme: LiquidGlassTheme { isDarkMode ? .dark : .light }
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Header
                    headerSection
                    
                    // Profile card
                    profileCard
                    
                    // Stats row
                    statsRow
                    
                    // Active Cycle
                    activeCycleCard
                    
                    // Goal Cards
                    goalCardsSection
                    
                    // Featured Peptides
                    featuredPeptidesSection
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 100)
            }
            .background(theme.background.ignoresSafeArea())
        }
    }
    
    // MARK: - Header
    
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Welcome back")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(theme.textMuted)
                Text("Pepmax")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(theme.text)
                    .overlay {
                        LinearGradient(
                            colors: [theme.primary, theme.primarySoft],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .mask(
                            Text("Pepmax")
                                .font(.system(size: 32, weight: .bold))
                        )
                    }
            }
            Spacer()
            // Profile avatar
            ZStack {
                Circle()
                    .fill(theme.primaryGlow)
                    .frame(width: 48, height: 48)
                Image(systemName: store.profile.gender.icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(theme.primary)
            }
        }
        .padding(.top, 8)
    }
    
    // MARK: - Profile Card
    
    private var profileCard: some View {
        GlassCard {
            VStack(spacing: 14) {
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [theme.primary, theme.primarySoft],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 56, height: 56)
                        Image(systemName: store.profile.gender.icon)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Profile")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(theme.text)
                        Text("\(store.profile.gender.rawValue) • \(store.profile.age) yrs")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(theme.textMuted)
                    }
                    
                    Spacer()
                    
                    // Gender Toggle
                    HStack(spacing: 0) {
                        genderButton(.male)
                        genderButton(.female)
                    }
                    .padding(3)
                    .background {
                        Capsule()
                            .fill(isDarkMode ? Color.white.opacity(0.06) : Color.black.opacity(0.04))
                    }
                }
                
                // Body metrics row
                HStack(spacing: 10) {
                    metricPill(label: "Weight", value: "\(Int(store.profile.weight)) kg", icon: "scalemass.fill")
                    metricPill(label: "Height", value: "\(Int(store.profile.height)) cm", icon: "ruler.fill")
                    metricPill(label: "BMI", value: String(format: "%.1f", store.profile.bmi), icon: "heart.text.square.fill", color: Color(hex: store.profile.bmiColor))
                }
            }
        }
    }
    
    private func metricPill(label: String, value: String, icon: String, color: Color? = nil) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(color ?? theme.textMuted)
            Text(value)
                .font(.system(size: 13, weight: .bold, design: .monospaced))
                .foregroundStyle(color ?? theme.text)
            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(theme.textMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white.opacity(isDarkMode ? 0.04 : 0.3))
        }
    }
    
    private func genderButton(_ gender: UserProfile.Gender) -> some View {
        Button {
            withAnimation(.spring(response: 0.35)) {
                store.profile.gender = gender
            }
        } label: {
            Image(systemName: gender.icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(store.profile.gender == gender ? .white : theme.textMuted)
                .frame(width: 36, height: 32)
                .background {
                    if store.profile.gender == gender {
                        Capsule()
                            .fill(theme.primary)
                            .shadow(color: theme.primary.opacity(0.4), radius: 6)
                    }
                }
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Stats Row
    
    private var statsRow: some View {
        HStack(spacing: 12) {
            statCard(title: "Peptides", value: "\(store.peptides.count)", icon: "pills.fill", color: theme.primary)
            statCard(title: "Injections", value: "\(store.totalInjections)", icon: "syringe.fill", color: theme.success)
            statCard(title: "Categories", value: "\(store.uniqueCategories.count)", icon: "square.grid.2x2.fill", color: Color(hex: "6C5CE7"))
        }
    }
    
    private func statCard(title: String, value: String, icon: String, color: Color) -> some View {
        GlassCard(padding: 14) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(color)
                Text(value)
                    .font(.system(size: 22, weight: .bold, design: .monospaced))
                    .foregroundStyle(theme.text)
                Text(title)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(theme.textMuted)
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    // MARK: - Active Cycle
    
    private var activeCycleCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(theme.success)
                            .frame(width: 8, height: 8)
                        Text("Active Cycle")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(theme.text)
                    }
                    Spacer()
                    if let cycle = store.activeCycle {
                        Text("Day \(cycle.durationDays)")
                            .font(.system(size: 14, weight: .semibold, design: .monospaced))
                            .foregroundStyle(theme.success)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background {
                                Capsule().fill(theme.success.opacity(0.15))
                            }
                    }
                }
                
                if let cycle = store.activeCycle {
                    // Cycle progress bar
                    VStack(alignment: .leading, spacing: 6) {
                        Text(cycle.name)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(theme.textMuted)
                        
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.white.opacity(0.08))
                                    .frame(height: 6)
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(LinearGradient(colors: [theme.primary, theme.primarySoft], startPoint: .leading, endPoint: .trailing))
                                    .frame(width: min(geo.size.width, geo.size.width * min(Double(cycle.durationDays) / 90.0, 1.0)), height: 6)
                                    .shadow(color: theme.primary.opacity(0.5), radius: 4)
                            }
                        }
                        .frame(height: 6)
                        
                        HStack {
                            Text("\(cycle.totalInjections) injections logged")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(theme.textMuted)
                            Spacer()
                            Text("\(cycle.peptides.count) peptides")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(theme.primary)
                        }
                    }
                } else {
                    // No active cycle
                    VStack(spacing: 8) {
                        Text("No active cycle")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(theme.textMuted)
                        Text("Start a new cycle from the Tracker tab")
                            .font(.system(size: 12))
                            .foregroundStyle(theme.textMuted.opacity(0.7))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
            }
        }
    }
    
    // MARK: - Goal Cards
    
    private var goalCardsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Goals")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(theme.text)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    goalCard(title: "Fat Loss", icon: "flame.fill", color: Color(hex: "FF6B6B"), peptideCount: 8)
                    goalCard(title: "Muscle Growth", icon: "figure.strengthtraining.traditional", color: Color(hex: "6C5CE7"), peptideCount: 5)
                    goalCard(title: "Healing", icon: "bandage.fill", color: Color(hex: "0984E3"), peptideCount: 6)
                    goalCard(title: "Cognitive", icon: "brain.head.profile", color: Color(hex: "FDCB6E"), peptideCount: 4)
                    goalCard(title: "Anti-Aging", icon: "sparkles", color: Color(hex: "F8A5C2"), peptideCount: 3)
                }
            }
        }
    }
    
    private func goalCard(title: String, icon: String, color: Color, peptideCount: Int) -> some View {
        GlassCard(padding: 14) {
            VStack(alignment: .leading, spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(color.opacity(0.15))
                        .frame(width: 40, height: 40)
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(color)
                }
                Text(title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(theme.text)
                Text("\(peptideCount) peptides")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(theme.textMuted)
            }
            .frame(width: 110)
        }
    }
    
    // MARK: - Featured Peptides
    
    private var featuredPeptidesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Featured Peptides")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(theme.text)
                Spacer()
                Image(systemName: "sparkle")
                    .foregroundStyle(theme.primary)
            }
            
            ForEach(store.featuredPeptides) { peptide in
                NavigationLink(destination: PeptideDetailView(peptide: peptide)) {
                    featuredPeptideRow(peptide)
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    private func featuredPeptideRow(_ peptide: Peptide) -> some View {
        GlassCard(padding: 14) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(CategoryColors.color(for: peptide.category).opacity(0.15))
                        .frame(width: 44, height: 44)
                    Image(systemName: CategoryColors.icon(for: peptide.category))
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(CategoryColors.color(for: peptide.category))
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(peptide.name)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(theme.text)
                    Text(peptide.category)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(theme.textMuted)
                }
                
                Spacer()
                
                // Status badge
                Text(peptide.clinicalStatus)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(Color(hex: peptide.statusColor))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background {
                        Capsule().fill(Color(hex: peptide.statusColor).opacity(0.15))
                    }
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(theme.textMuted)
            }
        }
    }
}
