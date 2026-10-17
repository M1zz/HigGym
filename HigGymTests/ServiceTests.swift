import Foundation
import Testing
import LeeoKit
@testable import HigGym

/// LeeoKit 계약 · 깔때기 · 새 기능 안내 · 콘텐츠 번역처럼 화면 밖에서 조용히 틀어지는 것들.
@MainActor
struct ServiceTests {
    private let storage = TestDefaults()

    /// 부트스트랩의 DEBUG 감사와 별개로, 출시해도 되는 계약인지 시험이 지킨다.
    @Test func 계약은_출시할_수_있는_상태다() {
        let report = LeeoPreflight.audit(HigGymSpec.self)
        #expect(report.isReleasable, "\(report)")
    }

    @Test func 깔때기_단계는_처음_도달할_때_한_번만_보낸다() {
        let sink = RecordingAnalytics()
        #expect(HigGymFunnel.reach(.lessonCompleted, defaults: storage.defaults, analytics: sink))
        #expect(!HigGymFunnel.reach(.lessonCompleted, defaults: storage.defaults, analytics: sink))
        #expect(HigGymFunnel.reach(.notesExported, defaults: storage.defaults, analytics: sink))
        #expect(sink.names == ["funnel_3_lesson_completed", "funnel_4_notes_exported"])
    }

    @Test func 새_기능_안내는_처음_온_사람에게_뜨지_않는다() {
        #expect(!WhatsNewContent.shouldPresent(isNewcomer: true, defaults: storage.defaults))
        // 처음 온 사람은 본 것으로 표시돼, 다음 실행에도 뜨지 않는다.
        #expect(!WhatsNewContent.shouldPresent(isNewcomer: false, defaults: storage.defaults))
    }

    @Test func 새_기능_안내는_쓰던_사람에게_한_번만_뜬다() {
        #expect(WhatsNewContent.shouldPresent(isNewcomer: false, defaults: storage.defaults))
        WhatsNewContent.markSeen(defaults: storage.defaults)
        #expect(!WhatsNewContent.shouldPresent(isNewcomer: false, defaults: storage.defaults))
    }

    @Test func 세이프_모드는_멈춘_레슨을_첫_단계부터_연다() {
        let store = NotebookStore(defaults: storage.defaults)
        let lesson = Lesson.all[2]
        store.write(LessonNote(impression: "느낀 점"), for: lesson)
        store.markPosition(lesson, step: 3)
        store.rewindResumeToFirstStep()
        #expect(store.resumeLessonID == lesson.id)
        #expect(store.resumeStep(for: lesson) == 0)
        #expect(store.note(for: lesson).impression == "느낀 점")
    }

    /// 콘텐츠(항목 · 실수 · 원칙)의 한국어 문장마다 영어 · 일본어 번역이 있어야 한다.
    /// 하나라도 빠지면 그 언어 사용자에게 한국어가 그대로 보인다.
    @Test(arguments: ["en", "ja"])
    func 콘텐츠의_모든_문장에_번역이_있다(language: String) throws {
        let app = Bundle(for: NotebookStore.self)
        let path = try #require(app.path(forResource: language, ofType: "lproj"))
        let localized = try #require(Bundle(path: path))
        for resource in ["entries", "mistakes"] {
            let url = try #require(app.url(forResource: resource, withExtension: "json"))
            let data = try ContentLocalization.localize(try Data(contentsOf: url), bundle: localized)
            let text = try #require(String(data: data, encoding: .utf8))
            let leaked = text.unicodeScalars.filter { (0xAC00...0xD7A3).contains($0.value) }.count
            #expect(leaked == 0, "\(language) \(resource).json 에 번역 안 된 한글 \(leaked)자")
        }
    }
}

private final class RecordingAnalytics: LeeoAnalytics, @unchecked Sendable {
    private(set) var names: [String] = []
    func track(_ event: LeeoEvent) { names.append(event.name) }
}
