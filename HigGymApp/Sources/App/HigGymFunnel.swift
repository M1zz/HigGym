import Foundation
import LeeoKit

/// 처음 연 사람이 이 앱의 핵심(레슨 한 편을 끝까지 하고, 쓴 글을 가져가는 것)까지 어디서 멈추는지 본다.
///
/// 단계마다 **처음 도달했을 때 한 번만** 익명 사용 통계(→ HigGymSpec.analytics, FeedbackHub)로 보낸다.
/// 몇 번 했는지는 세지 않는다. 노트 본문 같은 사용자 글은 싣지 않는다, 이벤트 이름뿐이다.
enum HigGymFunnel {
    enum Step: String, CaseIterable, Sendable {
        /// 설치 뒤 처음 연 날.
        case firstOpen = "funnel_1_first_open"
        /// 레슨을 처음 연 순간 (써보기 단계).
        case lessonStarted = "funnel_2_lesson_started"
        /// 다섯 단계를 끝까지 마친 순간.
        case lessonCompleted = "funnel_3_lesson_completed"
        /// 쓴 글을 노트에서 복사해 간 순간.
        case notesExported = "funnel_4_notes_exported"
    }

    /// 그 단계에 처음 도달했으면 기록하고 true. 이미 지난 단계면 아무것도 하지 않는다.
    @discardableResult
    static func reach(
        _ step: Step,
        defaults: UserDefaults = .standard,
        analytics: any LeeoAnalytics = HigGymSpec.analytics
    ) -> Bool {
        let key = "higgym.funnel.\(step.rawValue)"
        guard !defaults.bool(forKey: key) else { return false }
        defaults.set(true, forKey: key)
        analytics.track(step.rawValue)
        return true
    }
}
