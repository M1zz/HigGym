import SwiftUI

/// 실수 전용 예제의 무대 — **어긴 화면과 고친 화면을 한 화면에 나란히** 세운다.
///
/// 토글로 번갈아 보여주면 방금 본 것을 기억에 의존해 비교하게 된다. 둘을 동시에 두면
/// 눈이 왔다 갔다 하면서 **차이 그 자체**를 보게 된다 — 이 시리즈에서 배워야 할 것은
/// 각각의 화면이 아니라 둘 사이의 간격이기 때문이다.
///
/// 양쪽 모두 진짜로 동작한다. 작아서 누르기 어려우면 `크게 보기`로 실제 크기에서 만져본다.
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

    private enum Side: String, Identifiable {
        case bad, good
        var id: String { rawValue }
    }

    @State private var zoomed: Side?

    var body: some View {
        GeometryReader { geo in
            let width = (geo.size.width - 34) / 2
            // 헤더·라벨·크게 보기·설명·조작·요약이 쓰는 세로를 뺀 나머지가 미니 화면 몫이다.
            let reserved: CGFloat = Controls.self == EmptyView.self ? 230 : 320
            let phoneHeight = max(190, geo.size.height - reserved)

            VStack(spacing: 12) {
                header

                HStack(alignment: .top, spacing: 10) {
                    panel(
                        side: .bad,
                        label: "이렇게 했다",
                        note: badNote,
                        tint: .hgRed,
                        symbol: "xmark.octagon.fill",
                        width: width,
                        height: phoneHeight
                    ) { bad }

                    panel(
                        side: .good,
                        label: "이렇게 고쳤다",
                        note: goodNote,
                        tint: .hgGreen,
                        symbol: "checkmark.seal.fill",
                        width: width,
                        height: phoneHeight
                    ) { good }
                }

                controls

                takeawayCard
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
        .background(Color.hgBackground)
        .fullScreenCover(item: $zoomed) { side in
            ZStack(alignment: .topTrailing) {
                Group {
                    switch side {
                    case .bad:  bad
                    case .good: good
                    }
                }
                .ignoresSafeArea(.container, edges: .bottom)

                Button { zoomed = nil } label: {
                    Label(side == .bad ? "이렇게 했다" : "이렇게 고쳤다", systemImage: "xmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(side == .bad ? Color.hgRed : Color.hgGreen, in: .capsule)
                }
                .buttonStyle(.plain)
                .padding(.top, 4)
                .padding(.trailing, 12)
            }
        }
    }

    private var header: some View {
        VStack(spacing: 3) {
            Text(title)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(.hgText)
                .multilineTextAlignment(.center)
            Text("두 화면 다 실제로 동작합니다 — 눌러보고, 좁으면 크게 보기")
                .font(.system(size: 10.5))
                .foregroundStyle(.hgDim)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 30)
    }

    private func panel<Content: View>(
        side: Side,
        label: String,
        note: String,
        tint: Color,
        symbol: String,
        width: CGFloat,
        height: CGFloat,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(spacing: 7) {
            HStack(spacing: 4) {
                Image(systemName: symbol).font(.system(size: 10))
                Text(label).font(.system(size: 11, weight: .bold))
            }
            .foregroundStyle(tint)

            DemoMiniPhone(width: width, maxHeight: height) { content() }
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .strokeBorder(tint.opacity(0.55), lineWidth: 1.5)
                )

            Button { zoomed = side } label: {
                Label("크게 보기", systemImage: "arrow.up.left.and.arrow.down.right")
                    .font(.system(size: 10.5, weight: .semibold))
                    .foregroundStyle(tint)
            }
            .buttonStyle(.plain)

            Text(.init(note))
                .font(.system(size: 11))
                .foregroundStyle(.hgMuted)
                .multilineTextAlignment(.center)
                .lineLimit(3, reservesSpace: true)
                .frame(maxWidth: .infinity, alignment: .top)
        }
    }

    private var takeawayCard: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "scope")
                .font(.system(size: 12))
                .foregroundStyle(.hgAccent2)
                .padding(.top, 1)
            Text(.init(takeaway))
                .font(.system(size: 12.5))
                .foregroundStyle(.hgText)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(11)
        .background(Color.hgAccent2.opacity(0.08), in: .rect(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(Color.hgAccent2.opacity(0.25), lineWidth: 1))
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
