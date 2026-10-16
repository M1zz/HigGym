import Foundation
import Testing
@testable import HigGym

/// 노트는 이 앱이 저장하는 유일한 콘텐츠다. 쓴 글이 사라지거나 "이어서 하기"가 엉뚱한 곳을 열면 안 된다.
@MainActor
struct NotebookStoreTests {
    private let storage = TestDefaults()
    private var first: Lesson { Lesson.all[0] }
    private var second: Lesson { Lesson.all[1] }

    @Test func 빈_글은_남기지_않는다() {
        let store = NotebookStore(defaults: storage.defaults)
        store.write(LessonNote(), for: first)
        #expect(store.notes.isEmpty)

        store.write(LessonNote(impression: "삭제 버튼이 너무 가까웠다"), for: first)
        #expect(store.note(for: first).impression == "삭제 버튼이 너무 가까웠다")

        // 다 지우면 항목도 사라진다.
        store.write(LessonNote(), for: first)
        #expect(store.notes[first.id] == nil)
    }

    @Test func 쓴_글과_멈춘_자리는_다시_열어도_남는다() {
        let store = NotebookStore(defaults: storage.defaults)
        store.write(LessonNote(impression: "느낀 점", takeaway: "배운 것"), for: second)
        store.markPosition(second, step: 3)

        let reopened = NotebookStore(defaults: storage.defaults)
        #expect(reopened.note(for: second).takeaway == "배운 것")
        #expect(reopened.resumeStep(for: second) == 3)
        #expect(reopened.next?.id == second.id)
    }

    @Test func 하다_만_레슨이_이어서_하기의_첫_자리다() {
        let store = NotebookStore(defaults: storage.defaults)
        #expect(store.next?.id == first.id)

        store.markPosition(second, step: 2)
        #expect(store.next?.id == second.id)
        // 멈춘 자리가 아닌 레슨은 처음 단계부터 연다.
        #expect(store.resumeStep(for: first) == 0)
    }

    @Test func 마친_레슨은_멈춘_자리를_지우고_다시_기억하지_않는다() {
        let store = NotebookStore(defaults: storage.defaults)
        store.markPosition(first, step: 4)
        store.complete(first)

        #expect(store.note(for: first).isCompleted)
        #expect(store.completedCount == 1)
        #expect(store.resumeLessonID == nil)
        #expect(store.resumeStep(for: first) == 0)

        store.markPosition(first, step: 2)
        #expect(store.resumeLessonID == nil)
        #expect(store.next?.id == second.id)
    }

    @Test func 전부_마치면_마지막_편을_가리킨다() {
        let store = NotebookStore(defaults: storage.defaults)
        for lesson in Lesson.all { store.complete(lesson) }
        #expect(store.completedCount == Lesson.all.count)
        #expect(store.next?.id == Lesson.all.last?.id)
    }

    @Test func 내보내기에는_쓴_레슨만_들어간다() {
        let store = NotebookStore(defaults: storage.defaults)
        store.write(LessonNote(takeaway: "되돌릴 수 없는 액션은 멀리 둔다"), for: second)

        let text = store.plainText
        #expect(text.contains("## \(second.number). \(second.title)"))
        #expect(text.contains("되돌릴 수 없는 액션은 멀리 둔다"))
        #expect(!text.contains("## \(first.number). \(first.title)"))
    }
}
