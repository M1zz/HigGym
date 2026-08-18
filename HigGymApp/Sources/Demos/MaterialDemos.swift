import SwiftUI

/// 6장 System Materials — 재료와 vibrancy.
/// 둘 다 **뒤에 무엇이 있느냐**가 전부이므로, 배경을 바꿔가며 같은 레이어를 관찰한다.
@MainActor
enum MaterialDemos {
    static let all: [EntryDemo] = [
        EntryDemo(
            "m1",
            hints: [
                "**재료 두께**를 ultraThin → thick 으로 올려보세요. 뒤가 비치는 정도가 달라집니다.",
                "배경을 **사진 · 흰색**으로 바꿔보세요 — 얇은 재료가 어디서 무너지는지 바로 보입니다.",
                "판단 기준은 취향이 아니라 \"이 배경에서 위의 글자가 읽히는가\"입니다(8.1.4).",
            ],
            code: """
            Text("읽혀야 하는 글자")
                .padding()
                .background(.regularMaterial, in: .rect(cornerRadius: 16))
            // .ultraThinMaterial · .thinMaterial · .regularMaterial
            // .thickMaterial · .ultraThickMaterial
            """
        ) { MaterialDemoScreen() },

        EntryDemo(
            "vb1",
            hints: [
                "스위치로 **vibrancy를 껐다 켜보세요** — 같은 회색인데 읽히는 정도가 다릅니다.",
                "배경을 밝게·어둡게 바꿔보세요. vibrancy 쪽만 배경을 따라 스스로 조정됩니다.",
                "직접 지정한 고정 회색은 어느 한 배경에서 반드시 깨집니다 — 그게 이 항목의 요지입니다.",
            ],
            code: """
            VStack {
                Text("제목").foregroundStyle(.primary)
                Text("보조 설명").foregroundStyle(.secondary)   // vibrancy
                Text("보조 설명").foregroundStyle(Color(white: 0.6))  // 고정 회색
            }
            .padding()
            .background(.regularMaterial, in: .rect(cornerRadius: 16))
            """
        ) { VibrancyDemoScreen() },
    ]
}

private enum DemoMaterial: String, CaseIterable, Identifiable {
    case ultraThin = "ultraThin", thin = "thin", regular = "regular", thick = "thick"
    var id: String { rawValue }

    var material: Material {
        switch self {
        case .ultraThin: .ultraThinMaterial
        case .thin:      .thinMaterial
        case .regular:   .regularMaterial
        case .thick:     .thickMaterial
        }
    }
}

private struct MaterialDemoScreen: View {
    @State private var thickness = DemoMaterial.regular
    @State private var backdrop = DemoBackdrop.photo

    var body: some View {
        ZStack {
            backdrop.view.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {
                    card

                    // 같은 배경 위에 네 두께를 나란히 — 차이는 비교할 때만 보인다.
                    VStack(spacing: 10) {
                        ForEach(DemoMaterial.allCases) { option in
                            HStack {
                                Text(option.rawValue)
                                    .font(.system(size: 13, weight: .semibold, design: .monospaced))
                                Spacer()
                                Text("이 글자가 읽히는가")
                                    .font(.system(size: 13))
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 12)
                            .background(option.material, in: .rect(cornerRadius: 14))
                        }
                    }

                    controls
                }
                .padding(18)
            }
        }
    }

    private var card: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("선택한 재료 · \(thickness.rawValue)")
                .font(.system(size: 18, weight: .bold))
            Text(DemoData.longText)
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(thickness.material, in: .rect(cornerRadius: 18))
        .animation(.snappy(duration: 0.2), value: thickness)
    }

    private var controls: some View {
        VStack(spacing: 12) {
            DemoPicker(title: "재료 두께", options: DemoMaterial.allCases, label: \.rawValue, selection: $thickness)
            DemoPicker(title: "배경", options: DemoBackdrop.allCases, label: \.rawValue, selection: $backdrop)
        }
        .padding(14)
        .demoChromeSafe()
        .background(.thickMaterial, in: .rect(cornerRadius: 16))
    }
}

private struct VibrancyDemoScreen: View {
    @State private var vibrancy = true
    @State private var backdrop = DemoBackdrop.photo

    var body: some View {
        ZStack {
            backdrop.view.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {
                    sample(title: "vibrancy 적용", vibrant: true)
                        .opacity(vibrancy ? 1 : 0.999)
                    sample(title: "고정 회색", vibrant: false)

                    VStack(spacing: 12) {
                        Toggle("두 카드 비교 강조", isOn: $vibrancy)
                        DemoPicker(title: "배경", options: DemoBackdrop.allCases, label: \.rawValue, selection: $backdrop)
                        DemoNote(text: "배경을 바꿔보면 **한쪽만** 따라옵니다. 색을 직접 박아 넣은 쪽은 배경 사정을 모릅니다.")
                    }
                    .padding(14)
                    .demoChromeSafe()
                    .background(.thickMaterial, in: .rect(cornerRadius: 16))
                }
                .padding(18)
            }
        }
    }

    private func sample(title: String, vibrant: Bool) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(title)
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundStyle(vibrant ? AnyShapeStyle(.tint) : AnyShapeStyle(Color(white: 0.55)))

            HStack(spacing: 10) {
                Image(systemName: "square.stack.3d.up")
                    .font(.system(size: 20))
                    .foregroundStyle(vibrant ? AnyShapeStyle(.primary) : AnyShapeStyle(Color(white: 0.85)))
                VStack(alignment: .leading, spacing: 3) {
                    Text("시스템 재료 위의 제목")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(vibrant ? AnyShapeStyle(.primary) : AnyShapeStyle(Color(white: 0.85)))
                    Text("보조 설명 — 배경색을 혼합해 렌더링되는지, 고정된 회색인지")
                        .font(.system(size: 12))
                        .foregroundStyle(vibrant ? AnyShapeStyle(.secondary) : AnyShapeStyle(Color(white: 0.6)))
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(.regularMaterial, in: .rect(cornerRadius: 18))
    }
}
