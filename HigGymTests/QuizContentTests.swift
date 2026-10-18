import Foundation
import Testing
@testable import HigGym

/// 퀴즈 지문과 원칙 카드가 콘텐츠를 제자리에서 나누는지.
///
/// 예시는 "요약"과 "근거", 원칙 제목은 "이름"과 "한 줄 설명"으로 entries.json 에서부터 따로 온다.
/// 한 문장을 구분 기호로 다시 나누던 시절에는 기호가 바뀌자(1.0.1) 나누기가 조용히 멈춰,
/// 판별 문제의 지문에 근거가 그대로 붙어 답이 새어 나갔다.
struct QuizContentTests {
    private let store = ContentStore.shared

    @Test func 판별_문제의_지문에는_근거가_없다() throws {
        let judgements = QuizBank.shared.questions.filter { $0.kind == .judgement }
        #expect(judgements.count > 200)

        let examples = (store.entries + store.principles).flatMap { $0.good + $0.bad }
        let rationales = examples.map { PromptText.stripCrossReferences($0.rationale) }.filter { !$0.isEmpty }
        #expect(rationales.count > 150, "근거가 나뉜 예시가 너무 적다: \(rationales.count)")

        for question in judgements {
            let subject = try #require(question.subject)
            for rationale in rationales {
                #expect(!subject.contains(rationale), "\(question.id) 지문에 근거가 붙어 있다: \(subject)")
            }
            // 정답을 알려 주는 상호참조("(1.1.1 위반)")도 지문에 남지 않는다.
            #expect(subject.range(of: #"\d+\.\d+\.\d+"#, options: .regularExpression) == nil,
                    "\(question.id) 지문에 상호참조가 남았다: \(subject)")
        }
    }

    @Test func 원칙_문제의_지문에도_근거가_없고_해설에는_있다() {
        let questions = QuizBank.shared.questions.filter { $0.kind == .principleMatch }
        #expect(!questions.isEmpty)
        for principle in store.principles {
            for (i, example) in principle.bad.enumerated() where example.quiz {
                let (headline, rationale) = PromptText.split(example)
                let question = questions.first { $0.id == "prin-\(principle.id)-\(i)" }
                #expect(question?.subject == headline)
                if let rationale {
                    #expect(question?.subject?.contains(rationale) == false)
                    #expect(question?.explanation.contains(rationale) == true)
                }
            }
        }
    }

    @Test func 원칙_일곱_개_모두_이름과_한_줄_설명이_따로_있다() {
        #expect(store.principles.count == 7)
        for principle in store.principles {
            #expect(!principle.title.isEmpty)
            #expect(!principle.tagline.isEmpty, "\(principle.index) 한 줄 설명이 없다")
            #expect(!principle.title.contains(principle.tagline), "\(principle.index) 이름에 한 줄 설명이 붙어 있다")
        }
    }

    @Test func 상호참조는_번역문의_꼴까지_지운다() {
        #expect(PromptText.stripCrossReferences("**하단 바** (1.1.1 위반)") == "**하단 바**")
        #expect(PromptText.stripCrossReferences("**A bottom bar** (violates 1.1.1)") == "**A bottom bar**")
        #expect(PromptText.stripCrossReferences("tab bar (violates the Tip in 1.1.4)") == "tab bar")
        #expect(PromptText.stripCrossReferences("**下部のバー**（1.1.1違反）") == "**下部のバー**")
        #expect(PromptText.stripCrossReferences("**大きいタイトル**（1.2.1）") == "**大きいタイトル**")
        #expect(PromptText.stripCrossReferences("iOS 26 (WWDC25)") == "iOS 26 (WWDC25)")
    }

    /// 세 언어 모두에서 나뉜 두 부분이 따로 번역돼 있어야 한다. 하나라도 빠지면 그 칸만 한국어로 보인다.
    @Test(arguments: ["ko", "en", "ja"])
    func 요약과_근거_이름과_한_줄_설명이_세_언어_모두_빈칸이_없다(language: String) throws {
        let app = Bundle(for: NotebookStore.self)
        let path = try #require(app.path(forResource: language, ofType: "lproj"))
        let localized = try #require(Bundle(path: path))
        let url = try #require(app.url(forResource: "entries", withExtension: "json"))
        let data = try ContentLocalization.localize(try Data(contentsOf: url), bundle: localized)
        let bundle = try JSONDecoder().decode(ContentBundle.self, from: data)

        func check(_ text: String, _ label: String) {
            #expect(!text.isEmpty, "\(language) \(label) 이 비었다")
            if language != "ko" {
                #expect(!ContentLocalization.containsHangul(text), "\(language) \(label) 에 한글: \(text)")
            }
        }
        for entry in bundle.entries + bundle.principles {
            for (kind, examples) in [("good", entry.good), ("bad", entry.bad)] {
                for (i, example) in examples.enumerated() {
                    check(example.headline, "\(entry.index) \(kind)[\(i)] 요약")
                }
            }
        }
        // 원문에 근거가 있는 예시는 번역에도 근거가 있다(둘이 한 칸에 합쳐지지 않았다).
        let source = try JSONDecoder().decode(ContentBundle.self, from: Data(contentsOf: url))
        for (original, translated) in zip(source.entries + source.principles, bundle.entries + bundle.principles) {
            for (a, b) in zip(original.good + original.bad, translated.good + translated.bad) where !a.rationale.isEmpty {
                check(b.rationale, "\(original.index) 근거")
                #expect(a.quiz == b.quiz)
            }
        }
        for principle in bundle.principles {
            check(principle.title, "원칙 \(principle.index) 이름")
            check(principle.tagline, "원칙 \(principle.index) 한 줄 설명")
        }
    }
}
