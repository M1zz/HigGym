import SwiftUI

// MARK: - 표본 콘텐츠
//
// 데모마다 콘텐츠까지 다르면 화면끼리 비교가 안 된다. 같은 메일 목록·같은 사진 격자를
// 깔아두고, 항목마다 **달라지는 것이 배치와 동작뿐**이 되게 한다.

struct DemoMail: Identifiable, Hashable {
    let id: Int
    let sender: String
    let subject: String
    let preview: String
    let time: String
    var unread: Bool
}

enum DemoData {
    static let mail: [DemoMail] = [
        .init(id: 0, sender: "김하늘", subject: "다음 주 스프린트 리뷰", preview: "화요일 오후 3시로 옮겨도 괜찮을까요? 회의실은 그대로 3층입니다.", time: "오전 9:41", unread: true),
        .init(id: 1, sender: "App Store Connect", subject: "심사가 통과되었습니다", preview: "버전 2.4.0 이 App Store 에 게시되었습니다.", time: "오전 8:12", unread: true),
        .init(id: 2, sender: "박도윤", subject: "디자인 시안 v3", preview: "툴바 아이템을 네 개에서 두 개로 줄였습니다. 나머지는 오버플로로 접었어요.", time: "어제", unread: false),
        .init(id: 3, sender: "이서연", subject: "Re: 접근성 점검 결과", preview: "Dynamic Type 최대 크기에서 하단 바 라벨이 잘립니다.", time: "어제", unread: false),
        .init(id: 4, sender: "정민준", subject: "주간 보고", preview: "이번 주 크래시율 0.12%, 지난주 대비 0.04%p 개선.", time: "화요일", unread: false),
        .init(id: 5, sender: "TestFlight", subject: "새 빌드를 테스트할 수 있습니다", preview: "빌드 118 이 배포되었습니다.", time: "화요일", unread: false),
        .init(id: 6, sender: "최지우", subject: "사진 정리 부탁드려요", preview: "지난 워크숍 사진 중에서 열 장만 골라주시면 됩니다.", time: "월요일", unread: false),
        .init(id: 7, sender: "한소율", subject: "계약서 검토 완료", preview: "3조 2항만 문구를 다듬었습니다. 확인 후 회신 주세요.", time: "월요일", unread: false),
        .init(id: 8, sender: "강태민", subject: "라이브러리 업데이트", preview: "iOS 26 대응 브랜치를 main 에 머지했습니다.", time: "지난주", unread: false),
        .init(id: 9, sender: "윤채원", subject: "점심 어때요", preview: "1층에 새로 생긴 곳 가보실 분?", time: "지난주", unread: false),
        .init(id: 10, sender: "오세훈", subject: "분기 목표 정리", preview: "OKR 초안입니다. 코멘트 남겨주세요.", time: "지난주", unread: false),
        .init(id: 11, sender: "배수아", subject: "새 폰트 라이선스", preview: "본문용 서체 계약이 갱신되었습니다.", time: "지난달", unread: false),
    ]

    /// 사진 격자 - zoom 전환·그리드 전환·재료 뒤 배경으로 두루 쓴다.
    static let photoColors: [Color] = [
        .orange, .pink, .purple, .blue, .teal, .green,
        .indigo, .red, .mint, .yellow, .cyan, .brown,
    ]

    static let longText = "가장자리 효과는 스크롤되는 콘텐츠와 떠 있는 컨트롤이 만나는 지점을 어떻게 처리할지에 대한 계약입니다. 콘텐츠가 유리 아래로 지나갈 때 글자가 컨트롤과 겹쳐 읽히지 않는 순간을 막는 것이 목적이며, 배경이 밝을수록 더 강한 처리가 필요합니다."

    static let longTitle = "2026년 3분기 사용자 인터페이스 개선 계획서 최종본"

    static let filePath = "/Users/designer/Documents/Projects/2026/Design/Toolbar/Specification.pdf"

    /// 사진 앨범 - 카드·행 목록이 "항목 1, 2, 3" 대신 쓰는 표본. 순서대로 돌려 쓰도록 `album(_:)` 로 꺼낸다.
    static let albums: [DemoAlbum] = [
        .init(name: "제주 여름휴가", detail: "사진 128장 · 8월 12일"),
        .init(name: "성수동 카페 투어", detail: "사진 36장 · 9월 3일"),
        .init(name: "봄 벚꽃 산책", detail: "사진 54장 · 4월 6일"),
        .init(name: "팀 워크숍 가평", detail: "사진 212장 · 6월 20일"),
        .init(name: "우리 집 고양이 보리", detail: "사진 431장 · 어제"),
        .init(name: "부산 해운대 일출", detail: "사진 19장 · 1월 1일"),
        .init(name: "을지로 필름 사진", detail: "사진 72장 · 5월 18일"),
        .init(name: "강릉 바다 드라이브", detail: "사진 45장 · 7월 27일"),
        .init(name: "엄마 생신 저녁", detail: "사진 23장 · 3월 9일"),
        .init(name: "한강 야경", detail: "사진 61장 · 8월 30일"),
        .init(name: "교토 단풍 여행", detail: "사진 187장 · 지난해 11월"),
        .init(name: "스크린샷", detail: "사진 956장 · 오늘"),
        .init(name: "북한산 등산", detail: "사진 28장 · 10월 2일"),
        .init(name: "주말 베이킹 기록", detail: "사진 40장 · 9월 21일"),
        .init(name: "전주 한옥마을", detail: "사진 66장 · 2월 11일"),
        .init(name: "즐겨찾는 항목", detail: "사진 88장 · 지난주"),
    ]

    static func album(_ i: Int) -> DemoAlbum { albums[i % albums.count] }

    /// 메모 제목 - 짧은 카드 머리글로 쓴다.
    static let noteTitles = [
        "3분기 회고 메모", "이사 준비 체크리스트", "읽고 싶은 책", "주간 장보기",
        "여행 짐 목록", "운동 루틴 정리", "선물 아이디어", "회의록 · 디자인 리뷰",
    ]

    /// 설정 화면처럼 보이는 옵션 행.
    static let settingRows = [
        "알림", "공유 대상", "사진 보관 방식", "iCloud 동기화", "앨범 정렬",
        "추억 추천", "위치 정보 포함", "셀룰러 데이터 사용", "숨겨진 앨범 표시",
        "Face ID로 잠그기", "저장 공간 관리", "도움말",
    ]

    /// 문서 상세 화면의 본문 줄 - 회의록 한 편.
    static let meetingNotes = [
        "참석: 김하늘, 박도윤, 이서연, 정민준",
        "안건 1. 하단 툴바 아이템 정리",
        "작성 버튼을 오른쪽 아래로 옮기기로 결정했습니다.",
        "보관·삭제는 더보기 메뉴 안으로 넣습니다.",
        "안건 2. 탭바 구성",
        "탭은 홈, 탐색, 보관함, 알림 네 개로 줄입니다.",
        "설정은 프로필 화면 안으로 옮깁니다.",
        "안건 3. 접근성 점검",
        "가장 큰 글씨에서 하단 바 라벨이 잘리는 문제가 있습니다.",
        "라벨을 줄이지 않고 아이콘만 남기는 방식을 검토합니다.",
        "안건 4. 다크 모드 대비",
        "사진 위 버튼은 가장자리 효과를 켜서 대비를 확보합니다.",
        "안건 5. 출시 일정",
        "TestFlight 빌드는 목요일에 배포합니다.",
        "심사 제출은 다음 주 월요일로 잡습니다.",
        "할 일 · 박도윤: 툴바 시안 v4",
        "할 일 · 이서연: Dynamic Type 재점검",
        "할 일 · 정민준: 크래시 리포트 정리",
        "다음 회의: 목요일 오후 2시, 3층 회의실",
        "작성: 김하늘",
    ]
}

struct DemoAlbum: Hashable {
    let name: String
    let detail: String
}

// MARK: - 눌렀다는 사실을 보여주는 토스트
//
// 데모의 버튼은 장식이 아니라 실제로 동작해야 한다. 상태가 눈에 보이게 바뀌는 액션은
// 그 자체로 증거지만, "공유"처럼 결과가 화면 밖에 있는 액션은 눌린 사실을 이렇게 알린다.

@MainActor
@Observable
final class DemoLog {
    private(set) var message: String?
    private var token = 0

    func tap(_ message: String) {
        token += 1
        let mine = token
        withAnimation(.snappy(duration: 0.2)) { self.message = message }
        Task {
            try? await Task.sleep(for: .seconds(1.6))
            guard mine == token else { return }
            withAnimation(.easeOut(duration: 0.25)) { self.message = nil }
        }
    }
}

private struct DemoToast: ViewModifier {
    let log: DemoLog

    func body(content: Content) -> some View {
        content.overlay {
            if let message = log.message {
                Text(message)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 11)
                    .background(.black.opacity(0.72), in: .capsule)
                    .overlay(Capsule().strokeBorder(.white.opacity(0.18), lineWidth: 1))
                    .transition(.opacity.combined(with: .scale(scale: 0.94)))
                    .allowsHitTesting(false)
            }
        }
    }
}

extension View {
    /// 액션이 실제로 실행됐다는 사실을 화면 한가운데에 잠깐 띄운다.
    func demoToast(_ log: DemoLog) -> some View { modifier(DemoToast(log: log)) }
}

// MARK: - 공용 콘텐츠 뷰

/// 툴바·탭바·검색 데모가 깔고 쓰는 메일 목록. 스크롤이 충분히 길어야
/// 대형 제목 축소·가장자리 효과·탭바 최소화가 눈에 보인다.
struct DemoMailList: View {
    var rows: [DemoMail] = DemoData.mail
    var repeats: Int = 2
    /// 비워 두면 행을 눌렀을 때 어떤 메일을 열었는지 토스트로 알린다 - 눌러도 무반응인 행은 두지 않는다.
    var onTap: ((DemoMail) -> Void)?

    @State private var log = DemoLog()

    var body: some View {
        List {
            ForEach(0..<repeats, id: \.self) { pass in
                ForEach(rows) { mail in
                    Button {
                        if let onTap { onTap(mail) } else { log.tap("\(mail.sender) · \(mail.subject)") }
                    } label: {
                        DemoMailRow(mail: mail)
                    }
                    .buttonStyle(.plain)
                    .id("\(pass)-\(mail.id)")
                }
            }
        }
        .listStyle(.plain)
        .demoToast(log)
    }
}

struct DemoMailRow: View {
    let mail: DemoMail

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Circle()
                .fill(mail.unread ? Color.accentColor : .clear)
                .frame(width: 8, height: 8)
                .padding(.top, 6)

            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(mail.sender)
                        .font(.callout.weight(.semibold))
                    Spacer()
                    Text(mail.time)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                Text(mail.subject).font(.subheadline)
                Text(mail.preview)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 3)
    }
}

/// 사진 격자 - 유리 아래로 지나가는 "밝고 복잡한 콘텐츠" 역할도 겸한다.
struct DemoPhotoGrid: View {
    var count: Int = 24
    var columns: Int = 3
    var onTap: (Int) -> Void = { _ in }

    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 3), count: columns), spacing: 3) {
            ForEach(0..<count, id: \.self) { i in
                Button { onTap(i) } label: {
                    DemoPhoto(index: i)
                        .aspectRatio(1, contentMode: .fill)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 3)
    }
}

/// 자산 없이 코드로만 그리는 "사진" - 밝은 면과 어두운 면이 섞여야
/// 재료·가장자리 효과의 가독성 차이가 드러난다.
struct DemoPhoto: View {
    let index: Int

    var body: some View {
        let base = DemoData.photoColors[index % DemoData.photoColors.count]
        LinearGradient(
            colors: [base.opacity(0.95), base.mix(with: .white, by: 0.55)],
            startPoint: index.isMultiple(of: 2) ? .topLeading : .bottomLeading,
            endPoint: index.isMultiple(of: 2) ? .bottomTrailing : .topTrailing
        )
        .overlay(alignment: index.isMultiple(of: 3) ? .topTrailing : .bottomLeading) {
            Circle()
                .fill(.white.opacity(0.35))
                .frame(width: 42, height: 42)
                .blur(radius: 6)
                .padding(10)
        }
    }
}

// MARK: - 배경 전환기
//
// 가장자리 효과·재료는 **뒤에 무엇이 있느냐**로 판정이 갈린다(1.3 · 6.1).
// 그래서 배경을 바꿔볼 수 없는 데모는 반쪽짜리다.

enum DemoBackdrop: String, CaseIterable, Identifiable {
    case dark = "어두운 단색"
    case photo = "사진"
    case white = "흰 배경"

    var id: String { rawValue }

    @ViewBuilder
    var view: some View {
        switch self {
        case .dark:
            Color(red: 0.07, green: 0.08, blue: 0.11)
        case .photo:
            LinearGradient(
                colors: [.orange, .pink, .purple, .blue],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .overlay {
                RadialGradient(colors: [.white.opacity(0.8), .clear], center: .init(x: 0.7, y: 0.2), startRadius: 4, endRadius: 220)
            }
        case .white:
            Color.white
        }
    }

    /// 흰 배경 위에서는 본문 글자를 어둡게 - 데모가 스스로 안 읽히면 곤란하다.
    var contentColor: Color { self == .white ? .black : .white }
}

/// 데모 화면 안에 놓는 가로 선택기. 조작 장치는 화면 밖(설정 시트)이 아니라
/// **콘텐츠 안**에 둔다 - 실제 화면 크롬을 가리지 않기 위해서다.
struct DemoPicker<T: Hashable & Identifiable>: View {
    let title: String
    let options: [T]
    let label: (T) -> String
    @Binding var selection: T

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption.weight(.bold))
                .foregroundStyle(.secondary)
            Picker(title, selection: $selection) {
                ForEach(options) { Text(label($0)).tag($0) }
            }
            .pickerStyle(.segmented)
        }
    }
}

extension View {
    /// 화면 가장자리에 떠 있는 조작 캡슐(닫기·안내)과 겹치지 않게 안쪽으로 물러난다.
    /// 목록 행이 가려지는 건 괜찮지만, **누를 수 있는 것**이 그 밑에 깔리면 안 된다.
    func demoChromeSafe(_ edge: Edge.Set = .leading) -> some View {
        padding(edge, 46)
    }
}

/// 데모 안에서 "지금 무엇을 보고 있는지" 짚어주는 설명 카드.
struct DemoNote: View {
    let text: String
    var symbol: String = "hand.point.up.left.fill"

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: symbol)
                .font(.footnote)
                .foregroundStyle(.tint)
                .padding(.top, 1)
            Text(.init(text))
                .font(.subheadline)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(12)
        .background(.quaternary.opacity(0.5), in: .rect(cornerRadius: 12))
    }
}
