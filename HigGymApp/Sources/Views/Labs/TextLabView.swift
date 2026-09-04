import SwiftUI
import UIKit

/// 2.1 Text Behavior 의 판단 기준은 "잘려도 뜻이 통하는가?" —
/// 그래서 샘플마다 문장인지 값인지를 먼저 규정한다.
enum TextSample: String, CaseIterable, Identifiable {
    case sentence, amount, timer, path, name
    var id: String { rawValue }

    var label: String {
        switch self {
        case .sentence: "본문"
        case .amount:   "금액"
        case .timer:    "타이머"
        case .path:     "경로"
        case .name:     "이름"
        }
    }

    var text: String {
        switch self {
        case .sentence: "회의 일정이 다음 주 화요일 오후 3시로 변경되었습니다. 준비 자료는 미리 공유 부탁드립니다."
        case .amount:   "₩1,234,000"
        case .timer:    "12:34:56"
        case .path:     "/Users/designer/Documents/Projects/2026/Toolbar/report.pdf"
        case .name:     "홍길동"
        }
    }

    /// 잘려도 앞부분으로 뜻이 통하는 "문장"인가, 잘리면 정보가 파괴되는 "값"인가.
    var isSentence: Bool { self == .sentence }

    var semantics: String {
        switch self {
        case .sentence: "문장 — 잘려도 앞부분으로 뜻이 통한다"
        case .amount:   "값 — 잘리면 틀린 금액이 된다"
        case .timer:    "값 — 잘리면 다른 시간이 된다"
        case .path:     "값 — 정보 가치가 양 끝에 있다"
        case .name:     "값 — 표기 규칙이 문화권마다 다르다"
        }
    }
}

enum TruncationOption: String, CaseIterable, Identifiable {
    case tail, middle, head
    var id: String { rawValue }
    var label: String {
        switch self {
        case .tail:   ".tail"
        case .middle: ".middle"
        case .head:   ".head"
        }
    }
    var mode: Text.TruncationMode {
        switch self {
        case .tail:   .tail
        case .middle: .middle
        case .head:   .head
        }
    }
}

struct TextLabView: View {
    @State private var sample: TextSample = .amount
    @State private var width: CGFloat = 200
    @State private var lineLimit = 1
    @State private var reservesSpace = false
    @State private var truncation: TruncationOption = .tail
    @State private var scaleFactor: Double = 1.0
    @State private var typeSize: DynamicTypeSize = .large

    var body: some View {
        LabScaffold(title: "텍스트 잘림·축소", subtitle: "잘려도 뜻이 통하는가") {
                preview
                semanticsCard
                controls
                diagnosisSection
                FormatStyleSection()
                CodePanel(code: code)
        }
    }

    // MARK: 실제 Text 로 그리는 미리보기

    private var preview: some View {
        VStack(spacing: 10) {
            Text("실제 렌더링")
                .font(.caption.weight(.bold))
                .foregroundStyle(.hgDim)
                .frame(maxWidth: .infinity, alignment: .leading)

            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [4, 3]))
                    .foregroundStyle(reservesSpace ? Color.hgAccent : Color.hgLine)

                Text(sample.text)
                    .lineLimit(lineLimit, reservesSpace: reservesSpace)
                    .truncationMode(truncation.mode)
                    .minimumScaleFactor(scaleFactor)
                    .padding(10)
            }
            .frame(width: width)
            .dynamicTypeSize(typeSize)
            .animation(.snappy(duration: 0.2), value: width)

            Text("폭 \(Int(width))pt · Dynamic Type \(typeSizeLabel)")
                .font(.system(.caption, design: .monospaced))
                .foregroundStyle(.hgDim)
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(Color.hgCard, in: .rect(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(Color.hgLine, lineWidth: 1))
    }

    private var semanticsCard: some View {
        HStack(spacing: 10) {
            Image(systemName: sample.isSentence ? "text.alignleft" : "number")
                .foregroundStyle(sample.isSentence ? .hgGreen : .hgAmber)
            Text(sample.semantics)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.hgText)
            Spacer()
        }
        .padding(12)
        .background((sample.isSentence ? Color.hgGreen : Color.hgAmber).opacity(0.08), in: .rect(cornerRadius: 12))
    }

    // MARK: 컨트롤

    private var controls: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionLabel("무엇을 넣는가", accent: .hgAmber)
            Picker("샘플", selection: $sample) {
                ForEach(TextSample.allCases) { Text($0.label).tag($0) }
            }
            .pickerStyle(.segmented)

            SectionLabel("공간", accent: .hgAccent)
            VStack(alignment: .leading, spacing: 4) {
                Text("폭 \(Int(width))pt")
                    .font(.system(.footnote, design: .monospaced))
                    .foregroundStyle(.hgMuted)
                Slider(value: $width, in: 90...340, step: 1)
                    .tint(.hgAccent)
            }

            Stepper("lineLimit \(lineLimit)", value: $lineLimit, in: 1...4)
                .font(.subheadline)
                .foregroundStyle(.hgText)

            Toggle("reservesSpace — 짧아도 높이 유지", isOn: $reservesSpace)
                .font(.subheadline)
                .foregroundStyle(.hgText)
                .tint(.hgAccent)

            SectionLabel("넘칠 때의 처리", accent: .hgAccent)
            Picker("truncation", selection: $truncation) {
                ForEach(TruncationOption.allCases) { Text($0.label).tag($0) }
            }
            .pickerStyle(.segmented)

            VStack(alignment: .leading, spacing: 4) {
                Text("minimumScaleFactor \(scaleFactor, format: .number.precision(.fractionLength(2)))")
                    .font(.system(.footnote, design: .monospaced))
                    .foregroundStyle(.hgMuted)
                Slider(value: $scaleFactor, in: 0.3...1.0, step: 0.05)
                    .tint(.hgAccent)
            }

            SectionLabel("접근성", accent: .hgGreen)
            Picker("Dynamic Type", selection: $typeSize) {
                Text("기본").tag(DynamicTypeSize.large)
                Text("XXL").tag(DynamicTypeSize.xxLarge)
                Text("접근성 최대").tag(DynamicTypeSize.accessibility5)
            }
            .pickerStyle(.segmented)
        }
    }

    private var typeSizeLabel: String {
        switch typeSize {
        case .accessibility5: "접근성 최대"
        case .xxLarge:        "XXL"
        default:              "기본"
        }
    }

    // MARK: 판정 — 8.1.5 공간은 계약, 텍스트는 가변

    private var overflows: Bool {
        TextMetrics.overflows(
            sample.text,
            width: width - 20,       // 좌우 padding 제외
            lines: lineLimit,
            typeSize: typeSize
        )
    }

    private var diagnoses: [Diagnosis] {
        var out: [Diagnosis] = []
        let scaling = scaleFactor < 1.0

        if overflows && !sample.isSentence && !scaling {
            out.append(.init(
                level: .violation,
                message: "**\(sample.label)**은(는) 잘리는 순간 정보가 파괴되는 “값”인데 지금 잘리고 있습니다. “₩1,234,0…”은 뜻이 통하는 게 아니라 **틀린 값**을 보여주는 것입니다 — minimumScaleFactor로 줄이세요.",
                source: "2.1.3 · 8.1.5"
            ))
        }

        if overflows && sample.isSentence && lineLimit >= 2 {
            out.append(.init(
                level: .good,
                message: "본문은 문장이라 잘려도 앞부분으로 뜻이 통하고, 전문은 상세 화면이 담당합니다. 목록의 목적(훑기)에 맞게 높이를 계약으로 고정한 정석입니다.",
                source: "2.1.1"
            ))
        }

        if sample == .path && truncation != .middle && overflows {
            out.append(.init(
                level: .violation,
                message: "경로는 앞이 공통 접두사라 앞만 보이면 항목을 구분할 수 없습니다. 정보 가치가 양 끝에 있으니 **.middle**로 가운데를 접어야 합니다.",
                source: "2.1.2"
            ))
        } else if sample == .path && truncation == .middle {
            out.append(.init(
                level: .good,
                message: "가운데를 접어 양 끝(루트와 파일명)을 남겼습니다 — 정보 가치가 있는 쪽을 보존하는 선택입니다.",
                source: "2.1.2"
            ))
        }

        if scaleFactor < 0.5 {
            out.append(.init(
                level: .violation,
                message: "절반 이하로 줄여야 들어간다면 축소가 아니라 **설계 문제**입니다. 폭을 늘리거나 표기 자체를 줄이세요(1,234,000 → 1.2M). 잘림·축소는 안전장치이지 레이아웃 수단이 아닙니다.",
                source: "8.1.5"
            ))
        } else if scaling && !sample.isSentence {
            out.append(.init(
                level: .good,
                message: "값 타입에 축소를 적용했습니다 — 자르지 않고 줄여 정보를 보존하는 올바른 선택입니다.",
                source: "2.1.3"
            ))
        }

        if scaling && sample.isSentence {
            out.append(.init(
                level: .caution,
                message: "문장에 축소를 걸면 글자만 작아지고 읽기는 더 어려워집니다. 문장은 자르거나(truncation) 줄 수를 늘리는 쪽이 맞습니다.",
                source: "2.1.1 · 2.1.3"
            ))
        }

        if reservesSpace && lineLimit >= 2 {
            out.append(.init(
                level: .caution,
                message: "공간 예약의 목적은 **그리드·가로 카드의 균일성**입니다. 균일성이 필요 없는 세로 목록에 걸면 짧은 셀마다 빈 공간만 상시 소모합니다.",
                source: "2.1.4"
            ))
        }

        if typeSize == .accessibility5 && overflows {
            out.append(.init(
                level: .violation,
                message: "접근성 최대 글씨에서 내용이 잘립니다. 기본 크기에서만 확인하고 넘어가면 이 상태가 그대로 출시됩니다 — 검증 기준은 가장 나쁜 조건입니다.",
                source: "2.1.1 · 8.1.4"
            ))
        }

        if out.isEmpty {
            out.append(.init(
                level: .good,
                message: "지금 폭에서는 내용이 온전히 들어갑니다. 폭을 줄이거나 Dynamic Type을 키워 한계 조건을 만들어보세요.",
                source: "8.1.5"
            ))
        }

        return out.sorted { $0.level > $1.level }
    }

    private var diagnosisSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                SectionLabel("실시간 판정", accent: .hgGreen)
                Spacer()
                Pill(text: overflows ? "넘침" : "들어감", color: overflows ? .hgRed : .hgGreen)
            }
            ForEach(diagnoses) { DiagnosisRow(diagnosis: $0) }
        }
    }

    private var code: String {
        var lines = ["Text(\"\(sample.text.prefix(24))\(sample.text.count > 24 ? "…" : "")\")"]
        lines.append(reservesSpace
            ? "    .lineLimit(\(lineLimit), reservesSpace: true)"
            : "    .lineLimit(\(lineLimit))")
        if truncation != .tail {
            lines.append("    .truncationMode(\(truncation.label))")
        }
        if scaleFactor < 1.0 {
            lines.append("    .minimumScaleFactor(\(String(format: "%.2f", scaleFactor)))")
        }
        lines.append("    .frame(width: \(Int(width)))")
        return lines.joined(separator: "\n")
    }
}

// MARK: - 실제로 잘리는지 재본다

enum TextMetrics {
    static func overflows(_ text: String, width: CGFloat, lines: Int, typeSize: DynamicTypeSize) -> Bool {
        guard width > 0 else { return true }
        let font = UIFont.preferredFont(
            forTextStyle: .body,
            compatibleWith: UITraitCollection(preferredContentSizeCategory: category(for: typeSize))
        )
        let attributes: [NSAttributedString.Key: Any] = [.font: font]

        // 한 줄이면 폭만 재는 편이 정확하다 — 높이는 폰트별 line spacing 때문에
        // lineHeight 와 딱 떨어지지 않아 멀쩡한 텍스트도 넘침으로 잡힌다.
        if lines <= 1 {
            return (text as NSString).size(withAttributes: attributes).width > width + 0.5
        }

        let bounds = (text as NSString).boundingRect(
            with: CGSize(width: width, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: attributes,
            context: nil
        )
        let usedLines = Int(ceil(bounds.height / font.lineHeight - 0.01))
        return usedLines > lines
    }

    private static func category(for size: DynamicTypeSize) -> UIContentSizeCategory {
        switch size {
        case .xSmall:          .extraSmall
        case .small:           .small
        case .medium:          .medium
        case .large:           .large
        case .xLarge:          .extraLarge
        case .xxLarge:         .extraExtraLarge
        case .xxxLarge:        .extraExtraExtraLarge
        case .accessibility1:  .accessibilityMedium
        case .accessibility2:  .accessibilityLarge
        case .accessibility3:  .accessibilityExtraLarge
        case .accessibility4:  .accessibilityExtraExtraLarge
        case .accessibility5:  .accessibilityExtraExtraExtraLarge
        @unknown default:      .large
        }
    }
}

// MARK: - 2.2 데이터와 표기의 분리

private struct FormatStyleSection: View {
    @State private var isUS = false

    private var locale: Locale { isUS ? Locale(identifier: "en_US") : Locale(identifier: "ko_KR") }

    private var distance: String {
        Measurement(value: 5, unit: UnitLength.kilometers)
            .formatted(.measurement(width: .abbreviated).locale(locale))
    }

    private var price: String {
        Decimal(1_234_000).formatted(.currency(code: isUS ? "USD" : "KRW").locale(locale))
    }

    private var fullName: String {
        var components = PersonNameComponents()
        components.givenName = isUS ? "Gildong" : "길동"
        components.familyName = isUS ? "Hong" : "홍"
        return components.formatted(.name(style: .long).locale(locale))
    }

    private var initials: String {
        var components = PersonNameComponents()
        components.givenName = isUS ? "Gildong" : "길동"
        components.familyName = isUS ? "Hong" : "홍"
        return components.formatted(.name(style: .abbreviated).locale(locale))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionLabel("값은 앱이, 표기는 로케일이", accent: .hgAccent2)
            Text("아래 값들은 앱이 문자열을 만들지 않습니다. 같은 데이터가 로케일에 따라 다르게 렌더링되는 것을 확인하세요.")
                .font(.footnote)
                .foregroundStyle(.hgDim)

            Picker("로케일", selection: $isUS) {
                Text("ko_KR").tag(false)
                Text("en_US").tag(true)
            }
            .pickerStyle(.segmented)

            VStack(spacing: 8) {
                row("Measurement(5, .kilometers)", distance)
                row("Decimal(1234000) .currency", price)
                row("PersonNameComponents .long", fullName)
                row("PersonNameComponents .abbreviated", initials)
            }

            DiagnosisRow(diagnosis: .init(
                level: .good,
                message: "앱은 값만 소유하고 표기는 시스템에 위임했습니다. `\"\\(distance) km\"` 로 조립했다면 미국 사용자에게 킬로미터를 강요하는 국제화 버그가 됩니다.",
                source: "2.2.1 · 2.2.2 · 8.1.6"
            ))
        }
    }

    private func row(_ code: String, _ value: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Text(code)
                .font(.system(.caption, design: .monospaced))
                .foregroundStyle(.hgDim)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.hgAccent)
        }
        .padding(10)
        .background(Color.hgCard, in: .rect(cornerRadius: 10))
    }
}
