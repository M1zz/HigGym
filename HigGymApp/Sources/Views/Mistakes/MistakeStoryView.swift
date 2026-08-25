import SwiftUI

/// 실수 한 편의 회고. 카드가 "무엇을·왜·고치면" 세 줄로 요약이라면,
/// 여기는 그 세 줄이 나온 과정 — 증상에서 시작해 기준에 도착하는 글이다.
///
/// 원본은 `Retrospectives/<id>.md` 이고, 그대로 발행할 수 있게 마크다운으로 둔다.
/// 앱에는 build_mistakes.py 가 절 단위로 잘라 실어준다.
struct MistakeStoryView: View {
    let mistake: Mistake

    /// 절 제목마다 성격이 다르다 — 색으로 흐름(증상 → 원인 → 기준 → 해결)을 보이게 한다.
    private func tint(for heading: String) -> Color {
        switch heading {
        case "증상":                    .hgRed
        case "그때는 왜 그게 맞아 보였나":  .hgAmber
        case "무엇이 부러졌나":            .hgRed
        case "기준":                    .hgAccent2
        case "고친 뒤":                  .hgGreen
        default:                       .hgAccent
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header

                ForEach(mistake.story) { section in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 7) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(tint(for: section.heading))
                                .frame(width: 3, height: 15)
                            Text(section.heading)
                                .font(.callout.weight(.bold))
                                .foregroundStyle(.hgText)
                        }
                        MarkdownText(raw: section.body, font: .callout, color: .hgMuted)
                            .lineSpacing(4)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                footer
            }
            .padding(20)
        }
        .background(Color.hgBackground)
        .navigationTitle("회고 \(mistake.number)")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack(spacing: 7) {
                Text("실수 #\(mistake.number)")
                    .font(.system(.caption, design: .monospaced, weight: .bold))
                    .foregroundStyle(.hgDim)
                Label(mistake.severityLabel, systemImage: mistake.level.symbol)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(mistake.level.color)
            }
            Text(mistake.title)
                .font(.title2.weight(.bold))
                .foregroundStyle(.hgText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, 4)
    }

    private var footer: some View {
        VStack(alignment: .leading, spacing: 8) {
            Divider().background(Color.hgLine)
            Text("근거 · " + mistake.sources.map(\.index).joined(separator: " · "))
                .font(.system(.caption, design: .monospaced))
                .foregroundStyle(.hgDim)
            MarkdownText(raw: mistake.criterion, font: .footnote, color: .hgDim)
        }
        .padding(.top, 6)
    }
}
