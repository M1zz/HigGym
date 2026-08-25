import SwiftUI

/// 8장 원칙 — 항목 데모가 "이렇게 생겼다"를 보여준다면, 원칙 데모는 **어겼을 때와 지켰을 때**를 한 화면에서 바꿔 보여준다.
/// 스위치 하나로 같은 화면을 뒤집어 보는 것이 이 데모들의 공통 문법이다.
@MainActor
enum PrincipleDemos {
    static let all: [EntryDemo] = [
        EntryDemo(
            "p1",
            hints: [
                "스위치를 **어김 ↔ 지킴**으로 오가며, 같은 콘텐츠가 얼마나 다르게 보이는지 확인하세요.",
                "어긴 쪽에서 실제 콘텐츠가 화면의 몇 %를 차지하는지 눈으로 재보세요.",
                "지운 것들이 없어도 화면이 돌아가는지 — 그게 이 원칙의 판단 기준입니다.",
            ],
            code: """
            // 기준: 이 UI 요소를 지웠을 때 사용자가 못 하게 되는 일이 있는가?
            // 없다면 지운다.
            """
        ) { ContentFirstDemo() },

        EntryDemo(
            "p2",
            hints: [
                "**작성 5번** 과제를 한 손으로 해보세요. 먼저 어긴 배치(상단)로.",
                "스위치를 켜서 같은 과제를 하단 배치로 다시 해보세요. 엄지의 이동 거리를 비교합니다.",
                "빈도가 낮은 액션(설정)은 어디에 있는 게 맞는지도 함께 생각해 보세요.",
            ],
            code: """
            // 기준: 이 액션을 하루에 몇 번 누르는가?
            // 자주 누를수록 아래로.
            ToolbarItem(placement: .bottomBar) { ComposeButton() }
            """
        ) { ReachabilityDemo() },

        EntryDemo(
            "p3",
            hints: [
                "어긴 배치에서 **삭제**와 **정렬**이 한 캡슐에 붙어 있습니다. 같은 세트로 보입니다.",
                "스위치를 켜면 역할대로 갈라집니다 — 도구는 왼쪽, 파괴적 액션은 접힌 메뉴 안으로.",
                "묶음을 바꿨을 뿐 기능은 그대로입니다. 그런데도 읽히는 의미가 달라집니다.",
            ],
            code: """
            // 기준: 같은 캡슐에 든 것들을 사용자가 "한 세트"로 읽어도 맞는가?
            ToolbarItemGroup(placement: .topBarLeading) { 보기전환; 정렬 }
            ToolbarItem(placement: .topBarTrailing) { Menu { 삭제 } }
            """
        ) { GrammarDemo() },

        EntryDemo(
            "p4",
            hints: [
                "어긴 쪽은 얇은 재료 + 가장자리 효과 없음입니다. 밝은 사진 위에서 버튼을 읽어보세요.",
                "스위치를 켜면 hard 경계 + 두꺼운 재료로 바뀝니다. 투명함은 줄고 읽힘은 늘어납니다.",
                "배경을 바꿔가며, 어느 쪽이 **모든 배경에서** 살아남는지 확인하세요.",
            ],
            code: """
            // 기준: 최악의 배경에서도 컨트롤이 읽히는가?
            .scrollEdgeEffectStyle(.hard, for: .top)
            .toolbarBackground(.thickMaterial, for: .navigationBar)
            """
        ) { LegibilityDemo() },

        EntryDemo(
            "p5",
            hints: [
                "어긴 쪽은 고정 폭·고정 높이입니다. **Dynamic Type**을 키워보세요 — 글자가 잘려나갑니다.",
                "스위치를 켜면 줄 수 범위와 공간 예약이 들어갑니다. 같은 글자 크기에서 어떻게 버티는지 보세요.",
                "긴 이름·긴 제목으로 바꿔가며, 레이아웃이 텍스트를 예상하고 있었는지 확인하세요.",
            ],
            code: """
            // 기준: 글자가 두 배로 커져도 이 레이아웃이 버티는가?
            Text(title).lineLimit(2...3)
            Text(subtitle).lineLimit(2, reservesSpace: true)
            """
        ) { ElasticTextDemo() },

        EntryDemo(
            "p6",
            hints: [
                "어긴 쪽은 \"5km\", \"김하늘\" 처럼 **표기를 문자열로 박아** 뒀습니다.",
                "로케일을 en_US로 바꿔보세요 — 박아둔 쪽만 그대로 남습니다.",
                "지킨 쪽은 값만 들고 있다가 로케일에 맞춰 스스로 표기를 바꿉니다.",
            ],
            code: """
            // 기준: 값과 표기를 같은 문자열에 담고 있지 않은가?
            Text(distance.formatted(.measurement(width: .wide).locale(locale)))
            Text(name.formatted(.name(style: .medium).locale(locale)))
            """
        ) { DataVsPresentationDemo() },

        EntryDemo(
            "p7",
            hints: [
                "어긴 쪽에서 두 번째 메일을 삭제해 보세요 — 상단 메뉴에서 대상을 **다시 골라야** 합니다.",
                "스위치를 켜고 같은 일을 해보세요. 행을 왼쪽으로 밀거나 길게 누르면 됩니다.",
                "대상을 두 번 지정하게 만드는 UI는 대개 직접 조작으로 바꿀 수 있습니다.",
            ],
            code: """
            // 기준: 액션이 대상 위에 붙어 있는가?
            .swipeActions { Button("삭제", role: .destructive) { … } }
            .contextMenu { … }
            """
        ) { DirectManipulationDemo() },
    ]
}

// MARK: - 공통 껍데기

/// 원칙 데모는 전부 "어김 ↔ 지킴" 한 스위치로 뒤집힌다. 그 스위치와 설명을 한곳에서 그린다.
private struct PrincipleToggleBar: View {
    let title: String
    let violationText: String
    let complianceText: String
    @Binding var compliant: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: compliant ? "checkmark.seal.fill" : "exclamationmark.triangle.fill")
                    .foregroundStyle(compliant ? .green : .orange)
                Text(compliant ? "기준을 지킨 구성" : "기준을 어긴 구성")
                    .font(.subheadline.weight(.bold))
                Spacer()
                Toggle("", isOn: $compliant.animation(.snappy))
                    .labelsHidden()
            }
            Text(.init(compliant ? complianceText : violationText))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(13)
        .background((compliant ? Color.green : Color.orange).opacity(0.12), in: .rect(cornerRadius: 13))
    }
}

// MARK: - 8.1.1 Content-First

private struct ContentFirstDemo: View {
    @State private var compliant = false
    @State private var log = DemoLog()

    var body: some View {
        NavigationStack {
            List {
                Section {
                    PrincipleToggleBar(
                        title: "Content-First",
                        violationText: "장식 버튼 6개 · 배너 · 프로모션 카드가 콘텐츠 위를 덮고 있습니다. **지워도 아무도 못 하게 되는 일이 없는 것들**입니다.",
                        complianceText: "남긴 것은 이 화면에서 실제로 쓰는 액션뿐입니다. 콘텐츠가 화면의 주인으로 돌아왔습니다.",
                        compliant: $compliant
                    )
                    .listRowInsets(.init(top: 8, leading: 12, bottom: 8, trailing: 12))
                }

                if !compliant {
                    Section {
                        banner
                            .listRowInsets(.init(top: 6, leading: 12, bottom: 6, trailing: 12))
                    }
                }

                Section("받은 편지함") {
                    ForEach(DemoData.mail) { DemoMailRow(mail: $0) }
                }
            }
            .listStyle(.plain)
            .navigationTitle("메일")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    if compliant {
                        Button("작성", systemImage: "square.and.pencil") { log.tap("새 메일") }
                    } else {
                        Button("별표", systemImage: "star") { log.tap("별표") }
                        Button("깃발", systemImage: "flag") { log.tap("깃발") }
                        Button("공유", systemImage: "square.and.arrow.up") { log.tap("공유") }
                        Button("작성", systemImage: "square.and.pencil") { log.tap("새 메일") }
                    }
                }
                ToolbarItemGroup(placement: .bottomBar) {
                    if !compliant {
                        Button("추천", systemImage: "sparkles") { log.tap("추천") }
                        Spacer()
                        Button("이벤트", systemImage: "gift") { log.tap("이벤트") }
                        Spacer()
                        Button("설정", systemImage: "gearshape") { log.tap("설정") }
                    }
                }
            }
        }
        .demoToast(log)
    }

    private var banner: some View {
        HStack(spacing: 10) {
            Image(systemName: "megaphone.fill")
                .font(.title3)
                .foregroundStyle(.orange)
            VStack(alignment: .leading, spacing: 2) {
                Text("이번 주 특별 혜택!").font(.subheadline.weight(.bold))
                Text("지금 가입하면 3개월 무료").font(.footnote).foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "xmark").font(.footnote).foregroundStyle(.secondary)
        }
        .padding(12)
        .background(.orange.opacity(0.14), in: .rect(cornerRadius: 12))
    }
}

// MARK: - 8.1.2 Reachability

private struct ReachabilityDemo: View {
    @State private var compliant = false
    @State private var composed = 0

    var body: some View {
        NavigationStack {
            List {
                Section {
                    PrincipleToggleBar(
                        title: "Reachability",
                        violationText: "가장 자주 쓰는 **작성**이 화면 맨 위에 있습니다. 한 손으로 5번 눌러보세요.",
                        complianceText: "작성이 하단으로 내려왔습니다. 같은 과제를 다시 해보고 엄지의 이동 거리를 비교하세요.",
                        compliant: $compliant
                    )
                    .listRowInsets(.init(top: 8, leading: 12, bottom: 8, trailing: 12))

                    HStack {
                        Text("과제 · 작성 5번 누르기")
                            .font(.subheadline.weight(.semibold))
                        Spacer()
                        Text("\(composed) / 5")
                            .font(.system(.subheadline, design: .monospaced, weight: .bold))
                            .foregroundStyle(composed >= 5 ? .green : .secondary)
                    }
                    if composed >= 5 {
                        Button("과제 초기화") { composed = 0 }
                    }
                }

                Section("받은 편지함") {
                    ForEach(DemoData.mail) { DemoMailRow(mail: $0) }
                }
            }
            .listStyle(.plain)
            .navigationTitle("메일")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if compliant {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("설정", systemImage: "gearshape") {}
                    }
                    ToolbarItemGroup(placement: .bottomBar) {
                        Spacer()
                        Button("작성", systemImage: "square.and.pencil") { composed += 1 }
                    }
                } else {
                    ToolbarItemGroup(placement: .topBarTrailing) {
                        Button("작성", systemImage: "square.and.pencil") { composed += 1 }
                        Button("설정", systemImage: "gearshape") {}
                    }
                }
            }
        }
    }
}

// MARK: - 8.1.3 위치·묶음의 문법

private struct GrammarDemo: View {
    @State private var compliant = false
    @State private var log = DemoLog()

    var body: some View {
        NavigationStack {
            List {
                Section {
                    PrincipleToggleBar(
                        title: "위치·묶음의 문법",
                        violationText: "**삭제**와 **정렬**이 한 캡슐에 들어 있습니다. 성격이 다른 둘이 한 세트로 읽힙니다.",
                        complianceText: "도구(보기·정렬)는 왼쪽 묶음으로, 파괴적 액션은 오른쪽 메뉴 안으로 갈라졌습니다.",
                        compliant: $compliant
                    )
                    .listRowInsets(.init(top: 8, leading: 12, bottom: 8, trailing: 12))
                }
                Section("문서") {
                    ForEach(DemoData.mail.prefix(8)) { DemoMailRow(mail: $0) }
                }
            }
            .listStyle(.plain)
            .navigationTitle("문서")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if compliant {
                    ToolbarItemGroup(placement: .topBarLeading) {
                        Button("격자", systemImage: "square.grid.2x2") { log.tap("보기 전환") }
                        Button("정렬", systemImage: "arrow.up.arrow.down") { log.tap("정렬") }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Menu("더보기", systemImage: "ellipsis") {
                            Button("이름 변경", systemImage: "pencil") { log.tap("이름 변경") }
                            Divider()
                            Button("삭제", systemImage: "trash", role: .destructive) { log.tap("삭제") }
                        }
                    }
                } else {
                    ToolbarItemGroup(placement: .topBarTrailing) {
                        Button("삭제", systemImage: "trash") { log.tap("삭제 — 정렬과 한 세트로 보입니다") }
                        Button("정렬", systemImage: "arrow.up.arrow.down") { log.tap("정렬") }
                        Button("격자", systemImage: "square.grid.2x2") { log.tap("보기 전환") }
                    }
                }
            }
        }
        .demoToast(log)
    }
}

// MARK: - 8.1.4 가독성 > 미학

private struct LegibilityDemo: View {
    @State private var compliant = false
    @State private var backdrop = DemoBackdrop.photo

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 12) {
                    PrincipleToggleBar(
                        title: "가독성 > 미학",
                        violationText: "얇은 재료 + 가장자리 효과 없음. 밝은 배경에서 상단 버튼을 읽어보세요.",
                        complianceText: "hard 경계 + 두꺼운 재료. 재료감은 줄었지만 어느 배경에서도 읽힙니다.",
                        compliant: $compliant
                    )
                    DemoPicker(title: "배경", options: DemoBackdrop.allCases, label: \.rawValue, selection: $backdrop)
                        .demoChromeSafe()
                        .foregroundStyle(backdrop.contentColor)

                    ForEach(0..<16, id: \.self) { i in
                        HStack(spacing: 10) {
                            DemoPhoto(index: i).frame(width: 42, height: 42).clipShape(.rect(cornerRadius: 8))
                            Text("바 아래로 지나가는 항목 \(i + 1)")
                                .font(.subheadline)
                            Spacer()
                        }
                        .padding(10)
                        .background(.white.opacity(backdrop == .white ? 0.85 : 0.12), in: .rect(cornerRadius: 12))
                        .foregroundStyle(backdrop.contentColor)
                    }
                }
                .padding(16)
            }
            .background { backdrop.view.ignoresSafeArea() }
            .navigationTitle("갤러리")
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button("공유", systemImage: "square.and.arrow.up") {}
                    Button("선택", systemImage: "checkmark.circle") {}
                }
            }
            .modifier(LegibilityModifier(compliant: compliant))
        }
    }
}

private struct LegibilityModifier: ViewModifier {
    let compliant: Bool

    func body(content: Content) -> some View {
        if compliant {
            content
                .scrollEdgeEffectStyle(.hard, for: .top)
                .toolbarBackground(.thickMaterial, for: .navigationBar)
                .toolbarBackgroundVisibility(.visible, for: .navigationBar)
        } else {
            content.scrollEdgeEffectHidden(true, for: .top)
        }
    }
}

// MARK: - 8.1.5 공간은 계약, 텍스트는 가변

private struct ElasticTextDemo: View {
    @State private var compliant = false
    @State private var typeSize = DynamicTypeSize.large
    @State private var longNames = false

    private var rows: [(String, String)] {
        longNames
            ? [("김하늘하늘하늘 프로덕트 디자이너", DemoData.longTitle),
               ("Alexandra Konstantinopoulos", DemoData.longText),
               ("박도윤 · iOS 플랫폼 엔지니어링", DemoData.longTitle)]
            : [("김하늘", "스프린트 리뷰"), ("박도윤", "디자인 시안 v3"), ("이서연", "접근성 점검")]
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    PrincipleToggleBar(
                        title: "공간은 계약",
                        violationText: "고정 폭·한 줄 고정입니다. Dynamic Type을 키우면 **글자가 잘려 뜻이 사라집니다**.",
                        complianceText: "줄 수 범위와 공간 예약이 들어갔습니다. 커져도 무너지지 않고 이웃도 흔들리지 않습니다.",
                        compliant: $compliant
                    )

                    Toggle("긴 이름·긴 제목으로 바꾸기", isOn: $longNames.animation(.snappy))
                        .demoChromeSafe()

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Dynamic Type · \(typeSize.demoLabel)")
                            .font(.system(.caption, design: .monospaced, weight: .semibold))
                            .foregroundStyle(.secondary)
                        Slider(
                            value: Binding(
                                get: { Double(DynamicTypeSize.demoSteps.firstIndex(of: typeSize) ?? 3) },
                                set: { typeSize = DynamicTypeSize.demoSteps[Int($0.rounded())] }
                            ),
                            in: 0...Double(DynamicTypeSize.demoSteps.count - 1),
                            step: 1
                        )
                    }

                    Divider()

                    ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                        card(name: row.0, subject: row.1)
                    }
                    .dynamicTypeSize(typeSize)
                }
                .padding(16)
            }
            .navigationTitle("연락처")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func card(name: String, subject: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            DemoAvatar(initial: String(name.prefix(1)), size: 36)
            VStack(alignment: .leading, spacing: 3) {
                if compliant {
                    Text(name).font(.callout.weight(.semibold)).lineLimit(2)
                    Text(subject).font(.subheadline).foregroundStyle(.secondary)
                        .lineLimit(2, reservesSpace: true)
                } else {
                    Text(name).font(.callout.weight(.semibold)).lineLimit(1)
                    Text(subject).font(.subheadline).foregroundStyle(.secondary).lineLimit(1)
                }
            }
            .frame(width: compliant ? nil : 150, alignment: .leading)
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .frame(height: compliant ? nil : 74)
        .background(.quaternary.opacity(0.4), in: .rect(cornerRadius: 12))
    }
}

// MARK: - 8.1.6 데이터와 표기의 분리

private struct DataVsPresentationDemo: View {
    @State private var compliant = false
    @State private var english = false

    private var locale: Locale { Locale(identifier: english ? "en_US" : "ko_KR") }

    private var name: PersonNameComponents {
        var components = PersonNameComponents()
        components.givenName = english ? "Haneul" : "하늘"
        components.familyName = english ? "Kim" : "김"
        return components
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    PrincipleToggleBar(
                        title: "데이터와 표기의 분리",
                        violationText: "화면에 나갈 문자열을 앱이 직접 조립했습니다 — `\"\\(km)km\"`, `\"\\(family)\\(given)\"`.",
                        complianceText: "값만 들고 있다가 로케일에 맞춰 표기를 시스템에 맡깁니다.",
                        compliant: $compliant
                    )

                    Toggle("로케일을 en_US 로 바꾸기", isOn: $english.animation(.snappy))

                    row("거리", compliant
                        ? Measurement(value: 5, unit: UnitLength.kilometers)
                            .formatted(.measurement(width: .wide, usage: .road).locale(locale))
                        : "5km")

                    row("이름", compliant
                        ? name.formatted(.name(style: .medium).locale(locale))
                        : "김하늘")

                    row("날짜", compliant
                        ? Date(timeIntervalSince1970: 1_776_000_000)
                            .formatted(.dateTime.year().month(.wide).day().locale(locale))
                        : "2026년 4월 12일")

                    row("금액", compliant
                        ? Decimal(128_400).formatted(.currency(code: english ? "USD" : "KRW").locale(locale))
                        : "₩128,400")

                    DemoNote(text: compliant
                        ? "로케일을 바꾸면 **표기가 따라옵니다**. 앱 코드는 한 줄도 바뀌지 않았습니다."
                        : "로케일을 바꿔도 그대로입니다 — 표기를 앱이 이미 정해버렸기 때문입니다.")
                }
                .padding(18)
            }
            .navigationTitle("프로필")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func row(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .font(.footnote.weight(.bold))
                .foregroundStyle(.secondary)
                .frame(width: 44, alignment: .leading)
            Text(value)
                .font(.headline)
            Spacer()
        }
        .padding(12)
        .background(.quaternary.opacity(0.4), in: .rect(cornerRadius: 12))
    }
}

// MARK: - 8.1.7 직접 조작

private struct DirectManipulationDemo: View {
    @State private var compliant = false
    @State private var rows = DemoData.mail
    @State private var target: Int?
    @State private var log = DemoLog()

    var body: some View {
        NavigationStack {
            List {
                Section {
                    PrincipleToggleBar(
                        title: "직접 조작",
                        violationText: "삭제하려면 먼저 아래에서 **대상을 고르고**, 다시 위 메뉴에서 삭제를 눌러야 합니다.",
                        complianceText: "행을 왼쪽으로 밀거나 길게 누르면 됩니다. 액션이 대상 위에 붙어 있습니다.",
                        compliant: $compliant
                    )
                    .listRowInsets(.init(top: 8, leading: 12, bottom: 8, trailing: 12))

                    if !compliant {
                        Picker("대상 선택", selection: $target) {
                            Text("선택 안 함").tag(Int?.none)
                            ForEach(rows) { mail in
                                Text("\(mail.sender) · \(mail.subject)").tag(Int?.some(mail.id))
                            }
                        }
                    }
                    Button("원래대로 되돌리기") {
                        withAnimation { rows = DemoData.mail }
                    }
                }

                Section("받은 편지함") {
                    ForEach(rows) { mail in
                        DemoMailRow(mail: mail)
                            .modifier(DirectActions(enabled: compliant, mail: mail, onDelete: { remove(mail.id) }, log: log))
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("메일")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if !compliant {
                    ToolbarItem(placement: .topBarTrailing) {
                        Menu("작업", systemImage: "ellipsis") {
                            Button("선택한 항목 삭제", systemImage: "trash", role: .destructive) {
                                if let target { remove(target) } else { log.tap("먼저 대상을 골라야 합니다") }
                            }
                        }
                    }
                }
            }
        }
        .demoToast(log)
    }

    private func remove(_ id: Int) {
        withAnimation { rows.removeAll { $0.id == id } }
        target = nil
        log.tap("삭제했습니다")
    }
}

private struct DirectActions: ViewModifier {
    let enabled: Bool
    let mail: DemoMail
    let onDelete: () -> Void
    let log: DemoLog

    func body(content: Content) -> some View {
        if enabled {
            content
                .swipeActions(edge: .trailing) {
                    Button("삭제", systemImage: "trash", role: .destructive, action: onDelete)
                }
                .swipeActions(edge: .leading) {
                    Button("보관", systemImage: "archivebox") { log.tap("\(mail.sender) 보관") }
                        .tint(.blue)
                }
                .contextMenu {
                    Button("보관", systemImage: "archivebox") { log.tap("\(mail.sender) 보관") }
                    Divider()
                    Button("삭제", systemImage: "trash", role: .destructive, action: onDelete)
                }
        } else {
            content
        }
    }
}
