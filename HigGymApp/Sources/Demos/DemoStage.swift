import SwiftUI

/// 예제를 **실제 크기 화면 그대로** 띄우는 무대.
///
/// 항목 상세는 push 된 화면이라 여기서 또 push 하면 안 된다 — 데모 안쪽의
/// `NavigationStack`·`TabView` 가 조상 컨트롤러를 발견하고 자기 툴바를 그쪽으로
/// 올려버리기 때문(LabScaffold 주석과 같은 이유). 그래서 데모는 전체 화면으로 띄우고,
/// 닫기·안내는 화면 가장자리에 뜨는 캡슐로 따로 붙인다.
struct EntryDemoStage: View {
    let info: DemoGuideInfo
    let demo: EntryDemo

    init(info: DemoGuideInfo, demo: EntryDemo) {
        self.info = info
        self.demo = demo
    }

    init(entry: Entry, demo: EntryDemo) {
        self.init(info: DemoGuideInfo(entry: entry), demo: demo)
    }

    @Environment(\.dismiss) private var dismiss
    @State private var showGuide = false

    /// 안내를 이미 본 예제들. 항목마다 만져볼 것이 다르므로 **항목 단위로** 한 번씩만 펼친다.
    private static let seenKey = "higgym.demoGuideSeenIDs"

    var body: some View {
        demo.make()
            .overlay(alignment: demo.chromeEdge.alignment) { chrome }
            .sheet(isPresented: $showGuide) {
                DemoGuideSheet(info: info, demo: demo)
            }
            .onAppear(perform: presentGuideIfFirstVisit)
    }

    /// 처음 여는 예제에서는 "무엇을 해보라"를 먼저 펼친다. 시트는 비모달이라
    /// 읽으면서 뒤 화면을 그대로 만질 수 있다 — 4.1.5 가 말하는 그 동작.
    private func presentGuideIfFirstVisit() {
        var seen = Set(UserDefaults.standard.stringArray(forKey: Self.seenKey) ?? [])
        guard !seen.contains(demo.id) else { return }
        seen.insert(demo.id)
        UserDefaults.standard.set(Array(seen), forKey: Self.seenKey)
        showGuide = true
    }

    @ViewBuilder
    private var chrome: some View {
        if demo.chromeEdge.isHorizontalBar {
            HStack(spacing: 4) {
                chromeButton("xmark") { dismiss() }
                Divider().frame(height: 18)
                chromeButton("questionmark") { showGuide = true }
            }
            .padding(.horizontal, 7)
            .background(.ultraThinMaterial, in: .capsule)
            .overlay(Capsule().strokeBorder(Color.hgHairline, lineWidth: 1))
            .shadow(color: .black.opacity(0.35), radius: 10, y: 4)
            .padding(.bottom, 10)
        } else {
            verticalChrome
        }
    }

    private var verticalChrome: some View {
        VStack(spacing: 4) {
            chromeButton("xmark") { dismiss() }
            Divider().frame(width: 22)
            chromeButton("questionmark") { showGuide = true }
        }
        .padding(.vertical, 7)
        .background(.ultraThinMaterial, in: .capsule)
        .overlay(Capsule().strokeBorder(Color.hgHairline, lineWidth: 1))
        .shadow(color: .black.opacity(0.35), radius: 10, y: 4)
        .padding(demo.chromeEdge.padding, 8)
    }

    private func chromeButton(_ symbol: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(.primary)
                .frame(width: 32, height: 28)
                .contentShape(.rect)
        }
        .buttonStyle(.plain)
    }
}

/// 조작 캡슐을 어느 쪽 가장자리에 붙일지. 화면 가장자리를 쓰는 데모(5.2)와
/// 겹치지 않도록 항목별로 반대편을 고른다.
enum DemoChromeEdge {
    case leading, trailing
    /// 좌우가 모두 화면인 비교 예제용 — 캡슐을 아래 가운데로 눕힌다.
    case bottom

    var alignment: Alignment {
        switch self {
        case .leading:  .leading
        case .trailing: .trailing
        case .bottom:   .bottom
        }
    }

    var padding: Edge.Set {
        switch self {
        case .leading:  .leading
        case .trailing: .trailing
        case .bottom:   .bottom
        }
    }

    var isHorizontalBar: Bool { self == .bottom }
}

// MARK: - 안내 시트

/// 안내 시트에 실을 내용. 항목에서 열면 항목의 WHEN·WHY가, 실수에서 열면
/// 그 실수의 "그때는 왜 · 기준 · 고치면"이 붙는다 — 무대는 같고 설명만 갈린다.
struct DemoGuideInfo {
    let badge: String
    let title: String
    let summary: String
    let blocks: [Block]

    struct Block: Identifiable {
        let id: String
        let title: String
        let body: String
        let tint: Color
    }

    init(entry: Entry) {
        badge = entry.index
        title = entry.title
        summary = entry.summary
        var blocks: [Block] = []
        if !entry.when.isEmpty {
            blocks.append(.init(id: "when", title: "어느 상황에서", body: entry.when, tint: .hgGreen))
        }
        if !entry.why.isEmpty {
            blocks.append(.init(id: "why", title: "왜 이렇게", body: entry.why, tint: .hgAccent2))
        }
        self.blocks = blocks
    }

    init(mistake: Mistake) {
        badge = "실수 #\(mistake.number)"
        title = mistake.title
        summary = mistake.why
        blocks = [
            .init(id: "criterion", title: "판단 기준", body: mistake.criterion, tint: .hgAccent2),
            .init(id: "fix", title: "고치면", body: mistake.fix, tint: .hgGreen),
        ]
    }
}

private struct DemoGuideSheet: View {
    let info: DemoGuideInfo
    let demo: EntryDemo

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    header
                    hints
                    if let note = demo.note { noteBlock(note) }
                    CodePanel(code: demo.code, title: "이 화면의 코드")
                    criteria
                }
                .padding(18)
            }
            .background(Color.hgBackground)
            .navigationTitle("예제 안내")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("닫기") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        // 안내를 띄운 채로 뒤의 예제를 그대로 만질 수 있게 — 4.1.5 비모달.
        .presentationBackgroundInteraction(.enabled(upThrough: .medium))
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 7) {
            Pill(text: info.badge)
            Text(info.title)
                .font(.system(size: 19, weight: .bold))
                .foregroundStyle(.hgText)
            MarkdownText(raw: info.summary, font: .system(size: 13.5), color: .hgMuted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var hints: some View {
        VStack(alignment: .leading, spacing: 9) {
            SectionLabel("해보세요", accent: .hgGreen)
            ForEach(Array(demo.hints.enumerated()), id: \.offset) { index, hint in
                HStack(alignment: .top, spacing: 9) {
                    Text("\(index + 1)")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundStyle(.hgGreen)
                        .frame(width: 18, height: 18)
                        .background(Color.hgGreen.opacity(0.14), in: .circle)
                    MarkdownText(raw: hint, font: .system(size: 13.5), color: .hgText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color.hgGreen.opacity(0.06), in: .rect(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Color.hgGreen.opacity(0.22), lineWidth: 1))
    }

    private func noteBlock(_ note: String) -> some View {
        HStack(alignment: .top, spacing: 9) {
            Image(systemName: "exclamationmark.circle.fill")
                .font(.system(size: 13))
                .foregroundStyle(.hgAmber)
                .padding(.top, 1)
            MarkdownText(raw: note, font: .system(size: 13), color: .hgMuted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(13)
        .background(Color.hgAmber.opacity(0.07), in: .rect(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(Color.hgAmber.opacity(0.25), lineWidth: 1))
    }

    /// 예제를 만져본 직후가, 그것이 왜 그렇게 생겼는지 읽기 가장 좋은 때다.
    @ViewBuilder
    private var criteria: some View {
        if !info.blocks.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                ForEach(info.blocks) { block($0.title, $0.body, $0.tint) }
            }
        }
    }

    private func block(_ title: String, _ body: String, _ tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(tint)
            MarkdownText(raw: body, font: .system(size: 13), color: .hgText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(13)
        .background(Color.hgFill, in: .rect(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(Color.hgLine, lineWidth: 1))
    }
}

// MARK: - 항목 상세에서 예제를 여는 카드

struct DemoLaunchCard: View {
    let entry: Entry
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: "play.rectangle.fill")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 38, height: 38)
                    .background(.hgBrand, in: .rect(cornerRadius: 11))

                VStack(alignment: .leading, spacing: 2) {
                    Text("예제 보기")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.hgText)
                    Text("그림이 아니라 실제로 동작하는 화면 — 눌러보고 스크롤해 보세요")
                        .font(.system(size: 11.5))
                        .foregroundStyle(.hgDim)
                        .multilineTextAlignment(.leading)
                }

                Spacer(minLength: 4)

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.hgDim)
            }
            .padding(12)
            .background(Color.hgCard, in: .rect(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Color.hgAccent.opacity(0.45), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}
