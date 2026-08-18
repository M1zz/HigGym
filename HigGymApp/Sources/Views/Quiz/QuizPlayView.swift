import SwiftUI

struct QuizPlayView: View {
    @Bindable var session: QuizSession
    let onClose: () -> Void

    @Environment(ProgressStore.self) private var progress
    @Environment(Router.self) private var router

    var body: some View {
        NavigationStack {
            Group {
                if session.questions.isEmpty {
                    empty
                } else if let question = session.current {
                    playing(question)
                } else {
                    QuizResultView(session: session, onClose: onClose)
                }
            }
            .background(Color.hgBackground)
            .navigationTitle(session.mode.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("닫기") { onClose() }
                }
            }
        }
    }

    private var empty: some View {
        ContentUnavailableView(
            "복습할 문제가 없습니다",
            systemImage: "checkmark.circle",
            description: Text("틀린 문제가 생기면 여기 모입니다.")
        )
    }

    private func playing(_ question: Question) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 10) {
                ProgressView(value: session.progress)
                    .tint(.hgAccent)
                Text("\(session.index + 1) / \(session.questions.count)")
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundStyle(.hgDim)
            }
            .padding(.horizontal, 18)

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    header(question)
                    if let subject = question.subject {
                        subjectCard(subject)
                    }
                    options(question)
                    if session.isAnswered {
                        explanation(question)
                    }
                }
                .padding(18)
            }

            if session.isAnswered {
                nextButton
            }
        }
        .onAppear {
            if let choice = DebugLaunch.autoAnswer { session.select(choice, progress: progress) }
        }
    }

    private func header(_ question: Question) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Pill(text: question.kind.label, color: kindColor(question.kind))
                // 항목 번호는 답을 알려주는 단서라 채점 후에만 보여준다.
                if session.isAnswered {
                    Pill(text: question.sourceIndex, color: .hgDim)
                }
                Spacer()
            }
            MarkdownText(raw: question.prompt, font: .system(size: 17, weight: .semibold))
        }
    }

    private func kindColor(_ kind: Question.Kind) -> Color {
        switch kind {
        case .judgement:      .hgGreen
        case .whenMatch:      .hgAmber
        case .principleMatch: .hgAccent2
        case .scenario:       .hgAccent
        }
    }

    private func subjectCard(_ subject: String) -> some View {
        MarkdownText(raw: subject, font: .system(size: 15), color: .hgText)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(Color.hgCardHigh, in: .rect(cornerRadius: 14))
            .overlay(alignment: .leading) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(.hgBrand)
                    .frame(width: 3)
                    .padding(.vertical, 10)
            }
    }

    @ViewBuilder
    private func options(_ question: Question) -> some View {
        if question.optionSources.count == question.options.count, !question.optionSources.isEmpty {
            mockupOptions(question)
        } else {
            VStack(spacing: 9) {
                ForEach(Array(question.options.enumerated()), id: \.offset) { index, text in
                    Button {
                        withAnimation(.snappy(duration: 0.2)) {
                            session.select(index, progress: progress)
                        }
                    } label: {
                        OptionRow(
                            text: text,
                            state: state(for: index, question: question)
                        )
                    }
                    .buttonStyle(.plain)
                    .disabled(session.isAnswered)
                }
            }
        }
    }

    /// 배치를 묻는 문제는 글이 아니라 **그림**으로 고르는 게 맞다.
    private func mockupOptions(_ question: Question) -> some View {
        LazyVGrid(columns: [.init(.flexible(), spacing: 10), .init(.flexible(), spacing: 10)], spacing: 10) {
            ForEach(Array(question.optionSources.enumerated()), id: \.offset) { index, source in
                Button {
                    withAnimation(.snappy(duration: 0.2)) {
                        session.select(index, progress: progress)
                    }
                } label: {
                    MockupOption(
                        entry: ContentStore.shared.entry(index: source),
                        title: question.options[index],
                        state: state(for: index, question: question),
                        revealed: session.isAnswered
                    )
                }
                .buttonStyle(.plain)
                .disabled(session.isAnswered)
            }
        }
    }

    private func state(for index: Int, question: Question) -> OptionRow.State {
        guard let selection = session.selection else { return .idle }
        if index == question.answerIndex { return .correct }
        if index == selection { return .wrong }
        return .dimmed
    }

    private func explanation(_ question: Question) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            let isCorrect = session.selection == question.answerIndex

            HStack(spacing: 8) {
                Image(systemName: isCorrect ? "checkmark.seal.fill" : "xmark.octagon.fill")
                    .foregroundStyle(isCorrect ? .hgGreen : .hgRed)
                Text(isCorrect ? "정답" : "오답")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(isCorrect ? .hgGreen : .hgRed)
                Spacer()
            }

            MarkdownText(raw: question.explanation, font: .system(size: 14), color: .hgText)

            HStack(spacing: 6) {
                Image(systemName: "book.closed")
                    .font(.system(size: 11))
                Text("\(question.sourceIndex) \(question.sourceTitle)")
                    .font(.system(size: 12))
            }
            .foregroundStyle(.hgDim)

            if let lab = question.lab {
                Button {
                    onClose()
                    router.open(lab)
                } label: {
                    Label("\(lab.title)에서 직접 확인하기", systemImage: "hammer.fill")
                        .font(.system(size: 13.5, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 11)
                        .background(Color.hgAccent.opacity(0.14), in: .rect(cornerRadius: 11))
                        .foregroundStyle(.hgAccent)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(16)
        .background(Color.hgCard, in: .rect(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(Color.hgLine, lineWidth: 1))
        .transition(.opacity.combined(with: .move(edge: .bottom)))
    }

    private var nextButton: some View {
        Button {
            withAnimation(.snappy(duration: 0.2)) { session.advance() }
        } label: {
            Text(session.index == session.questions.count - 1 ? "결과 보기" : "다음 문제")
                .font(.system(size: 16, weight: .semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(.hgBrand, in: .rect(cornerRadius: 14))
                .foregroundStyle(.white)
        }
        .buttonStyle(.plain)
        .padding(18)
        .background(.ultraThinMaterial)
    }
}

/// 그림으로 고르는 보기 — 문서의 프리뷰가 그대로 선택지가 된다.
private struct MockupOption: View {
    let entry: Entry?
    let title: String
    let state: OptionRow.State
    let revealed: Bool

    private var tint: Color {
        switch state {
        case .correct: .hgGreen
        case .wrong:   .hgRed
        default:       .hgLine
        }
    }

    var body: some View {
        VStack(spacing: 8) {
            if let entry {
                MockupView(nodes: entry.mockup, scale: 0.66)
                    .frame(width: MockupStyle.phoneSize.width * 0.66)
            }

            // 이름을 먼저 읽으면 그림을 보지 않게 되므로 채점 후에만 밝힌다.
            Text(revealed ? title : (entry?.index ?? ""))
                .font(.system(size: 11, weight: revealed ? .semibold : .regular, design: revealed ? .default : .monospaced))
                .foregroundStyle(revealed ? Color.hgText : Color.hgDim)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
        }
        .padding(10)
        .background(
            (state == .correct ? Color.hgGreen.opacity(0.1)
             : state == .wrong ? Color.hgRed.opacity(0.1)
             : Color.hgCard),
            in: .rect(cornerRadius: 14)
        )
        .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(tint.opacity(0.55), lineWidth: 1))
        .opacity(state == .dimmed ? 0.5 : 1)
    }
}

struct OptionRow: View {
    enum State { case idle, correct, wrong, dimmed }

    let text: String
    let state: State

    var body: some View {
        HStack(alignment: .top, spacing: 11) {
            Image(systemName: symbol)
                .font(.system(size: 15))
                .foregroundStyle(tint)
                .padding(.top, 1)

            MarkdownText(raw: text, font: .system(size: 14.5), color: state == .dimmed ? .hgDim : .hgText)

            Spacer(minLength: 0)
        }
        .padding(13)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(background, in: .rect(cornerRadius: 13))
        .overlay(RoundedRectangle(cornerRadius: 13).strokeBorder(tint.opacity(borderOpacity), lineWidth: 1))
        .opacity(state == .dimmed ? 0.55 : 1)
    }

    private var symbol: String {
        switch state {
        case .idle:    "circle"
        case .correct: "checkmark.circle.fill"
        case .wrong:   "xmark.circle.fill"
        case .dimmed:  "circle"
        }
    }

    private var tint: Color {
        switch state {
        case .idle:    .hgDim
        case .correct: .hgGreen
        case .wrong:   .hgRed
        case .dimmed:  .hgLine
        }
    }

    private var background: Color {
        switch state {
        case .correct: Color.hgGreen.opacity(0.1)
        case .wrong:   Color.hgRed.opacity(0.1)
        default:       Color.hgCard
        }
    }

    private var borderOpacity: Double {
        switch state {
        case .idle, .dimmed: 0.5
        default:             0.4
        }
    }
}
