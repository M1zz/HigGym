import SwiftUI
import LeeoKit

/// 퀴즈 해설에서 "이건 실습으로 확인해보세요"를 눌렀을 때 실습 탭으로 넘겨주는 통로.
@MainActor
@Observable
final class Router {
    enum TabID: Hashable { case course, notebook, library }

    var tab: TabID = .course
    /// 항목 상세에서 실수로, 실수에서 다시 항목으로 넘나들므로 타입을 섞어 담는다.
    /// `[Entry]` 였을 때는 실수 링크를 경로에 넣을 수 없어 바로가기가 조용히 무시됐다.
    var entryPath = NavigationPath()
    /// 실습은 push 가 아니라 전체 화면으로 띄운다 - LabScaffold 주석 참고.
    var presentedLab: LabID?
    /// 학습 탭이 열어야 할 레슨 - 단축어("이어서 학습하기")가 여기에 넣고, 코스 화면이 꺼내 연다.
    var lessonToOpen: String?

    func open(_ lab: LabID) {
        tab = .library
        presentedLab = lab
    }
}

/// 시뮬레이터에서 특정 실습 화면을 바로 띄워 확인하기 위한 개발용 훅.
/// `xcrun simctl launch --console <device> <번들 ID>` 실행 시
/// 환경변수 HG_OPEN_LAB=toolbar 로 지정한다.
enum DebugLaunch {
    /// 스크린샷 검증 스크립트가 띄운 실행인가 (HG_ 로 시작하는 환경변수가 하나라도 있으면).
    /// 첫 실행 안내·기능 안내 말풍선이 찍을 화면을 가리지 않게 한다.
    static var isScripted: Bool {
        #if DEBUG
        ProcessInfo.processInfo.environment.keys.contains { $0.hasPrefix("HG_") }
        #else
        false
        #endif
    }

    static var lab: LabID? {
        #if DEBUG
        guard let raw = ProcessInfo.processInfo.environment["HG_OPEN_LAB"] else { return nil }
        return LabID(rawValue: raw)
        #else
        return nil
        #endif
    }

    /// 시작 탭 지정 - 스크린샷 검증용.
    static var tab: Router.TabID? {
        #if DEBUG
        switch ProcessInfo.processInfo.environment["HG_TAB"] {
        case "course":   .course
        case "notebook": .notebook
        case "library":  .library
        // 자료 안으로 들어간 옛 탭 이름들도 받아준다 - 검증 스크립트를 다시 쓰지 않게.
        case "entries", "mistakes", "principles", "labs", "quiz": .library
        default: nil
        }
        #else
        nil
        #endif
    }

    /// 퀴즈 유형 지정 - 스크린샷 검증용.
    static var quizKind: Question.Kind? {
        #if DEBUG
        ProcessInfo.processInfo.environment["HG_QUIZ_KIND"].flatMap(Question.Kind.init(rawValue:))
        #else
        nil
        #endif
    }

    /// 특정 항목 상세를 바로 연다 - 스크린샷 검증용.
    static var entryIndex: String? {
        #if DEBUG
        ProcessInfo.processInfo.environment["HG_ENTRY"]
        #else
        nil
        #endif
    }

    /// 특정 레슨을 바로 연다 - 스크린샷 검증용. (HG_LESSON=L2)
    static var lessonID: String? {
        #if DEBUG
        ProcessInfo.processInfo.environment["HG_LESSON"]
        #else
        nil
        #endif
    }

    /// 레슨의 특정 단계에서 시작한다 - 스크린샷 검증용. (HG_STEP=0~4)
    static var lessonStep: Int? {
        #if DEBUG
        ProcessInfo.processInfo.environment["HG_STEP"].flatMap(Int.init)
        #else
        nil
        #endif
    }

    /// 학습 노트를 표본 글로 채운다 - 스크린샷 검증용. (HG_SEED_NOTES=1)
    static var seedNotes: Bool {
        #if DEBUG
        ProcessInfo.processInfo.environment["HG_SEED_NOTES"] == "1"
        #else
        false
        #endif
    }

    /// 자료 탭에서 어떤 자료를 열 것인가 - 스크린샷 검증용. (HG_LIB=entries|mistakes|principles|labs|quiz)
    static var libraryTarget: String? {
        #if DEBUG
        ProcessInfo.processInfo.environment["HG_LIB"]
        #else
        nil
        #endif
    }

    /// 실전 퀴즈·샘플 앱을 바로 연다 - 스크린샷 검증용. (HG_LIVE=pick|reason · HG_CASE=1)
    static var liveKind: LiveQuestion.Kind? {
        #if DEBUG
        switch ProcessInfo.processInfo.environment["HG_LIVE"] {
        case "pick":   .pickScreen
        case "reason": .reason
        default:       nil
        }
        #else
        nil
        #endif
    }

    static var caseStudy: Bool {
        #if DEBUG
        ProcessInfo.processInfo.environment["HG_CASE"] == "1"
        #else
        false
        #endif
    }

    /// 특정 실수 상세를 바로 연다 - 스크린샷 검증용. (HG_MISTAKE=3)
    static var mistakeNumber: Int? {
        #if DEBUG
        ProcessInfo.processInfo.environment["HG_MISTAKE"].flatMap(Int.init)
        #else
        nil
        #endif
    }

    /// 실수 상세에서 회고까지 바로 연다 - 스크린샷 검증용.
    static var autoStory: Bool {
        #if DEBUG
        ProcessInfo.processInfo.environment["HG_STORY"] == "1"
        #else
        false
        #endif
    }

    /// 특정 원칙 상세를 바로 연다 - 스크린샷 검증용.
    static var principleIndex: String? {
        #if DEBUG
        ProcessInfo.processInfo.environment["HG_PRINCIPLE"]
        #else
        nil
        #endif
    }

    /// 항목 상세를 열자마자 그 항목의 예제까지 띄운다 - 스크린샷 검증용.
    static var autoDemo: Bool {
        #if DEBUG
        ProcessInfo.processInfo.environment["HG_DEMO"] == "1"
        #else
        false
        #endif
    }

    /// 퀴즈를 바로 시작한다 - 스크린샷 검증용.
    static var autoQuiz: Bool {
        #if DEBUG
        ProcessInfo.processInfo.environment["HG_QUIZ"] == "1"
        #else
        false
        #endif
    }

    /// 첫 문제를 지정한 보기로 자동 응답한다 - 채점·해설 화면 검증용.
    static var autoAnswer: Int? {
        #if DEBUG
        ProcessInfo.processInfo.environment["HG_QUIZ_ANSWER"].flatMap(Int.init)
        #else
        nil
        #endif
    }

    /// 예제 화면을 스크롤된 상태로 연다. 가장자리 효과 검증용. (HG_SCROLLED=1)
    static var scrolled: Bool {
        #if DEBUG
        ProcessInfo.processInfo.environment["HG_SCROLLED"] == "1"
        #else
        false
        #endif
    }

    /// 결제 화면만 단독으로 띄운다 - 인앱 상품 심사용 스크린샷. (HG_PAYWALL=1, 잠긴 상태는 HG_PRO=0 과 함께)
    static var paywall: Bool {
        #if DEBUG
        ProcessInfo.processInfo.environment["HG_PAYWALL"] == "1"
        #else
        false
        #endif
    }

    /// 결제 화면의 요금제 가격 - 인앱 상품 심사용 스크린샷. 주간|월간|평생 순서. (HG_PREVIEW_PRICES=₩2,900|₩9,900|₩50,000)
    static var previewPrices: [String]? {
        #if DEBUG
        ProcessInfo.processInfo.environment["HG_PREVIEW_PRICES"]?.components(separatedBy: "|")
        #else
        nil
        #endif
    }

    /// 실습을 열자마자 전체 화면 무대까지 띄운다 - 스크린샷 검증용.
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
    @Environment(NotebookStore.self) private var notebook
    /// 첫 실행 안내를 봤는가. 설정의 "사용법 다시 보기"로 다시 띄울 수 있다.
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    /// 단축어가 남긴 요청. 앱이 앞으로 나오면 여기서 꺼내 해당 화면으로 보낸다.
    private let intents = IntentInbox.shared
    /// 만족도 질문을 붙일지 - 원격 킬스위치로 끌 수 있다. 실행 중 한 번만 읽는다
    /// (그릴 때마다 읽으면 플래그가 갱신되는 순간 탭 화면이 통째로 다시 만들어진다).
    /// 업데이트 뒤 한 번 뜨는 새 기능 안내.
    @State private var showsWhatsNew = false
    @State private var asksSatisfaction = LeeoRemoteFlags.isEnabled(HigGymFlag.satisfactionPromptEnabled)
        && !DebugLaunch.isScripted

    var body: some View {
        if DebugLaunch.paywall {
            HigGymPaywallView(onClose: {})
        } else if let lab = DebugLaunch.lab {
            // 스크린샷 검증용 - 실습 화면만 단독으로 띄운다.
            labDestination(lab)
                .environment(router)
        } else {
            tabs
        }
    }

    /// 학습이 앱의 본문이고, 노트는 학습자가 쓴 것, 자료는 필요할 때 여는 뒤편이다.
    private var tabs: some View {
        TabView(selection: $router.tab) {
            Tab("학습", systemImage: "graduationcap.fill", value: Router.TabID.course) {
                CourseHomeView()
            }
            Tab("노트", systemImage: "text.book.closed.fill", value: Router.TabID.notebook) {
                NotebookView()
            }
            Tab("자료", systemImage: "books.vertical.fill", value: Router.TabID.library) {
                LibraryView()
            }
        }
        .environment(router)
        .modifier(SatisfactionCheck(isEnabled: asksSatisfaction))
        .fullScreenCover(isPresented: onboardingPresented) {
            HigGymOnboardingView { hasSeenOnboarding = true }
        }
        .sheet(isPresented: $showsWhatsNew, onDismiss: { WhatsNewContent.markSeen() }) {
            WhatsNewView { showsWhatsNew = false }
        }
        .onAppear {
            if let tab = DebugLaunch.tab { router.tab = tab }
            #if DEBUG
            if DebugLaunch.seedNotes { notebook.seedForScreenshots() }
            #endif
            // 안내가 생기기 전부터 쓰던 사람에게는 띄우지 않는다 - 이미 레슨을 해 본 사람이다.
            if !hasSeenOnboarding, !notebook.notes.isEmpty || notebook.resumeLessonID != nil {
                hasSeenOnboarding = true
            }
            // 첫 실행 안내를 볼 사람(처음 온 사람)에게는 새 기능 안내를 띄우지 않는다.
            if !DebugLaunch.isScripted,
               WhatsNewContent.shouldPresent(isNewcomer: !hasSeenOnboarding) {
                showsWhatsNew = true
            }
        }
        .onChange(of: intents.pending, initial: true) { _, request in
            guard let request else { return }
            intents.pending = nil
            handle(request)
        }
    }

    private var onboardingPresented: Binding<Bool> {
        Binding(
            get: { !hasSeenOnboarding && !DebugLaunch.isScripted },
            set: { if !$0 { hasSeenOnboarding = true } }
        )
    }

    private func handle(_ request: IntentInbox.Request) {
        switch request {
        case .resumeLesson:
            router.tab = .course
            router.lessonToOpen = notebook.next?.id
        case .openNotebook:
            router.tab = .notebook
        }
    }
}

/// 만족도 질문(→ LeeoKit). 레슨을 마친 횟수가 쌓이면 루트에서 스스로 묻는다.
/// 만족 → 시스템 리뷰 요청, 아쉬움 → 피드백 화면.
private struct SatisfactionCheck: ViewModifier {
    let isEnabled: Bool

    func body(content: Content) -> some View {
        if isEnabled {
            content.leeoSatisfactionCheck(HigGymSpec.self)
        } else {
            content
        }
    }
}
