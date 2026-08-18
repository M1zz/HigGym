import SwiftUI

/// 퀴즈 해설에서 "이건 실습으로 확인해보세요"를 눌렀을 때 실습 탭으로 넘겨주는 통로.
@MainActor
@Observable
final class Router {
    enum TabID: Hashable { case entries, mistakes, labs, quiz, principles }

    var tab: TabID = .entries
    var entryPath: [Entry] = []
    /// 실습은 push 가 아니라 전체 화면으로 띄운다 — LabScaffold 주석 참고.
    var presentedLab: LabID?

    func open(_ lab: LabID) {
        tab = .labs
        presentedLab = lab
    }
}

/// 시뮬레이터에서 특정 실습 화면을 바로 띄워 확인하기 위한 개발용 훅.
/// `xcrun simctl launch --console <device> dev.m1zz.HigGym` 실행 시
/// 환경변수 HG_OPEN_LAB=toolbar 로 지정한다.
enum DebugLaunch {
    static var lab: LabID? {
        #if DEBUG
        guard let raw = ProcessInfo.processInfo.environment["HG_OPEN_LAB"] else { return nil }
        return LabID(rawValue: raw)
        #else
        return nil
        #endif
    }

    /// 시작 탭 지정 — 스크린샷 검증용.
    static var tab: Router.TabID? {
        #if DEBUG
        switch ProcessInfo.processInfo.environment["HG_TAB"] {
        case "entries":    .entries
        case "mistakes":   .mistakes
        case "quiz":       .quiz
        case "principles": .principles
        case "labs":       .labs
        default:           nil
        }
        #else
        nil
        #endif
    }

    /// 퀴즈 유형 지정 — 스크린샷 검증용.
    static var quizKind: Question.Kind? {
        #if DEBUG
        ProcessInfo.processInfo.environment["HG_QUIZ_KIND"].flatMap(Question.Kind.init(rawValue:))
        #else
        nil
        #endif
    }

    /// 특정 항목 상세를 바로 연다 — 스크린샷 검증용.
    static var entryIndex: String? {
        #if DEBUG
        ProcessInfo.processInfo.environment["HG_ENTRY"]
        #else
        nil
        #endif
    }

    /// 특정 실수 상세를 바로 연다 — 스크린샷 검증용. (HG_MISTAKE=3)
    static var mistakeNumber: Int? {
        #if DEBUG
        ProcessInfo.processInfo.environment["HG_MISTAKE"].flatMap(Int.init)
        #else
        nil
        #endif
    }

    /// 실수 상세에서 회고까지 바로 연다 — 스크린샷 검증용.
    static var autoStory: Bool {
        #if DEBUG
        ProcessInfo.processInfo.environment["HG_STORY"] == "1"
        #else
        false
        #endif
    }

    /// 특정 원칙 상세를 바로 연다 — 스크린샷 검증용.
    static var principleIndex: String? {
        #if DEBUG
        ProcessInfo.processInfo.environment["HG_PRINCIPLE"]
        #else
        nil
        #endif
    }

    /// 항목 상세를 열자마자 그 항목의 예제까지 띄운다 — 스크린샷 검증용.
    static var autoDemo: Bool {
        #if DEBUG
        ProcessInfo.processInfo.environment["HG_DEMO"] == "1"
        #else
        false
        #endif
    }

    /// 퀴즈를 바로 시작한다 — 스크린샷 검증용.
    static var autoQuiz: Bool {
        #if DEBUG
        ProcessInfo.processInfo.environment["HG_QUIZ"] == "1"
        #else
        false
        #endif
    }

    /// 첫 문제를 지정한 보기로 자동 응답한다 — 채점·해설 화면 검증용.
    static var autoAnswer: Int? {
        #if DEBUG
        ProcessInfo.processInfo.environment["HG_QUIZ_ANSWER"].flatMap(Int.init)
        #else
        nil
        #endif
    }

    /// 실습을 열자마자 전체 화면 무대까지 띄운다 — 스크린샷 검증용.
    static var autoRunStage: Bool {
        #if DEBUG
        ProcessInfo.processInfo.environment["HG_RUN_STAGE"] == "1"
        #else
        false
        #endif
    }
}

struct RootView: View {
    @State private var router = Router()

    var body: some View {
        if let lab = DebugLaunch.lab {
            // 스크린샷 검증용 — 실습 화면만 단독으로 띄운다.
            labDestination(lab)
                .environment(router)
        } else {
            tabs
        }
    }

    private var tabs: some View {
        TabView(selection: $router.tab) {
            Tab("항목", systemImage: "square.grid.2x2.fill", value: Router.TabID.entries) {
                EntriesHomeView()
            }
            Tab("실수", systemImage: "exclamationmark.triangle.fill", value: Router.TabID.mistakes) {
                MistakesHomeView()
            }
            Tab("실습", systemImage: "hammer.fill", value: Router.TabID.labs) {
                LabsHomeView()
            }
            Tab("퀴즈", systemImage: "checkmark.circle.fill", value: Router.TabID.quiz) {
                QuizHomeView()
            }
            Tab("원칙", systemImage: "list.bullet.rectangle.portrait", value: Router.TabID.principles) {
                PrinciplesView()
            }
        }
        .environment(router)
        .onAppear { if let tab = DebugLaunch.tab { router.tab = tab } }
    }
}
