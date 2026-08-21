import SwiftUI
import UIKit

/// 교재 전체를 한 앱에 모아 놓은 표본 — 메모 앱 "노트".
///
/// 항목 예제가 컴포넌트 하나씩을 보여준다면, 여기는 **완성된 앱 한 벌**이다.
/// 그리고 그 앱의 결정 여덟 개가 스위치로 되어 있어서, 하나만 뒤집으면
/// 같은 앱이 어떻게 나빠지는지 나란히 볼 수 있다 — 체험도 퀴즈도 이 한 벌에서 나온다.
struct NoteAppConfig: Hashable {
    enum Compose: Hashable { case bottomTrailing, topTrailing }
    enum Deletion: Hashable { case swipe, bottomBarSolo }
    enum Grouping: Hashable { case byRole, oneCapsule }
    enum TitleStyle: Hashable { case menu, extraButton }
    enum Search: Hashable { case toolbar, drawerAlways }
    enum DateStyle: Hashable { case formatStyle, hardcoded }
    enum Selection: Hashable { case enabled, disabled }
    enum EditorExit: Hashable { case toolbar, none }

    var compose: Compose = .bottomTrailing
    var deletion: Deletion = .swipe
    var grouping: Grouping = .byRole
    var title: TitleStyle = .menu
    var search: Search = .toolbar
    var date: DateStyle = .formatStyle
    var selection: Selection = .enabled
    var editorExit: EditorExit = .toolbar

    /// 기준을 다 지킨 구성. 체험용 앱이 쓰는 값이다.
    static let recommended = NoteAppConfig()

    /// 결정 하나만 뒤집은 구성 — 퀴즈의 오답 보기가 여기서 나온다.
    func flipping(_ knob: Knob) -> NoteAppConfig {
        var copy = self
        switch knob {
        case .compose:    copy.compose = .topTrailing
        case .deletion:   copy.deletion = .bottomBarSolo
        case .grouping:   copy.grouping = .oneCapsule
        case .title:      copy.title = .extraButton
        case .search:     copy.search = .drawerAlways
        case .date:       copy.date = .hardcoded
        case .selection:  copy.selection = .disabled
        case .editorExit: copy.editorExit = .none
        }
        return copy
    }

    enum Knob: String, CaseIterable, Identifiable {
        case compose, deletion, grouping, title, search, date, selection, editorExit
        var id: String { rawValue }
    }
}

// MARK: - 표본 데이터

struct SampleNote: Identifiable, Hashable {
    let id: Int
    var title: String
    var body: String
    /// 값으로 들고 있다가 표기는 로케일에 맡긴다 — 2.2.1 이 말하는 그 분리.
    let edited: Date
    var folder: String
    var unread: Bool
}

enum SampleNotes {
    /// 회고·퀴즈가 같은 데이터를 쓰도록 기준 시각을 고정한다.
    static let now = Date(timeIntervalSince1970: 1_787_000_000)

    static let all: [SampleNote] = [
        .init(id: 0, title: "스프린트 회고", body: "이번 주에 배운 것 세 가지. 첫째, 하단 바에 삭제를 두면 안 된다는 것.", edited: now.addingTimeInterval(-60 * 12), folder: "업무", unread: true),
        .init(id: 1, title: "장보기", body: "우유, 달걀, 사과 두 봉지, 커피 원두 200g", edited: now.addingTimeInterval(-60 * 90), folder: "개인", unread: true),
        .init(id: 2, title: "운송장 번호", body: "1Z 999 AA1 0123 4567 — 목요일 도착 예정", edited: now.addingTimeInterval(-60 * 60 * 26), folder: "개인", unread: false),
        .init(id: 3, title: "면접 질문 정리", body: "탭바는 목적지, 툴바는 액션. 이 구분을 어떻게 설명할 것인가.", edited: now.addingTimeInterval(-60 * 60 * 50), folder: "업무", unread: false),
        .init(id: 4, title: "읽을 것", body: "HIG Toolbars, WWDC25 세션 323, Liquid Glass 해설 글", edited: now.addingTimeInterval(-60 * 60 * 24 * 6), folder: "개인", unread: false),
        .init(id: 5, title: "이사 체크리스트", body: "인터넷 이전 신청, 우편물 주소 변경, 관리비 정산", edited: now.addingTimeInterval(-60 * 60 * 24 * 20), folder: "개인", unread: false),
    ]
}

// MARK: - 앱 한 벌

/// 실제로 쓸 수 있는 노트 앱. 목록에서 열고, 쓰고, 지우고, 검색한다.
struct SampleNoteApp: View {
    var config: NoteAppConfig = .recommended
    /// 뜯어보기에서 특정 결정을 짚을 때 그 자리를 잠깐 강조한다.
    var spotlight: NoteAppConfig.Knob?

    @State private var notes = SampleNotes.all
    @State private var query = ""
    @State private var folder = "전체"
    @State private var editing = false
    @State private var composing = false
    @State private var selection = Set<Int>()
    @State private var opened: SampleNote?

    private var visible: [SampleNote] {
        var rows = folder == "전체" ? notes : notes.filter { $0.folder == folder }
        if !query.isEmpty {
            rows = rows.filter {
                $0.title.localizedCaseInsensitiveContains(query)
                    || $0.body.localizedCaseInsensitiveContains(query)
            }
        }
        return rows
    }

    var body: some View {
        NavigationStack {
            list
                .navigationTitle(folder == "전체" ? "노트" : folder)
                .modifier(TitleMenuModifier(config: config, folder: $folder, spotlight: spotlight))
                .toolbar { toolbarContent }
                .modifier(SearchPlacement(config: config, query: $query, spotlight: spotlight))
                .navigationDestination(item: $opened) { note in
                    NoteDetailScreen(note: note, config: config, spotlight: spotlight)
                }
        }
        .fullScreenCover(isPresented: $composing) {
            NoteEditorScreen(config: config, spotlight: spotlight) { title, body in
                notes.insert(
                    SampleNote(id: (notes.map(\.id).max() ?? 0) + 1, title: title, body: body,
                               edited: SampleNotes.now, folder: folder == "전체" ? "개인" : folder, unread: false),
                    at: 0
                )
            }
        }
    }

    private var list: some View {
        List(selection: $selection) {
            ForEach(visible) { note in
                Button {
                    markRead(note)
                    opened = note
                } label: {
                    NoteRow(note: note, config: config)
                }
                .buttonStyle(.plain)
                .tag(note.id)
                .modifier(
                    RowDeletionModifier(
                        config: config,
                        spotlight: spotlight,
                        onDelete: { withAnimation { notes.removeAll { $0.id == note.id } } }
                    )
                )
            }
        }
        .listStyle(.plain)
        .environment(\.editMode, .constant(editing ? .active : .inactive))
        .overlay {
            if visible.isEmpty {
                ContentUnavailableView(
                    query.isEmpty ? "노트 없음" : "결과 없음",
                    systemImage: query.isEmpty ? "note.text" : "magnifyingglass",
                    description: Text(query.isEmpty ? "오른쪽 아래에서 새 노트를 만들어 보세요" : "다른 말로 검색해 보세요")
                )
            }
        }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        switch config.grouping {
        case .byRole:
            // 도구(정렬·선택)와 확정 액션을 자리로 나눈다 — 1.1.2 · 8.1.3.
            ToolbarItem(placement: .topBarTrailing) {
                Button(editing ? "완료" : "편집") {
                    withAnimation { editing.toggle() }
                    if !editing { selection.removeAll() }
                }
                .fontWeight(editing ? .semibold : .regular)
                .spotlightRing(spotlight == .grouping)
            }
        case .oneCapsule:
            // 성격이 다른 셋을 한 캡슐에 — 사용자는 "한 세트"로 읽는다.
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button("삭제", systemImage: "trash") {
                    if let first = visible.first { notes.removeAll { $0.id == first.id } }
                }
                Button("정렬", systemImage: "arrow.up.arrow.down") {
                    notes.sort { $0.title < $1.title }
                }
                Button("편집") { withAnimation { editing.toggle() } }
            }
        }

        switch config.compose {
        case .bottomTrailing:
            // 이 화면에서 가장 자주 하는 일 = 새 노트. 그래서 엄지 자리 — 1.1.4 · 8.1.2.
            ToolbarItemGroup(placement: .bottomBar) {
                Spacer()
                Button("새 노트", systemImage: "square.and.pencil") { composing = true }
                    .spotlightRing(spotlight == .compose)
            }
        case .topTrailing:
            ToolbarItem(placement: .topBarTrailing) {
                Button("새 노트", systemImage: "square.and.pencil") { composing = true }
            }
        }

        if config.deletion == .bottomBarSolo {
            ToolbarItemGroup(placement: .bottomBar) {
                Button("삭제", systemImage: "trash", role: .destructive) {
                    if let first = visible.first { withAnimation { notes.removeAll { $0.id == first.id } } }
                }
                Spacer()
            }
        }
    }

    private func markRead(_ note: SampleNote) {
        guard let index = notes.firstIndex(where: { $0.id == note.id }) else { return }
        notes[index].unread = false
    }
}

// MARK: - 목록의 한 줄

private struct NoteRow: View {
    let note: SampleNote
    let config: NoteAppConfig

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack(spacing: 6) {
                if note.unread {
                    Circle().fill(Color.accentColor).frame(width: 7, height: 7)
                }
                Text(note.title)
                    .font(.system(size: 16, weight: .semibold))
                    // 글자가 커져도 제목이 사라지지 않게 — 2.1.4 · 8.1.5.
                    .lineLimit(2)
                Spacer(minLength: 6)
                Text(SampleFormat.edited(note.edited, style: config.date))
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }
            Text(note.body)
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
                .lineLimit(2, reservesSpace: true)
        }
        .padding(.vertical, 3)
    }
}

/// 값은 앱이, 표기는 로케일이 — 8.1.6. 잘못된 쪽은 문자열을 직접 조립한다.
enum SampleFormat {
    static func edited(_ date: Date, style: NoteAppConfig.DateStyle) -> String {
        switch style {
        case .formatStyle:
            return date.formatted(.relative(presentation: .numeric))
        case .hardcoded:
            let calendar = Calendar(identifier: .gregorian)
            let components = calendar.dateComponents([.month, .day], from: date)
            return "\(components.month ?? 1)월 \(components.day ?? 1)일"
        }
    }
}

// MARK: - 상세

struct NoteDetailScreen: View {
    let note: SampleNote
    var config: NoteAppConfig = .recommended
    var spotlight: NoteAppConfig.Knob?

    @State private var copied = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text(note.title)
                    .font(.system(size: 24, weight: .bold))
                    .lineLimit(3)

                Text(SampleFormat.edited(note.edited, style: config.date) + " 수정 · " + note.folder)
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)

                Text(note.body)
                    .font(.system(size: 16))
                    .lineSpacing(3)
                    .modifier(SelectableModifier(config: config))
                    .spotlightRing(spotlight == .selection)

                if note.title.contains("운송장") {
                    Button {
                        UIPasteboard.general.string = "1Z 999 AA1 0123 4567"
                        withAnimation { copied = true }
                    } label: {
                        Label(copied ? "복사됨" : "번호 복사", systemImage: copied ? "checkmark" : "doc.on.doc")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .buttonStyle(.borderless)
                    .opacity(config.selection == .enabled ? 1 : 0)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(18)
        }
        .navigationTitle(note.folder)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu("더보기", systemImage: "ellipsis") {
                    Button("공유", systemImage: "square.and.arrow.up") {}
                    Divider()
                    Button("삭제", systemImage: "trash", role: .destructive) {}
                }
            }
        }
    }
}

private struct SelectableModifier: ViewModifier {
    let config: NoteAppConfig

    func body(content: Content) -> some View {
        if config.selection == .enabled {
            // 옮겨 적을 일이 있는 값이라 선택을 연다 — 2.1.5.
            content.textSelection(.enabled)
        } else {
            content.textSelection(.disabled)
        }
    }
}

// MARK: - 편집기

struct NoteEditorScreen: View {
    var config: NoteAppConfig = .recommended
    var spotlight: NoteAppConfig.Knob?
    var onSave: (String, String) -> Void = { _, _ in }

    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var body_ = ""

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 10) {
                TextField("제목", text: $title)
                    .font(.system(size: 20, weight: .semibold))
                TextEditor(text: $body_)
                    .font(.system(size: 15))
                    .scrollContentBackground(.hidden)
                    .background(.quaternary.opacity(0.4), in: .rect(cornerRadius: 12))
            }
            .padding(16)
            .navigationTitle("새 노트")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if config.editorExit == .toolbar {
                    // 전체 화면 커버는 쓸어내려 닫히지 않는다. 출구를 직접 만든다 — 4.2.1.
                    ToolbarItem(placement: .topBarLeading) {
                        Button("취소") { dismiss() }.spotlightRing(spotlight == .editorExit)
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("완료") {
                            onSave(title.isEmpty ? "제목 없음" : title, body_)
                            dismiss()
                        }
                        .fontWeight(.semibold)
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                if config.editorExit == .none {
                    // 실제 앱에는 없는 비상구 — 교재가 사용자를 가두지 않기 위한 장치.
                    Button("예제에서 나가기") { dismiss() }
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.red)
                        .padding(.vertical, 7).padding(.horizontal, 13)
                        .overlay(Capsule().strokeBorder(.red, style: .init(lineWidth: 1, dash: [4, 3])))
                        .padding(.bottom, 8)
                }
            }
        }
    }
}

// MARK: - 결정을 뒤집는 부분들

private struct TitleMenuModifier: ViewModifier {
    let config: NoteAppConfig
    @Binding var folder: String
    let spotlight: NoteAppConfig.Knob?

    private let folders = ["전체", "업무", "개인"]

    func body(content: Content) -> some View {
        switch config.title {
        case .menu:
            // 대상(폴더 이름)이 곧 버튼 — 8.1.7 직접 조작.
            content
                .toolbarTitleDisplayMode(.large)
                .toolbarTitleMenu {
                    Picker("폴더", selection: $folder) {
                        ForEach(folders, id: \.self) { Label($0, systemImage: "folder").tag($0) }
                    }
                }
        case .extraButton:
            content
                .toolbarTitleDisplayMode(.large)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Menu("폴더 변경", systemImage: "folder") {
                            Picker("폴더", selection: $folder) {
                                ForEach(folders, id: \.self) { Text($0).tag($0) }
                            }
                        }
                    }
                }
        }
    }
}

/// 검색을 어디에 둘 것인가 — 1.4.1 vs 1.4.4.
private struct SearchPlacement: ViewModifier {
    let config: NoteAppConfig
    @Binding var query: String
    let spotlight: NoteAppConfig.Knob?

    func body(content: Content) -> some View {
        switch config.search {
        case .toolbar:
            // iPhone 에서는 하단 유리 캡슐 — 엄지 자리다.
            content
                .searchable(text: $query, placement: .toolbar, prompt: "노트 검색")
                .spotlightRing(spotlight == .search)
        case .drawerAlways:
            content.searchable(
                text: $query,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "노트 검색"
            )
        }
    }
}

private struct RowDeletionModifier: ViewModifier {
    let config: NoteAppConfig
    let spotlight: NoteAppConfig.Knob?
    let onDelete: () -> Void

    func body(content: Content) -> some View {
        if config.deletion == .swipe {
            // 액션이 대상 위에 붙는다 — 8.1.7, 그리고 한 단계 거치므로 오탭이 어렵다.
            content.swipeActions(edge: .trailing) {
                Button("삭제", systemImage: "trash", role: .destructive, action: onDelete)
            }
            .spotlightRing(spotlight == .deletion)
        } else {
            content
        }
    }
}

// MARK: - 뜯어보기에서 그 자리를 짚어주는 테두리

private struct SpotlightRing: ViewModifier {
    let active: Bool
    @State private var pulse = false

    func body(content: Content) -> some View {
        content
            .background {
                if active {
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(Color.hgAmber, lineWidth: 2)
                        .padding(-5)
                        .opacity(pulse ? 0.35 : 1)
                        .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: pulse)
                        .onAppear { pulse = true }
                }
            }
    }
}

extension View {
    /// 뜯어보기에서 지금 설명 중인 자리를 감싼다.
    func spotlightRing(_ active: Bool) -> some View { modifier(SpotlightRing(active: active)) }
}
