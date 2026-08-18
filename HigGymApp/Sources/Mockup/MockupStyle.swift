import SwiftUI

/// 목업 한 노드가 어떻게 그려지는지 — 문서 CSS를 그대로 옮긴 표.
struct MockupBox {
    enum Layout {
        case row(spacing: CGFloat, centered: Bool)
        case column(spacing: CGFloat, alignment: HorizontalAlignment)
        case distributedRow
    }

    struct FontSpec {
        var size: CGFloat
        var weight: Font.Weight = .regular
        var mono = false
    }

    var width: CGFloat?
    var height: CGFloat?
    var minWidth: CGFloat?
    var top: CGFloat?
    var left: CGFloat?
    var right: CGFloat?
    var bottom: CGFloat?
    var centerX = false
    var fillsParent = false

    var fill: Color?
    var stroke: Color?
    var dashed = false
    var radius: CGFloat = 0
    var circle = false
    var triangle = false
    var glow: Color?
    var blur: CGFloat = 0
    var opacity: Double = 1

    var layout: Layout?
    var padH: CGFloat = 0
    var padV: CGFloat = 0
    var grow = false

    var font: FontSpec?
    var foreground: Color?
    /// CSS의 white-space: nowrap — 라벨류는 줄바꿈하지 않는다.
    var nowrap = false

    var isAbsolute: Bool {
        top != nil || left != nil || right != nil || bottom != nil || centerX || fillsParent
    }
}

enum MockupStyle {
    static let phoneSize = CGSize(width: 148, height: 292)
    static let cardWidth: CGFloat = 158

    private static let white = Color.white

    // swiftlint:disable:next cyclomatic_complexity function_body_length
    static func box(for node: MockupNode, highlighted: Bool, selectedTab: Bool = false) -> MockupBox {
        var b = MockupBox()

        for name in node.classes {
            switch name {
            case "phone":
                b.width = phoneSize.width
                b.height = phoneSize.height
                b.radius = 24
                b.stroke = .hgLine
                b.fill = Color(hex: 0x16191F)

            case "island":
                b.top = 7; b.centerX = true
                b.width = 34; b.height = 9; b.radius = 5
                b.fill = .black

            case "pnav":
                b.top = 24; b.left = 8; b.right = 8; b.height = 24
                b.layout = .row(spacing: 4, centered: true)

            case "bbar":
                b.bottom = 12; b.left = 8; b.right = 8
                b.layout = .row(spacing: 6, centered: true)

            case "drawer":
                b.top = 52; b.left = 10; b.right = 10; b.height = 17
                b.radius = 9
                b.fill = white.opacity(0.06)
                b.stroke = white.opacity(0.14)
                b.layout = .row(spacing: 5, centered: true)
                b.padH = 6

            case "acc":
                b.bottom = 46; b.left = 8; b.right = 8; b.height = 20
                b.radius = 10
                b.fill = white.opacity(0.09)
                b.stroke = white.opacity(0.16)
                b.layout = .row(spacing: 6, centered: true)
                b.padH = 8

            case "topglass":
                b.top = 0; b.left = 0; b.right = 0; b.height = 54

            case "dimm":
                b.fillsParent = true
                b.top = 0; b.left = 0
                b.width = phoneSize.width; b.height = phoneSize.height
                b.fill = .black.opacity(0.42)

            case "sheet":
                b.left = 3; b.right = 3; b.bottom = 3
                b.radius = 16
                b.fill = Color(hex: 0x232833)
                b.stroke = .hgAccent
                b.layout = .column(spacing: 0, alignment: .leading)

            case "grab":
                b.width = 22; b.height = 3; b.radius = 2
                b.fill = white.opacity(0.35)

            case "sln":
                b.height = 5; b.radius = 3
                b.fill = white.opacity(0.10)

            case "cap":
                b.height = 20; b.radius = 10
                b.fill = white.opacity(0.07)
                b.stroke = white.opacity(0.14)
                b.layout = .row(spacing: 4, centered: true)
                b.padH = 7

            case "rd":
                b.width = 20; b.circle = true; b.padH = 0

            case "search":
                b.grow = true
                b.padH = 8
                b.layout = .row(spacing: 5, centered: true)

            case "sp":
                b.grow = true

            case "dot":
                b.width = 5; b.height = 5; b.circle = true
                b.fill = highlighted ? .hgAccent : white.opacity(0.55)

            case "chev":
                b.nowrap = true
                b.font = .init(size: 11)
                b.foreground = white.opacity(0.35)

            case "mag":
                b.nowrap = true
                b.font = .init(size: 10)
                b.foreground = highlighted ? .hgAccent : white.opacity(0.55)

            case "sline":
                b.grow = true; b.height = 5; b.radius = 3
                b.fill = white.opacity(0.12)

            case "seg":
                b.width = 20; b.height = 13; b.radius = 7

            case "on":
                // CSS는 `.seg.on` 만 칠하고, `.ti.on` 은 자식(.ic/.lb)에 색을 준다.
                if node.has("seg") { b.fill = white.opacity(0.28) }

            case "ell":
                b.nowrap = true
                b.font = .init(size: 10, weight: .bold)
                b.foreground = .hgAccent

            case "ttl":
                b.nowrap = true
                b.font = .init(size: 8.5, weight: .bold)
                b.foreground = white.opacity(0.8)

            case "hlt":
                b.foreground = .hgAccent
                b.glow = .hgAccent

            case "ln":
                b.left = 14; b.height = 6; b.radius = 3
                b.fill = white.opacity(0.06)

            case "big-ttl":
                b.top = 56; b.left = 14; b.width = 76; b.height = 13; b.radius = 4
                b.fill = white.opacity(0.2)

            case "mtag":
                b.nowrap = true
                b.font = .init(size: 7, weight: .bold)
                b.foreground = .hgAccent
                b.fill = Color(hex: 0x141820).opacity(0.9)
                b.stroke = Color.hgAccent.opacity(0.45)
                b.radius = 5
                b.padH = 4; b.padV = 1

            case "menu":
                b.top = 54; b.left = 38; b.width = 72
                b.radius = 8
                b.fill = Color(hex: 0x232833)
                b.stroke = .hgAccent
                b.layout = .column(spacing: 5, alignment: .leading)
                b.padH = 6; b.padV = 6

            case "logo":
                b.width = 14; b.height = 14; b.circle = true
                b.fill = .hgAccent

            case "blob":
                b.circle = true; b.blur = 7; b.opacity = 0.55

            case "hl":
                b.fill = Color.hgAccent.opacity(0.18)
                b.stroke = .hgAccent
                b.glow = .hgAccent

            case "hlb":
                b.fill = Color.hgAccent.opacity(0.4)
                b.glow = .hgAccent

            case "tbar":
                b.grow = true; b.height = 28; b.radius = 14
                b.fill = white.opacity(0.07)
                b.stroke = white.opacity(0.14)
                b.layout = .distributedRow
                b.padH = 2

            case "ti":
                b.layout = .column(spacing: 2, alignment: .center)

            case "ic":
                b.width = 9; b.height = 9; b.radius = 3
                b.fill = selectedTab ? .hgAccent : white.opacity(0.38)
                if selectedTab { b.glow = .hgAccent }

            case "lb":
                b.nowrap = true
                b.font = .init(size: 5.5)
                b.foreground = selectedTab ? .hgAccent : white.opacity(0.5)

            case "bdg":
                b.nowrap = true
                b.minWidth = 10; b.height = 10; b.radius = 5
                b.fill = .hgRed
                b.foreground = .white
                b.font = .init(size: 5.5, weight: .bold)
                b.padH = 2

            case "tri":
                b.width = 5; b.height = 7
                b.triangle = true
                b.fill = white.opacity(0.7)

            case "gcard":
                b.width = 56; b.height = 42; b.radius = 8
                b.fill = white.opacity(0.05)
                b.stroke = Color(hex: 0x232833)

            case "src":
                b.stroke = .hgAccent
                b.dashed = true
                b.glow = .hgAccent

            case "chip":
                b.width = 16; b.height = 8; b.radius = 4
                b.fill = white.opacity(0.2)

            case "vbar":
                b.width = 20; b.radius = 10
                b.fill = white.opacity(0.08)
                b.stroke = white.opacity(0.16)
                b.layout = .column(spacing: 7, alignment: .center)
                b.padV = 8

            case "matcard":
                b.left = 14; b.right = 14; b.height = 34; b.radius = 10
                b.stroke = white.opacity(0.18)
                b.layout = .row(spacing: 0, centered: true)
                b.padH = 10
                b.font = .init(size: 8)
                b.foreground = white.opacity(0.88)

            // ── Text 챕터의 카드형 프리뷰 ─────────────────────────────
            case "tcard":
                b.width = cardWidth
                b.radius = 14
                b.fill = .hgCardHigh
                b.stroke = .hgLine
                b.layout = .column(spacing: 0, alignment: .leading)
                b.padH = 12; b.padV = 12
                b.font = .init(size: 10)
                b.foreground = Color(hex: 0xC7CDDB)

            case "tc-cap":
                b.nowrap = true
                b.font = .init(size: 8.5, mono: true)
                b.foreground = .hgAccent

            case "trow":
                b.layout = .row(spacing: 6, centered: true)

            case "tl":
                b.nowrap = true
                b.width = 44
                b.font = .init(size: 7.5, mono: true)
                b.foreground = .hgDim

            case "tv":
                b.nowrap = true
                b.grow = true
                b.font = .init(size: 9.5)
                b.fill = white.opacity(0.04)
                b.stroke = Color(hex: 0x232833)
                b.radius = 6
                b.padH = 6; b.padV = 3

            case "e":
                b.foreground = .hgAccent
                b.font = .init(size: 9.5, weight: .bold)

            case "fitbox":
                b.stroke = white.opacity(0.22)
                b.dashed = true
                b.radius = 8
                b.padH = 8; b.padV = 4
                b.font = .init(size: 10, mono: true)

            case "sel":
                b.fill = Color.hgAccent.opacity(0.3)
                b.radius = 2

            case "hnd":
                b.width = 5; b.height = 5; b.circle = true
                b.fill = .hgAccent

            case "rsv":
                b.stroke = .hgAccent
                b.dashed = true
                b.radius = 6
                b.fill = Color.hgAccent.opacity(0.06)

            case "mini2":
                b.layout = .row(spacing: 8, centered: false)

            case "mc":
                b.grow = true; b.height = 74
                b.fill = white.opacity(0.03)
                b.stroke = Color(hex: 0x232833)
                b.radius = 8
                b.padH = 7; b.padV = 7
                b.font = .init(size: 7.5)

            case "avtr":
                b.width = 16; b.height = 16; b.circle = true
                b.fill = .hgAccent
                b.foreground = .white
                b.font = .init(size: 7, weight: .bold)

            default:
                break
            }
        }

        applyInline(node, to: &b)
        return b
    }

    /// 인라인 스타일은 클래스 기본값을 덮어쓴다 — 문서에서 항목마다 위치를 지정하는 방식.
    private static func applyInline(_ node: MockupNode, to b: inout MockupBox) {
        if let v = node.length("top") { b.top = v }
        if let v = node.length("left") { b.left = v }
        if let v = node.length("right") { b.right = v }
        if let v = node.length("bottom") { b.bottom = v }
        if let v = node.length("width") { b.width = v }
        if let v = node.length("height") { b.height = v }
        if let v = node.length("border-radius") { b.radius = v }
        if let v = node.length("gap"), case .row(_, let centered)? = b.layout {
            b.layout = .row(spacing: v, centered: centered)
        }
        if let v = node.length("font-size") { b.font = .init(size: v, weight: b.font?.weight ?? .regular) }
        if let raw = node.style["background"], let color = MockupPalette.color(css: raw) { b.fill = color }
        if let raw = node.style["color"], let color = MockupPalette.color(css: raw) { b.foreground = color }
        if let raw = node.style["opacity"], let value = Double(raw) { b.opacity = value }
        if node.style["flex"]?.hasPrefix("1") == true { b.grow = true }
        if let raw = node.style["border-color"], let color = MockupPalette.color(css: raw) { b.stroke = color }
        if let raw = node.style["border"] ?? node.style["border-top"] ?? node.style["border-bottom"] {
            if raw.contains("dashed") { b.dashed = true }
            if let color = MockupPalette.color(css: String(raw.split(separator: " ").dropFirst(2).joined(separator: " "))) {
                b.stroke = color
            }
        }
        if let raw = node.style["margin-top"], let v = MockupNode.parseLength(raw) { b.padV = v }
    }
}
