import SwiftUI

/// 자료 탭 — 코스가 본문이라면 여기는 **찾아보는 곳**이다.
///
/// 항목 68 · 실수 100 · 원칙 7 · 실습 5는 없앨 게 아니라 뒤로 물린 것이다.
/// 레슨을 밟다가 더 알고 싶어질 때 열고, 평소에는 자리를 차지하지 않는다.
struct LibraryView: View {
    private enum Destination: String, Identifiable {
        case entries, mistakes, principles, labs
        var id: String { rawValue }
    }

    @State private var opened: Destination?
    private let store = ContentStore.shared
    private let mistakes = MistakeStore.shared

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    intro

                    row(.entries, "항목", "\(store.entries.count)개",
                        "문서와 같은 목업 + 동작하는 예제", "square.grid.2x2.fill", .hgAccent)
                    row(.mistakes, "실수 100", "\(mistakes.mistakes.count)편",
                        "무엇을 했나 · 그때는 왜 · 고치면 · 회고", "exclamationmark.triangle.fill", .hgAmber)
                    row(.principles, "원칙", "\(store.principles.count)개",
                        "68개 항목을 관통하는 판단 기준", "list.bullet.rectangle.portrait.fill", .hgAccent2)
                    row(.labs, "실습실", "\(LabID.allCases.count)종",
                        "설정을 바꿔가며 실시간 판정 받기", "hammer.fill", .hgGreen)

                    quizRow

                    source
                }
                .padding(18)
            }
            .background(Color.hgBackground)
            .navigationTitle("자료")
            .task {
                if let target = DebugLaunch.libraryTarget {
                    opened = Destination(rawValue: target)
                } else if DebugLaunch.entryIndex != nil {
                    opened = .entries
                } else if DebugLaunch.mistakeNumber != nil {
                    opened = .mistakes
                } else if DebugLaunch.principleIndex != nil {
                    opened = .principles
                }
            }
        }
        .fullScreenCover(item: $opened) { destination in
            Group {
                switch destination {
                case .entries:    EntriesHomeView(onClose: { opened = nil })
                case .mistakes:   MistakesHomeView(onClose: { opened = nil })
                case .principles: PrinciplesView(onClose: { opened = nil })
                case .labs:       LabsHomeView(onClose: { opened = nil })
                }
            }
        }
    }

    private var intro: some View {
        Text("레슨을 밟다가 더 알고 싶어지면 여기서 찾습니다. 레슨 안에서도 **근거 본문**은 바로 열립니다.")
            .font(.system(size: 14))
            .foregroundStyle(.hgMuted)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func row(
        _ destination: Destination, _ title: String, _ count: String,
        _ subtitle: String, _ symbol: String, _ tint: Color
    ) -> some View {
        Button { opened = destination } label: {
            HStack(spacing: 13) {
                Image(systemName: symbol)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(tint)
                    .frame(width: 40, height: 40)
                    .background(tint.opacity(0.12), in: .rect(cornerRadius: 11))
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(title)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.hgText)
                        Text(count)
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundStyle(tint)
                    }
                    Text(subtitle)
                        .font(.system(size: 12.5))
                        .foregroundStyle(.hgMuted)
                        .multilineTextAlignment(.leading)
                }
                Spacer(minLength: 4)
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.hgDim)
            }
            .padding(13)
            .background(Color.hgCard, in: .rect(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Color.hgLine, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    private var quizRow: some View {
        NavigationLink {
            QuizHomeView(embedded: true)
        } label: {
            HStack(spacing: 13) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.hgRed)
                    .frame(width: 40, height: 40)
                    .background(Color.hgRed.opacity(0.12), in: .rect(cornerRadius: 11))
                VStack(alignment: .leading, spacing: 2) {
                    Text("퀴즈")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.hgText)
                    Text("화면으로 판단하기 · 문항 396개")
                        .font(.system(size: 12.5))
                        .foregroundStyle(.hgMuted)
                }
                Spacer(minLength: 4)
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.hgDim)
            }
            .padding(13)
            .background(Color.hgCard, in: .rect(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Color.hgLine, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    private var source: some View {
        Text("모든 자료는 `toolbar-annotated.html` 한 문서에서 나옵니다. 문서를 고치고 `Tools/extract_content.py` → `Tools/build_mistakes.py` 를 실행하면 앱 내용이 함께 갱신됩니다.")
            .font(.system(size: 12))
            .foregroundStyle(.hgDim)
            .padding(.top, 4)
    }
}
