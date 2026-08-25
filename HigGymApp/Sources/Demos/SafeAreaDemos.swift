import SwiftUI

/// 5장 Safe Area Bar — 시스템 바가 아닌 **내 바**를 안전 영역에 얹는 방법.
/// 핵심은 "콘텐츠가 그 바 밑으로 잘리지 않는다"는 계약이므로, 데모는 전부 끝까지 스크롤해봐야 한다.
@MainActor
enum SafeAreaDemos {
    static let all: [EntryDemo] = [
        EntryDemo(
            "va1",
            hints: [
                "상단의 필터 칩은 시스템 툴바가 아니라 **직접 만든 바**입니다. 눌러서 목록을 걸러보세요.",
                "끝까지 스크롤해 보세요 — 첫 항목이 바에 가려지지 않습니다. 자동으로 자리를 비켜줍니다.",
                "같은 뷰를 `overlay`로 얹었다면 첫 항목이 그 밑에 깔렸을 겁니다. 그 차이가 이 API의 전부입니다.",
            ],
            code: """
            ScrollView { /* 콘텐츠 */ }
                .safeAreaBar(edge: .top) {
                    FilterChips(selection: $filter)
                }
            """
        ) { SafeAreaBarDemo(kind: .top) },

        EntryDemo(
            "va2",
            hints: [
                "상단 바 안에 **타이틀과 카운트**가 함께 있습니다. 필터를 바꾸면 숫자가 실제로 바뀝니다.",
                "시스템 제목 대신 이 바가 화면 정체를 말합니다 — 그만큼 스스로 설명해야 합니다.",
                "스크롤해도 이 바는 접히지 않습니다. 대형 제목과의 차이를 1.2.1과 비교해 보세요.",
            ],
            code: """
            .safeAreaBar(edge: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("보관함").font(.title3.bold())
                    FilterChips(selection: $filter)
                }
            }
            """
        ) { SafeAreaBarDemo(kind: .topWithTitle) },

        EntryDemo(
            "va3",
            hints: [
                "하단의 **선택 액션 바**가 직접 만든 바입니다. 항목을 골라 눌러보세요.",
                "목록 맨 아래까지 스크롤해 보세요 — 마지막 항목이 바 위에서 멈춥니다.",
                "엄지에 가까운 자리라 자주 쓰는 액션을 둡니다 — 1.1.4와 같은 근거(8.1.2)입니다.",
            ],
            code: """
            List { /* … */ }
                .safeAreaBar(edge: .bottom) {
                    SelectionActionBar(count: selection.count)
                }
            """
        ) { SafeAreaBarDemo(kind: .bottom) },

        EntryDemo(
            "va4",
            hints: [
                "하단 커스텀 바 + **hard 가장자리 효과** + 시스템 툴바 아이템이 한 화면에 있습니다.",
                "배경을 사진·흰색으로 바꿔가며 스크롤해 보세요. 경계가 어떻게 가독성을 지키는지 보입니다.",
                "내 바와 시스템 바가 같은 아래쪽을 나눠 쓰고 있다는 점도 확인해 보세요.",
            ],
            code: """
            ScrollView { /* … */ }
                .safeAreaBar(edge: .bottom) { CustomBar() }
                .scrollEdgeEffectStyle(.hard, for: .bottom)
                .toolbar { ToolbarItemGroup(placement: .topBarTrailing) { … } }
            """
        ) { SafeAreaBarDemo(kind: .bottomHard) },

        EntryDemo(
            "va5",
            hints: [
                "위아래 **양쪽 모두** 커스텀 바입니다. 수직 방향의 풀 구성입니다.",
                "스크롤해서 콘텐츠가 두 바 사이에서만 움직이는지 확인해 보세요.",
                "남은 콘텐츠 영역이 얼마나 좁아졌는지 보세요 — 바를 하나 더 놓을 때마다 치르는 비용입니다.",
            ],
            code: """
            ScrollView { /* … */ }
                .safeAreaBar(edge: .top) { HeaderBar() }
                .safeAreaBar(edge: .bottom) { ActionBar() }
                .scrollEdgeEffectStyle(.soft, for: .top)
            """
        ) { SafeAreaBarDemo(kind: .topAndBottom) },

        EntryDemo(
            "ha1",
            hints: [
                "왼쪽 가장자리 **세로 도구 바**입니다. 도구를 눌러 캔버스 위에서 바꿔보세요.",
                "재료 배경이라 뒤 캔버스가 비칩니다 — 작업 대상을 가리지 않으려는 선택입니다.",
                "가로 바는 세로 공간을 아낍니다. 캔버스처럼 세로가 아까운 화면의 도구 배치입니다.",
            ],
            code: """
            Canvas { … }
                .safeAreaBar(edge: .leading, alignment: .top) {
                    ToolPalette(selection: $tool)
                        .background(.thinMaterial, in: .capsule)
                }
            """,
            chromeEdge: .trailing
        ) { HorizontalBarDemo(edge: .leading) },

        EntryDemo(
            "ha2",
            hints: [
                "오른쪽 가장자리 **정중앙**입니다. 엄지의 호가 지나가는 자리죠.",
                "버튼을 눌러 캔버스가 실제로 바뀌는지 확인해 보세요.",
                "5.2.1(왼쪽 상단)과 번갈아 열어, 손이 얼마나 다르게 움직이는지 느껴보세요.",
            ],
            code: """
            Canvas { … }
                .safeAreaBar(edge: .trailing, alignment: .center) {
                    QuickActions()
                }
            """,
            chromeEdge: .leading
        ) { HorizontalBarDemo(edge: .trailing) },
    ]
}

// MARK: - 세로 방향 바

private struct SafeAreaBarDemo: View {
    enum Kind { case top, topWithTitle, bottom, bottomHard, topAndBottom }

    let kind: Kind

    @State private var filter = DemoFilter.all
    @State private var selection = Set<Int>()
    @State private var backdrop = DemoBackdrop.dark
    @State private var log = DemoLog()

    private var rows: [DemoMail] { filter.apply(to: DemoData.mail) }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 0) {
                    if kind == .bottomHard {
                        DemoPicker(title: "배경", options: DemoBackdrop.allCases, label: \.rawValue, selection: $backdrop)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 8)
                            .foregroundStyle(backdrop.contentColor)
                    }
                    ForEach(rows) { mail in
                        row(mail)
                        Divider().padding(.leading, 16)
                    }
                    ForEach(rows) { mail in
                        row(mail).id("dup-\(mail.id)")
                        Divider().padding(.leading, 16)
                    }
                }
            }
            .background { if kind == .bottomHard { backdrop.view.ignoresSafeArea() } }
            .navigationTitle(kind == .topWithTitle ? "" : "보관함")
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                if kind == .bottomHard || kind == .topAndBottom {
                    ToolbarItemGroup(placement: .topBarTrailing) {
                        Button("선택", systemImage: "checkmark.circle") { log.tap("선택 모드") }
                        Button("더보기", systemImage: "ellipsis") { log.tap("더보기") }
                    }
                }
            }
            .modifier(BarsModifier(kind: kind, filter: $filter, count: rows.count, selection: $selection, log: log))
        }
        .demoToast(log)
    }

    private func row(_ mail: DemoMail) -> some View {
        Button {
            if selection.contains(mail.id) { selection.remove(mail.id) } else { selection.insert(mail.id) }
        } label: {
            HStack(spacing: 10) {
                Image(systemName: selection.contains(mail.id) ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(selection.contains(mail.id) ? AnyShapeStyle(.tint) : AnyShapeStyle(.secondary))
                DemoMailRow(mail: mail)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .foregroundStyle(kind == .bottomHard ? backdrop.contentColor : .primary)
    }
}

enum DemoFilter: String, CaseIterable, Identifiable {
    case all = "전체", unread = "안 읽음", flagged = "보낸사람순"
    var id: String { rawValue }

    func apply(to mail: [DemoMail]) -> [DemoMail] {
        switch self {
        case .all:     mail
        case .unread:  mail.filter(\.unread)
        case .flagged: mail.sorted { $0.sender < $1.sender }
        }
    }
}

/// 바를 어느 가장자리에 몇 개 붙일지는 케이스마다 다르므로 modifier 로 뺐다.
private struct BarsModifier: ViewModifier {
    let kind: SafeAreaBarDemo.Kind
    @Binding var filter: DemoFilter
    let count: Int
    @Binding var selection: Set<Int>
    let log: DemoLog

    func body(content: Content) -> some View {
        switch kind {
        case .top:
            content.safeAreaBar(edge: .top) { chips }
        case .topWithTitle:
            content.safeAreaBar(edge: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .firstTextBaseline) {
                        Text("보관함").font(.title2.weight(.bold))
                        Text("\(count)개").font(.subheadline).foregroundStyle(.secondary)
                        Spacer()
                    }
                    chips
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
        case .bottom:
            content.safeAreaBar(edge: .bottom) { actionBar }
        case .bottomHard:
            content
                .safeAreaBar(edge: .bottom) { actionBar }
                .scrollEdgeEffectStyle(.hard, for: .bottom)
        case .topAndBottom:
            content
                .safeAreaBar(edge: .top) { chips }
                .safeAreaBar(edge: .bottom) { actionBar }
                .scrollEdgeEffectStyle(.soft, for: .top)
        }
    }

    private var chips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(DemoFilter.allCases) { option in
                    Button {
                        withAnimation(.snappy) { filter = option }
                    } label: {
                        Text(option.rawValue)
                            .font(.subheadline.weight(.semibold))
                            .padding(.horizontal, 13)
                            .padding(.vertical, 7)
                            .background(filter == option ? AnyShapeStyle(.tint) : AnyShapeStyle(.quaternary), in: .capsule)
                            .foregroundStyle(filter == option ? .white : .primary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.vertical, 6)
    }

    private var actionBar: some View {
        HStack(spacing: 14) {
            Text(selection.isEmpty ? "항목을 선택하세요" : "\(selection.count)개 선택됨")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(selection.isEmpty ? .secondary : .primary)
            Spacer()
            Button("이동", systemImage: "folder") { log.tap("\(selection.count)개 이동") }
                .disabled(selection.isEmpty)
            Button("삭제", systemImage: "trash", role: .destructive) {
                log.tap("\(selection.count)개 삭제")
                selection.removeAll()
            }
            .disabled(selection.isEmpty)
        }
        .labelStyle(.iconOnly)
        .font(.body)
        .padding(.horizontal, 18)
        .padding(.vertical, 8)
    }
}

// MARK: - 가로 방향 바

private struct HorizontalBarDemo: View {
    let edge: HorizontalEdge

    @State private var tool = DemoTool.pen
    @State private var strokes: [DemoTool] = []
    @State private var log = DemoLog()

    var body: some View {
        NavigationStack {
            canvas
                .navigationTitle("캔버스")
                .toolbarTitleDisplayMode(.inline)
                .modifier(SideBarModifier(edge: edge, tool: $tool, onClear: { strokes.removeAll() }, log: log))
        }
        .demoToast(log)
    }

    private var canvas: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.12, green: 0.13, blue: 0.18), Color(red: 0.06, green: 0.07, blue: 0.1)],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 14) {
                ForEach(Array(strokes.enumerated()), id: \.offset) { index, stroke in
                    Capsule()
                        .fill(stroke.color.opacity(0.85))
                        .frame(width: CGFloat(80 + index * 18), height: stroke.thickness)
                }
                if strokes.isEmpty {
                    Text("도구를 골라 눌러보세요")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .animation(.snappy(duration: 0.2), value: strokes.count)
        }
        .contentShape(.rect)
        .onTapGesture { strokes.append(tool) }
    }
}

enum DemoTool: String, CaseIterable, Identifiable {
    case pen = "펜", marker = "마커", eraser = "지우개"
    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .pen: "pencil.tip"
        case .marker: "highlighter"
        case .eraser: "eraser"
        }
    }
    var color: Color {
        switch self {
        case .pen: .cyan
        case .marker: .yellow
        case .eraser: .gray
        }
    }
    var thickness: CGFloat {
        switch self {
        case .pen: 6
        case .marker: 14
        case .eraser: 10
        }
    }
}

private struct SideBarModifier: ViewModifier {
    let edge: HorizontalEdge
    @Binding var tool: DemoTool
    let onClear: () -> Void
    let log: DemoLog

    func body(content: Content) -> some View {
        if edge == .leading {
            content.safeAreaBar(edge: .leading, alignment: .top) {
                palette
                    .background(.thinMaterial, in: .capsule)
                    .overlay(Capsule().strokeBorder(.white.opacity(0.14), lineWidth: 1))
            }
        } else {
            content.safeAreaBar(edge: .trailing, alignment: .center) {
                palette
                    .background(.thinMaterial, in: .capsule)
                    .overlay(Capsule().strokeBorder(.white.opacity(0.14), lineWidth: 1))
            }
        }
    }

    private var palette: some View {
        VStack(spacing: 6) {
            ForEach(DemoTool.allCases) { option in
                Button {
                    withAnimation(.snappy) { tool = option }
                } label: {
                    Image(systemName: option.symbol)
                        .font(.callout)
                        .foregroundStyle(tool == option ? AnyShapeStyle(.tint) : AnyShapeStyle(.primary))
                        .frame(width: 36, height: 34)
                        .background {
                            if tool == option {
                                Circle().fill(.tint.opacity(0.16))
                            }
                        }
                }
                .buttonStyle(.plain)
            }
            Divider().frame(width: 22)
            Button {
                onClear()
                log.tap("지웠습니다")
            } label: {
                Image(systemName: "trash")
                    .font(.subheadline)
                    .frame(width: 36, height: 32)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 6)
    }
}
