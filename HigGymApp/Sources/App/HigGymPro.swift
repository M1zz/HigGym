import Foundation
import Combine
import StoreKit
import LeeoKit

/// 앱 디자인 실습 Pro: 한 번 결제로 평생 여는 권한과, 무료로 어디까지 여는지의 판정.
///
/// 무료로 두는 것은 **이 앱이 어떤 공부인지 끝까지 겪어 볼 만큼**이다:
/// 레슨 앞 3편 · 실수 앞 10편 · 첫 실습실(툴바) · 퀴즈 첫 장 · 샘플 앱 · 오답 복습 ·
/// 항목 68개와 예제 · 원칙 7개 · 노트. 나머지는 Pro 다.
///
/// 한도 숫자와 상품 ID 는 `HigGymSpec.monetization` 한 곳에 있다. 여기서는 그 선언을
/// "이 레슨(이 실수, 이 실습실)은 몇 번째인가" 로 바꿔 묻기만 한다.
@MainActor
final class HigGymPro: ObservableObject {
    static let shared = HigGymPro()

    // App Store Connect 의 상품 ID 와의 계약이다, 바꾸지 않는다. 셋 다 같은 Pro 를 연다.
    /// 자동 갱신 구독 (구독 그룹 "Pro"). 월간이 그룹 레벨 1, 주간이 2.
    nonisolated static let monthlyID = "com.leeo.higgym.pro.monthly"
    nonisolated static let weeklyID = "com.leeo.higgym.pro.weekly"
    /// 비소모성 평생 이용권.
    nonisolated static let lifetimeID = "com.leeo.higgym.pro"
    /// 결제 화면에 보이는 순서: 주간 · 월간 · 평생.
    nonisolated static let productIDs = [weeklyID, monthlyID, lifetimeID]

    /// 결제 없이 나간 마지막 빌드 번호. 이 빌드 이하로 처음 설치한 사람은 평생 Pro 다
    /// ("모든 기능이 무료" 라고 약속하고 받은 사용자). 1.0.2 (빌드 5) 가 마지막 무료판이다.
    /// 결제가 들어가기 전에 무료 빌드를 하나 더 올리면 이 숫자도 같이 올린다.
    nonisolated static let lastFreeBuild = 5

    /// 무엇을 열려고 하는가. 페이월이 "방금 부딪힌 그것" 을 말하는 데도 쓴다.
    enum Feature: Hashable, Identifiable, Sendable {
        case lesson(id: String)
        case mistake(number: Int)
        case lab(LabID)
        case quizChapter(Int)
        /// 랜덤 · 원칙 판정 · 판별 · 상황 → 컴포넌트 훈련.
        case quizMode
        /// 실전 문항 (기준 → 화면 고르기 · 화면 → 이유 고르기).
        case liveQuiz
        /// 특정 기능 없이 설정에서 연 경우.
        case general

        var id: String {
            switch self {
            case .lesson(let id):       "lesson.\(id)"
            case .mistake(let n):       "mistake.\(n)"
            case .lab(let lab):         "lab.\(lab.rawValue)"
            case .quizChapter(let n):   "quizChapter.\(n)"
            case .quizMode:             "quizMode"
            case .liveQuiz:             "liveQuiz"
            case .general:              "general"
            }
        }
    }

    /// `HigGymSpec.monetization` 의 게이트 키. 매니페스트·시험과의 계약이다.
    enum Key {
        static let lesson = "lesson"
        static let mistake = "mistake"
        static let lab = "lab"
        static let quizChapter = "quizChapter"
        static let quizMode = "quizMode"
        static let liveQuiz = "liveQuiz"
    }

    let store: LeeoStore
    private var storeChange: AnyCancellable?

    private init() {
        guard let config = HigGymSpec.paywall else {
            preconditionFailure("HigGymSpec.monetization 에 상품이 없다")
        }
        store = LeeoStore(
            config: config,
            unlockOverride: { Self.unlockOverride() },
            grandfather: { await Self.installedBeforePaywall() }
        )
        // 구매·복원·환불로 권한이 바뀌면 이 객체를 보는 화면도 다시 그린다.
        storeChange = store.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }
    }

    var hasPro: Bool { store.hasPro }
    /// 처음부터 함께한 사람이라 결제 없이 Pro 인가.
    var isGrandfathered: Bool { store.isGrandfathered && store.purchasedProductIDs.isEmpty }
    /// 자동 갱신 구독으로 Pro 인가 (설정에 '구독 관리' 를 보일지). 평생 이용권이 있으면 구독은 의미가 없다.
    var isSubscriber: Bool {
        !store.purchasedProductIDs.contains(Self.lifetimeID)
            && !store.purchasedProductIDs.isDisjoint(with: [Self.weeklyID, Self.monthlyID])
    }

    func allows(_ feature: Feature) -> Bool {
        Self.allows(feature, gate: store.gate)
    }

    /// 권한과 무관한 순수 판정. 시험이 같은 함수를 부른다.
    static func allows(_ feature: Feature, gate: LeeoGate) -> Bool {
        switch feature {
        case .lesson(let id):
            guard let position = Lesson.all.firstIndex(where: { $0.id == id }) else { return true }
            return gate.evaluate(Key.lesson, current: position).isAllowed
        case .mistake(let number):
            return gate.evaluate(Key.mistake, current: number - 1).isAllowed
        case .lab(let lab):
            let position = LabID.allCases.firstIndex(of: lab) ?? 0
            return gate.evaluate(Key.lab, current: position).isAllowed
        case .quizChapter(let position):
            return gate.evaluate(Key.quizChapter, current: position).isAllowed
        case .quizMode:
            return gate.allows(Key.quizMode)
        case .liveQuiz:
            return gate.allows(Key.liveQuiz)
        case .general:
            return gate.isUnlocked
        }
    }

    // MARK: - 권한 정책

    /// 스크린샷 촬영(HG_ 환경변수로 띄운 실행)은 늘 Pro 화면이어야 한다.
    /// 잠금 화면을 시험할 때는 `HG_PRO=0`, 강제로 열 때는 `HG_PRO=1`.
    private static func unlockOverride() -> Bool? {
        #if DEBUG
        switch ProcessInfo.processInfo.environment["HG_PRO"] {
        case "0": return false
        case "1": return true
        default:  return DebugLaunch.isScripted ? true : nil
        }
        #else
        return nil
        #endif
    }

    /// 결제가 들어가기 전 빌드로 처음 설치했는지. iOS 의 `originalAppVersion` 은
    /// 버전이 아니라 **빌드 번호**다. 샌드박스·TestFlight 는 늘 "1.0" 을 주므로
    /// 실서비스 영수증만 본다 (그러지 않으면 테스트에서 결제 화면을 볼 수 없다).
    private static func installedBeforePaywall() async -> Bool {
        guard let result = try? await AppTransaction.shared,
              case .verified(let transaction) = result,
              transaction.environment == .production,
              let build = Int(transaction.originalAppVersion)
        else { return false }
        return build <= lastFreeBuild
    }
}
