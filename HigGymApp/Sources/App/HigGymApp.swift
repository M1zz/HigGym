import SwiftUI

@main
struct HigGymApp: App {
    @State private var progress = ProgressStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(progress)
                .preferredColorScheme(.dark)
                .tint(.hgAccent)
        }
    }
}
