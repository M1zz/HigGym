import SwiftUI

/// 레슨 한 편 — 이 앱의 기본 단위.
///
/// 도감처럼 훑는 화면이 아니라 **다섯 단계를 순서대로 밟는 워크북**이다.
/// 써보고 → 느낀 것을 쓰고 → 이유를 확인하고 → 어긴 화면과 비교하고 → 배운 것을 남긴다.
/// 쓰는 단계가 있어야 남는다. 그래서 읽기만 하고 지나갈 수 없게 만들었다.
@MainActor
struct Lesson: Identifiable {
    /// 레슨이 세우는 화면이 어디서 오는가.
    enum Source {
        /// 표본 앱(노트)의 결정 하나를 뒤집는다.
        case sampleApp(NoteAppConfig.Knob)
        /// 표본 앱으로는 못 보여주는 것들 — 사진 위 가장자리 효과, 배지, 탭 같은 것.
        case pair(LessonPair)
    }

    let id: String
    let number: Int
    let source: Source
    let title: String
    /// 한 줄로 요약한 배울 것.
    let subtitle: String

    /// ① 써보기 — 손으로 해볼 과제. 짧고 분명해야 한다.
    let task: String
    /// ② 적기 — 무엇을 관찰했는지 묻는 질문.
    let question: String
    /// ②의 입력칸에 흐리게 깔리는 예시.
    let placeholder: String

    /// ③ 이유 확인에 실리는 세 문단.
    let decision: String
    let why: String
    let ifFlipped: String
    /// ④ 비교 — 무엇이 달라졌는지 한 줄.
    let diff: String

    let sources: [String]
    /// 회고가 있는 실수 편이면 그 번호 — 레슨 끝에서 이어 읽을 수 있게.
    var mistakeNumber: Int?

    /// 표본 앱의 결정에서 만드는 레슨 — 설명 세 문단은 그 결정에서 그대로 가져온다.
    init(
        id: String, number: Int, knob: NoteAppConfig.Knob,
        title: String, subtitle: String,
        task: String, question: String, placeholder: String, diff: String,
        mistakeNumber: Int? = nil
    ) {
        let decision = NoteAppDecision.of(knob)
        self.id = id
        self.number = number
        self.source = .sampleApp(knob)
        self.title = title
        self.subtitle = subtitle
        self.task = task
        self.question = question
        self.placeholder = placeholder
        self.decision = decision.decision
        self.why = decision.why
        self.ifFlipped = decision.ifFlipped
        self.diff = diff
        self.sources = decision.sources
        self.mistakeNumber = mistakeNumber
    }

    /// 표본 앱 밖의 화면 한 쌍으로 만드는 레슨.
    init(
        id: String, number: Int, pair: LessonPair,
        title: String, subtitle: String,
        task: String, question: String, placeholder: String,
        decision: String, why: String, ifFlipped: String, diff: String,
        sources: [String], mistakeNumber: Int?
    ) {
        self.id = id
        self.number = number
        self.source = .pair(pair)
        self.title = title
        self.subtitle = subtitle
        self.task = task
        self.question = question
        self.placeholder = placeholder
        self.decision = decision
        self.why = why
        self.ifFlipped = ifFlipped
        self.diff = diff
        self.sources = sources
        self.mistakeNumber = mistakeNumber
    }

    static let all: [Lesson] = [
        Lesson(
            id: "L1", number: 1, knob: .compose,
            title: "가장 자주 하는 일은 어디에 두는가",
            subtitle: "빈도와 높이는 반비례한다",
            task: "노트를 **세 개 만들어** 보세요. 한 손으로, 기기를 고쳐 쥐지 말고 해보세요.",
            question: "새 노트 버튼을 세 번 누르는 동안 엄지가 어떻게 움직였나요? 그 자리가 아니라 오른쪽 위였다면 어땠을까요?",
            placeholder: "예: 엄지를 거의 안 움직이고 눌렀다. 위에 있었으면 손을 바꿔 쥐어야 했을 것 같다.",
            diff: "새 노트 버튼이 하단 오른쪽 ↔ 상단 오른쪽으로만 옮겨졌습니다.",
            mistakeNumber: 99
        ),
        Lesson(
            id: "L2", number: 2, knob: .deletion,
            title: "되돌릴 수 없는 일은 어떻게 시키는가",
            subtitle: "도달성은 무해한 액션에만 적용한다",
            task: "노트를 **하나 지워** 보세요. 툴바에는 삭제가 없습니다 — 목록의 행을 왼쪽으로 밀어보세요.",
            question: "지우기까지 몇 단계를 거쳤나요? 실수로 지울 뻔한 순간이 있었나요?",
            placeholder: "예: 밀고, 빨간 버튼을 다시 눌러야 했다. 무엇을 지우는지도 분명했다.",
            diff: "삭제가 행 위(스와이프) ↔ 하단 바 단독 버튼으로 옮겨졌습니다.",
            mistakeNumber: 7
        ),
        Lesson(
            id: "L3", number: 3, knob: .grouping,
            title: "한 캡슐에 묶는다는 것의 뜻",
            subtitle: "묶음은 정리가 아니라 선언이다",
            task: "오른쪽 위를 보세요. 지금 그 자리에는 **편집 하나**뿐입니다. 눌러서 편집 모드에 들어갔다 나와보세요.",
            question: "상단에 삭제·정렬이 함께 있었다면, 편집을 누르려다 무엇을 누를 뻔했을까요?",
            placeholder: "예: 세 개가 붙어 있으면 아이콘을 하나씩 확인하지 않고 손이 먼저 갈 것 같다.",
            diff: "상단이 확정 액션 하나 ↔ 삭제·정렬·편집 한 캡슐로 바뀌었습니다.",
            mistakeNumber: 3
        ),
        Lesson(
            id: "L4", number: 4, knob: .title,
            title: "액션은 어디에 붙어야 하는가",
            subtitle: "대상이 보이면 액션은 그 위에",
            task: "**제목 \"노트\"를 눌러** 폴더를 업무 → 개인으로 바꿔보세요.",
            question: "폴더를 바꾸는 버튼을 어디서 찾았나요? 찾기까지 헤맸다면 그 이유는 무엇일까요?",
            placeholder: "예: 처음엔 툴바를 봤다. 제목에 ⌄가 있는 걸 보고 눌렀다.",
            diff: "폴더 전환이 제목 메뉴 ↔ 왼쪽 위 별도 버튼으로 옮겨졌습니다.",
            mistakeNumber: 100
        ),
        Lesson(
            id: "L5", number: 5, knob: .search,
            title: "자주 여는 입구는 어디에 두는가",
            subtitle: "닿기 쉬운 자리 · 안 쓸 때는 비켜 있기",
            task: "**검색으로 \"운송장\"을 찾아** 보세요. 그다음 검색을 비우고 목록으로 돌아와 보세요.",
            question: "검색을 열고 닫는 동안 손이 어디까지 올라갔나요? 검색을 안 쓸 때 그 자리는 무엇을 하고 있었나요?",
            placeholder: "예: 아래에 있어서 엄지로 바로 닿았다. 안 쓸 때는 캡슐 하나만 차지했다.",
            diff: "검색이 하단 캡슐 ↔ 항상 펼쳐진 상단 서랍으로 바뀌었습니다.",
            mistakeNumber: 30
        ),
        Lesson(
            id: "L6", number: 6, knob: .date,
            title: "값과 표기를 누가 갖는가",
            subtitle: "값은 앱이, 표기는 로케일이",
            task: "목록의 **수정 시각**을 보세요. \"3일 전\"처럼 나옵니다. 노트를 하나 새로 만들어 방금 만든 것의 시각도 확인해 보세요.",
            question: "이 앱이 영어 기기에서 열린다면 이 시각은 어떻게 보여야 할까요? 지금 방식이면 가능할까요?",
            placeholder: "예: 영어면 \"3 days ago\"로 나와야 한다. 문자열로 저장했다면 못 바꿀 것 같다.",
            diff: "두 화면 모두 **영어(en_US) 기기**입니다. 표기를 로케일에 맡긴 쪽 ↔ 문자열로 굳힌 쪽.",
            mistakeNumber: 47
        ),
        Lesson(
            id: "L7", number: 7, knob: .selection,
            title: "읽기 전용이라는 말의 뜻",
            subtitle: "옮겨 적을 값에는 길을 낸다",
            task: "**운송장 번호 노트를 열고** 본문을 길게 눌러보세요. 번호를 복사해 보세요.",
            question: "이 번호를 다른 앱에 넣어야 한다면, 복사가 막혀 있을 때 사용자는 무엇을 하게 될까요?",
            placeholder: "예: 화면을 보면서 손으로 옮겨 적을 것 같다. 열여섯 자리라 틀리기 쉽다.",
            diff: "본문 선택·복사가 열린 쪽 ↔ 막힌 쪽입니다.",
            mistakeNumber: 46
        ),
        Lesson(
            id: "L8", number: 8, knob: .editorExit,
            title: "덮는 화면에는 출구가 필요하다",
            subtitle: "전체 화면 커버는 쓸어내려 닫히지 않는다",
            task: "**새 노트를 열고** 아래로 쓸어내려 닫아보세요. 그다음 취소로 나와보세요.",
            question: "쓸어내렸을 때 무슨 일이 있었나요? 취소 버튼이 없었다면 어떻게 했을까요?",
            placeholder: "예: 쓸어내려도 그대로였다. 버튼이 없었으면 앱이 멈춘 줄 알았을 것 같다.",
            diff: "편집기에 취소·완료가 있는 쪽 ↔ 출구가 없는 쪽입니다.",
            mistakeNumber: 81
        ),
        Lesson(
            id: "L9", number: 9, pair: .overflowOrder,
            title: "무엇이 접혀도 되는가",
            subtitle: "선언 순서가 곧 우선순위다",
            task: "이 화면에서 **저장을 세 번** 눌러보세요. 저장 버튼을 먼저 찾아야 합니다.",
            question: "저장을 찾는 데 몇 초 걸렸나요? 어디에 있었나요? 하루에 스무 번 저장한다면 이 배치가 어떨까요?",
            placeholder: "예: ⋯ 안에 있어서 두 번 눌러야 했다. 자주 쓰는 건데 한 단계가 더 있다.",
            decision: "자주 쓰는 저장을 툴바 앞쪽에 두고, 가끔 쓰는 것들을 뒤로 보냈다.",
            why: "폭이 모자라면 시스템은 **뒤쪽부터** ⋯ 안으로 접는다. 그러니 코드에 적는 순서가 곧 우선순위 선언이다. 접기를 막을 게 아니라 무엇이 접혀도 되는지를 정하는 일이다.",
            ifFlipped: "만든 순서대로 적으면 나중에 추가된 핵심 기능이 접힌다. 큰 기기에서는 다 보이므로 개발 중에는 만나지도 못한다.",
            diff: "아이템 개수는 같습니다. **순서만** 다릅니다 — 저장이 앞이냐 뒤냐.",
            sources: ["1.1.7"], mistakeNumber: 11
        ),
        Lesson(
            id: "L10", number: 10, pair: .scrollEdge,
            title: "최악의 배경에서 확인한다",
            subtitle: "가장자리 효과는 장식이 아니라 안전장치",
            task: "사진 격자를 **천천히 스크롤**해 보세요. **흰 사진**이 상단 바를 지나는 순간을 노려 보세요.",
            question: "흰 사진이 지나갈 때 상단의 선택·공유 버튼은 어떻게 보였나요? 어두운 사진일 때와 달랐나요?",
            placeholder: "예: 어두운 사진에선 잘 보였는데 흰 사진에선 글자가 흐려졌다.",
            decision: "콘텐츠와 바 사이에 hard 경계를 둬서 대비를 배경에 맡기지 않았다.",
            why: "가장자리 효과는 콘텐츠가 유리 아래로 지나가는 순간을 위한 **가독성 장치**다. 판정은 우리가 고른 샘플이 아니라 사용자가 가진 가장 밝은 사진에서 한다.",
            ifFlipped: "어두운 샘플 한 장으로 확인하고 끄면, 흰 사진이 지나는 몇 초 동안 컨트롤이 실제로 사라진다. 재현이 안 되는 게 아니라 그 조건을 안 만들어 본 것이다.",
            diff: "`.hard` 경계 ↔ 효과 끔(`scrollEdgeEffectHidden`). 사진과 배치는 같습니다.",
            sources: ["1.3.4", "8.1.4"], mistakeNumber: 29
        ),
        Lesson(
            id: "L11", number: 11, pair: .clampedText,
            title: "글자가 커져도 값이 남는가",
            subtitle: "잘려도 뜻이 통하는가로 도구를 고른다",
            task: "이 화면은 **접근성 큰 글씨** 설정이 켜진 상태입니다. 배송지와 주문번호를 **소리 내어 읽어** 보세요.",
            question: "읽을 수 있었나요? 주소의 어디까지 남아 있었나요? 이 화면으로 배송지를 확인하고 결제할 수 있을까요?",
            placeholder: "예: 앞부분만 남고 동·호수가 사라졌다. 이대로면 잘못된 주소인지 알 수 없다.",
            decision: "잘리면 안 되는 값에는 줄 수 범위를 줘서 카드가 길어지게 뒀다.",
            why: "`lineLimit(1)`과 `minimumScaleFactor`는 둘 다 넘침을 막는 도구지만 **함께 걸면 서로를 가린다** — 축소가 먼저 일해 글자를 줄이고, 그래도 안 들어가면 한 줄 제한이 나머지를 자른다. 남는 건 첫 어절뿐이다.",
            ifFlipped: "기본 글자 크기에서는 멀쩡해 보인다. 접근성 최대 설정에서 한 번 열어보지 않으면 배송 사고가 나서야 알게 된다.",
            diff: "`lineLimit(1) + minimumScaleFactor(0.4)` ↔ `lineLimit(2...3)`. 값도 글자 크기도 같습니다.",
            sources: ["2.1.1", "8.1.5"], mistakeNumber: 38
        ),
        Lesson(
            id: "L12", number: 12, pair: .stickyBadge,
            title: "배지는 무엇을 약속하는가",
            subtitle: "셀 수 있고 줄어드는 것에만 붙인다",
            task: "**소식 탭**에 들어가 새 소식을 **전부 읽음으로 표시**해 보세요. 그다음 배지를 확인하세요.",
            question: "다 읽은 뒤 배지는 어떻게 됐나요? 이 배지를 며칠 보고 나면 어떤 습관이 생길까요?",
            placeholder: "예: 다 읽었는데도 1이 그대로였다. 며칠 지나면 빨간 점을 아예 안 볼 것 같다.",
            decision: "배지를 실제 안 읽은 소식 수에 연결하고, 0이 되면 사라지게 뒀다.",
            why: "배지는 \"처리할 것이 남았다\"는 **약속**이다. 사용자는 그 약속을 믿고 들어왔다가 처리할 게 없다는 걸 확인한다. 두세 번 반복되면 학습이 끝난다.",
            ifFlipped: "그때 잃는 건 이 배지 하나가 아니라 **그 앱의 모든 배지**다. 나중에 진짜 급한 알림에 붙여도 아무도 보지 않는다.",
            diff: "실제 미확인 수 ↔ 고정된 1. 읽어도 줄지 않는 쪽이 어긴 화면입니다.",
            sources: ["3.1.3"], mistakeNumber: 52
        ),
        Lesson(
            id: "L13", number: 13, pair: .fakeTab,
            title: "탭은 무엇을 약속하는가",
            subtitle: "탭은 목적지, 액션은 툴바",
            task: "가운데 **작성 탭**을 눌러보세요. 시트를 닫고 나서 지금 어느 탭에 있는지 확인하세요.",
            question: "작성 탭을 눌렀을 때 어디로 갔나요? 시트를 닫은 뒤 선택된 탭은 어디였나요? 그게 자연스러웠나요?",
            placeholder: "예: 시트만 뜨고 탭은 홈으로 돌아왔다. 내가 뭘 잘못 눌렀나 싶었다.",
            decision: "작성을 탭이 아니라 하단 툴바 버튼으로 두고, 탭에는 목적지만 남겼다.",
            why: "탭바는 \"이 앱이 어떤 세계로 이루어져 있는가\"를 말하는 지도다. 탭 하나하나가 **목적지**라는 약속이라, 이동하지 않는 탭은 그 약속을 깬다.",
            ifFlipped: "선택 상태가 원래 탭으로 되돌아가는 순간 사용자는 자기가 뭘 잘못 눌렀다고 느낀다. 가장 좋은 자리를 쓰고 신뢰를 잃는다.",
            diff: "작성이 하단 툴바 버튼 ↔ 가짜 탭. 탭 개수도 함께 달라집니다.",
            sources: ["3.4.4"], mistakeNumber: 68
        ),
        Lesson(
            id: "L14", number: 14, pair: .decorButtons,
            title: "빈 자리는 실패가 아니다",
            subtitle: "지워도 못 하게 되는 일이 없다면 지운다",
            task: "**완료를 세 번** 눌러보세요. 그리고 본문을 **길게 눌러** 무엇이 나오는지 보세요.",
            question: "오른쪽 위에서 완료를 고르는 데 망설임이 있었나요? 공유·별표는 어디에 있는 편이 자연스러웠나요?",
            placeholder: "예: 버튼이 하나뿐이라 볼 것도 없이 눌렀다. 공유는 본문을 누를 때 나오는 게 더 가깝게 느껴졌다.",
            decision: "이 화면에서 실제로 쓰이는 액션(완료)만 툴바에 남기고, 나머지는 대상 위 컨텍스트 메뉴로 옮겼다.",
            why: "사용자는 툴바를 그림이 아니라 **선택지 목록**으로 읽는다. 넷이 나란히 있으면 매번 넷 중에서 고르는 일이 되고, 92%가 쓰는 하나가 셋 사이에 묻힌다. 기능을 없앤 게 아니라 자리를 옮긴 것이다.",
            ifFlipped: "\"휑해 보인다\"는 이유로 채우면 캡슐마다 시각적 무게가 붙어, UI가 물러나야 할 화면에서 UI가 앞으로 나온다.",
            diff: "툴바 아이템 넷 ↔ 하나. 공유·별표는 사라진 게 아니라 본문 컨텍스트 메뉴에 있습니다.",
            sources: ["1.1.1", "8.1.1"], mistakeNumber: 1
        ),
        Lesson(
            id: "L15", number: 15, pair: .adBar,
            title: "그 자리는 무엇을 위한 자리인가",
            subtitle: "하단 바는 조작을 위한 콕핏이다",
            task: "**새 글쓰기를 세 번** 눌러보세요. 한 손으로, 목록을 스크롤하는 사이사이에 눌러보세요.",
            question: "혜택 배너를 실수로 누를 뻔한 적이 있나요? 눌렀다면 그건 누르려던 것이었나요?",
            placeholder: "예: 스크롤하다 엄지가 배너 위를 지났다. 두 버튼이 붙어 있어 새 글쓰기가 좁게 느껴졌다.",
            decision: "하단 바에는 이 화면의 조작(새 글쓰기)만 두고, 프로모션은 콘텐츠 흐름 안으로 넣었다.",
            why: "하단은 스크롤하다가·기기를 고쳐 쥐다가 엄지가 지나가는 자리다. 그래서 **의도한 탭과 지나가다 닿은 탭이 구분되지 않는다.** 노출이 잘 되는 이유와 잘못 눌리는 이유가 같다.",
            ifFlipped: "그 자리의 약속을 한 번 깨면, 다음에 거기 놓는 진짜 액션도 광고처럼 보인다.",
            diff: "하단 바에 혜택 배너 + 새 글 ↔ 새 글만. 배너는 목록 세 번째 자리로 옮겨졌습니다.",
            sources: ["1.1.8", "3.5.1"], mistakeNumber: 14
        ),
        Lesson(
            id: "L16", number: 16, pair: .customNavBar,
            title: "시스템 바를 다시 만들기 전에",
            subtitle: "그것이 대신 해주던 일을 셀 수 있는가",
            task: "이 화면은 **접근성 큰 글씨** 상태입니다. 제목과 액션이 자리를 어떻게 나눴는지 보고, 액션을 하나씩 눌러보세요.",
            question: "제목은 글자 크기를 따라 커졌나요? 버튼은 손가락으로 정확히 눌렸나요? 어긴 쪽과 무엇이 달랐나요?",
            placeholder: "예: 제목이 잘리고 아이콘이 다닥다닥 붙었다. 두 번째 버튼을 누르려다 옆을 눌렀다.",
            decision: "직접 만든 헤더를 버리고 시스템 내비바로 돌아갔다. 넘치는 아이템은 시스템이 ⋯ 로 접게 뒀다.",
            why: "시스템 내비바는 평상시 모습만 그리는 게 아니다 — 회전·글자 크기·언어 길이·다크 모드·VoiceOver 순서·안전 영역·스크롤 축소를 함께 책임진다. 직접 만드는 순간 그 전부를 떠안는다.",
            ifFlipped: "반나절이면 만들어지지만, 이후 반년 동안 회전·큰 글씨·마이너 업데이트마다 버그가 하나씩 돌아온다.",
            diff: "직접 만든 고정 높이 헤더(제목·아이콘이 안 커짐) ↔ 시스템 내비바(제목이 커지고 넘치는 건 스스로 접힘).",
            sources: ["1.2.4"], mistakeNumber: 20
        ),
        Lesson(
            id: "L17", number: 17, pair: .mapControls,
            title: "예쁨은 어디서 판정하는가",
            subtitle: "읽힘과 미학이 충돌하면 읽힘이 이긴다",
            task: "지도를 **위로 끝까지 스크롤**해 눈 덮인 지역으로 올라가 보세요. 그 상태에서 상단 컨트롤을 읽어보세요.",
            question: "밝은 지역에서 버튼 글자가 읽혔나요? 어두운 지역과 무엇이 달랐나요?",
            placeholder: "예: 어두운 구역에선 잘 보였는데 눈밭에서는 흰 글자가 배경에 묻혔다.",
            decision: "얇은 재료를 두꺼운 재료로 바꾸고 테두리를 줘서, 대비를 배경에 의존하지 않게 했다.",
            why: "예쁨은 시안 한 장에서 판정할 수 있지만 **가독성은 최악의 배경에서만 판정된다.** \"몇몇 지역에서만\"처럼 보이는 문제는 대개 \"모든 사용자가 하루에 몇 번씩 만나는 순간\"이다.",
            ifFlipped: "가장 아름다웠던 상태를 지키려다, 흰 사진·눈밭·강 위를 지날 때마다 컨트롤이 사라진다.",
            diff: "`.ultraThinMaterial` + 흰 글자 ↔ `.thickMaterial` + 테두리. 지도와 배치는 같습니다.",
            sources: ["1.3.3", "8.1.4"], mistakeNumber: 28
        ),
        Lesson(
            id: "L18", number: 18, pair: .searchDrawer,
            title: "기본값은 우리 앱을 모른다",
            subtitle: "주 사용 방식이면 늘 손에 닿아야 한다",
            task: "목록을 **한참 아래로 내린 뒤** 검색을 해보세요. 검색을 시작하기까지 무엇을 해야 했는지 세어 보세요.",
            question: "검색창을 다시 꺼내기 위해 무엇을 했나요? 이 앱에서 검색이 주 사용 방식이라면 그 동작이 적절할까요?",
            placeholder: "예: 목록 맨 위까지 다시 올려야 검색창이 나왔다. 한 손으로는 두 번 쓸어 올려야 했다.",
            decision: "검색을 접히는 상단 서랍에서 하단 툴바 캡슐로 내렸다.",
            why: "\"필요할 때만 꺼내 쓴다\"는 기본 동작은 검색이 **부수적인 앱**을 위한 것이다. 주 사용 방식을 꺼내 쓰게 만들면 사용자는 꺼내는 대신 다른 길(끝없는 스크롤)로 간다.",
            ifFlipped: "도달성 문제가 발견 가능성 문제로 위장된다 — 검색이 있는 줄 알면서도 안 쓴다.",
            diff: "상단 서랍(스크롤하면 접힘) ↔ 하단 툴바 캡슐. 목록과 데이터는 같습니다.",
            sources: ["1.4.3", "1.4.1"], mistakeNumber: 34
        ),
        Lesson(
            id: "L19", number: 19, pair: .amount,
            title: "잘려도 뜻이 통하는가",
            subtitle: "숫자가 잘리면 요약이 아니라 오답이다",
            task: "결제 내역의 **금액을 소리 내어 읽어** 보세요. 세 줄 다 읽어보세요.",
            question: "금액을 정확히 읽을 수 있었나요? 읽을 수 없었다면, 사용자는 이 화면을 보고 무엇이라고 판단할까요?",
            placeholder: "예: ₩1,284,0… 까지만 보였다. 말줄임표를 못 봤다면 12만 원으로 읽었을 것 같다.",
            decision: "이름과 금액을 한 줄에서 다투게 두지 않고, 금액에 자기 줄을 줬다.",
            why: "문장이 잘리면 요약이 되지만 숫자가 잘리면 **다른 값**이 된다. 텍스트 처리 규칙을 앱 전체에 일괄로 세우면 안 되는 이유가 여기 있다 — 규칙은 값의 종류마다 다르다.",
            ifFlipped: "\"다른 셀과 같은 방식\"이라는 이유로 코드 리뷰를 통과하고, 결제 문의로 돌아온다.",
            diff: "이름과 금액이 한 줄 ↔ 금액이 자기 줄. 값도 글자 크기도 같습니다.",
            sources: ["2.1.3", "8.1.5"], mistakeNumber: 43
        ),
        Lesson(
            id: "L20", number: 20, pair: .tabCount,
            title: "탭이 넘칠 때 의심할 것",
            subtitle: "3~5개가 표준 범위다",
            task: "**가장 오른쪽 탭**을 한 손으로 눌러보세요. 그다음 옆 탭으로 옮겨보세요.",
            question: "라벨이 다 보였나요? 누르려던 탭을 정확히 눌렀나요?",
            placeholder: "예: \"내 정…\"으로 잘렸고, 엄지로 누르니 옆 탭이 눌렸다.",
            decision: "여섯을 넷으로 줄였다. 성격이 겹치는 둘은 한 탭 안 세그먼트로 합치고, 액션이던 하나는 툴바로 내렸다.",
            why: "들어가는 것과 **쓸 수 있는 것**은 다르다. 폭이 좁아질수록 라벨이 잘리고 터치 타깃이 좁아진다. 그리고 여섯이 필요하다는 건 정보 구조가 여섯 갈래로 흩어져 있다는 신호다.",
            ifFlipped: "가장 큰 기기에서 확인하면 문제를 만나지 못한다. 작은 기기·긴 라벨·큰 글씨가 겹칠 때만 드러난다.",
            diff: "탭 6개 ↔ 4개. 화면 내용은 같습니다.",
            sources: ["3.2.4"], mistakeNumber: 59
        ),
        Lesson(
            id: "L21", number: 21, pair: .checkoutTab,
            title: "잃을 것이 있는 화면",
            subtitle: "가두지 않는 것이 언제나 친절은 아니다",
            task: "카드 번호를 **몇 자 입력한 뒤** 다른 탭으로 갔다가 돌아와 보세요.",
            question: "돌아왔을 때 입력한 내용은 어떻게 됐나요? 그때 사용자는 무엇을 할까요?",
            placeholder: "예: 카드 번호가 비어 있었다. 다시 입력하기 싫어서 그냥 나갈 것 같다.",
            decision: "결제 흐름에서는 탭바를 숨기고 출구를 취소 하나로 좁혔다. 나갈 때는 한 번 묻는다.",
            why: "여기서 필요한 친절은 \"언제든 나갈 수 있음\"이 아니라 **\"쓰던 것을 잃지 않음\"**이다. 경고도 복원도 없이 열어둔 길은 길이 아니라 함정이다.",
            ifFlipped: "\"잠깐 보고 오면 되겠지\"라는 합리적인 판단이 배신당하고, 사용자는 다시 시작하지 않는다.",
            diff: "결제 중에도 탭바가 살아 있음 ↔ 탭바를 숨기고 취소에 확인을 붙임.",
            sources: ["3.3.1"], mistakeNumber: 62
        ),
        Lesson(
            id: "L22", number: 22, pair: .paymentSheet,
            title: "이 시트가 확정하는 순간인가",
            subtitle: "뒤에서 값이 바뀌면 시트가 거짓말을 한다",
            task: "결제 시트를 연 **다음**, 뒤 화면에서 **수량을 바꿔** 보세요. 그리고 시트의 결제하기를 누르세요.",
            question: "시트에 표시된 금액과 실제 청구액이 같았나요? 사용자는 어느 쪽을 봤을까요?",
            placeholder: "예: 시트에는 열었을 때 금액이 남아 있었다. 뒤에서 수량을 늘렸더니 청구액이 달랐다.",
            decision: "결제 시트를 모달로 두고, 참조해야 할 내용(수량·합계)을 시트 안으로 가져왔다.",
            why: "비모달이 좋았던 화면들에는 공통점이 있다 — **뒤에서 무엇을 하든 시트 내용이 흔들리지 않는다.** 확정하는 시트는 반대다. 뒤를 열어두는 순간 표시된 값과 청구될 값이 갈라질 창이 열린다.",
            ifFlipped: "편의를 준 게 아니라 불일치를 허용한 것이 된다. 그 불일치는 결제 문의로 돌아온다.",
            diff: "비모달(뒤 조작 가능) ↔ 모달 + 시트 안 주문 요약. 결제하기를 누르면 결과가 아래에 남습니다.",
            sources: ["4.1.5"], mistakeNumber: 79
        ),
        Lesson(
            id: "L23", number: 23, pair: .menuOrder,
            title: "메뉴의 순서를 정하는 기준",
            subtitle: "흐름이 아니라 무게로 정한다",
            task: "파일 하나의 **⋯ 메뉴를 열고 이름 변경**을 눌러보세요. 메뉴를 보지 말고 빠르게 눌러보세요.",
            question: "손이 먼저 간 자리는 어디였나요? 삭제와 얼마나 가까웠나요?",
            placeholder: "예: 위에서 두세 번째쯤으로 손이 갔다. 거기 삭제가 있어서 아찔했다.",
            decision: "삭제를 구분선 아래 맨 끝으로 내리고 `role: .destructive` 를 줬다.",
            why: "사용자는 메뉴를 읽지 않는다. 열고 **대략의 위치로 손을 뻗는다.** 그 자리에 되돌릴 수 없는 항목이 균일한 모습으로 섞여 있으면 손이 멈출 이유가 없다.",
            ifFlipped: "작업 흐름 순서대로 정렬하면 논리적으로는 맞지만, 손의 습관과는 어긋난다.",
            diff: "삭제가 항목들 사이 ↔ 구분선 아래 맨 끝(빨간색). 항목 구성은 같습니다.",
            sources: ["7.1.1"], mistakeNumber: 96
        ),
    ]

    static func lesson(_ id: String) -> Lesson? { all.first { $0.id == id } }
}

// MARK: - 학습 노트

/// 레슨마다 학습자가 남긴 글. 이 앱이 저장하는 유일한 콘텐츠다.
struct LessonNote: Codable, Hashable, Sendable {
    /// ② 단계에서 쓴 느낀 점.
    var impression: String = ""
    /// ⑤ 단계에서 쓴 배운 것.
    var takeaway: String = ""
    var completedAt: Date?

    var isEmpty: Bool { impression.isEmpty && takeaway.isEmpty }
    var isCompleted: Bool { completedAt != nil }
}

/// 학습자가 쓴 글과 진도를 들고 있는 저장소.
@MainActor
@Observable
final class NotebookStore {
    private enum Key {
        static let notes = "higgym.lessonNotes"
    }

    private(set) var notes: [String: LessonNote] = [:]
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if let data = defaults.data(forKey: Key.notes),
           let decoded = try? JSONDecoder().decode([String: LessonNote].self, from: data) {
            notes = decoded
        }
    }

    func note(for lesson: Lesson) -> LessonNote { notes[lesson.id] ?? LessonNote() }

    func write(_ note: LessonNote, for lesson: Lesson) {
        notes[lesson.id] = note
        persist()
    }

    func complete(_ lesson: Lesson) {
        var note = note(for: lesson)
        note.completedAt = Date()
        write(note, for: lesson)
    }

    func reset(_ lesson: Lesson) {
        notes[lesson.id] = nil
        persist()
    }

    var completedCount: Int { Lesson.all.filter { note(for: $0).isCompleted }.count }

    /// 마지막으로 끝낸 다음 편 — 코스 화면의 "이어서 하기".
    var next: Lesson? {
        Lesson.all.first { !note(for: $0).isCompleted } ?? Lesson.all.last
    }

    /// 학습 노트를 통째로 복사할 수 있게 — 남긴 글은 앱 밖으로 나갈 수 있어야 한다.
    var plainText: String {
        var lines: [String] = ["# HigGym 학습 노트", ""]
        for lesson in Lesson.all {
            let note = note(for: lesson)
            guard !note.isEmpty else { continue }
            lines.append("## \(lesson.number). \(lesson.title)")
            if !note.impression.isEmpty {
                lines.append("**써보고 느낀 것**")
                lines.append(note.impression)
            }
            if !note.takeaway.isEmpty {
                lines.append("**배운 것**")
                lines.append(note.takeaway)
            }
            lines.append("근거 · " + lesson.sources.joined(separator: " · "))
            lines.append("")
        }
        return lines.joined(separator: "\n")
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(notes) else { return }
        defaults.set(data, forKey: Key.notes)
    }
}
