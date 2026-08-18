import SwiftUI

/// 1.4 Search — 검색을 어디에 두느냐의 여섯 케이스.
/// 전부 **실제로 걸러집니다** — "김", "디자인", "빌드" 처럼 쳐보면 자리마다 손의 동선이 달라지는 게 느껴진다.
@MainActor
enum SearchDemos {
    static let all: [EntryDemo] = [
        EntryDemo(
            "q1",
            hints: [
                "화면 아래 검색 캡슐을 눌러 **김**이라고 쳐보세요 — 목록이 실제로 걸러집니다.",
                "엄지를 거의 움직이지 않고 닿습니다. iOS 26이 검색을 아래로 내린 이유입니다.",
                "스크롤하면 캡슐이 어떻게 반응하는지도 보세요.",
            ],
            code: """
            .searchable(text: $query, placement: .toolbar, prompt: "메일 검색")
            // iPhone: 하단 유리 캡슐 · iPad: 상단 trailing
            """
        ) { SearchDemoScreen(placement: .toolbarBottom) },

        EntryDemo(
            "q2",
            hints: [
                "하단에 검색 필드와 **작성 버튼**이 함께 있습니다. 둘 다 눌러보세요.",
                "검색을 시작하면 옆 버튼이 어떻게 자리를 내주는지 보세요.",
                "하단은 이제 경쟁이 심한 자리입니다 — 무엇까지 내려보낼지가 설계입니다.",
            ],
            code: """
            .searchable(text: $query, placement: .toolbar)
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    Button("새 메일", systemImage: "square.and.pencil") { composing = true }
                }
            }
            """
        ) { SearchDemoScreen(placement: .toolbarWithItem) },

        EntryDemo(
            "q3",
            hints: [
                "검색바가 제목 **아래 서랍**에 있습니다. 목록을 스크롤해 보세요 — 접혀서 사라집니다.",
                "다시 아래로 당기면 나타납니다. \"필요할 때만 꺼내는\" 기본 동작입니다.",
                "손이 화면 위쪽까지 올라가야 한다는 점을 1.4.1과 비교해 보세요.",
            ],
            code: """
            .searchable(text: $query, placement: .navigationBarDrawer)
            // 기본값: 스크롤하면 접힌다
            """
        ) { SearchDemoScreen(placement: .drawerAuto) },

        EntryDemo(
            "q4",
            hints: [
                "스크롤해도 검색바가 **사라지지 않습니다**.",
                "1.4.3과 번갈아 보며, 항상 보이는 대신 무엇을 잃었는지(세로 공간) 확인해 보세요.",
                "검색이 그 화면의 주 사용 방식일 때만 정당한 선택입니다.",
            ],
            code: """
            .searchable(
                text: $query,
                placement: .navigationBarDrawer(displayMode: .always)
            )
            """
        ) { SearchDemoScreen(placement: .drawerAlways) },

        EntryDemo(
            "q5",
            hints: [
                "제목이 있어야 할 정중앙을 **검색 필드가 차지**했습니다.",
                "화면 정체를 검색이 대신 설명합니다 — 검색이 곧 이 화면의 목적일 때만 맞습니다.",
                "1.1.5(principal)와 같은 자리 문법입니다. 자리가 곧 선언입니다.",
            ],
            code: """
            .searchable(text: $query, placement: .toolbarPrincipal)
            """
        ) { SearchDemoScreen(placement: .principal) },

        EntryDemo(
            "q6",
            hints: [
                "툴바에 아이템이 여럿 있는 상태에서 검색을 시작해 보세요.",
                "스크롤하면 검색이 **아이콘 하나로 축소**됩니다 — `.searchToolbarBehavior(.minimize)`.",
                "축소·분리·자리 확보를 조합해 한 툴바 안에서 공존시키는 게 이 항목의 요지입니다.",
            ],
            code: """
            .searchable(text: $query)
            .searchToolbarBehavior(.minimize)
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) { /* 다른 아이템들 */ }
            }
            """
        ) { SearchDemoScreen(placement: .minimized) },
    ]
}

private struct SearchDemoScreen: View {
    enum Placement {
        case toolbarBottom, toolbarWithItem, drawerAuto, drawerAlways, principal, minimized
    }

    let placement: Placement

    @State private var query = ""
    @State private var composing = false
    @State private var log = DemoLog()

    private var rows: [DemoMail] {
        guard !query.isEmpty else { return DemoData.mail }
        return DemoData.mail.filter {
            $0.sender.localizedCaseInsensitiveContains(query)
                || $0.subject.localizedCaseInsensitiveContains(query)
                || $0.preview.localizedCaseInsensitiveContains(query)
        }
    }

    var body: some View {
        NavigationStack {
            List {
                if rows.isEmpty {
                    ContentUnavailableView.search(text: query)
                } else {
                    Section {
                        DemoNote(text: "**김 · 디자인 · 빌드** 중 아무거나 쳐보세요. 진짜로 걸러집니다.")
                            .listRowInsets(.init(top: 6, leading: 12, bottom: 6, trailing: 12))
                    }
                    ForEach(rows) { DemoMailRow(mail: $0) }
                    ForEach(rows) { DemoMailRow(mail: $0).id("dup-\($0.id)") }
                }
            }
            .listStyle(.plain)
            .navigationTitle("메일")
            .toolbarTitleDisplayMode(placement == .principal ? .inline : .large)
            .toolbar { extraItems }
            .modifier(SearchPlacementModifier(placement: placement, query: $query))
        }
        .sheet(isPresented: $composing) { DemoComposeSheet() }
        .demoToast(log)
    }

    @ToolbarContentBuilder
    private var extraItems: some ToolbarContent {
        if placement == .toolbarWithItem {
            ToolbarItem(placement: .bottomBar) {
                Button("새 메일", systemImage: "square.and.pencil") { composing = true }
            }
        }
        if placement == .minimized {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button("필터", systemImage: "line.3.horizontal.decrease") { log.tap("필터") }
                Button("정렬", systemImage: "arrow.up.arrow.down") { log.tap("정렬") }
                Button("더보기", systemImage: "ellipsis") { log.tap("더보기") }
            }
        }
    }
}

private struct SearchPlacementModifier: ViewModifier {
    let placement: SearchDemoScreen.Placement
    @Binding var query: String

    func body(content: Content) -> some View {
        switch placement {
        case .toolbarBottom, .toolbarWithItem:
            content.searchable(text: $query, placement: .toolbar, prompt: "메일 검색")
        case .drawerAuto:
            content.searchable(text: $query, placement: .navigationBarDrawer, prompt: "메일 검색")
        case .drawerAlways:
            content.searchable(text: $query, placement: .navigationBarDrawer(displayMode: .always), prompt: "메일 검색")
        case .principal:
            content.searchable(text: $query, placement: .toolbarPrincipal, prompt: "메일 검색")
        case .minimized:
            content.searchable(text: $query, prompt: "메일 검색").searchToolbarBehavior(.minimize)
        }
    }
}
