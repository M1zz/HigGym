import SwiftUI

enum DetentOption: String, CaseIterable, Identifiable {
    case large, medium, custom, combo
    var id: String { rawValue }

    var label: String {
        switch self {
        case .large:  "Large"
        case .medium: "Medium"
        case .custom: "Custom"
        case .combo:  "Combo"
        }
    }

    var detents: Set<PresentationDetent> {
        switch self {
        case .large:  [.large]
        case .medium: [.medium]
        case .custom: [.height(200)]
        case .combo:  [.medium, .large]
        }
    }

    var code: String {
        switch self {
        case .large:  ".presentationDetents([.large])"
        case .medium: ".presentationDetents([.medium])"
        case .custom: ".presentationDetents([.height(200)])"
        case .combo:  ".presentationDetents([.medium, .large])"
        }
    }

    var source: String {
        switch self {
        case .large:  "4.1.1"
        case .medium: "4.1.2"
        case .custom: "4.1.3"
        case .combo:  "4.1.4"
        }
    }
}

enum PresentationKind: String, CaseIterable, Identifiable {
    case sheet, zoomSheet, cover
    var id: String { rawValue }
    var label: String {
        switch self {
        case .sheet:     "Standard"
        case .zoomSheet: "Zoom"
        case .cover:     "Full Cover"
        }
    }
}

struct SheetLabView: View {
    @State private var detent: DetentOption = .medium
    @State private var kind: PresentationKind = .sheet
    @State private var dragIndicator = true
    @State private var nonmodal = false

    @State private var showSheet = false
    @State private var showCover = false
    @State private var selectedCard: Int?
    @Namespace private var zoomNamespace

    var body: some View {
        LabScaffold(title: "시트 디텐트", subtitle: "얼마나 덮을 것인가") {
                stage
                controls
                diagnosisSection
                CodePanel(code: code)
        }
        .sheet(isPresented: $showSheet) { sheetContent }
        .fullScreenCover(isPresented: $showCover) { coverContent }
    }

    // MARK: 배경 — 시트가 얼마나 덮는지 비교할 대상

    private var stage: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("시트 뒤에 남는 것이 무엇인지 보세요")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.hgText)
            Text("medium은 “원본과의 대화”, large는 사실상 새 화면입니다. 비모달로 바꾸면 아래 카드를 시트가 열린 채로 만질 수 있습니다.")
                .font(.system(size: 13))
                .foregroundStyle(.hgMuted)

            LazyVGrid(columns: [.init(.flexible()), .init(.flexible())], spacing: 10) {
                ForEach(0..<4, id: \.self) { i in
                    Button {
                        selectedCard = i
                        present()
                    } label: {
                        VStack(alignment: .leading, spacing: 6) {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.hgBrand)
                                .frame(height: 52)
                            Text("카드 \(i + 1)")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(.hgText)
                            Text("탭하면 이 카드의 상세")
                                .font(.system(size: 11))
                                .foregroundStyle(.hgDim)
                        }
                        .padding(10)
                        .background(Color.hgCardHigh, in: .rect(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                    .matchedTransitionSource(id: i, in: zoomNamespace)
                }
            }
        }
        .hgCard()
    }

    private func present() {
        if kind == .cover { showCover = true } else { showSheet = true }
    }

    // MARK: 띄우는 내용

    @ViewBuilder
    private var sheetContent: some View {
        let base = SheetBody(
            title: selectedCard.map { "카드 \($0 + 1) 상세" } ?? "상세",
            detent: detent,
            nonmodal: nonmodal
        )
        .presentationDetents(detent.detents)
        .presentationDragIndicator(dragIndicator ? .visible : .hidden)
        .modifier(BackgroundInteractionModifier(enabled: nonmodal, detent: detent))

        if kind == .zoomSheet, let card = selectedCard {
            base.navigationTransition(.zoom(sourceID: card, in: zoomNamespace))
        } else {
            base
        }
    }

    private var coverContent: some View {
        NavigationStack {
            SheetBody(title: "전체 화면 커버", detent: .large, nonmodal: false)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("완료") { showCover = false }
                    }
                }
                .navigationTitle("온보딩")
                .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: 컨트롤

    private var controls: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionLabel("얼마나 덮을 것인가", accent: .hgAccent)
            Picker("detent", selection: $detent) {
                ForEach(DetentOption.allCases) { Text($0.label).tag($0) }
            }
            .pickerStyle(.segmented)
            .disabled(kind == .cover)

            SectionLabel("어떻게 열 것인가", accent: .hgAmber)
            Picker("전환", selection: $kind) {
                ForEach(PresentationKind.allCases) { Text($0.label).tag($0) }
            }
            .pickerStyle(.segmented)

            Toggle("그랩바 표시 (dragIndicator)", isOn: $dragIndicator)
                .font(.system(size: 14)).foregroundStyle(.hgText).tint(.hgAccent)
                .disabled(kind == .cover)

            Toggle("비모달 — 뒤를 만질 수 있게", isOn: $nonmodal)
                .font(.system(size: 14)).foregroundStyle(.hgText).tint(.hgAccent)
                .disabled(kind == .cover)
        }
    }

    // MARK: 판정

    private var diagnoses: [Diagnosis] {
        var out: [Diagnosis] = []

        switch detent {
        case .medium:
            out.append(.init(
                level: .good,
                message: "절반 높이는 **“원본과의 대화”** 은유입니다 — 화면을 나눠 가짐으로써 이 시트가 배경 콘텐츠에 대한 것임을 형태로 말합니다.",
                source: "4.1.2"
            ))
        case .large:
            out.append(.init(
                level: .good,
                message: "배경 컨텍스트를 참조할 필요가 없는 독립 작업에 맞습니다. 뒤가 살짝 보이는 스택 은유가 “끝나면 돌아간다”는 감각을 유지합니다.",
                source: "4.1.1"
            ))
        case .custom:
            out.append(.init(
                level: .good,
                message: "시트 높이는 콘텐츠가 결정해야 합니다 — 작은 UI에 medium을 쓰면 잉여 공백이 “뭔가 더 있나?”라는 오독을 만듭니다.",
                source: "4.1.3"
            ))
        case .combo:
            out.append(.init(
                level: .good,
                message: "“지금 얼마나 보고 싶은지”는 시스템이 판단할 수 없는 **사용자의 의도**라 선택권을 넘긴 구성입니다. 그랩바가 “단계가 더 있다”는 어포던스입니다.",
                source: "4.1.4"
            ))
        }

        if detent == .combo && !dragIndicator {
            out.append(.init(
                level: .violation,
                message: "높이 단계가 둘인데 그랩바를 껐습니다. 끌어올릴 수 있다는 어포던스가 사라져 사용자가 large 단계의 존재를 모릅니다.",
                source: "4.1.4"
            ))
        }

        if nonmodal {
            out.append(.init(
                level: .good,
                message: "모달의 본질은 “응답을 요구하고 나머지를 차단”인데 도구 패널은 응답이 아니라 **병행 작업**입니다. 딤이 사라진 것이 “뒤를 만져도 된다”는 시각 신호입니다.",
                source: "4.1.5"
            ))
            if detent == .large {
                out.append(.init(
                    level: .caution,
                    message: "large에서 비모달은 의미가 약합니다 — 뒤가 거의 안 보이는데 만질 수 있다고 말하는 셈입니다. 비모달은 medium·custom과 짝입니다.",
                    source: "4.1.5"
                ))
            }
        }

        switch kind {
        case .zoomSheet:
            out.append(.init(
                level: .good,
                message: "눌렀던 것과 열린 것이 **같은 것임을 모션으로 증명**합니다. 공간적 연속성이 유지되어 “어디서 왔는지”를 설명할 필요가 없습니다.",
                source: "4.3.2"
            ))
        case .sheet:
            out.append(.init(
                level: .good,
                message: "아래에서 올라오는 기본 모션은 OS 전역에서 동일해 “내리면 닫힌다”를 즉시 예측하게 합니다. 예측 가능성이 이 전환의 가치입니다.",
                source: "4.3.1"
            ))
        case .cover:
            out.append(.init(
                level: .caution,
                message: "전체 화면 커버는 제스처 닫기가 없는 **강한 모달**입니다. 온보딩·로그인·카메라처럼 “끝내거나 명시적으로 나가라”가 맞는 흐름에만 쓰세요.",
                source: "4.2.1"
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
        if kind == .cover {
            return """
            .fullScreenCover(isPresented: $show) {
                OnboardingView()
            }
            """
        }
        var lines = [".sheet(isPresented: $show) {", "    DetailView()"]
        lines.append("        \(detent.code)")
        lines.append("        .presentationDragIndicator(.\(dragIndicator ? "visible" : "hidden"))")
        if nonmodal {
            let upThrough = detent == .custom ? ".height(200)" : ".medium"
            lines.append("        .presentationBackgroundInteraction(.enabled(upThrough: \(upThrough)))")
        }
        if kind == .zoomSheet {
            lines.append("        .navigationTransition(.zoom(sourceID: card.id, in: namespace))")
        }
        lines.append("}")
        if kind == .zoomSheet {
            lines.append("")
            lines.append("// 여는 쪽")
            lines.append("CardView().matchedTransitionSource(id: card.id, in: namespace)")
        }
        return lines.joined(separator: "\n")
    }
}

private struct BackgroundInteractionModifier: ViewModifier {
    let enabled: Bool
    let detent: DetentOption

    func body(content: Content) -> some View {
        if enabled {
            content.presentationBackgroundInteraction(
                .enabled(upThrough: detent == .custom ? .height(200) : .medium)
            )
        } else {
            content
        }
    }
}

private struct SheetBody: View {
    let title: String
    let detent: DetentOption
    let nonmodal: Bool

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text(title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.hgText)
                Text(nonmodal
                     ? "비모달입니다 — 시트를 연 채로 뒤의 카드를 만져보세요."
                     : "모달입니다 — 뒤는 딤 처리되어 닫기 전에는 만질 수 없습니다.")
                    .font(.system(size: 13))
                    .foregroundStyle(.hgMuted)

                ForEach(0..<12, id: \.self) { i in
                    HStack {
                        Text("옵션 \(i + 1)")
                            .font(.system(size: 14))
                            .foregroundStyle(.hgText)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12))
                            .foregroundStyle(.hgDim)
                    }
                    .padding(12)
                    .background(Color.hgCard, in: .rect(cornerRadius: 10))
                }
            }
            .padding(18)
        }
        .background(Color.hgBackground)
    }
}
