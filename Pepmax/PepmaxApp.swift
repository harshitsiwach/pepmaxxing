import SwiftUI

@main
struct PepmaxApp: App {
    @StateObject private var store = AppStore()
    
    var body: some Scene {
        WindowGroup {
            Group {
                if store.profile.hasCompletedOnboarding {
                    MainTabView()
                } else {
                    OnboardingView()
                }
            }
            .environmentObject(store)
            .environment(\.isDarkMode, store.profile.isDarkMode)
            .environment(\.theme, store.profile.isDarkMode ? .dark : .light)
            .preferredColorScheme(store.profile.isDarkMode ? .dark : .light)
            .animation(.easeInOut(duration: 0.3), value: store.profile.hasCompletedOnboarding)
        }
    }
}

