import SwiftUI

extension View {
    /// 만져 보는 iOS 화면(예제 · 실습 · 써보기)에 건다.
    ///
    /// 아이폰 · 아이패드에서는 아무것도 하지 않는다: 기기가 곧 그 화면이다.
    /// Mac 에서는 창이 얼마든지 늘어나 아이폰 화면의 비율과 엄지 자리가 사라지므로,
    /// **아이폰 크기 그대로** 베젤 안에 세운다(→ `PhoneStage`).
    @ViewBuilder
    func phoneStaged() -> some View {
        #if targetEnvironment(macCatalyst)
        PhoneStage { self }
        #else
        self
        #endif
    }
}

#if targetEnvironment(macCatalyst)
import UIKit

/// Mac 창 안에 세우는 아이폰 한 대.
///
/// 틀만 씌우면 안 된다. 예제가 띄우는 시트 · 전체 화면 덮개는 UIKit 이 **창 전체**에 올리므로
/// 틀 밖으로 나가 Mac 창을 덮는다. 그래서 화면을 아이폰 크기의 창(`PhoneWindow`)에 따로 세운다:
/// 그 안에서 뜨는 것은 모두 그 창 안에 머물고, 크기 클래스 · 안전 영역도 아이폰과 같아진다.
/// 여기 SwiftUI 쪽은 베젤을 그리고 그 창이 설 자리를 잡아 주기만 한다.
struct PhoneStage<Content: View>: View {
    @ViewBuilder var content: Content
    @Environment(\.self) private var environment

    var body: some View {
        GeometryReader { geo in
            let outer = CGSize(width: PhoneMetrics.screen.width + PhoneMetrics.bezel * 2,
                               height: PhoneMetrics.screen.height + PhoneMetrics.bezel * 2)
            let room = CGSize(width: max(geo.size.width - 24, 1), height: max(geo.size.height - 24, 1))
            // 비율은 절대 깨지 않는다. 자리가 모자라면 통째로 줄이고, 남아도 실물 크기보다 키우지 않는다.
            let scale = min(PhoneMetrics.actualSize, room.width / outer.width, room.height / outer.height)

            ZStack {
                RoundedRectangle(cornerRadius: (PhoneMetrics.corner + PhoneMetrics.bezel) * scale, style: .continuous)
                    .fill(Color.black)
                    .overlay(
                        RoundedRectangle(cornerRadius: (PhoneMetrics.corner + PhoneMetrics.bezel) * scale, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.22), lineWidth: 1.5)
                    )
                    .frame(width: outer.width * scale, height: outer.height * scale)
                    .shadow(color: .black.opacity(0.35), radius: 24, y: 10)

                PhoneWindowAnchor(
                    // 덮개의 닫기(dismiss) · 진도 · 노트 같은 환경은 새 창으로 저절로 건너가지 않는다. 통째로 넘긴다.
                    content: AnyView(content
                        .environment(\.horizontalSizeClass, .compact)
                        .environment(\.verticalSizeClass, .regular)
                        .environment(\.self, environment)),
                    scale: scale
                )
                .frame(width: PhoneMetrics.screen.width * scale, height: PhoneMetrics.screen.height * scale)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(minWidth: 220, minHeight: 440)
        .accessibilityElement(children: .contain)
    }
}

/// 아이폰 한 대의 치수(pt). 393×852 는 6.1~6.3형의 논리 화면이다.
enum PhoneMetrics {
    static let screen = CGSize(width: 393, height: 852)
    static let corner: CGFloat = 55
    static let bezel: CGFloat = 11
    /// Mac 은 화면을 77% 로 줄여 그린다(iPad 크기 맞춤). 이만큼 키워야 Mac 화면에서 실물 pt 크기다.
    static let actualSize: CGFloat = 1 / 0.77
    /// 위는 다이내믹 아일랜드, 아래는 홈 표시줄이 차지하는 안전 영역.
    static let safeArea = UIEdgeInsets(top: 59, left: 0, bottom: 34, right: 0)
}

// MARK: - 자리 표시 뷰 ↔ 아이폰 창

private struct PhoneWindowAnchor: UIViewRepresentable {
    let content: AnyView
    let scale: CGFloat

    func makeUIView(context: Context) -> AnchorView { AnchorView() }

    func updateUIView(_ view: AnchorView, context: Context) {
        view.scale = scale
        view.setContent(content)
    }

    static func dismantleUIView(_ view: AnchorView, coordinator: ()) {
        view.tearDown()
    }
}

/// SwiftUI 배치 안에서 "여기에 폰 화면" 이라는 자리만 차지하고, 아이폰 창을 그 자리에 붙들어 둔다.
private final class AnchorView: UIView {
    var scale: CGFloat = 1
    private var phone: PhoneWindow?
    private var pending: AnyView?
    private var link: CADisplayLink?

    func setContent(_ content: AnyView) {
        pending = content
        phone?.host.rootView = content
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard let scene = window?.windowScene else { return tearDown() }
        guard phone == nil else { return }
        let phone = PhoneWindow(windowScene: scene, content: pending ?? AnyView(EmptyView()))
        self.phone = phone
        sync()
        phone.makeKeyAndVisible()
        // 스크롤 · 창 크기 조절로 자리가 움직여도 layoutSubviews 는 불리지 않는다. 화면 주기마다 자리를 맞춘다.
        let link = CADisplayLink(target: self, selector: #selector(sync))
        link.add(to: .main, forMode: .common)
        self.link = link
    }

    @objc private func sync() {
        guard let phone, let window else { return }
        let frame = convert(bounds, to: window)
        let center = CGPoint(x: frame.midX, y: frame.midY)
        if phone.center != center { phone.center = center }
        let transform = CGAffineTransform(scaleX: scale, y: scale)
        if phone.transform != transform { phone.transform = transform }
    }

    func tearDown() {
        link?.invalidate()
        link = nil
        guard let phone else { return }
        self.phone = nil
        phone.rootViewController?.dismiss(animated: false)
        phone.isHidden = true
        phone.rootViewController = nil
        window?.makeKey()
    }
}

/// 아이폰 크기의 창. 이 안에서 뜨는 시트 · 덮개는 이 창을 넘지 않는다.
private final class PhoneWindow: UIWindow {
    let host: UIHostingController<AnyView>
    private let furniture = PhoneFurniture()

    init(windowScene: UIWindowScene, content: AnyView) {
        host = UIHostingController(rootView: content)
        super.init(windowScene: windowScene)
        bounds = CGRect(origin: .zero, size: PhoneMetrics.screen)
        windowLevel = .normal + 1
        layer.cornerRadius = PhoneMetrics.corner
        layer.cornerCurve = .continuous
        layer.masksToBounds = true
        // 창 너비가 393 이어도 Mac 은 넓은 화면으로 친다. 탭 막대 · 시트가 아이폰처럼 서도록 좁은 화면으로 못 박는다.
        traitOverrides.horizontalSizeClass = .compact
        traitOverrides.verticalSizeClass = .regular
        rootViewController = host
        furniture.frame = bounds
        addSubview(furniture)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) 는 쓰지 않는다") }

    /// Mac 창에는 안전 영역이 없다. 아이폰의 것을 준다: 이 창의 모든 화면(덮개 포함)이 이 값을 물려받는다.
    override var safeAreaInsets: UIEdgeInsets { PhoneMetrics.safeArea }

    /// 덮개 · 시트가 올라와도 아일랜드와 홈 표시줄은 맨 위에 남는다(실물이 그렇다).
    override func didAddSubview(_ subview: UIView) {
        super.didAddSubview(subview)
        if subview !== furniture { bringSubviewToFront(furniture) }
    }
}

/// 화면 위에 늘 얹혀 있는 것: 다이내믹 아일랜드, 시각, 홈 표시줄. 터치는 받지 않는다.
private final class PhoneFurniture: UIView {
    private let island = UIView()
    private let clock = UILabel()
    private let home = UIView()

    init() {
        super.init(frame: .zero)
        isUserInteractionEnabled = false
        isAccessibilityElement = false
        autoresizingMask = [.flexibleWidth, .flexibleHeight]

        island.backgroundColor = .black
        island.layer.cornerRadius = 18.5
        island.layer.cornerCurve = .continuous
        clock.text = "9:41"
        clock.font = .systemFont(ofSize: 17, weight: .semibold)
        clock.textColor = .label
        clock.textAlignment = .center
        home.backgroundColor = .label
        home.layer.cornerRadius = 2.5
        [island, clock, home].forEach(addSubview)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) 는 쓰지 않는다") }

    override func layoutSubviews() {
        super.layoutSubviews()
        island.frame = CGRect(x: (bounds.width - 126) / 2, y: 11, width: 126, height: 37)
        clock.frame = CGRect(x: 30, y: 14, width: 80, height: 30)
        home.frame = CGRect(x: (bounds.width - 139) / 2, y: bounds.height - 13, width: 139, height: 5)
    }
}
#endif
