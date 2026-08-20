import SwiftUI

enum EdgeStyleOption: String, CaseIterable, Identifiable {
    case soft, hard, hidden
    var id: String { rawValue }
    var label: String {
        switch self {
        case .soft:   "Soft"
        case .hard:   "Hard"
        case .hidden: "Hidden"
        }
    }
    var source: String {
        switch self {
        case .soft:   "1.3.1"
        case .hard:   "1.3.2"
        case .hidden: "1.3.4"
        }
    }
}

enum BackdropOption: String, CaseIterable, Identifiable {
    case calm, photo, white
    var id: String { rawValue }
    var label: String {
        switch self {
        case .calm:  "단색"
        case .photo: "사진"
        case .white: "흰 배경"
        }
    }
    /// 이 배경이 가독성 검증에서 "최악의 조건"인가.
    var isHostile: Bool { self != .calm }
}

struct ScrollEdgeLabView: View {
    @State private var style: EdgeStyleOption = .soft
    @State private var backdrop: BackdropOption = .calm
    @State private var thickMaterial = false
    @State private var running = false

    var body: some View {
        LabScaffold(title: "스크롤 엣지 이펙트", subtitle: "최악의 배경에서 컨트롤이 읽히는지") {
                RunStageCard(
                    title: "최악의 배경에서 확인하세요",
                    body_: "실행한 뒤 스크롤해 콘텐츠가 바 뒤를 지나가게 해보세요. 판정 기준은 가장 좋은 조건이 아니라 가장 나쁜 조건입니다."
                ) { running = true }

                controls
                diagnosisSection
                CodePanel(code: code)
        }
        .onAppear { if DebugLaunch.autoRunStage { running = true } }
        .fullScreenCover(isPresented: $running) {
            stage.stageChrome(onClose: { running = false }) {
                controls
                diagnosisSection
            }
        }
    }

    // MARK: 실제 API를 적용한 화면

    private var stage: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(0..<20, id: \.self) { i in
                        HStack(spacing: 12) {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.white.opacity(0.9))
                                .frame(width: 44, height: 44)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("항목 \(i + 1)")
                                    .font(.system(size: 14, weight: .semibold))
                                Text("바 뒤로 지나가는 콘텐츠")
                                    .font(.system(size: 12))
                                    .opacity(0.75)
                            }
                            Spacer()
                        }
                        .padding(12)
                        .background(.white.opacity(backdrop == .white ? 0.95 : 0.14), in: .rect(cornerRadius: 12))
                        .foregroundStyle(backdrop == .white ? .black : .white)
                    }
                }
                .padding(16)
            }
            .background(backdropView)
            .navigationTitle("갤러리")
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button("공유", systemImage: "square.and.arrow.up") {}
                    Button("선택", systemImage: "checkmark.circle") {}
                }
            }
            .modifier(EdgeEffectModifier(style: style))
            .modifier(ToolbarBackgroundModifier(thick: thickMaterial))
        }
    }

    @ViewBuilder
    private var backdropView: some View {
        switch backdrop {
        case .calm:
            // 앱 모드를 따라가면 안 된다 — 여기서 판정하는 건 앱 크롬이 아니라
            // **바 뒤로 지나가는 콘텐츠**다. 조건을 고정해야 세 배경의 비교가 성립한다.
            Color(red: 0.07, green: 0.08, blue: 0.11)
        case .white:
            Color.white
        case .photo:
            // 밝기가 크게 출렁이는 배경 — 반투명 바의 대비가 무너지는 조건을 만든다.
            MeshGradient(
                width: 3, height: 3,
                points: [
                    [0, 0], [0.5, 0], [1, 0],
                    [0, 0.5], [0.5, 0.5], [1, 0.5],
                    [0, 1], [0.5, 1], [1, 1],
                ],
                colors: [
                    .white, .yellow, .white,
                    .orange, .white, .cyan,
                    .white, .pink, .white,
                ]
            )
        }
    }

    // MARK: 컨트롤

    private var controls: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionLabel("배경 조건", accent: .hgAmber)
            Picker("배경", selection: $backdrop) {
                ForEach(BackdropOption.allCases) { Text($0.label).tag($0) }
            }
            .pickerStyle(.segmented)

            SectionLabel("가장자리 효과", accent: .hgAccent)
            Picker("효과", selection: $style) {
                ForEach(EdgeStyleOption.allCases) { Text($0.label).tag($0) }
            }
            .pickerStyle(.segmented)

            Toggle(isOn: $thickMaterial) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("툴바 배경을 두꺼운 material로")
                        .font(.system(size: 14))
                        .foregroundStyle(.hgText)
                    Text("투명함을 포기하고 대비를 확보하는 공식 탈출구 (1.3.3)")
                        .font(.system(size: 11.5))
                        .foregroundStyle(.hgDim)
                }
            }
            .tint(.hgAccent)
        }
    }

    // MARK: 판정 — 8.1.4 가독성 > 미학

    private var diagnoses: [Diagnosis] {
        var out: [Diagnosis] = []

        switch (style, backdrop.isHostile, thickMaterial) {
        case (.hidden, true, false):
            out.append(.init(
                level: .violation,
                message: "밝고 복잡한 배경 위에서 가장자리 효과를 껐습니다. 흰 영역이 바 뒤를 지나는 순간 컨트롤이 배경에 녹아 사라집니다 — 최악의 배경에서 검증하는 단계를 건너뛴 전형입니다.",
                source: "1.3.4 · 8.1.4"
            ))
        case (.hidden, false, _):
            out.append(.init(
                level: .caution,
                message: "지금 단색 배경에서는 멀쩡해 보입니다. 배경을 **사진**이나 **흰 배경**으로 바꿔 같은 설정을 다시 확인해보세요 — 그게 실제 검증 조건입니다.",
                source: "1.3.4 · 8.1.4"
            ))
        case (.soft, true, false):
            out.append(.init(
                level: .caution,
                message: "soft는 콘텐츠를 부드럽게 흐리는 대신 대비 확보력이 약합니다. 사진 위라면 hard 또는 두꺼운 material 쪽이 안전합니다.",
                source: "1.3.1 · 1.3.3"
            ))
        case (.hard, true, true), (.soft, true, true):
            out.append(.init(
                level: .good,
                message: "복잡한 배경에서 투명도(미학)를 포기하고 불투명 배경으로 가독성을 확보했습니다 — “예쁜데 안 읽힌다”에 대한 공식 탈출구입니다.",
                source: "1.3.3 · 8.1.4"
            ))
        case (.hard, true, false):
            out.append(.init(
                level: .caution,
                message: "hard는 경계를 또렷하게 나누지만, 사진처럼 밝기가 출렁이는 배경에서는 그것만으로 부족할 수 있습니다. 두꺼운 material을 함께 켜고 비교해보세요.",
                source: "1.3.2 · 1.3.3"
            ))
        case (.soft, false, _):
            out.append(.init(
                level: .good,
                message: "콘텐츠가 자연스럽게 흘러 사라지는 기본값입니다 — 목록·피드처럼 배경이 잔잔한 화면의 표준입니다.",
                source: "1.3.1"
            ))
        case (.hard, false, _):
            out.append(.init(
                level: .good,
                message: "바와 콘텐츠의 경계를 또렷이 나눕니다 — 표·폼처럼 구조가 중요한 화면에 맞습니다.",
                source: "1.3.2"
            ))
        case (.hidden, true, true):
            out.append(.init(
                level: .caution,
                message: "효과는 껐지만 두꺼운 material이 대비를 대신 확보하고 있습니다. 다만 “왜 껐는가”가 설명되지 않으면 기본값을 유지하는 편이 안전합니다.",
                source: "1.3.4"
            ))
        }

        if thickMaterial && !backdrop.isHostile {
            out.append(.init(
                level: .caution,
                message: "배경이 잔잔한데 불투명 바를 썼습니다. 필요 없는 곳에서 투명함을 포기하면 바가 콘텐츠 위의 “스티커”처럼 단절돼 보입니다.",
                source: "6.1.1"
            ))
        }

        out.append(.init(
            level: .caution,
            message: "설정 앱의 **투명도 감소**와 **큰 글씨**를 켠 상태에서도 같은 화면을 확인하세요. 접근성 설정은 가독성 검증의 일부입니다.",
            source: "8.1.4"
        ))

        return out.sorted { $0.level > $1.level }
    }

    private var diagnosisSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionLabel("실시간 판정", accent: .hgGreen)
            ForEach(diagnoses) { DiagnosisRow(diagnosis: $0) }
        }
    }

    private var code: String {
        var lines = ["ScrollView { /* 콘텐츠 */ }", "    .navigationTitle(\"갤러리\")"]
        switch style {
        case .soft:   lines.append("    .scrollEdgeEffectStyle(.soft, for: .top)")
        case .hard:   lines.append("    .scrollEdgeEffectStyle(.hard, for: .top)")
        case .hidden: lines.append("    .scrollEdgeEffectHidden(true, for: .top)")
        }
        if thickMaterial {
            lines.append("    .toolbarBackground(.thickMaterial, for: .navigationBar)")
            lines.append("    .toolbarBackgroundVisibility(.visible, for: .navigationBar)")
        }
        return lines.joined(separator: "\n")
    }
}

private struct EdgeEffectModifier: ViewModifier {
    let style: EdgeStyleOption

    func body(content: Content) -> some View {
        switch style {
        case .soft:   content.scrollEdgeEffectStyle(.soft, for: .top)
        case .hard:   content.scrollEdgeEffectStyle(.hard, for: .top)
        case .hidden: content.scrollEdgeEffectHidden(true, for: .top)
        }
    }
}

private struct ToolbarBackgroundModifier: ViewModifier {
    let thick: Bool

    func body(content: Content) -> some View {
        if thick {
            content
                .toolbarBackground(.thickMaterial, for: .navigationBar)
                .toolbarBackgroundVisibility(.visible, for: .navigationBar)
        } else {
            content
        }
    }
}
