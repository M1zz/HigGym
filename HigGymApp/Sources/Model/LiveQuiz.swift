import SwiftUI

/// 화면을 보고 판단하는 문항.
///
/// 기존 퀴즈(QuizBank)가 문장을 읽고 고르는 훈련이라면, 이쪽은 **돌아가는 화면**을 보고 고른다.
/// 실무에서 판단하는 대상이 문장이 아니라 화면이기 때문이다. 보기로 나오는 화면은
/// 전부 표본 앱(노트)의 같은 화면이고, 결정 하나만 다르다.
@MainActor
struct LiveQuestion: Identifiable {
    enum Kind: String {
        /// 기준을 주고, 그 기준을 지킨 화면을 고른다.
        case pickScreen
        /// 화면을 주고, 왜 그렇게 만들었는지를 고른다.
        case reason

        var title: String {
            switch self {
            case .pickScreen: "이 기준이면 어느 화면"
            case .reason:     "이 화면, 왜 이렇게 했나"
            }
        }
        var symbol: String {
            switch self {
            case .pickScreen: "rectangle.on.rectangle.angled"
            case .reason:     "questionmark.bubble"
            }
        }
    }

    let id: String
    let kind: Kind
    /// 기준 문장(pickScreen) 또는 질문(reason).
    let prompt: String
    /// 화면에서 어디를 보라는 안내.
    let lookAt: String
    /// reason 문항이 판단 대상으로 보여주는 화면.
    let subject: (() -> AnyView)?
    let options: [LiveOption]
    let explanation: String
    let sources: [String]
    /// 이 문항이 다루는 실수 번호 — 해설에서 회고로 이어준다.
    let mistakeNumber: Int?

    var correctIndex: Int { options.firstIndex(where: \.isCorrect) ?? 0 }
}

@MainActor
struct LiveOption: Identifiable {
    let id: String
    let label: String
    /// pickScreen 문항의 보기는 **돌아가는 화면**이다.
    let screen: (() -> AnyView)?
    let isCorrect: Bool
    /// 고른 뒤에 붙는 한 줄 — 왜 맞고 왜 틀렸는지.
    let note: String
}

// MARK: - 표본 앱의 어느 면을 보여줄 것인가

extension NoteAppConfig.Knob {
    /// 이 결정이 드러나는 화면. 목록에서 안 보이는 결정(본문 선택·편집기 출구)은 그 화면을 직접 연다.
    @MainActor @ViewBuilder
    func surface(_ config: NoteAppConfig, spotlight: NoteAppConfig.Knob? = nil) -> some View {
        switch self {
        case .selection:
            NavigationStack {
                NoteDetailScreen(note: SampleNotes.all[2], config: config, spotlight: spotlight)
            }
        case .editorExit:
            NoteEditorScreen(config: config, spotlight: spotlight)
        case .date:
            // 표기가 로케일을 따라가는지 보려면 로케일을 눈에 보이게 바꿔야 한다.
            SampleNoteApp(config: config, spotlight: spotlight)
                .environment(\.locale, Locale(identifier: "en_US"))
        default:
            SampleNoteApp(config: config, spotlight: spotlight)
        }
    }
}

// MARK: - 문항 은행

@MainActor
enum LiveQuizBank {
    static let pickScreen: [LiveQuestion] = NoteAppDecision.all.enumerated().map { index, decision in
        let knob = decision.knob
        let good = LiveOption(
            id: "\(knob.rawValue)-good",
            label: "A",
            screen: { AnyView(knob.surface(.recommended)) },
            isCorrect: true,
            note: decision.decision
        )
        let bad = LiveOption(
            id: "\(knob.rawValue)-bad",
            label: "B",
            screen: { AnyView(knob.surface(NoteAppConfig.recommended.flipping(knob))) },
            isCorrect: false,
            note: decision.ifFlipped
        )
        // 정답이 한쪽에 몰리지 않게 번갈아 놓는다.
        let options = index.isMultiple(of: 2) ? [bad, good] : [good, bad]

        return LiveQuestion(
            id: "pick-\(knob.rawValue)",
            kind: .pickScreen,
            prompt: Self.criterion(for: knob),
            lookAt: decision.place,
            subject: nil,
            options: options.enumerated().map { position, option in
                LiveOption(
                    id: option.id,
                    label: position == 0 ? "왼쪽" : "오른쪽",
                    screen: option.screen,
                    isCorrect: option.isCorrect,
                    note: option.note
                )
            },
            explanation: decision.why,
            sources: decision.sources,
            mistakeNumber: Self.mistakeNumber(for: knob)
        )
    }

    /// 기준은 원칙의 문장을 그 결정에 맞게 한 줄로 줄인 것이다.
    private static func criterion(for knob: NoteAppConfig.Knob) -> String {
        switch knob {
        case .compose:    "자주·반복해서 누르는 액션은 엄지에 가깝게 — 어느 쪽이 이 기준을 지켰습니까?"
        case .deletion:   "되돌릴 수 없는 액션은 한 단계 멀리, 그리고 대상 위에 — 어느 쪽입니까?"
        case .grouping:   "한 캡슐에 묶인 것들은 사용자가 한 세트로 읽는다 — 어느 쪽이 이 문법을 지켰습니까?"
        case .title:      "액션은 그 대상 위에 붙어야 한다 — 어느 쪽이 폴더 전환을 제대로 뒀습니까?"
        case .search:     "자주 여는 입구는 엄지에 가깝게, 그리고 안 쓰는 순간에 자리를 차지하지 않게 — 어느 쪽입니까?"
        case .date:       "값과 표기를 한 문자열에 담지 않는다 — **이 두 화면은 영어(en_US) 기기**입니다. 어느 쪽이 로케일을 따라갑니까?"
        case .selection:  "옮겨 적을 일이 있는 값에는 선택·복사를 연다 — 어느 쪽입니까? (본문을 길게 눌러보세요)"
        case .editorExit: "덮는 화면일수록 나가는 길을 먼저 설계한다 — 어느 쪽에 출구가 있습니까?"
        }
    }

    private static func mistakeNumber(for knob: NoteAppConfig.Knob) -> Int? {
        switch knob {
        case .compose:    99
        case .deletion:   7
        case .grouping:   3
        case .title:      100
        case .search:     30
        case .date:       47
        case .selection:  46
        case .editorExit: 81
        }
    }

    // MARK: 이 화면, 왜 이렇게 했나

    static let reason: [LiveQuestion] = [
        LiveQuestion(
            id: "why-compose",
            kind: .reason,
            prompt: "새 노트 버튼이 **하단 오른쪽 끝**에 있습니다. 왜 여기일까요?",
            lookAt: "화면 아래 오른쪽 캡슐",
            subject: { AnyView(NoteAppConfig.Knob.compose.surface(.recommended)) },
            options: [
                .init(id: "a", label: "이 화면에서 가장 자주 하는 일이라, 엄지가 가장 쉽게 닿는 자리를 줬다",
                      screen: nil, isCorrect: true,
                      note: "빈도와 높이는 반비례해야 합니다. 목록에서 반복되는 액션은 새 노트 하나뿐입니다."),
                .init(id: "b", label: "가장 중요한 기능이라 가장 잘 보이는 자리에 뒀다",
                      screen: nil, isCorrect: false,
                      note: "자리를 정하는 건 중요도가 아니라 **빈도**입니다. 중요하지만 가끔 쓰는 액션(완료·저장)은 상단입니다."),
                .init(id: "c", label: "상단이 제목으로 차 있어서 남는 자리가 아래뿐이었다",
                      screen: nil, isCorrect: false,
                      note: "남는 자리를 채운 게 아니라, 그 자리를 이 액션에 준 것입니다."),
                .init(id: "d", label: "하단 바가 비어 보이면 미완성처럼 보이기 때문에",
                      screen: nil, isCorrect: false,
                      note: "빈 자리는 실패가 아닙니다. 채우기 위해 넣은 것은 대개 군더더기입니다(8.1.1)."),
            ],
            explanation: "도달성 기준은 \"자주·반복해서 누르는가\"입니다. 그렇다면 하단, 가끔 쓰는 확정성 액션이면 상단 — 빈도와 높이가 반비례해야 합니다.",
            sources: ["1.1.4", "8.1.2"],
            mistakeNumber: 99
        ),
        LiveQuestion(
            id: "why-delete",
            kind: .reason,
            prompt: "삭제가 툴바에 없습니다. 행을 밀어야 나옵니다. 왜 이렇게 했을까요?",
            lookAt: "목록의 행을 왼쪽으로 밀어보세요",
            subject: { AnyView(NoteAppConfig.Knob.deletion.surface(.recommended)) },
            options: [
                .init(id: "a", label: "되돌릴 수 없는 액션이라, 대상 위에 두고 한 단계 거치게 했다",
                      screen: nil, isCorrect: true,
                      note: "무엇을 지우는지가 분명해지고, 미는 동작 자체가 오탭을 막습니다."),
                .init(id: "b", label: "툴바 자리가 모자라서 어쩔 수 없이 숨겼다",
                      screen: nil, isCorrect: false,
                      note: "자리가 있었어도 두지 않았을 겁니다. 문제는 공간이 아니라 사고 위험입니다."),
                .init(id: "c", label: "삭제는 잘 쓰지 않는 기능이라 접어둔 것이다",
                      screen: nil, isCorrect: false,
                      note: "빈도 문제가 아닙니다. 자주 쓰더라도 되돌릴 수 없으면 한 단계 멀리 둡니다."),
                .init(id: "d", label: "스와이프가 요즘 유행하는 제스처여서",
                      screen: nil, isCorrect: false,
                      note: "유행이 아니라 대상-액션 결합의 문제입니다(8.1.7)."),
            ],
            explanation: "도달성 기준에는 말하지 않은 전제가 있습니다 — **잘못 눌러도 되는 액션**에만 해당한다는 것. 되돌릴 수 없는 액션은 일부러 멀리 둡니다.",
            sources: ["8.1.7", "1.1.4"],
            mistakeNumber: 7
        ),
        LiveQuestion(
            id: "why-title-menu",
            kind: .reason,
            prompt: "폴더를 바꾸는 방법이 **제목을 누르는 것**입니다. 왜 별도 버튼을 두지 않았을까요?",
            lookAt: "제목 옆의 ⌄ 를 눌러보세요",
            subject: { AnyView(NoteAppConfig.Knob.title.surface(.recommended)) },
            options: [
                .init(id: "a", label: "제목이 곧 \"지금 무엇을 보고 있는가\"이므로, 그것을 바꾸는 액션은 제목 위에 있는 게 맞다",
                      screen: nil, isCorrect: true,
                      note: "대상과 액션이 붙어 있어 사용자가 둘을 이어 생각할 필요가 없습니다."),
                .init(id: "b", label: "툴바를 최대한 비워 미니멀하게 보이려고",
                      screen: nil, isCorrect: false,
                      note: "미학이 아니라 문법의 문제입니다. 비우는 것이 목적이었다면 기능을 없앴을 겁니다."),
                .init(id: "c", label: "제목 메뉴가 iOS 26의 새 기능이라 써본 것이다",
                      screen: nil, isCorrect: false,
                      note: "새 API라서가 아니라, 이 액션의 대상이 제목이기 때문입니다."),
                .init(id: "d", label: "폴더 전환을 잘 안 쓰니까 눈에 안 띄게 감췄다",
                      screen: nil, isCorrect: false,
                      note: "감춘 게 아닙니다 — ⌄ 표시로 누를 수 있다는 사실을 분명히 알립니다(1.2.5)."),
            ],
            explanation: "대상이 화면에 보이는데 액션이 떨어진 버튼에 있으면, 사용자는 \"이 버튼이 저 제목에 대한 것\"임을 유추해야 합니다. 붙여 두면 유추가 필요 없습니다.",
            sources: ["1.2.5", "8.1.7"],
            mistakeNumber: 100
        ),
        LiveQuestion(
            id: "why-search",
            kind: .reason,
            prompt: "검색이 상단 서랍이 아니라 **화면 아래 캡슐**에 있습니다. 왜 내렸을까요?",
            lookAt: "화면 아래의 검색 캡슐",
            subject: { AnyView(NoteAppConfig.Knob.search.surface(.recommended)) },
            options: [
                .init(id: "a", label: "자주 여는 입구라 엄지에 가까워야 하고, 안 쓰는 순간에는 세로 공간을 먹지 않아야 한다",
                      screen: nil, isCorrect: true,
                      note: "iOS 26이 검색을 아래로 내린 것과 같은 이유입니다 — 도달성, 그리고 상시 점유 회피."),
                .init(id: "b", label: "상단에는 제목이 있어서 검색을 넣을 자리가 없었다",
                      screen: nil, isCorrect: false,
                      note: "자리는 있습니다(서랍). 자리가 아니라 손과 공간의 문제입니다."),
                .init(id: "c", label: "하단 캡슐이 더 최신 디자인처럼 보이기 때문에",
                      screen: nil, isCorrect: false,
                      note: "새로워 보여서가 아닙니다. 새 배치가 나온 이유가 도달성입니다."),
                .init(id: "d", label: "검색을 잘 쓰지 않으니 눈에 덜 띄는 곳으로 밀어둔 것이다",
                      screen: nil, isCorrect: false,
                      note: "감춘 게 아니라 **더 닿기 쉬운 자리**로 옮긴 것입니다."),
            ],
            explanation: "검색이 이 화면의 주 사용 방식이면 늘 손에 닿아야 하고, 그렇지 않은 순간에는 자리를 차지하지 않아야 합니다. 하단 캡슐이 그 둘을 동시에 만족합니다.",
            sources: ["1.4.1", "1.4.4"],
            mistakeNumber: 30
        ),
        LiveQuestion(
            id: "why-editor-exit",
            kind: .reason,
            prompt: "이 편집기는 전체 화면인데 **취소·완료**가 붙어 있습니다. 왜 필요할까요?",
            lookAt: "아래로 쓸어내려 보세요 — 닫히지 않습니다",
            subject: { AnyView(NoteAppConfig.Knob.editorExit.surface(.recommended)) },
            options: [
                .init(id: "a", label: "전체 화면 커버는 일부러 스와이프로 닫히지 않으므로, 출구를 직접 만들어야 한다",
                      screen: nil, isCorrect: true,
                      note: "작성 중인 글을 지키는 대신 출구를 만들 의무가 따라옵니다."),
                .init(id: "b", label: "상단이 비면 허전해서 버튼을 채운 것이다",
                      screen: nil, isCorrect: false,
                      note: "채우기 위한 버튼이 아니라, 없으면 나갈 수 없는 버튼입니다."),
                .init(id: "c", label: "시트와 모양을 맞추기 위한 관습적인 배치다",
                      screen: nil, isCorrect: false,
                      note: "시트는 쓸어내려 닫히지만 전체 화면 커버는 아닙니다. 그 차이가 이 항목의 요지입니다."),
                .init(id: "d", label: "저장하지 않고 나가는 경로를 만들기 위한 선택 사항이다",
                      screen: nil, isCorrect: false,
                      note: "선택 사항이 아니라 필수입니다. 없으면 앱이 멈춘 것처럼 보입니다."),
            ],
            explanation: "덮는 화면일수록 나가는 길을 먼저 설계합니다. 시트의 습관은 여기서 통하지 않습니다.",
            sources: ["4.2.1"],
            mistakeNumber: 81
        ),
        LiveQuestion(
            id: "why-date",
            kind: .reason,
            prompt: "수정 시각이 \"3일 전\"처럼 나옵니다. 앱은 이 값을 어떻게 갖고 있을까요?",
            lookAt: "행 오른쪽의 시각",
            subject: { AnyView(NoteAppConfig.Knob.date.surface(.recommended)) },
            options: [
                .init(id: "a", label: "문자열이 아니라 Date 값을 갖고 있고, 표기는 로케일에 맡긴다",
                      screen: nil, isCorrect: true,
                      note: "언어가 바뀌면 표기가 따라옵니다. 앱 코드는 그대로입니다."),
                .init(id: "b", label: "\"3일 전\" 같은 문자열을 계산해서 저장해 둔다",
                      screen: nil, isCorrect: false,
                      note: "저장하는 순간 굳습니다 — 하루 뒤에도, 영어 사용자에게도 \"3일 전\"입니다."),
                .init(id: "c", label: "서버가 내려준 표시용 문자열을 그대로 쓴다",
                      screen: nil, isCorrect: false,
                      note: "표기를 서버가 정하면 기기의 언어·시간대 설정을 따를 수 없습니다."),
                .init(id: "d", label: "한국어와 영어 두 벌을 만들어 두고 골라 쓴다",
                      screen: nil, isCorrect: false,
                      note: "포맷터가 이미 모든 로케일을 알고 있습니다. 두 벌을 만들 이유가 없습니다."),
            ],
            explanation: "값과 표기를 한 문자열에 담지 않는 것 — 값은 앱이, 표기는 로케일이 정합니다.",
            sources: ["2.2.1", "8.1.6"],
            mistakeNumber: 47
        ),
    ]

    static var all: [LiveQuestion] { pickScreen + reason }

    static func questions(kind: LiveQuestion.Kind) -> [LiveQuestion] {
        kind == .pickScreen ? pickScreen : reason
    }
}
