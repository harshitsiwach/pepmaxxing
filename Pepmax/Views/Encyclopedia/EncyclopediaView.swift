import SwiftUI

struct EncyclopediaView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.isDarkMode) private var isDarkMode
    @State private var searchText = ""
    @State private var selectedCategory = "All"
    
    private var theme: LiquidGlassTheme { isDarkMode ? .dark : .light }
    
    private var filteredPeptides: [Peptide] {
        var result = store.peptides
        if selectedCategory != "All" {
            result = result.filter { $0.category == selectedCategory }
        }
        if !searchText.isEmpty {
            result = result.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.category.localizedCaseInsensitiveContains(searchText) ||
                $0.mechanism.localizedCaseInsensitiveContains(searchText)
            }
        }
        return result
    }
    
    private var categories: [String] {
        ["All"] + store.uniqueCategories
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
                            Text("\(store.peptides.count) peptides")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(theme.textMuted)
                        }
                        Spacer()
                    }
                    
                    // Search
                    GlassSearchBar(text: $searchText)
                    
                    // Category filters
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(categories, id: \.self) { cat in
                                Button {
                                    withAnimation(.spring(response: 0.3)) {
                                        selectedCategory = cat
                                    }
                                } label: {
                                    GlassPill(text: cat, color: cat == "All" ? theme.primary : CategoryColors.color(for: cat), isSelected: selectedCategory == cat)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    
                    // Results count
                    HStack {
                        Text("\(filteredPeptides.count) results")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(theme.textMuted)
                        Spacer()
                    }
                    
                    // Peptide list
                    LazyVStack(spacing: 10) {
                        ForEach(filteredPeptides) { peptide in
                            NavigationLink(destination: PeptideDetailView(peptide: peptide)) {
                                peptideRow(peptide)
                            }
                            .buttonStyle(.plain)
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
                    Text(peptide.name)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(theme.text)
                        .lineLimit(1)
                    
                    Text(peptide.mechanism.components(separatedBy: ";").first ?? peptide.mechanism)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(theme.textMuted)
                        .lineLimit(1)
                    
                    HStack(spacing: 6) {
                        // Category pill
                        Text(peptide.category)
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(CategoryColors.color(for: peptide.category))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background {
                                Capsule().fill(CategoryColors.color(for: peptide.category).opacity(0.12))
                            }
                        
                        // Status
                        Text(peptide.clinicalStatus)
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(Color(hex: peptide.statusColor))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background {
                                Capsule().fill(Color(hex: peptide.statusColor).opacity(0.12))
                            }
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(theme.textMuted)
            }
        }
    }
}
