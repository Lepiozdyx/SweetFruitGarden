import SwiftUI

@main
struct MainApp: App {
    @UIApplicationDelegateAdaptor(NotificationAppDelegate.self) var appDelegate
    @StateObject private var store = GardenStore()

    var body: some Scene {
        WindowGroup {
            AppRootView()
                .environmentObject(store)
                .buttonStyle(ClickSoundButtonStyle())
        }
    }
}
