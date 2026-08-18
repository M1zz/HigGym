import Foundation

enum LabID: String, Codable, CaseIterable, Identifiable, Sendable {
    case toolbar, scrollEdge, text, tabBar, sheet
    var id: String { rawValue }

    var title: String {
        switch self {
        case .toolbar:    "툴바 배치 실험실"
        case .scrollEdge: "스크롤 엣지 이펙트"
        case .text:       "텍스트 잘림·축소"
        case .tabBar:     "탭바 구성"
        case .sheet:      "시트 디텐트"
        }
    }

    var subtitle: String {
        switch self {
        case .toolbar:    "자리와 묶음의 문법을 직접 어겨보기"
        case .scrollEdge: "최악의 배경에서 컨트롤이 읽히는지"
        case .text:       "잘려도 뜻이 통하는가"
        case .tabBar:     "몇 개까지가 탭바인가"
        case .sheet:      "얼마나 덮을 것인가"
        }
    }

    var symbol: String {
        switch self {
        case .toolbar:    "slider.horizontal.below.rectangle"
        case .scrollEdge: "square.stack.3d.down.right"
        case .text:       "textformat.size"
        case .tabBar:     "squares.below.rectangle"
        case .sheet:      "rectangle.portrait.bottomhalf.filled"
        }
    }

    /// 본문 항목 번호 → 그 항목을 손으로 확인할 수 있는 실습.
    static func forSection(_ section: String) -> LabID? {
        switch section {
        case "1.1", "1.2", "1.4", "7.1": .toolbar
        case "1.3", "6.1", "6.2":        .scrollEdge
        case "2.1", "2.2":               .text
        case "3.1", "3.2", "3.3", "3.4", "3.5": .tabBar
        case "4.1", "4.2", "4.3":        .sheet
        default: nil
        }
    }
}

struct Question: Identifiable, Hashable, Sendable {
    enum Kind: String, Sendable {
        case judgement       // 이 판단은 적절한가 / 부적절한가
        case whenMatch       // 이 상황에 맞는 컴포넌트는
        case principleMatch  // 이건 어떤 원칙 위반인가
        case scenario        // 시나리오 객관식 (직접 작성)

        var label: String {
            switch self {
            case .judgement:      "판별"
            case .whenMatch:      "선택"
            case .principleMatch: "원칙"
            case .scenario:       "실무"
            }
        }
    }

    let id: String
    let kind: Kind
    let prompt: String          // 질문 문장
    let subject: String?        // 판단 대상 (예시/상황 카드로 따로 보여줌)
    let options: [String]
    /// 보기마다 대응하는 본문 항목 번호 — 있으면 보기를 목업 그림으로 낸다.
    var optionSources: [String] = []
    let answerIndex: Int
    let explanation: String
    let sourceIndex: String     // 본문 항목 번호
    let sourceTitle: String
    let lab: LabID?

    var chapter: Int { Int(sourceIndex.split(separator: ".").first ?? "0") ?? 0 }
}

// MARK: - 문서 텍스트를 문제 지문으로 다듬기

enum PromptText {
    /// "(1.1.1 위반)" 처럼 정답을 알려주는 상호참조를 지운다.
    static func stripCrossReferences(_ s: String) -> String {
        let pattern = #"\s*\((\d+\.\d+\.\d+)[^)]*\)"#
        let cleaned = s.replacingOccurrences(of: pattern, with: "", options: .regularExpression)
        return cleaned.trimmingCharacters(in: .whitespaces)
    }

    /// "**요약** — 왜 그런지" → (요약, 왜 그런지). 근거 부분이 지문에 남으면 답이 새어나간다.
    static func split(_ example: String) -> (headline: String, rationale: String?) {
        let cleaned = stripCrossReferences(example)
        guard let range = cleaned.range(of: " — ") else { return (cleaned, nil) }
        let head = String(cleaned[..<range.lowerBound]).trimmingCharacters(in: .whitespaces)
        let tail = String(cleaned[range.upperBound...]).trimmingCharacters(in: .whitespaces)
        return (head.isEmpty ? cleaned : head, tail.isEmpty ? nil : tail)
    }

    /// 지문에 정답 이름이 그대로 박혀 있으면 가린다.
    static func mask(_ text: String, term: String) -> String {
        guard term.count > 2 else { return text }
        return text.replacingOccurrences(of: term, with: "◯◯◯", options: [.caseInsensitive])
    }
}

// MARK: - 문제 은행

struct QuizBank: Sendable {
    let questions: [Question]

    static let shared = QuizBank(store: .shared)

    init(store: ContentStore) {
        var built: [Question] = []
        built += Self.judgementQuestions(store)
        built += Self.whenMatchQuestions(store)
        built += Self.principleQuestions(store)
        built += CuratedQuestions.all
        questions = built
    }

    // 적절/부적절 판별 — 본문 68항목 + 원칙 7개의 예시 전체가 소재.
    private static func judgementQuestions(_ store: ContentStore) -> [Question] {
        let all = store.entries + store.principles
        var out: [Question] = []
        for entry in all {
            for (isGood, examples) in [(true, entry.good), (false, entry.bad)] {
                for (i, raw) in examples.enumerated() {
                    let (headline, rationale) = PromptText.split(raw)
                    guard headline.count > 6 else { continue }
                    let basis = entry.criterion.isEmpty ? entry.why : entry.criterion
                    var explanation = isGood
                        ? "적절합니다. \(rationale ?? "")"
                        : "부적절합니다. \(rationale ?? "")"
                    explanation = explanation.trimmingCharacters(in: .whitespaces)
                    explanation += "\n\n**기준** — \(PromptText.stripCrossReferences(basis))"

                    out.append(
                        Question(
                            id: "judge-\(entry.id)-\(isGood ? "ok" : "ng")-\(i)",
                            kind: .judgement,
                            prompt: "\(entry.chapter == 8 ? entry.title : "\(entry.sectionTitle) · \(entry.title)")\n이 설계 판단은 적절한가요?",
                            subject: headline,
                            options: ["적절하다", "부적절하다"],
                            answerIndex: isGood ? 0 : 1,
                            explanation: explanation,
                            sourceIndex: entry.index,
                            sourceTitle: entry.title,
                            lab: LabID.forSection(entry.section)
                        )
                    )
                }
            }
        }
        return out
    }

    // WHEN(어느 상황에서 쓰는가) → 해당 컴포넌트 고르기.
    private static func whenMatchQuestions(_ store: ContentStore) -> [Question] {
        var out: [Question] = []
        for entry in store.entries where !entry.when.isEmpty {
            let pool = store.siblings(of: entry).filter { $0.id != entry.id }
            guard pool.count >= 3 else { continue }
            let distractors = Array(pool.shuffled(seed: entry.index.hashValue).prefix(3))
            // 정답이 늘 마지막에 오지 않도록 항목 번호로 고정 정렬한다.
            let choices = (distractors + [entry]).sorted { $0.index < $1.index }
            guard let answerIndex = choices.firstIndex(where: { $0.id == entry.id }) else { continue }

            out.append(
                Question(
                    id: "when-\(entry.id)",
                    kind: .whenMatch,
                    prompt: "다음 상황에 맞는 것은? (\(entry.chapterTitle) · \(entry.sectionTitle))",
                    subject: PromptText.mask(entry.when, term: entry.title),
                    options: choices.map(\.title),
                    optionSources: choices.map(\.index),
                    answerIndex: answerIndex,
                    explanation: "**\(entry.title)** — \(entry.summary)\n\n**왜** — \(entry.why)",
                    sourceIndex: entry.index,
                    sourceTitle: entry.title,
                    lab: LabID.forSection(entry.section)
                )
            )
        }
        return out
    }

    // 잘못된 예 → 어떤 원칙을 어겼나.
    private static func principleQuestions(_ store: ContentStore) -> [Question] {
        let principles = store.principles
        guard principles.count >= 4 else { return [] }
        var out: [Question] = []

        for principle in principles {
            for (i, raw) in principle.bad.enumerated() {
                let (headline, rationale) = PromptText.split(raw)
                guard headline.count > 6 else { continue }
                let others = principles.filter { $0.id != principle.id }
                    .shuffled(seed: principle.id.hashValue &+ i)
                    .prefix(3)
                var options = (Array(others) + [principle]).map(\.title)
                options.sort()
                guard let answerIndex = options.firstIndex(of: principle.title) else { continue }

                out.append(
                    Question(
                        id: "prin-\(principle.id)-\(i)",
                        kind: .principleMatch,
                        prompt: "이 설계는 어떤 원칙을 어겼나요?",
                        subject: headline,
                        options: options,
                        answerIndex: answerIndex,
                        explanation: "\(rationale ?? "")\n\n**기준** — \(PromptText.stripCrossReferences(principle.criterion))"
                            .trimmingCharacters(in: .whitespacesAndNewlines),
                        sourceIndex: principle.index,
                        sourceTitle: principle.title,
                        lab: nil
                    )
                )
            }
        }
        return out
    }
}

// MARK: - 결정적 셔플 (같은 문제는 늘 같은 보기 순서)

extension Array {
    func shuffled(seed: Int) -> [Element] {
        var rng = SeededRNG(seed: UInt64(bitPattern: Int64(seed)))
        return shuffled(using: &rng)
    }
}

struct SeededRNG: RandomNumberGenerator {
    private var state: UInt64
    init(seed: UInt64) { state = seed == 0 ? 0x9E3779B97F4A7C15 : seed }

    mutating func next() -> UInt64 {
        state ^= state << 13
        state ^= state >> 7
        state ^= state << 17
        return state
    }
}
