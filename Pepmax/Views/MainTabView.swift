import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var store: AppStore
    @State private var selectedTab = 0
    
    private var theme: LiquidGlassTheme {
        store.profile.isDarkMode ? .dark : .light
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)
            
            EncyclopediaView()
                .tabItem {
                    Label("Encyclopedia", systemImage: "book.fill")
                }
                .tag(1)
            
            CompareView()
                .tabItem {
                    Label("Compare", systemImage: "square.stack.3d.up")
                }
                .tag(2)
            
            TrackerView()
                .tabItem {
                    Label("Tracker", systemImage: "syringe.fill")
                }
                .tag(3)
            
            CalculatorView()
                .tabItem {
                    Label("Calculator", systemImage: "function")
                }
                .tag(4)
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(5)
        }
        .tint(theme.primary)
    }
}
