import SwiftUI

struct ToolbarLabView: View {
    @State private var config = ToolbarConfig()
    @State private var showCode = false
    @State private var running = false
    @State private var selectedPart: MockupPart?

    private var diagnoses: [Diagnosis] { ToolbarDiagnostics.evaluate(config) }

    var body: some View {
        LabScaffold(title: "툴바 배치 실험실", subtitle: "자리와 묶음의 문법을 직접 어겨보기") {
                LiveMockup(
                    nodes: MockupBuilder.toolbar(config),
                    caption: "설정을 바꾸면 이 그림이 바로 다시 그려집니다 — 문서의 프리뷰와 같은 언어",
                    selected: $selectedPart
                )

                RunStageCard(
                    title: "실제 SwiftUI로도 확인하기",
                    body_: "그림으로 배치를 잡았다면, 실행해서 시스템이 그리는 진짜 툴바와 대조해보세요."
                ) { running = true }

                presets
                slotEditors
                titleAndSearch
                diagnosisSection

                DisclosureGroup("생성된 SwiftUI 코드", isExpanded: $showCode) {
                    CodePanel(code: ToolbarCodeGenerator.code(for: config))
                        .padding(.top, 10)
                }
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.hgText)
                .padding(.horizontal, 4)
        }
        .animation(.snappy(duration: 0.25), value: config.allItems)
        .onAppear { if DebugLaunch.autoRunStage { running = true } }
        .fullScreenCover(isPresented: $running) {
            ToolbarStage(config: config)
                .stageChrome(onClose: { running = false }) {
                    presets
                    titleAndSearch
                    diagnosisSection
                }
        }
    }

    // MARK: 프리셋 — 좋은 예 / 나쁜 예를 한 번에 불러와 비교

    private var presets: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionLabel("먼저 눌러볼 것", accent: .hgAccent)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    presetButton("액션 하나", "1.1.1", .hgGreen) {
                        var c = ToolbarConfig()
                        c.items[.trailing] = [item("done")]
                        return c
                    }
                    presetButton("도구 + 결정", "1.1.2", .hgGreen) {
                        var c = ToolbarConfig()
                        c.items[.leading] = [item("undo"), item("redo")]
                        c.items[.trailing] = [item("done")]
                        return c
                    }
                    presetButton("고빈도는 하단", "1.1.4", .hgGreen) {
                        var c = ToolbarConfig()
                        c.items[.trailing] = [item("filter")]
                        c.items[.bottom] = [item("compose")]
                        return c
                    }
                    presetButton("전부 채우기", "1.1.9", .hgRed) {
                        var c = ToolbarConfig()
                        c.items[.leading] = [item("sort"), item("filter")]
                        c.items[.principal] = [item("share")]
                        c.items[.trailing] = [item("done"), item("star")]
                        c.items[.bottom] = [item("compose"), item("delete")]
                        return c
                    }
                    presetButton("완료를 하단에", "8.1.2", .hgRed) {
                        var c = ToolbarConfig()
                        c.items[.bottom] = [item("done")]
                        return c
                    }

                    Button("비우기") { withAnimation { config.clear() } }
                        .font(.system(size: 13, weight: .semibold))
                        .buttonStyle(.bordered)
                        .tint(.hgDim)
                }
                .padding(.horizontal, 2)
            }
        }
    }

    private func presetButton(
        _ title: String, _ source: String, _ tint: Color, _ make: @escaping () -> ToolbarConfig
    ) -> some View {
        Button {
            withAnimation(.snappy) { config = make() }
        } label: {
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.system(size: 13, weight: .semibold))
                Text(source).font(.system(size: 10, design: .monospaced)).foregroundStyle(.hgDim)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(tint.opacity(0.12), in: .rect(cornerRadius: 10))
            .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(tint.opacity(0.3), lineWidth: 1))
        }
        .buttonStyle(.plain)
        .foregroundStyle(.hgText)
    }

    private func item(_ id: String) -> ToolbarItemSpec {
        ToolbarItemSpec.palette.first { $0.id == id }!
    }

    // MARK: 자리별 편집

    private var slotEditors: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionLabel("자리에 넣기", accent: .hgAccent)
            Text("자리마다 원래 말하는 것이 있습니다 — 그 문법과 어긋나면 아래 진단에 잡힙니다.")
                .font(.system(size: 12.5))
                .foregroundStyle(.hgDim)

            ForEach(ToolbarSlot.allCases) { slot in
                SlotEditor(slot: slot, config: $config)
            }

            Toggle(isOn: $config.isRoot) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("루트 화면 (뒤로가기 없음)")
                        .font(.system(size: 14))
                        .foregroundStyle(.hgText)
                    Text("끄면 push된 상세 화면 — leading이 뒤로가기와 다투는지 판정합니다")
                        .font(.system(size: 11.5))
                        .foregroundStyle(.hgDim)
                }
            }
            .tint(.hgAccent)
            .padding(.top, 4)
        }
    }

    // MARK: 제목 · 검색

    private var titleAndSearch: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionLabel("제목 표시 방식", accent: .hgAmber)
            Picker("제목", selection: $config.titleMode) {
                ForEach(TitleMode.allCases) { Text($0.label).tag($0) }
            }
            .pickerStyle(.segmented)

            SectionLabel("검색 배치", accent: .hgAmber)
            Picker("검색", selection: $config.search) {
                ForEach(SearchOption.allCases) { Text($0.label).tag($0) }
            }
            .pickerStyle(.segmented)
        }
    }

    // MARK: 진단

    private var diagnosisSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                SectionLabel("실시간 판정", accent: .hgGreen)
                Spacer()
                Text("\(diagnoses.count)건")
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundStyle(.hgDim)
            }
            ForEach(diagnoses) { DiagnosisRow(diagnosis: $0) }
        }
    }
}

// MARK: - 한 자리의 편집기

private struct SlotEditor: View {
    let slot: ToolbarSlot
    @Binding var config: ToolbarConfig

    private var assigned: [ToolbarItemSpec] { config.items(in: slot) }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Text(slot.title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.hgText)
                Pill(text: slot.grammar, color: .hgAccent2)
                Spacer()
                Menu {
                    ForEach(ToolbarItemSpec.palette) { spec in
                        Button {
                            withAnimation(.snappy) { config.toggle(spec, in: slot) }
                        } label: {
                            Label(
                                "\(spec.name) · \(spec.role.label)\(spec.frequent ? " · 고빈도" : "")",
                                systemImage: assigned.contains(spec) ? "checkmark" : spec.symbol
                            )
                        }
                    }
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(.hgAccent)
                }
            }

            if assigned.isEmpty {
                Text("비어 있음")
                    .font(.system(size: 12))
                    .foregroundStyle(.hgDim)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 6)
            } else {
                FlowChips(items: assigned) { spec in
                    withAnimation(.snappy) { config.toggle(spec, in: slot) }
                }
            }
        }
        .padding(12)
        .background(Color.hgCard, in: .rect(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Color.hgLine, lineWidth: 1))
    }
}

private struct FlowChips: View {
    let items: [ToolbarItemSpec]
    let onRemove: (ToolbarItemSpec) -> Void

    var body: some View {
        // 아이템 수가 적어 단순 wrap 으로 충분하다.
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 6) { chips }
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) { chipRange(0..<min(2, items.count)) }
                if items.count > 2 {
                    HStack(spacing: 6) { chipRange(2..<items.count) }
                }
            }
        }
    }

    private var chips: some View { chipRange(0..<items.count) }

    private func chipRange(_ range: Range<Int>) -> some View {
        ForEach(Array(items[range]), id: \.id) { spec in
            Button { onRemove(spec) } label: {
                HStack(spacing: 5) {
                    Image(systemName: spec.symbol).font(.system(size: 11))
                    Text(spec.name).font(.system(size: 12.5, weight: .medium))
                    Image(systemName: "xmark").font(.system(size: 9, weight: .bold)).opacity(0.5)
                }
                .foregroundStyle(spec.role.color)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(spec.role.color.opacity(0.12), in: .capsule)
                .overlay(Capsule().strokeBorder(spec.role.color.opacity(0.3), lineWidth: 1))
            }
            .buttonStyle(.plain)
        }
    }
}

struct SectionLabel: View {
    let text: String
    var accent: Color = .hgAccent

    init(_ text: String, accent: Color = .hgAccent) {
        self.text = text
        self.accent = accent
    }

    var body: some View {
        HStack(spacing: 6) {
            RoundedRectangle(cornerRadius: 2).fill(accent).frame(width: 3, height: 13)
            Text(text)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(.hgText)
        }
    }
}

// MARK: - 실제 SwiftUI 툴바로 그리는 화면

private struct ToolbarStage: View {
    let config: ToolbarConfig
    @State private var query = ""

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("받은 편지함")
                .modifier(TitleModeModifier(mode: config.titleMode))
                .toolbar { toolbarContent }
                .modifier(SearchModifier(option: config.search, query: $query))
                .toolbar {
                    if !config.isRoot {
                        ToolbarItem(placement: .topBarLeading) {
                            Button("뒤로", systemImage: "chevron.backward") {}
                        }
                    }
                }
        }
    }

    private var content: some View {
        List {
            ForEach(0..<12, id: \.self) { i in
                VStack(alignment: .leading, spacing: 3) {
                    Text("메시지 \(i + 1)")
                        .font(.system(size: 14, weight: .semibold))
                    Text("본문 미리보기 텍스트가 두 줄까지 보이는 셀입니다.")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
                .listRowBackground(Color.hgCard)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color.hgBackground)
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarLeading) {
            ForEach(config.items(in: .leading)) { spec in
                Button(spec.name, systemImage: spec.symbol) {}
            }
        }
        ToolbarItem(placement: .principal) {
            if let spec = config.items(in: .principal).first {
                if spec.role == .identity {
                    Picker("", selection: .constant(0)) {
                        Text("지도").tag(0)
                        Text("목록").tag(1)
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 140)
                } else {
                    Button(spec.name, systemImage: spec.symbol) {}
                }
            }
        }
        ToolbarItemGroup(placement: .topBarTrailing) {
            ForEach(config.items(in: .trailing)) { spec in
                Button(spec.name, systemImage: spec.symbol) {}
            }
        }
        ToolbarItemGroup(placement: .bottomBar) {
            ForEach(config.items(in: .bottom)) { spec in
                Button(spec.name, systemImage: spec.symbol) {}
            }
        }
    }
}

/// 제목 표시 방식은 modifier 종류가 달라서 따로 뺐다.
private struct TitleModeModifier: ViewModifier {
    let mode: TitleMode

    func body(content: Content) -> some View {
        switch mode {
        case .large:
            content.toolbarTitleDisplayMode(.large)
        case .inlineLarge:
            content.toolbarTitleDisplayMode(.inlineLarge)
        case .inline:
            content.toolbarTitleDisplayMode(.inline)
        case .titleMenu:
            content
                .toolbarTitleDisplayMode(.inline)
                .toolbarTitleMenu {
                    Button("이름 변경", systemImage: "pencil") {}
                    Button("폴더 전환", systemImage: "folder") {}
                    Divider()
                    Button("삭제", systemImage: "trash", role: .destructive) {}
                }
        case .custom:
            content.toolbarTitleDisplayMode(.inline)
        }
    }
}

private struct SearchModifier: ViewModifier {
    let option: SearchOption
    @Binding var query: String

    func body(content: Content) -> some View {
        switch option {
        case .none:
            content
        case .drawerAuto:
            content.searchable(text: $query, placement: .navigationBarDrawer)
        case .drawerAlways:
            content.searchable(text: $query, placement: .navigationBarDrawer(displayMode: .always))
        case .minimized:
            content.searchable(text: $query).searchToolbarBehavior(.minimize)
        }
    }
}
