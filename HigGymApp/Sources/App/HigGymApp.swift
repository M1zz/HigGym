import SwiftUI

@main
struct HigGymApp: App {
    @State private var progress = ProgressStore()
    @State private var notebook = NotebookStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(progress)
                .environment(notebook)
                // 다크를 강제하지 않는다 — 팔레트가 두 모드를 다 갖고 있고,
                // 예제는 시스템 컴포넌트라 모드를 따라가야 실물과 같아진다.
                .tint(.hgAccent)
        }
    }
}
