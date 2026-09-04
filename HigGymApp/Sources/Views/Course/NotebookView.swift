import SwiftUI
import UIKit

/// 학습자가 남긴 글만 모아 놓은 탭.
///
/// 이 앱이 저장하는 것은 점수가 아니라 **자기 문장**이다. 나중에 다시 읽을 때
/// 값을 하는 것도 정답이 아니라 그때 자기가 뭘 느꼈는지 쪽이라서, 통째로 복사해 나갈 수 있게 뒀다.
struct NotebookView: View {
    @Environment(NotebookStore.self) private var notebook
    @State private var copied = false
    @State private var editing: Lesson?
    /// 마크다운 파일로 내보내기 — 남긴 글은 앱 밖으로 나갈 수 있어야 한다.
    @State private var exportURL: URL?

    private var written: [Lesson] {
        Lesson.all.filter { !notebook.note(for: $0).isEmpty }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    if written.isEmpty {
                        empty
                    } else {
                        summary
                        ForEach(written) { lesson in
                            NoteCard(lesson: lesson, note: notebook.note(for: lesson)) {
                                editing = lesson
                            }
                        }
                    }
                }
                .padding(18)
            }
            .background(Color.hgBackground)
            .navigationTitle("노트")
            .toolbar {
                if !written.isEmpty {
                    ToolbarItem(placement: .topBarTrailing) {
                        Menu("내보내기", systemImage: "square.and.arrow.up") {
                            Button {
                                UIPasteboard.general.string = notebook.plainText
                                withAnimation { copied = true }
                            } label: {
                                Label(copied ? "복사됨" : "텍스트로 복사", systemImage: copied ? "checkmark" : "doc.on.doc")
                            }
                            if let exportURL {
                                ShareLink(item: exportURL) {
                                    Label("마크다운 파일로 내보내기", systemImage: "doc.text")
                                }
                            }
                        }
                    }
                }
            }
            .task(id: notebook.notes) { refreshExport() }
        }
        .fullScreenCover(item: $editing) { lesson in
            LessonPlayerView(lesson: lesson) { editing = nil }
        }
    }

    /// 공유 시트는 항목을 미리 요구하므로, 글이 바뀔 때마다 임시 파일을 다시 써 둔다.
    private func refreshExport() {
        guard !written.isEmpty else { exportURL = nil; return }
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("앱 디자인 실습 학습 노트.md")
        do {
            try notebook.plainText.write(to: url, atomically: true, encoding: .utf8)
            exportURL = url
        } catch {
            exportURL = nil
        }
    }

    private var empty: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("아직 쓴 글이 없습니다")
                .font(.callout.weight(.semibold))
                .foregroundStyle(.hgText)
            Text("**학습** 탭에서 레슨을 하나 마치면, 그때 쓴 느낀 점과 배운 것이 여기에 쌓입니다. 쌓인 글은 텍스트로 복사하거나 **마크다운 파일로 내보낼** 수 있습니다.")
                .font(.subheadline)
                .foregroundStyle(.hgMuted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.hgCard, in: .rect(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(Color.hgLine, lineWidth: 1))
    }

    private var summary: some View {
        HStack(spacing: 18) {
            stat("쓴 레슨", "\(written.count)")
            stat("마친 레슨", "\(notebook.completedCount)")
            stat("전체", "\(Lesson.all.count)")
            Spacer()
        }
        .padding(14)
        .background(Color.hgCard, in: .rect(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Color.hgLine, lineWidth: 1))
    }

    private func stat(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value)
                .font(.system(.headline, design: .rounded, weight: .bold))
                .foregroundStyle(.hgAccent)
            Text(label)
                .font(.caption)
                .foregroundStyle(.hgDim)
        }
    }
}

private struct NoteCard: View {
    let lesson: Lesson
    let note: LessonNote
    let onEdit: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Text("\(lesson.number)")
                    .font(.system(.caption, design: .monospaced, weight: .bold))
                    .foregroundStyle(.hgAccent)
                Text(lesson.title)
                    .font(.callout.weight(.bold))
                    .foregroundStyle(.hgText)
                    .multilineTextAlignment(.leading)
                Spacer(minLength: 4)
                if note.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.subheadline)
                        .foregroundStyle(.hgGreen)
                }
            }

            if !note.impression.isEmpty {
                passage("써보고 느낀 것", note.impression, .hgAmber)
            }
            if !note.takeaway.isEmpty {
                passage("배운 것", note.takeaway, .hgGreen)
            }

            HStack(spacing: 6) {
                ForEach(lesson.sources, id: \.self) { Pill(text: $0) }
                Spacer()
                Button(action: onEdit) {
                    Label("다시 하기", systemImage: "arrow.counterclockwise")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.hgAccent)
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color.hgCard, in: .rect(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(Color.hgLine, lineWidth: 1))
    }

    private func passage(_ label: String, _ body: String, _ tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption.weight(.bold))
                .foregroundStyle(tint)
            Text(body)
                .font(.subheadline)
                .foregroundStyle(.hgText)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(11)
        .background(tint.opacity(0.07), in: .rect(cornerRadius: 11))
    }
}
