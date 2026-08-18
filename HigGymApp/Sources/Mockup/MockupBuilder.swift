import SwiftUI

/// 실습에서 만지는 설정을 문서와 **같은 목업**으로 그려주는 조립기.
///
/// 실습 미리보기와 항목 설명이 같은 그림 언어를 쓰기 때문에,
/// 문서에서 본 배치를 실습에서 그대로 만들어볼 수 있다.
enum MockupBuilder {

    // MARK: 공통 조각

    static func node(
        _ tag: String,
        _ classes: [String] = [],
        style: [String: String] = [:],
        text: String? = nil,
        children: [MockupNode] = []
    ) -> MockupNode {
        MockupNode(tag: tag, classes: classes, style: style, text: text, children: children)
    }

    static var island: MockupNode { node("i", ["island"]) }

    static var spacer: MockupNode { node("span", ["sp"]) }

    static func dots(_ count: Int) -> [MockupNode] {
        (0..<max(count, 1)).map { _ in node("span", ["dot"]) }
    }

    /// 유리 캡슐 — 아이템 수에 따라 단일(원형)과 클러스터가 갈린다.
    static func capsule(items: Int, highlighted: Bool = true) -> MockupNode {
        var classes = ["cap"]
        if items <= 1 { classes.append("rd") }
        if highlighted { classes.append("hl") }
        return node("span", classes, children: dots(items))
    }

    /// 본문 콘텐츠 줄 — 문서와 같은 리듬으로, 비어 있는 세로 구간에만 깐다.
    static func contentLines(from top: CGFloat = 60, to bottom: CGFloat = 275) -> [MockupNode] {
        let offsets = [14, 44, 22, 58, 16, 36, 26]
        var lines: [MockupNode] = []
        var y = top
        var index = 0
        while y + 6 <= bottom {
            lines.append(node("i", ["ln"], style: [
                "top": "\(y)px",
                "right": "\(offsets[index % offsets.count])px",
            ]))
            y += 15
            index += 1
        }
        return lines
    }

    static func tag(_ text: String, bottom: Int, left: Int) -> MockupNode {
        node("span", ["mtag"], style: ["bottom": "\(bottom)px", "left": "\(left)px"], text: nil,
             children: [node("text", text: text)])
    }
}

// MARK: - 툴바 실험실

extension MockupBuilder {

    static func toolbar(_ config: ToolbarConfig) -> [MockupNode] {
        var children: [MockupNode] = [island]

        children.append(navigationBar(config))

        var contentTop: CGFloat = 60
        if config.titleMode == .large {
            children.append(node("i", ["big-ttl"]))
            contentTop = 80
        }

        switch config.search {
        case .none, .minimized:
            break
        case .drawerAuto, .drawerAlways:
            children.append(searchDrawer())
            contentTop = max(contentTop, 78)
        }

        // 하단 바가 있으면 그 위까지만 콘텐츠를 채운다.
        let contentBottom: CGFloat = config.items(in: .bottom).isEmpty ? 275 : 245
        children += contentLines(from: contentTop, to: contentBottom)

        if !config.items(in: .bottom).isEmpty {
            children.append(bottomBar(config))
        }

        if config.titleMode == .titleMenu {
            children.append(tag("제목 메뉴", bottom: 214, left: 44))
        }

        return [node("div", ["phone"], children: children)]
    }

    private static func navigationBar(_ config: ToolbarConfig) -> MockupNode {
        var row: [MockupNode] = []

        let leading = config.items(in: .leading)
        if !config.isRoot {
            row.append(node("span", ["chev"], children: [node("text", text: "‹")]))
        }
        if !leading.isEmpty {
            row.append(capsule(items: leading.count))
        }
        row.append(spacer)

        row += principalContent(config)

        row.append(spacer)

        let trailing = config.items(in: .trailing)
        if config.search == .minimized {
            row.append(node("span", ["cap", "rd", "hl"], children: [
                node("span", ["mag"], children: [node("text", text: "⌕")]),
            ]))
        }
        if !trailing.isEmpty {
            row.append(capsule(items: trailing.count))
        }

        return node("div", ["pnav"], children: row)
    }

    private static func principalContent(_ config: ToolbarConfig) -> [MockupNode] {
        let principal = config.items(in: .principal)

        if let item = principal.first {
            if item.role == .identity {
                return [node("span", ["cap", "hl"], children: [
                    node("span", ["seg", "on"]),
                    node("span", ["seg"]),
                ])]
            }
            return [capsule(items: 1)]
        }

        switch config.titleMode {
        case .large:
            return []                       // 큰 제목은 바 아래에 따로 놓인다
        case .inline, .inlineLarge:
            return [node("span", ["ttl"], children: [node("text", text: "제목")])]
        case .titleMenu:
            return [
                node("span", ["ttl", "hlt"], children: [node("text", text: "제목")]),
                node("span", ["ell"], children: [node("text", text: "⌄")]),
            ]
        case .custom:
            return [node("span", ["logo"])]
        }
    }

    private static func searchDrawer() -> MockupNode {
        node("div", ["drawer"], children: [
            node("span", ["mag"], children: [node("text", text: "⌕")]),
            node("span", ["sline"]),
        ])
    }

    private static func bottomBar(_ config: ToolbarConfig) -> MockupNode {
        let items = config.items(in: .bottom)
        return node("div", ["bbar"], children: [
            spacer,
            capsule(items: items.count),
            spacer,
        ])
    }
}

// MARK: - 탭바 실험실

extension MockupBuilder {

    static func tabBar(
        tabCount: Int,
        badge: BadgeOption,
        search: SearchTabOption,
        accessory: Bool,
        minimized: Bool
    ) -> [MockupNode] {
        var children: [MockupNode] = [island]

        children.append(node("div", ["pnav"], children: [
            spacer,
            node("span", ["ttl"], children: [node("text", text: "제목")]),
            spacer,
        ]))

        // 액세서리·탭바가 차지하는 아래쪽을 비워둔다.
        children += contentLines(from: 60, to: accessory ? 210 : 240)

        if accessory {
            children.append(node("div", ["acc", "hl"], children: [
                node("span", ["tri"]),
                node("span", [], style: [
                    "flex": "1", "height": "5px", "border-radius": "3px",
                    "background": "rgba(255,255,255,.18)",
                ]),
                node("span", ["dot"]),
            ]))
            children.append(tag("액세서리", bottom: 70, left: 10))
        }

        children.append(tabRow(tabCount: tabCount, badge: badge, search: search, minimized: minimized))

        return [node("div", ["phone"], children: children)]
    }

    private static let tabNames = ["홈", "탐색", "보관함", "알림", "설정", "더보기"]

    private static func tabRow(
        tabCount: Int,
        badge: BadgeOption,
        search: SearchTabOption,
        minimized: Bool
    ) -> MockupNode {
        var tabs: [MockupNode] = []
        let names = search == .plainTab ? tabNames + ["검색"] : tabNames

        for index in 0..<(search == .plainTab ? tabCount + 1 : tabCount) {
            var item: [MockupNode] = [node("span", ["ic"])]
            item.append(node("span", ["lb"], children: [node("text", text: names[index % names.count])]))
            if index == 0, badge != .none {
                item.append(node("span", ["bdg"], children: [
                    node("text", text: badge == .count ? "3" : "N"),
                ]))
            }
            tabs.append(node("span", index == 0 ? ["ti", "on"] : ["ti"], children: item))
        }

        var bar: [MockupNode] = [node("div", ["tbar"], children: tabs)]

        if search == .searchRole {
            bar.append(node("span", ["cap", "rd", "hl"], children: [
                node("span", ["mag"], children: [node("text", text: "⌕")]),
            ]))
        }

        return node("div", ["bbar"], children: bar)
    }
}
