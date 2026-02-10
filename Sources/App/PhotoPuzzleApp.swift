import SwiftUI

@main
struct PhotoPuzzleApp: App {
    @State private var settings = UserSettings()
    @State private var storeManager = StoreManager()
    @State private var adsManager = AdMobManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(settings)
                .environment(storeManager)
                .environment(adsManager)
                .task {
                    adsManager.start()
                }
        }
    }
}
