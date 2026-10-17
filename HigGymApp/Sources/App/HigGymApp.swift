import SwiftUI
import TipKit
import LeeoKit

@main
struct HigGymApp: App {
    @State private var progress = ProgressStore()
    @State private var notebook: NotebookStore

    /// 켤 때마다 같은 자리에서 죽는 일을 알아채는 가드. 두 번 연속 첫 화면까지 못 가면 다음 실행을 세이프 모드로 연다.
    private static let crashGuard = LeeoCrashLoopGuard(name: "app", defaults: .standard)

    init() {
        // LeeoKit 계약을 켜는 한 줄 (→ HigGymSpec.swift). 실행 횟수 기록 · 익명 사용 통계 ·
        // 크래시 진단 · 원격 킬스위치(→ HigGymFlags.swift) · DEBUG 프리플라이트.
        // 통계·진단·플래그는 FeedbackHub(CloudKit)를 쓴다, 그 iCloud 컨테이너 권한은 HigGymApp/HigGym.entitlements 에 있다.
        LeeoKit.bootstrap(HigGymSpec.self, flags: HigGymFlag.self)

        let notebook = NotebookStore()
        // 세이프 모드: 연속으로 죽었다면 가장 의심스러운 두 가지를 건너뛴다.
        // ① 하다 만 레슨을 멈춘 단계(실물 크기 비교 화면 등)에서 다시 여는 일 → 그 레슨의 첫 단계부터 연다. 쓴 글은 그대로다.
        // ② 기능 안내 말풍선(TipKit) 저장소 → 이번 실행에서는 켜지 않는다.
        let isSafeMode = Self.crashGuard.beginLaunch()
        if isSafeMode {
            HigGymLog.launch.error("연속으로 시작에 실패해 세이프 모드로 엽니다")
            notebook.rewindResumeToFirstStep()
        }
        _notebook = State(initialValue: notebook)

        // 기능 안내 말풍선(→ FeatureTips.swift). 스크린샷 검증 실행에서는 화면을 가리지 않게 켜지 않는다.
        if !isSafeMode, LeeoRemoteFlags.isEnabled(HigGymFlag.featureTipsEnabled), !DebugLaunch.isScripted {
            try? Tips.configure()
        }
        HigGymFunnel.reach(.firstOpen)
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(progress)
                .environment(notebook)
                // 다크를 강제하지 않는다 - 팔레트가 두 모드를 다 갖고 있고,
                // 예제는 시스템 컴포넌트라 모드를 따라가야 실물과 같아진다.
                .tint(.hgAccent)
                // 첫 화면이 뜨고 몇 초 살아 있으면 이번 시작은 성공이다.
                .task { Self.crashGuard.markLaunchSucceededAfterSurvivalDelay() }
        }
    }
}
