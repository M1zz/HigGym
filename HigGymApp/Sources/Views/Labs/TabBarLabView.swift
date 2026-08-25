import SwiftUI

enum SearchTabOption: String, CaseIterable, Identifiable {
    case none, plainTab, searchRole
    var id: String { rawValue }
    var label: String {
        switch self {
        case .none:       "없음"
        case .plainTab:   "일반 탭"
        case .searchRole: "role: .search"
        }
    }
}

enum BadgeOption: String, CaseIterable, Identifiable {
    case none, count, text
    var id: String { rawValue }
    var label: String {
        switch self {
        case .none:  "없음"
        case .count: "숫자"
        case .text:  "텍스트"
        }
    }
}

struct TabBarLabView: View {
    @State private var tabCount = 4
    @State private var badge: BadgeOption = .none
    @State private var search: SearchTabOption = .none
    @State private var minimize = false
    @State private var accessory = false
    @State private var hideOnDetail = false
    @State private var running = false
    @State private var selectedPart: MockupPart?

    var body: some View {
        LabScaffold(title: "탭바 구성", subtitle: "몇 개까지가 탭바인가") {
                LiveMockup(
                    nodes: MockupBuilder.tabBar(
                        tabCount: tabCount,
                        badge: badge,
                        search: search,
                        accessory: accessory,
                        minimized: minimize
                    ),
                    caption: "설정을 바꾸면 이 그림이 바로 다시 그려집니다 — 문서의 프리뷰와 같은 언어",
                    selected: $selectedPart
                )

                RunStageCard(
                    title: "실제 SwiftUI로도 확인하기",
                    body_: "그림으로 구성을 잡았다면, 실행해서 시스템이 그리는 진짜 탭바와 접힘 동작을 확인해보세요."
                ) { running = true }

                controls
                diagnosisSection
                CodePanel(code: code)
        }
        .onAppear { if DebugLaunch.autoRunStage { running = true } }
        .fullScreenCover(isPresented: $running) {
            TabBarStage(
                tabCount: tabCount,
                badge: badge,
                search: search,
                minimize: minimize,
                accessory: accessory,
                hideOnDetail: hideOnDetail
            )
            .stageChrome(onClose: { running = false }) {
                controls
                diagnosisSection
            }
        }
    }

    private var controls: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionLabel("탭 개수", accent: .hgAccent)
            Picker("개수", selection: $tabCount) {
                ForEach([2, 3, 4, 6], id: \.self) { Text("\($0)개").tag($0) }
            }
            .pickerStyle(.segmented)

            SectionLabel("배지", accent: .hgAmber)
            Picker("배지", selection: $badge) {
                ForEach(BadgeOption.allCases) { Text($0.label).tag($0) }
            }
            .pickerStyle(.segmented)

            SectionLabel("검색", accent: .hgAmber)
            Picker("검색", selection: $search) {
                ForEach(SearchTabOption.allCases) { Text($0.label).tag($0) }
            }
            .pickerStyle(.segmented)

            SectionLabel("동작", accent: .hgGreen)
            Toggle("스크롤 내리면 탭바 접기 (minimize)", isOn: $minimize)
                .font(.subheadline).foregroundStyle(.hgText).tint(.hgAccent)
            Toggle("하단 액세서리 (미니 플레이어)", isOn: $accessory)
                .font(.subheadline).foregroundStyle(.hgText).tint(.hgAccent)
            Toggle("상세 화면에서 탭바 숨기기", isOn: $hideOnDetail)
                .font(.subheadline).foregroundStyle(.hgText).tint(.hgAccent)
        }
    }

    // MARK: 판정

    private var diagnoses: [Diagnosis] {
        var out: [Diagnosis] = []

        switch tabCount {
        case 6:
            out.append(.init(
                level: .violation,
                message: "iPhone 폭에서 6개는 터치 타깃과 라벨이 모두 압박됩니다. 3~5개로 추리고 **덜 중요한 건 탭 안의 화면으로** 내리세요.",
                source: "3.2.3 · 3.2.4"
            ))
        case 2:
            out.append(.init(
                level: .caution,
                message: "2개뿐이라면 탭 대신 **세그먼트 컨트롤**로 충분한 구조일 수 있습니다. 앱의 세계가 정말 둘로 나뉘는지 먼저 확인하세요.",
                source: "3.2.1"
            ))
        default:
            out.append(.init(
                level: .good,
                message: "3~5개는 터치 타깃 크기와 인지 부하가 만나는 안전 범위입니다.",
                source: "3.2.3"
            ))
        }

        switch badge {
        case .count:
            out.append(.init(
                level: .good,
                message: "숫자 배지는 **“몇 개인지가 행동을 결정할 때”** 씁니다. 모든 탭에 달면 인터럽트 가치가 인플레이션되어 진짜 중요한 알림이 묻힙니다.",
                source: "3.1.3"
            ))
        case .text:
            out.append(.init(
                level: .good,
                message: "개수가 아니라 상태가 정보일 때(NEW·LIVE) 쓰는 형태입니다. 긴 문자열은 탭 레이아웃을 침범하므로 짧게 유지하세요.",
                source: "3.1.4"
            ))
        case .none:
            break
        }

        switch search {
        case .searchRole:
            out.append(.init(
                level: .good,
                message: "탭은 “장소 이동”이지만 검색은 **“모드 진입”** — 역할로 선언하면 시스템이 별도 캡슐로 분리하고 위치·전환까지 처리합니다. iOS 26의 표준입니다.",
                source: "3.4.2"
            ))
        case .plainTab:
            out.append(.init(
                level: .caution,
                message: "검색을 일반 탭으로 두면 “검색은 우리 앱의 한 세계”라는 선언이 됩니다. 목록을 좁히는 필터형 검색이라면 과합니다 — `role: .search`나 화면 안 `.searchable`이 맞습니다.",
                source: "3.4.1 · 3.4.2"
            ))
        case .none:
            break
        }

        if minimize && accessory {
            out.append(.init(
                level: .good,
                message: "접힐 때 액세서리가 사라지지 않고 **탭바 자리로 승격**됩니다 — “이동 < 상태”라는 우선순위 역전을 시스템이 자동 처리합니다.",
                source: "3.5.2"
            ))
        } else if accessory {
            out.append(.init(
                level: .good,
                message: "탭을 넘나드는 진행 중 상태는 특정 화면이 아니라 **앱 전역의 소유**라 탭바 계층에 붙입니다.",
                source: "3.5.1"
            ))
        }

        if minimize {
            out.append(.init(
                level: .good,
                message: "**이동 장치는 이동할 때만 크면 됩니다.** 사라지는 게 아니라 접히는 것이라 위치 단서는 유지됩니다.",
                source: "3.2.2"
            ))
        }

        if hideOnDetail {
            out.append(.init(
                level: .caution,
                message: "상세에서 탭바를 숨기는 건 **몰입이 주 작업일 때**만 맞습니다(사진 전체화면·영상·작성 중). 얕은 계층이라면 탭바는 “지금 어디에 있는지”를 알려주는 상시 지도이므로 유지가 기본값입니다.",
                source: "3.3.1 · 3.3.2"
            ))
        }

        return out.sorted { $0.level > $1.level }
    }

    private var diagnosisSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionLabel("실시간 판정", accent: .hgGreen)
            ForEach(diagnoses) { DiagnosisRow(diagnosis: $0) }
        }
    }

    private var code: String {
        var lines = ["TabView {"]
        for i in 0..<tabCount {
            let name = TabBarStage.names[i % TabBarStage.names.count]
            let symbol = TabBarStage.symbols[i % TabBarStage.symbols.count]
            if i == 0, badge != .none {
                let value = badge == .count ? "3" : "\"NEW\""
                lines.append("    Tab(\"\(name)\", systemImage: \"\(symbol)\") { \(name)View() }")
                lines.append("        .badge(\(value))")
            } else {
                lines.append("    Tab(\"\(name)\", systemImage: \"\(symbol)\") { \(name)View() }")
            }
        }
        switch search {
        case .none: break
        case .plainTab:
            lines.append("    Tab(\"검색\", systemImage: \"magnifyingglass\") { SearchView() }")
        case .searchRole:
            lines.append("    Tab(role: .search) { SearchView() }")
        }
        lines.append("}")
        if minimize {
            lines.append(".tabBarMinimizeBehavior(.onScrollDown)")
        }
        if accessory {
            lines.append(".tabViewBottomAccessory { MiniPlayer() }")
        }
        if hideOnDetail {
            lines.append("")
            lines.append("// 상세 화면 쪽")
            lines.append("DetailView()")
            lines.append("    .toolbar(.hidden, for: .tabBar)")
        }
        return lines.joined(separator: "\n")
    }
}

// MARK: - 진짜 시스템 탭바로 띄우는 미리보기

private struct TabBarStage: View {
    let tabCount: Int
    let badge: BadgeOption
    let search: SearchTabOption
    let minimize: Bool
    let accessory: Bool
    let hideOnDetail: Bool

    static let names = ["홈", "탐색", "보관함", "알림", "설정", "더보기"]
    static let symbols = ["house", "safari", "square.stack", "bell", "gearshape", "ellipsis"]

    var body: some View {
        TabView { tabs }
            .modifier(MinimizeModifier(enabled: minimize))
            .modifier(AccessoryModifier(enabled: accessory))
    }

    /// TabContentBuilder 안에서 switch 를 쓰면 타입 체크가 폭발해서 if 로 편다.
    @TabContentBuilder<Never>
    private var tabs: some TabContent<Never> {
        ForEach(0..<tabCount, id: \.self) { i in
            Tab(Self.names[i % Self.names.count],
                systemImage: Self.symbols[i % Self.symbols.count]) {
                tabContent(title: Self.names[i % Self.names.count])
            }
            .badge(badgeValue(for: i))
        }

        if search == .plainTab {
            Tab("검색", systemImage: "magnifyingglass") {
                tabContent(title: "검색")
            }
        }

        if search == .searchRole {
            Tab(role: .search) {
                tabContent(title: "검색")
            }
        }
    }

    private func badgeValue(for index: Int) -> Text? {
        guard index == 0 else { return nil }
        switch badge {
        case .none:  return nil
        case .count: return Text("3")
        case .text:  return Text("NEW")
        }
    }

    private func tabContent(title: String) -> some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink("상세 화면으로 들어가기") {
                        detail
                    }
                }
                ForEach(0..<30, id: \.self) { i in
                    Text("\(title) 항목 \(i + 1)")
                }
            }
            .navigationTitle(title)
        }
    }

    private var detail: some View {
        List {
            Text("상세 화면입니다.")
            Text(hideOnDetail
                 ? "탭바를 숨겼습니다 — 뒤로가기가 유일한 출구입니다."
                 : "탭바가 유지됩니다 — 지금 어느 탭 안에 있는지가 계속 보입니다.")
            ForEach(0..<20, id: \.self) { i in
                Text("본문 \(i + 1)")
            }
        }
        .navigationTitle("상세")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(hideOnDetail ? .hidden : .visible, for: .tabBar)
    }
}

private struct MinimizeModifier: ViewModifier {
    let enabled: Bool
    func body(content: Content) -> some View {
        if enabled {
            content.tabBarMinimizeBehavior(.onScrollDown)
        } else {
            content
        }
    }
}

private struct AccessoryModifier: ViewModifier {
    let enabled: Bool
    func body(content: Content) -> some View {
        if enabled {
            content.tabViewBottomAccessory {
                HStack(spacing: 10) {
                    RoundedRectangle(cornerRadius: 5)
                        .fill(.hgBrand)
                        .frame(width: 26, height: 26)
                    VStack(alignment: .leading, spacing: 1) {
                        Text("재생 중인 항목").font(.footnote.weight(.semibold))
                        Text("전역 상태").font(.caption).foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: "play.fill").font(.subheadline)
                }
                .padding(.horizontal, 14)
            }
        } else {
            content
        }
    }
}
