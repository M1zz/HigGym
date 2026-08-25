import SwiftUI

/// 3장 Tab Bar — 탭 아이템 · 개수 · 표시 여부 · 검색 · 액세서리.
/// 탭바는 **전환해보고 스크롤해봐야** 성격이 드러난다. 모든 데모의 탭 내용이 서로 다른 이유다.
@MainActor
enum TabBarDemos {
    static let all: [EntryDemo] = [
        EntryDemo(
            "tb1",
            hints: [
                "탭을 하나씩 눌러보세요 — 아이콘과 한 단어 제목이 함께 있는 표준형입니다.",
                "선택된 탭만 틴트로 강조됩니다. \"지금 어디에 있는가\"를 색으로 말합니다.",
                "제목을 지운 형태(3.1.2)와 비교하면, 라벨이 있는 쪽이 처음 온 사람에게 얼마나 친절한지 보입니다.",
            ],
            code: """
            TabView {
                Tab("홈", systemImage: "house") { HomeView() }
                Tab("둘러보기", systemImage: "safari") { BrowseView() }
                Tab("보관함", systemImage: "square.stack") { LibraryView() }
                Tab("설정", systemImage: "gearshape") { SettingsView() }
            }
            """
        ) { TabDemoScreen(config: .init(count: 4)) },

        EntryDemo(
            "tb2",
            hints: [
                "라벨이 없습니다. 아이콘만 보고 각 탭이 무엇일지 **맞혀보세요**.",
                "3.1.1과 번갈아 열어보면, 라벨이 사라졌을 때 무엇을 잃는지 바로 느껴집니다.",
                "누구나 아는 소수의 아이콘(홈·검색)에만 쓸 수 있는 형태입니다.",
            ],
            code: """
            Tab(value: id) {
                HomeView()
            } label: {
                Image(systemName: "house")   // 라벨 없이 아이콘만
            }
            """
        ) { TabDemoScreen(config: .init(count: 4, iconOnly: true)) },

        EntryDemo(
            "tb3",
            hints: [
                "첫 번째 탭 우상단의 **빨간 3**이 배지입니다.",
                "그 탭에 들어가 목록의 항목을 눌러 읽으면 **배지 숫자가 실제로 줄어듭니다**.",
                "0이 되면 배지가 사라집니다 — 배지는 \"처리할 것이 남았다\"는 뜻이지 장식이 아닙니다.",
            ],
            code: """
            Tab("알림", systemImage: "bell") { InboxView() }
                .badge(unreadCount)   // 0 이면 자동으로 사라진다
            """
        ) { TabDemoScreen(config: .init(count: 4, badge: .count)) },

        EntryDemo(
            "tb4",
            hints: [
                "숫자 대신 **NEW** 라는 짧은 텍스트가 붙어 있습니다.",
                "그 탭에 한 번 들어갔다 나오면 배지가 사라집니다 — \"새 것\"은 한 번 보면 새 것이 아니니까요.",
                "긴 문장을 넣으면 배지가 탭 라벨을 덮습니다. 두세 글자가 한계입니다.",
            ],
            code: """
            Tab("스토어", systemImage: "bag") { StoreView() }
                .badge(hasNew ? Text("NEW") : nil)
            """
        ) { TabDemoScreen(config: .init(count: 4, badge: .text)) },

        EntryDemo(
            "tc1",
            hints: [
                "탭이 둘뿐입니다 — 하단 바 전체를 두 목적지가 나눠 씁니다.",
                "터치 타깃이 아주 넉넉합니다. 두 세계를 오가는 앱이라면 이 이상 필요하지 않습니다.",
                "탭이 둘인데 한쪽을 거의 안 쓴다면, 그건 탭이 아니라 화면 안의 전환일 수 있습니다.",
            ],
            code: """
            TabView {
                Tab("홈", systemImage: "house") { HomeView() }
                Tab("설정", systemImage: "gearshape") { SettingsView() }
            }
            """
        ) { TabDemoScreen(config: .init(count: 2)) },

        EntryDemo(
            "tc2",
            hints: [
                "목록을 **아래로 스크롤**해 보세요 — 탭바가 작게 접힙니다.",
                "다시 위로 올리면 원래대로 펼쳐집니다. 읽는 동안엔 물러나고, 이동하려 하면 돌아옵니다.",
                "접힌 상태에서도 탭은 그대로 눌립니다. 사라지는 게 아니라 **작아지는** 것입니다.",
            ],
            code: """
            TabView { /* 탭 2개 */ }
                .tabBarMinimizeBehavior(.onScrollDown)
            """
        ) { TabDemoScreen(config: .init(count: 2, minimize: true)) },

        EntryDemo(
            "tc3",
            hints: [
                "네 개 — 대부분의 앱이 도달하는 균형점입니다. 눌러 옮겨 다녀 보세요.",
                "라벨이 잘리지 않고, 손가락이 옆 탭을 건드리지도 않습니다.",
                "6개(3.2.4)와 번갈아 열어보면 이 여유가 어디서 온 것인지 보입니다.",
            ],
            code: """
            TabView {
                Tab("홈", systemImage: "house") { … }
                Tab("둘러보기", systemImage: "safari") { … }
                Tab("보관함", systemImage: "square.stack") { … }
                Tab("설정", systemImage: "gearshape") { … }
            }
            """
        ) { TabDemoScreen(config: .init(count: 4)) },

        EntryDemo(
            "tc4",
            hints: [
                "탭 6개입니다. **라벨이 어떻게 되는지** 보세요 — 줄어들거나 잘립니다.",
                "가장 오른쪽 탭을 한 손으로 눌러보세요. 옆 탭을 잘못 누르지 않는지도요.",
                "여기까지 왔다면 대개 정보 구조를 다시 짜야 한다는 신호입니다.",
            ],
            code: """
            TabView { /* 탭 6개 — 표준 범위(3~5)를 넘어선 한계 케이스 */ }
            """
        ) { TabDemoScreen(config: .init(count: 6)) },

        EntryDemo(
            "tv1",
            hints: [
                "목록에서 **상세 화면으로 들어가기**를 눌러 깊이 들어가 보세요.",
                "탭바가 그대로 있습니다 — 상세를 보다가도 다른 탭으로 바로 건너뛸 수 있습니다.",
                "\"지금 어느 세계에 있는가\"가 계속 보이는 것이 기본 동작인 이유입니다.",
            ],
            code: """
            NavigationStack {
                List { NavigationLink("상세") { DetailView() } }
            }
            // 아무것도 하지 않으면 탭바는 계속 보인다
            """
        ) { TabDemoScreen(config: .init(count: 4)) },

        EntryDemo(
            "tv2",
            hints: [
                "상세 화면으로 들어가 보세요 — 탭바가 **사라집니다**.",
                "출구가 뒤로가기 하나뿐입니다. 몰입은 얻고 이동성은 잃습니다.",
                "3.3.1과 번갈아 보며, 이 화면이 정말 몰입이 필요한 화면인지 스스로 물어보세요.",
            ],
            code: """
            DetailView()
                .toolbar(.hidden, for: .tabBar)
            """
        ) { TabDemoScreen(config: .init(count: 4, hideOnDetail: true)) },

        EntryDemo(
            "ts1",
            hints: [
                "검색이 **다른 탭과 나란히** 있습니다 — 동급의 한 세계라는 선언입니다.",
                "검색 탭에 들어가면 최근 검색·추천이 있는 별도의 화면입니다. 단순 필터가 아닙니다.",
                "3.4.2(search role)와 비교해 보세요. 자리 하나가 의미를 바꿉니다.",
            ],
            code: """
            TabView {
                Tab("홈", systemImage: "house") { … }
                Tab("검색", systemImage: "magnifyingglass") { SearchWorld() }
            }
            """
        ) { TabDemoScreen(config: .init(count: 3, search: .plainTab)) },

        EntryDemo(
            "ts2",
            hints: [
                "오른쪽 끝 검색이 **다른 탭과 분리된 캡슐**로 떠 있습니다. 눌러보세요.",
                "시스템이 검색임을 알고 자리를 따로 준 것입니다 — 라벨이 아니라 role 이 만든 차이입니다.",
                "검색 화면에서 실제로 걸러지는지 쳐보세요.",
            ],
            code: """
            TabView {
                Tab("홈", systemImage: "house") { … }
                Tab(role: .search) { SearchView() }
            }
            """
        ) { TabDemoScreen(config: .init(count: 3, search: .role)) },

        EntryDemo(
            "ts3",
            hints: [
                "스크롤해 보세요 — 탭바는 접히고 **검색 캡슐은 남습니다**.",
                "접힌 상태에서 검색을 눌러보세요. 읽는 중에도 검색만은 한 손에 닿습니다.",
                "무엇을 접고 무엇을 남길지 — 시스템이 이미 정해둔 우선순위를 확인하는 항목입니다.",
            ],
            code: """
            TabView {
                Tab("홈", systemImage: "house") { … }
                Tab(role: .search) { SearchView() }
            }
            .tabBarMinimizeBehavior(.onScrollDown)
            """
        ) { TabDemoScreen(config: .init(count: 3, minimize: true, search: .role)) },

        EntryDemo(
            "ts4",
            hints: [
                "지금 보이는 오른쪽 분리 캡슐은 **검색 role**로 만든 것입니다.",
                "iOS 27의 `.prominent` 는 이 자리를 검색이 아닌 탭에도 열어줍니다 — 예: \"만들기\".",
                "그때 판단 기준은 하나입니다. 그 탭이 정말 **다른 탭들과 격이 다른가**.",
            ],
            code: """
            // iOS 27 (WWDC26) 예정 API
            TabView {
                Tab("홈", systemImage: "house") { … }
                Tab("만들기", systemImage: "plus", role: .prominent) { CreateView() }
            }
            """,
            note: "이 앱이 쓰는 iOS 26 SDK에는 `.prominent` 가 아직 없습니다. 그래서 여기서는 **같은 자리를 쓰는 `.search` role** 로 대신 보여줍니다 — 자리와 분리 방식은 동일합니다."
        ) { TabDemoScreen(config: .init(count: 3, search: .role, prominentNote: true)) },

        EntryDemo(
            "ta1",
            hints: [
                "탭바 위에 **미니 플레이어**가 얹혀 있습니다. 재생 버튼을 눌러보세요 — 실제로 상태가 바뀝니다.",
                "탭을 옮겨 다녀도 재생 상태가 유지됩니다. 화면이 아니라 **앱 전체의 상태**이기 때문입니다.",
                "액세서리를 눌러 확장 화면을 열어보세요.",
            ],
            code: """
            TabView { /* 탭 3개 */ }
                .tabViewBottomAccessory {
                    MiniPlayer(isPlaying: $isPlaying)
                }
            """
        ) { TabDemoScreen(config: .init(count: 3, accessory: true)) },

        EntryDemo(
            "ta2",
            hints: [
                "스크롤해 보세요 — 탭바가 접히면서 액세서리가 **그 자리로 내려앉습니다**.",
                "접힌 상태에서도 재생·일시정지는 그대로 눌립니다. 기능을 잃지 않고 자리만 줄입니다.",
                "다시 위로 올려 원래 배치로 돌아오는 것까지 확인해 보세요.",
            ],
            code: """
            TabView { /* 탭 3개 */ }
                .tabViewBottomAccessory { MiniPlayer() }
                .tabBarMinimizeBehavior(.onScrollDown)
            """
        ) { TabDemoScreen(config: .init(count: 3, minimize: true, accessory: true)) },

        EntryDemo(
            "ta3",
            hints: [
                "하단 시스템의 풀 구성입니다 — 탭 + 검색 캡슐 + 액세서리 + 최소화.",
                "스크롤하며 **네 요소가 각각 어떻게 반응하는지** 하나씩 눈으로 따라가 보세요.",
                "여기까지 쌓았다면 하단은 포화 상태입니다. 더 넣을 자리는 없습니다.",
            ],
            code: """
            TabView {
                Tab("홈", systemImage: "house") { … }
                Tab(role: .search) { SearchView() }
            }
            .tabViewBottomAccessory { MiniPlayer() }
            .tabBarMinimizeBehavior(.onScrollDown)
            """
        ) { TabDemoScreen(config: .init(count: 3, minimize: true, search: .role, accessory: true)) },
    ]
}

// MARK: - 구성

private struct TabDemoConfig {
    enum Badge { case none, count, text }
    enum Search { case none, plainTab, role }

    var count: Int = 4
    var iconOnly = false
    var badge = Badge.none
    var minimize = false
    var hideOnDetail = false
    var search = Search.none
    var accessory = false
    var prominentNote = false
}

// MARK: - 한 벌의 탭 화면

private struct TabDemoScreen: View {
    let config: TabDemoConfig

    @State private var selection = 0
    @State private var unread = 3
    @State private var hasNew = true
    @State private var playing = false
    @State private var expanded = false

    private static let names = ["홈", "둘러보기", "보관함", "알림", "설정", "더보기"]
    private static let symbols = ["house", "safari", "square.stack", "bell", "gearshape", "ellipsis"]

    var body: some View {
        TabView(selection: $selection) { tabs }
            .modifier(TabMinimize(enabled: config.minimize))
            .modifier(TabAccessory(enabled: config.accessory, playing: $playing, expanded: $expanded))
            .sheet(isPresented: $expanded) {
                DemoPlayerSheet(playing: $playing)
            }
            .onChange(of: selection) { _, new in
                // 배지는 "처리할 것이 남았다"는 뜻 — 보고 나면 줄어야 한다.
                if new == 0, config.badge == .text { hasNew = false }
            }
    }

    @TabContentBuilder<Int>
    private var tabs: some TabContent<Int> {
        ForEach(0..<config.count, id: \.self) { i in
            Tab(value: i) {
                page(i)
            } label: {
                if config.iconOnly {
                    Image(systemName: Self.symbols[i % Self.symbols.count])
                } else {
                    Label(Self.names[i % Self.names.count], systemImage: Self.symbols[i % Self.symbols.count])
                }
            }
            .badge(badge(for: i))
        }

        if config.search == .plainTab {
            Tab("검색", systemImage: "magnifyingglass", value: 90) {
                DemoSearchPage(asWorld: true)
            }
        }

        if config.search == .role {
            Tab(value: 91, role: .search) {
                DemoSearchPage(asWorld: false)
            }
        }
    }

    private func badge(for index: Int) -> Text? {
        guard index == 0 else { return nil }
        switch config.badge {
        case .none:  return nil
        case .count: return unread > 0 ? Text("\(unread)") : nil
        case .text:  return hasNew ? Text("NEW") : nil
        }
    }

    @ViewBuilder
    private func page(_ index: Int) -> some View {
        let title = Self.names[index % Self.names.count]

        NavigationStack {
            Group {
                switch index % 6 {
                case 1:
                    ScrollView { DemoPhotoGrid(count: 36) }
                case 4:
                    DemoSettingsPage()
                default:
                    List {
                        if config.prominentNote {
                            Section {
                                DemoNote(text: "오른쪽 끝 캡슐이 iOS 27 `.prominent` 가 노리는 **바로 그 자리**입니다. 지금은 `.search` role 로 대신 보여줍니다.", symbol: "sparkles")
                                    .listRowInsets(.init(top: 6, leading: 12, bottom: 6, trailing: 12))
                            }
                        }
                        Section {
                            NavigationLink("상세 화면으로 들어가기") { detail }
                        }
                        if config.badge == .count, index == 0 {
                            Section("읽지 않음 \(unread)") {
                                ForEach(0..<max(unread, 1), id: \.self) { i in
                                    Button {
                                        withAnimation { unread = max(0, unread - 1) }
                                    } label: {
                                        Label("읽음으로 표시 \(i + 1)", systemImage: "envelope.badge")
                                    }
                                }
                            }
                        }
                        Section(title) {
                            ForEach(DemoData.mail) { DemoMailRow(mail: $0) }
                            ForEach(DemoData.mail) { DemoMailRow(mail: $0).id("dup-\($0.id)") }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle(title)
        }
    }

    private var detail: some View {
        List {
            DemoNote(
                text: config.hideOnDetail
                    ? "탭바를 **숨겼습니다** — 뒤로가기가 유일한 출구입니다."
                    : "탭바가 **유지됩니다** — 지금 어느 탭 안에 있는지가 계속 보이고, 바로 건너뛸 수 있습니다.",
                symbol: config.hideOnDetail ? "eye.slash" : "eye"
            )
            .listRowInsets(.init(top: 6, leading: 12, bottom: 6, trailing: 12))

            ForEach(0..<20, id: \.self) { i in
                Text("본문 \(i + 1)")
            }
        }
        .navigationTitle("상세")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(config.hideOnDetail ? .hidden : .visible, for: .tabBar)
    }
}

// MARK: - 탭 안의 화면들

private struct DemoSearchPage: View {
    /// 검색이 "한 세계"인지(탭), "목록을 좁히는 도구"인지(role)에 따라 첫 화면이 다르다.
    let asWorld: Bool

    @State private var query = ""

    private var rows: [DemoMail] {
        guard !query.isEmpty else { return [] }
        return DemoData.mail.filter {
            $0.sender.localizedCaseInsensitiveContains(query)
                || $0.subject.localizedCaseInsensitiveContains(query)
        }
    }

    var body: some View {
        NavigationStack {
            List {
                if query.isEmpty {
                    if asWorld {
                        Section("최근 검색") {
                            ForEach(["디자인 시안", "스프린트", "TestFlight"], id: \.self) { term in
                                Button { query = term } label: {
                                    Label(term, systemImage: "clock.arrow.circlepath")
                                }
                            }
                        }
                        Section("추천") {
                            ForEach(["읽지 않음", "첨부 있음", "지난 7일"], id: \.self) { term in
                                Label(term, systemImage: "sparkles")
                            }
                        }
                    } else {
                        Section {
                            DemoNote(text: "검색어를 입력하면 목록이 좁혀집니다 — **김 · 디자인 · 빌드**를 쳐보세요.")
                                .listRowInsets(.init(top: 6, leading: 12, bottom: 6, trailing: 12))
                        }
                    }
                } else if rows.isEmpty {
                    ContentUnavailableView.search(text: query)
                } else {
                    ForEach(rows) { DemoMailRow(mail: $0) }
                }
            }
            .navigationTitle("검색")
            .searchable(text: $query, prompt: "메일 검색")
        }
    }
}

private struct DemoSettingsPage: View {
    @State private var push = true
    @State private var sound = false
    @State private var size = 1.0

    var body: some View {
        Form {
            Section("알림") {
                Toggle("푸시 알림", isOn: $push)
                Toggle("소리", isOn: $sound)
            }
            Section("표시") {
                VStack(alignment: .leading) {
                    Text("글자 크기").font(.footnote).foregroundStyle(.secondary)
                    Slider(value: $size, in: 0.8...1.4)
                }
            }
            Section {
                LabeledContent("버전", value: "2.4.0")
            }
        }
    }
}

// MARK: - 액세서리

private struct TabMinimize: ViewModifier {
    let enabled: Bool

    func body(content: Content) -> some View {
        if enabled {
            content.tabBarMinimizeBehavior(.onScrollDown)
        } else {
            content
        }
    }
}

private struct TabAccessory: ViewModifier {
    let enabled: Bool
    @Binding var playing: Bool
    @Binding var expanded: Bool

    func body(content: Content) -> some View {
        if enabled {
            content.tabViewBottomAccessory {
                Button { expanded = true } label: {
                    HStack(spacing: 10) {
                        RoundedRectangle(cornerRadius: 5)
                            .fill(LinearGradient(colors: [.pink, .orange], startPoint: .top, endPoint: .bottom))
                            .frame(width: 26, height: 26)
                        VStack(alignment: .leading, spacing: 1) {
                            Text("Liquid Glass")
                                .font(.footnote.weight(.semibold))
                            Text(playing ? "재생 중" : "일시정지")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Button {
                            withAnimation { playing.toggle() }
                        } label: {
                            Image(systemName: playing ? "pause.fill" : "play.fill")
                                .font(.callout)
                                .frame(width: 32, height: 32)
                                .contentShape(.rect)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 14)
                    .contentShape(.rect)
                }
                .buttonStyle(.plain)
            }
        } else {
            content
        }
    }
}

private struct DemoPlayerSheet: View {
    @Binding var playing: Bool
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 22) {
            RoundedRectangle(cornerRadius: 18)
                .fill(LinearGradient(colors: [.pink, .orange], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 180, height: 180)

            VStack(spacing: 4) {
                Text("Liquid Glass").font(.title3.weight(.bold))
                Text("탭을 옮겨도 이 상태는 유지됩니다").font(.subheadline).foregroundStyle(.secondary)
            }

            Button {
                withAnimation { playing.toggle() }
            } label: {
                Image(systemName: playing ? "pause.circle.fill" : "play.circle.fill")
                    .font(.largeTitle)
            }
            .buttonStyle(.plain)

            Button("닫기") { dismiss() }
        }
        .padding(30)
        .presentationDetents([.medium])
    }
}
