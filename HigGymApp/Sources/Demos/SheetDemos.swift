import SwiftUI

/// 4장 Sheets — "얼마나 덮을 것인가"와 "뒤를 살려둘 것인가"의 문제.
/// 시트는 **끌어봐야** 안다. 모든 데모에서 실제로 드래그하고 뒤 화면을 만져볼 수 있다.
@MainActor
enum SheetDemos {
    static let all: [EntryDemo] = [
        EntryDemo(
            "sh1",
            hints: [
                "**열기**를 눌러보세요 — 화면을 거의 다 덮으며 뒤 화면이 살짝 물러납니다.",
                "아래로 쓸어내려 닫아보세요. 큰 시트의 기본 출구입니다.",
                "뒤 화면의 카드를 눌러보려 해도 반응하지 않습니다 — 모달이라는 뜻입니다.",
            ],
            code: """
            .sheet(isPresented: $showing) {
                DetailSheet()
                    .presentationDetents([.large])
            }
            """
        ) { SheetDemoScreen(kind: .large) },

        EntryDemo(
            "sh2",
            hints: [
                "절반 높이에서 멈춥니다 — 뒤 화면의 위쪽 절반이 계속 보입니다.",
                "위로 끌어올려 보세요. **더 커지지 않습니다** — 선언한 detent가 하나뿐이기 때문입니다.",
                "뒤가 보이는 것과 뒤를 만질 수 있는 것은 다릅니다. 4.1.5에서 확인해 보세요.",
            ],
            code: """
            .sheet(isPresented: $showing) {
                FilterSheet()
                    .presentationDetents([.medium])
            }
            """
        ) { SheetDemoScreen(kind: .medium) },

        EntryDemo(
            "sh3",
            hints: [
                "높이 방식을 **height(250) ↔ fraction(0.3)** 로 바꿔가며 열어보세요.",
                "화면이 작을수록 fraction은 함께 줄고, height는 그대로입니다 — 무엇을 기준으로 삼을지의 선택입니다.",
                "내용이 커지면 어떻게 되는지도 확인해 보세요. 커스텀 높이는 내용과 어긋나기 쉽습니다.",
            ],
            code: """
            .presentationDetents([.height(250)])
            // 또는
            .presentationDetents([.fraction(0.3)])
            """
        ) { SheetDemoScreen(kind: .custom) },

        EntryDemo(
            "sh4",
            hints: [
                "시트를 **위아래로 끌어보세요** — medium과 large 사이에서 걸립니다.",
                "지금 어느 단계인지 시트 안에 표시됩니다. 손이 아니라 시스템이 단계를 정합니다.",
                "그랩바를 껐다 켜보세요 — 끌 수 있다는 사실을 무엇이 알려주는지 드러납니다.",
            ],
            code: """
            .presentationDetents([.medium, .large], selection: $detent)
            .presentationDragIndicator(showGrabber ? .visible : .hidden)
            """
        ) { SheetDemoScreen(kind: .combo) },

        EntryDemo(
            "sh5",
            hints: [
                "시트를 연 채로 **뒤 화면의 슬라이더를 만져보세요** — 실제로 움직입니다.",
                "시트를 large까지 끌어올리면 뒤가 다시 잠깁니다. 허용 구간이 medium까지이기 때문입니다.",
                "지도 위 검색 시트처럼 \"보면서 조절하는\" 화면이 이 설정의 자리입니다.",
            ],
            code: """
            .presentationDetents([.medium, .large])
            .presentationBackgroundInteraction(.enabled(upThrough: .medium))
            """
        ) { SheetDemoScreen(kind: .nonmodal) },

        EntryDemo(
            "fc1",
            hints: [
                "**아래로 쓸어내려 보세요** — 닫히지 않습니다.",
                "닫는 방법은 화면 안의 명시적인 버튼뿐입니다. 그래서 그 버튼이 반드시 있어야 합니다.",
                "작성 중이던 내용을 지키는 대신 사용자를 가둡니다 — 그 무게에 맞는 화면에만 씁니다.",
            ],
            code: """
            .fullScreenCover(isPresented: $editing) {
                EditorView()   // 닫기 버튼을 반드시 직접 제공한다
            }
            """
        ) { SheetDemoScreen(kind: .fullScreen) },

        EntryDemo(
            "tr1",
            hints: [
                "카드를 눌러 시트를 열어보세요 — 아래에서 위로 올라오는 기본 전환입니다.",
                "어느 카드를 눌러도 같은 자리에서 올라옵니다. 출발지와 도착지가 이어지지 않습니다.",
                "4.3.2(zoom)와 번갈아 보면 그 연결이 있고 없고의 차이가 분명합니다.",
            ],
            code: """
            .sheet(item: $selected) { card in
                CardDetail(card: card)
            }
            """
        ) { ZoomTransitionDemo(zoom: false, fullScreen: false) },

        EntryDemo(
            "tr2",
            hints: [
                "카드를 눌러보세요 — 시트가 **그 카드 자리에서 확대**되어 나옵니다.",
                "다른 카드도 눌러보세요. 시작점이 매번 다릅니다.",
                "닫을 때도 원래 카드로 돌아갑니다 — \"내가 누른 그것\"이라는 감각이 유지됩니다.",
            ],
            code: """
            CardView(card)
                .matchedTransitionSource(id: card.id, in: namespace)

            .sheet(item: $selected) { card in
                CardDetail(card: card)
                    .navigationTransition(.zoom(sourceID: card.id, in: namespace))
            }
            """
        ) { ZoomTransitionDemo(zoom: true, fullScreen: false) },

        EntryDemo(
            "tr3",
            hints: [
                "썸네일을 누르면 **화면 전체로 확대**됩니다. 사진 앱에서 익숙한 그 동작입니다.",
                "닫으면 원래 썸네일 자리로 돌아갑니다. 목록에서의 위치를 잃지 않습니다.",
                "전체를 덮는 화면일수록 어디서 왔는지가 중요해집니다 — zoom이 특히 값을 하는 이유입니다.",
            ],
            code: """
            .fullScreenCover(item: $selected) { photo in
                PhotoViewer(photo: photo)
                    .navigationTransition(.zoom(sourceID: photo.id, in: namespace))
            }
            """
        ) { ZoomTransitionDemo(zoom: true, fullScreen: true) },
    ]
}

// MARK: - detent 데모

private struct SheetDemoScreen: View {
    enum Kind { case large, medium, custom, combo, nonmodal, fullScreen }

    let kind: Kind

    @State private var showing = false
    @State private var covering = false
    @State private var detent = PresentationDetent.medium
    @State private var useFraction = false
    @State private var grabber = true
    /// 뒤 화면이 살아 있는지 증명하는 값 — 4.1.5 비모달에서 결정적이다.
    @State private var brightness: Double = 0.5
    @State private var taps = 0

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Button {
                        if kind == .fullScreen { covering = true } else { showing = true }
                    } label: {
                        Label(kind == .fullScreen ? "전체 화면 열기" : "시트 열기", systemImage: "rectangle.portrait.bottomhalf.filled")
                            .font(.system(size: 16, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 13)
                            .background(.tint, in: .rect(cornerRadius: 13))
                            .foregroundStyle(.white)
                    }
                    .buttonStyle(.plain)

                    if kind == .custom {
                        Toggle("fraction(0.3) 으로 바꾸기", isOn: $useFraction)
                    }
                    if kind == .combo {
                        Toggle("그랩바 표시", isOn: $grabber)
                    }

                    if kind == .nonmodal {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("뒤 화면의 밝기 \(Int(brightness * 100))%")
                                .font(.system(size: 12, weight: .semibold, design: .monospaced))
                                .foregroundStyle(.secondary)
                            Slider(value: $brightness)
                            DemoNote(text: "시트를 연 채로 이 슬라이더를 움직여 보세요. **뒤가 살아 있다**는 게 이 항목의 전부입니다.")
                        }
                    }

                    Text("뒤 화면 · 카드를 눌러보세요 (\(taps)회)")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)

                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 10)], spacing: 10) {
                        ForEach(0..<9, id: \.self) { i in
                            Button { taps += 1 } label: {
                                DemoPhoto(index: i)
                                    .frame(height: 84)
                                    .clipShape(.rect(cornerRadius: 12))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(18)
                .brightness(kind == .nonmodal ? (brightness - 0.5) * 0.6 : 0)
            }
            .navigationTitle("시트")
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $showing) {
            DemoSheetBody(kind: kind, detent: $detent)
                .modifier(DetentModifier(kind: kind, detent: $detent, useFraction: useFraction, grabber: grabber))
        }
        .fullScreenCover(isPresented: $covering) {
            DemoFullScreenBody()
        }
    }
}

private struct DetentModifier: ViewModifier {
    let kind: SheetDemoScreen.Kind
    @Binding var detent: PresentationDetent
    let useFraction: Bool
    let grabber: Bool

    func body(content: Content) -> some View {
        switch kind {
        case .large:
            content.presentationDetents([.large])
        case .medium:
            content.presentationDetents([.medium])
        case .custom:
            content.presentationDetents([useFraction ? .fraction(0.3) : .height(250)])
        case .combo:
            content
                .presentationDetents([.medium, .large], selection: $detent)
                .presentationDragIndicator(grabber ? .visible : .hidden)
        case .nonmodal:
            content
                .presentationDetents([.medium, .large], selection: $detent)
                .presentationDragIndicator(.visible)
                .presentationBackgroundInteraction(.enabled(upThrough: .medium))
        case .fullScreen:
            content
        }
    }
}

private struct DemoSheetBody: View {
    let kind: SheetDemoScreen.Kind
    @Binding var detent: PresentationDetent

    @Environment(\.dismiss) private var dismiss
    @State private var query = ""

    var body: some View {
        NavigationStack {
            List {
                if kind == .combo || kind == .nonmodal {
                    Section {
                        LabeledContent("현재 단계", value: detent == .large ? "large" : "medium")
                            .font(.system(size: 14, design: .monospaced))
                    }
                }
                Section("필터") {
                    ForEach(["읽지 않음", "깃발 표시", "첨부 있음", "지난 7일"], id: \.self) { item in
                        Label(item, systemImage: "line.3.horizontal.decrease")
                    }
                }
                Section("결과") {
                    ForEach(DemoData.mail.prefix(8)) { DemoMailRow(mail: $0) }
                }
            }
            .navigationTitle("옵션")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("닫기") { dismiss() }
                }
            }
        }
    }
}

private struct DemoFullScreenBody: View {
    @Environment(\.dismiss) private var dismiss
    @State private var text = "여기에 쓴 내용은 실수로 쓸어내려도 사라지지 않습니다."

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 14) {
                DemoNote(text: "아래로 쓸어내려 보세요 — **닫히지 않습니다**. 닫기 버튼만이 출구입니다.", symbol: "hand.draw")
                TextEditor(text: $text)
                    .font(.system(size: 15))
                    .scrollContentBackground(.hidden)
                    .background(.quaternary.opacity(0.4), in: .rect(cornerRadius: 12))
            }
            .padding(18)
            .navigationTitle("편집기")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("취소") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("완료") { dismiss() }.fontWeight(.semibold)
                }
            }
        }
    }
}

// MARK: - 전환 데모

private struct ZoomTransitionDemo: View {
    let zoom: Bool
    let fullScreen: Bool

    @Namespace private var namespace
    @State private var selected: DemoCard?

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 104), spacing: 10)], spacing: 10) {
                    ForEach(DemoCard.all) { card in
                        Button { selected = card } label: {
                            DemoPhoto(index: card.id)
                                .frame(height: 104)
                                .clipShape(.rect(cornerRadius: 14))
                                .overlay(alignment: .bottomLeading) {
                                    Text(card.title)
                                        .font(.system(size: 11, weight: .semibold))
                                        .foregroundStyle(.white)
                                        .padding(7)
                                }
                        }
                        .buttonStyle(.plain)
                        .matchedTransitionSource(id: card.id, in: namespace)
                    }
                }
                .padding(12)
            }
            .navigationTitle(zoom ? "Zoom 전환" : "기본 전환")
            .navigationBarTitleDisplayMode(.inline)
        }
        .modifier(
            PresentModifier(
                zoom: zoom,
                fullScreen: fullScreen,
                namespace: namespace,
                selected: $selected
            )
        )
    }
}

struct DemoCard: Identifiable, Hashable {
    let id: Int
    let title: String

    static let all: [DemoCard] = (0..<9).map {
        DemoCard(id: $0, title: ["광장", "해변", "노을", "숲길", "야경", "골목", "설산", "호수", "사막"][$0])
    }
}

private struct PresentModifier: ViewModifier {
    let zoom: Bool
    let fullScreen: Bool
    let namespace: Namespace.ID
    @Binding var selected: DemoCard?

    func body(content: Content) -> some View {
        if fullScreen {
            content.fullScreenCover(item: $selected) { card in
                DemoCardDetail(card: card, fullScreen: true)
                    .modifier(ZoomModifier(zoom: zoom, id: card.id, namespace: namespace))
            }
        } else {
            content.sheet(item: $selected) { card in
                DemoCardDetail(card: card, fullScreen: false)
                    .presentationDetents([.large])
                    .modifier(ZoomModifier(zoom: zoom, id: card.id, namespace: namespace))
            }
        }
    }
}

private struct ZoomModifier: ViewModifier {
    let zoom: Bool
    let id: Int
    let namespace: Namespace.ID

    func body(content: Content) -> some View {
        if zoom {
            content.navigationTransition(.zoom(sourceID: id, in: namespace))
        } else {
            content
        }
    }
}

private struct DemoCardDetail: View {
    let card: DemoCard
    let fullScreen: Bool

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    DemoPhoto(index: card.id)
                        .frame(height: 220)
                        .clipShape(.rect(cornerRadius: 18))
                    Text(card.title).font(.system(size: 24, weight: .bold))
                    Text(DemoData.longText).font(.system(size: 14)).foregroundStyle(.secondary)
                }
                .padding(18)
            }
            .navigationTitle(card.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("닫기") { dismiss() }
                }
            }
        }
    }
}
