import Foundation
import OSLog

/// 앱이 남기는 기록과 성능 구간의 한 곳.
///
/// `print` 대신 통합 로그(Console.app · `log stream --predicate 'subsystem == "com.leeo.higgym"'`)에 남긴다.
/// 사용자 글(노트 본문)은 절대 싣지 않는다. 남기는 것은 무엇이 실패했는지와 몇 개였는지뿐이다.
enum HigGymLog {
    static let subsystem = Bundle.main.bundleIdentifier ?? "com.leeo.higgym"

    /// 번들 콘텐츠(entries.json · mistakes.json)를 읽고 번역을 입히는 일.
    static let content = Logger(subsystem: subsystem, category: "content")
    /// 학습 노트 저장·내보내기.
    static let notes = Logger(subsystem: subsystem, category: "notes")
    /// 시작 · 세이프 모드 · 새 기능 안내.
    static let launch = Logger(subsystem: subsystem, category: "launch")

    /// 첫 화면이 뜨기 전에 하는 무거운 일(콘텐츠 디코딩·번역·퀴즈 문항 생성)을 Instruments 에서 구간으로 본다.
    static let signposter = OSSignposter(subsystem: subsystem, category: .pointsOfInterest)
}
