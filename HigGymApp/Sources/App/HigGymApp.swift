import SwiftUI
import LeeoKit

@main
struct HigGymApp: App {
    @State private var progress = ProgressStore()
    @State private var notebook = NotebookStore()

    init() {
        // LeeoKit 계약을 켜는 한 줄 (→ HigGymSpec.swift). 실행 횟수 기록 · DEBUG 프리플라이트.
        // ⚠️ 크래시 진단은 끈다(`diagnostics: false`). 진단은 FeedbackHub(CloudKit)로 올리는데
        //    이 앱엔 아직 그 iCloud 컨테이너 권한이 없다 — 권한 없이 CKContainer 를 만들면 앱이 죽는다.
        LeeoKit.bootstrap(HigGymSpec.self, diagnostics: false)
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(progress)
                .environment(notebook)
                // 다크를 강제하지 않는다 - 팔레트가 두 모드를 다 갖고 있고,
                // 예제는 시스템 컴포넌트라 모드를 따라가야 실물과 같아진다.
                .tint(.hgAccent)
        }
    }
}
