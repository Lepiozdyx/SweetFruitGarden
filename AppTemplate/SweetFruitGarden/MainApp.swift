import SwiftUI

struct MainApp: View {
    @UIApplicationDelegateAdaptor(NotificationAppDelegate.self) var appDelegate
    @StateObject private var store = GardenStore()

    var body: some View {
        AppRootView()
            .environmentObject(store)
            .buttonStyle(ClickSoundButtonStyle())
    }
}
