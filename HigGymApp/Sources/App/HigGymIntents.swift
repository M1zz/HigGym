//
//  HigGymIntents.swift
//  HigGym
//
//  단축어 · Spotlight · Siri 에서 여는 앱의 핵심 동작 두 가지.
//  인텐트는 앱을 앞으로 띄우고 요청만 IntentInbox 에 남긴다. 화면 이동은 RootView 가 한다
//  (인텐트가 화면 상태를 직접 만지면 앱이 막 켜지는 중일 때 요청이 사라진다).
//

import AppIntents
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
