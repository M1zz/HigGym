import Foundation
import Testing
@testable import HigGym

/// 정답·오답 기록이 오답 복습과 챕터 숙련도의 근거다.
@MainActor
struct ProgressStoreTests {
    private let storage = TestDefaults()

    private var question: Question {
        get throws { try #require(QuizBank.shared.questions.first) }
    }

    @Test func 최근_결과가_이전_결과를_덮는다() throws {
        let store = ProgressStore(defaults: storage.defaults)
        let q = try question

        store.record(question: q, isCorrect: false)
        #expect(store.wrongIDs.contains(q.id))
        #expect(!store.correctIDs.contains(q.id))

        store.record(question: q, isCorrect: true)
        #expect(store.correctIDs.contains(q.id))
        #expect(!store.wrongIDs.contains(q.id))
        #expect(store.answeredCount == 2)
    }

    @Test func 정답률은_푼_횟수를_넘지_않는다() throws {
        let store = ProgressStore(defaults: storage.defaults)
        #expect(store.accuracy == 0)

        let q = try question
        store.record(question: q, isCorrect: true)
        #expect(store.accuracy == 1)

        store.record(question: q, isCorrect: true)
        #expect(store.accuracy == 0.5)
    }

    @Test func 기록은_다시_열어도_남고_초기화하면_지워진다() throws {
        let q = try question
        let store = ProgressStore(defaults: storage.defaults)
        store.record(question: q, isCorrect: false)
        store.markLabVisited(.toolbar)

        let reopened = ProgressStore(defaults: storage.defaults)
        #expect(reopened.wrongIDs == [q.id])
        #expect(reopened.answeredCount == 1)
        #expect(reopened.visitedLabs == [LabID.toolbar.rawValue])

        reopened.resetAll()
        let afterReset = ProgressStore(defaults: storage.defaults)
        #expect(afterReset.wrongIDs.isEmpty)
        #expect(afterReset.answeredCount == 0)
    }

    @Test func 실수_체크는_눌러서_켜고_끈다() {
        let store = ProgressStore(defaults: storage.defaults)
        store.toggleMistake("m001")
        #expect(store.checkedMistakes == ["m001"])
        #expect(ProgressStore(defaults: storage.defaults).checkedMistakes == ["m001"])

        store.toggleMistake("m001")
        #expect(store.checkedMistakes.isEmpty)
    }

    @Test func 화면_퀴즈는_다시_풀면_최근_결과만_남는다() {
        let store = ProgressStore(defaults: storage.defaults)
        store.recordLive("live-1", correct: true)
        store.recordLive("live-1", correct: false)
        #expect(store.liveAnsweredIDs == ["live-1"])
        #expect(store.liveCorrectIDs.isEmpty)
        // 화면 퀴즈는 문장 퀴즈 성적과 섞이지 않는다.
        #expect(store.answeredCount == 0)
    }
}

/// 한 판의 퀴즈 진행 규칙.
@MainActor
struct QuizSessionTests {
    private let storage = TestDefaults()

    @Test func 오답_복습은_틀린_문제만_낸다() throws {
        let store = ProgressStore(defaults: storage.defaults)
        let questions = Array(QuizBank.shared.questions.prefix(3))
        try #require(questions.count == 3)
        store.record(question: questions[0], isCorrect: false)
        store.record(question: questions[1], isCorrect: true)

        let session = QuizSession(mode: .review, progress: store)
        #expect(session.questions.map(\.id) == [questions[0].id])
    }

    @Test func 한_문제에는_한_번만_답한다() throws {
        let store = ProgressStore(defaults: storage.defaults)
        let session = QuizSession(mode: .mixed(4), progress: store)
        let current = try #require(session.current)

        // 답하기 전에는 다음으로 넘어가지 않는다.
        session.advance()
        #expect(session.current?.id == current.id)

        session.select(current.answerIndex, progress: store)
        session.select((current.answerIndex + 1) % current.options.count, progress: store)
        #expect(session.results.count == 1)
        #expect(session.correctCount == 1)
        #expect(store.answeredCount == 1)

        session.advance()
        #expect(!session.isAnswered)
        #expect(session.progress == 0.25)
    }

    @Test func 랜덤_훈련은_요청한_수만큼_낸다() {
        let session = QuizSession(mode: .mixed(10))
        #expect(session.questions.count == 10)
        #expect(Set(session.questions.map(\.id)).count == 10)
    }
}
