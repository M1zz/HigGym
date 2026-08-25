import SwiftUI

/// 화면을 보고 판단하는 퀴즈의 진행 화면.
///
/// 보기가 글이 아니라 **돌아가는 화면**이라는 게 이 퀴즈의 전부다. 그래서 고르기 전에
/// 두 화면을 실제로 만져볼 수 있고, 고른 뒤에는 왜 그런지가 화면 아래 그대로 붙는다.
struct LiveQuizPlayView: View {
    let kind: LiveQuestion.Kind
    let onClose: () -> Void

    @Environment(ProgressStore.self) private var progress

    @State private var questions: [LiveQuestion] = []
    @State private var index = 0
    @State private var chosen: Int?
    @State private var results: [Bool] = []
    @State private var zoomed: LiveOption?

    private var question: LiveQuestion? { index < questions.count ? questions[index] : nil }
    private var answered: Bool { chosen != nil }

    var body: some View {
        VStack(spacing: 0) {
            header

            if let question {
                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        promptCard(question)

                        switch question.kind {
                        case .pickScreen: screenOptions(question)
                        case .reason:     reasonBlock(question)
                        }

                        if answered { verdict(question) }
                    }
                    .padding(16)
                    .padding(.bottom, 90)
                }
                .safeAreaInset(edge: .bottom) { footer(question) }
            } else {
                LiveQuizResultView(results: results, kind: kind, onClose: onClose) {
                    start()
                }
            }
        }
        .background(Color.hgBackground)
        .onAppear { if questions.isEmpty { start() } }
        .fullScreenCover(item: $zoomed) { option in
            ZStack(alignment: .topTrailing) {
                option.screen?()
                Button { zoomed = nil } label: {
                    Label("닫기", systemImage: "xmark")
                        .font(.footnote.weight(.bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12).padding(.vertical, 8)
                        .background(Color.hgAccent, in: .capsule)
                }
                .buttonStyle(.plain)
                .padding(.top, 4)
                .padding(.trailing, 12)
            }
        }
    }

    private func start() {
        questions = LiveQuizBank.questions(kind: kind).shuffled()
        index = 0
        chosen = nil
        results = []
    }

    // MARK: 머리

    private var header: some View {
        HStack(spacing: 10) {
            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.hgMuted)
                    .frame(width: 32, height: 32)
                    .background(Color.hgCard, in: .circle)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 2) {
                Text(kind.title)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.hgText)
                Text(questions.isEmpty ? "" : "\(min(index + 1, questions.count)) / \(questions.count)")
                    .font(.system(.caption, design: .monospaced))
                    .foregroundStyle(.hgDim)
            }

            Spacer()

            if !results.isEmpty {
                Text("\(results.filter { $0 }.count)")
                    .font(.system(.callout, design: .rounded, weight: .bold))
                    .foregroundStyle(.hgGreen)
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 10)
    }

    // MARK: 문제

    private func promptCard(_ question: LiveQuestion) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            Label(question.kind == .pickScreen ? "기준" : "질문", systemImage: question.kind.symbol)
                .font(.caption.weight(.bold))
                .foregroundStyle(.hgAccent2)
            MarkdownText(raw: question.prompt, font: .callout, color: .hgText)
            Label(question.lookAt, systemImage: "eye")
                .font(.caption)
                .foregroundStyle(.hgDim)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color.hgAccent2.opacity(0.07), in: .rect(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Color.hgAccent2.opacity(0.25), lineWidth: 1))
    }

    // MARK: 화면 고르기

    private func screenOptions(_ question: LiveQuestion) -> some View {
        GeometryReader { geo in
            let width = (geo.size.width - 12) / 2
            HStack(alignment: .top, spacing: 12) {
                ForEach(Array(question.options.enumerated()), id: \.element.id) { position, option in
                    screenOption(option, at: position, width: width, question: question)
                }
            }
        }
        .frame(height: 430)
    }

    private func screenOption(_ option: LiveOption, at position: Int, width: CGFloat, question: LiveQuestion) -> some View {
        let picked = chosen == position
        let tint: Color = answered ? (option.isCorrect ? .hgGreen : (picked ? .hgRed : .hgLine)) : (picked ? .hgAccent : .hgLine)

        return VStack(spacing: 7) {
            DemoMiniPhone(width: width, maxHeight: 330) { option.screen?() }
                .overlay(RoundedRectangle(cornerRadius: 18).strokeBorder(tint, lineWidth: picked || (answered && option.isCorrect) ? 2.5 : 1))
                .overlay(alignment: .topTrailing) {
                    if answered {
                        Image(systemName: option.isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .font(.title3)
                            .foregroundStyle(option.isCorrect ? .hgGreen : .hgRed)
                            .background(Circle().fill(.background))
                            .padding(6)
                    }
                }

            Button {
                if answered { zoomed = option } else { withAnimation(.snappy(duration: 0.15)) { chosen = position } }
            } label: {
                Label(answered ? "크게 보기" : option.label, systemImage: answered ? "arrow.up.left.and.arrow.down.right" : (picked ? "largecircle.fill.circle" : "circle"))
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(answered ? .hgAccent : (picked ? .hgAccent : .hgMuted))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 7)
                    .background(picked && !answered ? Color.hgAccent.opacity(0.12) : Color.hgCard, in: .rect(cornerRadius: 9))
            }
            .buttonStyle(.plain)

            if answered {
                MarkdownText(raw: option.note, font: .caption, color: .hgMuted)
                    .multilineTextAlignment(.center)
            }
        }
        .contentShape(.rect)
        .onTapGesture {
            guard !answered else { return }
            withAnimation(.snappy(duration: 0.15)) { chosen = position }
        }
    }

    // MARK: 이유 고르기

    private func reasonBlock(_ question: LiveQuestion) -> some View {
        VStack(spacing: 12) {
            if let subject = question.subject {
                DemoMiniPhone(width: 250, maxHeight: 330) { subject() }
                    .overlay(RoundedRectangle(cornerRadius: 18).strokeBorder(Color.hgLine, lineWidth: 1))
                    .frame(maxWidth: .infinity)
            }

            VStack(spacing: 8) {
                ForEach(Array(question.options.enumerated()), id: \.element.id) { position, option in
                    reasonOption(option, at: position)
                }
            }
        }
    }

    private func reasonOption(_ option: LiveOption, at position: Int) -> some View {
        let picked = chosen == position
        let show = answered && (option.isCorrect || picked)
        let tint: Color = answered ? (option.isCorrect ? .hgGreen : (picked ? .hgRed : .hgLine)) : (picked ? .hgAccent : .hgLine)

        return Button {
            guard !answered else { return }
            withAnimation(.snappy(duration: 0.15)) { chosen = position }
        } label: {
            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .top, spacing: 9) {
                    Image(systemName: answered
                          ? (option.isCorrect ? "checkmark.circle.fill" : (picked ? "xmark.circle.fill" : "circle"))
                          : (picked ? "largecircle.fill.circle" : "circle"))
                        .font(.callout)
                        .foregroundStyle(tint == .hgLine ? .hgDim : tint)
                    Text(option.label)
                        .font(.subheadline)
                        .foregroundStyle(.hgText)
                        .multilineTextAlignment(.leading)
                    Spacer(minLength: 0)
                }
                if show {
                    MarkdownText(raw: option.note, font: .footnote, color: .hgMuted)
                        .padding(.leading, 24)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(Color.hgCard, in: .rect(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(tint, lineWidth: picked || (answered && option.isCorrect) ? 2 : 1))
        }
        .buttonStyle(.plain)
    }

    // MARK: 판정

    private func verdict(_ question: LiveQuestion) -> some View {
        let correct = chosen == question.correctIndex
        return VStack(alignment: .leading, spacing: 9) {
            Label(correct ? "맞았습니다" : "다시 보세요", systemImage: correct ? "checkmark.seal.fill" : "xmark.octagon.fill")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(correct ? .hgGreen : .hgRed)

            MarkdownText(raw: question.explanation, font: .subheadline, color: .hgText)

            HStack(spacing: 6) {
                ForEach(question.sources, id: \.self) { Pill(text: $0) }
                if let number = question.mistakeNumber {
                    Label("실수 #\(number)", systemImage: "exclamationmark.triangle.fill")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.hgAmber)
                        .padding(.horizontal, 8).padding(.vertical, 3)
                        .background(Color.hgAmber.opacity(0.12), in: .capsule)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background((correct ? Color.hgGreen : Color.hgRed).opacity(0.08), in: .rect(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder((correct ? Color.hgGreen : Color.hgRed).opacity(0.3), lineWidth: 1)
        )
    }

    // MARK: 발

    private func footer(_ question: LiveQuestion) -> some View {
        Button {
            if answered {
                withAnimation(.snappy(duration: 0.2)) {
                    index += 1
                    chosen = nil
                }
            } else if let chosen {
                let correct = chosen == question.correctIndex
                results.append(correct)
                progress.recordLive(question.id, correct: correct)
                withAnimation(.snappy(duration: 0.2)) { self.chosen = chosen }
            }
        } label: {
            Text(answered ? (index + 1 < questions.count ? "다음 문항" : "결과 보기") : "확인")
                .font(.callout.weight(.semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(chosen == nil ? AnyShapeStyle(Color.hgLine) : AnyShapeStyle(.hgBrand), in: .rect(cornerRadius: 14))
        }
        .buttonStyle(.plain)
        .disabled(chosen == nil)
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
        .background(.ultraThinMaterial)
    }
}

// MARK: - 결과

private struct LiveQuizResultView: View {
    let results: [Bool]
    let kind: LiveQuestion.Kind
    let onClose: () -> Void
    let onRetry: () -> Void

    private var correct: Int { results.filter { $0 }.count }

    var body: some View {
        VStack(spacing: 18) {
            Spacer()

            Text("\(correct) / \(results.count)")
                .font(.system(.largeTitle, design: .rounded, weight: .bold))
                .foregroundStyle(.hgAccent)

            Text(correct == results.count
                 ? "전부 맞혔습니다. 이제 같은 판단을 실무 화면에서 해보세요."
                 : "틀린 문항의 화면을 다시 열어 두 쪽을 나란히 보면 차이가 남습니다.")
                .font(.subheadline)
                .foregroundStyle(.hgMuted)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)

            Spacer()

            VStack(spacing: 10) {
                Button(action: onRetry) {
                    Text("다시 풀기")
                        .font(.callout.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(.hgBrand, in: .rect(cornerRadius: 14))
                }
                .buttonStyle(.plain)

                Button(action: onClose) {
                    Text("닫기")
                        .font(.callout)
                        .foregroundStyle(.hgMuted)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
