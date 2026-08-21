import SwiftUI

/// 레슨 한 편을 다섯 단계로 진행하는 화면.
///
/// 순서가 중요하다. **먼저 써보게 하고, 답을 보기 전에 쓰게 한다.** 답을 먼저 보면
/// "알고 있었다"고 느끼고 넘어가지만, 자기 문장으로 써본 뒤에 답을 보면 어긋난 지점이 남는다.
struct LessonPlayerView: View {
    let lesson: Lesson
    let onClose: () -> Void

    @Environment(NotebookStore.self) private var notebook

    @State private var step = Step.use
    @State private var impression = ""
    @State private var takeaway = ""
    @State private var showReference = false

    enum Step: Int, CaseIterable, Identifiable {
        case use, write, reveal, compare, takeaway
        var id: Int { rawValue }

        var title: String {
            switch self {
            case .use:      "써보기"
            case .write:    "적어보기"
            case .reveal:   "이유 확인"
            case .compare:  "비교"
            case .takeaway: "배운 것"
            }
        }
        var symbol: String {
            switch self {
            case .use:      "hand.tap"
            case .write:    "square.and.pencil"
            case .reveal:   "lightbulb"
            case .compare:  "arrow.left.arrow.right"
            case .takeaway: "checkmark.seal"
            }
        }
        /// 화면 전체를 써야 하는 단계 — 앱을 실제 크기로 보여준다.
        var isFullBleed: Bool { self == .use || self == .compare }
    }

    var body: some View {
        VStack(spacing: 0) {
            header

            Group {
                switch step {
                case .use:      useStep
                case .write:    writeStep
                case .reveal:   revealStep
                case .compare:  compareStep
                case .takeaway: takeawayStep
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            footer
        }
        .background(Color.hgBackground)
        .onAppear {
            let note = notebook.note(for: lesson)
            impression = note.impression
            takeaway = note.takeaway
            if let raw = DebugLaunch.lessonStep, let target = Step(rawValue: raw) { step = target }
        }
        .onChange(of: step) { _, _ in save() }
        .sheet(isPresented: $showReference) {
            LessonReferenceSheet(lesson: lesson)
        }
    }

    private func save() {
        var note = notebook.note(for: lesson)
        note.impression = impression
        note.takeaway = takeaway
        notebook.write(note, for: lesson)
    }

    // MARK: 머리 — 지금 어느 단계인가

    private var header: some View {
        VStack(spacing: 9) {
            HStack(spacing: 10) {
                Button {
                    save()
                    onClose()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.hgMuted)
                        .frame(width: 30, height: 30)
                        .background(Color.hgCard, in: .circle)
                }
                .buttonStyle(.plain)

                VStack(alignment: .leading, spacing: 1) {
                    Text("\(lesson.number). \(lesson.title)")
                        .font(.system(size: 13.5, weight: .bold))
                        .foregroundStyle(.hgText)
                        .lineLimit(1)
                    Text(lesson.subtitle)
                        .font(.system(size: 11))
                        .foregroundStyle(.hgDim)
                        .lineLimit(1)
                }

                Spacer(minLength: 4)

                Button { showReference = true } label: {
                    Image(systemName: "book")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.hgAccent)
                        .frame(width: 30, height: 30)
                        .background(Color.hgCard, in: .circle)
                }
                .buttonStyle(.plain)
            }

            HStack(spacing: 6) {
                ForEach(Step.allCases) { item in
                    let done = item.rawValue < step.rawValue
                    let now = item == step
                    HStack(spacing: 4) {
                        Image(systemName: done ? "checkmark" : item.symbol)
                            .font(.system(size: 9, weight: .bold))
                        if now {
                            Text(item.title).font(.system(size: 10, weight: .bold))
                        }
                    }
                    .foregroundStyle(now ? .white : (done ? .hgGreen : .hgDim))
                    .padding(.horizontal, now ? 9 : 7)
                    .padding(.vertical, 5)
                    .background(
                        now ? AnyShapeStyle(.hgBrand) : AnyShapeStyle(Color.hgCard),
                        in: .capsule
                    )
                    .animation(.snappy(duration: 0.2), value: step)
                }
                Spacer(minLength: 0)
            }
        }
        .padding(.horizontal, 14)
        .padding(.bottom, 10)
    }

    // MARK: ① 써보기

    private var useStep: some View {
        VStack(spacing: 0) {
            taskCard

            lesson.knob.surface(.recommended)
                .clipShape(.rect(cornerRadius: 18))
                .overlay(RoundedRectangle(cornerRadius: 18).strokeBorder(Color.hgLine, lineWidth: 1))
                .padding(.horizontal, 8)
                .padding(.bottom, 6)
        }
    }

    private var taskCard: some View {
        HStack(alignment: .top, spacing: 9) {
            Image(systemName: "hand.tap.fill")
                .font(.system(size: 12))
                .foregroundStyle(.hgAmber)
                .padding(.top, 1)
            VStack(alignment: .leading, spacing: 3) {
                Text("해볼 것")
                    .font(.system(size: 10.5, weight: .bold))
                    .foregroundStyle(.hgAmber)
                MarkdownText(raw: lesson.task, font: .system(size: 13.5), color: .hgText)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color.hgAmber.opacity(0.1), in: .rect(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(Color.hgAmber.opacity(0.3), lineWidth: 1))
        .padding(.horizontal, 12)
        .padding(.bottom, 8)
    }

    // MARK: ② 적어보기

    private var writeStep: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                questionCard

                LessonEditor(
                    text: $impression,
                    placeholder: lesson.placeholder,
                    minHeight: 190
                )

                Text("정답을 맞히는 칸이 아닙니다. 방금 손으로 겪은 것을 그대로 적으면 됩니다. 다음 단계에서 기준과 나란히 놓고 볼 겁니다.")
                    .font(.system(size: 12))
                    .foregroundStyle(.hgDim)
            }
            .padding(16)
        }
    }

    private var questionCard: some View {
        VStack(alignment: .leading, spacing: 7) {
            Label("질문", systemImage: "questionmark.circle")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(.hgAccent2)
            MarkdownText(raw: lesson.question, font: .system(size: 15), color: .hgText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color.hgAccent2.opacity(0.07), in: .rect(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Color.hgAccent2.opacity(0.25), lineWidth: 1))
    }

    // MARK: ③ 이유 확인 — 내가 쓴 것과 나란히

    private var revealStep: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                if !impression.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        Label("내가 쓴 것", systemImage: "person.fill")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(.hgDim)
                        Text(impression)
                            .font(.system(size: 14))
                            .foregroundStyle(.hgText)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(14)
                    .background(Color.hgFill, in: .rect(cornerRadius: 14))
                    .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Color.hgLine, lineWidth: 1))
                }

                block("이 앱이 한 결정", lesson.decision.decision, .hgAccent, "checkmark.circle")
                block("왜 그렇게 했나", lesson.decision.why, .hgAccent2, "lightbulb")
                block("뒤집으면", lesson.decision.ifFlipped, .hgRed, "exclamationmark.triangle")

                HStack(spacing: 6) {
                    Text("근거")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.hgDim)
                    ForEach(lesson.decision.sources, id: \.self) { Pill(text: $0) }
                    Spacer()
                    Button {
                        showReference = true
                    } label: {
                        Label("본문 보기", systemImage: "book")
                            .font(.system(size: 11.5, weight: .semibold))
                            .foregroundStyle(.hgAccent)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(16)
        }
    }

    private func block(_ title: String, _ body: String, _ tint: Color, _ symbol: String) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            Label(title, systemImage: symbol)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(tint)
            MarkdownText(raw: body, font: .system(size: 14), color: .hgText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(tint.opacity(0.06), in: .rect(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(tint.opacity(0.22), lineWidth: 1))
    }

    // MARK: ④ 비교

    private var compareStep: some View {
        ABCompareView(knob: lesson.knob, diff: lesson.diff)
    }

    // MARK: ⑤ 배운 것

    private var takeawayStep: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                VStack(alignment: .leading, spacing: 7) {
                    Label("이 레슨에서 배운 것", systemImage: "checkmark.seal")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.hgGreen)
                    Text("다음에 같은 상황을 만났을 때 꺼내 쓸 수 있는 문장으로 적어보세요. 남긴 글은 **노트** 탭에 쌓입니다.")
                        .font(.system(size: 13.5))
                        .foregroundStyle(.hgMuted)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(14)
                .background(Color.hgGreen.opacity(0.07), in: .rect(cornerRadius: 14))
                .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Color.hgGreen.opacity(0.25), lineWidth: 1))

                LessonEditor(
                    text: $takeaway,
                    placeholder: "예: 자리를 정할 땐 중요도가 아니라 하루에 몇 번 누르는지를 먼저 센다.",
                    minHeight: 160
                )

                VStack(alignment: .leading, spacing: 6) {
                    Text("이 레슨의 기준")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.hgDim)
                    MarkdownText(raw: lesson.decision.why, font: .system(size: 12.5), color: .hgDim)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(16)
        }
    }

    // MARK: 발 — 다음으로

    private var footer: some View {
        HStack(spacing: 10) {
            if step != .use {
                Button {
                    withAnimation(.snappy(duration: 0.2)) {
                        step = Step(rawValue: step.rawValue - 1) ?? .use
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.hgMuted)
                        .frame(width: 46, height: 46)
                        .background(Color.hgCard, in: .rect(cornerRadius: 13))
                }
                .buttonStyle(.plain)
            }

            Button {
                if step == .takeaway {
                    save()
                    notebook.complete(lesson)
                    onClose()
                } else {
                    withAnimation(.snappy(duration: 0.2)) {
                        step = Step(rawValue: step.rawValue + 1) ?? .takeaway
                    }
                }
            } label: {
                Text(nextLabel)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(.hgBrand, in: .rect(cornerRadius: 13))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 14)
        .padding(.bottom, 8)
    }

    private var nextLabel: String {
        switch step {
        case .use:      "다 해봤어요"
        case .write:    impression.isEmpty ? "건너뛰고 이유 보기" : "이유 확인하기"
        case .reveal:   "어긴 화면과 비교하기"
        case .compare:  "배운 것 적기"
        case .takeaway: "이 레슨 마치기"
        }
    }
}

// MARK: - 글 쓰는 칸

/// 레슨에서 쓰는 입력칸. 비어 있을 때 예시를 흐리게 깔아 무엇을 쓰라는 건지 알려준다.
private struct LessonEditor: View {
    @Binding var text: String
    let placeholder: String
    var minHeight: CGFloat = 160

    @FocusState private var focused: Bool

    var body: some View {
        ZStack(alignment: .topLeading) {
            if text.isEmpty {
                Text(placeholder)
                    .font(.system(size: 14))
                    .foregroundStyle(.hgDim)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 14)
                    .allowsHitTesting(false)
            }
            TextEditor(text: $text)
                .font(.system(size: 15))
                .foregroundStyle(.hgText)
                .scrollContentBackground(.hidden)
                .padding(.horizontal, 9)
                .padding(.vertical, 6)
                .focused($focused)
        }
        .frame(minHeight: minHeight)
        .background(Color.hgCard, in: .rect(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(focused ? Color.hgAccent : Color.hgLine, lineWidth: focused ? 2 : 1)
        )
        .toolbar {
            if focused {
                ToolbarItem(placement: .keyboard) {
                    HStack {
                        Spacer()
                        Button("완료") { focused = false }
                            .font(.system(size: 15, weight: .semibold))
                    }
                }
            }
        }
    }
}

// MARK: - 근거 자료

/// 레슨 중에 본문 항목을 꺼내 볼 수 있게 — 참고 자료는 흐름을 끊지 않고 옆에서 열린다.
private struct LessonReferenceSheet: View {
    let lesson: Lesson

    @Environment(\.dismiss) private var dismiss
    private let store = ContentStore.shared

    private var entries: [Entry] {
        lesson.decision.sources.compactMap { index in
            (store.entries + store.principles).first { $0.index == index }
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    ForEach(entries) { entry in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 7) {
                                Pill(text: entry.index)
                                Text(entry.title)
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundStyle(.hgText)
                            }
                            MarkdownText(raw: entry.summary, font: .system(size: 13.5), color: .hgMuted)
                            if !entry.why.isEmpty {
                                MarkdownText(raw: entry.why, font: .system(size: 13), color: .hgText)
                            } else if !entry.criterion.isEmpty {
                                MarkdownText(raw: entry.criterion, font: .system(size: 13), color: .hgText)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(14)
                        .background(Color.hgCard, in: .rect(cornerRadius: 14))
                        .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Color.hgLine, lineWidth: 1))
                    }
                }
                .padding(16)
            }
            .background(Color.hgBackground)
            .navigationTitle("근거 본문")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("닫기") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}
