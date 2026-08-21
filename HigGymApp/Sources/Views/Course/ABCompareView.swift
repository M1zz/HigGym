import SwiftUI

/// 어긴 화면과 고친 화면을 **같은 자리에서 즉시 갈아 끼우는** 비교기.
///
/// 두 화면을 나란히 놓으면 각각이 절반으로 줄어 정작 봐야 할 것(글자 크기, 버튼이 닿는 자리)이
/// 사라진다. 그래서 한 화면을 실제 크기로 두고 위에서 갈아 끼운다 — 자리가 고정된 채 바뀌니
/// 달라진 지점만 도드라진다. 두 화면 모두 살려 두어 오가도 스크롤·상태가 유지된다.
struct ABCompareView: View {
    let knob: NoteAppConfig.Knob
    /// 무엇이 달라졌는지 한 줄.
    let diff: String
    var showsSpotlight = true

    @State private var side = Side.broken

    private enum Side: String, CaseIterable, Identifiable {
        case broken, fixed
        var id: String { rawValue }
        var label: String { self == .broken ? "이렇게 했다" : "이렇게 고쳤다" }
        var tint: Color { self == .broken ? .hgRed : .hgGreen }
        var symbol: String { self == .broken ? "xmark.octagon.fill" : "checkmark.seal.fill" }
    }

    var body: some View {
        VStack(spacing: 0) {
            switcher

            ZStack {
                // 둘 다 그려 두고 보이는 쪽만 만지게 한다. 오갈 때마다 새로 그리면
                // 스크롤 위치가 초기화돼 "같은 자리에서 바뀐다"는 전제가 깨진다.
                screen(.broken)
                screen(.fixed)
            }
            .clipShape(.rect(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(side.tint.opacity(0.55), lineWidth: 2)
            )
            .padding(.horizontal, 8)

            caption
        }
        .background(Color.hgBackground)
    }

    @ViewBuilder
    private func screen(_ target: Side) -> some View {
        let config = target == .fixed ? NoteAppConfig.recommended : NoteAppConfig.recommended.flipping(knob)
        knob.surface(config, spotlight: showsSpotlight ? knob : nil)
            .opacity(side == target ? 1 : 0)
            .allowsHitTesting(side == target)
            .accessibilityHidden(side != target)
    }

    private var switcher: some View {
        VStack(spacing: 6) {
            Picker("비교", selection: $side.animation(.snappy(duration: 0.15))) {
                ForEach(Side.allCases) { option in
                    Text(option.label).tag(option)
                }
            }
            .pickerStyle(.segmented)

            HStack(spacing: 5) {
                Image(systemName: side.symbol).font(.system(size: 10))
                Text(side == .broken ? "지금 보는 건 어긴 화면입니다" : "지금 보는 건 고친 화면입니다")
                    .font(.system(size: 11, weight: .semibold))
            }
            .foregroundStyle(side.tint)
        }
        .padding(.horizontal, 14)
        .padding(.bottom, 8)
    }

    private var caption: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "arrow.left.arrow.right")
                .font(.system(size: 11))
                .foregroundStyle(.hgAccent2)
                .padding(.top, 1)
            MarkdownText(raw: diff, font: .system(size: 12.5), color: .hgMuted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color.hgCard, in: .rect(cornerRadius: 12))
        .padding(.horizontal, 12)
        .padding(.top, 8)
    }
}
