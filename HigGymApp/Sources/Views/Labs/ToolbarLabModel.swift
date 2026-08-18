import SwiftUI

// MARK: - 자리와 역할

enum ToolbarSlot: String, CaseIterable, Identifiable, Hashable {
    case leading, principal, trailing, bottom
    var id: String { rawValue }

    var title: String {
        switch self {
        case .leading:   "왼쪽 상단 (leading)"
        case .principal: "제목 자리 (principal)"
        case .trailing:  "오른쪽 상단 (trailing)"
        case .bottom:    "하단 바 (bottom)"
        }
    }

    /// 이 자리가 원래 말하는 것 — 문법을 어겼는지 판정하는 기준.
    var grammar: String {
        switch self {
        case .leading:   "이동"
        case .principal: "화면의 정체성"
        case .trailing:  "확정"
        case .bottom:    "빈도"
        }
    }

    var placementCode: String {
        switch self {
        case .leading:   ".topBarLeading"
        case .principal: ".principal"
        case .trailing:  ".topBarTrailing"
        case .bottom:    ".bottomBar"
        }
    }

    /// 이 자리에 어울리는 역할 — 벗어나면 진단이 걸린다.
    var expectedRoles: Set<ItemRole> {
        switch self {
        case .leading:   [.navigate, .tool]
        case .principal: [.identity]
        case .trailing:  [.confirm, .tool]
        case .bottom:    [.create, .tool, .destructive]
        }
    }
}

enum ItemRole: String, Hashable {
    case navigate, tool, confirm, create, identity, destructive

    var label: String {
        switch self {
        case .navigate:    "이동"
        case .tool:        "도구"
        case .confirm:     "확정"
        case .create:      "생성"
        case .identity:    "정체성"
        case .destructive: "파괴적"
        }
    }

    var color: Color {
        switch self {
        case .navigate:    .hgAccent
        case .tool:        .hgMuted
        case .confirm:     .hgGreen
        case .create:      .hgAccent2
        case .identity:    .hgAmber
        case .destructive: .hgRed
        }
    }
}

struct ToolbarItemSpec: Identifiable, Hashable {
    let id: String
    let name: String
    let symbol: String
    let role: ItemRole
    /// 화면당 여러 번 반복해서 누르는가 — Reachability 판정의 입력.
    let frequent: Bool

    static let palette: [ToolbarItemSpec] = [
        .init(id: "compose",  name: "새 메시지", symbol: "square.and.pencil", role: .create,      frequent: true),
        .init(id: "add",      name: "추가",      symbol: "plus",              role: .create,      frequent: true),
        .init(id: "done",     name: "완료",      symbol: "checkmark",         role: .confirm,     frequent: false),
        .init(id: "save",     name: "저장",      symbol: "tray.and.arrow.down", role: .confirm,   frequent: false),
        .init(id: "sort",     name: "정렬",      symbol: "arrow.up.arrow.down", role: .tool,      frequent: false),
        .init(id: "filter",   name: "필터",      symbol: "line.3.horizontal.decrease", role: .tool, frequent: false),
        .init(id: "viewmode", name: "보기 전환", symbol: "square.grid.2x2",   role: .tool,        frequent: false),
        .init(id: "undo",     name: "실행취소",  symbol: "arrow.uturn.backward", role: .tool,     frequent: true),
        .init(id: "redo",     name: "재실행",    symbol: "arrow.uturn.forward", role: .tool,      frequent: true),
        .init(id: "share",    name: "공유",      symbol: "square.and.arrow.up", role: .tool,      frequent: false),
        .init(id: "star",     name: "즐겨찾기",  symbol: "star",              role: .tool,        frequent: false),
        .init(id: "delete",   name: "삭제",      symbol: "trash",             role: .destructive, frequent: false),
        .init(id: "segment",  name: "지도/목록", symbol: "map",               role: .identity,    frequent: false),
    ]
}

// MARK: - 구성

enum TitleMode: String, CaseIterable, Identifiable {
    case large, inlineLarge, inline, titleMenu, custom
    var id: String { rawValue }

    var label: String {
        switch self {
        case .large:       "Large"
        case .inlineLarge: "Inline Large"
        case .inline:      "Inline"
        case .titleMenu:   "Title Menu"
        case .custom:      "Custom"
        }
    }

    var source: String {
        switch self {
        case .large:       "1.2.1"
        case .inlineLarge: "1.2.2"
        case .inline:      "1.2.3"
        case .titleMenu:   "1.2.5"
        case .custom:      "1.2.6"
        }
    }
}

enum SearchOption: String, CaseIterable, Identifiable {
    case none, drawerAuto, drawerAlways, minimized
    var id: String { rawValue }

    var label: String {
        switch self {
        case .none:         "없음"
        case .drawerAuto:   "Drawer"
        case .drawerAlways: "Drawer .always"
        case .minimized:    "Minimize"
        }
    }

    var source: String {
        switch self {
        case .none:         "—"
        case .drawerAuto:   "1.4.3"
        case .drawerAlways: "1.4.4"
        case .minimized:    "1.4.6"
        }
    }
}

struct ToolbarConfig {
    /// 1.1.1 최소 구성에서 시작한다 — 여기서 하나씩 어겨보게.
    var items: [ToolbarSlot: [ToolbarItemSpec]] = [
        .leading: [],
        .principal: [],
        .trailing: ToolbarItemSpec.palette.filter { $0.id == "done" },
        .bottom: [],
    ]
    var titleMode: TitleMode = .large
    var search: SearchOption = .none
    /// 루트 화면인가 — leading 클러스터가 뒤로가기와 다투는지 판정하는 입력.
    var isRoot = true

    func items(in slot: ToolbarSlot) -> [ToolbarItemSpec] { items[slot] ?? [] }

    var allItems: [ToolbarItemSpec] { ToolbarSlot.allCases.flatMap { items(in: $0) } }

    /// 정체성 컨트롤(세그먼트)은 액션이 아니라 화면 구성이므로 액션 수에서 뺀다.
    var actionCount: Int { allItems.filter { $0.role != .identity }.count }

    mutating func toggle(_ item: ToolbarItemSpec, in slot: ToolbarSlot) {
        var list = items(in: slot)
        if let idx = list.firstIndex(of: item) {
            list.remove(at: idx)
        } else {
            list.append(item)
        }
        items[slot] = list
    }

    mutating func clear() {
        items = [.leading: [], .principal: [], .trailing: [], .bottom: []]
    }
}

// MARK: - 진단 — 8장 원칙과 1장 항목을 규칙으로 옮긴 것

enum ToolbarDiagnostics {

    static func evaluate(_ c: ToolbarConfig) -> [Diagnosis] {
        var out: [Diagnosis] = []

        if c.allItems.isEmpty {
            out.append(.init(
                level: .caution,
                message: "아직 아무 액션도 없습니다. 팔레트에서 아이템을 자리에 넣어보세요.",
                source: "1.1 Items"
            ))
            return out
        }

        out += placementGrammar(c)
        out += reachability(c)
        out += clustering(c)
        out += minimization(c)
        out += titleRules(c)
        out += searchRules(c)

        if out.allSatisfy({ $0.level == .good }) || out.isEmpty {
            out.insert(.init(
                level: .good,
                message: "지금 구성은 자리·묶음의 문법과 도달성 기준을 모두 지키고 있습니다.",
                source: "8.1.2 · 8.1.3"
            ), at: 0)
        }
        return out.sorted { $0.level > $1.level }
    }

    // 8.1.3 위치·묶음의 문법 — 자리와 역할이 맞는가
    private static func placementGrammar(_ c: ToolbarConfig) -> [Diagnosis] {
        var out: [Diagnosis] = []

        let principal = c.items(in: .principal)
        if let wrong = principal.first(where: { $0.role != .identity }) {
            out.append(.init(
                level: .violation,
                message: "**\(wrong.name)**을(를) principal에 두었습니다. 제목 자리는 “화면의 정체성”을 말하는 문법이라 부가 액션이 오면 제목까지 사라지면서 이 화면이 무엇인지 말할 장치가 없어집니다.",
                source: "1.1.5 · 8.1.3"
            ))
        } else if principal.contains(where: { $0.role == .identity }) {
            out.append(.init(
                level: .good,
                message: "세그먼트를 principal에 두었습니다 — 값에 따라 화면 전체가 바뀌므로 “화면의 정체성”이라는 자리의 문법과 정확히 일치합니다.",
                source: "1.1.5"
            ))
        }

        if !c.items(in: .leading).isEmpty && !c.isRoot {
            out.append(.init(
                level: .caution,
                message: "push된 상세 화면의 leading에 아이템이 있습니다. 이 자리는 뒤로가기가 선점하므로, leading 클러스터는 루트나 모달처럼 **back이 없는 화면**의 패턴입니다.",
                source: "1.1.2"
            ))
        }

        if let confirm = c.items(in: .bottom).first(where: { $0.role == .confirm }) {
            out.append(.init(
                level: .violation,
                message: "**\(confirm.name)**은(는) 화면당 한 번 누르는 확정 액션인데 하단에 있습니다. 고빈도 자리를 낭비하고, 탭바(이동)와 인접해 역할까지 혼동됩니다.",
                source: "1.1.4 · 8.1.2"
            ))
        }

        // 같은 아이템이 두 자리에 중복
        let names = c.allItems.map(\.id)
        let dupes = Set(names.filter { id in names.filter { $0 == id }.count > 1 })
        for id in dupes {
            let name = ToolbarItemSpec.palette.first { $0.id == id }?.name ?? id
            out.append(.init(
                level: .violation,
                message: "**\(name)**이(가) 두 자리에 중복 배치돼 있습니다. 같은 기능이 두 곳에 있으면 사용자는 둘을 다른 기능으로 읽습니다.",
                source: "1.1.3"
            ))
        }

        return out
    }

    // 8.1.2 Reachability — 빈도가 높을수록 엄지에 가깝게
    private static func reachability(_ c: ToolbarConfig) -> [Diagnosis] {
        var out: [Diagnosis] = []

        for slot in [ToolbarSlot.leading, .trailing] {
            for item in c.items(in: slot) where item.frequent && item.role == .create {
                out.append(.init(
                    level: .violation,
                    message: "**\(item.name)**은(는) 반복해서 누르는 고빈도 액션인데 상단에 있습니다. 빈도와 높이는 반비례해야 합니다 — 하단이 엄지의 홈 그라운드입니다.",
                    source: "1.1.4 · 8.1.2"
                ))
            }
        }

        for item in c.items(in: .bottom) where item.frequent {
            out.append(.init(
                level: .good,
                message: "**\(item.name)**처럼 자주 반복하는 액션을 하단에 둔 것은 빈도–높이 반비례 기준에 맞습니다.",
                source: "8.1.2"
            ))
        }

        return out
    }

    // 1.1.3 묶음 = 의미
    private static func clustering(_ c: ToolbarConfig) -> [Diagnosis] {
        var out: [Diagnosis] = []

        for slot in ToolbarSlot.allCases {
            let list = c.items(in: slot)
            guard list.count >= 2 else { continue }

            if list.contains(where: { $0.role == .destructive }) && list.count > 1 {
                out.append(.init(
                    level: .violation,
                    message: "\(slot.title)에서 **삭제**가 다른 도구와 한 캡슐로 묶였습니다. 같은 캡슐 = 한 세트라서, 성격이 다른 파괴적 액션이 섞이면 묶음이 거짓 정보가 됩니다.",
                    source: "1.1.3 · 8.1.3"
                ))
            }

            let roles = Set(list.map(\.role))
            if roles.count >= 3 {
                out.append(.init(
                    level: .caution,
                    message: "\(slot.title)에 서로 다른 역할 \(roles.count)종이 한 묶음입니다. 관련 없는 액션을 기계적으로 한 캡슐에 넣으면 “한 세트”라는 신호가 거짓이 됩니다.",
                    source: "1.1.3"
                ))
            }

            if list.count > 3 {
                out.append(.init(
                    level: .caution,
                    message: "\(slot.title)에 \(list.count)개 — 그룹당 2~3개가 적정입니다. 그 이상은 overflow(⋯)나 하단 바로 분산하세요.",
                    source: "1.1.3 · 1.1.7"
                ))
            }
        }

        return out
    }

    // 8.1.1 Content-First
    private static func minimization(_ c: ToolbarConfig) -> [Diagnosis] {
        var out: [Diagnosis] = []

        if !c.items(in: .bottom).isEmpty && c.actionCount == 1 {
            out.append(.init(
                level: .violation,
                message: "액션이 하나뿐인데 하단 바를 만들었습니다. 하단 바 전체가 상시 세로 공간을 차지하지만 기여하는 건 버튼 하나 — 오른쪽 상단 단일 캡슐로 충분합니다.",
                source: "1.1.1 · 8.1.1"
            ))
        }

        let filled = ToolbarSlot.allCases.filter { !c.items(in: $0).isEmpty }
        if filled.count == 4 {
            out.append(.init(
                level: .violation,
                message: "leading · principal · trailing · bottom을 모두 채웠습니다. “자리가 있으니 채운다”는 Content-First의 정반대입니다.",
                source: "1.1.9 · 8.1.1"
            ))
        }

        if c.actionCount == 1,
           let only = c.allItems.first(where: { $0.role != .identity }),
           c.items(in: .trailing).contains(only) {
            out.append(.init(
                level: .good,
                message: "액션이 하나뿐이니 형태도 하나 — 최소 구성입니다. trailing은 primary action의 관례적 위치입니다.",
                source: "1.1.1"
            ))
        }

        return out
    }

    private static func titleRules(_ c: ToolbarConfig) -> [Diagnosis] {
        var out: [Diagnosis] = []

        if c.titleMode == .custom && !c.items(in: .principal).isEmpty {
            out.append(.init(
                level: .violation,
                message: "Custom Large Title 자리에 인터랙티브 컨트롤을 넣었습니다. 제목 자리는 “화면 정체성” 문법이라 버튼·입력 필드가 오면 자리의 문법이 깨집니다.",
                source: "1.2.6 · 8.1.3"
            ))
        }

        if c.titleMode == .titleMenu {
            out.append(.init(
                level: .good,
                message: "제목 자체를 눌러 대상에 대한 액션을 여는 구성입니다. 대상과 액션이 한 몸이라 관계를 설명할 필요가 없고 툴바 자리도 아낍니다.",
                source: "1.2.5 · 8.1.7"
            ))
        }

        if c.titleMode == .large && c.search == .drawerAlways {
            out.append(.init(
                level: .caution,
                message: "Large 타이틀 + 상시 검색 드로어는 진입 시점의 세로 점유가 큽니다. 스크롤하면 제목은 접히지만 검색바는 남습니다.",
                source: "1.2.1 · 1.4.4"
            ))
        }

        return out
    }

    private static func searchRules(_ c: ToolbarConfig) -> [Diagnosis] {
        switch c.search {
        case .none:
            return []
        case .drawerAlways:
            return [.init(
                level: .caution,
                message: "검색바가 항상 한 줄을 차지합니다. 검색이 주 진입점인 화면에서만 쓰고, 그렇지 않다면 대부분의 순간 과업에 기여하지 않는 UI가 상시 점유하는 셈입니다.",
                source: "1.4.4 · 8.1.1"
            )]
        case .minimized:
            return [.init(
                level: .good,
                message: "검색이 조연인 화면에서 돋보기 크기로 접어두는 구성 — 한 탭 거리는 유지하면서 평소 점유는 최소입니다.",
                source: "1.4.6 · 8.1.1"
            )]
        case .drawerAuto:
            return [.init(
                level: .good,
                message: "스크롤하면 숨고 당기면 나타나는 기본 드로어 — 필요할 때만 공간을 씁니다.",
                source: "1.4.3"
            )]
        }
    }
}

// MARK: - 코드 생성

enum ToolbarCodeGenerator {

    static func code(for c: ToolbarConfig) -> String {
        var lines: [String] = []
        lines.append("List { /* 콘텐츠 */ }")
        lines.append("    .navigationTitle(\"받은 편지함\")")

        switch c.titleMode {
        case .large:       lines.append("    .toolbarTitleDisplayMode(.large)")
        case .inlineLarge: lines.append("    .toolbarTitleDisplayMode(.inlineLarge)")
        case .inline:      lines.append("    .toolbarTitleDisplayMode(.inline)")
        case .titleMenu:
            lines.append("    .toolbarTitleDisplayMode(.inline)")
            lines.append("    .toolbarTitleMenu {")
            lines.append("        Button(\"이름 변경\") {}")
            lines.append("        Button(\"폴더 전환\") {}")
            lines.append("    }")
        case .custom:
            lines.append("    .toolbar {")
            lines.append("        ToolbarItem(placement: .principal) { CustomTitleView() }")
            lines.append("    }")
        }

        let used = ToolbarSlot.allCases.filter { !c.items(in: $0).isEmpty }
        if !used.isEmpty {
            lines.append("    .toolbar {")
            for slot in used {
                let list = c.items(in: slot)
                if list.count == 1, let item = list.first {
                    lines.append("        ToolbarItem(placement: \(slot.placementCode)) {")
                    lines.append("            Button(\"\(item.name)\", systemImage: \"\(item.symbol)\") {}")
                    lines.append("        }")
                } else {
                    lines.append("        ToolbarItemGroup(placement: \(slot.placementCode)) {")
                    for item in list {
                        lines.append("            Button(\"\(item.name)\", systemImage: \"\(item.symbol)\") {}")
                    }
                    lines.append("        }")
                }
            }
            // 두 묶음이 서로 다른 일임을 여백으로 말하는 iOS 26 API
            if c.items(in: .trailing).count >= 2 {
                lines.append("        ToolbarSpacer(.fixed, placement: .topBarTrailing)")
            }
            lines.append("    }")
        }

        switch c.search {
        case .none: break
        case .drawerAuto:
            lines.append("    .searchable(text: $query, placement: .navigationBarDrawer)")
        case .drawerAlways:
            lines.append("    .searchable(text: $query,")
            lines.append("                placement: .navigationBarDrawer(displayMode: .always))")
        case .minimized:
            lines.append("    .searchable(text: $query)")
            lines.append("    .searchToolbarBehavior(.minimize)")
        }

        return lines.joined(separator: "\n")
    }
}
