import SwiftUI

struct QuizHomeView: View {
    /// 자료 탭 안으로 push 될 때는 바깥 스택을 쓴다 — 스택을 겹치면 안쪽 툴바가 바깥으로 끌려 올라간다.
    var embedded = false

    @Environment(ProgressStore.self) private var progress
    @State private var session: QuizSession?
    @State private var liveKind: LiveQuestion.Kind?
    @State private var caseStudy = false

    private let bank = QuizBank.shared
    private let store = ContentStore.shared

    var body: some View {
        if embedded { content } else { NavigationStack { content } }
    }

    private var content: some View {
        ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    scoreCard
                    liveSection
                    modeSection
                    chapterSection
                    bankInfo
                }
                .padding(18)
            }
            .background(Color.hgBackground)
            .navigationTitle("퀴즈")
            .onAppear {
                if let kind = DebugLaunch.liveKind { liveKind = kind }
                if DebugLaunch.caseStudy { caseStudy = true }
                if DebugLaunch.autoQuiz, session == nil {
                    let mode: QuizSession.Mode = DebugLaunch.quizKind.map { .kind($0) } ?? .mixed(10)
                    session = QuizSession(mode: mode, bank: bank, progress: progress)
                }
            }
            .fullScreenCover(item: $session) { session in
                QuizPlayView(session: session) { self.session = nil }
            }
            .fullScreenCover(item: $liveKind) { kind in
                LiveQuizPlayView(kind: kind) { liveKind = nil }
            }
            .fullScreenCover(isPresented: $caseStudy) {
                CaseStudyView()
            }
    }

    // MARK: 성적

    private var scoreCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text("\(progress.correctCount)")
                    .font(.system(.largeTitle, design: .rounded, weight: .bold))
                    .foregroundStyle(.hgAccent)
                Text("문제를 맞혔습니다")
                    .font(.subheadline)
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
                .font(.system(.headline, design: .rounded))
                .foregroundStyle(.hgText)
            Text(label)
                .font(.caption)
                .foregroundStyle(.hgDim)
        }
    }

    // MARK: 실전 — 화면을 보고 판단하기

    /// 문장을 읽고 고르는 훈련과 화면을 보고 고르는 훈련은 다른 근육을 쓴다.
    /// 실무에서 판단하는 대상은 언제나 화면이므로 이쪽을 위에 둔다.
    private var liveSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionLabel("실전 — 화면으로 판단하기", accent: .hgGreen)

            Button { caseStudy = true } label: {
                VStack(alignment: .leading, spacing: 9) {
                    HStack(spacing: 13) {
                        Image(systemName: "iphone.gen3")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(width: 40, height: 40)
                            .background(.hgBrand, in: .rect(cornerRadius: 11))
                        VStack(alignment: .leading, spacing: 2) {
                            Text("샘플 앱 뜯어보기")
                                .font(.callout.weight(.bold))
                                .foregroundStyle(.hgText)
                            Text("완성된 노트 앱을 직접 써보고, 결정 8개의 이유를 짚어봅니다")
                                .font(.footnote)
                                .foregroundStyle(.hgMuted)
                                .multilineTextAlignment(.leading)
                        }
                        Spacer(minLength: 4)
                        Image(systemName: "chevron.right")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(.hgDim)
                    }
                }
                .padding(14)
                .background(Color.hgCard, in: .rect(cornerRadius: 14))
                .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Color.hgGreen.opacity(0.4), lineWidth: 1))
            }
            .buttonStyle(.plain)

            liveRow(.pickScreen, "기준을 주면 어느 화면이 맞는지 고릅니다", .hgAccent)
            liveRow(.reason, "화면을 보고 왜 그렇게 만들었는지 고릅니다", .hgAccent2)
        }
    }

    private func liveRow(_ kind: LiveQuestion.Kind, _ subtitle: String, _ tint: Color) -> some View {
        Button { liveKind = kind } label: {
            HStack(spacing: 13) {
                Image(systemName: kind.symbol)
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(tint)
                    .frame(width: 38, height: 38)
                    .background(tint.opacity(0.12), in: .rect(cornerRadius: 10))
                VStack(alignment: .leading, spacing: 2) {
                    Text(kind.title)
                        .font(.callout.weight(.semibold))
                        .foregroundStyle(.hgText)
                    Text(subtitle)
                        .font(.footnote)
                        .foregroundStyle(.hgMuted)
                        .multilineTextAlignment(.leading)
                }
                Spacer(minLength: 8)
                MasteryBar(value: progress.liveMastery(kind: kind))
                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.hgDim)
            }
            .padding(13)
            .background(Color.hgCard, in: .rect(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Color.hgLine, lineWidth: 1))
        }
        .buttonStyle(.plain)
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
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(tint)
                    .frame(width: 38, height: 38)
                    .background(tint.opacity(0.12), in: .rect(cornerRadius: 10))
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.callout.weight(.semibold))
                        .foregroundStyle(.hgText)
                    Text(subtitle)
                        .font(.footnote)
                        .foregroundStyle(.hgMuted)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
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
                            .font(.system(.subheadline, design: .monospaced, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 28, height: 28)
                            .background(.hgBrand, in: .rect(cornerRadius: 8))

                        VStack(alignment: .leading, spacing: 2) {
                            Text(chapter.title)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.hgText)
                            Text(chapter.subtitle)
                                .font(.caption)
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
            .font(.footnote)
            .foregroundStyle(.hgDim)
            .padding(.top, 4)
    }
}

private struct MasteryBar: View {
    let value: Double

    var body: some View {
        VStack(alignment: .trailing, spacing: 3) {
            Text("\(Int(value * 100))%")
                .font(.system(.caption, design: .monospaced, weight: .semibold))
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

extension LiveQuestion.Kind: Identifiable {
    var id: String { rawValue }
}

extension QuizSession: Identifiable {
    nonisolated var id: ObjectIdentifier { ObjectIdentifier(self) }
}
