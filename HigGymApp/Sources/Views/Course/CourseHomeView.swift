import SwiftUI

/// 앱의 첫 화면 — 여덟 편짜리 코스.
///
/// 목록이지만 도감이 아니다. 순서가 있고, 어디까지 왔는지가 보이고,
/// 무엇보다 **이어서 할 곳**이 맨 위에 있다.
struct CourseHomeView: View {
    @Environment(NotebookStore.self) private var notebook
    @State private var playing: Lesson?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    intro
                    resumeCard

                    SectionLabel("여덟 편", accent: .hgAccent)
                    ForEach(Lesson.all) { lesson in
                        LessonRow(lesson: lesson, note: notebook.note(for: lesson)) {
                            playing = lesson
                        }
                    }

                    footnote
                }
                .padding(18)
            }
            .background(Color.hgBackground)
            .navigationTitle("학습")
            .task {
                if let id = DebugLaunch.lessonID { playing = Lesson.lesson(id) }
            }
        }
        .fullScreenCover(item: $playing) { lesson in
            LessonPlayerView(lesson: lesson) { playing = nil }
        }
    }

    private var intro: some View {
        Text("한 편에 결정 하나입니다. **직접 써보고 → 느낀 것을 적고 → 이유를 확인하고 → 어긴 화면과 비교하고 → 배운 것을 남깁니다.** 쓰는 칸이 있어야 남기 때문에 순서를 건너뛸 수 없게 두었습니다.")
            .font(.system(size: 14))
            .foregroundStyle(.hgMuted)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var resumeCard: some View {
        let done = notebook.completedCount
        let total = Lesson.all.count
        let next = notebook.next

        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(done == 0 ? "아직 시작 전입니다" : "\(done) / \(total) 편 마침")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(done == 0 ? .hgDim : .hgText)
                Spacer()
                if done > 0 {
                    Text("\(Int(Double(done) / Double(total) * 100))%")
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                        .foregroundStyle(.hgAccent)
                }
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.hgFill)
                    Capsule().fill(.hgBrand)
                        .frame(width: geo.size.width * CGFloat(done) / CGFloat(total))
                }
            }
            .frame(height: 6)

            if let next {
                Button { playing = next } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "play.fill")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 32, height: 32)
                            .background(.hgBrand, in: .rect(cornerRadius: 9))
                        VStack(alignment: .leading, spacing: 1) {
                            Text(done == 0 ? "1편부터 시작하기" : "이어서 하기")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(.hgText)
                            Text("\(next.number). \(next.title)")
                                .font(.system(size: 12))
                                .foregroundStyle(.hgDim)
                                .lineLimit(1)
                        }
                        Spacer(minLength: 4)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(.hgDim)
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(14)
        .background(Color.hgCard, in: .rect(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(Color.hgAccent.opacity(0.35), lineWidth: 1))
    }

    private var footnote: some View {
        Text("여덟 편이 다루는 화면은 전부 같은 앱 한 벌입니다. 결정 하나만 뒤집어 같은 앱이 어떻게 나빠지는지 봅니다. 더 넓은 자료(항목 68 · 실수 100 · 원칙 7)는 **자료** 탭에 있습니다.")
            .font(.system(size: 12))
            .foregroundStyle(.hgDim)
            .padding(.top, 4)
    }
}

private struct LessonRow: View {
    let lesson: Lesson
    let note: LessonNote
    let action: () -> Void

    private var state: (label: String, color: Color, symbol: String) {
        if note.isCompleted { return ("마침", .hgGreen, "checkmark.circle.fill") }
        if !note.isEmpty { return ("쓰는 중", .hgAmber, "ellipsis.circle.fill") }
        return ("", .hgDim, "circle")
    }

    var body: some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: 12) {
                Text("\(lesson.number)")
                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                    .foregroundStyle(note.isCompleted ? .hgGreen : .hgAccent)
                    .frame(width: 30, height: 30)
                    .background(
                        (note.isCompleted ? Color.hgGreen : Color.hgAccent).opacity(0.12),
                        in: .rect(cornerRadius: 9)
                    )

                VStack(alignment: .leading, spacing: 3) {
                    Text(lesson.title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.hgText)
                        .multilineTextAlignment(.leading)
                    Text(lesson.subtitle)
                        .font(.system(size: 12.5))
                        .foregroundStyle(.hgMuted)
                        .multilineTextAlignment(.leading)

                    if !state.label.isEmpty {
                        Label(state.label, systemImage: state.symbol)
                            .font(.system(size: 10.5, weight: .bold))
                            .foregroundStyle(state.color)
                            .padding(.top, 2)
                    }
                }

                Spacer(minLength: 0)

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.hgDim)
                    .padding(.top, 8)
            }
            .padding(13)
            .background(Color.hgCard, in: .rect(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(note.isCompleted ? Color.hgGreen.opacity(0.35) : Color.hgLine, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}
