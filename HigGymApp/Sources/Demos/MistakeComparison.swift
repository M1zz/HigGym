import SwiftUI

/// 실수 전용 예제의 무대 — 어긴 화면과 고친 화면을 **같은 자리에서 갈아 끼워** 비교한다.
///
/// 처음에는 미니 두 대를 나란히 놓았는데, 절반 폭으로 줄이면 정작 봐야 할 것(글자 크기,
/// 버튼이 닿는 자리)이 사라졌다. 그래서 전체 크기 한 화면을 위에서 바꾸는 방식으로 옮겼다.
/// 두 화면 모두 진짜로 동작하고, 오가도 각자의 상태가 유지된다.
struct MistakeComparisonScreen<Bad: View, Good: View, Controls: View>: View {
    let title: String
    let badNote: String
    let goodNote: String
    /// 두 화면을 다 본 뒤에 남아야 할 한 문장.
    let takeaway: String
    /// 두 화면에 **함께** 걸리는 조건(로케일·글자 크기 같은 것). 한쪽만 바꾸면 비교가 안 되므로 여기 둔다.
    @ViewBuilder var controls: Controls
    @ViewBuilder var bad: Bad
    @ViewBuilder var good: Good

    var body: some View {
        VStack(spacing: 10) {
            header

            ABCompareView(
                diff: takeaway,
                brokenNote: badNote,
                fixedNote: goodNote,
                broken: { bad },
                fixed: { good }
            )

            controls
                .padding(.horizontal, 12)
        }
        .padding(.top, 6)
        .background(Color.hgBackground)
    }

    private var header: some View {
        Text(title)
            .font(.callout.weight(.bold))
            .foregroundStyle(.hgText)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 24)
    }
}

/// 실제 화면을 그대로 축소한 미니 아이폰.
///
/// 작은 프레임에 직접 그리면 글자와 여백 비율이 실물과 달라져 비교가 거짓말이 된다.
/// 그래서 **원래 크기(393×760)로 그린 뒤 통째로 축소**한다 — 터치는 그대로 살아 있다.
struct DemoMiniPhone<Content: View>: View {
    let width: CGFloat
    /// 세로로도 잘려선 안 되므로 쓸 수 있는 높이를 함께 받는다.
    var maxHeight: CGFloat = .infinity
    var nominal: CGSize = CGSize(width: 393, height: 740)
    @ViewBuilder var content: Content

    private var scale: CGFloat { min(width / nominal.width, maxHeight / nominal.height) }

    var body: some View {
        // scaleEffect 는 레이아웃 크기를 바꾸지 않는다. 축소 기준점(topLeading)과
        // 바깥 프레임의 정렬을 같게 맞춰야 잘린 자리가 어긋나지 않는다.
        content
            .frame(width: nominal.width, height: nominal.height)
            .scaleEffect(scale, anchor: .topLeading)
            .frame(width: nominal.width * scale, height: nominal.height * scale, alignment: .topLeading)
            .clipShape(.rect(cornerRadius: 18))
            .background(Color.black, in: .rect(cornerRadius: 18))
            .shadow(color: .black.opacity(0.35), radius: 8, y: 4)
    }
}


extension MistakeComparisonScreen where Controls == EmptyView {
    init(
        title: String,
        badNote: String,
        goodNote: String,
        takeaway: String,
        @ViewBuilder bad: () -> Bad,
        @ViewBuilder good: () -> Good
    ) {
        self.init(
            title: title,
            badNote: badNote,
            goodNote: goodNote,
            takeaway: takeaway,
            controls: { EmptyView() },
            bad: bad,
            good: good
        )
    }
}

/// 두 화면에 함께 거는 조건 줄 — 비교 화면 아래에 붙는다.
struct ComparisonControls<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 6) { content }
            .padding(11)
            .background(Color.hgCard, in: .rect(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(Color.hgLine, lineWidth: 1))
    }
}
