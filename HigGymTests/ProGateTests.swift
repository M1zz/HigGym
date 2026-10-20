import Foundation
import Testing
import LeeoKit
@testable import HigGym

/// 무료로 어디까지 여는지. 숫자 하나가 틀어지면 무료 사용자가 맛보기를 못 하거나, 결제한 의미가 사라진다.
@MainActor
struct ProGateTests {
    private let free = LeeoGate(policy: HigGymSpec.gate, hasPro: false, isTrialActive: false)
    private let paid = LeeoGate(policy: HigGymSpec.gate, hasPro: true, isTrialActive: false)

    @Test func 레슨은_앞의_세_편만_무료다() {
        let open = Lesson.all.filter { HigGymPro.allows(.lesson(id: $0.id), gate: free) }
        #expect(open.map(\.id) == Lesson.all.prefix(3).map(\.id))
    }

    @Test func 실수는_1편부터_10편까지_무료다() {
        #expect(HigGymPro.allows(.mistake(number: 1), gate: free))
        #expect(HigGymPro.allows(.mistake(number: 10), gate: free))
        #expect(!HigGymPro.allows(.mistake(number: 11), gate: free))
        #expect(!HigGymPro.allows(.mistake(number: 100), gate: free))
    }

    @Test func 실습실은_툴바만_무료다() {
        let open = LabID.allCases.filter { HigGymPro.allows(.lab($0), gate: free) }
        #expect(open == [.toolbar])
    }

    @Test func 퀴즈는_첫_장만_무료이고_훈련과_실전은_Pro다() {
        #expect(HigGymPro.allows(.quizChapter(0), gate: free))
        #expect(!HigGymPro.allows(.quizChapter(1), gate: free))
        #expect(!HigGymPro.allows(.quizMode, gate: free))
        #expect(!HigGymPro.allows(.liveQuiz, gate: free))
    }

    @Test func Pro는_전부_연다() {
        #expect(Lesson.all.allSatisfy { HigGymPro.allows(.lesson(id: $0.id), gate: paid) })
        #expect(MistakeStore.shared.mistakes.allSatisfy { HigGymPro.allows(.mistake(number: $0.number), gate: paid) })
        #expect(LabID.allCases.allSatisfy { HigGymPro.allows(.lab($0), gate: paid) })
        #expect(HigGymPro.allows(.quizMode, gate: paid))
        #expect(HigGymPro.allows(.liveQuiz, gate: paid))
        #expect(HigGymPro.allows(.general, gate: paid))
    }

    /// 상품 ID 는 App Store Connect 와의 계약이고, 판매 상품과 권한 상품이 같아야 산 사람이 열린다.
    /// 주간 · 월간 구독과 평생 이용권, 어느 것을 사도 같은 Pro 다.
    @Test func 파는_상품이_곧_여는_상품이다() throws {
        let paywall = try #require(HigGymSpec.paywall)
        let ids = ["com.leeo.higgym.pro.weekly", "com.leeo.higgym.pro.monthly", "com.leeo.higgym.pro"]
        #expect(paywall.productIDs == ids)
        #expect(paywall.entitlementIDs == Set(ids))
        #expect(HigGymSpec.monetization.sellsSubscription)
        #expect(paywall.termsURL != nil)
    }

    /// "모든 기능이 무료" 라고 받은 마지막 빌드는 1.0.2 의 빌드 5 다. 이 숫자가 줄면 그 사람들이 잠긴다.
    @Test func 무료판으로_받은_사람은_평생_Pro다() {
        #expect(HigGymPro.lastFreeBuild >= 5)
    }
}
