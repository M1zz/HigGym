import SwiftUI

/// 8장 원칙 7개 — 실습 판정과 퀴즈 해설이 모두 여기서 나온다.
struct PrinciplesView: View {
    private let store = ContentStore.shared
    @State private var query = ""
    @State private var path: [Entry] = []

    private var filtered: [Entry] {
        guard !query.isEmpty else { return store.principles }
        return store.principles.filter {
            $0.title.localizedCaseInsensitiveContains(query)
                || $0.criterion.localizedCaseInsensitiveContains(query)
                || $0.summary.localizedCaseInsensitiveContains(query)
        }
    }

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 14) {
                    intro
                    ForEach(filtered) { principle in
                        NavigationLink(value: principle) {
                            PrincipleCard(principle: principle)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(18)
            }
            .background(Color.hgBackground)
            .navigationTitle("디자인 원칙")
            .searchable(text: $query, prompt: "원칙·기준 검색")
            .navigationDestination(for: Entry.self) { PrincipleDetailView(principle: $0) }
            .navigationDestination(for: Mistake.self) { MistakeDetailView(mistake: $0) }
            .navigationDestination(for: MistakeStoryRoute.self) { MistakeStoryView(mistake: $0.mistake) }
            .task {
                if let index = DebugLaunch.principleIndex,
                   let principle = store.principles.first(where: { $0.index == index }) {
                    path = [principle]
                }
            }
        }
    }

    private var intro: some View {
        Text("68개 항목을 관통하는 7가지입니다. 원칙마다 **판단 기준이 한 문장**으로 정의돼 있고, 실습의 실시간 판정도 퀴즈의 해설도 전부 이 기준을 근거로 삼습니다.")
            .font(.system(size: 14))
            .foregroundStyle(.hgMuted)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, 4)
    }
}

private struct PrincipleCard: View {
    let principle: Entry

    /// "Content-First · Minimization — UI는 콘텐츠를 위해 물러난다" 를 두 줄로 나눈다.
    private var parts: (name: String, tagline: String?) {
        guard let range = principle.title.range(of: " — ") else { return (principle.title, nil) }
        return (
            String(principle.title[..<range.lowerBound]),
            String(principle.title[range.upperBound...])
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack(spacing: 8) {
                Pill(text: principle.index, color: .hgAccent2)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.hgDim)
            }

            Text(parts.name)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.hgText)

            if let tagline = parts.tagline {
                Text(tagline)
                    .font(.system(size: 13))
                    .foregroundStyle(.hgAccent)
            }

            MarkdownText(raw: principle.criterion, font: .system(size: 13), color: .hgMuted)
                .lineLimit(3)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .hgCard()
    }
}

private struct PrincipleDetailView: View {
    let principle: Entry

    @State private var runningDemo: EntryDemo?

    private var demo: EntryDemo? { EntryDemos.demo(for: principle) }


    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Pill(text: principle.index, color: .hgAccent2)
                    Text(principle.title)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.hgText)
                    MarkdownText(raw: principle.summary, font: .system(size: 14), color: .hgMuted)
                }

                block("기준", principle.criterion, .hgAmber, "scope")

                // 원칙은 어겼을 때와 지켰을 때를 나란히 만져봐야 몸에 남는다.
                if let demo {
                    DemoLaunchCard(entry: principle) { runningDemo = demo }
                }

                if !principle.good.isEmpty {
                    examples("기준을 통과한 예", principle.good, .hgGreen, "checkmark.circle.fill")
                }
                if !principle.bad.isEmpty {
                    examples("기준을 위반한 예", principle.bad, .hgRed, "xmark.octagon.fill")
                }

                if !principle.refs.isEmpty {
                    references
                }
            }
            .padding(18)
        }
        .background(Color.hgBackground)
        .navigationTitle("원칙 \(principle.index)")
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(item: $runningDemo) { demo in
            EntryDemoStage(entry: principle, demo: demo)
        }
        .onAppear { if DebugLaunch.autoDemo { runningDemo = demo } }
    }

    private func block(_ title: String, _ body: String, _ tint: Color, _ symbol: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: symbol)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(tint)
            MarkdownText(raw: body, font: .system(size: 14.5), color: .hgText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(15)
        .background(tint.opacity(0.07), in: .rect(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(tint.opacity(0.25), lineWidth: 1))
    }

    private func examples(
        _ title: String, _ items: [String], _ tint: Color, _ symbol: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 9) {
            Label(title, systemImage: symbol)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(tint)

            ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                MarkdownText(raw: item, font: .system(size: 13.5), color: .hgText)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(13)
                    .background(Color.hgCard, in: .rect(cornerRadius: 12))
                    .overlay(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(tint)
                            .frame(width: 3)
                            .padding(.vertical, 9)
                    }
            }
        }
    }

    private var references: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("참고 자료", systemImage: "link")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(.hgDim)
            ForEach(principle.refs, id: \.url) { ref in
                Link(destination: URL(string: ref.url) ?? URL(string: "https://developer.apple.com")!) {
                    HStack(spacing: 6) {
                        Text(ref.title)
                            .font(.system(size: 12.5))
                            .multilineTextAlignment(.leading)
                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 10))
                    }
                    .foregroundStyle(.hgAccent)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 4)
    }
}
