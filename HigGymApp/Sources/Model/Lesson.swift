import SwiftUI

/// 레슨 한 편 — 이 앱의 기본 단위.
///
/// 도감처럼 훑는 화면이 아니라 **다섯 단계를 순서대로 밟는 워크북**이다.
/// 써보고 → 느낀 것을 쓰고 → 이유를 확인하고 → 어긴 화면과 비교하고 → 배운 것을 남긴다.
/// 쓰는 단계가 있어야 남는다. 그래서 읽기만 하고 지나갈 수 없게 만들었다.
@MainActor
struct Lesson: Identifiable {
    /// 레슨이 세우는 화면이 어디서 오는가.
    enum Source {
        /// 표본 앱(노트)의 결정 하나를 뒤집는다.
        case sampleApp(NoteAppConfig.Knob)
        /// 표본 앱으로는 못 보여주는 것들 — 사진 위 가장자리 효과, 배지, 탭 같은 것.
        case pair(LessonPair)
    }

    let id: String
    let number: Int
    let source: Source
    let title: String
    /// 한 줄로 요약한 배울 것.
    let subtitle: String

    /// ① 써보기 — 손으로 해볼 과제. 짧고 분명해야 한다.
    let task: String
    /// ② 적기 — 무엇을 관찰했는지 묻는 질문.
    let question: String
    /// ②의 입력칸에 흐리게 깔리는 예시.
    let placeholder: String

    /// ③ 이유 확인에 실리는 세 문단.
    let decision: String
    let why: String
    let ifFlipped: String
    /// ④ 비교 — 무엇이 달라졌는지 한 줄.
    let diff: String

    let sources: [String]
    /// 회고가 있는 실수 편이면 그 번호 — 레슨 끝에서 이어 읽을 수 있게.
    var mistakeNumber: Int?

    /// 표본 앱의 결정에서 만드는 레슨 — 설명 세 문단은 그 결정에서 그대로 가져온다.
    init(
        id: String, number: Int, knob: NoteAppConfig.Knob,
        title: String, subtitle: String,
        task: String, question: String, placeholder: String, diff: String,
        mistakeNumber: Int? = nil
    ) {
        let decision = NoteAppDecision.of(knob)
        self.id = id
        self.number = number
        self.source = .sampleApp(knob)
        self.title = title
        self.subtitle = subtitle
        self.task = task
        self.question = question
        self.placeholder = placeholder
        self.decision = decision.decision
        self.why = decision.why
        self.ifFlipped = decision.ifFlipped
        self.diff = diff
        self.sources = decision.sources
        self.mistakeNumber = mistakeNumber
    }

    /// 표본 앱 밖의 화면 한 쌍으로 만드는 레슨.
    init(
        id: String, number: Int, pair: LessonPair,
        title: String, subtitle: String,
        task: String, question: String, placeholder: String,
        decision: String, why: String, ifFlipped: String, diff: String,
        sources: [String], mistakeNumber: Int?
    ) {
        self.id = id
        self.number = number
        self.source = .pair(pair)
        self.title = title
        self.subtitle = subtitle
        self.task = task
        self.question = question
        self.placeholder = placeholder
        self.decision = decision
        self.why = why
        self.ifFlipped = ifFlipped
        self.diff = diff
        self.sources = sources
        self.mistakeNumber = mistakeNumber
    }

    static let all: [Lesson] = [
        Lesson(
            id: "L1", number: 1, knob: .compose,
            title: "가장 자주 하는 일은 어디에 두는가",
            subtitle: "빈도와 높이는 반비례한다",
            task: "노트를 **세 개 만들어** 보세요. 한 손으로, 기기를 고쳐 쥐지 말고 해보세요.",
            question: "새 노트 버튼을 세 번 누르는 동안 엄지가 어떻게 움직였나요? 그 자리가 아니라 오른쪽 위였다면 어땠을까요?",
            placeholder: "예: 엄지를 거의 안 움직이고 눌렀다. 위에 있었으면 손을 바꿔 쥐어야 했을 것 같다.",
            diff: "새 노트 버튼이 하단 오른쪽 ↔ 상단 오른쪽으로만 옮겨졌습니다.",
            mistakeNumber: 99
        ),
        Lesson(
            id: "L2", number: 2, knob: .deletion,
            title: "되돌릴 수 없는 일은 어떻게 시키는가",
            subtitle: "도달성은 무해한 액션에만 적용한다",
            task: "노트를 **하나 지워** 보세요. 툴바에는 삭제가 없습니다 — 목록의 행을 왼쪽으로 밀어보세요.",
            question: "지우기까지 몇 단계를 거쳤나요? 실수로 지울 뻔한 순간이 있었나요?",
            placeholder: "예: 밀고, 빨간 버튼을 다시 눌러야 했다. 무엇을 지우는지도 분명했다.",
            diff: "삭제가 행 위(스와이프) ↔ 하단 바 단독 버튼으로 옮겨졌습니다.",
            mistakeNumber: 7
        ),
        Lesson(
            id: "L3", number: 3, knob: .grouping,
            title: "한 캡슐에 묶는다는 것의 뜻",
            subtitle: "묶음은 정리가 아니라 선언이다",
            task: "오른쪽 위를 보세요. 지금 그 자리에는 **편집 하나**뿐입니다. 눌러서 편집 모드에 들어갔다 나와보세요.",
            question: "상단에 삭제·정렬이 함께 있었다면, 편집을 누르려다 무엇을 누를 뻔했을까요?",
            placeholder: "예: 세 개가 붙어 있으면 아이콘을 하나씩 확인하지 않고 손이 먼저 갈 것 같다.",
            diff: "상단이 확정 액션 하나 ↔ 삭제·정렬·편집 한 캡슐로 바뀌었습니다.",
            mistakeNumber: 3
        ),
        Lesson(
            id: "L4", number: 4, knob: .title,
            title: "액션은 어디에 붙어야 하는가",
            subtitle: "대상이 보이면 액션은 그 위에",
            task: "**제목 \"노트\"를 눌러** 폴더를 업무 → 개인으로 바꿔보세요.",
            question: "폴더를 바꾸는 버튼을 어디서 찾았나요? 찾기까지 헤맸다면 그 이유는 무엇일까요?",
            placeholder: "예: 처음엔 툴바를 봤다. 제목에 ⌄가 있는 걸 보고 눌렀다.",
            diff: "폴더 전환이 제목 메뉴 ↔ 왼쪽 위 별도 버튼으로 옮겨졌습니다.",
            mistakeNumber: 100
        ),
        Lesson(
            id: "L5", number: 5, knob: .search,
            title: "자주 여는 입구는 어디에 두는가",
            subtitle: "닿기 쉬운 자리 · 안 쓸 때는 비켜 있기",
            task: "**검색으로 \"운송장\"을 찾아** 보세요. 그다음 검색을 비우고 목록으로 돌아와 보세요.",
            question: "검색을 열고 닫는 동안 손이 어디까지 올라갔나요? 검색을 안 쓸 때 그 자리는 무엇을 하고 있었나요?",
            placeholder: "예: 아래에 있어서 엄지로 바로 닿았다. 안 쓸 때는 캡슐 하나만 차지했다.",
            diff: "검색이 하단 캡슐 ↔ 항상 펼쳐진 상단 서랍으로 바뀌었습니다.",
            mistakeNumber: 30
        ),
        Lesson(
            id: "L6", number: 6, knob: .date,
            title: "값과 표기를 누가 갖는가",
            subtitle: "값은 앱이, 표기는 로케일이",
            task: "목록의 **수정 시각**을 보세요. \"3일 전\"처럼 나옵니다. 노트를 하나 새로 만들어 방금 만든 것의 시각도 확인해 보세요.",
            question: "이 앱이 영어 기기에서 열린다면 이 시각은 어떻게 보여야 할까요? 지금 방식이면 가능할까요?",
            placeholder: "예: 영어면 \"3 days ago\"로 나와야 한다. 문자열로 저장했다면 못 바꿀 것 같다.",
            diff: "두 화면 모두 **영어(en_US) 기기**입니다. 표기를 로케일에 맡긴 쪽 ↔ 문자열로 굳힌 쪽.",
            mistakeNumber: 47
        ),
        Lesson(
            id: "L7", number: 7, knob: .selection,
            title: "읽기 전용이라는 말의 뜻",
            subtitle: "옮겨 적을 값에는 길을 낸다",
            task: "**운송장 번호 노트를 열고** 본문을 길게 눌러보세요. 번호를 복사해 보세요.",
            question: "이 번호를 다른 앱에 넣어야 한다면, 복사가 막혀 있을 때 사용자는 무엇을 하게 될까요?",
            placeholder: "예: 화면을 보면서 손으로 옮겨 적을 것 같다. 열여섯 자리라 틀리기 쉽다.",
            diff: "본문 선택·복사가 열린 쪽 ↔ 막힌 쪽입니다.",
            mistakeNumber: 46
        ),
        Lesson(
            id: "L8", number: 8, knob: .editorExit,
            title: "덮는 화면에는 출구가 필요하다",
            subtitle: "전체 화면 커버는 쓸어내려 닫히지 않는다",
            task: "**새 노트를 열고** 아래로 쓸어내려 닫아보세요. 그다음 취소로 나와보세요.",
            question: "쓸어내렸을 때 무슨 일이 있었나요? 취소 버튼이 없었다면 어떻게 했을까요?",
            placeholder: "예: 쓸어내려도 그대로였다. 버튼이 없었으면 앱이 멈춘 줄 알았을 것 같다.",
            diff: "편집기에 취소·완료가 있는 쪽 ↔ 출구가 없는 쪽입니다.",
            mistakeNumber: 81
        ),
        Lesson(
            id: "L9", number: 9, pair: .overflowOrder,
            title: "무엇이 접혀도 되는가",
            subtitle: "선언 순서가 곧 우선순위다",
            task: "이 화면에서 **저장을 세 번** 눌러보세요. 저장 버튼을 먼저 찾아야 합니다.",
            question: "저장을 찾는 데 몇 초 걸렸나요? 어디에 있었나요? 하루에 스무 번 저장한다면 이 배치가 어떨까요?",
            placeholder: "예: ⋯ 안에 있어서 두 번 눌러야 했다. 자주 쓰는 건데 한 단계가 더 있다.",
            decision: "자주 쓰는 저장을 툴바 앞쪽에 두고, 가끔 쓰는 것들을 뒤로 보냈다.",
            why: "폭이 모자라면 시스템은 **뒤쪽부터** ⋯ 안으로 접는다. 그러니 코드에 적는 순서가 곧 우선순위 선언이다. 접기를 막을 게 아니라 무엇이 접혀도 되는지를 정하는 일이다.",
            ifFlipped: "만든 순서대로 적으면 나중에 추가된 핵심 기능이 접힌다. 큰 기기에서는 다 보이므로 개발 중에는 만나지도 못한다.",
            diff: "아이템 개수는 같습니다. **순서만** 다릅니다 — 저장이 앞이냐 뒤냐.",
            sources: ["1.1.7"], mistakeNumber: 11
        ),
        Lesson(
            id: "L10", number: 10, pair: .scrollEdge,
            title: "최악의 배경에서 확인한다",
            subtitle: "가장자리 효과는 장식이 아니라 안전장치",
            task: "사진 격자를 **천천히 스크롤**해 보세요. **흰 사진**이 상단 바를 지나는 순간을 노려 보세요.",
            question: "흰 사진이 지나갈 때 상단의 선택·공유 버튼은 어떻게 보였나요? 어두운 사진일 때와 달랐나요?",
            placeholder: "예: 어두운 사진에선 잘 보였는데 흰 사진에선 글자가 흐려졌다.",
            decision: "콘텐츠와 바 사이에 hard 경계를 둬서 대비를 배경에 맡기지 않았다.",
            why: "가장자리 효과는 콘텐츠가 유리 아래로 지나가는 순간을 위한 **가독성 장치**다. 판정은 우리가 고른 샘플이 아니라 사용자가 가진 가장 밝은 사진에서 한다.",
            ifFlipped: "어두운 샘플 한 장으로 확인하고 끄면, 흰 사진이 지나는 몇 초 동안 컨트롤이 실제로 사라진다. 재현이 안 되는 게 아니라 그 조건을 안 만들어 본 것이다.",
            diff: "`.hard` 경계 ↔ 효과 끔(`scrollEdgeEffectHidden`). 사진과 배치는 같습니다.",
            sources: ["1.3.4", "8.1.4"], mistakeNumber: 29
        ),
        Lesson(
            id: "L11", number: 11, pair: .clampedText,
            title: "글자가 커져도 값이 남는가",
            subtitle: "잘려도 뜻이 통하는가로 도구를 고른다",
            task: "이 화면은 **접근성 큰 글씨** 설정이 켜진 상태입니다. 배송지와 주문번호를 **소리 내어 읽어** 보세요.",
            question: "읽을 수 있었나요? 주소의 어디까지 남아 있었나요? 이 화면으로 배송지를 확인하고 결제할 수 있을까요?",
            placeholder: "예: 앞부분만 남고 동·호수가 사라졌다. 이대로면 잘못된 주소인지 알 수 없다.",
            decision: "잘리면 안 되는 값에는 줄 수 범위를 줘서 카드가 길어지게 뒀다.",
            why: "`lineLimit(1)`과 `minimumScaleFactor`는 둘 다 넘침을 막는 도구지만 **함께 걸면 서로를 가린다** — 축소가 먼저 일해 글자를 줄이고, 그래도 안 들어가면 한 줄 제한이 나머지를 자른다. 남는 건 첫 어절뿐이다.",
            ifFlipped: "기본 글자 크기에서는 멀쩡해 보인다. 접근성 최대 설정에서 한 번 열어보지 않으면 배송 사고가 나서야 알게 된다.",
            diff: "`lineLimit(1) + minimumScaleFactor(0.4)` ↔ `lineLimit(2...3)`. 값도 글자 크기도 같습니다.",
            sources: ["2.1.1", "8.1.5"], mistakeNumber: 38
        ),
        Lesson(
            id: "L12", number: 12, pair: .stickyBadge,
            title: "배지는 무엇을 약속하는가",
            subtitle: "셀 수 있고 줄어드는 것에만 붙인다",
            task: "**소식 탭**에 들어가 새 소식을 **전부 읽음으로 표시**해 보세요. 그다음 배지를 확인하세요.",
            question: "다 읽은 뒤 배지는 어떻게 됐나요? 이 배지를 며칠 보고 나면 어떤 습관이 생길까요?",
            placeholder: "예: 다 읽었는데도 1이 그대로였다. 며칠 지나면 빨간 점을 아예 안 볼 것 같다.",
            decision: "배지를 실제 안 읽은 소식 수에 연결하고, 0이 되면 사라지게 뒀다.",
            why: "배지는 \"처리할 것이 남았다\"는 **약속**이다. 사용자는 그 약속을 믿고 들어왔다가 처리할 게 없다는 걸 확인한다. 두세 번 반복되면 학습이 끝난다.",
            ifFlipped: "그때 잃는 건 이 배지 하나가 아니라 **그 앱의 모든 배지**다. 나중에 진짜 급한 알림에 붙여도 아무도 보지 않는다.",
            diff: "실제 미확인 수 ↔ 고정된 1. 읽어도 줄지 않는 쪽이 어긴 화면입니다.",
            sources: ["3.1.3"], mistakeNumber: 52
        ),
        Lesson(
            id: "L13", number: 13, pair: .fakeTab,
            title: "탭은 무엇을 약속하는가",
            subtitle: "탭은 목적지, 액션은 툴바",
            task: "가운데 **작성 탭**을 눌러보세요. 시트를 닫고 나서 지금 어느 탭에 있는지 확인하세요.",
            question: "작성 탭을 눌렀을 때 어디로 갔나요? 시트를 닫은 뒤 선택된 탭은 어디였나요? 그게 자연스러웠나요?",
            placeholder: "예: 시트만 뜨고 탭은 홈으로 돌아왔다. 내가 뭘 잘못 눌렀나 싶었다.",
            decision: "작성을 탭이 아니라 하단 툴바 버튼으로 두고, 탭에는 목적지만 남겼다.",
            why: "탭바는 \"이 앱이 어떤 세계로 이루어져 있는가\"를 말하는 지도다. 탭 하나하나가 **목적지**라는 약속이라, 이동하지 않는 탭은 그 약속을 깬다.",
            ifFlipped: "선택 상태가 원래 탭으로 되돌아가는 순간 사용자는 자기가 뭘 잘못 눌렀다고 느낀다. 가장 좋은 자리를 쓰고 신뢰를 잃는다.",
            diff: "작성이 하단 툴바 버튼 ↔ 가짜 탭. 탭 개수도 함께 달라집니다.",
            sources: ["3.4.4"], mistakeNumber: 68
        ),
    ]

    static func lesson(_ id: String) -> Lesson? { all.first { $0.id == id } }
}

// MARK: - 학습 노트

/// 레슨마다 학습자가 남긴 글. 이 앱이 저장하는 유일한 콘텐츠다.
struct LessonNote: Codable, Hashable, Sendable {
    /// ② 단계에서 쓴 느낀 점.
    var impression: String = ""
    /// ⑤ 단계에서 쓴 배운 것.
    var takeaway: String = ""
    var completedAt: Date?

    var isEmpty: Bool { impression.isEmpty && takeaway.isEmpty }
    var isCompleted: Bool { completedAt != nil }
}

/// 학습자가 쓴 글과 진도를 들고 있는 저장소.
@MainActor
@Observable
final class NotebookStore {
    private enum Key {
        static let notes = "higgym.lessonNotes"
    }

    private(set) var notes: [String: LessonNote] = [:]
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if let data = defaults.data(forKey: Key.notes),
           let decoded = try? JSONDecoder().decode([String: LessonNote].self, from: data) {
            notes = decoded
        }
    }

    func note(for lesson: Lesson) -> LessonNote { notes[lesson.id] ?? LessonNote() }

    func write(_ note: LessonNote, for lesson: Lesson) {
        notes[lesson.id] = note
        persist()
    }

    func complete(_ lesson: Lesson) {
        var note = note(for: lesson)
        note.completedAt = Date()
        write(note, for: lesson)
    }

    func reset(_ lesson: Lesson) {
        notes[lesson.id] = nil
        persist()
    }

    var completedCount: Int { Lesson.all.filter { note(for: $0).isCompleted }.count }

    /// 마지막으로 끝낸 다음 편 — 코스 화면의 "이어서 하기".
    var next: Lesson? {
        Lesson.all.first { !note(for: $0).isCompleted } ?? Lesson.all.last
    }

    /// 학습 노트를 통째로 복사할 수 있게 — 남긴 글은 앱 밖으로 나갈 수 있어야 한다.
    var plainText: String {
        var lines: [String] = ["# HigGym 학습 노트", ""]
        for lesson in Lesson.all {
            let note = note(for: lesson)
            guard !note.isEmpty else { continue }
            lines.append("## \(lesson.number). \(lesson.title)")
            if !note.impression.isEmpty {
                lines.append("**써보고 느낀 것**")
                lines.append(note.impression)
            }
            if !note.takeaway.isEmpty {
                lines.append("**배운 것**")
                lines.append(note.takeaway)
            }
            lines.append("근거 · " + lesson.sources.joined(separator: " · "))
            lines.append("")
        }
        return lines.joined(separator: "\n")
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(notes) else { return }
        defaults.set(data, forKey: Key.notes)
    }
}
