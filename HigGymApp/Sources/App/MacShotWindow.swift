#if DEBUG && targetEnvironment(macCatalyst)
import UIKit

/// Mac 스크린샷: `HG_MAC_WINDOW=가로,세로`(UIKit pt) 를 주면 창을 그 크기로 묶는다.
/// Mac App Store 규격(2880×1800)에 꾸밈 없이 맞추려고 — scripts/capture_mac.sh 만 쓴다.
enum MacShotWindow {
    static func applyIfAsked() {
        guard let raw = ProcessInfo.processInfo.environment["HG_MAC_WINDOW"] else { return }
        let parts = raw.split(separator: ",").compactMap { Double($0) }
        guard parts.count == 2 else { return }
        let size = CGSize(width: parts[0], height: parts[1])
        for case let scene as UIWindowScene in UIApplication.shared.connectedScenes {
            scene.sizeRestrictions?.minimumSize = size
            scene.sizeRestrictions?.maximumSize = size
        }
    }
}
#endif
