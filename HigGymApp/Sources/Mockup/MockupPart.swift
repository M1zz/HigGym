import SwiftUI

/// 목업에서 눌러볼 수 있는 한 부위. 클래스 이름이 곧 그 자리의 이름이다.
struct MockupPart: Hashable {
    let classes: [String]
    let text: String?

    init(node: MockupNode) {
        classes = node.classes
        text = node.text
    }

    /// 설명이 붙어 있는 부위만 눌린다 — 아무 데나 눌리면 그것대로 소음이다.
    var isMeaningful: Bool { entry != nil }

    private var entry: Glossary.Entry? {
        // 더 구체적인 클래스가 이긴다 (.cap.rd 는 .cap 보다 먼저).
        for name in classes.sorted(by: { Glossary.priority($0) > Glossary.priority($1) }) {
            if let found = Glossary.table[name] { return found }
        }
        return nil
    }

    var name: String { entry?.name ?? "" }
    var meaning: String { entry?.meaning ?? "" }
    var source: String { entry?.source ?? "" }
    var accent: Color { classes.contains("hl") || classes.contains("hlb") ? .hgAccent : .hgMuted }
}

enum Glossary {
    struct Entry {
        let name: String
        let meaning: String
        let source: String
    }

    /// 구체적인 클래스일수록 높은 값 — 같은 노드에 여러 클래스가 붙었을 때 무엇을 설명할지 정한다.
    static func priority(_ name: String) -> Int {
        switch name {
        case "rd", "search", "on", "src", "hlt": 3
        case "hl", "hlb":                        1
        default:                                 2
        }
    }

    static let table: [String: Entry] = [
        "pnav": .init(
            name: "상단 툴바",
            meaning: "leading은 이동, 가운데는 화면의 정체성, trailing은 확정 — 자리마다 말하는 것이 정해져 있습니다.",
            source: "1.1 · 8.1.3"
        ),
        "cap": .init(
            name: "유리 캡슐 (클러스터)",
            meaning: "같은 캡슐에 있으면 사용자는 **한 세트**로 읽습니다. 묶음 자체가 의미라서, 성격이 다른 것을 넣으면 묶음이 거짓 정보가 됩니다.",
            source: "1.1.3 · 8.1.3"
        ),
        "rd": .init(
            name: "단일 액션 캡슐",
            meaning: "액션이 하나뿐일 때의 최소 구성. 버튼이 하나면 캡슐도 하나 — 시각적 무게를 최소로 둡니다.",
            source: "1.1.1"
        ),
        "search": .init(
            name: "검색 필드",
            meaning: "iOS 26에서 검색은 “모드 진입”이라 툴바 안에서도 별도 형태를 갖습니다.",
            source: "1.4.1 · 3.4.2"
        ),
        "dot": .init(
            name: "툴바 아이템",
            meaning: "버튼 하나. 몇 개를 어느 자리에 두느냐가 곧 이 화면의 문법입니다.",
            source: "1.1"
        ),
        "ttl": .init(
            name: "제목",
            meaning: "이 화면이 무엇인지 말하는 장치. 인터랙티브 컨트롤로 대체하면 자리의 문법이 깨집니다.",
            source: "1.2 · 8.1.3"
        ),
        "big-ttl": .init(
            name: "Large 타이틀",
            meaning: "진입 순간엔 방향감을 주고, 읽기 시작하면 inline으로 접혀 공간을 콘텐츠에 반납합니다.",
            source: "1.2.1 · 8.1.1"
        ),
        "bbar": .init(
            name: "하단 바",
            meaning: "**자주·반복해서 누르는** 액션 자리. 엄지의 홈 그라운드라 빈도가 높을수록 여기로 내려옵니다.",
            source: "1.1.4 · 8.1.2"
        ),
        "tbar": .init(
            name: "탭바",
            meaning: "지금 어디에 있고 어디로 갈 수 있는지 보여주는 **상시 지도**. 3~5개가 안전 범위입니다.",
            source: "3.2.3 · 3.3.1"
        ),
        "ti": .init(
            name: "탭 아이템",
            meaning: "아이콘은 빠른 스캔용, 제목은 의미 확정용 — 두 채널을 함께 줘야 학습 없이 읽힙니다.",
            source: "3.1.1"
        ),
        "on": .init(
            name: "선택된 탭",
            meaning: "현재 위치 표시. 이게 있어야 깊이 들어가도 “나는 이 탭 안에 있다”는 맥락이 유지됩니다.",
            source: "3.3.1"
        ),
        "bdg": .init(
            name: "배지",
            meaning: "**“몇 개인지가 행동을 결정할 때”**만 붙입니다. 전부에 달면 인터럽트 가치가 인플레이션됩니다.",
            source: "3.1.3"
        ),
        "acc": .init(
            name: "하단 액세서리",
            meaning: "탭을 넘나드는 진행 중 상태는 특정 화면이 아니라 **앱 전역의 소유**라 탭바 계층에 붙습니다.",
            source: "3.5.1"
        ),
        "sheet": .init(
            name: "시트",
            meaning: "임시 컨텍스트 전환. 얼마나 덮느냐(detent)가 곧 “원본과의 관계”를 말합니다.",
            source: "4.1"
        ),
        "grab": .init(
            name: "그랩바",
            meaning: "“단계가 더 있다”는 어포던스. 높이 단계가 둘 이상이면 반드시 필요합니다.",
            source: "4.1.4"
        ),
        "dimm": .init(
            name: "딤",
            meaning: "모달성의 시각 신호 — 딤이 없다는 건 “뒤를 만져도 된다”는 뜻입니다.",
            source: "4.1.5"
        ),
        "drawer": .init(
            name: "검색 드로어",
            meaning: "제목 아래 한 줄. `.always`로 상시 노출하면 대부분의 순간 기여하지 않는 UI가 세로 공간을 계속 씁니다.",
            source: "1.4.3 · 1.4.4"
        ),
        "topglass": .init(
            name: "스크롤 가장자리 효과",
            meaning: "콘텐츠가 바 뒤를 지날 때 컨트롤이 읽히게 하는 층. 최악의 배경에서 검증해야 합니다.",
            source: "1.3 · 8.1.4"
        ),
        "matcard": .init(
            name: "Material 레이어",
            meaning: "뒤를 비춰 “콘텐츠 위에 떠 있다”는 깊이 관계를 표현합니다. 뒤가 복잡할수록 두껍게.",
            source: "6.1.1"
        ),
        "vbar": .init(
            name: "세로 Safe Area Bar",
            meaning: "가로 화면·iPad의 세로 도구 막대. 인셋과 가장자리 효과를 시스템이 대줍니다.",
            source: "5.2"
        ),
        "menu": .init(
            name: "메뉴",
            meaning: "드물게 쓰는 액션을 접어두는 곳. 파괴적 액션은 Divider로 분리해 빨간색이 규약입니다.",
            source: "7.1.1"
        ),
        "gcard": .init(
            name: "그리드 카드",
            meaning: "전환의 출처가 되는 요소. 탭한 것과 열린 것이 같음을 모션으로 증명할 대상입니다.",
            source: "4.3.2"
        ),
        "src": .init(
            name: "전환 출처",
            meaning: "`matchedTransitionSource` 로 지정한 요소 — 여기서 확대되어 열립니다.",
            source: "4.3.2"
        ),
        "seg": .init(
            name: "세그먼트 컨트롤",
            meaning: "값에 따라 화면 전체가 바뀌므로 “화면의 정체성” — principal 자리의 문법과 일치합니다.",
            source: "1.1.5"
        ),
        "ln": .init(
            name: "콘텐츠",
            meaning: "크롬이 물러나야 할 대상. UI는 이걸 돕는 수단이지 주인공이 아닙니다.",
            source: "8.1.1"
        ),
        "island": .init(
            name: "다이나믹 아일랜드",
            meaning: "시스템 영역. 상단 배치를 정할 때 실제로 쓸 수 있는 폭을 좌우합니다.",
            source: "1.2"
        ),
        "mtag": .init(
            name: "설명 라벨",
            meaning: "이 목업에서 지금 주목할 자리를 가리킵니다.",
            source: "—"
        ),
        "chip": .init(
            name: "칩",
            meaning: "필터·상태처럼 상단에 상주하는 작은 컨트롤.",
            source: "5.1.1"
        ),
    ]
}
