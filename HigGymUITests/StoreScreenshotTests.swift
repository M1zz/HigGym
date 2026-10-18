import XCTest

/// App Store 스크린샷 원본을 언어마다 찍는다. 평소 시험에서는 건너뛴다.
///
///   TEST_RUNNER_HG_SHOTS_DIR=/경로 TEST_RUNNER_HG_SHOTS_LANG=en xcodebuild test \
///     -only-testing:HigGymUITests/StoreScreenshotTests ...
///
/// 찍은 그림은 `<경로>/<언어>/0N-….png` (1320×2868, 6.9" 시뮬레이터). 합성은 scripts/make_marketing_screenshots.py.
@MainActor
final class StoreScreenshotTests: XCTestCase {
    private var directory: URL!
    private var language = "ko"

    override func setUpWithError() throws {
        let env = ProcessInfo.processInfo.environment
        let dir = try XCTUnwrap(env["HG_SHOTS_DIR"], "스크린샷 실행이 아니다")
        language = env["HG_SHOTS_LANG"] ?? "ko"
        directory = URL(fileURLWithPath: dir).appendingPathComponent(language)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        continueAfterFailure = false
    }

    override func invokeTest() {
        guard ProcessInfo.processInfo.environment["HG_SHOTS_DIR"] != nil else { return }
        super.invokeTest()
    }

    private func launch(_ environment: [String: String]) -> XCUIApplication {
        let app = XCUIApplication()
        let locale = ["ko": "ko_KR", "en": "en_US", "ja": "ja_JP"][language] ?? "en_US"
        app.launchArguments = ["-AppleLanguages", "(\(language))", "-AppleLocale", locale]
        app.launchEnvironment = environment.merging(["HG_SHOTS": "1"]) { $1 }
        app.launch()
        return app
    }

    private func shoot(_ name: String, after delay: TimeInterval = 2) {
        Thread.sleep(forTimeInterval: delay)
        let data = XCUIScreen.main.screenshot().pngRepresentation
        try? data.write(to: directory.appendingPathComponent(name))
    }

    /// 순서가 중요하다 - 앞 장은 빈 기록에서, '적어보기'부터는 표본 노트를 깐 상태에서 찍는다.
    func testCaptureStoreScreens() {
        var app = launch(["HG_TAB": "course"])
        shoot("01-course.png")
        app.terminate()

        app = launch(["HG_LESSON": "L1", "HG_STEP": "0"])
        shoot("02-try.png")
        app.terminate()

        app = launch(["HG_LESSON": "L1", "HG_STEP": "1", "HG_SEED_NOTES": "1"])
        shoot("03-write.png")
        app.terminate()

        app = launch(["HG_LESSON": "L1", "HG_STEP": "2", "HG_SEED_NOTES": "1"])
        shoot("04-reason.png")
        app.terminate()

        app = launch(["HG_LESSON": "L1", "HG_STEP": "3", "HG_SEED_NOTES": "1"])
        shoot("05-compare.png")
        app.terminate()

        app = launch(["HG_TAB": "library", "HG_LIB": "entries"])
        shoot("06-items.png")
        app.terminate()

        // 제품 페이지 헤더 · 검색 결과 그림(scripts/make_creative_assets.py)에 쓰는 노트 화면.
        app = launch(["HG_TAB": "notebook", "HG_SEED_NOTES": "1"])
        shoot("creative-notebook.png")
        app.terminate()
    }
}
