import SwiftUI

struct QuizResultView: View {
    let session: QuizSession
    let onClose: () -> Void
    @State private var presentedLab: LabID?

    private var score: Double {
        session.results.isEmpty ? 0 : Double(session.correctCount) / Double(session.results.count)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                scoreCard
                if !wrongResults.isEmpty {
                    weakSpots
                }
                Button {
                    onClose()
                } label: {
                    Text("마치기")
                        .font(.system(size: 16, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(.hgBrand, in: .rect(cornerRadius: 14))
                        .foregroundStyle(.white)
                }
                .buttonStyle(.plain)
            }
            .padding(18)
        }
        .fullScreenCover(item: $presentedLab) { labDestination($0) }
    }

    private var wrongResults: [(question: Question, correct: Bool)] {
        session.results.filter { !$0.correct }
    }

    private var scoreCard: some View {
        VStack(spacing: 10) {
            Text("\(session.correctCount) / \(session.results.count)")
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .foregroundStyle(score >= 0.7 ? .hgGreen : .hgAmber)
            Text(message)
                .font(.system(size: 14))
                .foregroundStyle(.hgMuted)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(Color.hgCard, in: .rect(cornerRadius: 18))
        .overlay(RoundedRectangle(cornerRadius: 18).strokeBorder(Color.hgLine, lineWidth: 1))
    }

    private var message: String {
        switch score {
        case 1:         "전부 맞혔습니다. 다른 유형으로 넘어가 보세요."
        case 0.7...:    "기준이 잡혀 있습니다. 틀린 항목만 실습으로 확인해보세요."
        case 0.4..<0.7: "판단은 서지만 근거가 흔들립니다. 아래 항목의 본문을 다시 보세요."
        default:        "괜찮습니다 — 원칙 7개부터 다시 훑는 것을 권합니다."
        }
    }

    private var weakSpots: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionLabel("다시 볼 항목", accent: .hgRed)

            ForEach(wrongResults, id: \.question.id) { result in
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 6) {
                        Pill(text: result.question.sourceIndex, color: .hgRed)
                        Text(result.question.sourceTitle)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.hgText)
                        Spacer()
                    }
                    MarkdownText(
                        raw: result.question.explanation,
                        font: .system(size: 12.5),
                        color: .hgMuted
                    )
                    if let lab = result.question.lab {
                        Button {
                            onClose()
                            presentedLab = lab
                        } label: {
                            Label(lab.title, systemImage: "hammer.fill")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(.hgAccent)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.hgCard, in: .rect(cornerRadius: 14))
                .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Color.hgLine, lineWidth: 1))
            }
        }
    }
}
