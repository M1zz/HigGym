import SwiftUI

/// 한 항목의 화면 — 목업이 위에 있고 설명이 그 그림에 붙는다.
struct EntryDetailView: View {
    let entry: Entry

    @State private var selectedPart: MockupPart?
    @State private var presentedLab: LabID?
    @State private var runningDemo: EntryDemo?

    private var lab: LabID? { LabID.forSection(entry.section) }
    private var demo: EntryDemo? { EntryDemos.demo(for: entry) }
    /// 이 항목이 근거가 된 실수들 — 100편 쪽에서 같은 자리를 반대편에서 본 것.
    private var mistakes: [Mistake] { MistakeStore.shared.mistakes(citing: entry.index) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                summary
                if let demo {
                    DemoLaunchCard(entry: entry) { runningDemo = demo }
                }
                stage
                rows
                if !mistakes.isEmpty { mistakeLinks }
                if let lab { labLink(lab) }
                if !entry.refs.isEmpty { references }
            }
            .padding(18)
        }
        .background(Color.hgBackground)
        .navigationTitle(entry.index)
        .navigationBarTitleDisplayMode(.inline)
        // 예제는 push 가 아니라 전체 화면으로 — EntryDemoStage 주석 참고.
        .fullScreenCover(item: $runningDemo) { demo in
            EntryDemoStage(entry: entry, demo: demo)
        }
        .onAppear { if DebugLaunch.autoDemo { runningDemo = demo } }
        .fullScreenCover(item: $presentedLab) { labDestination($0) }
    }

    // MARK: 목업 — 이 화면의 근간

    private var stage: some View {
        VStack(spacing: 12) {
            MockupView(
                nodes: entry.mockup,
                scale: 1.55,
                selected: selectedPart,
                onSelect: { part in
                    withAnimation(.snappy(duration: 0.2)) {
                        selectedPart = selectedPart == part ? nil : part
                    }
                }
            )
            .frame(maxWidth: .infinity)

            if !entry.caption.isEmpty {
                MarkdownText(raw: entry.caption, font: .system(size: 12), color: .hgDim)
                    .multilineTextAlignment(.center)
            }

            if let part = selectedPart {
                partCallout(part)
            } else {
                Text("그림의 부위를 눌러보세요")
                    .font(.system(size: 11.5))
                    .foregroundStyle(.hgDim)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .background(Color.hgCard, in: .rect(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).strokeBorder(Color.hgLine, lineWidth: 1))
    }

    private func partCallout(_ part: MockupPart) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Text(part.name)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.hgAmber)
                Spacer()
                Text(part.source)
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(.hgDim)
            }
            MarkdownText(raw: part.meaning, font: .system(size: 12.5), color: .hgText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(13)
        .background(Color.hgAmber.opacity(0.08), in: .rect(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(Color.hgAmber.opacity(0.3), lineWidth: 1))
        .padding(.horizontal, 16)
        .transition(.opacity.combined(with: .move(edge: .bottom)))
    }

    private var summary: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(entry.title)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(.hgText)
            MarkdownText(raw: entry.summary, font: .system(size: 14), color: .hgMuted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var rows: some View {
        VStack(spacing: 9) {
            row("어느 상황에서", entry.when, .hgGreen, "questionmark.circle")
            row("왜 이렇게", entry.why, .hgAccent2, "lightbulb")
            row("Tip", entry.tip, .hgAmber, "hand.raised")
            row("iOS 27", entry.ios27, .hgAmber, "sparkles")
            examples("적절한 예", entry.good, .hgGreen, "checkmark.circle.fill")
            examples("잘못된 예", entry.bad, .hgRed, "xmark.octagon.fill")
        }
    }

    @ViewBuilder
    private func row(_ label: String, _ body: String, _ tint: Color, _ symbol: String) -> some View {
        if !body.isEmpty {
            VStack(alignment: .leading, spacing: 6) {
                Label(label, systemImage: symbol)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(tint)
                MarkdownText(raw: body, font: .system(size: 13.5), color: .hgText)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(13)
            .background(Color.hgFill, in: .rect(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(Color.hgLine, lineWidth: 1))
        }
    }

    @ViewBuilder
    private func examples(_ label: String, _ items: [String], _ tint: Color, _ symbol: String) -> some View {
        if !items.isEmpty {
            VStack(alignment: .leading, spacing: 7) {
                Label(label, systemImage: symbol)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(tint)
                ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                    MarkdownText(raw: item, font: .system(size: 13), color: .hgText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(13)
            .background(tint.opacity(0.05), in: .rect(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(tint.opacity(0.22), lineWidth: 1))
        }
    }

    /// 항목에서 실수로, 실수에서 다시 항목으로 — 양쪽이 서로를 가리켜야 교재가 된다.
    private var mistakeLinks: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("여기서 나온 실수 \(mistakes.count)개", systemImage: "exclamationmark.triangle.fill")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(.hgAmber)

            ForEach(mistakes) { mistake in
                NavigationLink(value: mistake) {
                    HStack(spacing: 9) {
                        Text("#\(mistake.number)")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundStyle(mistake.level.color)
                        Text(mistake.title)
                            .font(.system(size: 13))
                            .foregroundStyle(.hgText)
                            .multilineTextAlignment(.leading)
                            .lineLimit(2)
                        Spacer(minLength: 0)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(.hgDim)
                    }
                    .padding(11)
                    .background(Color.hgCard, in: .rect(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(Color.hgAmber.opacity(0.25), lineWidth: 1))
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func labLink(_ lab: LabID) -> some View {
        Button {
            presentedLab = lab
        } label: {
            HStack(spacing: 10) {
                Image(systemName: lab.symbol)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 36, height: 36)
                    .background(.hgBrand, in: .rect(cornerRadius: 10))
                VStack(alignment: .leading, spacing: 1) {
                    Text("\(lab.title)에서 직접 해보기")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.hgText)
                    Text(lab.subtitle)
                        .font(.system(size: 11.5))
                        .foregroundStyle(.hgDim)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.hgDim)
            }
            .padding(12)
            .background(Color.hgCard, in: .rect(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Color.hgAccent.opacity(0.3), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    private var references: some View {
        VStack(alignment: .leading, spacing: 7) {
            Label("참고 자료", systemImage: "link")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(.hgDim)
            ForEach(entry.refs, id: \.url) { ref in
                if let url = URL(string: ref.url) {
                    Link(destination: url) {
                        HStack(spacing: 5) {
                            Text(ref.title)
                                .font(.system(size: 12))
                                .multilineTextAlignment(.leading)
                            Image(systemName: "arrow.up.right").font(.system(size: 9))
                        }
                        .foregroundStyle(.hgAccent)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
