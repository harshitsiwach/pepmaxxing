import SwiftUI

struct HomeView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.isDarkMode) private var isDarkMode
    @Binding var selectedTab: Int
    @State private var showSettings = false
    
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
                    
                    // Daily Tip
                    dailyTipCard
                    
                    // Active Cycle
                    activeCycleCard
                    
                    // My Favorites
                    if !store.favoritePeptides.isEmpty || !store.favoriteSteroids.isEmpty {
                        favoritesSection
                    }
                    
                    // Recently Viewed
                    if !store.recentlyViewedPeptides.isEmpty || !store.recentlyViewedSteroids.isEmpty {
                        recentlyViewedSection
                    }
                    
                    // Goal Cards
                    goalCardsSection
                    
                    // Featured Compounds
                    featuredCompoundsSection
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 100)
            }
            .background(theme.background.ignoresSafeArea())
            .sheet(isPresented: $showSettings) {
                SettingsView()
                    .environmentObject(store)
                    .environment(\.isDarkMode, isDarkMode)
            }
        }
    }
    
    // MARK: - Header
    
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Welcome back")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(theme.textMuted)
                Text("Pepmax")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(theme.text)
                    .overlay {
                        LinearGradient(
                            colors: [theme.primary, theme.primarySoft],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .mask(
                            Text("Pepmax")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                        )
                    }
            }
            Spacer()
            // Profile avatar -> Settings
            Button {
                showSettings = true
            } label: {
                ZStack {
                    Circle()
                        .fill(theme.primaryGlow)
                        .frame(width: 48, height: 48)
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundStyle(theme.primary)
                }
            }
            .buttonStyle(.plain)
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
            Button { selectedTab = 3 } label: {
                statCard(title: "Peptides", value: "\(store.peptides.count)", icon: "pills.fill", color: theme.primary)
            }.buttonStyle(.plain)
            
            Button { selectedTab = 3 } label: {
                statCard(title: "Steroids", value: "\(store.steroids.count)", icon: "figure.strengthtraining.traditional", color: Color(hex: "FF3B30"))
            }.buttonStyle(.plain)
            
            Button { selectedTab = 1 } label: {
                statCard(title: "Injections", value: "\(store.totalInjections)", icon: "syringe.fill", color: theme.success)
            }.buttonStyle(.plain)
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
    
    // MARK: - Daily Tip
    
    private var dailyTipCard: some View {
        let tip = DailyTips.todaysTip
        let tipColor = Color(hex: tip.color)
        
        return Button {
            Haptics.notification(.success)
        } label: {
            GlassCard(padding: 14) {
                HStack(spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(tipColor.opacity(0.12))
                            .frame(width: 44, height: 44)
                        Image(systemName: tip.icon)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(tipColor)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 6) {
                            Text("💡")
                                .font(.system(size: 10))
                            Text("Daily Tip")
                                .font(.system(size: 11, weight: .semibold, design: .rounded))
                                .foregroundStyle(tipColor)
                        }
                        Text(tip.title)
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundStyle(theme.text)
                        Text(tip.body)
                            .font(.system(size: 12, weight: .regular, design: .rounded))
                            .foregroundStyle(theme.textMuted)
                            .lineSpacing(2)
                            .lineLimit(3)
                    }
                }
            }
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Active Cycle
    
    private var activeCycleCard: some View {
        Button {
            selectedTab = 1
        } label: {
            GlassCard {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        HStack(spacing: 6) {
                            Circle()
                                .fill(theme.success)
                                .frame(width: 8, height: 8)
                            Text("Active Cycle")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
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
                                .font(.system(size: 14, weight: .medium, design: .rounded))
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
                                    .font(.system(size: 12, weight: .medium, design: .rounded))
                                    .foregroundStyle(theme.textMuted)
                                Spacer()
                                Text("\(cycle.peptides.count) peptides")
                                    .font(.system(size: 12, weight: .bold, design: .rounded))
                                    .foregroundStyle(theme.primary)
                            }
                        }
                    } else {
                        // No active cycle
                        VStack(spacing: 8) {
                            Text("No active cycle")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundStyle(theme.textMuted)
                            Text("Start a new cycle from the Tracker tab")
                                .font(.system(size: 12, design: .rounded))
                                .foregroundStyle(theme.textMuted.opacity(0.7))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                    }
                }
            }
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Goal Cards
    
    private var goalCardsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Goals")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(theme.text)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    goalCard(title: "Fat Loss", icon: "flame.fill", color: Color(hex: "FF6B6B"), compoundCount: 15)
                    goalCard(title: "Muscle Growth", icon: "figure.strengthtraining.traditional", color: Color(hex: "6C5CE7"), compoundCount: 52)
                    goalCard(title: "TRT / HRT", icon: "arrow.triangle.2.circlepath", color: Color(hex: "00B894"), compoundCount: 18)
                    goalCard(title: "Healing", icon: "bandage.fill", color: Color(hex: "0984E3"), compoundCount: 12)
                    goalCard(title: "Cognitive", icon: "brain.head.profile", color: Color(hex: "FDCB6E"), compoundCount: 4)
                    goalCard(title: "Anti-Aging", icon: "sparkles", color: Color(hex: "F8A5C2"), compoundCount: 6)
                }
            }
        }
    }
    
    private func goalCard(title: String, icon: String, color: Color, compoundCount: Int) -> some View {
        Button {
            selectedTab = 3
        } label: {
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
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(theme.text)
                    Text("\(compoundCount) compounds")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(theme.textMuted)
                }
                .frame(width: 110)
            }
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - My Favorites
    
    private var favoritesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "heart.fill")
                        .foregroundStyle(theme.primary)
                    Text("My Favorites")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(theme.text)
                }
                Spacer()
                Text("\(store.favoritePeptides.count)")
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundStyle(theme.primary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background { Capsule().fill(theme.primary.opacity(0.12)) }
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(store.favoritePeptides) { peptide in
                        NavigationLink(destination: PeptideDetailView(peptide: peptide)) {
                            favoriteCard(peptide)
                        }
                        .buttonStyle(.plain)
                    }
                    ForEach(store.favoriteSteroids) { steroid in
                        NavigationLink(destination: SteroidDetailView(steroid: steroid)) {
                            favoriteSteroidCard(steroid)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
    
    private func favoriteCard(_ peptide: Peptide) -> some View {
        GlassCard(padding: 14) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(CategoryColors.color(for: peptide.category).opacity(0.15))
                            .frame(width: 36, height: 36)
                        Image(systemName: CategoryColors.icon(for: peptide.category))
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(CategoryColors.color(for: peptide.category))
                    }
                    Spacer()
                    Image(systemName: "heart.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(theme.primary)
                }
                
                Text(peptide.name)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(theme.text)
                    .lineLimit(1)
                
                Text(peptide.category)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(theme.textMuted)
                    .lineLimit(1)
            }
            .frame(width: 130)
        }
    }
    
    private func favoriteSteroidCard(_ steroid: Steroid) -> some View {
        GlassCard(padding: 14) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(Color(hex: "FF3B30").opacity(0.15))
                            .frame(width: 36, height: 36)
                        Image(systemName: "figure.strengthtraining.traditional")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Color(hex: "FF3B30"))
                    }
                    Spacer()
                    Image(systemName: "heart.fill").font(.system(size: 12)).foregroundStyle(theme.primary)
                }
                
                Text(steroid.name).font(.system(size: 14, weight: .bold)).foregroundStyle(theme.text).lineLimit(1)
                Text(steroid.steroidClass).font(.system(size: 11, weight: .medium)).foregroundStyle(theme.textMuted).lineLimit(1)
            }
            .frame(width: 130)
        }
    }
    
    // MARK: - Recently Viewed
    
    private var recentlyViewedSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "clock.arrow.circlepath")
                        .foregroundStyle(Color(hex: "6C5CE7"))
                    Text("Recently Viewed")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(theme.text)
                }
                Spacer()
            }
            
            ForEach(store.recentlyViewedPeptides.prefix(3)) { peptide in
                NavigationLink(destination: PeptideDetailView(peptide: peptide)) {
                    recentRow(peptide)
                }
                .buttonStyle(.plain)
            }
            ForEach(store.recentlyViewedSteroids.prefix(3)) { steroid in
                NavigationLink(destination: SteroidDetailView(steroid: steroid)) {
                    recentSteroidRow(steroid)
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    private func recentRow(_ peptide: Peptide) -> some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(CategoryColors.color(for: peptide.category).opacity(0.12))
                    .frame(width: 38, height: 38)
                Image(systemName: CategoryColors.icon(for: peptide.category))
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(CategoryColors.color(for: peptide.category))
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(peptide.name)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(theme.text)
                    .lineLimit(1)
                Text(peptide.category)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(theme.textMuted)
            }
            
            Spacer()
            
            if store.isFavorite(peptide) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 11))
                    .foregroundStyle(theme.primary)
            }
            
            Image(systemName: "chevron.right")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(theme.textMuted.opacity(0.5))
        }
        .padding(.vertical, 6)
    }
    
    private func recentSteroidRow(_ steroid: Steroid) -> some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous).fill(Color(hex: "FF3B30").opacity(0.12)).frame(width: 38, height: 38)
                Image(systemName: "figure.strengthtraining.traditional").font(.system(size: 15, weight: .semibold)).foregroundStyle(Color(hex: "FF3B30"))
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(steroid.name).font(.system(size: 14, weight: .semibold)).foregroundStyle(theme.text).lineLimit(1)
                Text(steroid.steroidClass).font(.system(size: 11, weight: .medium)).foregroundStyle(theme.textMuted)
            }
            Spacer()
            
            if store.isFavorite(steroid) {
                Image(systemName: "heart.fill").font(.system(size: 11)).foregroundStyle(theme.primary)
            }
            Image(systemName: "chevron.right").font(.system(size: 11, weight: .semibold)).foregroundStyle(theme.textMuted.opacity(0.5))
        }
        .padding(.vertical, 6)
    }
    
    // MARK: - Featured Compounds
    
    private var featuredCompoundsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Featured Compounds")
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
            
            ForEach(store.featuredSteroids) { steroid in
                NavigationLink(destination: SteroidDetailView(steroid: steroid)) {
                    featuredSteroidRow(steroid)
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
    
    private func featuredSteroidRow(_ steroid: Steroid) -> some View {
        GlassCard(padding: 14) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Color(hex: "FF3B30").opacity(0.15)).frame(width: 44, height: 44)
                    Image(systemName: "figure.strengthtraining.traditional").font(.system(size: 18, weight: .semibold)).foregroundStyle(Color(hex: "FF3B30"))
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(steroid.name).font(.system(size: 15, weight: .bold)).foregroundStyle(theme.text)
                    Text(steroid.steroidClass).font(.system(size: 12, weight: .medium)).foregroundStyle(theme.textMuted)
                }
                Spacer()
                
                Text(steroid.clinicalStatus)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(Color(hex: steroid.statusColor))
                    .padding(.horizontal, 8).padding(.vertical, 4)
                    .background { Capsule().fill(Color(hex: steroid.statusColor).opacity(0.15)) }
                
                Image(systemName: "chevron.right").font(.system(size: 12, weight: .semibold)).foregroundStyle(theme.textMuted)
            }
        }
    }
}
