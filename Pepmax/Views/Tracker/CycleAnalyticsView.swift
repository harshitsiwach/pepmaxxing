import SwiftUI

struct CycleAnalyticsView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.isDarkMode) private var isDarkMode
    @Environment(\.dismiss) private var dismiss
    
    private var theme: LiquidGlassTheme { isDarkMode ? .dark : .light }
    
    // Calendar math
    private let calendar = Calendar.current
    private let today = Date()
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Overall Stats
                    overallStatsSection
                    
                    // Heatmap
                    heatmapSection
                    
                    // Top Compounds Chart
                    topCompoundsSection
                    
                    // Body Metrics (if we had historic data we'd graph it, but we'll show current BMI impact)
                    bodyMetricsSection
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
                .padding(.bottom, 40)
            }
            .background(theme.background.ignoresSafeArea())
            .navigationTitle("Analytics")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .fontWeight(.bold)
                        .foregroundStyle(theme.primary)
                }
            }
        }
    }
    
    // MARK: - Overall Stats
    
    private var overallStatsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Lifetime Statistics")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(theme.text)
            
            HStack(spacing: 12) {
                statCard(title: "Total Injections", value: "\(store.totalInjections)", icon: "syringe.fill", color: theme.primary)
                statCard(title: "Cycles Completed", value: "\(store.cycles.filter { !$0.isActive }.count)", icon: "arrow.triangle.2.circlepath", color: theme.success)
                statCard(title: "Compounds Used", value: "\(Set(store.cycles.flatMap { $0.peptides }).count)", icon: "flask.fill", color: Color(hex: "6C5CE7"))
            }
        }
    }
    
    private func statCard(title: String, value: String, icon: String, color: Color) -> some View {
        GlassCard(padding: 12) {
            VStack(alignment: .leading, spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundStyle(color)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(value)
                        .font(.system(size: 24, weight: .bold, design: .monospaced))
                        .foregroundStyle(theme.text)
                    Text(title)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(theme.textMuted)
                        .lineLimit(2)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    // MARK: - Heatmap
    
    private var heatmapSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Injection History (Last 30 Days)")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(theme.text)
            
            GlassCard {
                VStack(alignment: .leading, spacing: 16) {
                    // Generate last 30 days
                    let days = (0..<30).reversed().map { calendar.date(byAdding: .day, value: -$0, to: today)! }
                    let chunks = stride(from: 0, to: days.count, by: 7).map {
                        Array(days[$0..<min($0 + 7, days.count)])
                    }
                    
                    HStack(spacing: 8) {
                        ForEach(0..<chunks.count, id: \.self) { colIndex in
                            VStack(spacing: 8) {
                                ForEach(chunks[colIndex], id: \.self) { date in
                                    let count = countInjections(for: date)
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(heatmapColor(for: count))
                                        .frame(width: 32, height: 32)
                                        .overlay {
                                            if count > 0 {
                                                Text("\(count)")
                                                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                                                    .foregroundStyle(.white)
                                            }
                                        }
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    
                    HStack {
                        Text("Less")
                            .font(.system(size: 11))
                            .foregroundStyle(theme.textMuted)
                        HStack(spacing: 4) {
                            ForEach(0...3, id: \.self) { i in
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(heatmapColor(for: i))
                                    .frame(width: 12, height: 12)
                            }
                        }
                        Text("More")
                            .font(.system(size: 11))
                            .foregroundStyle(theme.textMuted)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
    }
    
    private func countInjections(for date: Date) -> Int {
        var count = 0
        for cycle in store.cycles {
            count += cycle.logs.filter { calendar.isDate($0.date, inSameDayAs: date) }.count
        }
        return count
    }
    
    private func heatmapColor(for count: Int) -> Color {
        if count == 0 { return Color.white.opacity(isDarkMode ? 0.05 : 0.2) }
        let base = theme.primary
        switch count {
        case 1: return base.opacity(0.4)
        case 2: return base.opacity(0.7)
        default: return base
        }
    }
    
    // MARK: - Top Compounds
    
    private var topCompoundsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Most Used Compounds")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(theme.text)
            
            let counts = compoundUsageCounts()
            if counts.isEmpty {
                GlassCard {
                    Text("Not enough data yet")
                        .font(.system(size: 14))
                        .foregroundStyle(theme.textMuted)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                }
            } else {
                GlassCard {
                    VStack(spacing: 12) {
                        ForEach(Array(counts.prefix(5).enumerated()), id: \.element.key) { index, element in
                            let (name, count) = element
                            HStack {
                                Text("\(index + 1).")
                                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                                    .foregroundStyle(theme.textMuted)
                                    .frame(width: 20, alignment: .leading)
                                
                                Text(name)
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundStyle(theme.text)
                                
                                Spacer()
                                
                                Text("\(count) uses")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundStyle(theme.primary)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background { Capsule().fill(theme.primary.opacity(0.12)) }
                            }
                            
                            if index < min(counts.count, 5) - 1 {
                                Divider().foregroundStyle(theme.border)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func compoundUsageCounts() -> [(key: String, value: Int)] {
        var counts: [String: Int] = [:]
        for cycle in store.cycles {
            for log in cycle.logs {
                counts[log.peptideName, default: 0] += 1
            }
        }
        return counts.sorted { $0.value > $1.value }
    }
    
    // MARK: - Body Metrics
    
    private var bodyMetricsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Current Metrics")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(theme.text)
            
            GlassCard {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("BMI Profile")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(theme.textMuted)
                        HStack(alignment: .firstTextBaseline, spacing: 8) {
                            Text(String(format: "%.1f", store.profile.bmi))
                                .font(.system(size: 28, weight: .bold, design: .monospaced))
                                .foregroundStyle(Color(hex: store.profile.bmiColor))
                            Text(store.profile.bmiCategory)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(Color(hex: store.profile.bmiColor))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background { Capsule().fill(Color(hex: store.profile.bmiColor).opacity(0.12)) }
                        }
                    }
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Weight")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(theme.textMuted)
                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text(String(format: "%.1f", store.profile.weight))
                                .font(.system(size: 24, weight: .bold, design: .monospaced))
                                .foregroundStyle(theme.text)
                            Text("kg")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(theme.textMuted)
                        }
                    }
                }
            }
        }
    }
}
