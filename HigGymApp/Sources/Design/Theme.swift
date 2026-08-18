import SwiftUI
import UIKit

/// 문서(toolbar-annotated.html)와 같은 팔레트 — 두 매체가 한 교재로 읽히도록.
/// 한 곳에서만 값을 정의하고 Color · ShapeStyle 양쪽에 그대로 노출한다.
enum HG {
    static let background = Color(hex: 0x0B0C10)
    static let card       = Color(hex: 0x181B22)
    static let cardHigh   = Color(hex: 0x1E222B)
    static let line       = Color(hex: 0x2A2F3A)
    static let text       = Color(hex: 0xE9EDF4)
    static let muted      = Color(hex: 0x9AA4B2)
    static let dim        = Color(hex: 0x6F7787)
    static let accent     = Color(hex: 0x5AA8FF)
    static let accent2    = Color(hex: 0x7B6CFF)
    static let green      = Color(hex: 0x37D39B)
    static let amber      = Color(hex: 0xF5B451)
    static let red        = Color(hex: 0xFF6B6B)
}

extension Color {
    static let hgBackground = HG.background
    static let hgCard       = HG.card
    static let hgCardHigh   = HG.cardHigh
    static let hgLine       = HG.line
    static let hgText       = HG.text
    static let hgMuted      = HG.muted
    static let hgDim        = HG.dim
    static let hgAccent     = HG.accent
    static let hgAccent2    = HG.accent2
    static let hgGreen      = HG.green
    static let hgAmber      = HG.amber
    static let hgRed        = HG.red

    init(hex: UInt32) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: 1
        )
    }
}

/// `.foregroundStyle(.hgDim)` 처럼 짧게 쓰기 위한 노출.
extension ShapeStyle where Self == Color {
    static var hgBackground: Color { HG.background }
    static var hgCard: Color       { HG.card }
    static var hgCardHigh: Color   { HG.cardHigh }
    static var hgLine: Color       { HG.line }
    static var hgText: Color       { HG.text }
    static var hgMuted: Color      { HG.muted }
    static var hgDim: Color        { HG.dim }
    static var hgAccent: Color     { HG.accent }
    static var hgAccent2: Color    { HG.accent2 }
    static var hgGreen: Color      { HG.green }
    static var hgAmber: Color      { HG.amber }
    static var hgRed: Color        { HG.red }
}

extension ShapeStyle where Self == LinearGradient {
    /// 챕터 번호 배지 등에 쓰는 문서와 동일한 그라디언트.
    static var hgBrand: LinearGradient {
        LinearGradient(
            colors: [.hgAccent, .hgAccent2],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

/// 문서에서 뽑아온 텍스트는 **굵게**·`코드`·[링크](url) 마크다운을 포함한다.
struct MarkdownText: View {
    let raw: String
    var font: Font = .body
    var color: Color = .hgText

    var body: some View {
        Text(attributed)
            .font(font)
            .foregroundStyle(color)
            .tint(.hgAccent)
    }

    private var attributed: AttributedString {
        (try? AttributedString(
            markdown: raw,
            options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace)
        )) ?? AttributedString(raw)
    }
}

/// 항목 카드·실습 패널의 공통 배경.
struct CardBackground: ViewModifier {
    var tint: Color = .hgLine
    func body(content: Content) -> some View {
        content
            .padding(16)
            .background(Color.hgCard, in: .rect(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(tint.opacity(0.6), lineWidth: 1))
    }
}

extension View {
    func hgCard(tint: Color = .hgLine) -> some View { modifier(CardBackground(tint: tint)) }
}

/// 라벨 배지 — 문서의 .pill 과 같은 역할.
struct Pill: View {
    let text: String
    var color: Color = .hgAccent

    var body: some View {
        Text(text)
            .font(.system(size: 11, weight: .bold, design: .monospaced))
            .foregroundStyle(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(color.opacity(0.12), in: .capsule)
            .overlay(Capsule().strokeBorder(color.opacity(0.28), lineWidth: 1))
    }
}

/// 실습 화면에서 "지금 이 설정이 어떤 기준을 지키고 어기는지" 알려주는 진단 결과.
struct Diagnosis: Identifiable, Hashable {
    enum Level: Int, Comparable {
        case good, caution, violation
        static func < (a: Level, b: Level) -> Bool { a.rawValue < b.rawValue }

        var color: Color {
            switch self {
            case .good:      .hgGreen
            case .caution:   .hgAmber
            case .violation: .hgRed
            }
        }
        var symbol: String {
            switch self {
            case .good:      "checkmark.seal.fill"
            case .caution:   "exclamationmark.triangle.fill"
            case .violation: "xmark.octagon.fill"
            }
        }
        var label: String {
            switch self {
            case .good:      "기준 통과"
            case .caution:   "주의"
            case .violation: "원칙 위반"
            }
        }
    }

    var id: String { source + message }
    let level: Level
    let message: String
    let source: String      // 근거가 되는 본문 항목 번호
}

struct DiagnosisRow: View {
    let diagnosis: Diagnosis

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: diagnosis.level.symbol)
                .foregroundStyle(diagnosis.level.color)
                .font(.system(size: 14))
                .padding(.top, 1)
            VStack(alignment: .leading, spacing: 4) {
                MarkdownText(raw: diagnosis.message, font: .system(size: 13.5), color: .hgText)
                Text(diagnosis.source)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundStyle(.hgDim)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(diagnosis.level.color.opacity(0.07), in: .rect(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(diagnosis.level.color.opacity(0.25), lineWidth: 1)
        )
    }
}

/// 실습마다 "이건 실제 어떤 SwiftUI 코드인가"를 같이 보여준다 — 교구의 핵심.
struct CodePanel: View {
    let code: String
    /// 실습에서는 설정으로부터 "생성된" 코드지만, 예제에서는 그 화면을 만든 코드 자체다.
    var title: String = "생성된 SwiftUI"
    @State private var copied = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label(title, systemImage: "curlybraces")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.hgDim)
                Spacer()
                Button {
                    UIPasteboard.general.string = code
                    withAnimation { copied = true }
                } label: {
                    Label(copied ? "복사됨" : "복사", systemImage: copied ? "checkmark" : "doc.on.doc")
                        .font(.system(size: 12, weight: .semibold))
                }
                .buttonStyle(.borderless)
                .tint(.hgAccent)
            }
            ScrollView(.horizontal, showsIndicators: false) {
                Text(code)
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundStyle(.hgText)
                    .textSelection(.enabled)
            }
        }
        .padding(14)
        .background(Color.black.opacity(0.35), in: .rect(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Color.hgLine, lineWidth: 1))
        .onChange(of: code) { _, _ in copied = false }
    }
}
