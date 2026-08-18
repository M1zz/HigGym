import SwiftUI

/// 7.1 Menu — 버튼 하나 뒤에 접어둔 액션 목록.
/// 메뉴는 **열어봐야** 구조가 보인다. 섹션·서브메뉴·토글·파괴적 액션이 전부 실제로 동작한다.
@MainActor
enum MenuDemos {
    static let all: [EntryDemo] = [
        EntryDemo(
            "mn1",
            hints: [
                "오른쪽 위 **⋯** 를 열어보세요 — 아이콘 · 구분선 · 서브메뉴 · 토글 · 삭제가 모두 들어 있습니다.",
                "정렬과 표시 옵션을 바꾸면 목록이 **실제로** 바뀝니다. 메뉴는 창고가 아니라 조작 장치입니다.",
                "행을 **길게 눌러** 보세요 — 같은 액션이 대상 위에 직접 붙습니다(8.1.7 직접 조작).",
            ],
            code: """
            Menu("더보기", systemImage: "ellipsis") {
                Picker("정렬", selection: $sort) { /* … */ }
                Divider()
                Toggle("읽지 않음만", isOn: $unreadOnly)
                Menu("보기") { /* 서브메뉴 */ }
                Divider()
                Button("모두 삭제", systemImage: "trash", role: .destructive) { … }
            }

            // 대상 위에서 바로 — 행에는 contextMenu
            .contextMenu { … }
            """
        ) { MenuDemoScreen() },
    ]
}

private struct MenuDemoScreen: View {
    private enum Sort: String, CaseIterable, Identifiable {
        case recent = "최신순", sender = "보낸사람", subject = "제목"
        var id: String { rawValue }
    }

    private enum Density: String, CaseIterable, Identifiable {
        case comfy = "여유롭게", compact = "빽빽하게"
        var id: String { rawValue }
    }

    @State private var sort = Sort.recent
    @State private var density = Density.comfy
    @State private var unreadOnly = false
    @State private var rows = DemoData.mail
    @State private var log = DemoLog()

    private var visible: [DemoMail] {
        let base = unreadOnly ? rows.filter(\.unread) : rows
        switch sort {
        case .recent:  return base
        case .sender:  return base.sorted { $0.sender < $1.sender }
        case .subject: return base.sorted { $0.subject < $1.subject }
        }
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    DemoNote(text: "메뉴에서 무엇을 바꾸든 **이 목록이 바로 반응합니다**. 지금 정렬: \(sort.rawValue) · \(unreadOnly ? "안 읽음만" : "전체")")
                        .listRowInsets(.init(top: 6, leading: 12, bottom: 6, trailing: 12))
                }
                ForEach(visible) { mail in
                    DemoMailRow(mail: mail)
                        .padding(.vertical, density == .comfy ? 4 : 0)
                        .contextMenu {
                            Button(mail.unread ? "읽음으로 표시" : "안 읽음으로 표시",
                                   systemImage: mail.unread ? "envelope.open" : "envelope.badge") {
                                toggleRead(mail)
                            }
                            Button("보낸사람으로 정렬", systemImage: "arrow.up.arrow.down") { sort = .sender }
                            Divider()
                            Button("삭제", systemImage: "trash", role: .destructive) { remove(mail) }
                        }
                }
            }
            .listStyle(.plain)
            .animation(.snappy(duration: 0.25), value: sort)
            .animation(.snappy(duration: 0.25), value: unreadOnly)
            .navigationTitle("메일")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu("더보기", systemImage: "ellipsis") {
                        Picker("정렬", selection: $sort) {
                            ForEach(Sort.allCases) { option in
                                Label(option.rawValue, systemImage: "arrow.up.arrow.down").tag(option)
                            }
                        }

                        Divider()

                        Toggle(isOn: $unreadOnly) {
                            Label("읽지 않음만 보기", systemImage: "envelope.badge")
                        }

                        Menu {
                            Picker("밀도", selection: $density) {
                                ForEach(Density.allCases) { Text($0.rawValue).tag($0) }
                            }
                        } label: {
                            Label("보기", systemImage: "textformat.size")
                        }

                        Divider()

                        Button("모두 읽음으로 표시", systemImage: "envelope.open") {
                            rows = rows.map { var m = $0; m.unread = false; return m }
                            log.tap("모두 읽음으로 표시했습니다")
                        }
                        Button("모두 삭제", systemImage: "trash", role: .destructive) {
                            withAnimation { rows.removeAll() }
                            log.tap("전부 삭제했습니다")
                        }
                    }
                }
                ToolbarItemGroup(placement: .bottomBar) {
                    Spacer()
                    Button("되돌리기", systemImage: "arrow.uturn.backward") {
                        withAnimation { rows = DemoData.mail }
                        log.tap("원래대로 되돌렸습니다")
                    }
                }
            }
        }
        .demoToast(log)
    }

    private func toggleRead(_ mail: DemoMail) {
        guard let index = rows.firstIndex(of: mail) else { return }
        rows[index].unread.toggle()
    }

    private func remove(_ mail: DemoMail) {
        withAnimation { rows.removeAll { $0.id == mail.id } }
    }
}
