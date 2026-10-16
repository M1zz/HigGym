import SwiftUI

/// 첫 실행 안내 - 이 앱이 왜 순서를 건너뛸 수 없게 생겼는지를 먼저 알려 준다.
///
/// 레슨의 첫 화면은 일부러 **어긴 쪽**이다. 그걸 모르고 들어오면 버그로 여기고 떠난다.
/// 그래서 안내는 세 장뿐이고, 그중 한 장을 그 이야기에 쓴다.
/// 한 번 보면 RootView 의 hasSeenOnboarding 이 켜지고, 설정의 "사용법 다시 보기"로 다시 볼 수 있다.
struct HigGymOnboardingView: View {
    let onFinish: () -> Void

    @State private var page = 0

    private struct Page: Identifiable {
        let id: Int
        let symbol: String
        let title: String
        let body: String
    }

    private let pages: [Page] = [
        Page(
            id: 0, symbol: "hand.tap.fill",
            title: "먼저 만져 봅니다",
            body: "한 편에 결정 하나를 다룹니다. 처음 만지는 화면은 일부러 가이드라인을 어긴 쪽입니다. 어색하다면 제대로 느낀 것이니 버그로 여기지 마세요."
        ),
        Page(
            id: 1, symbol: "square.and.pencil",
            title: "답보다 내 문장이 먼저",
            body: "써보기, 적어보기, 이유 확인, 비교, 배운 것 적기. 다섯 단계를 순서대로 밟습니다. 답을 보기 전에 느낀 점을 적어야 어긋난 자리가 남습니다."
        ),
        Page(
            id: 2, symbol: "text.book.closed.fill",
            title: "쓴 글은 노트에 쌓입니다",
            body: "노트 탭에서 다시 읽고, 텍스트나 마크다운 파일로 내보낼 수 있습니다. 진도와 노트는 이 기기에만 저장되고 어디로도 보내지 않습니다."
        ),
    ]

    private var isLast: Bool { page == pages.count - 1 }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                if !isLast {
                    Button("건너뛰기", action: onFinish)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.hgMuted)
                }
            }
            .frame(height: 44)
            .padding(.horizontal, 20)

            TabView(selection: $page) {
                ForEach(pages) { item in
                    pageView(item).tag(item.id)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))

            Button {
                if isLast {
                    onFinish()
                } else {
                    withAnimation(.snappy(duration: 0.25)) { page += 1 }
                }
            } label: {
                Text(isLast ? "시작하기" : "다음")
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(.hgBrand, in: .rect(cornerRadius: 14))
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
        }
        .background(Color.hgBackground)
    }

    private func pageView(_ item: Page) -> some View {
        VStack(spacing: 22) {
            Spacer(minLength: 0)
            Image(systemName: item.symbol)
                .font(.system(size: 52, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 104, height: 104)
                .background(.hgBrand, in: .rect(cornerRadius: 28))
                .accessibilityHidden(true)
            Text(item.title)
                .font(.title2.weight(.bold))
                .foregroundStyle(.hgText)
                .multilineTextAlignment(.center)
            Text(item.body)
                .font(.body)
                .foregroundStyle(.hgMuted)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 28)
        .accessibilityElement(children: .combine)
    }
}
