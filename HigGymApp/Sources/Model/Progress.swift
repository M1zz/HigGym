import Foundation
import Observation

/// 맞힌·틀린 문제를 기억해 오답 복습과 챕터별 숙련도를 만든다.
@MainActor
@Observable
final class ProgressStore {
    private enum Key {
        static let correct = "higgym.correctIDs"
        static let wrong = "higgym.wrongIDs"
        static let answered = "higgym.answeredCount"
        static let visitedLabs = "higgym.visitedLabs"
        static let checkedMistakes = "higgym.checkedMistakes"
    }

    private(set) var correctIDs: Set<String>
    private(set) var wrongIDs: Set<String>
    private(set) var answeredCount: Int
    private(set) var visitedLabs: Set<String>
    /// "이건 나도 해봤다"고 체크한 실수들 — 100편을 훑는 진행도의 근거.
    private(set) var checkedMistakes: Set<String>

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        correctIDs = Set(defaults.stringArray(forKey: Key.correct) ?? [])
        wrongIDs = Set(defaults.stringArray(forKey: Key.wrong) ?? [])
        answeredCount = defaults.integer(forKey: Key.answered)
        visitedLabs = Set(defaults.stringArray(forKey: Key.visitedLabs) ?? [])
        checkedMistakes = Set(defaults.stringArray(forKey: Key.checkedMistakes) ?? [])
    }

    var correctCount: Int { correctIDs.count }

    var accuracy: Double {
        answeredCount == 0 ? 0 : Double(correctIDs.count) / Double(max(answeredCount, correctIDs.count))
    }

    func record(question: Question, isCorrect: Bool) {
        answeredCount += 1
        if isCorrect {
            correctIDs.insert(question.id)
            wrongIDs.remove(question.id)
        } else {
            wrongIDs.insert(question.id)
            correctIDs.remove(question.id)
        }
        persist()
    }

    func markLabVisited(_ lab: LabID) {
        guard !visitedLabs.contains(lab.rawValue) else { return }
        visitedLabs.insert(lab.rawValue)
        defaults.set(Array(visitedLabs), forKey: Key.visitedLabs)
    }

    func toggleMistake(_ id: String) {
        if checkedMistakes.contains(id) {
            checkedMistakes.remove(id)
        } else {
            checkedMistakes.insert(id)
        }
        defaults.set(Array(checkedMistakes), forKey: Key.checkedMistakes)
    }

    func isChecked(_ mistake: Mistake) -> Bool { checkedMistakes.contains(mistake.id) }

    /// 챕터별 정답률 — 홈에서 "어디가 약한지" 보여주는 데 쓴다.
    func mastery(chapter: Int, bank: QuizBank) -> Double {
        let ids = bank.questions.filter { $0.chapter == chapter }.map(\.id)
        guard !ids.isEmpty else { return 0 }
        let hit = ids.filter { correctIDs.contains($0) }.count
        return Double(hit) / Double(ids.count)
    }

    func resetAll() {
        correctIDs = []
        wrongIDs = []
        answeredCount = 0
        persist()
    }

    private func persist() {
        defaults.set(Array(correctIDs), forKey: Key.correct)
        defaults.set(Array(wrongIDs), forKey: Key.wrong)
        defaults.set(answeredCount, forKey: Key.answered)
    }
}

// MARK: - 한 판의 퀴즈

@MainActor
@Observable
final class QuizSession {
    enum Mode: Hashable {
        case mixed(Int)
        case chapter(Int)
        case principles
        case review
        case kind(Question.Kind)

        var title: String {
            switch self {
            case .mixed:            "랜덤 훈련"
            case .chapter(let n):   "\(n)장 집중"
            case .principles:       "원칙 판정"
            case .review:           "오답 복습"
            case .kind(let k):      "\(k.label) 모드"
            }
        }
    }

    let mode: Mode
    let questions: [Question]
    private(set) var index = 0
    private(set) var selection: Int?
    private(set) var results: [(question: Question, correct: Bool)] = []

    var current: Question? { index < questions.count ? questions[index] : nil }
    var isFinished: Bool { index >= questions.count }
    var isAnswered: Bool { selection != nil }
    var progress: Double {
        questions.isEmpty ? 1 : Double(index) / Double(questions.count)
    }
    var correctCount: Int { results.filter(\.correct).count }

    init(mode: Mode, bank: QuizBank = .shared, progress: ProgressStore? = nil) {
        self.mode = mode
        let pool = bank.questions
        switch mode {
        case .mixed(let count):
            // 유형이 한쪽으로 쏠리지 않게 종류별로 고루 뽑는다.
            var picked: [Question] = []
            let byKind = Dictionary(grouping: pool, by: \.kind)
            let kinds: [Question.Kind] = [.scenario, .judgement, .whenMatch, .principleMatch]
            let share = max(1, count / kinds.count)
            for kind in kinds {
                picked += (byKind[kind] ?? []).shuffled().prefix(share)
            }
            if picked.count < count {
                picked += pool.filter { q in !picked.contains(where: { $0.id == q.id }) }
                    .shuffled().prefix(count - picked.count)
            }
            questions = Array(picked.shuffled().prefix(count))

        case .chapter(let n):
            questions = Array(pool.filter { $0.chapter == n }.shuffled().prefix(12))

        case .principles:
            questions = Array(
                pool.filter { $0.kind == .principleMatch || $0.chapter == 8 }.shuffled().prefix(12)
            )

        case .review:
            let wrong = progress?.wrongIDs ?? []
            questions = pool.filter { wrong.contains($0.id) }.shuffled()

        case .kind(let k):
            questions = Array(pool.filter { $0.kind == k }.shuffled().prefix(12))
        }
    }

    func select(_ option: Int, progress: ProgressStore) {
        guard selection == nil, let question = current else { return }
        selection = option
        let correct = option == question.answerIndex
        results.append((question, correct))
        progress.record(question: question, isCorrect: correct)
    }

    func advance() {
        guard selection != nil else { return }
        selection = nil
        index += 1
    }
}
