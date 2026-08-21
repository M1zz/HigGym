import SwiftUI

/// 레슨 한 편 — 이 앱의 기본 단위.
///
/// 도감처럼 훑는 화면이 아니라 **다섯 단계를 순서대로 밟는 워크북**이다.
/// 써보고 → 느낀 것을 쓰고 → 이유를 확인하고 → 어긴 화면과 비교하고 → 배운 것을 남긴다.
/// 쓰는 단계가 있어야 남는다. 그래서 읽기만 하고 지나갈 수 없게 만들었다.
@MainActor
struct Lesson: Identifiable {
    let id: String
    let number: Int
    /// 이 레슨이 다루는 표본 앱의 결정.
    let knob: NoteAppConfig.Knob
    let title: String
    /// 한 줄로 요약한 배울 것.
    let subtitle: String

    /// ① 써보기 — 손으로 해볼 과제. 짧고 분명해야 한다.
    let task: String
    /// ② 적기 — 무엇을 관찰했는지 묻는 질문.
    let question: String
    /// ②의 입력칸에 흐리게 깔리는 예시.
    let placeholder: String

    /// ④ 비교 — 무엇이 달라졌는지 한 줄.
    let diff: String

    var decision: NoteAppDecision { NoteAppDecision.of(knob) }

    static let all: [Lesson] = [
        Lesson(
            id: "L1", number: 1, knob: .compose,
            title: "가장 자주 하는 일은 어디에 두는가",
            subtitle: "빈도와 높이는 반비례한다",
            task: "노트를 **세 개 만들어** 보세요. 한 손으로, 기기를 고쳐 쥐지 말고 해보세요.",
            question: "새 노트 버튼을 세 번 누르는 동안 엄지가 어떻게 움직였나요? 그 자리가 아니라 오른쪽 위였다면 어땠을까요?",
            placeholder: "예: 엄지를 거의 안 움직이고 눌렀다. 위에 있었으면 손을 바꿔 쥐어야 했을 것 같다.",
            diff: "새 노트 버튼이 하단 오른쪽 ↔ 상단 오른쪽으로만 옮겨졌습니다."
        ),
        Lesson(
            id: "L2", number: 2, knob: .deletion,
            title: "되돌릴 수 없는 일은 어떻게 시키는가",
            subtitle: "도달성은 무해한 액션에만 적용한다",
            task: "노트를 **하나 지워** 보세요. 툴바에는 삭제가 없습니다 — 목록의 행을 왼쪽으로 밀어보세요.",
            question: "지우기까지 몇 단계를 거쳤나요? 실수로 지울 뻔한 순간이 있었나요?",
            placeholder: "예: 밀고, 빨간 버튼을 다시 눌러야 했다. 무엇을 지우는지도 분명했다.",
            diff: "삭제가 행 위(스와이프) ↔ 하단 바 단독 버튼으로 옮겨졌습니다."
        ),
        Lesson(
            id: "L3", number: 3, knob: .grouping,
            title: "한 캡슐에 묶는다는 것의 뜻",
            subtitle: "묶음은 정리가 아니라 선언이다",
            task: "오른쪽 위를 보세요. 지금 그 자리에는 **편집 하나**뿐입니다. 눌러서 편집 모드에 들어갔다 나와보세요.",
            question: "상단에 삭제·정렬이 함께 있었다면, 편집을 누르려다 무엇을 누를 뻔했을까요?",
            placeholder: "예: 세 개가 붙어 있으면 아이콘을 하나씩 확인하지 않고 손이 먼저 갈 것 같다.",
            diff: "상단이 확정 액션 하나 ↔ 삭제·정렬·편집 한 캡슐로 바뀌었습니다."
        ),
        Lesson(
            id: "L4", number: 4, knob: .title,
            title: "액션은 어디에 붙어야 하는가",
            subtitle: "대상이 보이면 액션은 그 위에",
            task: "**제목 \"노트\"를 눌러** 폴더를 업무 → 개인으로 바꿔보세요.",
            question: "폴더를 바꾸는 버튼을 어디서 찾았나요? 찾기까지 헤맸다면 그 이유는 무엇일까요?",
            placeholder: "예: 처음엔 툴바를 봤다. 제목에 ⌄가 있는 걸 보고 눌렀다.",
            diff: "폴더 전환이 제목 메뉴 ↔ 왼쪽 위 별도 버튼으로 옮겨졌습니다."
        ),
        Lesson(
            id: "L5", number: 5, knob: .search,
            title: "자주 여는 입구는 어디에 두는가",
            subtitle: "닿기 쉬운 자리 · 안 쓸 때는 비켜 있기",
            task: "**검색으로 \"운송장\"을 찾아** 보세요. 그다음 검색을 비우고 목록으로 돌아와 보세요.",
            question: "검색을 열고 닫는 동안 손이 어디까지 올라갔나요? 검색을 안 쓸 때 그 자리는 무엇을 하고 있었나요?",
            placeholder: "예: 아래에 있어서 엄지로 바로 닿았다. 안 쓸 때는 캡슐 하나만 차지했다.",
            diff: "검색이 하단 캡슐 ↔ 항상 펼쳐진 상단 서랍으로 바뀌었습니다."
        ),
        Lesson(
            id: "L6", number: 6, knob: .date,
            title: "값과 표기를 누가 갖는가",
            subtitle: "값은 앱이, 표기는 로케일이",
            task: "목록의 **수정 시각**을 보세요. \"3일 전\"처럼 나옵니다. 노트를 하나 새로 만들어 방금 만든 것의 시각도 확인해 보세요.",
            question: "이 앱이 영어 기기에서 열린다면 이 시각은 어떻게 보여야 할까요? 지금 방식이면 가능할까요?",
            placeholder: "예: 영어면 \"3 days ago\"로 나와야 한다. 문자열로 저장했다면 못 바꿀 것 같다.",
            diff: "두 화면 모두 **영어(en_US) 기기**입니다. 표기를 로케일에 맡긴 쪽 ↔ 문자열로 굳힌 쪽."
        ),
        Lesson(
            id: "L7", number: 7, knob: .selection,
            title: "읽기 전용이라는 말의 뜻",
            subtitle: "옮겨 적을 값에는 길을 낸다",
            task: "**운송장 번호 노트를 열고** 본문을 길게 눌러보세요. 번호를 복사해 보세요.",
            question: "이 번호를 다른 앱에 넣어야 한다면, 복사가 막혀 있을 때 사용자는 무엇을 하게 될까요?",
            placeholder: "예: 화면을 보면서 손으로 옮겨 적을 것 같다. 열여섯 자리라 틀리기 쉽다.",
            diff: "본문 선택·복사가 열린 쪽 ↔ 막힌 쪽입니다."
        ),
        Lesson(
            id: "L8", number: 8, knob: .editorExit,
            title: "덮는 화면에는 출구가 필요하다",
            subtitle: "전체 화면 커버는 쓸어내려 닫히지 않는다",
            task: "**새 노트를 열고** 아래로 쓸어내려 닫아보세요. 그다음 취소로 나와보세요.",
            question: "쓸어내렸을 때 무슨 일이 있었나요? 취소 버튼이 없었다면 어떻게 했을까요?",
            placeholder: "예: 쓸어내려도 그대로였다. 버튼이 없었으면 앱이 멈춘 줄 알았을 것 같다.",
            diff: "편집기에 취소·완료가 있는 쪽 ↔ 출구가 없는 쪽입니다."
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
            lines.append("근거 · " + lesson.decision.sources.joined(separator: " · "))
            lines.append("")
        }
        return lines.joined(separator: "\n")
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(notes) else { return }
        defaults.set(data, forKey: Key.notes)
    }
}
