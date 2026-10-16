import SwiftUI
import TipKit
import LeeoKit

@main
struct HigGymApp: App {
    @State private var progress = ProgressStore()
    @State private var notebook = NotebookStore()

    init() {
        // LeeoKit 계약을 켜는 한 줄 (→ HigGymSpec.swift). 실행 횟수 기록 · 익명 사용 통계 ·
        // 크래시 진단 · 원격 킬스위치(→ HigGymFlags.swift) · DEBUG 프리플라이트.
        // 통계·진단·플래그는 FeedbackHub(CloudKit)를 쓴다, 그 iCloud 컨테이너 권한은 HigGymApp/HigGym.entitlements 에 있다.
        LeeoKit.bootstrap(HigGymSpec.self, flags: HigGymFlag.self)

        // 기능 안내 말풍선(→ FeatureTips.swift). 스크린샷 검증 실행에서는 화면을 가리지 않게 켜지 않는다.
        if LeeoRemoteFlags.isEnabled(HigGymFlag.featureTipsEnabled), !DebugLaunch.isScripted {
            try? Tips.configure()
        }
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
