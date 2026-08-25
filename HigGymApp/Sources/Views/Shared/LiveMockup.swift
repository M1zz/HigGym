import SwiftUI

/// 실습의 라이브 미리보기 — 설정이 바뀔 때마다 문서와 같은 목업으로 다시 그려진다.
///
/// 그림의 부위를 누르면 그 자리가 무엇을 말하는지 알려주므로,
/// 배치를 만드는 동안에도 설명이 손끝에 붙어 있다.
struct LiveMockup: View {
    let nodes: [MockupNode]
    var caption: String?
    @Binding var selected: MockupPart?

    var body: some View {
        VStack(spacing: 12) {
            MockupView(
                nodes: nodes,
                scale: 1.5,
                selected: selected,
                onSelect: { part in
                    withAnimation(.snappy(duration: 0.2)) {
                        selected = selected == part ? nil : part
                    }
                }
            )

            if let part = selected {
                callout(part)
            } else if let caption {
                Text(caption)
                    .font(.caption)
                    .foregroundStyle(.hgDim)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.hgCard, in: .rect(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).strokeBorder(Color.hgLine, lineWidth: 1))
    }

    private func callout(_ part: MockupPart) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack(spacing: 6) {
                Text(part.name)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.hgAmber)
                Spacer()
                Text(part.source)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundStyle(.hgDim)
            }
            MarkdownText(raw: part.meaning, font: .footnote, color: .hgText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color.hgAmber.opacity(0.08), in: .rect(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(Color.hgAmber.opacity(0.3), lineWidth: 1))
        .padding(.horizontal, 14)
        .transition(.opacity.combined(with: .move(edge: .bottom)))
    }
}
