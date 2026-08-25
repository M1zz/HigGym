import SwiftUI

/// 표본 앱(노트)으로는 보여줄 수 없는 결정들 — 오버플로 순서, 사진 위 가장자리 효과,
/// 큰 글씨에서의 잘림, 배지, 가짜 탭 — 을 위한 화면 한 쌍씩.
///
/// 레슨은 이 쌍을 두 번 쓴다. ① 써보기에서는 **고친 쪽만** 실제 크기로 띄워 손에 쥐여주고,
/// ④ 비교에서는 두 쪽을 같은 자리에서 갈아 끼운다. 그래서 쌍은 각자 상태를 갖는
/// 독립된 화면이어야 한다 — 비교하다 돌아와도 방금 만지던 상태가 남아 있어야 하기 때문.
enum LessonPair: String, CaseIterable, Identifiable, Sendable {
    case overflowOrder      // 실수 11 — 선언 순서가 곧 우선순위
    case scrollEdge         // 실수 29 — 사진 위에서 컨트롤이 사라진다
    case clampedText        // 실수 38 — 한 줄 고정 + 축소
    case stickyBadge        // 실수 52 — 줄지 않는 배지
    case fakeTab            // 실수 68 — 이동하지 않는 탭
    case decorButtons       // 실수 1  — 자리가 비어 보인다고 채운다
    case adBar              // 실수 14 — 콕핏 자리에 광고
    case customNavBar       // 실수 20 — 내비바를 직접 만든다
    case mapControls        // 실수 28 — 안 읽히는데 투명한 쪽이 예뻐서
    case searchDrawer       // 실수 34 — 검색이 접히는 서랍에
    case amount             // 실수 43 — 잘리면 안 되는 값을 자른다
    case tabCount           // 실수 59 — 여섯 개 탭
    case checkoutTab        // 실수 62 — 진행 중에 나갈 길을 열어둔다
    case paymentSheet       // 실수 79 — 확정하는 시트를 비모달로
    case menuOrder          // 실수 96 — 삭제를 일반 항목들 사이에

    var id: String { rawValue }

    @MainActor @ViewBuilder
    func view(broken: Bool) -> some View {
        switch self {
        case .overflowOrder: OverflowOrderScreen(broken: broken)
        case .scrollEdge:    ScrollEdgeScreen(broken: broken)
        case .clampedText:   ClampedTextScreen(broken: broken)
        case .stickyBadge:   StickyBadgeScreen(broken: broken)
        case .fakeTab:       FakeTabScreen(broken: broken)
        case .decorButtons:  DecorButtonsScreen(broken: broken)
        case .adBar:         AdBarScreen(broken: broken)
        case .customNavBar:  CustomNavBarScreen(broken: broken)
        case .mapControls:   MapControlsScreen(broken: broken)
        case .searchDrawer:  SearchDrawerScreen(broken: broken)
        case .amount:        AmountScreen(broken: broken)
        case .tabCount:      TabCountScreen(broken: broken)
        case .checkoutTab:   CheckoutTabScreen(broken: broken)
        case .paymentSheet:  PaymentSheetScreen(broken: broken)
        case .menuOrder:     MenuOrderScreen(broken: broken)
        }
    }
}

// MARK: - 실수 11 · 선언 순서가 곧 우선순위

private struct OverflowOrderScreen: View {
    let broken: Bool

    private struct Act: Identifiable {
        let id: String
        let name: String
        let symbol: String
    }

    private var actions: [Act] {
        let star = Act(id: "star", name: "별표", symbol: "star")
        let flag = Act(id: "flag", name: "깃발", symbol: "flag")
        let print_ = Act(id: "print", name: "프린트", symbol: "printer")
        let move = Act(id: "move", name: "이동", symbol: "folder")
        let save = Act(id: "save", name: "저장", symbol: "tray.and.arrow.down")
        // 폭이 모자라면 시스템은 뒤쪽부터 ⋯ 안으로 접는다. 순서가 곧 우선순위 선언이다.
        return broken ? [star, flag, print_, move, save] : [save, move, star, flag, print_]
    }

    @State private var saved = 0

    var body: some View {
        NavigationStack {
            List {
                Section {
                    LabeledContent("저장한 횟수", value: "\(saved)")
                        .font(.system(size: 14))
                }
                Section("문서") {
                    ForEach(DemoData.mail.prefix(8)) { DemoMailRow(mail: $0) }
                }
            }
            .listStyle(.plain)
            .navigationTitle("보고서 초안")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    ForEach(actions) { action in
                        Button(action.name, systemImage: action.symbol) {
                            if action.id == "save" { saved += 1 }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - 실수 29 · 밝은 사진이 바 뒤를 지날 때

private struct ScrollEdgeScreen: View {
    let broken: Bool

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 3), count: 3), spacing: 3) {
                    ForEach(0..<30, id: \.self) { i in
                        Group {
                            // 위쪽에 흰 사진을 섞어 둔다 — 어두운 샘플로만 확인하면 못 만나는 조건.
                            if i % 4 == 0 {
                                LinearGradient(colors: [.white, Color(white: 0.94)], startPoint: .top, endPoint: .bottom)
                            } else {
                                DemoPhoto(index: i)
                            }
                        }
                        .aspectRatio(1, contentMode: .fill)
                    }
                }
                .padding(.horizontal, 3)
            }
            .navigationTitle("사진")
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button("선택", systemImage: "checkmark.circle") {}
                    Button("공유", systemImage: "square.and.arrow.up") {}
                }
            }
            .modifier(EdgeModifier(hidden: broken))
        }
    }

    private struct EdgeModifier: ViewModifier {
        let hidden: Bool
        func body(content: Content) -> some View {
            if hidden {
                content.scrollEdgeEffectHidden(true, for: .top)
            } else {
                content.scrollEdgeEffectStyle(.hard, for: .top)
            }
        }
    }
}

// MARK: - 실수 38 · 큰 글씨에서 값이 사라진다

private struct ClampedTextScreen: View {
    let broken: Bool

    private let rows: [(String, String)] = [
        ("배송지", "서울특별시 성동구 아차산로 111 무학빌딩 7층 703호"),
        ("결제 금액", "₩1,284,000"),
        ("주문번호", "2026-0821-A7K9-4421"),
        ("받는 사람", "김하늘 (010-1234-5678)"),
    ]

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Label("접근성 큰 글씨 설정을 켠 상태입니다", systemImage: "textformat.size")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                Section("주문 정보") {
                    ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(row.0)
                                // 고정 크기(.system(size:))는 Dynamic Type 을 따르지 않는다.
                                // 잘림을 보여주려면 값도 라벨도 상대 폰트여야 한다.
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.secondary)
                            if broken {
                                Text(row.1).font(.body).lineLimit(1).minimumScaleFactor(0.4)
                            } else {
                                Text(row.1).font(.body).lineLimit(2...3)
                            }
                        }
                        .padding(.vertical, 3)
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("주문 확인")
            .navigationBarTitleDisplayMode(.inline)
        }
        // 기기 설정을 바꾸게 할 수는 없으니, 문제가 드러나는 조건을 화면이 스스로 만든다.
        // 축소(minimumScaleFactor)가 먼저 일하므로, 그 한계를 넘는 크기라야 잘림까지 보인다.
        .dynamicTypeSize(.accessibility5)
    }
}

// MARK: - 실수 52 · 줄지 않는 배지

private struct StickyBadgeScreen: View {
    let broken: Bool

    @State private var unread = 3
    @State private var read = 0

    var body: some View {
        TabView {
            Tab("홈", systemImage: "house") {
                NavigationStack {
                    List(DemoData.mail.prefix(8)) { DemoMailRow(mail: $0) }
                        .listStyle(.plain)
                        .navigationTitle("홈")
                }
            }
            Tab("소식", systemImage: "bell") {
                inbox
            }
            .badge(broken ? 1 : unread)
            Tab("설정", systemImage: "gearshape") {
                NavigationStack {
                    Form { Toggle("푸시 알림", isOn: .constant(true)) }
                        .navigationTitle("설정")
                }
            }
        }
    }

    private var inbox: some View {
        NavigationStack {
            List {
                if broken {
                    Section {
                        Text("읽은 소식 \(read)개 — 배지는 그대로입니다")
                            .font(.system(size: 13))
                            .foregroundStyle(.secondary)
                    }
                }
                if !broken && unread == 0 {
                    ContentUnavailableView("새 소식 없음", systemImage: "checkmark.circle")
                } else {
                    ForEach(0..<(broken ? 3 : unread), id: \.self) { index in
                        Button {
                            if broken { read += 1 } else { unread = max(0, unread - 1) }
                        } label: {
                            Label("새 소식 \(index + 1) — 읽음으로 표시", systemImage: "envelope.badge")
                        }
                    }
                }
            }
            .navigationTitle("소식")
        }
    }
}

// MARK: - 실수 68 · 이동하지 않는 탭

private struct FakeTabScreen: View {
    let broken: Bool

    @State private var selection = 0
    @State private var composing = false

    var body: some View {
        Group {
            if broken {
                TabView(selection: $selection) {
                    Tab("홈", systemImage: "house", value: 0) { page("홈") }
                    Tab("작성", systemImage: "square.and.pencil", value: 1) { Color.clear }
                    Tab("설정", systemImage: "gearshape", value: 2) { page("설정") }
                }
                .onChange(of: selection) { _, new in
                    // 목적지가 없는 탭 — 누르면 시트만 뜨고 선택은 되돌아간다.
                    guard new == 1 else { return }
                    composing = true
                    selection = 0
                }
            } else {
                TabView(selection: $selection) {
                    Tab("홈", systemImage: "house", value: 0) {
                        page("홈", compose: { composing = true })
                    }
                    Tab("설정", systemImage: "gearshape", value: 2) { page("설정") }
                }
            }
        }
        .sheet(isPresented: $composing) { DemoComposeSheet() }
    }

    private func page(_ title: String, compose: (() -> Void)? = nil) -> some View {
        NavigationStack {
            List(DemoData.mail.prefix(8)) { DemoMailRow(mail: $0) }
                .listStyle(.plain)
                .navigationTitle(title)
                .toolbar {
                    if let compose {
                        ToolbarItemGroup(placement: .bottomBar) {
                            Spacer()
                            Button("작성", systemImage: "square.and.pencil", action: compose)
                        }
                    }
                }
        }
    }
}
