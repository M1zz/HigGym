import SwiftUI

/// 1.1 Items — 아홉 케이스는 결국 **자리 · 개수 · 넘칠 때의 처리** 세 변수의 조합이다.
/// 그림으로는 배치까지만 보이므로, 여기서는 그 배치가 실제로 어떻게 동작하는지까지 만져본다.
@MainActor
enum ToolbarItemsDemos {
    static let all: [EntryDemo] = [
        EntryDemo(
            "i1",
            hints: [
                "오른쪽 위 **편집**을 눌러보세요 — 액션 하나가 화면 전체의 모드를 바꿉니다.",
                "편집 중에는 같은 자리가 **완료**로 바뀝니다. 자리는 그대로, 역할만 이어집니다.",
                "왼쪽은 비어 있습니다 — 뒤로가기가 선점하는 자리라 액션을 두지 않습니다.",
            ],
            code: """
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(editing ? "완료" : "편집") { editing.toggle() }
                }
            }
            """
        ) { SingleTrailingDemo() },

        EntryDemo(
            "i2",
            hints: [
                "줄을 몇 개 추가한 뒤 왼쪽 **실행취소 / 다시실행**을 눌러보세요 — 실제로 되돌아갑니다.",
                "두 버튼은 한 캡슐에 묶여 있습니다. \"같은 세트\"라는 신호입니다.",
                "오른쪽 **완료**는 혼자 떨어져 있습니다 — 도구가 아니라 결정이기 때문입니다.",
            ],
            code: """
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button("실행취소", systemImage: "arrow.uturn.backward") { undo() }
                        .disabled(lines.isEmpty)
                    Button("다시실행", systemImage: "arrow.uturn.forward") { redo() }
                        .disabled(undone.isEmpty)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("완료") { save() }
                }
            }
            """
        ) { LeadingClusterDemo() },

        EntryDemo(
            "i3",
            hints: [
                "왼쪽 캡슐 — **보기 전환**과 **정렬**. 둘 다 \"어떻게 볼 것인가\"입니다.",
                "오른쪽 캡슐 — **선택**과 **공유**. 콘텐츠를 다루는 일입니다.",
                "두 캡슐 사이의 빈 공간이 \"서로 다른 일\"이라는 신호입니다. 하나로 합쳐진 모습을 상상해 보세요.",
            ],
            code: """
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button(grid ? "목록" : "격자", systemImage: grid ? "list.bullet" : "square.grid.2x2") {
                        grid.toggle()
                    }
                    Menu("정렬", systemImage: "arrow.up.arrow.down") { /* 정렬 기준 */ }
                }
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button("선택", systemImage: "checkmark.circle") { selecting.toggle() }
                    Button("공유", systemImage: "square.and.arrow.up") { share() }
                }
            }
            """
        ) { TwoClustersDemo() },

        EntryDemo(
            "i4",
            hints: [
                "화면 아래 오른쪽에 떠 있는 **작성** 버튼을 눌러보세요 — 엄지가 닿는 자리입니다.",
                "같은 액션이 오른쪽 위에 있었다면 한 손으로 몇 번이나 눌렀을지 상상해 보세요.",
                "목록을 스크롤해도 하단 버튼은 그대로 떠 있습니다.",
            ],
            code: """
            .toolbar {
                // 단독 아이템은 기본이 가운데다. 메일 앱처럼 오른쪽 끝에 두려면 Spacer 로 민다.
                ToolbarItemGroup(placement: .bottomBar) {
                    Spacer()
                    Button("새 메일", systemImage: "square.and.pencil") { composing = true }
                }
            }
            .sheet(isPresented: $composing) { ComposeView() }
            """
        ) { BottomItemDemo() },

        EntryDemo(
            "i5",
            hints: [
                "정중앙의 **지도 / 목록** 세그먼트를 눌러보세요 — 화면 전체가 바뀝니다.",
                "제목이 없습니다. 이 컨트롤이 곧 \"이 화면이 무엇인가\"이기 때문입니다.",
                "여기에 공유 버튼이 있었다면 어땠을지 — 가장 강한 자리가 잡일에 쓰였을 겁니다.",
            ],
            code: """
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Picker("보기", selection: $mode) {
                        Text("지도").tag(Mode.map)
                        Text("목록").tag(Mode.list)
                    }
                    .pickerStyle(.segmented)
                }
            }
            """
        ) { PrincipalDemo() },

        EntryDemo(
            "i6",
            hints: [
                "중앙 세그먼트로 화면을 바꾸고, 오른쪽 **⋯** 메뉴도 열어보세요.",
                "오른쪽 액션은 어느 모드에서도 그대로입니다 — 모드와 무관한 부가 기능이기 때문입니다.",
                "세그먼트를 더 길게 만들면 오른쪽과 공간을 다투게 됩니다. 그래서 trailing은 하나로 절제합니다.",
            ],
            code: """
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Picker("보기", selection: $mode) { /* 지도 · 목록 */ }
                        .pickerStyle(.segmented)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Menu("더보기", systemImage: "ellipsis") { /* 부가 액션 */ }
                }
            }
            """
        ) { PrincipalTrailingDemo() },

        EntryDemo(
            "i7",
            hints: [
                "화면 안 스테퍼로 아이템을 **하나씩 늘려보세요**. 어느 순간 시스템이 나머지를 **…** 안으로 접습니다.",
                "접히는 순서는 선언 순서를 따릅니다 — 자주 쓰는 것을 앞에 둬야 하는 이유입니다.",
                "억지로 다 펼쳤다면 버튼이 손가락보다 작아졌을 겁니다. 접기는 최소 터치 크기를 지키는 장치입니다.",
            ],
            code: """
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    ForEach(actions.prefix(count)) { action in
                        Button(action.name, systemImage: action.symbol) { run(action) }
                    }
                }
            }
            // 폭이 모자라면 시스템이 뒤쪽부터 ··· 메뉴로 접는다.
            """
        ) { OverflowDemo() },

        EntryDemo(
            "i8",
            hints: [
                "하단 바의 **슬라이더**를 끌어보세요 — 버튼이 아닌 뷰도 툴바에 들어갑니다.",
                "격자 크기가 실제로 바뀝니다. 조작 대상(사진)을 보면서 조작합니다.",
                "왼쪽 진행 표시처럼 **상태를 보여주기만 하는 뷰**도 같은 자리에 놓을 수 있습니다.",
            ],
            code: """
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    HStack(spacing: 12) {
                        Text("\\(count)장").font(.footnote).monospacedDigit()
                        Slider(value: $zoom, in: 2...5, step: 1)
                            .frame(width: 140)
                        ProgressView(value: uploaded).frame(width: 44)
                    }
                }
            }
            """
        ) { CustomBottomViewsDemo() },

        EntryDemo(
            "i9",
            hints: [
                "네 자리가 한 화면에 다 있습니다 — 왼쪽 묶음 · 중앙 컨트롤 · 오른쪽 액션 · 하단 바.",
                "전부 눌러보세요. 다 동작하지만, 이 화면에서 **정말 필요한 것이 몇 개인지** 세어 보세요.",
                "하단 스위치로 \"필요한 것만\" 구성과 비교해 보세요. 같은 화면이 얼마나 조용해지는지 봅니다.",
            ],
            code: """
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) { /* 도구 묶음 */ }
                ToolbarItem(placement: .principal) { /* 화면을 정의하는 컨트롤 */ }
                ToolbarItemGroup(placement: .topBarTrailing) { /* 결정 액션 */ }
                ToolbarItemGroup(placement: .bottomBar) { /* 고빈도 액션 */ }
            }
            """
        ) { MixedToolbarDemo() },
    ]
}

// MARK: - 1.1.1 액션 하나

private struct SingleTrailingDemo: View {
    @State private var editing = false
    @State private var selection = Set<Int>()
    @State private var rows = DemoData.mail

    var body: some View {
        NavigationStack {
            List(selection: $selection) {
                ForEach(rows) { mail in
                    DemoMailRow(mail: mail).tag(mail.id)
                }
                .onDelete { rows.remove(atOffsets: $0) }
            }
            .listStyle(.plain)
            .environment(\.editMode, .constant(editing ? .active : .inactive))
            .navigationTitle("보관함")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(editing ? "완료" : "편집") {
                        withAnimation { editing.toggle() }
                        if !editing { selection.removeAll() }
                    }
                    .fontWeight(editing ? .semibold : .regular)
                }
            }
        }
    }
}

// MARK: - 1.1.2 도구 묶음 + 결정

private struct LeadingClusterDemo: View {
    @State private var lines: [String] = ["회의록 초안", "참석자 정리"]
    @State private var undone: [String] = []
    @State private var log = DemoLog()

    private let pool = ["할 일 정리", "다음 액션 아이템", "일정 확정", "공유 대상", "예산 확인"]

    var body: some View {
        NavigationStack {
            List {
                ForEach(Array(lines.enumerated()), id: \.offset) { _, line in
                    Text(line).font(.callout)
                }
                Button {
                    withAnimation {
                        lines.append(pool[lines.count % pool.count])
                        undone.removeAll()
                    }
                } label: {
                    Label("줄 추가", systemImage: "plus")
                }
            }
            .navigationTitle("메모")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button("실행취소", systemImage: "arrow.uturn.backward") {
                        withAnimation { undone.append(lines.removeLast()) }
                    }
                    .disabled(lines.isEmpty)

                    Button("다시실행", systemImage: "arrow.uturn.forward") {
                        withAnimation { lines.append(undone.removeLast()) }
                    }
                    .disabled(undone.isEmpty)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("완료") { log.tap("저장했습니다 · \(lines.count)줄") }
                        .fontWeight(.semibold)
                }
            }
        }
        .demoToast(log)
    }
}

// MARK: - 1.1.3 두 개의 독립 클러스터

private struct TwoClustersDemo: View {
    private enum Sort: String, CaseIterable, Identifiable {
        case recent = "최신순", sender = "보낸사람", unread = "안 읽음 먼저"
        var id: String { rawValue }
    }

    @State private var grid = false
    @State private var sort = Sort.recent
    @State private var selecting = false
    @State private var log = DemoLog()

    private var rows: [DemoMail] {
        switch sort {
        case .recent: DemoData.mail
        case .sender: DemoData.mail.sorted { $0.sender < $1.sender }
        case .unread: DemoData.mail.sorted { $0.unread && !$1.unread }
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if grid {
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 12)], spacing: 12) {
                            ForEach(rows) { mail in
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(mail.sender).font(.subheadline.weight(.semibold))
                                    Text(mail.subject).font(.footnote).foregroundStyle(.secondary)
                                        .lineLimit(2)
                                }
                                .frame(maxWidth: .infinity, minHeight: 66, alignment: .topLeading)
                                .padding(10)
                                .background(.quaternary.opacity(0.4), in: .rect(cornerRadius: 12))
                                .overlay(alignment: .topTrailing) {
                                    if selecting {
                                        Image(systemName: "circle").padding(6).foregroundStyle(.tint)
                                    }
                                }
                            }
                        }
                        .padding(12)
                    }
                } else {
                    List(rows) { mail in
                        HStack(spacing: 8) {
                            if selecting {
                                Image(systemName: "circle").foregroundStyle(.tint)
                            }
                            DemoMailRow(mail: mail)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .animation(.snappy(duration: 0.25), value: grid)
            .animation(.snappy(duration: 0.25), value: sort)
            .navigationTitle("보관함")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button(grid ? "목록" : "격자", systemImage: grid ? "list.bullet" : "square.grid.2x2") {
                        withAnimation { grid.toggle() }
                    }
                    Menu("정렬", systemImage: "arrow.up.arrow.down") {
                        Picker("정렬", selection: $sort) {
                            ForEach(Sort.allCases) { Text($0.rawValue).tag($0) }
                        }
                    }
                }
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button("선택", systemImage: selecting ? "checkmark.circle.fill" : "checkmark.circle") {
                        withAnimation { selecting.toggle() }
                    }
                    Button("공유", systemImage: "square.and.arrow.up") {
                        log.tap(selecting ? "선택한 항목을 공유합니다" : "먼저 선택 모드를 켜보세요")
                    }
                }
            }
        }
        .demoToast(log)
    }
}

// MARK: - 1.1.4 고빈도는 하단으로

private struct BottomItemDemo: View {
    @State private var composing = false
    @State private var sent = 0

    var body: some View {
        NavigationStack {
            DemoMailList()
                .navigationTitle("받은 편지함")
                .toolbar {
                    // 하단 단독 아이템은 시스템 기본값이 가운데다. 문서 목업(1.1.4)과 메일 앱은
                    // 오른쪽 끝 — 왼손·오른손 모두 엄지 호의 바깥이 아닌 자리다. Spacer 로 밀어준다.
                    ToolbarItemGroup(placement: .bottomBar) {
                        Spacer()
                        Button("새 메일", systemImage: "square.and.pencil") { composing = true }
                    }
                }
                .safeAreaInset(edge: .top) {
                    if sent > 0 {
                        Text("보낸 메일 \(sent)통")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(.secondary)
                            .padding(.vertical, 5)
                    }
                }
        }
        .sheet(isPresented: $composing) {
            DemoComposeSheet { sent += 1 }
        }
    }
}

/// 하단 액션이 실제로 무언가를 여는지 확인시켜 주는 최소한의 작성 화면.
struct DemoComposeSheet: View {
    var onSend: () -> Void = {}

    @Environment(\.dismiss) private var dismiss
    @State private var to = ""
    @State private var body_ = ""

    var body: some View {
        NavigationStack {
            Form {
                TextField("받는 사람", text: $to)
                TextField("내용", text: $body_, axis: .vertical)
                    .lineLimit(4...8)
            }
            .navigationTitle("새 메일")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("취소") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("보내기") { onSend(); dismiss() }
                        .fontWeight(.semibold)
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

// MARK: - 1.1.5 화면을 정의하는 중앙 컨트롤

private struct PrincipalDemo: View {
    enum Mode: String, CaseIterable, Identifiable {
        case map = "지도", list = "목록"
        var id: String { rawValue }
    }

    @State private var mode = Mode.map

    var body: some View {
        NavigationStack {
            content
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Picker("보기", selection: $mode) {
                            ForEach(Mode.allCases) { Text($0.rawValue).tag($0) }
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 160)
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
        }
    }

    @ViewBuilder
    private var content: some View {
        switch mode {
        case .map:  DemoMapCanvas()
        case .list: DemoMailList(repeats: 1)
        }
    }
}

/// 코드로만 그리는 지도 대용 — 중앙 컨트롤을 바꿨을 때 화면 전체가 바뀐다는 사실이 보이면 충분하다.
struct DemoMapCanvas: View {
    var pins: Int = 5

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.10, green: 0.22, blue: 0.18), Color(red: 0.06, green: 0.13, blue: 0.22)],
                startPoint: .top, endPoint: .bottom
            )
            Canvas { context, size in
                for i in stride(from: 0, to: size.width, by: 48) {
                    context.stroke(Path { $0.move(to: .init(x: i, y: 0)); $0.addLine(to: .init(x: i, y: size.height)) },
                                   with: .color(.white.opacity(0.06)))
                }
                for i in stride(from: 0, to: size.height, by: 48) {
                    context.stroke(Path { $0.move(to: .init(x: 0, y: i)); $0.addLine(to: .init(x: size.width, y: i)) },
                                   with: .color(.white.opacity(0.06)))
                }
                context.stroke(
                    Path { path in
                        path.move(to: .init(x: 0, y: size.height * 0.7))
                        path.addCurve(to: .init(x: size.width, y: size.height * 0.35),
                                      control1: .init(x: size.width * 0.35, y: size.height * 0.9),
                                      control2: .init(x: size.width * 0.6, y: size.height * 0.2))
                    },
                    with: .color(.white.opacity(0.22)), lineWidth: 10
                )
            }
            ForEach(0..<pins, id: \.self) { i in
                Image(systemName: "mappin.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.red, .white)
                    .offset(x: CGFloat((i % 3) - 1) * 90, y: CGFloat(i) * 52 - 110)
            }
        }
        .ignoresSafeArea()
    }
}

// MARK: - 1.1.6 중앙 + 오른쪽 보조

private struct PrincipalTrailingDemo: View {
    @State private var mode = PrincipalDemo.Mode.map
    @State private var satellite = false
    @State private var log = DemoLog()

    var body: some View {
        NavigationStack {
            Group {
                switch mode {
                case .map:  DemoMapCanvas().overlay { if satellite { Color.brown.opacity(0.35).ignoresSafeArea() } }
                case .list: DemoMailList(repeats: 1)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Picker("보기", selection: $mode) {
                        ForEach(PrincipalDemo.Mode.allCases) { Text($0.rawValue).tag($0) }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 150)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Menu("더보기", systemImage: "ellipsis") {
                        Toggle("위성 사진", isOn: $satellite)
                        Button("현재 위치", systemImage: "location") { log.tap("현재 위치로 이동") }
                        Divider()
                        Button("이 지역 공유", systemImage: "square.and.arrow.up") { log.tap("공유 시트 열기") }
                    }
                }
            }
        }
        .demoToast(log)
    }
}

// MARK: - 1.1.7 넘치면 접힌다

private struct OverflowDemo: View {
    private struct Action: Identifiable {
        let id: String
        let name: String
        let symbol: String
    }

    private let actions: [Action] = [
        .init(id: "star", name: "별표", symbol: "star"),
        .init(id: "flag", name: "깃발", symbol: "flag"),
        .init(id: "folder", name: "이동", symbol: "folder"),
        .init(id: "share", name: "공유", symbol: "square.and.arrow.up"),
        .init(id: "reply", name: "답장", symbol: "arrowshape.turn.up.left"),
        .init(id: "print", name: "프린트", symbol: "printer"),
        .init(id: "trash", name: "삭제", symbol: "trash"),
    ]

    @State private var count = 2
    @State private var log = DemoLog()

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Stepper("툴바 아이템 \(count)개", value: $count, in: 1...7)
                    DemoNote(text: "숫자를 올리다 보면 어느 지점에서 **…** 가 나타납니다. 그 순간이 시스템이 \"더 넣으면 손가락보다 작아진다\"고 판단한 지점입니다.")
                        .listRowInsets(.init(top: 6, leading: 12, bottom: 6, trailing: 12))
                }
                Section("메시지") {
                    ForEach(DemoData.mail.prefix(6)) { DemoMailRow(mail: $0) }
                }
            }
            .navigationTitle("메일")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    ForEach(actions.prefix(count)) { action in
                        Button(action.name, systemImage: action.symbol) { log.tap("\(action.name) 실행") }
                    }
                }
            }
        }
        .demoToast(log)
    }
}

// MARK: - 1.1.8 버튼이 아닌 뷰

private struct CustomBottomViewsDemo: View {
    @State private var zoom: Double = 3
    @State private var uploaded: Double = 0.35
    @State private var log = DemoLog()

    var body: some View {
        NavigationStack {
            ScrollView {
                DemoPhotoGrid(count: 30, columns: Int(zoom)) { i in log.tap("사진 \(i + 1) 열기") }
                    .animation(.snappy(duration: 0.25), value: zoom)
            }
            .navigationTitle("사진")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    HStack(spacing: 12) {
                        Text("30장")
                            .font(.footnote.weight(.medium))
                            .monospacedDigit()
                            .foregroundStyle(.secondary)

                        Slider(value: $zoom, in: 2...5, step: 1)
                            .frame(width: 130)

                        ProgressView(value: uploaded)
                            .progressViewStyle(.circular)
                            .controlSize(.mini)
                    }
                }
            }
            .task {
                // 상태를 보여주기만 하는 뷰도 툴바의 정당한 시민이라는 걸 보이기 위해 실제로 움직인다.
                while uploaded < 1 {
                    try? await Task.sleep(for: .milliseconds(700))
                    uploaded = min(1, uploaded + 0.08)
                }
            }
        }
        .demoToast(log)
    }
}

// MARK: - 1.1.9 네 자리를 한꺼번에

private struct MixedToolbarDemo: View {
    @State private var mode = PrincipalDemo.Mode.list
    @State private var minimal = false
    @State private var log = DemoLog()

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Toggle("필요한 것만 남기기", isOn: $minimal.animation(.snappy))
                    DemoNote(
                        text: minimal
                            ? "액션 두 개만 남았습니다. 화면이 조용해지고 시선이 콘텐츠로 돌아옵니다 — 8.1.1."
                            : "네 자리를 다 채웠습니다. 다 동작하지만, 이 화면에서 정말 필요한 것이 몇 개인지 세어 보세요.",
                        symbol: minimal ? "checkmark.seal.fill" : "exclamationmark.triangle.fill"
                    )
                    .listRowInsets(.init(top: 6, leading: 12, bottom: 6, trailing: 12))
                }
                Section("문서") {
                    ForEach(DemoData.mail.prefix(8)) { DemoMailRow(mail: $0) }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    if !minimal {
                        Button("정렬", systemImage: "arrow.up.arrow.down") { log.tap("정렬 기준 변경") }
                        Button("필터", systemImage: "line.3.horizontal.decrease") { log.tap("필터 적용") }
                    }
                }
                ToolbarItem(placement: .principal) {
                    if !minimal {
                        Picker("보기", selection: $mode) {
                            ForEach(PrincipalDemo.Mode.allCases) { Text($0.rawValue).tag($0) }
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 130)
                    } else {
                        Text("문서").font(.headline)
                    }
                }
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button("완료") { log.tap("저장했습니다") }
                    if !minimal {
                        Button("별표", systemImage: "star") { log.tap("별표 표시") }
                    }
                }
                ToolbarItemGroup(placement: .bottomBar) {
                    Button("새로 만들기", systemImage: "square.and.pencil") { log.tap("새 문서") }
                    if !minimal {
                        Spacer()
                        Button("삭제", systemImage: "trash", role: .destructive) { log.tap("삭제 — 가장 누르기 쉬운 자리에 두면 위험합니다") }
                    }
                }
            }
        }
        .demoToast(log)
    }
}
