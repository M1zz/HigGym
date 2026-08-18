import SwiftUI

/// 2.1 Text Behavior · 2.2 Text Formatting —
/// 텍스트 항목은 **폭을 줄여봐야** 배운다. 그래서 모든 데모에 폭 슬라이더와 Dynamic Type 조절을 붙였다.
@MainActor
enum TextDemos {
    static let all: [EntryDemo] = [
        EntryDemo(
            "x1",
            hints: [
                "**폭 슬라이더**를 줄여보세요 — 정해진 줄 수를 넘는 순간 뒤가 …로 접힙니다.",
                "줄 수를 1 → 3으로 올려보며, 어느 줄 수에서 뜻이 통하는지 판단해 보세요.",
                "**Dynamic Type**을 키우면 같은 폭에서 더 빨리 잘립니다. 잘림은 폰트 크기의 함수이기도 합니다.",
            ],
            code: """
            Text(body)
                .lineLimit(limit)
            """
        ) { LineLimitDemo() },

        EntryDemo(
            "x2",
            hints: [
                "**tail · middle · head**를 바꿔가며 같은 경로를 보세요.",
                "파일 경로에서는 middle이 이깁니다 — 앞(위치)과 뒤(파일명) 둘 다 살아남기 때문입니다.",
                "아래 이름·주소 예시에서는 어느 쪽이 맞는지 직접 골라보세요. 정답은 \"무엇이 식별에 쓰이는가\"입니다.",
            ],
            code: """
            Text(path)
                .lineLimit(1)
                .truncationMode(.middle)
            """
        ) { TruncationDemo() },

        EntryDemo(
            "x3",
            hints: [
                "폭을 줄여보세요 — 자르는 대신 **글자가 작아집니다**.",
                "축소 한계를 0.3까지 낮추면 어디까지 읽히는지 확인해 보세요. 읽히지 않으면 축소는 실패입니다.",
                "긴 문장으로 바꿔보면 왜 이 도구가 **짧고 반드시 다 보여야 하는 값**(금액·수치) 전용인지 드러납니다.",
            ],
            code: """
            Text(amount)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            """
        ) { ScaleToFitDemo() },

        EntryDemo(
            "x4",
            hints: [
                "**공간 예약**을 껐다 켜보세요 — 목록의 행 높이가 들썩이는지, 고정되는지 보입니다.",
                "짧은 글·긴 글 전환을 몇 번 반복해 보세요. 예약이 없으면 이웃 행까지 밀립니다.",
                "범위(2...4)는 최소도 정합니다 — 최소를 정한다는 건 레이아웃과의 계약입니다(8.1.5).",
            ],
            code: """
            Text(body)
                .lineLimit(2...4)

            Text(subtitle)
                .lineLimit(3, reservesSpace: true)   // 짧아도 3줄만큼 자리를 잡아둔다
            """
        ) { LineLimitRangeDemo() },

        EntryDemo(
            "x5",
            hints: [
                "아래 문단을 **길게 눌러** 보세요 — 선택·복사가 됩니다.",
                "스위치를 끄면 같은 문단이 선택되지 않습니다. 차이를 직접 느껴보세요.",
                "코드·주소·인증번호처럼 **옮겨 적을 일이 있는 텍스트**에는 켜는 편이 맞습니다.",
            ],
            code: """
            Text(code)
                .textSelection(.enabled)
            """
        ) { TextSelectionDemo() },

        EntryDemo(
            "f1",
            hints: [
                "**로케일**을 en_US로 바꿔보세요 — 5 km가 mi로 바뀝니다. 값은 그대로입니다.",
                "너비를 wide · abbreviated · narrow로 바꿔가며 같은 값의 표기 차이를 보세요.",
                "직접 \"km\"를 문자열로 붙였다면 이 전환은 전부 수동 작업이 됐을 겁니다 — 8.1.6.",
            ],
            code: """
            let distance = Measurement(value: 5, unit: UnitLength.kilometers)

            Text(distance.formatted(
                .measurement(width: .wide, usage: .road).locale(locale)
            ))
            """
        ) { MeasurementFormatDemo() },

        EntryDemo(
            "f2",
            hints: [
                "로케일을 ko_KR ↔ en_US로 바꿔보세요 — **성과 이름의 순서**가 뒤집힙니다.",
                "스타일을 abbreviated로 바꾸면 이니셜만 남습니다. 아바타에 쓰는 그 값입니다.",
                "이름을 한 문자열로 저장했다면 이 중 어느 것도 불가능했을 겁니다.",
            ],
            code: """
            var name = PersonNameComponents()
            name.givenName = "하늘"
            name.familyName = "김"

            Text(name.formatted(.name(style: style).locale(locale)))
            """
        ) { NameFormatDemo() },
    ]
}

// MARK: - 공통 조작 장치

/// 텍스트 데모의 공통 껍데기 — 폭·Dynamic Type을 손에 쥐여준다.
private struct TextDemoScaffold<Controls: View, Sample: View>: View {
    let title: String
    var showWidth = true
    var showTypeSize = true
    @Binding var width: CGFloat
    @Binding var typeSize: DynamicTypeSize
    @ViewBuilder var controls: Controls
    @ViewBuilder var sample: Sample

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    VStack(alignment: .leading, spacing: 10) {
                        sample
                            .frame(width: width, alignment: .leading)
                            .padding(12)
                            .background(.quaternary.opacity(0.45), in: .rect(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .strokeBorder(.tint.opacity(0.35), style: .init(lineWidth: 1, dash: [4, 3]))
                            )
                            .dynamicTypeSize(typeSize)
                            .animation(.snappy(duration: 0.2), value: width)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    Divider()

                    VStack(alignment: .leading, spacing: 14) {
                        controls

                        if showWidth {
                            labeled("폭 \(Int(width))pt") {
                                Slider(value: $width, in: 110...340)
                            }
                        }
                        if showTypeSize {
                            labeled("Dynamic Type · \(typeSize.demoLabel)") {
                                Slider(
                                    value: Binding(
                                        get: { Double(DynamicTypeSize.demoSteps.firstIndex(of: typeSize) ?? 2) },
                                        set: { typeSize = DynamicTypeSize.demoSteps[Int($0.rounded())] }
                                    ),
                                    in: 0...Double(DynamicTypeSize.demoSteps.count - 1),
                                    step: 1
                                )
                            }
                        }
                    }
                }
                .padding(18)
                .demoChromeSafe()
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func labeled<V: View>(_ label: String, @ViewBuilder content: () -> V) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                .foregroundStyle(.secondary)
            content()
        }
    }
}

extension DynamicTypeSize {
    static let demoSteps: [DynamicTypeSize] = [.xSmall, .small, .medium, .large, .xLarge, .xxLarge, .xxxLarge, .accessibility1, .accessibility3, .accessibility5]

    var demoLabel: String {
        switch self {
        case .xSmall: "xSmall"
        case .small: "small"
        case .medium: "medium"
        case .large: "large(기본)"
        case .xLarge: "xLarge"
        case .xxLarge: "xxLarge"
        case .xxxLarge: "xxxLarge"
        case .accessibility1: "접근성 1"
        case .accessibility2: "접근성 2"
        case .accessibility3: "접근성 3"
        case .accessibility4: "접근성 4"
        case .accessibility5: "접근성 5"
        @unknown default: "기본"
        }
    }
}

// MARK: - 2.1.1 Line Limit

private struct LineLimitDemo: View {
    @State private var width: CGFloat = 240
    @State private var typeSize = DynamicTypeSize.large
    @State private var limit = 2

    var body: some View {
        TextDemoScaffold(title: "Line Limit", width: $width, typeSize: $typeSize) {
            Stepper("줄 수 제한 \(limit)줄", value: $limit, in: 1...5)
            DemoNote(text: "제한을 넘는 내용은 사라집니다. **몇 줄이면 뜻이 통하는가**가 이 값을 정하는 기준입니다.")
        } sample: {
            Text(DemoData.longText)
                .font(.system(size: 14))
                .lineLimit(limit)
        }
    }
}

// MARK: - 2.1.2 Truncation

private struct TruncationDemo: View {
    private enum Sample: String, CaseIterable, Identifiable {
        case path = "파일 경로", name = "긴 제목", url = "주소"
        var id: String { rawValue }

        var text: String {
            switch self {
            case .path: DemoData.filePath
            case .name: DemoData.longTitle
            case .url:  "https://developer.apple.com/design/human-interface-guidelines/toolbars"
            }
        }
    }

    @State private var width: CGFloat = 240
    @State private var typeSize = DynamicTypeSize.large
    @State private var mode = Text.TruncationMode.middle
    @State private var sample = Sample.path

    var body: some View {
        TextDemoScaffold(title: "Truncation", width: $width, typeSize: $typeSize) {
            VStack(alignment: .leading, spacing: 6) {
                Text("잘리는 자리").font(.system(size: 11, weight: .bold)).foregroundStyle(.secondary)
                Picker("모드", selection: $mode) {
                    Text("head").tag(Text.TruncationMode.head)
                    Text("middle").tag(Text.TruncationMode.middle)
                    Text("tail").tag(Text.TruncationMode.tail)
                }
                .pickerStyle(.segmented)
            }
            DemoPicker(title: "예시", options: Sample.allCases, label: \.rawValue, selection: $sample)
            DemoNote(text: "정답은 취향이 아니라 **무엇이 식별에 쓰이는가**입니다. 경로는 끝(파일명)이, 제목은 앞이 결정적입니다.")
        } sample: {
            Text(sample.text)
                .font(.system(size: 14, design: sample == .path ? .monospaced : .default))
                .lineLimit(1)
                .truncationMode(mode)
        }
    }
}

// MARK: - 2.1.3 Scale to Fit

private struct ScaleToFitDemo: View {
    @State private var width: CGFloat = 200
    @State private var typeSize = DynamicTypeSize.large
    @State private var factor: Double = 0.5
    @State private var long = false

    var body: some View {
        TextDemoScaffold(title: "Scale to Fit", width: $width, typeSize: $typeSize) {
            VStack(alignment: .leading, spacing: 2) {
                Text("minimumScaleFactor \(factor, specifier: "%.2f")")
                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
                    .foregroundStyle(.secondary)
                Slider(value: $factor, in: 0.3...1.0)
            }
            Toggle("긴 문장으로 바꾸기", isOn: $long.animation(.snappy))
            DemoNote(text: long
                ? "문장에 쓰면 이렇게 됩니다 — 다 보이긴 하지만 **읽히지 않습니다**. 가독성이 미학을 이깁니다(8.1.4)."
                : "짧고 반드시 다 보여야 하는 값에는 축소가 맞습니다 — 금액·수치·코드.")
        } sample: {
            Text(long ? DemoData.longText : "₩1,284,000")
                .font(.system(size: 28, weight: .semibold))
                .lineLimit(1)
                .minimumScaleFactor(factor)
        }
    }
}

// MARK: - 2.1.4 범위 · 공간 예약

private struct LineLimitRangeDemo: View {
    @State private var width: CGFloat = 300
    @State private var typeSize = DynamicTypeSize.large
    @State private var reserve = true
    @State private var short = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Toggle("공간 예약 (reservesSpace)", isOn: $reserve.animation(.snappy))
                    Toggle("짧은 글로 바꾸기", isOn: $short.animation(.snappy))
                    DemoNote(text: reserve
                        ? "예약이 켜져 있어 글이 짧아져도 **행 높이가 그대로**입니다. 이웃이 흔들리지 않습니다."
                        : "예약이 꺼져 있어 글 길이에 따라 **행 높이가 들썩입니다**. 목록에서 특히 산만합니다.")

                    Divider()

                    ForEach(0..<4, id: \.self) { i in
                        VStack(alignment: .leading, spacing: 4) {
                            Text("카드 \(i + 1)").font(.system(size: 14, weight: .semibold))
                            Text(short ? "한 줄." : DemoData.longText)
                                .font(.system(size: 13))
                                .foregroundStyle(.secondary)
                                .modifier(RangeLimit(reserve: reserve))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(12)
                        .background(.quaternary.opacity(0.4), in: .rect(cornerRadius: 12))
                    }
                }
                .padding(18)
                .demoChromeSafe()
                .dynamicTypeSize(typeSize)
                .animation(.snappy(duration: 0.2), value: short)
            }
            .navigationTitle("Line Limit 범위")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

private struct RangeLimit: ViewModifier {
    let reserve: Bool

    func body(content: Content) -> some View {
        if reserve {
            content.lineLimit(3, reservesSpace: true)
        } else {
            content.lineLimit(2...4)
        }
    }
}

// MARK: - 2.1.5 Text Selection

private struct TextSelectionDemo: View {
    @State private var enabled = true

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Toggle("텍스트 선택 허용", isOn: $enabled)
                    DemoNote(text: "아래 상자를 **길게 눌러** 보세요. 스위치를 끄면 같은 동작이 통하지 않습니다.", symbol: "hand.tap")

                    VStack(alignment: .leading, spacing: 8) {
                        Text("인증 코드")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(.secondary)
                        Text("HG-2026-4F7K-9QX2")
                            .font(.system(size: 20, weight: .semibold, design: .monospaced))
                        Text(DemoData.longText)
                            .font(.system(size: 13))
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(14)
                    .background(.quaternary.opacity(0.45), in: .rect(cornerRadius: 12))
                    .modifier(SelectionModifier(enabled: enabled))
                }
                .padding(18)
                .demoChromeSafe()
            }
            .navigationTitle("Text Selection")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

private struct SelectionModifier: ViewModifier {
    let enabled: Bool

    func body(content: Content) -> some View {
        if enabled {
            content.textSelection(.enabled)
        } else {
            content.textSelection(.disabled)
        }
    }
}

// MARK: - 2.2.1 Measurement

private struct DemoLocale: Hashable, Identifiable {
    let id: String
    let label: String
    var locale: Locale { Locale(identifier: id) }

    static let all: [DemoLocale] = [
        .init(id: "ko_KR", label: "ko_KR"),
        .init(id: "en_US", label: "en_US"),
        .init(id: "ja_JP", label: "ja_JP"),
    ]
}

private struct MeasurementFormatDemo: View {
    @State private var value: Double = 5
    @State private var width = Measurement<UnitLength>.FormatStyle.UnitWidth.wide
    @State private var locale = DemoLocale.all[0]

    private var distance: Measurement<UnitLength> {
        Measurement(value: value, unit: .kilometers)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("앱이 들고 있는 값")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(.secondary)
                        Text("Measurement(value: \(value, specifier: "%.1f"), unit: .kilometers)")
                            .font(.system(size: 12, design: .monospaced))
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("화면에 나가는 표기")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(.tint)
                        Text(distance.formatted(.measurement(width: width, usage: .road).locale(locale.locale)))
                            .font(.system(size: 30, weight: .semibold))
                            .contentTransition(.numericText())
                            .animation(.snappy, value: value)
                    }

                    Divider()

                    VStack(alignment: .leading, spacing: 2) {
                        Text("값 \(value, specifier: "%.1f") km")
                            .font(.system(size: 11, weight: .semibold, design: .monospaced))
                            .foregroundStyle(.secondary)
                        Slider(value: $value, in: 0.1...42)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("너비").font(.system(size: 11, weight: .bold)).foregroundStyle(.secondary)
                        Picker("너비", selection: $width) {
                            Text("wide").tag(Measurement<UnitLength>.FormatStyle.UnitWidth.wide)
                            Text("abbreviated").tag(Measurement<UnitLength>.FormatStyle.UnitWidth.abbreviated)
                            Text("narrow").tag(Measurement<UnitLength>.FormatStyle.UnitWidth.narrow)
                        }
                        .pickerStyle(.segmented)
                    }

                    DemoPicker(title: "로케일", options: DemoLocale.all, label: \.label, selection: $locale)

                    DemoNote(text: "로케일을 en_US로 바꾸면 **단위계 자체가 바뀝니다**(km → mi). 앱은 값만 들고 있으면 됩니다.")
                }
                .padding(18)
                .demoChromeSafe()
            }
            .navigationTitle("Format Styles")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - 2.2.2 이름 표기

private struct NameFormatDemo: View {
    @State private var style = PersonNameComponents.FormatStyle.Style.medium
    @State private var locale = DemoLocale.all[0]

    private var name: PersonNameComponents {
        var components = PersonNameComponents()
        components.givenName = locale.id == "ko_KR" ? "하늘" : "Haneul"
        components.familyName = locale.id == "ko_KR" ? "김" : "Kim"
        components.nickname = locale.id == "ko_KR" ? "하니" : "Hani"
        return components
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("앱이 들고 있는 값")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(.secondary)
                        Text("givenName: \(name.givenName ?? "") · familyName: \(name.familyName ?? "")")
                            .font(.system(size: 12, design: .monospaced))
                    }

                    HStack(spacing: 12) {
                        DemoAvatar(
                            initial: name.formatted(.name(style: .abbreviated).locale(locale.locale)),
                            size: 46
                        )
                        VStack(alignment: .leading, spacing: 3) {
                            Text("화면에 나가는 표기")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(.tint)
                            Text(name.formatted(.name(style: style).locale(locale.locale)))
                                .font(.system(size: 24, weight: .semibold))
                        }
                    }

                    Divider()

                    VStack(alignment: .leading, spacing: 6) {
                        Text("스타일").font(.system(size: 11, weight: .bold)).foregroundStyle(.secondary)
                        Picker("스타일", selection: $style) {
                            Text("short").tag(PersonNameComponents.FormatStyle.Style.short)
                            Text("medium").tag(PersonNameComponents.FormatStyle.Style.medium)
                            Text("long").tag(PersonNameComponents.FormatStyle.Style.long)
                            Text("abbrev.").tag(PersonNameComponents.FormatStyle.Style.abbreviated)
                        }
                        .pickerStyle(.segmented)
                    }

                    DemoPicker(title: "로케일", options: DemoLocale.all, label: \.label, selection: $locale)

                    DemoNote(text: "ko_KR은 **성 → 이름**, en_US는 **이름 → 성**. 순서를 앱이 정하지 않는다는 게 요지입니다.")
                }
                .padding(18)
                .demoChromeSafe()
            }
            .navigationTitle("Name Formatting")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
