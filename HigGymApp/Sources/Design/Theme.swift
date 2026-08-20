import SwiftUI
import UIKit

/// 문서(toolbar-annotated.html)와 같은 팔레트 — 두 매체가 한 교재로 읽히도록.
///
/// 값은 여기 한 곳에서만 정의하고 Color · ShapeStyle 양쪽에 그대로 노출한다.
/// 라이트 모드는 다크 팔레트를 뒤집은 것이 아니라 **같은 역할을 하는 짝**을 따로 골랐다 —
/// 특히 강조색은 흰 배경에서 대비가 무너지므로 한 단계 진한 값을 쓴다(8.1.4 가독성 > 미학).
enum HG {
    static let background = Color(light: 0xF4F6FA, dark: 0x0B0C10)
    static let card       = Color(light: 0xFFFFFF, dark: 0x181B22)
    static let cardHigh   = Color(light: 0xF7F9FD, dark: 0x1E222B)
    static let line       = Color(light: 0xDCE1EA, dark: 0x2A2F3A)
    static let text       = Color(light: 0x14171E, dark: 0xE9EDF4)
    static let muted      = Color(light: 0x525B6B, dark: 0x9AA4B2)
    static let dim        = Color(light: 0x798393, dark: 0x6F7787)
    static let accent     = Color(light: 0x1668E3, dark: 0x5AA8FF)
    static let accent2    = Color(light: 0x5A48D6, dark: 0x7B6CFF)
    static let green      = Color(light: 0x0E8F60, dark: 0x37D39B)
    static let amber      = Color(light: 0xA76A0B, dark: 0xF5B451)
    static let red        = Color(light: 0xD22F2F, dark: 0xFF6B6B)

    /// 카드 안의 은은한 채움. 다크에선 흰색을 아주 옅게, 라이트에선 검정을 아주 옅게.
    static let fill = Color(lightWhite: 0.0, lightAlpha: 0.035, darkWhite: 1.0, darkAlpha: 0.02)
    /// 유리 위에 얹는 실선 테두리. 배경이 뒤집히면 테두리도 뒤집혀야 보인다.
    static let hairline = Color(lightWhite: 0.0, lightAlpha: 0.14, darkWhite: 1.0, darkAlpha: 0.18)
    /// 코드 패널 배경 — 다크에선 더 어둡게, 라이트에선 종이보다 살짝 눌러서.
    static let code = Color(light: 0xEEF1F7, dark: 0x05070B)
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
    static let hgFill       = HG.fill
    static let hgHairline   = HG.hairline
    static let hgCode       = HG.code

    init(hex: UInt32) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: 1
        )
    }

    /// 모드에 따라 갈리는 색. UIKit 의 동적 색으로 만들어야 같은 뷰가 모드 전환에 바로 반응한다.
    init(light: UInt32, dark: UInt32) {
        self.init(uiColor: UIColor { traits in
            UIColor(hex: traits.userInterfaceStyle == .dark ? dark : light)
        })
    }

    /// 흑/백을 옅게 깐 채움처럼, 모드마다 **색과 투명도가 함께** 갈리는 값.
    init(lightWhite: CGFloat, lightAlpha: CGFloat, darkWhite: CGFloat, darkAlpha: CGFloat) {
        self.init(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(white: darkWhite, alpha: darkAlpha)
                : UIColor(white: lightWhite, alpha: lightAlpha)
        })
    }
}

extension UIColor {
    fileprivate convenience init(hex: UInt32) {
        self.init(
            red: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: 1
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
    static var hgFill: Color       { HG.fill }
    static var hgHairline: Color   { HG.hairline }
    static var hgCode: Color       { HG.code }
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
        .background(Color.hgCode, in: .rect(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Color.hgLine, lineWidth: 1))
        .onChange(of: code) { _, _ in copied = false }
    }
}
