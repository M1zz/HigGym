import SwiftUI

/// 문서의 프리뷰 목업을 그대로 그리는 뷰.
///
/// 앱의 설명 화면과 실습이 모두 이 그림 위에서 이뤄진다. `onSelect` 를 주면
/// 목업의 각 부위를 눌러 "이 자리가 무엇을 말하는지" 확인할 수 있다.
struct MockupView: View {
    let nodes: [MockupNode]
    var scale: CGFloat = 1.75
    var selected: MockupPart?
    var onSelect: ((MockupPart) -> Void)?

    var body: some View {
        HStack(alignment: .top, spacing: 12 * scale) {
            ForEach(Array(nodes.enumerated()), id: \.offset) { _, node in
                MockupNodeView(node: node, context: context)
            }
        }
    }

    private var context: MockupContext {
        MockupContext(scale: scale, selected: selected, onSelect: onSelect)
    }
}

/// 렌더링 내내 따라다니는 값들 — 상속되는 글꼴·색과 선택 상태.
struct MockupContext {
    var scale: CGFloat
    var selected: MockupPart?
    var onSelect: ((MockupPart) -> Void)?
    var highlighted = false
    /// `.ti.on` 안쪽인가 — CSS 자손 선택자를 문맥으로 옮긴 것.
    var selectedTab = false
    var font: MockupBox.FontSpec?
    var color: Color?
    var nowrap = false

    func inheriting(_ box: MockupBox, node: MockupNode) -> MockupContext {
        var next = self
        next.highlighted = highlighted || node.has("hl") || node.has("hlb")
        next.selectedTab = selectedTab || (node.has("ti") && node.has("on"))
        next.font = box.font ?? font
        next.color = box.foreground ?? color
        next.nowrap = nowrap || box.nowrap
        return next
    }
}

/// 목업 한 노드.
///
/// 재귀는 반드시 **이름 있는 구조체**를 통해야 한다 — 함수로 재귀시키면
/// 불투명 반환 타입이 무한 중첩되어 타입 체크가 끝나지 않는다.
struct MockupNodeView: View {
    let node: MockupNode
    let context: MockupContext

    var body: some View {
        if node.tag == "text" {
            textView
        } else {
            shapeView
        }
    }

    private var textView: some View {
        let spec = context.font ?? .init(size: 9)
        return Text(node.text ?? "")
            .font(.system(
                size: spec.size * context.scale,
                weight: spec.weight,
                design: spec.mono ? .monospaced : .default
            ))
            .foregroundStyle(context.color ?? Color.white.opacity(0.8))
            .lineLimit(context.nowrap ? 1 : nil)
            .fixedSize(horizontal: context.nowrap, vertical: true)
    }

    private var shapeView: some View {
        let box = MockupStyle.box(
            for: node,
            highlighted: context.highlighted,
            selectedTab: context.selectedTab
        )
        let child = context.inheriting(box, node: node)
        let part = MockupPart(node: node)

        return MockupChildren(node: node, box: box, context: child)
            .modifier(BoxDecoration(
                box: box,
                scale: context.scale,
                isSelected: context.selected == part
            ))
            .modifier(TapTarget(part: part, onSelect: context.onSelect))
    }
}

/// 자식 배치 — `.phone` 안은 절대 배치, 나머지는 행/열.
private struct MockupChildren: View {
    let node: MockupNode
    let box: MockupBox
    let context: MockupContext

    var body: some View {
        if node.has("phone") {
            PhoneCanvas(node: node, context: context)
        } else if let layout = box.layout {
            FlowLayout(node: node, layout: layout, context: context)
        } else if node.children.isEmpty {
            Color.clear.frame(width: 0, height: 0)
        } else {
            FlowLayout(
                node: node,
                layout: .column(spacing: 0, alignment: .leading),
                context: context
            )
        }
    }
}

/// `.phone` 안은 전부 절대 배치 — 문서 CSS와 같은 규칙으로 좌표를 계산한다.
private struct PhoneCanvas: View {
    let node: MockupNode
    let context: MockupContext

    var body: some View {
        ZStack {
            ForEach(Array(node.children.enumerated()), id: \.offset) { _, child in
                placed(child)
            }
        }
        .frame(
            width: MockupStyle.phoneSize.width * context.scale,
            height: MockupStyle.phoneSize.height * context.scale
        )
    }

    private func placed(_ child: MockupNode) -> some View {
        let box = MockupStyle.box(for: child, highlighted: context.highlighted, selectedTab: context.selectedTab)
        let scale = context.scale
        return MockupNodeView(node: resolvingWidth(child, box: box), context: context)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: alignment(box))
            .offset(x: offsetX(box) * scale, y: offsetY(box) * scale)
    }

    /// left·right 를 함께 지정한 요소는 폭이 계산으로 정해진다.
    /// 배경을 그리기 전에 폭이 확정돼 있어야 해서 노드에 직접 써 넣는다.
    private func resolvingWidth(_ child: MockupNode, box: MockupBox) -> MockupNode {
        guard box.width == nil else { return child }

        let resolved: CGFloat?
        if box.fillsParent {
            resolved = MockupStyle.phoneSize.width
        } else if let left = box.left, let right = box.right {
            resolved = MockupStyle.phoneSize.width - left - right
        } else {
            resolved = nil
        }
        guard let resolved else { return child }

        var style = child.style
        style["width"] = "\(resolved)px"
        return MockupNode(
            tag: child.tag,
            classes: child.classes,
            style: style,
            text: child.text,
            children: child.children
        )
    }

    private func alignment(_ box: MockupBox) -> Alignment {
        let horizontal: HorizontalAlignment
        if box.centerX { horizontal = .center }
        else if box.left != nil { horizontal = .leading }
        else if box.right != nil { horizontal = .trailing }
        else { horizontal = .center }

        let vertical: VerticalAlignment
        if box.top != nil || box.fillsParent { vertical = .top }
        else if box.bottom != nil { vertical = .bottom }
        else { vertical = .center }

        return Alignment(horizontal: horizontal, vertical: vertical)
    }

    private func offsetX(_ box: MockupBox) -> CGFloat {
        if box.centerX { return 0 }
        if let left = box.left { return left }
        if let right = box.right { return -right }
        return 0
    }

    private func offsetY(_ box: MockupBox) -> CGFloat {
        if box.fillsParent { return 0 }
        if let top = box.top { return top }
        if let bottom = box.bottom { return -bottom }
        return 0
    }
}

private struct FlowLayout: View {
    let node: MockupNode
    let layout: MockupBox.Layout
    let context: MockupContext

    var body: some View {
        switch layout {
        case .row(let spacing, let centered):
            HStack(alignment: centered ? .center : .top, spacing: spacing * context.scale) {
                children
            }
        case .distributedRow:
            HStack(spacing: 0) {
                ForEach(Array(node.children.enumerated()), id: \.offset) { _, child in
                    MockupNodeView(node: child, context: context)
                        .frame(maxWidth: .infinity)
                }
            }
        case .column(let spacing, let alignment):
            VStack(alignment: alignment, spacing: spacing * context.scale) {
                children
            }
        }
    }

    private var children: some View {
        ForEach(Array(node.children.enumerated()), id: \.offset) { _, child in
            child.has("bdg") ? AnyView(badge(child)) : AnyView(flowChild(child))
        }
    }

    /// 배지만은 부모 위에 겹치는 절대 배치다.
    private func badge(_ child: MockupNode) -> some View {
        Color.clear
            .frame(width: 0, height: 0)
            .overlay(alignment: .topTrailing) {
                MockupNodeView(node: child, context: context)
                    .offset(x: 5 * context.scale, y: -5 * context.scale)
            }
    }

    private func flowChild(_ child: MockupNode) -> some View {
        let box = MockupStyle.box(for: child, highlighted: context.highlighted, selectedTab: context.selectedTab)
        return MockupNodeView(node: child, context: context)
            .frame(maxWidth: box.grow ? .infinity : nil)
    }
}

// MARK: - 상자 꾸미기

private struct BoxDecoration: ViewModifier {
    let box: MockupBox
    let scale: CGFloat
    let isSelected: Bool

    func body(content: Content) -> some View {
        content
            .padding(.horizontal, box.padH * scale)
            .padding(.vertical, box.padV * scale)
            .frame(width: box.width.map { $0 * scale }, height: box.height.map { $0 * scale })
            .frame(minWidth: box.minWidth.map { $0 * scale })
            .background(background)
            .overlay(strokeOverlay)
            .shadow(color: box.glow?.opacity(0.5) ?? .clear, radius: 5 * scale)
            .overlay(selectionRing)
            .blur(radius: box.blur * scale)
            .opacity(box.opacity)
    }

    @ViewBuilder
    private var background: some View {
        if let fill = box.fill {
            if box.triangle {
                RightTriangle().fill(fill)
            } else if box.circle {
                Circle().fill(fill)
            } else {
                RoundedRectangle(cornerRadius: box.radius * scale, style: .continuous).fill(fill)
            }
        }
    }

    @ViewBuilder
    private var strokeOverlay: some View {
        if let stroke = box.stroke {
            border(stroke, width: 1, dash: box.dashed ? [3, 2] : [])
        }
    }

    @ViewBuilder
    private var selectionRing: some View {
        if isSelected {
            border(.hgAmber, width: 1.5, dash: [])
                .shadow(color: Color.hgAmber.opacity(0.8), radius: 5)
        }
    }

    @ViewBuilder
    private func border(_ color: Color, width: CGFloat, dash: [CGFloat]) -> some View {
        if box.circle {
            Circle().strokeBorder(color, style: StrokeStyle(lineWidth: width, dash: dash))
        } else {
            RoundedRectangle(cornerRadius: box.radius * scale, style: .continuous)
                .strokeBorder(color, style: StrokeStyle(lineWidth: width, dash: dash))
        }
    }
}

// MARK: - 부위 선택

private struct TapTarget: ViewModifier {
    let part: MockupPart
    let onSelect: ((MockupPart) -> Void)?

    func body(content: Content) -> some View {
        if let onSelect, part.isMeaningful {
            content
                .contentShape(.rect)
                .onTapGesture { onSelect(part) }
        } else {
            content
        }
    }
}


/// `.tri` — 재생 표시로 쓰는 CSS 보더 삼각형.
private struct RightTriangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}
