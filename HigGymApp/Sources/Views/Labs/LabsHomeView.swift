import SwiftUI

@ViewBuilder
func labDestination(_ lab: LabID) -> some View {
    switch lab {
    case .toolbar:    ToolbarLabView()
    case .scrollEdge: ScrollEdgeLabView()
    case .text:       TextLabView()
    case .tabBar:     TabBarLabView()
    case .sheet:      SheetLabView()
    }
}

struct LabsHomeView: View {
    var onClose: (() -> Void)?

    @Environment(Router.self) private var router
    @Environment(ProgressStore.self) private var progress

    var body: some View {
        @Bindable var router = router

        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    header

                    ForEach(LabID.allCases) { lab in
                        Button {
                            router.presentedLab = lab
                        } label: {
                            LabCard(lab: lab, visited: progress.visitedLabs.contains(lab.rawValue))
                        }
                        .buttonStyle(.plain)
                    }

                    sourceNote
                }
                .padding(20)
            }
            .background(Color.hgBackground)
            .navigationTitle("실습실")
            .toolbar {
                if let onClose {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("닫기", systemImage: "xmark", action: onClose)
                    }
                }
            }
        }
        .fullScreenCover(item: $router.presentedLab) { lab in
            labDestination(lab)
                .onAppear { progress.markLabVisited(lab) }
        }
    }

    private var header: some View {
        Text("설정을 바꾸면 문서와 같은 목업이 바로 다시 그려지고, 지금 구성이 어떤 기준을 지키고 어기는지 함께 판정합니다. 실제 SwiftUI 화면으로도 대조할 수 있습니다.")
            .font(.subheadline)
            .foregroundStyle(.hgMuted)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, 6)
    }

    private var sourceNote: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("판정 근거")
                .font(.footnote.weight(.bold))
                .foregroundStyle(.hgDim)
            Text("모든 진단 문구는 본문 68개 항목의 WHEN·WHY와 8장 디자인 원칙 7개에서 나옵니다. 항목 번호를 함께 표시하니 원문과 대조해 보세요.")
                .font(.footnote)
                .foregroundStyle(.hgDim)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 8)
    }
}

private struct LabCard: View {
    let lab: LabID
    let visited: Bool

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: lab.symbol)
                .font(.title3.weight(.semibold))
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .background(.hgBrand, in: .rect(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 3) {
                Text(lab.title)
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(.hgText)
                Text(lab.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.hgMuted)
            }

            Spacer(minLength: 4)

            if visited {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.hgGreen)
                    .font(.callout)
            }
            Image(systemName: "chevron.right")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.hgDim)
        }
        .hgCard()
    }
}
