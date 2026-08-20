import SwiftUI

/// iOS 앱 디자인 실수 100 — 항목이 "이렇게 생겼다"라면 여기는 **"이렇게 하다 밟았다"**이다.
///
/// 목록은 훑는 곳이고, 배우는 건 상세와 예제에서 일어난다. 그래서 행은 최대한 조용하게 두고
/// 번호 · 실수 한 줄 · 심각도 · 확인 여부만 싣는다.
struct MistakesHomeView: View {
    private let store = MistakeStore.shared

    @Environment(ProgressStore.self) private var progress
    @State private var query = ""
    @State private var category: String?
    @State private var onlyUnchecked = false
    @State private var onlyStories = false
    @State private var path = NavigationPath()

    private var filtered: [Mistake] {
        store.mistakes.filter { mistake in
            if let category, mistake.category != category { return false }
            if onlyUnchecked, progress.isChecked(mistake) { return false }
            if onlyStories, !mistake.hasStory { return false }
            guard !query.isEmpty else { return true }
            return mistake.title.localizedCaseInsensitiveContains(query)
                || mistake.why.localizedCaseInsensitiveContains(query)
                || mistake.fix.localizedCaseInsensitiveContains(query)
                || mistake.sources.contains { $0.index.contains(query) }
        }
    }

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12, pinnedViews: [.sectionHeaders]) {
                    if query.isEmpty { header }

                    Section {
                        ForEach(filtered) { mistake in
                            NavigationLink(value: mistake) {
                                MistakeRow(mistake: mistake, checked: progress.isChecked(mistake))
                            }
                            .buttonStyle(.plain)
                        }

                        if filtered.isEmpty {
                            Text("해당하는 실수가 없습니다")
                                .font(.system(size: 13))
                                .foregroundStyle(.hgDim)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.vertical, 30)
                        }
                    } header: {
                        filterBar
                    }
                }
                .padding(.horizontal, 18)
                .padding(.bottom, 30)
            }
            .background(Color.hgBackground)
            .navigationTitle("실수 100")
            .searchable(text: $query, prompt: "실수·근거 항목 검색")
            .navigationDestination(for: Mistake.self) { MistakeDetailView(mistake: $0) }
            .navigationDestination(for: MistakeStoryRoute.self) { MistakeStoryView(mistake: $0.mistake) }
            .navigationDestination(for: Entry.self) { EntryDetailView(entry: $0) }
            .task {
                if let number = DebugLaunch.mistakeNumber,
                   let mistake = store.mistakes.first(where: { $0.number == number }) {
                    path.append(mistake)
                    if DebugLaunch.autoStory, mistake.hasStory {
                        path.append(MistakeStoryRoute(mistake: mistake))
                    }
                }
            }
        }
    }

    // MARK: 진행도

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 7) {
                Text("직접 밟아봐야 안 밟는다")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.hgText)
                Text("본문 68개 항목의 **잘못된 예 154개**를 실수 단위로 추려 100편으로 묶었습니다. 각 실수마다 그때는 왜 그게 맞아 보였는지, 판단 기준이 무엇인지, 그리고 **직접 어겨볼 화면**이 붙습니다.")
                    .font(.system(size: 14))
                    .foregroundStyle(.hgMuted)
            }

            progressBar
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 4)
    }

    private var progressBar: some View {
        let done = progress.checkedMistakes.count
        let total = max(store.mistakes.count, 1)
        return VStack(alignment: .leading, spacing: 7) {
            HStack {
                Text("겪어본 것으로 표시한 실수")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.hgDim)
                Spacer()
                Text("\(done) / \(total)")
                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                    .foregroundStyle(done > 0 ? .hgAccent : .hgDim)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.hgFill)
                    Capsule()
                        .fill(.hgBrand)
                        .frame(width: geo.size.width * CGFloat(done) / CGFloat(total))
                }
            }
            .frame(height: 6)
        }
        .padding(13)
        .background(Color.hgCard, in: .rect(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Color.hgLine, lineWidth: 1))
    }

    // MARK: 분류 필터

    private var filterBar: some View {
        VStack(spacing: 8) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 7) {
                    chip(title: "전체", count: store.mistakes.count, color: .hgAccent, active: category == nil) {
                        category = nil
                    }
                    ForEach(store.categories) { item in
                        chip(
                            title: item.title,
                            count: store.mistakes(in: item.id).count,
                            color: item.color,
                            active: category == item.id
                        ) {
                            category = category == item.id ? nil : item.id
                        }
                    }
                }
                .padding(.vertical, 2)
            }

            HStack(spacing: 8) {
                if let category, let info = store.category(category) {
                    Text(info.desc)
                        .font(.system(size: 11.5))
                        .foregroundStyle(.hgDim)
                        .lineLimit(2)
                }
                Spacer(minLength: 0)
                Button {
                    withAnimation(.snappy) { onlyStories.toggle() }
                } label: {
                    Label("회고 있는 것만", systemImage: onlyStories ? "checkmark.square.fill" : "square")
                        .font(.system(size: 11.5, weight: .semibold))
                        .foregroundStyle(onlyStories ? .hgAmber : .hgDim)
                }
                .buttonStyle(.plain)

                Button {
                    withAnimation(.snappy) { onlyUnchecked.toggle() }
                } label: {
                    Label("안 본 것만", systemImage: onlyUnchecked ? "checkmark.square.fill" : "square")
                        .font(.system(size: 11.5, weight: .semibold))
                        .foregroundStyle(onlyUnchecked ? .hgAccent : .hgDim)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 6)
        .background(Color.hgBackground)
    }

    private func chip(title: String, count: Int, color: Color, active: Bool, action: @escaping () -> Void) -> some View {
        Button(action: { withAnimation(.snappy) { action() } }) {
            HStack(spacing: 5) {
                Text(title).font(.system(size: 12.5, weight: .semibold))
                Text("\(count)")
                    .font(.system(size: 10.5, weight: .bold, design: .monospaced))
                    .opacity(0.75)
            }
            .foregroundStyle(active ? .white : color)
            .padding(.horizontal, 11)
            .padding(.vertical, 6)
            .background(active ? AnyShapeStyle(color) : AnyShapeStyle(color.opacity(0.12)), in: .capsule)
            .overlay(Capsule().strokeBorder(color.opacity(active ? 0 : 0.3), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 목록의 한 줄

private struct MistakeRow: View {
    let mistake: Mistake
    let checked: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(mistake.number)")
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundStyle(checked ? .hgDim : mistake.level.color)
                .frame(width: 28, height: 24)
                .background((checked ? Color.hgDim : mistake.level.color).opacity(0.12), in: .rect(cornerRadius: 7))

            VStack(alignment: .leading, spacing: 5) {
                Text(mistake.title)
                    .font(.system(size: 14.5, weight: .semibold))
                    .foregroundStyle(checked ? .hgMuted : .hgText)
                    .multilineTextAlignment(.leading)
                    .strikethrough(checked, color: .hgDim)

                HStack(spacing: 6) {
                    Label(mistake.severityLabel, systemImage: mistake.level.symbol)
                        .font(.system(size: 10.5, weight: .semibold))
                        .foregroundStyle(mistake.level.color)
                    if mistake.hasStory {
                        Label("회고", systemImage: "text.book.closed.fill")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.hgAmber)
                    }
                    if MistakeDemos.demo(for: mistake) != nil {
                        Label("전용 예제", systemImage: "rectangle.split.2x1.fill")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.hgGreen)
                    }
                    Text(mistake.sources.map(\.index).joined(separator: " · "))
                        .font(.system(size: 10.5, design: .monospaced))
                        .foregroundStyle(.hgDim)
                        .lineLimit(1)
                }
            }

            Spacer(minLength: 0)

            Image(systemName: checked ? "checkmark.circle.fill" : "chevron.right")
                .font(.system(size: checked ? 15 : 12, weight: .semibold))
                .foregroundStyle(checked ? .hgGreen : .hgDim)
                .padding(.top, 2)
        }
        .padding(13)
        .background(Color.hgCard, in: .rect(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Color.hgLine, lineWidth: 1))
    }
}
