import SwiftUI

/// 68개 항목 브라우저 — 앱의 기본 화면.
/// 각 항목은 문서와 똑같은 목업으로 먼저 보여주고, 설명은 그 그림에 붙는다.
struct EntriesHomeView: View {
    @Environment(Router.self) private var router
    private let store = ContentStore.shared

    @State private var query = ""

    private var visibleChapters: [ChapterInfo] {
        store.chapters.filter { chapter in
            query.isEmpty || !entries(in: chapter.number).isEmpty
        }
    }

    private func entries(in chapter: Int) -> [Entry] {
        let all = store.entries(chapter: chapter)
        guard !query.isEmpty else { return all }
        return all.filter {
            $0.title.localizedCaseInsensitiveContains(query)
                || $0.summary.localizedCaseInsensitiveContains(query)
                || $0.when.localizedCaseInsensitiveContains(query)
                || $0.index.contains(query)
        }
    }

    var body: some View {
        @Bindable var router = router

        NavigationStack(path: $router.entryPath) {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 22, pinnedViews: [.sectionHeaders]) {
                    if query.isEmpty { intro }

                    ForEach(visibleChapters) { chapter in
                        Section {
                            ForEach(sections(in: chapter.number), id: \.self) { section in
                                sectionBlock(section, chapter: chapter.number)
                            }
                        } header: {
                            ChapterHeader(chapter: chapter)
                        }
                    }
                }
                .padding(.horizontal, 18)
                .padding(.bottom, 32)
            }
            .background(Color.hgBackground)
            .navigationTitle("항목")
            .searchable(text: $query, prompt: "항목·상황 검색")
            .navigationDestination(for: Entry.self) { EntryDetailView(entry: $0) }
            .navigationDestination(for: Mistake.self) { MistakeDetailView(mistake: $0) }
            .navigationDestination(for: MistakeStoryRoute.self) { MistakeStoryView(mistake: $0.mistake) }
            .task {
                if let index = DebugLaunch.entryIndex, let entry = store.entry(index: index) {
                    router.entryPath = [entry]
                }
            }
        }
    }

    private func sections(in chapter: Int) -> [String] {
        var seen: [String] = []
        for entry in entries(in: chapter) where !seen.contains(entry.section) {
            seen.append(entry.section)
        }
        return seen
    }

    @ViewBuilder
    private func sectionBlock(_ section: String, chapter: Int) -> some View {
        let items = entries(in: chapter).filter { $0.section == section }

        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Text(section)
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundStyle(.hgAccent)
                Text(items.first?.sectionTitle ?? "")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.hgText)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 14) {
                    ForEach(items) { entry in
                        NavigationLink(value: entry) {
                            EntryThumbnail(entry: entry)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 2)
            }
        }
    }

    private var intro: some View {
        Text("항목마다 문서와 같은 목업이 먼저 나옵니다. 그림의 **아무 부위나 누르면** 그 자리가 무엇을 말하는지 알려주고, **예제 보기**로 같은 화면을 직접 만져볼 수 있습니다.")
            .font(.system(size: 14))
            .foregroundStyle(.hgMuted)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct ChapterHeader: View {
    let chapter: ChapterInfo

    var body: some View {
        HStack(spacing: 10) {
            Text("\(chapter.number)")
                .font(.system(size: 14, weight: .bold, design: .monospaced))
                .foregroundStyle(.white)
                .frame(width: 28, height: 28)
                .background(.hgBrand, in: .rect(cornerRadius: 8))
            VStack(alignment: .leading, spacing: 1) {
                Text(chapter.title)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(.hgText)
                Text(chapter.subtitle)
                    .font(.system(size: 11))
                    .foregroundStyle(.hgDim)
                    .lineLimit(1)
            }
            Spacer()
        }
        .padding(.vertical, 8)
        .background(Color.hgBackground)
    }
}

/// 목록에서도 목업이 먼저 보인다 — 제목보다 그림이 항목을 구분해준다.
private struct EntryThumbnail: View {
    let entry: Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            MockupView(nodes: entry.mockup, scale: 0.62)
                .frame(width: MockupStyle.phoneSize.width * 0.62, alignment: .top)
                .clipped()

            VStack(alignment: .leading, spacing: 2) {
                Text(entry.index)
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(.hgDim)
                Text(entry.title)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.hgText)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
            .frame(width: MockupStyle.phoneSize.width * 0.62, alignment: .leading)
        }
    }
}
