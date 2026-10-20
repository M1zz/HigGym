//
//  HigGymSpec.swift
//  HigGym
//
//  LeeoKit 계약(LeeoAppSpec) 준수, 이 앱의 공통 기능 설정값 단일 소스.
//  피드백·리뷰·진단 구현은 전부 LeeoKit 에 있고, 앱은 이 설정만 제공한다.
//
//  ⚠️ recordType/구독 ID는 CloudKit Dashboard·기존 사용자 기기와의 계약이다, 변경 금지.
//

import Foundation
import LeeoKit

enum HigGymSpec: LeeoAppSpec {
    static let appName = "앱 디자인 실습"
    static let developerEmail = "leeo@kakao.com"

    /// App Store 앱 ID. 설정의 "리뷰 남기기"가 작성 페이지로 바로 간다.
    static let appStoreID: String? = "6808132576"

    /// 설정의 문의 행이 여는 인스타그램.
    // 아래 URL 들은 고정 문자열 상수라 실패할 수 없다.
    // swiftlint:disable force_unwrapping
    static let instagramURL = URL(string: "https://instagram.com/lee25_ios")!

    /// 공용 피드백 허브(FeedbackHub)로 수집, appIdentifier(번들 ID)로 앱을 구분한다.
    /// 컨테이너 권한은 project.yml 의 entitlements(→ HigGymApp/HigGym.entitlements)에 있다. 빼면 CKContainer 를 만드는 순간 앱이 죽는다.
    static let feedback = LeeoFeedbackConfig(
        containerIdentifier: "iCloud.com.Ysoup.FeedbackHub",
        appIdentifier: "com.leeo.higgym"
    )

    /// 개인정보·지원 페이지 (LeeoKit 3.x 부터 필수). README.md 에 적힌 주소를 그대로 쓴다.
    static let legal = LeeoLegalConfig(
        privacyURL: URL(string: "https://m1zz.github.io/HigGym/privacy.html")!,
        supportURL: URL(string: "https://m1zz.github.io/HigGym/support.html")!,
        marketingURL: URL(string: "https://m1zz.github.io/HigGym/")!
    )
    // swiftlint:enable force_unwrapping

    /// 수익모델 (LeeoKit 3.x 부터 필수), 부분유료: 앞부분은 무료, 평생 이용권 한 번으로 전부 연다.
    /// 무엇이 몇 번째까지 무료인지의 판정은 HigGymPro.allows 가 이 선언을 읽어 한다.
    /// 1.0.2 (빌드 5) 이하로 처음 받은 사람은 평생 Pro 다 (HigGymPro.lastFreeBuild).
    static let monetization = LeeoMonetization.freemium(
        LeeoPurchaseConfig(
            productIDs: [HigGymPro.productID],
            gate: LeeoGatePolicy(
                freeLimits: [
                    HigGymPro.Key.lesson: 3,       // 레슨 1~3편
                    HigGymPro.Key.mistake: 10,     // 실수 1~10편
                    HigGymPro.Key.lab: 1,          // 첫 실습실(툴바 배치)
                    HigGymPro.Key.quizChapter: 1,  // 퀴즈 1장 집중
                ],
                proOnly: [HigGymPro.Key.quizMode, HigGymPro.Key.liveQuiz]
            )
        )
    )

    /// 익명 사용 통계 → FeedbackHub(CloudKit). 기본값(Noop)이면 부트스트랩이 아무것도 보내지 않는다.
    static let analytics: any LeeoAnalytics = LeeoUsageAnalytics(spec: HigGymSpec.self)
}
