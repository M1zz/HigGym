import SwiftUI

/// 실수 한 편. 회고 한 편이 그대로 화면이 된 구조다 —
/// **무엇을 했나 → 그때는 왜 맞아 보였나 → 판단 기준 → 고치면 → 직접 해보기 → 근거**.
///
/// 가운데의 "직접 해보기"가 이 화면의 심장이다. 읽고 끄덕이는 것과
/// 자기 손으로 어겨보고 고쳐보는 것은 남는 것이 다르다.
/// 실수 상세에서 회고로 가는 경로. Mistake 자체를 값으로 쓰면 실수 상세가 다시 열리므로 감싼다.
struct MistakeStoryRoute: Hashable {
    let mistake: Mistake
}

struct MistakeDetailView: View {
    let mistake: Mistake

    @Environment(ProgressStore.self) private var progress
    @State private var runningDemo: EntryDemo?

    private let entries = ContentStore.shared
    private let store = MistakeStore.shared

    private var demoEntry: Entry? {
        (entries.entries + entries.principles).first { $0.id == mistake.demoEntryID }
    }
    private var category: MistakeCategory? { store.category(mistake.category) }
    /// 전용 예제(어긴 화면 ↔ 고친 화면)가 있으면 그것이 우선. 없으면 관련 항목 예제로 보낸다.
    private var dedicated: EntryDemo? { MistakeDemos.demo(for: mistake) }
    private var checked: Bool { progress.isChecked(mistake) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                head
                block("그때는 왜 그게 맞아 보였나", mistake.why, .hgAmber, "quote.opening")
                criterionBlock
                block("고치면", mistake.fix, .hgGreen, "checkmark.seal")
                if mistake.hasStory { storyLink }
                tryItCard
                sourcesSection
                if !mistake.refs.isEmpty { references }
                checkButton
            }
            .padding(18)
        }
        .background(Color.hgBackground)
        .navigationTitle("실수 \(mistake.number)")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if DebugLaunch.autoDemo {
                runningDemo = dedicated ?? demoEntry.flatMap { EntryDemos.demo(for: $0) }
            }
        }
        .fullScreenCover(item: $runningDemo) { demo in
            if demo.id == mistake.id {
                EntryDemoStage(info: DemoGuideInfo(mistake: mistake), demo: demo)
            } else if let demoEntry {
                EntryDemoStage(entry: demoEntry, demo: demo)
            }
        }
    }

    // MARK: 실수 자체

    private var head: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 7) {
                Text("#\(mistake.number)")
                    .font(.system(.caption, design: .monospaced, weight: .bold))
                    .foregroundStyle(.hgDim)
                if let category {
                    Label(category.title, systemImage: category.symbol)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(category.color)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(category.color.opacity(0.12), in: .capsule)
                }
                Spacer()
                Label(mistake.severityLabel, systemImage: mistake.level.symbol)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(mistake.level.color)
            }

            Text(mistake.title)
                .font(.title3.weight(.bold))
                .foregroundStyle(.hgText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var criterionBlock: some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack(spacing: 6) {
                Label("판단 기준", systemImage: "scope")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.hgAccent2)
                Spacer()
                if let principle = category?.principle, !principle.isEmpty {
                    Text("원칙 \(principle)")
                        .font(.system(.caption, design: .monospaced))
                        .foregroundStyle(.hgDim)
                }
            }
            MarkdownText(
                raw: mistake.criterion.isEmpty ? (category?.desc ?? "") : mistake.criterion,
                font: .subheadline,
                color: .hgText
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color.hgAccent2.opacity(0.07), in: .rect(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Color.hgAccent2.opacity(0.25), lineWidth: 1))
    }

    private func block(_ title: String, _ body: String, _ tint: Color, _ symbol: String) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            Label(title, systemImage: symbol)
                .font(.caption.weight(.bold))
                .foregroundStyle(tint)
            MarkdownText(raw: body, font: .subheadline, color: .hgText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(tint.opacity(0.06), in: .rect(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(tint.opacity(0.22), lineWidth: 1))
    }

    /// 회고가 있는 편은 카드 세 줄 뒤에 "어쩌다 그렇게 됐는지"를 읽을 수 있다.
    private var storyLink: some View {
        NavigationLink(value: MistakeStoryRoute(mistake: mistake)) {
            HStack(spacing: 12) {
                Image(systemName: "text.book.closed.fill")
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(width: 36, height: 36)
                    .background(Color.hgAmber, in: .rect(cornerRadius: 10))
                VStack(alignment: .leading, spacing: 1) {
                    Text("회고 읽기")
                        .font(.callout.weight(.bold))
                        .foregroundStyle(.hgText)
                    Text("증상에서 기준까지 — 어쩌다 이 실수를 하게 됐는가")
                        .font(.caption)
                        .foregroundStyle(.hgDim)
                }
                Spacer(minLength: 4)
                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.hgDim)
            }
            .padding(13)
            .background(Color.hgCard, in: .rect(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(Color.hgAmber.opacity(0.45), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    // MARK: 직접 해보기

    @ViewBuilder
    private var tryItCard: some View {
        if let dedicated {
            Button { runningDemo = dedicated } label: {
                HStack(spacing: 10) {
                    Image(systemName: "rectangle.split.2x1.fill")
                        .font(.callout.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(width: 36, height: 36)
                        .background(.hgBrand, in: .rect(cornerRadius: 10))
                    VStack(alignment: .leading, spacing: 1) {
                        HStack(spacing: 5) {
                            Text("이 실수 전용 예제")
                                .font(.callout.weight(.bold))
                                .foregroundStyle(.hgText)
                            Text("전용")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(.hgGreen)
                                .padding(.horizontal, 5).padding(.vertical, 2)
                                .background(Color.hgGreen.opacity(0.15), in: .capsule)
                        }
                        Text("어긴 화면과 고친 화면을 나란히 — 둘 다 실제로 동작합니다")
                            .font(.caption)
                            .foregroundStyle(.hgDim)
                            .multilineTextAlignment(.leading)
                    }
                    Spacer(minLength: 4)
                    Image(systemName: "chevron.right")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.hgDim)
                }
                .padding(13)
                .background(Color.hgCard, in: .rect(cornerRadius: 16))
                .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(Color.hgGreen.opacity(0.45), lineWidth: 1))
            }
            .buttonStyle(.plain)
        } else if let demoEntry, let demo = EntryDemos.demo(for: demoEntry) {
            VStack(alignment: .leading, spacing: 10) {
                // 원칙(8장)에는 목업이 없다 — 그림이 없으면 카드만 남긴다.
                if !demoEntry.mockup.isEmpty {
                    MockupView(nodes: demoEntry.mockup, scale: 1.15, selected: nil, onSelect: { _ in })
                        .frame(maxWidth: .infinity)
                }

                Button { runningDemo = demo } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "play.rectangle.fill")
                            .font(.callout.weight(.semibold))
                            .foregroundStyle(.white)
                            .frame(width: 36, height: 36)
                            .background(.hgBrand, in: .rect(cornerRadius: 10))
                        VStack(alignment: .leading, spacing: 1) {
                            Text("직접 해보기")
                                .font(.callout.weight(.bold))
                                .foregroundStyle(.hgText)
                            Text("\(demoEntry.index) \(demoEntry.title) 예제에서 손으로 확인")
                                .font(.caption)
                                .foregroundStyle(.hgDim)
                                .lineLimit(2)
                                .multilineTextAlignment(.leading)
                        }
                        Spacer(minLength: 4)
                        Image(systemName: "chevron.right")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(.hgDim)
                    }
                }
                .buttonStyle(.plain)
            }
            .padding(14)
            .background(Color.hgCard, in: .rect(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(Color.hgAccent.opacity(0.4), lineWidth: 1))
        }
    }

    // MARK: 근거

    private var sourcesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("근거가 되는 본문 항목", systemImage: "text.book.closed")
                .font(.caption.weight(.bold))
                .foregroundStyle(.hgDim)

            ForEach(mistake.sources, id: \.index) { source in
                if let entry = (entries.entries + entries.principles).first(where: { $0.id == source.entryID }) {
                    NavigationLink(value: entry) {
                        HStack(spacing: 9) {
                            Pill(text: source.index, color: .hgAccent)
                            Text(source.title)
                                .font(.subheadline)
                                .foregroundStyle(.hgText)
                                .multilineTextAlignment(.leading)
                                .lineLimit(2)
                            Spacer(minLength: 0)
                            Image(systemName: "chevron.right")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.hgDim)
                        }
                        .padding(11)
                        .background(Color.hgFill, in: .rect(cornerRadius: 12))
                        .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(Color.hgLine, lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var references: some View {
        VStack(alignment: .leading, spacing: 7) {
            Label("참고 자료", systemImage: "link")
                .font(.caption.weight(.bold))
                .foregroundStyle(.hgDim)
            ForEach(mistake.refs, id: \.url) { ref in
                if let url = URL(string: ref.url) {
                    Link(destination: url) {
                        HStack(spacing: 5) {
                            Text(ref.title)
                                .font(.footnote)
                                .multilineTextAlignment(.leading)
                            Image(systemName: "arrow.up.right").font(.caption)
                        }
                        .foregroundStyle(.hgAccent)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var checkButton: some View {
        Button {
            withAnimation(.snappy) { progress.toggleMistake(mistake.id) }
        } label: {
            Label(
                checked ? "겪어본 실수로 표시됨" : "이건 나도 해봤다",
                systemImage: checked ? "checkmark.circle.fill" : "circle"
            )
            .font(.callout.weight(.semibold))
            .foregroundStyle(checked ? .hgGreen : .hgText)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 13)
            .background((checked ? Color.hgGreen : Color.hgCard).opacity(checked ? 0.14 : 1), in: .rect(cornerRadius: 13))
            .overlay(
                RoundedRectangle(cornerRadius: 13)
                    .strokeBorder((checked ? Color.hgGreen : Color.hgLine).opacity(checked ? 0.4 : 1), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .padding(.top, 4)
    }
}
