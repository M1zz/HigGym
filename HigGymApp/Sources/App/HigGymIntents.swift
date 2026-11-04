//
//  HigGymIntents.swift
//  HigGym
//
//  단축어 · Spotlight · Siri 에서 여는 앱의 핵심 동작 두 가지.
//  인텐트는 앱을 앞으로 띄우고 요청만 IntentInbox 에 남긴다. 화면 이동은 RootView 가 한다
//  (인텐트가 화면 상태를 직접 만지면 앱이 막 켜지는 중일 때 요청이 사라진다).
//  레슨마다 쓴 노트는 Spotlight 에 싣는다. 누르면 노트 탭이 열린다.
//

import AppIntents
import CoreSpotlight
import Observation

/// 단축어가 남긴 요청을 화면이 꺼내 갈 때까지 들고 있는 우편함.
@MainActor
@Observable
final class IntentInbox {
    enum Request: Equatable {
        /// 멈춘 레슨(없으면 다음 편)을 바로 연다.
        case resumeLesson
        /// 학습 노트 탭을 연다.
        case openNotebook
    }

    static let shared = IntentInbox()
    var pending: Request?
}

struct ResumeLessonIntent: AppIntent {
    static let title: LocalizedStringResource = "이어서 학습하기"
    static let description = IntentDescription("멈춘 레슨을 그 단계부터 엽니다. 다 마친 편이면 다음 편을 엽니다.")
    static let supportedModes: IntentModes = .foreground

    @MainActor
    func perform() async throws -> some IntentResult {
        IntentInbox.shared.pending = .resumeLesson
        return .result()
    }
}

struct OpenNotebookIntent: AppIntent {
    static let title: LocalizedStringResource = "학습 노트 열기"
    static let description = IntentDescription("레슨에서 직접 쓴 글을 모아 둔 노트를 엽니다.")
    static let supportedModes: IntentModes = .foreground

    @MainActor
    func perform() async throws -> some IntentResult {
        IntentInbox.shared.pending = .openNotebook
        return .result()
    }
}

// MARK: - 노트

/// 레슨 하나에 학습자가 쓴 노트. id 는 레슨 id 다.
struct NoteEntity: AppEntity, IndexedEntity {
    static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "학습 노트")
    static let defaultQuery = NoteQuery()

    let id: String
    let lessonTitle: String
    let text: String

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(lessonTitle)", subtitle: "\(String(text.prefix(80)))")
    }

    var attributeSet: CSSearchableItemAttributeSet {
        let set = defaultAttributeSet
        set.textContent = text
        return set
    }

    /// 글을 쓴 레슨만, 레슨 순서대로.
    @MainActor
    static func written() -> [NoteEntity] {
        let notebook = NotebookStore()
        return Lesson.all.compactMap { lesson in
            let note = notebook.note(for: lesson)
            guard !note.isEmpty else { return nil }
            let text = [note.impression, note.takeaway].filter { !$0.isEmpty }.joined(separator: "\n")
            return NoteEntity(id: lesson.id, lessonTitle: "\(lesson.number). \(lesson.title)", text: text)
        }
    }
}

struct NoteQuery: EntityStringQuery {
    func entities(for identifiers: [String]) async throws -> [NoteEntity] {
        let wanted = Set(identifiers)
        return await NoteEntity.written().filter { wanted.contains($0.id) }
    }

    func entities(matching string: String) async throws -> [NoteEntity] {
        await NoteEntity.written().filter {
            $0.lessonTitle.localizedCaseInsensitiveContains(string) || $0.text.localizedCaseInsensitiveContains(string)
        }
    }

    func suggestedEntities() async throws -> [NoteEntity] {
        await NoteEntity.written()
    }

    /// Spotlight 에 싣는 노트를 지금 것에 맞춘다. 앱을 열 때와 뒤로 보낼 때 부른다.
    static func reindex() async {
        let index = CSSearchableIndex.default()
        try? await index.deleteAppEntities(ofType: NoteEntity.self)
        try? await index.indexAppEntities(await NoteEntity.written())
    }
}

/// 노트를 연다. Spotlight · Siri 결과를 누르면 여기로 온다.
struct OpenNoteIntent: OpenIntent {
    static let title: LocalizedStringResource = "노트 열기"
    static let description = IntentDescription("레슨에서 쓴 노트를 노트 탭에서 엽니다.")
    static let supportedModes: IntentModes = .foreground

    @Parameter(title: "레슨 노트", description: "열어 볼 레슨의 노트")
    var target: NoteEntity

    init() {}

    @MainActor
    func perform() async throws -> some IntentResult {
        IntentInbox.shared.pending = .openNotebook
        return .result()
    }
}

// MARK: - Siri 문구

struct HigGymShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: ResumeLessonIntent(),
            phrases: [
                "\(.applicationName)에서 이어서 학습하기",
                "\(.applicationName) 이어서 하기",
            ],
            shortTitle: "이어서 학습하기",
            systemImageName: "play.fill"
        )
        AppShortcut(
            intent: OpenNotebookIntent(),
            phrases: [
                "\(.applicationName) 노트 열기",
                "\(.applicationName)에서 학습 노트 보기",
            ],
            shortTitle: "학습 노트",
            systemImageName: "text.book.closed.fill"
        )
    }
}
