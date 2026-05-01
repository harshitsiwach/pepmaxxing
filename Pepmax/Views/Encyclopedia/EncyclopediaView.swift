import SwiftUI

struct EncyclopediaView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.isDarkMode) private var isDarkMode
    @State private var searchText = ""
    @State private var selectedCategory = "All"
    @State private var showFavoritesOnly = false
    
    enum CompoundMode: String, CaseIterable {
        case peptides = "Peptides"
        case steroids = "Steroids"
    }
    @State private var mode: CompoundMode = .peptides
    
    private var theme: LiquidGlassTheme { isDarkMode ? .dark : .light }
    
    private var filteredPeptides: [Peptide] {
        var result = store.peptides
        if showFavoritesOnly { result = result.filter { store.isFavorite($0) } }
        if selectedCategory != "All" { result = result.filter { $0.category == selectedCategory } }
        if !searchText.isEmpty {
            result = result.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.category.localizedCaseInsensitiveContains(searchText) ||
                $0.mechanism.localizedCaseInsensitiveContains(searchText)
            }
        }
        return result
    }
    
    private var filteredSteroids: [Steroid] {
        var result = store.steroids
        if showFavoritesOnly { result = result.filter { store.isFavorite($0) } }
        if selectedCategory != "All" { result = result.filter { $0.steroidClass == selectedCategory } }
        if !searchText.isEmpty {
            result = result.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.steroidClass.localizedCaseInsensitiveContains(searchText) ||
                $0.mechanism.localizedCaseInsensitiveContains(searchText)
            }
        }
        return result
    }
    
    private var categories: [String] {
        if mode == .peptides {
            return ["All"] + store.uniqueCategories
        } else {
            return ["All"] + store.uniqueSteroidCategories
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    // Header
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Encyclopedia")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundStyle(theme.text)
                            Text(mode == .peptides ? "\(store.peptides.count) peptides" : "\(store.steroids.count) steroids")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(theme.textMuted)
                        }
                        Spacer()
                        
                        // Favorites toggle
                        Button {
                            withAnimation(.spring(response: 0.3)) {
                                showFavoritesOnly.toggle()
                                Haptics.selection()
                            }
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(showFavoritesOnly ? theme.primary.opacity(0.15) : Color.white.opacity(isDarkMode ? 0.06 : 0.5))
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                                            .stroke(showFavoritesOnly ? theme.primary.opacity(0.4) : theme.glassBorder, lineWidth: 1)
                                    }
                                    .frame(width: 44, height: 44)
                                Image(systemName: showFavoritesOnly ? "heart.fill" : "heart")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundStyle(showFavoritesOnly ? theme.primary : theme.textMuted)
                            }
                            .shadow(color: showFavoritesOnly ? theme.primary.opacity(0.2) : .clear, radius: 8)
                        }
                        .buttonStyle(.plain)
                    }
                    
                    // Search
                    GlassSearchBar(text: $searchText)
                    
                    // Mode Picker
                    Picker("Compound Type", selection: $mode) {
                        ForEach(CompoundMode.allCases, id: \.self) { m in
                            Text(m.rawValue).tag(m)
                        }
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: mode) { _ in
                        selectedCategory = "All"
                    }
                    
                    // Category filters
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(categories, id: \.self) { cat in
                                Button {
                                    withAnimation(.spring(response: 0.3)) {
                                        selectedCategory = cat
                                        Haptics.selection()
                                    }
                                } label: {
                                    GlassPill(text: cat, color: cat == "All" ? theme.primary : CategoryColors.color(for: cat), isSelected: selectedCategory == cat)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    
                    // Results count + favorites count
                    HStack {
                        let resultCount = mode == .peptides ? filteredPeptides.count : filteredSteroids.count
                        Text("\(resultCount) results")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(theme.textMuted)
                        Spacer()
                        
                        let favCount = mode == .peptides ? store.favoritePeptideNames.count : store.favoriteSteroidNames.count
                        if favCount > 0 {
                            HStack(spacing: 4) {
                                Image(systemName: "heart.fill")
                                    .font(.system(size: 10))
                                    .foregroundStyle(theme.primary)
                                Text("\(favCount)")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(theme.primary)
                            }
                        }
                    }
                    
                    // List
                    LazyVStack(spacing: 10) {
                        if mode == .peptides {
                            ForEach(filteredPeptides) { peptide in
                                NavigationLink(destination: PeptideDetailView(peptide: peptide)) {
                                    peptideRow(peptide)
                                }
                                .buttonStyle(.plain)
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button { store.toggleFavorite(peptide) } label: {
                                        Label(store.isFavorite(peptide) ? "Unfavorite" : "Favorite", systemImage: store.isFavorite(peptide) ? "heart.slash.fill" : "heart.fill")
                                    }
                                    .tint(theme.primary)
                                }
                                .contextMenu {
                                    Button { store.toggleFavorite(peptide) } label: {
                                        Label(store.isFavorite(peptide) ? "Remove from Favorites" : "Add to Favorites", systemImage: store.isFavorite(peptide) ? "heart.slash" : "heart")
                                    }
                                }
                            }
                        } else {
                            ForEach(filteredSteroids) { steroid in
                                NavigationLink(destination: SteroidDetailView(steroid: steroid)) {
                                    steroidRow(steroid)
                                }
                                .buttonStyle(.plain)
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button { store.toggleFavorite(steroid) } label: {
                                        Label(store.isFavorite(steroid) ? "Unfavorite" : "Favorite", systemImage: store.isFavorite(steroid) ? "heart.slash.fill" : "heart.fill")
                                    }
                                    .tint(theme.primary)
                                }
                                .contextMenu {
                                    Button { store.toggleFavorite(steroid) } label: {
                                        Label(store.isFavorite(steroid) ? "Remove from Favorites" : "Add to Favorites", systemImage: store.isFavorite(steroid) ? "heart.slash" : "heart")
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 100)
            }
            .background(theme.background.ignoresSafeArea())
        }
    }
    
    private func peptideRow(_ peptide: Peptide) -> some View {
        GlassCard(padding: 14) {
            HStack(spacing: 14) {
                // Category icon
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(CategoryColors.color(for: peptide.category).opacity(0.15))
                        .frame(width: 44, height: 44)
                    Image(systemName: CategoryColors.icon(for: peptide.category))
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(CategoryColors.color(for: peptide.category))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(peptide.name)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(theme.text)
                            .lineLimit(1)
                        if store.isFavorite(peptide) {
                            Image(systemName: "heart.fill").font(.system(size: 10)).foregroundStyle(theme.primary)
                        }
                    }
                    Text(peptide.mechanism.components(separatedBy: ";").first ?? peptide.mechanism)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(theme.textMuted)
                        .lineLimit(1)
                    HStack(spacing: 6) {
                        Text(peptide.category)
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(CategoryColors.color(for: peptide.category))
                            .padding(.horizontal, 6).padding(.vertical, 2)
                            .background { Capsule().fill(CategoryColors.color(for: peptide.category).opacity(0.12)) }
                        Text(peptide.clinicalStatus)
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(Color(hex: peptide.statusColor))
                            .padding(.horizontal, 6).padding(.vertical, 2)
                            .background { Capsule().fill(Color(hex: peptide.statusColor).opacity(0.12)) }
                    }
                }
                Spacer()
                Image(systemName: "chevron.right").font(.system(size: 12, weight: .semibold)).foregroundStyle(theme.textMuted)
            }
        }
    }
    
    private func steroidRow(_ steroid: Steroid) -> some View {
        GlassCard(padding: 14) {
            HStack(spacing: 14) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color(hex: "FF3B30").opacity(0.15))
                        .frame(width: 44, height: 44)
                    Image(systemName: "figure.strengthtraining.traditional")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color(hex: "FF3B30"))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(steroid.name)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(theme.text)
                            .lineLimit(1)
                        if store.isFavorite(steroid) {
                            Image(systemName: "heart.fill").font(.system(size: 10)).foregroundStyle(theme.primary)
                        }
                    }
                    Text(steroid.mechanism.components(separatedBy: ";").first ?? steroid.mechanism)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(theme.textMuted)
                        .lineLimit(1)
                    HStack(spacing: 6) {
                        Text(steroid.steroidClass)
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(Color(hex: "FF3B30"))
                            .padding(.horizontal, 6).padding(.vertical, 2)
                            .background { Capsule().fill(Color(hex: "FF3B30").opacity(0.12)) }
                        Text(steroid.clinicalStatus)
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(Color(hex: steroid.statusColor))
                            .padding(.horizontal, 6).padding(.vertical, 2)
                            .background { Capsule().fill(Color(hex: steroid.statusColor).opacity(0.12)) }
                    }
                }
                Spacer()
                Image(systemName: "chevron.right").font(.system(size: 12, weight: .semibold)).foregroundStyle(theme.textMuted)
            }
        }
    }
}
