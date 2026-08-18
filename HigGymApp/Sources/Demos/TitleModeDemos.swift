import SwiftUI

/// 1.2 Title Display Modes — 제목은 "이 화면이 무엇인가"를 말하는 자리다.
/// 표시 방식의 차이는 **스크롤해봐야** 드러나므로, 데모는 전부 충분히 긴 목록을 깔았다.
@MainActor
enum TitleModeDemos {
    static let all: [EntryDemo] = [
        EntryDemo(
            "t1",
            hints: [
                "천천히 **위로 스크롤**해 보세요 — 대형 제목이 내비바 안 작은 제목으로 접힙니다.",
                "다시 아래로 당기면 원래 크기로 돌아옵니다. 콘텐츠를 볼 때는 물러나고, 시작 지점에선 존재감을 갖습니다.",
                "제목이 접히는 동안 오른쪽 버튼은 그대로입니다 — 액션은 제목의 사정과 무관합니다.",
            ],
            code: """
            .navigationTitle("받은 편지함")
            .toolbarTitleDisplayMode(.large)   // 기본값
            """
        ) { TitleModeDemoScreen(mode: .large, title: "받은 편지함") },

        EntryDemo(
            "t2",
            hints: [
                "스크롤해 보세요 — 제목이 **접히지 않고** 내비바 안에 큰 크기 그대로 남습니다.",
                "1.2.1(Large)과 번갈아 열어 같은 동작에서 무엇이 다른지 비교해 보세요.",
                "제목이 늘 커 보이는 대신, 콘텐츠에 내주는 세로 공간은 없습니다 — 그 교환이 이 모드의 전부입니다.",
            ],
            code: """
            .navigationTitle("받은 편지함")
            .toolbarTitleDisplayMode(.inlineLarge)   // iOS 26
            """
        ) { TitleModeDemoScreen(mode: .inlineLarge, title: "받은 편지함") },

        EntryDemo(
            "t3",
            hints: [
                "스크롤해도 제목이 변하지 않습니다 — 처음부터 가장 작은 형태입니다.",
                "제목이 차지하는 세로 공간이 가장 적습니다. 상세 화면·모달처럼 콘텐츠가 주인공인 화면의 기본값입니다.",
                "좌우 버튼과 한 줄을 나눠 씁니다. 제목이 길어지면 어떻게 될지 1.2.4에서 확인해 보세요.",
            ],
            code: """
            .navigationTitle("스프린트 리뷰")
            .toolbarTitleDisplayMode(.inline)
            """
        ) { TitleModeDemoScreen(mode: .inline, title: "스프린트 리뷰") },

        EntryDemo(
            "t4",
            hints: [
                "한 줄에 제목 + 아이템 5개가 함께 있습니다. **제목이 어떻게 줄어드는지** 보세요.",
                "화면 안 스위치로 제목을 긴 것으로 바꿔보세요 — 어디까지 버티는지 드러납니다.",
                "이 상태가 편안해 보이지 않는다면 그게 정답입니다. 1.1.7의 overflow가 왜 기본 동작인지 알려주는 케이스입니다.",
            ],
            code: """
            .navigationTitle(title)
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    // 아이템 5개 — 제목과 폭을 다툰다
                }
            }
            """
        ) { CrowdedInlineTitleDemo() },

        EntryDemo(
            "t5",
            hints: [
                "제목 옆 **⌄** 를 눌러보세요 — 제목 자체가 메뉴 버튼입니다.",
                "폴더를 고르면 제목과 목록이 함께 바뀝니다. 제목이 \"지금 무엇을 보고 있는가\"를 말하고 있기 때문입니다.",
                "같은 기능을 오른쪽 버튼으로 뺐다면, 화면 정체와 액션이 따로 놀았을 겁니다.",
            ],
            code: """
            .navigationTitle(folder.name)
            .toolbarTitleDisplayMode(.inline)
            .toolbarTitleMenu {
                Picker("폴더", selection: $folder) { /* 폴더 목록 */ }
                Divider()
                Button("이름 변경", systemImage: "pencil") { renaming = true }
            }
            """
        ) { TitleMenuDemo() },

        EntryDemo(
            "t6",
            hints: [
                "제목 자리에 텍스트가 아니라 **아바타 + 이름 + 상태**가 들어가 있습니다.",
                "스크롤하면 큰 커스텀 헤더가 접히고, 내비바 안의 작은 커스텀 제목만 남습니다.",
                "글자로 못 하는 말(사진·상태 점)을 해야 할 때만 씁니다 — 대부분의 화면은 텍스트 제목으로 충분합니다.",
            ],
            code: """
            // 큰 자리: 스크롤 콘텐츠 맨 위의 커스텀 헤더
            // 작은 자리: principal 에 같은 정보를 압축해 넣는다
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 6) { Avatar(); Text(name).bold() }
                }
            }
            .toolbarTitleDisplayMode(.inline)
            """
        ) { CustomLargeTitleDemo() },
    ]
}

// MARK: - 표시 방식만 바뀌는 공통 화면

private struct TitleModeDemoScreen: View {
    enum Mode { case large, inlineLarge, inline }

    let mode: Mode
    let title: String

    var body: some View {
        NavigationStack {
            List {
                Section {
                    DemoNote(text: "**스크롤**이 이 항목의 전부입니다. 위로 밀었다 아래로 당기며 제목이 어떻게 반응하는지 보세요.", symbol: "hand.draw")
                        .listRowInsets(.init(top: 6, leading: 12, bottom: 6, trailing: 12))
                }
                ForEach(0..<2, id: \.self) { pass in
                    Section(pass == 0 ? "오늘" : "지난주") {
                        ForEach(DemoData.mail) { mail in
                            DemoMailRow(mail: mail).id("\(pass)-\(mail.id)")
                        }
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle(title)
            .modifier(TitleDisplay(mode: mode))
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("편집") {}
                }
            }
        }
    }
}

private struct TitleDisplay: ViewModifier {
    let mode: TitleModeDemoScreen.Mode

    func body(content: Content) -> some View {
        switch mode {
        case .large:       content.toolbarTitleDisplayMode(.large)
        case .inlineLarge: content.toolbarTitleDisplayMode(.inlineLarge)
        case .inline:      content.toolbarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - 1.2.4 좁은 줄을 다섯이 나눠 쓰기

private struct CrowdedInlineTitleDemo: View {
    @State private var longTitle = false
    @State private var log = DemoLog()

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Toggle("긴 제목으로 바꾸기", isOn: $longTitle.animation(.snappy))
                    DemoNote(text: longTitle
                        ? "제목이 **잘렸습니다**. 좁은 줄에서 제목과 아이템은 같은 폭을 두고 경쟁합니다 — 8.1.5."
                        : "아이템 다섯 개가 이미 오른쪽을 가득 채웠습니다. 제목을 길게 바꿔보세요.")
                        .listRowInsets(.init(top: 6, leading: 12, bottom: 6, trailing: 12))
                }
                Section("문서") {
                    ForEach(DemoData.mail.prefix(8)) { DemoMailRow(mail: $0) }
                }
            }
            .navigationTitle(longTitle ? DemoData.longTitle : "문서")
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button("별표", systemImage: "star") { log.tap("별표") }
                    Button("깃발", systemImage: "flag") { log.tap("깃발") }
                    Button("이동", systemImage: "folder") { log.tap("이동") }
                    Button("공유", systemImage: "square.and.arrow.up") { log.tap("공유") }
                    Button("더보기", systemImage: "ellipsis") { log.tap("더보기") }
                }
            }
        }
        .demoToast(log)
    }
}

// MARK: - 1.2.5 제목이 곧 메뉴

private struct TitleMenuDemo: View {
    private enum Folder: String, CaseIterable, Identifiable {
        case inbox = "받은 편지함", flagged = "깃발 표시", archive = "보관함"
        var id: String { rawValue }

        var rows: [DemoMail] {
            switch self {
            case .inbox:   DemoData.mail
            case .flagged: DemoData.mail.filter(\.unread)
            case .archive: DemoData.mail.suffix(5).map { $0 }
            }
        }
    }

    @State private var folder = Folder.inbox
    @State private var renamed: String?
    @State private var renaming = false
    @State private var draft = ""

    private var title: String { renamed ?? folder.rawValue }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    DemoNote(text: "제목 옆의 **⌄** 를 누르면 메뉴가 열립니다. 폴더를 바꾸면 제목과 목록이 같이 바뀝니다.")
                        .listRowInsets(.init(top: 6, leading: 12, bottom: 6, trailing: 12))
                }
                Section {
                    ForEach(folder.rows) { DemoMailRow(mail: $0) }
                }
            }
            .listStyle(.plain)
            .navigationTitle(title)
            .toolbarTitleDisplayMode(.inline)
            .toolbarTitleMenu {
                Picker("폴더", selection: $folder) {
                    ForEach(Folder.allCases) { Label($0.rawValue, systemImage: "folder").tag($0) }
                }
                .onChange(of: folder) { renamed = nil }
                Divider()
                Button("이름 변경", systemImage: "pencil") {
                    draft = title
                    renaming = true
                }
            }
            .alert("이름 변경", isPresented: $renaming) {
                TextField("이름", text: $draft)
                Button("확인") { renamed = draft.isEmpty ? nil : draft }
                Button("취소", role: .cancel) {}
            }
        }
    }
}

// MARK: - 1.2.6 텍스트로 못 하는 말

private struct CustomLargeTitleDemo: View {
    @State private var online = true

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    header
                    ForEach(0..<2, id: \.self) { pass in
                        ForEach(DemoData.mail) { mail in
                            DemoMailRow(mail: mail)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .id("\(pass)-\(mail.id)")
                            Divider().padding(.leading, 16)
                        }
                    }
                }
            }
            .navigationTitle("김하늘")
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 6) {
                        DemoAvatar(initial: "하", size: 22)
                        Text("김하늘").font(.system(size: 15, weight: .semibold))
                        Circle()
                            .fill(online ? .green : .gray)
                            .frame(width: 7, height: 7)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(online ? "자리 비움" : "온라인") { withAnimation { online.toggle() } }
                        .font(.system(size: 14))
                }
            }
        }
    }

    private var header: some View {
        HStack(spacing: 12) {
            DemoAvatar(initial: "하", size: 54)
            VStack(alignment: .leading, spacing: 3) {
                Text("김하늘").font(.system(size: 26, weight: .bold))
                HStack(spacing: 5) {
                    Circle().fill(online ? .green : .gray).frame(width: 7, height: 7)
                    Text(online ? "온라인" : "자리 비움")
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 14)
    }
}

struct DemoAvatar: View {
    let initial: String
    var size: CGFloat = 32

    var body: some View {
        Text(initial)
            .font(.system(size: size * 0.42, weight: .bold))
            .foregroundStyle(.white)
            .frame(width: size, height: size)
            .background(
                LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing),
                in: .circle
            )
    }
}
