import XCTest

/// 실제 앱을 띄워 핵심 흐름(레슨 한 편의 다섯 단계 → 노트)을 한 바퀴 돌고, 접근성 감사를 한다.
///
/// 첫 실행 안내 · 기능 말풍선 · 새 기능 안내는 HG_ 환경변수가 있으면 뜨지 않는다(→ DebugLaunch.isScripted).
@MainActor
final class HigGymUITests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    private func launch(_ environment: [String: String] = [:]) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchEnvironment = ["HG_UITEST": "1"].merging(environment) { $1 }
        app.launch()
        return app
    }

    /// 학습 탭에서 첫 레슨을 열어 다섯 단계를 끝까지 넘기고, 노트 탭에 그 레슨이 생기는지 본다.
    func testLessonRoundTrip() {
        let app = launch(["HG_LESSON": "L1"])
        let next = app.buttons["lesson.next"]
        XCTAssertTrue(next.waitForExistence(timeout: 10), "레슨 화면이 열리지 않았다")

        next.tap()                                   // ① 써보기 → ② 적어보기
        let editor = app.textViews.firstMatch
        XCTAssertTrue(editor.waitForExistence(timeout: 5))
        editor.tap()
        editor.typeText("Reaching up every time felt awkward.")
        next.tap()                                   // ② → ③ 이유 확인
        next.tap()                                   // ③ → ④ 비교
        next.tap()                                   // ④ → ⑤ 배운 것
        next.tap()                                   // 마치기

        app.tabBars.buttons.element(boundBy: 1).tap()  // 노트 탭
        let note = app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", "felt awkward")).firstMatch
        if !note.waitForExistence(timeout: 5) { print(app.debugDescription) }
        XCTAssertTrue(note.exists, "쓴 글이 노트에 쌓이지 않았다")
    }

    /// 학습 · 노트 · 자료 세 탭의 첫 화면에 접근성 문제가 없는지.
    func testAccessibilityAudit() throws {
        let app = launch(["HG_SEED_NOTES": "1"])
        XCTAssertTrue(app.tabBars.firstMatch.waitForExistence(timeout: 10))
        for index in 0..<3 {
            app.tabBars.buttons.element(boundBy: index).tap()
            let tabBarFrame = app.tabBars.firstMatch.frame
            try app.performAccessibilityAudit(for: [.dynamicType, .sufficientElementDescription, .hitRegion, .contrast]) { issue in
                // 탭 막대·내비게이션 바처럼 시스템이 그리는 요소의 문제는 앱이 고칠 수 없다.
                guard let element = issue.element else { return false }
                if element.elementType == .tabBar || element.elementType == .navigationBar { return true }
                // 탭 막대 유리 밑으로 스크롤돼 들어간 글은 가장자리 효과로 흐려 보일 뿐이다(스크롤하면 제 대비로 돌아온다).
                // 화면 안에서 읽히는 자리의 대비만 본다.
                if issue.auditType == .contrast, element.frame.intersects(tabBarFrame) { return true }
                return false
            }
        }
    }
}
