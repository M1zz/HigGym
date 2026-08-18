import SwiftUI

/// 문서의 `<figure class="preview">` 안에 있던 목업 한 조각.
///
/// HTML을 그대로 옮겨왔기 때문에 앱과 문서가 **같은 그림**을 보여준다.
/// 이 그림이 설명의 기본이자 손으로 만지는 대상이다.
struct MockupNode: Codable, Hashable, Sendable {
    let tag: String
    let classes: [String]
    let style: [String: String]
    let text: String?
    let children: [MockupNode]

    init(
        tag: String,
        classes: [String] = [],
        style: [String: String] = [:],
        text: String? = nil,
        children: [MockupNode] = []
    ) {
        self.tag = tag
        self.classes = classes
        self.style = style
        self.text = text
        self.children = children
    }

    func has(_ name: String) -> Bool { classes.contains(name) }

    /// 인라인 스타일의 길이값(px)을 꺼낸다.
    func length(_ key: String) -> CGFloat? {
        guard let raw = style[key] else { return nil }
        return MockupNode.parseLength(raw)
    }

    static func parseLength(_ raw: String) -> CGFloat? {
        let trimmed = raw.replacingOccurrences(of: "px", with: "").trimmingCharacters(in: .whitespaces)
        guard let value = Double(trimmed) else { return nil }
        return CGFloat(value)
    }

    /// 문서에서 색을 강조 표시로 쓴 경우(`background:` 인라인)를 해석한다.
    var inlineColor: Color? {
        guard let raw = style["background"] ?? style["color"] else { return nil }
        return MockupPalette.color(css: raw)
    }
}

// MARK: - 문서 CSS 색을 그대로 옮긴 표

enum MockupPalette {
    static func color(css raw: String) -> Color? {
        let value = raw.trimmingCharacters(in: .whitespaces)

        if value.hasPrefix("var(") {
            switch value {
            case "var(--accent)":   return .hgAccent
            case "var(--accent-2)": return .hgAccent2
            case "var(--green)":    return .hgGreen
            case "var(--amber)":    return .hgAmber
            case "var(--red)":      return .hgRed
            case "var(--dim)":      return .hgDim
            case "var(--muted)":    return .hgMuted
            case "var(--line)":     return .hgLine
            default:                return nil
            }
        }

        if value.hasPrefix("rgba(") || value.hasPrefix("rgb(") {
            let numbers = value
                .drop(while: { $0 != "(" }).dropFirst().prefix(while: { $0 != ")" })
                .split(separator: ",")
                .compactMap { Double($0.trimmingCharacters(in: .whitespaces)) }
            guard numbers.count >= 3 else { return nil }
            return Color(
                .sRGB,
                red: numbers[0] / 255,
                green: numbers[1] / 255,
                blue: numbers[2] / 255,
                opacity: numbers.count > 3 ? numbers[3] : 1
            )
        }

        if value.hasPrefix("#") {
            let hex = String(value.dropFirst())
            guard let raw = UInt32(hex, radix: 16) else { return nil }
            return hex.count == 6 ? Color(hex: raw) : nil
        }

        // linear-gradient 등은 대표색으로 대체한다 — 목업에서는 면의 존재만 전달하면 된다.
        if value.contains("linear-gradient") {
            return value.contains("--accent") ? .hgAccent : Color.white.opacity(0.08)
        }
        return nil
    }
}
