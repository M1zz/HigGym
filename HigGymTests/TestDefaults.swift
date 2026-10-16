import Foundation

/// 테스트마다 따로 쓰는 UserDefaults. 실제 앱의 학습 기록을 건드리지 않고, 끝나면 지운다.
final class TestDefaults {
    let suiteName = "HigGymTests.\(UUID().uuidString)"
    let defaults: UserDefaults

    init() {
        defaults = UserDefaults(suiteName: suiteName)!
    }

    deinit {
        defaults.removePersistentDomain(forName: suiteName)
    }
}
