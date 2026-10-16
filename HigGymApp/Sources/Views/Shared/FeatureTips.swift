import SwiftUI
import TipKit

//  기능 안내 말풍선 (TipKit).
//
//  아이콘 하나로만 보이는 기능, 또는 메뉴 안에 숨어 있는 기능만 알려 준다.
//  TipKit 이 표시 빈도와 "이미 써 봤는지"를 관리한다 (→ HigGymApp 의 Tips.configure).
//  원격 킬스위치 HigGymFlag.featureTipsEnabled 를 끄면 Tips.configure 를 부르지 않아 아무것도 뜨지 않는다.

/// 레슨 머리의 책 아이콘 - 이 결정의 근거 본문을 레슨 중 언제든 열 수 있다.
struct LessonReferenceTip: Tip {
    var title: Text { Text("근거 본문은 여기서") }
    var message: Text? {
        Text("이 레슨이 다루는 결정의 근거 항목을 단계와 상관없이 언제든 펼쳐 볼 수 있습니다.")
    }
    var image: Image? { Image(systemName: "book") }
}

/// 노트 탭의 내보내기 메뉴 - 쓴 글을 앱 밖으로 가져갈 수 있다.
struct ExportNotesTip: Tip {
    var title: Text { Text("노트를 앱 밖으로") }
    var message: Text? {
        Text("쓴 글을 텍스트로 복사하거나 마크다운 파일로 내보낼 수 있습니다. 노트는 이 기기에만 저장되니 가끔 내보내 두세요.")
    }
    var image: Image? { Image(systemName: "square.and.arrow.up") }
}
