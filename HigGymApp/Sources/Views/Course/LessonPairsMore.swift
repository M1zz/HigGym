import SwiftUI

// 회고가 있는 실수 편들을 레슨으로 세우기 위한 화면 쌍.
// LessonPair 의 케이스에서 골라 쓰므로 파일 밖에서도 보여야 한다(그래서 private 이 아니다).
//
// 한 쌍은 언제나 **문제의 그 한 가지만** 다르다. 데이터도, 배치도, 글도 같아야
// 학습자가 "무엇이 달라졌는지"를 찾을 수 있다.

// MARK: - 실수 1 · 자리가 비어 보인다고 채운다

struct DecorButtonsScreen: View {
    let broken: Bool
    @State private var saved = 0
    @State private var log = DemoLog()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    Text("스프린트 회고")
                        .font(.title2.bold())
                    Text("이번 주에 배운 것 세 가지. 첫째, 하단 바에 삭제를 두면 안 된다는 것. 둘째, 배지는 줄어야 한다는 것. 셋째, 전체 화면을 덮을 때는 나가는 길을 먼저 만들어야 한다는 것.")
                        .font(.body)
                        .lineSpacing(3)
                    Text("저장한 횟수 \(saved)")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(18)
                .contextMenu {
                    // 지운 게 아니라 대상 위로 옮긴 것 — 기능은 그대로다.
                    Button("공유", systemImage: "square.and.arrow.up") { log.tap("공유") }
                    Button("별표", systemImage: "star") { log.tap("별표 표시") }
                }
            }
            .navigationTitle("메모")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button("완료") { saved += 1 }
                        .fontWeight(.semibold)
                    if broken {
                        Button("공유", systemImage: "square.and.arrow.up") { log.tap("공유") }
                        Button("별표", systemImage: "star") { log.tap("별표 표시") }
                        Button("더보기", systemImage: "ellipsis") { log.tap("더보기") }
                    }
                }
            }
        }
        .demoToast(log)
    }
}

// MARK: - 실수 14 · 콕핏 자리에 광고

struct AdBarScreen: View {
    let broken: Bool
    @State private var wrote = 0
    @State private var log = DemoLog()

    var body: some View {
        NavigationStack {
            List {
                ForEach(Array(DemoData.mail.prefix(8).enumerated()), id: \.element.id) { index, mail in
                    if !broken && index == 2 {
                        promo
                    }
                    DemoMailRow(mail: mail)
                }
            }
            .listStyle(.plain)
            .safeAreaInset(edge: .top) {
                Text("새 글쓰기 \(wrote)회")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 5)
            }
            .navigationTitle("피드")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if broken {
                    // 시선이 오래 머무는 자리 = 엄지가 지나가는 자리. 노출과 오탭이 같이 온다.
                    ToolbarItemGroup(placement: .bottomBar) {
                        Button {
                            log.tap("이벤트 페이지로 이동")
                        } label: {
                            Label("이번 주 혜택 보기", systemImage: "gift.fill")
                                .font(.subheadline.weight(.semibold))
                        }
                        Spacer()
                        Button("새 글", systemImage: "square.and.pencil") { wrote += 1 }
                    }
                } else {
                    ToolbarItemGroup(placement: .bottomBar) {
                        Spacer()
                        Button("새 글", systemImage: "square.and.pencil") { wrote += 1 }
                    }
                }
            }
        }
        .demoToast(log)
    }

    private var promo: some View {
        Button {
            log.tap("이벤트 페이지로 이동")
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "gift.fill")
                    .font(.body)
                    .foregroundStyle(.orange)
                VStack(alignment: .leading, spacing: 2) {
                    Text("이번 주 혜택").font(.subheadline.weight(.semibold))
                    Text("스크롤로 지나칠 수 있는 자리").font(.footnote).foregroundStyle(.secondary)
                }
                Spacer()
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 실수 20 · 내비바를 직접 만든다

struct CustomNavBarScreen: View {
    let broken: Bool
    @State private var log = DemoLog()

    private let actions: [(String, String)] = [
        ("저장", "tray.and.arrow.down"), ("이동", "folder"), ("별표", "star"),
        ("깃발", "flag"), ("프린트", "printer"),
    ]

    var body: some View {
        Group {
            if broken {
                VStack(spacing: 0) {
                    // 직접 만든 헤더 — 높이도 글자도 고정이라 큰 글씨에서 무너진다.
                    HStack(spacing: 6) {
                        Text("보고서 초안")
                            .font(.headline)
                            .lineLimit(1)
                        Spacer(minLength: 4)
                        ForEach(actions, id: \.0) { action in
                            Button { log.tap(action.0) } label: {
                                Image(systemName: action.1).font(.callout)
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                    .frame(height: 44)
                    .background(.bar)

                    list
                }
            } else {
                NavigationStack {
                    list
                        .navigationTitle("보고서 초안")
                        // 시스템에 맡기면 제목도 글자 크기를 따라 커지고, 넘치는 아이템은 스스로 접힌다.
                        .navigationBarTitleDisplayMode(.large)
                        .toolbar {
                            ToolbarItemGroup(placement: .topBarTrailing) {
                                ForEach(actions, id: \.0) { action in
                                    Button(action.0, systemImage: action.1) { log.tap(action.0) }
                                }
                            }
                        }
                }
            }
        }
        // 큰 글씨 설정에서만 드러나는 차이라, 화면이 그 조건을 스스로 만든다.
        .dynamicTypeSize(.accessibility3)
        .demoToast(log)
    }

    /// 이 레슨은 "큰 글씨에서 무엇이 무너지는가"가 전부라, 본문도 상대 폰트여야 한다.
    /// 고정 크기(.system(size:))로 그리면 설정을 키워도 아무 일이 없어 비교가 성립하지 않는다.
    private var list: some View {
        List(DemoData.mail.prefix(6)) { mail in
            VStack(alignment: .leading, spacing: 2) {
                Text(mail.sender).font(.headline)
                Text(mail.subject).font(.subheadline).foregroundStyle(.secondary)
            }
            .padding(.vertical, 2)
        }
        .listStyle(.plain)
    }
}

// MARK: - 실수 28 · 안 읽히는데 투명한 쪽이 예뻐서

struct MapControlsScreen: View {
    let broken: Bool
    @State private var log = DemoLog()

    var body: some View {
        ZStack(alignment: .top) {
            ScrollView {
                VStack(spacing: 0) {
                    // 위로 올릴수록 밝아지는 지도 — 눈밭·강 위를 지나는 순간을 만든다.
                    ForEach(0..<8, id: \.self) { band in
                        LinearGradient(
                            colors: [
                                Color(white: 1 - Double(band) * 0.09),
                                Color(white: 0.96 - Double(band) * 0.09),
                            ],
                            startPoint: .top, endPoint: .bottom
                        )
                        .frame(height: 120)
                        .overlay(alignment: .leading) {
                            Text(band == 0 ? "눈 덮인 지역" : "구역 \(band)")
                                .font(.caption)
                                .foregroundStyle(.black.opacity(0.35))
                                .padding(.leading, 12)
                        }
                    }
                }
            }
            .ignoresSafeArea(edges: .bottom)

            controls
        }
    }

    private var controls: some View {
        HStack(spacing: 10) {
            Button("현재 위치", systemImage: "location.fill") { log.tap("현재 위치") }
            Divider().frame(height: 16)
            Button("경로", systemImage: "arrow.triangle.turn.up.right.diamond.fill") { log.tap("경로 안내") }
        }
        .font(.subheadline.weight(.semibold))
        .foregroundStyle(broken ? .white : .primary)
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            broken ? AnyShapeStyle(.ultraThinMaterial) : AnyShapeStyle(.thickMaterial),
            in: .capsule
        )
        .overlay {
            if !broken {
                Capsule().strokeBorder(.primary.opacity(0.15), lineWidth: 1)
            }
        }
        .padding(.top, 10)
        .demoToast(log)
    }
}

// MARK: - 실수 34 · 검색이 접히는 서랍에 있다

struct SearchDrawerScreen: View {
    let broken: Bool
    @State private var query = ""

    private var rows: [DemoMail] {
        guard !query.isEmpty else { return DemoData.mail }
        return DemoData.mail.filter {
            $0.sender.localizedCaseInsensitiveContains(query)
                || $0.subject.localizedCaseInsensitiveContains(query)
        }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(0..<3, id: \.self) { pass in
                    ForEach(rows) { mail in
                        DemoMailRow(mail: mail).id("\(pass)-\(mail.id)")
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("자료")
            .modifier(SearchPlace(broken: broken, query: $query))
        }
    }

    private struct SearchPlace: ViewModifier {
        let broken: Bool
        @Binding var query: String

        func body(content: Content) -> some View {
            if broken {
                // 기본값 — 스크롤하면 접힌다. 다시 쓰려면 맨 위까지 올라가야 한다.
                content.searchable(text: $query, placement: .navigationBarDrawer, prompt: "자료 검색")
            } else {
                content.searchable(text: $query, placement: .toolbar, prompt: "자료 검색")
            }
        }
    }
}

// MARK: - 실수 43 · 잘리면 안 되는 값을 자른다

struct AmountScreen: View {
    let broken: Bool

    private let orders: [(String, String, String)] = [
        ("무선 이어폰 프로 실버", "₩1,284,000", "2건"),
        ("책상 정리 세트", "₩38,900", "1건"),
        ("연간 구독 · 프리미엄 플랜", "₩264,000", "1건"),
    ]

    var body: some View {
        NavigationStack {
            List {
                ForEach(Array(orders.enumerated()), id: \.offset) { _, order in
                    if broken {
                        // 한 줄에 이름과 금액을 함께 — 금액이 tail 로 잘린다.
                        HStack {
                            Text(order.0).font(.body).lineLimit(1)
                            Spacer(minLength: 8)
                            Text(order.1).font(.body).lineLimit(1)
                        }
                    } else {
                        VStack(alignment: .leading, spacing: 3) {
                            Text(order.0).font(.body).lineLimit(2)
                            Text(order.1)
                                .font(.body.weight(.semibold))
                                .lineLimit(1)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("결제 내역")
            .navigationBarTitleDisplayMode(.inline)
        }
        .dynamicTypeSize(.accessibility2)
    }
}

// MARK: - 실수 59 · 여섯 개 탭

struct TabCountScreen: View {
    let broken: Bool
    @State private var log = DemoLog()

    private let six = ["홈", "둘러보기", "보관함", "알림", "내 정보", "설정"]
    private let four = ["홈", "둘러보기", "보관함", "내 정보"]
    private let symbols = ["house", "safari", "square.stack", "bell", "person.crop.circle", "gearshape"]

    var body: some View {
        TabView {
            ForEach(Array((broken ? six : four).enumerated()), id: \.offset) { index, name in
                Tab(name, systemImage: symbols[index]) {
                    NavigationStack {
                        List(DemoData.mail.prefix(6)) { DemoMailRow(mail: $0) }
                            .listStyle(.plain)
                            .navigationTitle(name)
                    }
                }
            }
        }
        .demoToast(log)
    }
}

// MARK: - 실수 62 · 진행 중에 나갈 길을 열어둔다

struct CheckoutTabScreen: View {
    let broken: Bool

    @State private var selection = 0
    @State private var card = ""
    @State private var lost = false
    @State private var confirming = false

    var body: some View {
        Group {
            if broken {
                TabView(selection: $selection) {
                    Tab("결제", systemImage: "creditcard", value: 0) { checkout }
                    Tab("쿠폰", systemImage: "ticket", value: 1) { simple("쿠폰함") }
                    Tab("내 정보", systemImage: "person.crop.circle", value: 2) { simple("내 정보") }
                }
                .onChange(of: selection) { _, new in
                    // 실제 앱에서는 결제 화면이 해제되면서 입력이 이렇게 사라진다.
                    guard new != 0, !card.isEmpty else { return }
                    card = ""
                    lost = true
                }
            } else {
                checkout
            }
        }
        .alert("입력한 정보가 사라집니다", isPresented: $confirming) {
            Button("결제 계속하기", role: .cancel) {}
            Button("나가기", role: .destructive) { card = "" }
        } message: {
            Text("카드 정보를 다시 입력해야 합니다.")
        }
    }

    private var checkout: some View {
        NavigationStack {
            Form {
                Section("3 / 3 · 카드 정보") {
                    TextField("카드 번호", text: $card)
                        .font(.body.monospacedDigit())
                    LabeledContent("결제 금액", value: "₩128,400")
                }
                if lost {
                    Section {
                        Label("입력하던 카드 번호가 사라졌습니다", systemImage: "exclamationmark.triangle.fill")
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }
                }
                Section {
                    Button("결제하기") {}
                        .disabled(card.isEmpty)
                }
            }
            .navigationTitle("결제")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if !broken {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("취소") { confirming = true }
                    }
                }
            }
        }
    }

    private func simple(_ title: String) -> some View {
        NavigationStack {
            List(DemoData.mail.prefix(5)) { DemoMailRow(mail: $0) }
                .listStyle(.plain)
                .navigationTitle(title)
        }
    }
}

// MARK: - 실수 79 · 확정하는 시트를 비모달로

struct PaymentSheetScreen: View {
    let broken: Bool

    @State private var quantity = 2
    @State private var showing = false
    /// 시트를 연 순간의 금액 — 뒤에서 수량이 바뀌면 이 값과 실제가 갈라진다.
    @State private var quoted = 0
    @State private var result: String?

    private let unit = 64_200

    var body: some View {
        NavigationStack {
            Form {
                Section("장바구니") {
                    Stepper("무선 이어폰 · \(quantity)개", value: $quantity, in: 1...9)
                    LabeledContent("합계", value: "₩\((unit * quantity).formatted())")
                }
                Section {
                    Button("결제 시트 열기") {
                        quoted = unit * quantity
                        showing = true
                    }
                }
                if let result {
                    Section {
                        Text(result)
                            .font(.footnote)
                            .foregroundStyle(result.contains("불일치") ? .red : .green)
                    }
                }
            }
            .navigationTitle("장바구니")
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $showing) {
            sheet
                .presentationDetents([.medium])
                .modifier(NonmodalModifier(enabled: broken))
        }
    }

    private var sheet: some View {
        NavigationStack {
            Form {
                Section("결제 확인") {
                    LabeledContent("표시된 금액", value: "₩\(quoted.formatted())")
                    if !broken {
                        // 확정하는 시트는 참조할 내용을 안으로 가져온다 — 뒤를 만질 이유를 없앤다.
                        LabeledContent("수량", value: "\(quantity)개")
                    }
                }
                Section {
                    Button("결제하기") {
                        let actual = unit * quantity
                        result = actual == quoted
                            ? "결제 완료 · ₩\(actual.formatted())"
                            : "금액 불일치 — 표시 ₩\(quoted.formatted()) / 청구 ₩\(actual.formatted())"
                        showing = false
                    }
                }
            }
            .navigationTitle("결제")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private struct NonmodalModifier: ViewModifier {
        let enabled: Bool
        func body(content: Content) -> some View {
            if enabled {
                content.presentationBackgroundInteraction(.enabled(upThrough: .medium))
            } else {
                content
            }
        }
    }
}

// MARK: - 실수 96 · 삭제를 일반 항목들 사이에

struct MenuOrderScreen: View {
    let broken: Bool

    @State private var files = ["분기 보고서", "디자인 시안 v3", "회의록 0821", "예산안"]
    @State private var log = DemoLog()

    var body: some View {
        NavigationStack {
            List {
                ForEach(Array(files.enumerated()), id: \.offset) { index, name in
                    HStack {
                        Label(name, systemImage: "doc.text")
                        Spacer()
                        Menu("더보기", systemImage: "ellipsis") {
                            if broken {
                                // 작업 흐름 순서대로 — 삭제가 한가운데 섞인다.
                                Button("이름 변경", systemImage: "pencil") { log.tap("이름 변경") }
                                Button("복제", systemImage: "doc.on.doc") { log.tap("복제") }
                                Button("삭제", systemImage: "trash") { remove(index) }
                                Button("이동", systemImage: "folder") { log.tap("이동") }
                                Button("공유", systemImage: "square.and.arrow.up") { log.tap("공유") }
                            } else {
                                Button("이름 변경", systemImage: "pencil") { log.tap("이름 변경") }
                                Button("복제", systemImage: "doc.on.doc") { log.tap("복제") }
                                Button("이동", systemImage: "folder") { log.tap("이동") }
                                Button("공유", systemImage: "square.and.arrow.up") { log.tap("공유") }
                                Divider()
                                Button("삭제", systemImage: "trash", role: .destructive) { remove(index) }
                            }
                        }
                        .labelStyle(.iconOnly)
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("파일")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    Spacer()
                    Button("되돌리기", systemImage: "arrow.uturn.backward") {
                        files = ["분기 보고서", "디자인 시안 v3", "회의록 0821", "예산안"]
                    }
                }
            }
        }
        .demoToast(log)
    }

    private func remove(_ index: Int) {
        guard files.indices.contains(index) else { return }
        let name = files.remove(at: index)
        log.tap("\(name) 삭제됨")
    }
}
