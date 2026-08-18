import SwiftUI

struct QuizHomeView: View {
    @Environment(ProgressStore.self) private var progress
    @State private var session: QuizSession?

    private let bank = QuizBank.shared
    private let store = ContentStore.shared

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    scoreCard
                    modeSection
                    chapterSection
                    bankInfo
                }
                .padding(18)
            }
            .background(Color.hgBackground)
            .navigationTitle("퀴즈")
            .onAppear {
                if DebugLaunch.autoQuiz, session == nil {
                    let mode: QuizSession.Mode = DebugLaunch.quizKind.map { .kind($0) } ?? .mixed(10)
                    session = QuizSession(mode: mode, bank: bank, progress: progress)
                }
            }
            .fullScreenCover(item: $session) { session in
                QuizPlayView(session: session) { self.session = nil }
            }
        }
    }

    // MARK: 성적

    private var scoreCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text("\(progress.correctCount)")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(.hgAccent)
                Text("문제를 맞혔습니다")
                    .font(.system(size: 14))
                    .foregroundStyle(.hgMuted)
                Spacer()
            }

            HStack(spacing: 18) {
                stat("푼 문제", "\(progress.answeredCount)")
                stat("복습 대기", "\(progress.wrongIDs.count)")
                stat("전체 문항", "\(bank.questions.count)")
            }
        }
        .hgCard()
    }

    private func stat(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value)
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundStyle(.hgText)
            Text(label)
                .font(.system(size: 11))
                .foregroundStyle(.hgDim)
        }
    }

    // MARK: 모드

    private var modeSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionLabel("훈련 모드", accent: .hgAccent)

            modeRow(
                "랜덤 10문항", "유형을 섞어 전 범위에서",
                "shuffle", .hgAccent, .mixed(10)
            )
            modeRow(
                "원칙 판정", "잘못된 설계가 어떤 원칙을 어겼는지",
                "scale.3d", .hgAccent2, .principles
            )
            modeRow(
                "적절/부적절 판별", "예시를 보고 즉시 판단하기",
                "checkmark.circle.badge.questionmark", .hgGreen, .kind(.judgement)
            )
            modeRow(
                "상황 → 컴포넌트", "이 상황엔 무엇을 쓰는가",
                "arrow.triangle.branch", .hgAmber, .kind(.whenMatch)
            )

            if !progress.wrongIDs.isEmpty {
                modeRow(
                    "오답 복습 \(progress.wrongIDs.count)문항", "틀렸던 것만 다시",
                    "arrow.counterclockwise", .hgRed, .review
                )
            }
        }
    }

    private func modeRow(
        _ title: String, _ subtitle: String, _ symbol: String,
        _ tint: Color, _ mode: QuizSession.Mode
    ) -> some View {
        Button {
            session = QuizSession(mode: mode, bank: bank, progress: progress)
        } label: {
            HStack(spacing: 13) {
                Image(systemName: symbol)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(tint)
                    .frame(width: 38, height: 38)
                    .background(tint.opacity(0.12), in: .rect(cornerRadius: 10))
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.hgText)
                    Text(subtitle)
                        .font(.system(size: 12.5))
                        .foregroundStyle(.hgMuted)
                }
                Spacer()
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

    // MARK: 챕터별

    private var chapterSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionLabel("챕터별 집중", accent: .hgAmber)

            ForEach(store.chapters) { chapter in
                Button {
                    session = QuizSession(mode: .chapter(chapter.number), bank: bank, progress: progress)
                } label: {
                    HStack(spacing: 12) {
                        Text("\(chapter.number)")
                            .font(.system(size: 13, weight: .bold, design: .monospaced))
                            .foregroundStyle(.white)
                            .frame(width: 28, height: 28)
                            .background(.hgBrand, in: .rect(cornerRadius: 8))

                        VStack(alignment: .leading, spacing: 2) {
                            Text(chapter.title)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(.hgText)
                            Text(chapter.subtitle)
                                .font(.system(size: 11))
                                .foregroundStyle(.hgDim)
                                .lineLimit(1)
                        }

                        Spacer(minLength: 8)

                        MasteryBar(value: progress.mastery(chapter: chapter.number, bank: bank))
                    }
                    .padding(12)
                    .background(Color.hgCard, in: .rect(cornerRadius: 12))
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var bankInfo: some View {
        Text("문항은 문서의 68개 항목과 8장 원칙 7개에서 자동 생성된 것과, 실무 시나리오로 직접 쓴 것이 함께 들어 있습니다. 해설에는 항상 본문 항목 번호가 붙습니다.")
            .font(.system(size: 12))
            .foregroundStyle(.hgDim)
            .padding(.top, 4)
    }
}

private struct MasteryBar: View {
    let value: Double

    var body: some View {
        VStack(alignment: .trailing, spacing: 3) {
            Text("\(Int(value * 100))%")
                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                .foregroundStyle(value > 0 ? .hgGreen : .hgDim)
            Capsule()
                .fill(Color.hgLine)
                .frame(width: 48, height: 4)
                .overlay(alignment: .leading) {
                    Capsule()
                        .fill(Color.hgGreen)
                        .frame(width: 48 * value, height: 4)
                }
        }
    }
}

extension QuizSession: Identifiable {
    nonisolated var id: ObjectIdentifier { ObjectIdentifier(self) }
}
