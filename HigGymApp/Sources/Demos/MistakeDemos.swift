import SwiftUI

/// 실수 전용 예제 — 어긴 화면과 고친 화면을 **나란히** 세운다.
///
/// 항목 예제(EntryDemos)가 "이 컴포넌트는 이렇게 동작한다"를 보여준다면,
/// 여기는 "같은 화면인데 이 하나가 달라지면 이만큼 달라진다"를 보여준다.
/// 그래서 두 화면은 콘텐츠·데이터를 똑같이 쓰고 **문제의 그 한 가지만** 다르다.
@MainActor
enum MistakeDemos {
    static let byID: [String: EntryDemo] = {
        var map: [String: EntryDemo] = [:]
        for demo in all { map[demo.id] = demo }
        return map
    }()

    static func demo(for mistake: Mistake) -> EntryDemo? { byID[mistake.id] }

    static let all: [EntryDemo] = [
        EntryDemo(
            "m003",
            hints: [
                "왼쪽 캡슐에서 **삭제**를 눌러보세요. 정렬·격자와 한 덩어리라 손이 먼저 갑니다.",
                "오른쪽은 도구가 왼쪽 묶음, 삭제는 오른쪽 메뉴 안쪽에 있습니다. 같은 실수를 하기가 어렵습니다.",
                "기능은 양쪽이 똑같습니다. 달라진 건 **묶는 방법**뿐입니다.",
            ],
            code: """
            // 이렇게 했다 — 성격이 다른 셋이 한 캡슐
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button("삭제", systemImage: "trash") { … }
                Button("정렬", systemImage: "arrow.up.arrow.down") { … }
                Button("격자", systemImage: "square.grid.2x2") { … }
            }

            // 이렇게 고쳤다 — 도구는 왼쪽, 파괴적 액션은 메뉴 안
            ToolbarItemGroup(placement: .topBarLeading) { 격자; 정렬 }
            ToolbarItem(placement: .topBarTrailing) {
                Menu("더보기", systemImage: "ellipsis") {
                    Button("삭제", systemImage: "trash", role: .destructive) { … }
                }
            }
            """,
            chromeEdge: .bottom
        ) { M003 () },

        EntryDemo(
            "m007",
            hints: [
                "왼쪽 하단의 **삭제**를 눌러보세요 — 확인도 없이 사라집니다. 엄지 자리라 오탭도 쉽습니다.",
                "오른쪽 하단은 **작성**입니다. 삭제는 행을 왼쪽으로 밀어야 나옵니다.",
                "지운 개수를 두 화면에서 세어보세요. 자리 하나가 사고율을 바꿉니다.",
            ],
            code: """
            // 이렇게 했다 — 되돌릴 수 없는 액션이 가장 누르기 쉬운 자리에
            ToolbarItem(placement: .bottomBar) {
                Button("삭제", systemImage: "trash", role: .destructive) { delete() }
            }

            // 이렇게 고쳤다 — 하단은 고빈도 액션, 삭제는 대상 위에서 한 단계 거쳐
            ToolbarItem(placement: .bottomBar) {
                Button("새 메일", systemImage: "square.and.pencil") { compose() }
            }
            .swipeActions { Button("삭제", role: .destructive) { … } }
            """,
            chromeEdge: .bottom
        ) { M007() },

        EntryDemo(
            "m011",
            hints: [
                "왼쪽에서 **저장**을 찾아보세요 — ⋯ 안에 접혀 있습니다. 가장 자주 누르는 버튼인데요.",
                "오른쪽은 저장이 밖에, 별표·프린트가 접혔습니다. 선언 순서만 바꾼 결과입니다.",
                "두 화면 모두 아이템 개수는 같습니다. 무엇을 앞에 뒀는지만 다릅니다.",
            ],
            code: """
            // 선언 순서 = 우선순위. 폭이 모자라면 뒤쪽부터 ⋯ 로 접힌다.
            // 이렇게 했다
            ForEach([별표, 깃발, 프린트, 이동, 저장]) { … }
            // 이렇게 고쳤다
            ForEach([저장, 이동, 별표, 깃발, 프린트]) { … }
            """,
            chromeEdge: .bottom
        ) { M011() },

        EntryDemo(
            "m029",
            hints: [
                "두 화면을 **같이 스크롤**해 보세요. 흰 사진이 상단 바를 지날 때를 노려 보세요.",
                "왼쪽은 그 순간 버튼 글자가 사진에 묻힙니다. 오른쪽은 경계가 대비를 만들어 냅니다.",
                "어두운 사진에서는 둘이 똑같아 보입니다 — 그래서 어두운 샘플로만 확인하면 놓칩니다.",
            ],
            code: """
            // 이렇게 했다
            ScrollView { PhotoGrid() }
                .scrollEdgeEffectHidden(true, for: .top)

            // 이렇게 고쳤다
            ScrollView { PhotoGrid() }
                .scrollEdgeEffectStyle(.hard, for: .top)
            """,
            chromeEdge: .bottom
        ) { M029() },

        EntryDemo(
            "m038",
            hints: [
                "아래 슬라이더로 **글자 크기를 접근성 단계까지** 올려보세요.",
                "왼쪽은 한 줄 고정 + 축소라 커질수록 작아지다가 결국 첫 어절만 남습니다.",
                "오른쪽은 줄이 늘어나며 값을 지킵니다. 카드가 길어질 뿐 정보는 살아 있습니다.",
            ],
            code: """
            // 이렇게 했다 — 두 장치를 겹쳐 걸었다
            Text(address).lineLimit(1).minimumScaleFactor(0.4)

            // 이렇게 고쳤다 — 줄 수로 다루고, 넘치면 볼 경로를 준다
            Text(address).lineLimit(2...3)
            """,
            chromeEdge: .bottom
        ) { M038() },

        EntryDemo(
            "m046",
            hints: [
                "왼쪽 운송장 번호를 **길게 눌러** 보세요 — 아무 일도 없습니다.",
                "오른쪽은 선택·복사가 되고, 복사 버튼도 있습니다. 실제로 복사됩니다.",
                "사용자가 화면을 보며 손으로 옮겨 적고 있다면 그건 기능이 빠진 것입니다.",
            ],
            code: """
            // 이렇게 했다
            Text(trackingNumber)

            // 이렇게 고쳤다
            Text(trackingNumber)
                .textSelection(.enabled)
            Button("복사", systemImage: "doc.on.doc") {
                UIPasteboard.general.string = trackingNumber
            }
            """,
            chromeEdge: .bottom
        ) { M046() },

        EntryDemo(
            "m047",
            hints: [
                "아래에서 로케일을 **en_US**로 바꿔보세요.",
                "왼쪽은 미국 사용자에게도 5km라고 말합니다. 문자열로 굳혔기 때문입니다.",
                "오른쪽은 값만 들고 있다가 3.1mi로 바뀝니다. 앱 코드는 한 줄도 다르지 않습니다.",
            ],
            code: """
            // 이렇게 했다
            Text("\\(distanceKm) km")

            // 이렇게 고쳤다
            let distance = Measurement(value: distanceKm, unit: UnitLength.kilometers)
            Text(distance.formatted(.measurement(width: .abbreviated, usage: .road)))
            """,
            chromeEdge: .bottom
        ) { M047() },

        EntryDemo(
            "m052",
            hints: [
                "왼쪽 배지의 **1**은 무엇을 해도 사라지지 않습니다. 목록을 다 읽어도 그대로입니다.",
                "오른쪽은 읽을 때마다 숫자가 줄고, 0이 되면 배지가 사라집니다.",
                "왼쪽을 며칠 쓰면 배지를 아예 안 보게 됩니다 — 잃는 건 그 앱의 모든 배지입니다.",
            ],
            code: """
            // 이렇게 했다 — 상시 부착
            Tab("소식", systemImage: "bell") { … }.badge(1)

            // 이렇게 고쳤다 — 남은 것의 수. 0이면 시스템이 알아서 감춘다
            Tab("소식", systemImage: "bell") { … }.badge(unread.count)
            """,
            chromeEdge: .bottom
        ) { M052() },

        EntryDemo(
            "m068",
            hints: [
                "왼쪽 **작성** 탭을 눌러보세요 — 시트만 뜨고, 닫으면 원래 탭으로 돌아옵니다.",
                "탭이 가리키는 목적지가 없습니다. \"어디로 가는가\"에 답을 못 합니다.",
                "오른쪽은 작성이 하단 툴바 버튼입니다. 탭은 목적지만 남았습니다.",
            ],
            code: """
            // 이렇게 했다 — 이동하지 않는 탭
            Tab("작성", systemImage: "square.and.pencil", value: 2) { EmptyView() }
            .onChange(of: selection) { if $1 == 2 { composing = true; selection = old } }

            // 이렇게 고쳤다 — 액션은 툴바로
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    Button("작성", systemImage: "square.and.pencil") { composing = true }
                }
            }
            """,
            chromeEdge: .bottom
        ) { M068() },

        EntryDemo(
            "m081",
            hints: [
                "왼쪽에서 편집기를 연 뒤 **닫아보세요**. 쓸어내려도, 어디를 눌러도 나갈 수 없습니다.",
                "오른쪽에는 취소·완료가 있습니다. 같은 전체 화면인데 출구가 있습니다.",
                "왼쪽의 빨간 점선 버튼은 예제에서 빠져나오기 위한 장치입니다 — 실제 앱에는 없습니다.",
            ],
            code: """
            // fullScreenCover 는 쓸어내려 닫히지 않는다. 출구는 직접 만들어야 한다.
            .fullScreenCover(isPresented: $editing) {
                EditorView()
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) { Button("취소") { editing = false } }
                        ToolbarItem(placement: .topBarTrailing) { Button("완료") { save() } }
                    }
            }
            """,
            note: "왼쪽 화면의 **빨간 점선 '예제에서 나가기'** 는 이 교재가 넣은 비상구입니다. 실제로 이 실수를 저지른 앱에는 그 버튼이 없습니다.",
            chromeEdge: .bottom
        ) { M081() },
    ]
}

// MARK: - 공용 조각

/// 두 화면이 같은 데이터를 쓰게 하는 표본. 달라지는 건 오직 실수 하나여야 한다.
private let sample = Array(DemoData.mail.prefix(9))

/// 미니 화면 안에서도 무엇이 일어났는지 보이게 하는 작은 상태 줄.
private struct MiniStatus: View {
    let text: String
    var tint: Color = .secondary

    var body: some View {
        Text(text)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(tint)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.vertical, 6)
    }
}

// MARK: - m003 성격이 다른 액션을 한 캡슐에

private struct M003: View {
    @State private var badLog = DemoLog()
    @State private var goodLog = DemoLog()
    @State private var badRows = sample
    @State private var goodRows = sample
    @State private var badGrid = false
    @State private var goodGrid = false

    var body: some View {
        MistakeComparisonScreen(
            title: "삭제·정렬·격자가 한 캡슐에 있으면 한 세트로 읽힌다",
            badNote: "세 개가 붙어 있어 **삭제가 도구처럼** 보입니다.",
            goodNote: "도구는 왼쪽 묶음, 삭제는 메뉴 안 맨 아래.",
            takeaway: "묶음은 곧 \"한 세트\"라는 선언입니다. 기능은 그대로 두고 **묶는 방법만** 바꿔도 오해가 사라집니다."
        ) {
            NavigationStack {
                list(rows: badRows, grid: badGrid)
                    .navigationTitle("문서")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItemGroup(placement: .topBarTrailing) {
                            Button("삭제", systemImage: "trash") {
                                if !badRows.isEmpty { badRows.removeFirst() }
                                badLog.tap("삭제됨")
                            }
                            Button("정렬", systemImage: "arrow.up.arrow.down") {
                                badRows.sort { $0.sender < $1.sender }
                            }
                            Button("격자", systemImage: "square.grid.2x2") {
                                withAnimation { badGrid.toggle() }
                            }
                        }
                    }
            }
            .demoToast(badLog)
        } good: {
            NavigationStack {
                list(rows: goodRows, grid: goodGrid)
                    .navigationTitle("문서")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItemGroup(placement: .topBarLeading) {
                            Button("격자", systemImage: "square.grid.2x2") {
                                withAnimation { goodGrid.toggle() }
                            }
                            Button("정렬", systemImage: "arrow.up.arrow.down") {
                                goodRows.sort { $0.sender < $1.sender }
                            }
                        }
                        ToolbarItem(placement: .topBarTrailing) {
                            Menu("더보기", systemImage: "ellipsis") {
                                Button("이름 변경", systemImage: "pencil") { goodLog.tap("이름 변경") }
                                Divider()
                                Button("삭제", systemImage: "trash", role: .destructive) {
                                    if !goodRows.isEmpty { goodRows.removeFirst() }
                                    goodLog.tap("삭제됨")
                                }
                            }
                        }
                    }
            }
            .demoToast(goodLog)
        }
    }

    @ViewBuilder
    private func list(rows: [DemoMail], grid: Bool) -> some View {
        if grid {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 10)], spacing: 10) {
                    ForEach(rows) { mail in
                        VStack(alignment: .leading, spacing: 3) {
                            Text(mail.sender).font(.subheadline.weight(.semibold))
                            Text(mail.subject).font(.footnote).foregroundStyle(.secondary).lineLimit(2)
                        }
                        .frame(maxWidth: .infinity, minHeight: 60, alignment: .topLeading)
                        .padding(10)
                        .background(.quaternary.opacity(0.4), in: .rect(cornerRadius: 10))
                    }
                }
                .padding(12)
            }
        } else {
            List(rows) { DemoMailRow(mail: $0) }.listStyle(.plain)
        }
    }
}

// MARK: - m007 파괴적 액션을 하단 단독으로

private struct M007: View {
    @State private var badRows = sample
    @State private var goodRows = sample
    @State private var badDeleted = 0
    @State private var goodDeleted = 0
    @State private var composing = false

    var body: some View {
        MistakeComparisonScreen(
            title: "삭제가 엄지 자리에 혼자 있으면, 누를 생각이 없어도 눌린다",
            badNote: "확인 없이 즉시 삭제 — 지운 수 **\(badDeleted)**",
            goodNote: "하단은 작성. 삭제는 행을 밀어야 — 지운 수 **\(goodDeleted)**",
            takeaway: "도달성 기준은 **무해한 고빈도 액션**에만 적용합니다. 되돌릴 수 없는 것은 일부러 한 단계 멀리 둡니다."
        ) {
            NavigationStack {
                List(badRows) { DemoMailRow(mail: $0) }
                    .listStyle(.plain)
                    .safeAreaInset(edge: .top) { MiniStatus(text: "삭제한 항목 \(badDeleted)개", tint: .red) }
                    .navigationTitle("받은 편지함")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .bottomBar) {
                            Button("삭제", systemImage: "trash", role: .destructive) {
                                guard !badRows.isEmpty else { return }
                                withAnimation { badRows.removeFirst() }
                                badDeleted += 1
                            }
                        }
                    }
            }
        } good: {
            NavigationStack {
                List {
                    ForEach(goodRows) { mail in
                        DemoMailRow(mail: mail)
                            .swipeActions(edge: .trailing) {
                                Button("삭제", systemImage: "trash", role: .destructive) {
                                    withAnimation { goodRows.removeAll { $0.id == mail.id } }
                                    goodDeleted += 1
                                }
                            }
                    }
                }
                .listStyle(.plain)
                .safeAreaInset(edge: .top) { MiniStatus(text: "삭제한 항목 \(goodDeleted)개", tint: .green) }
                .navigationTitle("받은 편지함")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItemGroup(placement: .bottomBar) {
                        Spacer()
                        Button("새 메일", systemImage: "square.and.pencil") { composing = true }
                    }
                }
                .sheet(isPresented: $composing) { DemoComposeSheet() }
            }
        }
    }
}

// MARK: - m011 선언 순서가 곧 우선순위

private struct M011: View {
    private struct Act: Identifiable {
        let id: String
        let name: String
        let symbol: String
    }

    private let badOrder: [Act] = [
        .init(id: "star", name: "별표", symbol: "star"),
        .init(id: "flag", name: "깃발", symbol: "flag"),
        .init(id: "print", name: "프린트", symbol: "printer"),
        .init(id: "move", name: "이동", symbol: "folder"),
        .init(id: "save", name: "저장", symbol: "tray.and.arrow.down"),
    ]
    private let goodOrder: [Act] = [
        .init(id: "save", name: "저장", symbol: "tray.and.arrow.down"),
        .init(id: "move", name: "이동", symbol: "folder"),
        .init(id: "star", name: "별표", symbol: "star"),
        .init(id: "flag", name: "깃발", symbol: "flag"),
        .init(id: "print", name: "프린트", symbol: "printer"),
    ]

    @State private var badSaves = 0
    @State private var goodSaves = 0

    var body: some View {
        MistakeComparisonScreen(
            title: "폭이 모자라면 뒤쪽부터 접힌다 — 무엇을 앞에 뒀는가의 문제",
            badNote: "저장이 **⋯ 안**에. 저장 횟수 \(badSaves)",
            goodNote: "저장이 밖에, 별표·프린트가 접힘. 저장 \(goodSaves)",
            takeaway: "접기는 시스템이 최소 터치 크기를 지키는 방식입니다. 막을 게 아니라 **순서를 설계**하면 됩니다."
        ) {
            screen(order: badOrder) { badSaves += 1 }
        } good: {
            screen(order: goodOrder) { goodSaves += 1 }
        }
    }

    private func screen(order: [Act], onSave: @escaping () -> Void) -> some View {
        NavigationStack {
            List(sample) { DemoMailRow(mail: $0) }
                .listStyle(.plain)
                .navigationTitle("문서")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItemGroup(placement: .topBarTrailing) {
                        ForEach(order) { act in
                            Button(act.name, systemImage: act.symbol) {
                                if act.id == "save" { onSave() }
                            }
                        }
                    }
                }
        }
    }
}

// MARK: - m029 사진 피드에서 가장자리 효과를 끄면

private struct M029: View {
    var body: some View {
        MistakeComparisonScreen(
            title: "밝은 사진이 바 뒤를 지나는 순간에 판정이 갈린다",
            badNote: "`scrollEdgeEffectHidden(true)` — 흰 사진에서 버튼이 사라집니다.",
            goodNote: "`.hard` — 경계가 스스로 대비를 만듭니다.",
            takeaway: "가장자리 효과는 장식이 아니라 **가독성 장치**입니다. 판정은 언제나 최악의 배경에서 합니다."
        ) {
            screen(hidden: true)
        } good: {
            screen(hidden: false)
        }
    }

    private func screen(hidden: Bool) -> some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 3), count: 3), spacing: 3) {
                    ForEach(0..<30, id: \.self) { i in
                        // 위쪽을 일부러 흰 사진으로 — 스크롤하면 바 뒤로 지나간다.
                        Group {
                            if i % 4 == 0 {
                                LinearGradient(colors: [.white, Color(white: 0.93)], startPoint: .top, endPoint: .bottom)
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
            .modifier(EdgeModifier(hidden: hidden))
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

// MARK: - m038 한 줄 고정 + 축소

private struct M038: View {
    @State private var typeSize = DynamicTypeSize.large

    private let rows: [(String, String)] = [
        ("배송지", "서울특별시 성동구 아차산로 111 무학빌딩 7층 703호"),
        ("결제 금액", "₩1,284,000"),
        ("주문번호", "2026-0818-A7K9-4421"),
    ]

    var body: some View {
        MistakeComparisonScreen(
            title: "글자가 커지면 한 줄 고정은 값을 지우기 시작한다",
            badNote: "`lineLimit(1)` + `minimumScaleFactor(0.4)`",
            goodNote: "`lineLimit(2...3)` — 카드가 길어질 뿐 값은 남습니다.",
            takeaway: "두 장치를 겹치면 서로를 가립니다. **잘려도 뜻이 통하는가**로 도구를 고릅니다.",
            controls: {
                ComparisonControls {
                    Text("Dynamic Type · \(typeSize.demoLabel)")
                        .font(.system(.caption, design: .monospaced, weight: .semibold))
                        .foregroundStyle(.hgDim)
                    Slider(
                        value: Binding(
                            get: { Double(DynamicTypeSize.demoSteps.firstIndex(of: typeSize) ?? 3) },
                            set: { typeSize = DynamicTypeSize.demoSteps[Int($0.rounded())] }
                        ),
                        in: 0...Double(DynamicTypeSize.demoSteps.count - 1),
                        step: 1
                    )
                    .tint(.hgAccent)
                }
            },
            bad: { screen(clamped: true) },
            good: { screen(clamped: false) }
        )
    }

    private func screen(clamped: Bool) -> some View {
        NavigationStack {
            List {
                ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(row.0)
                            // 고정 크기 폰트는 Dynamic Type 을 따르지 않는다 — 상대 폰트여야 슬라이더가 일한다.
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.secondary)
                        if clamped {
                            Text(row.1).font(.body).lineLimit(1).minimumScaleFactor(0.4)
                        } else {
                            Text(row.1).font(.body).lineLimit(2...3)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .listStyle(.plain)
            .navigationTitle("주문 확인")
            .navigationBarTitleDisplayMode(.inline)
        }
        .dynamicTypeSize(typeSize)
    }
}

// MARK: - m046 옮겨 적어야 하는 값

private struct M046: View {
    @State private var copied = false

    private let number = "1Z 999 AA1 0123 4567"

    var body: some View {
        MistakeComparisonScreen(
            title: "옮겨 적을 값인데 선택이 막혀 있으면, 사용자가 눈으로 받아 적는다",
            badNote: "길게 눌러도 아무 일도 없습니다.",
            goodNote: "선택·복사가 됩니다. 복사 버튼도 있습니다.",
            takeaway: "읽기 전용 텍스트라고 조작이 필요 없는 건 아닙니다. **옮겨 적을 일이 있는 값**에는 선택을 엽니다."
        ) {
            screen(selectable: false)
        } good: {
            screen(selectable: true)
        }
    }

    private func screen(selectable: Bool) -> some View {
        NavigationStack {
            List {
                Section("운송장") {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(number)
                            .font(.system(.headline, design: .monospaced))
                            .modifier(SelectionMod(enabled: selectable))
                        if selectable {
                            Button {
                                UIPasteboard.general.string = number
                                withAnimation { copied = true }
                            } label: {
                                Label(copied ? "복사됨" : "복사", systemImage: copied ? "checkmark" : "doc.on.doc")
                                    .font(.subheadline.weight(.semibold))
                            }
                            .buttonStyle(.borderless)
                        } else {
                            Text("길게 눌러보세요")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
                Section("배송 상태") {
                    Label("허브 도착", systemImage: "shippingbox")
                    Label("배송 출발", systemImage: "truck.box")
                }
            }
            .navigationTitle("배송 조회")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private struct SelectionMod: ViewModifier {
        let enabled: Bool
        func body(content: Content) -> some View {
            if enabled { content.textSelection(.enabled) } else { content.textSelection(.disabled) }
        }
    }
}

// MARK: - m047 표기를 문자열로 굳히면

private struct M047: View {
    @State private var english = false

    private var locale: Locale { Locale(identifier: english ? "en_US" : "ko_KR") }
    private let km: Double = 5

    var body: some View {
        MistakeComparisonScreen(
            title: "값과 표기를 한 문자열에 담으면 문화권 규칙을 앱이 소유하게 된다",
            badNote: "`\"\\(km) km\"` — 로케일을 바꿔도 그대로입니다.",
            goodNote: "`Measurement` — mi로 따라옵니다.",
            takeaway: "앱은 **값**만 들고, 표기는 시스템에 맡깁니다. 그래야 앱 코드를 고치지 않고도 세계가 늘어납니다.",
            controls: {
                ComparisonControls {
                    Picker("로케일", selection: $english) {
                        Text("ko_KR").tag(false)
                        Text("en_US").tag(true)
                    }
                    .pickerStyle(.segmented)
                }
            },
            bad: { screen(hardcoded: true) },
            good: { screen(hardcoded: false) }
        )
    }

    private func screen(hardcoded: Bool) -> some View {
        let distance = Measurement(value: km, unit: UnitLength.kilometers)
        let text = hardcoded
            ? "\(Int(km)) km"
            : distance.formatted(.measurement(width: .abbreviated, usage: .road).locale(locale))

        return NavigationStack {
            List {
                Section("가까운 매장") {
                    ForEach(["성수점", "합정점", "한남점"], id: \.self) { (name: String) in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(name).font(.callout.weight(.semibold))
                                Text("영업 중").font(.footnote).foregroundStyle(.secondary)
                            }
                            Spacer()
                            Text(text)
                                .font(.system(.callout, design: .rounded, weight: .semibold))
                                .foregroundStyle(hardcoded ? AnyShapeStyle(.primary) : AnyShapeStyle(.tint))
                        }
                        .padding(.vertical, 3)
                    }
                }
            }
            .navigationTitle("매장 찾기")
            .navigationBarTitleDisplayMode(.inline)
            .environment(\.locale, locale)
        }
    }
}

// MARK: - m052 줄지 않는 배지

private struct M052: View {
    @State private var badRead = 0
    @State private var goodUnread = 3

    var body: some View {
        MistakeComparisonScreen(
            title: "처리해도 줄지 않는 배지는, 그 앱의 모든 배지를 무효로 만든다",
            badNote: "다 읽어도 **1** 그대로 (읽은 수 \(badRead))",
            goodNote: "읽을 때마다 줄고 0이면 사라집니다 (남은 수 \(goodUnread))",
            takeaway: "배지는 \"처리할 것이 남았다\"는 약속입니다. 한 번 거짓말하면 다시는 안 봅니다."
        ) {
            TabView {
                Tab("홈", systemImage: "house") { feed }
                Tab("소식", systemImage: "bell") {
                    inbox(count: 3) { badRead += 1 }
                }
                .badge(1)
                Tab("설정", systemImage: "gearshape") { settings }
            }
        } good: {
            TabView {
                Tab("홈", systemImage: "house") { feed }
                Tab("소식", systemImage: "bell") {
                    inbox(count: goodUnread) { goodUnread = max(0, goodUnread - 1) }
                }
                .badge(goodUnread)
                Tab("설정", systemImage: "gearshape") { settings }
            }
        }
    }

    private var feed: some View {
        NavigationStack {
            List(sample) { DemoMailRow(mail: $0) }
                .listStyle(.plain)
                .navigationTitle("홈")
        }
    }

    private func inbox(count: Int, onRead: @escaping () -> Void) -> some View {
        NavigationStack {
            List {
                if count == 0 {
                    ContentUnavailableView("새 소식 없음", systemImage: "checkmark.circle")
                } else {
                    ForEach(0..<count, id: \.self) { i in
                        Button { onRead() } label: {
                            Label("새 소식 \(i + 1) — 읽음으로 표시", systemImage: "envelope.badge")
                        }
                    }
                }
            }
            .navigationTitle("소식")
        }
    }

    private var settings: some View {
        NavigationStack {
            Form { Toggle("푸시 알림", isOn: .constant(true)) }
                .navigationTitle("설정")
        }
    }
}

// MARK: - m068 이동하지 않는 탭

private struct M068: View {
    @State private var badSelection = 0
    @State private var badComposing = false
    @State private var goodSelection = 0
    @State private var goodComposing = false

    var body: some View {
        MistakeComparisonScreen(
            title: "탭을 눌렀는데 이동하지 않으면, 탭이라는 약속이 깨진다",
            badNote: "작성 탭 → 시트만 뜨고 선택은 되돌아옵니다.",
            goodNote: "작성은 하단 툴바 버튼. 탭은 목적지만.",
            takeaway: "탭은 **어디로 가는가**에 답하는 자리입니다. 액션은 툴바가 맡습니다."
        ) {
            TabView(selection: $badSelection) {
                Tab("홈", systemImage: "house", value: 0) { page("홈") }
                Tab("작성", systemImage: "square.and.pencil", value: 1) {
                    // 목적지가 없다 — 선택되자마자 되돌아간다.
                    Color.clear
                }
                Tab("설정", systemImage: "gearshape", value: 2) { page("설정") }
            }
            .onChange(of: badSelection) { _, new in
                guard new == 1 else { return }
                badComposing = true
                badSelection = 0
            }
            .sheet(isPresented: $badComposing) { DemoComposeSheet() }
        } good: {
            TabView(selection: $goodSelection) {
                Tab("홈", systemImage: "house", value: 0) {
                    page("홈", compose: { goodComposing = true })
                }
                Tab("설정", systemImage: "gearshape", value: 2) { page("설정") }
            }
            .sheet(isPresented: $goodComposing) { DemoComposeSheet() }
        }
    }

    private func page(_ title: String, compose: (() -> Void)? = nil) -> some View {
        NavigationStack {
            List(sample) { DemoMailRow(mail: $0) }
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

// MARK: - m081 출구 없는 전체 화면

private struct M081: View {
    @State private var badEditing = false
    @State private var goodEditing = false
    @State private var text = "작성 중인 내용"

    var body: some View {
        MistakeComparisonScreen(
            title: "전체 화면 커버는 쓸어내려 닫히지 않는다 — 출구는 직접 만들어야 한다",
            badNote: "닫기 버튼이 없습니다. 쓸어내려도 그대로입니다.",
            goodNote: "취소·완료가 있습니다.",
            takeaway: "덮는 화면일수록 **나가는 길**을 먼저 설계합니다. 시트의 습관이 여기서는 통하지 않습니다."
        ) {
            NavigationStack {
                editorEntry { badEditing = true }
            }
            .fullScreenCover(isPresented: $badEditing) {
                NavigationStack {
                    editorBody
                        .navigationTitle("편집기")
                        .navigationBarTitleDisplayMode(.inline)
                        .safeAreaInset(edge: .bottom) {
                            // 실제 앱에는 없는 비상구 — 교재가 사용자를 가두지 않기 위한 장치.
                            Button("예제에서 나가기") { badEditing = false }
                                .font(.footnote.weight(.semibold))
                                .foregroundStyle(.red)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 14)
                                .overlay(
                                    Capsule().strokeBorder(.red, style: .init(lineWidth: 1, dash: [4, 3]))
                                )
                                .padding(.bottom, 10)
                        }
                }
            }
        } good: {
            NavigationStack {
                editorEntry { goodEditing = true }
            }
            .fullScreenCover(isPresented: $goodEditing) {
                NavigationStack {
                    editorBody
                        .navigationTitle("편집기")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .topBarLeading) {
                                Button("취소") { goodEditing = false }
                            }
                            ToolbarItem(placement: .topBarTrailing) {
                                Button("완료") { goodEditing = false }.fontWeight(.semibold)
                            }
                        }
                }
            }
        }
    }

    private func editorEntry(_ open: @escaping () -> Void) -> some View {
        List {
            Section {
                Button("전체 화면으로 편집하기", systemImage: "square.and.pencil", action: open)
            }
            Section("문서") {
                ForEach(sample.prefix(6)) { DemoMailRow(mail: $0) }
            }
        }
        .listStyle(.plain)
        .navigationTitle("메모")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var editorBody: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("아래로 쓸어내려 보세요 — 닫히지 않습니다.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            TextEditor(text: $text)
                .font(.callout)
                .scrollContentBackground(.hidden)
                .background(.quaternary.opacity(0.4), in: .rect(cornerRadius: 12))
        }
        .padding(16)
    }
}
