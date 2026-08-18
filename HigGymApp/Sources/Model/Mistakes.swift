import Foundation
import SwiftUI

/// 실수 한 건 — 회고 한 편이 될 단위.
///
/// 항목(Entry)이 "이건 이렇게 생겼다"라면, 실수는 **"이렇게 하다가 밟았다"**이다.
/// 그래서 카드에는 언제나 세 줄이 붙는다: 무엇을 했는가 · 그때는 왜 맞아 보였는가 · 고치면 어떤 모습인가.
struct Mistake: Codable, Identifiable, Hashable, Sendable {
    let id: String
    let number: Int
    let title: String
    /// 회고의 핵심. 이게 없으면 남의 잘못을 지적하는 목록에 그친다.
    let why: String
    let fix: String
    let category: String
    let severity: String
    let severityLabel: String
    /// 판단 기준 — 분류가 걸린 8장 원칙에서 가져온다.
    let criterion: String
    let sources: [Source]
    /// 이 실수를 직접 만들어볼 수 있는 예제(항목 id).
    let demoEntryID: String
    let refs: [Entry.Reference]
    /// 이 실수의 회고. Retrospectives/<id>.md 를 절 단위로 잘라 실었다. 아직 안 쓴 편은 빈 배열.
    let story: [StorySection]

    struct StorySection: Codable, Hashable, Sendable, Identifiable {
        var id: String { heading }
        let heading: String
        let body: String
    }

    struct Source: Codable, Hashable, Sendable {
        let index: String
        let title: String
        let entryID: String
    }

    enum Severity: String {
        case common, critical, subtle

        var color: Color {
            switch self {
            case .critical: .hgRed
            case .common:   .hgAmber
            case .subtle:   .hgAccent
            }
        }
        var symbol: String {
            switch self {
            case .critical: "exclamationmark.octagon.fill"
            case .common:   "exclamationmark.triangle.fill"
            case .subtle:   "eye.trianglebadge.exclamationmark"
            }
        }
    }

    var level: Severity { Severity(rawValue: severity) ?? .common }
    var hasStory: Bool { !story.isEmpty }
}

struct MistakeCategory: Codable, Identifiable, Hashable, Sendable {
    let id: String
    let title: String
    let desc: String
    /// 이 분류가 걸린 8장 원칙 번호. "구조"만 원칙이 없어 빈 문자열이다.
    let principle: String
    let criterion: String

    var color: Color {
        switch id {
        case "clutter":   .hgGreen
        case "reach":     .hgAmber
        case "grammar":   .hgAccent2
        case "legible":   .hgRed
        case "text":      .hgAccent
        case "locale":    .hgGreen
        case "direct":    .hgAccent2
        default:          .hgAmber
        }
    }

    var symbol: String {
        switch id {
        case "clutter":   "square.stack.3d.up.slash"
        case "reach":     "hand.point.up.left"
        case "grammar":   "text.alignleft"
        case "legible":   "eye.slash"
        case "text":      "textformat.size"
        case "locale":    "globe"
        case "direct":    "hand.tap"
        default:          "point.topleft.down.to.point.bottomright.curvepath"
        }
    }
}

/// 번들에 실린 mistakes.json 을 한 번만 읽어 들고 있는 읽기 전용 스토어.
struct MistakeStore: Sendable {
    let categories: [MistakeCategory]
    let mistakes: [Mistake]

    static let shared: MistakeStore = load()

    private struct Bundled: Codable {
        let categories: [MistakeCategory]
        let mistakes: [Mistake]
    }

    private static func load() -> MistakeStore {
        guard let url = Bundle.main.url(forResource: "mistakes", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let bundled = try? JSONDecoder().decode(Bundled.self, from: data)
        else {
            assertionFailure("mistakes.json 을 읽지 못했습니다 — Tools/build_mistakes.py 를 먼저 실행하세요.")
            return MistakeStore(categories: [], mistakes: [])
        }
        return MistakeStore(categories: bundled.categories, mistakes: bundled.mistakes)
    }

    func category(_ id: String) -> MistakeCategory? { categories.first { $0.id == id } }

    func mistakes(in category: String) -> [Mistake] { mistakes.filter { $0.category == category } }

    /// 이 항목이 근거가 된 실수들 — 항목 상세에서 "여기서 나온 실수"로 잇는다.
    func mistakes(citing index: String) -> [Mistake] {
        mistakes.filter { $0.sources.contains { $0.index == index } }
    }
}
