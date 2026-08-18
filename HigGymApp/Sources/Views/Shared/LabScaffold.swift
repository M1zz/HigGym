import SwiftUI

/// 실습 화면의 공통 껍데기.
///
/// 일부러 `NavigationStack` 을 쓰지 않는다 — 미리보기 안의 `NavigationStack` 이
/// 조상 내비게이션 컨트롤러를 발견하면 자기 툴바를 그쪽으로 올려버려서,
/// 상자 안에 있어야 할 툴바가 화면 상단에 나타난다. 그래서 실습은 push 가 아니라
/// 전체 화면으로 띄우고, 헤더는 직접 그린다.
struct LabScaffold<Content: View>: View {
    let title: String
    var subtitle: String?
    @ViewBuilder var content: Content

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            header
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    content
                }
                .padding(18)
            }
        }
        .background(Color.hgBackground)
    }

    private var header: some View {
        HStack(spacing: 10) {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.hgAccent)
                    .frame(width: 32, height: 32)
                    .background(Color.hgCard, in: .circle)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.hgText)
                if let subtitle {
                    Text(subtitle)
                        .font(.system(size: 11.5))
                        .foregroundStyle(.hgDim)
                }
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 10)
        .background(Color.hgBackground)
    }
}
