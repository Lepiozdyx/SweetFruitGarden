import SwiftUI

struct AppRootView: View {
    @AppStorage("has_seen_onboarding_v1") private var hasSeenOnboarding = false

    var body: some View {
        Group {
            if hasSeenOnboarding {
                PlantLibraryRootView()
            } else {
                OnboardingTabView {
                    hasSeenOnboarding = true
                }
            }
        }
    }
}

#Preview {
    AppRootView()
        .environmentObject(GardenStore())
}
