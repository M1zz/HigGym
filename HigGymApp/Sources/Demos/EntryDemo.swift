import SwiftUI

/// 한 항목의 "예제 보기" — 목업이 설명이라면, 데모는 **실제로 눌리는 화면**이다.
///
/// 목업(`MockupView`)은 배치를 그림으로 읽게 해주지만 동작이 없다. 데모는 같은 배치를
/// 진짜 SwiftUI API로 세워서, 눌러보고 스크롤해봐야 알 수 있는 것을 손에 남긴다 —
/// 오버플로가 접히는 순간, 대형 제목이 inline으로 줄어드는 지점, 시트가 detent에 걸리는 감각.
@MainActor
struct EntryDemo: Identifiable {
    /// `Entry.id` 와 같은 값 — 항목과 데모를 잇는 열쇠.
    let id: String
    /// 열자마자 무엇을 만져야 하는지. 2~4개면 충분하다.
    let hints: [String]
    /// 이 화면을 실제로 만든 코드의 핵심부.
    let code: String
    /// SDK·시뮬레이터 사정으로 실물과 다른 부분이 있으면 여기에 적는다.
    let note: String?
    /// 닫기·안내 캡슐을 붙일 가장자리. 화면 가장자리를 쓰는 데모(5.2)는 반대편으로 비킨다.
    let chromeEdge: DemoChromeEdge
    /// 화면 자체. 항목마다 타입이 다르므로 지우고 담는다.
    let make: () -> AnyView

    init<V: View>(
        _ id: String,
        hints: [String],
        code: String,
        note: String? = nil,
        chromeEdge: DemoChromeEdge = .leading,
        @ViewBuilder view: @escaping () -> V
    ) {
        self.id = id
        self.hints = hints
        self.code = code
        self.note = note
        self.chromeEdge = chromeEdge
        self.make = { AnyView(view()) }
    }
}

/// 항목 id → 데모. 챕터별 파일이 각자 `all` 을 내놓고 여기서 한 표로 합친다.
@MainActor
enum EntryDemos {
    static let byID: [String: EntryDemo] = {
        let groups: [[EntryDemo]] = [
            ToolbarItemsDemos.all,
            TitleModeDemos.all,
            ScrollEdgeDemos.all,
            SearchDemos.all,
            TextDemos.all,
            TabBarDemos.all,
            SheetDemos.all,
            SafeAreaDemos.all,
            MaterialDemos.all,
            MenuDemos.all,
            PrincipleDemos.all,
        ]
        var map: [String: EntryDemo] = [:]
        for group in groups {
            for demo in group {
                assert(map[demo.id] == nil, "데모 id 중복: \(demo.id)")
                map[demo.id] = demo
            }
        }
        return map
    }()

    static func demo(for entry: Entry) -> EntryDemo? { byID[entry.id] }
}
