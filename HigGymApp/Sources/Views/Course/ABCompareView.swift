import SwiftUI

/// 어긴 화면과 고친 화면을 **같은 자리에서 즉시 갈아 끼우는** 비교기.
///
/// 두 화면을 나란히 놓으면 각각이 절반으로 줄어 정작 봐야 할 것(글자 크기, 버튼이 닿는 자리)이
/// 사라진다. 그래서 한 화면을 실제 크기로 두고 위에서 갈아 끼운다 — 자리가 고정된 채 바뀌니
/// 달라진 지점만 도드라진다. 두 화면 모두 살려 두어 오가도 스크롤·상태가 유지된다.
struct ABCompareView<Broken: View, Fixed: View>: View {
    /// 무엇이 달라졌는지 한 줄. 비어 있으면 캡션을 그리지 않는다.
    var diff: String?
    /// 지금 보고 있는 쪽에 붙는 설명.
    var brokenNote: String?
    var fixedNote: String?
    /// 레슨에서는 어긴 쪽을 이미 겪은 뒤라 고친 쪽부터 보여준다.
    var startOnFixed = false
    @ViewBuilder var broken: Broken
    @ViewBuilder var fixed: Fixed

    @State private var side: Side?

    private enum Side: String, CaseIterable, Identifiable {
        case broken, fixed
        var id: String { rawValue }
        var label: String { self == .broken ? "이렇게 했다" : "이렇게 고쳤다" }
        var tint: Color { self == .broken ? .hgRed : .hgGreen }
        var symbol: String { self == .broken ? "xmark.octagon.fill" : "checkmark.seal.fill" }
    }

    private var current: Side { side ?? (startOnFixed ? .fixed : .broken) }

    var body: some View {
        VStack(spacing: 0) {
            switcher

            ZStack {
                // 둘 다 그려 두고 보이는 쪽만 만지게 한다. 오갈 때마다 새로 그리면
                // 스크롤 위치가 초기화돼 "같은 자리에서 바뀐다"는 전제가 깨진다.
                broken
                    .opacity(current == .broken ? 1 : 0)
                    .allowsHitTesting(current == .broken)
                    .accessibilityHidden(current != .broken)
                fixed
                    .opacity(current == .fixed ? 1 : 0)
                    .allowsHitTesting(current == .fixed)
                    .accessibilityHidden(current != .fixed)
            }
            .clipShape(.rect(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(current.tint.opacity(0.55), lineWidth: 2)
            )
            .padding(.horizontal, 8)

            caption
        }
        .background(Color.hgBackground)
    }

    private var switcher: some View {
        VStack(spacing: 6) {
            Picker("비교", selection: Binding(
                get: { current },
                set: { side = $0 }
            ).animation(.snappy(duration: 0.15))) {
                ForEach(Side.allCases) { option in
                    Text(option.label).tag(option)
                }
            }
            .pickerStyle(.segmented)

            HStack(spacing: 5) {
                Image(systemName: current.symbol).font(.caption)
                Text(activeNote)
                    .font(.caption.weight(.semibold))
                    .multilineTextAlignment(.center)
            }
            .foregroundStyle(current.tint)
        }
        .padding(.horizontal, 14)
        .padding(.bottom, 8)
    }

    private var activeNote: String {
        let note = current == .broken ? brokenNote : fixedNote
        return note ?? (current == .broken ? "지금 보는 건 어긴 화면입니다" : "지금 보는 건 고친 화면입니다")
    }

    @ViewBuilder
    private var caption: some View {
        if let diff {
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "arrow.left.arrow.right")
                    .font(.caption)
                    .foregroundStyle(.hgAccent2)
                    .padding(.top, 1)
                MarkdownText(raw: diff, font: .footnote, color: .hgMuted)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(Color.hgCard, in: .rect(cornerRadius: 12))
            .padding(.horizontal, 12)
            .padding(.top, 8)
        }
    }
}

// MARK: - 표본 앱의 결정 하나를 뒤집어 비교하기

extension ABCompareView where Broken == AnyView, Fixed == AnyView {
    /// 레슨이 쓰는 형태 — 결정 하나만 뒤집은 같은 앱 두 벌.
    init(knob: NoteAppConfig.Knob, diff: String, showsSpotlight: Bool = true, startOnFixed: Bool = false) {
        self.init(
            diff: diff,
            brokenNote: nil,
            fixedNote: nil,
            startOnFixed: startOnFixed,
            broken: {
                AnyView(
                    knob.surface(
                        NoteAppConfig.recommended.flipping(knob),
                        spotlight: showsSpotlight ? knob : nil
                    )
                )
            },
            fixed: {
                AnyView(knob.surface(.recommended, spotlight: showsSpotlight ? knob : nil))
            }
        )
    }
}
