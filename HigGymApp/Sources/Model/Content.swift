import Foundation

/// 문서(toolbar-annotated.html)에서 Tools/extract_content.py 로 뽑아낸 한 항목.
struct Entry: Codable, Identifiable, Hashable, Sendable {
    let id: String
    let index: String          // "1.1.1"
    let chapter: Int
    let chapterTitle: String
    let section: String        // "1.1"
    let sectionTitle: String
    let title: String
    let summary: String
    let caption: String
    /// 문서 프리뷰를 그대로 옮긴 목업 — 앱 화면의 근간.
    let mockup: [MockupNode]
    let when: String
    let why: String
    let tip: String
    let ios27: String
    let criterion: String      // 원칙(8장)에만 존재
    let good: [String]
    let bad: [String]
    let refs: [Reference]

    struct Reference: Codable, Hashable, Sendable {
        let title: String
        let url: String
    }

    /// "1.1.1" → 앞의 두 마디. 형제 항목을 고를 때 쓴다.
    var sectionKey: String { section.isEmpty ? "\(chapter)" : section }
}

struct ChapterInfo: Codable, Identifiable, Hashable, Sendable {
    let id: String
    let number: Int
    let title: String
    let subtitle: String
}

struct SectionInfo: Codable, Identifiable, Hashable, Sendable {
    var id: String { number }
    let number: String
    let title: String
    let desc: String
}

struct ContentBundle: Codable, Sendable {
    let generatedFrom: String
    let chapters: [ChapterInfo]
    let sections: [SectionInfo]
    let entries: [Entry]
    let principles: [Entry]
}

/// 번들에 실린 entries.json 을 한 번만 읽어 들고 있는 읽기 전용 스토어.
struct ContentStore: Sendable {
    let chapters: [ChapterInfo]
    let sections: [SectionInfo]
    let entries: [Entry]
    let principles: [Entry]

    static let shared: ContentStore = load()

    private static func load() -> ContentStore {
        guard let url = Bundle.main.url(forResource: "entries", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let bundle = try? JSONDecoder().decode(ContentBundle.self, from: data)
        else {
            assertionFailure("entries.json 을 읽지 못했습니다 — Tools/extract_content.py 를 먼저 실행하세요.")
            return ContentStore(chapters: [], sections: [], entries: [], principles: [])
        }
        return ContentStore(
            chapters: bundle.chapters,
            sections: bundle.sections,
            entries: bundle.entries,
            principles: bundle.principles
        )
    }

    func entry(index: String) -> Entry? { entries.first { $0.index == index } }

    func entries(chapter: Int) -> [Entry] { entries.filter { $0.chapter == chapter } }

    func siblings(of entry: Entry) -> [Entry] {
        let inSection = entries.filter { $0.section == entry.section }
        // 섹션에 형제가 부족하면 챕터 전체로 넓힌다 — 보기 4개를 채우기 위해.
        return inSection.count >= 4 ? inSection : entries(chapter: entry.chapter)
    }

    func section(_ number: String) -> SectionInfo? { sections.first { $0.number == number } }
}
