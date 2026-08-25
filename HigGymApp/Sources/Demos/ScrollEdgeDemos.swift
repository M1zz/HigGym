import SwiftUI

/// 1.3 Scroll Edge Effects — 콘텐츠가 떠 있는 유리 아래로 지나갈 때의 처리.
/// 판정은 **뒤에 무엇이 있느냐**로 갈리므로, 네 데모 모두 배경을 바꿔가며 볼 수 있게 했다.
@MainActor
enum ScrollEdgeDemos {
    static let all: [EntryDemo] = [
        EntryDemo(
            "s1",
            hints: [
                "스크롤해서 카드가 상단 바 아래로 들어가는 순간을 보세요 — 경계 없이 **번지듯** 사라집니다.",
                "화면 안 배경 전환기로 **흰 배경**을 골라보세요. 부드러운 페이드가 어디까지 버티는지 드러납니다.",
                "배경을 **사진**으로 바꾸면 밝은 부분에서 버튼이 흐려집니다 — 그때가 hard로 옮길 때입니다.",
            ],
            code: """
            ScrollView { /* 콘텐츠 */ }
                .scrollEdgeEffectStyle(.soft, for: .top)
            """
        ) { ScrollEdgeDemoScreen(style: .soft) },

        EntryDemo(
            "s2",
            hints: [
                "스크롤하면 바 아래로 **선명한 경계**가 생깁니다. 콘텐츠와 바가 딱 나뉩니다.",
                "1.3.1(Soft)과 번갈아 열어 같은 배경에서 비교해 보세요.",
                "밝은 사진 배경에서 특히 유리합니다 — 대비를 배경에 맡기지 않고 스스로 만들기 때문입니다.",
            ],
            code: """
            ScrollView { /* 콘텐츠 */ }
                .scrollEdgeEffectStyle(.hard, for: .top)
            """
        ) { ScrollEdgeDemoScreen(style: .hard) },

        EntryDemo(
            "s3",
            hints: [
                "hard 경계 + **두꺼운 재료** 배경입니다. 바 뒤가 거의 비치지 않습니다.",
                "배경을 흰색·사진으로 바꿔도 버튼 대비가 흔들리지 않는지 확인해 보세요.",
                "그만큼 \"떠 있는 유리\" 느낌은 줄어듭니다 — 가독성과 재료감을 맞바꾼 구성입니다(8.1.4).",
            ],
            code: """
            ScrollView { /* 콘텐츠 */ }
                .scrollEdgeEffectStyle(.hard, for: .top)
                .toolbarBackground(.thickMaterial, for: .navigationBar)
                .toolbarBackgroundVisibility(.visible, for: .navigationBar)
            """
        ) { ScrollEdgeDemoScreen(style: .hardThick) },

        EntryDemo(
            "s4",
            hints: [
                "효과가 없습니다 — 콘텐츠가 **아무 처리 없이** 바 밑을 그대로 지나갑니다.",
                "배경을 **사진**으로 바꾸고 밝은 부분이 버튼 뒤로 지나가게 해보세요. 무엇이 문제인지 바로 보입니다.",
                "쓸 수 있는 경우는 콘텐츠가 바 아래로 절대 지나가지 않을 때뿐입니다.",
            ],
            code: """
            ScrollView { /* 콘텐츠 */ }
                .scrollEdgeEffectHidden(true, for: .top)
            """
        ) { ScrollEdgeDemoScreen(style: .hidden) },
    ]
}

private struct ScrollEdgeDemoScreen: View {
    enum Style { case soft, hard, hardThick, hidden }

    let style: Style
    @State private var backdrop = DemoBackdrop.photo
    @State private var log = DemoLog()

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 12) {
                    DemoPicker(title: "배경", options: DemoBackdrop.allCases, label: \.rawValue, selection: $backdrop)
                        .demoChromeSafe()
                        .padding(.bottom, 4)
                        .foregroundStyle(backdrop.contentColor)

                    ForEach(0..<18, id: \.self) { i in
                        card(i)
                    }
                }
                .padding(16)
            }
            .background { backdrop.view.ignoresSafeArea() }
            .navigationTitle("갤러리")
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button("공유", systemImage: "square.and.arrow.up") { log.tap("공유") }
                    Button("선택", systemImage: "checkmark.circle") { log.tap("선택 모드") }
                }
            }
            .modifier(EdgeStyleModifier(style: style))
        }
        .demoToast(log)
    }

    private func card(_ i: Int) -> some View {
        HStack(spacing: 12) {
            DemoPhoto(index: i)
                .frame(width: 46, height: 46)
                .clipShape(.rect(cornerRadius: 9))
            VStack(alignment: .leading, spacing: 3) {
                Text("항목 \(i + 1)").font(.subheadline.weight(.semibold))
                Text("바 뒤로 지나가는 콘텐츠").font(.footnote).opacity(0.75)
            }
            Spacer()
        }
        .padding(12)
        .background(.white.opacity(backdrop == .white ? 0.9 : 0.14), in: .rect(cornerRadius: 12))
        .foregroundStyle(backdrop.contentColor)
    }
}

private struct EdgeStyleModifier: ViewModifier {
    let style: ScrollEdgeDemoScreen.Style

    func body(content: Content) -> some View {
        switch style {
        case .soft:
            content.scrollEdgeEffectStyle(.soft, for: .top)
        case .hard:
            content.scrollEdgeEffectStyle(.hard, for: .top)
        case .hardThick:
            content
                .scrollEdgeEffectStyle(.hard, for: .top)
                .toolbarBackground(.thickMaterial, for: .navigationBar)
                .toolbarBackgroundVisibility(.visible, for: .navigationBar)
        case .hidden:
            content.scrollEdgeEffectHidden(true, for: .top)
        }
    }
}
