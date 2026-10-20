import SwiftUI
import StoreKit
import LeeoKit

/// Pro 결제 화면. 상품 로드·구매·복원·권한은 `HigGymPro.shared.store`(LeeoStore)가 한다.
///
/// LeeoPaywallView 를 쓰지 않는 이유 두 가지:
/// ① 결제는 `@Environment(\.purchase)` 로 해야 한다. 아이폰 전용 앱도 심사는 아이패드에서
///    돌려 보는데, 창을 짐작하는 결제는 거기서 오류로 끝난다 (2.1(b) 거절 사례).
/// ② 디자인을 가르치는 앱이다. 결제 화면도 앱의 카드 · 색 · 글자 체계를 그대로 따른다.
///
/// 원칙: 무엇이 열리는지는 숫자로, 결제는 한 번뿐이라는 것을 버튼 바로 아래에, 닫기는 늘 보이게.
struct HigGymPaywallView: View {
    /// 무엇을 열려다 여기 왔는가. 맨 위 한 줄이 그것을 말한다.
    var feature: HigGymPro.Feature = .general
    /// nil 이면 환경의 dismiss 로 닫는다 (push · sheet · cover 어디서든).
    var onClose: (() -> Void)?

    @ObservedObject private var pro = HigGymPro.shared
    @Environment(\.purchase) private var purchaseAction
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    private var store: LeeoStore { pro.store }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    hero
                    benefits
                    promise
                }
                .padding(.horizontal, 22)
                .padding(.top, 56)
                .padding(.bottom, 20)
                .frame(maxWidth: 560)
                .frame(maxWidth: .infinity)
            }
            purchaseBar
        }
        .background(Color.hgBackground)
        .overlay(alignment: .topTrailing) { closeButton }
        .task {
            LeeoAnalyticsCenter.track(.paywallShown(reason: feature.id))
            if store.products.isEmpty { await store.loadProducts() }
        }
    }

    // MARK: 맨 위: 무엇을 열려다 왔는가

    private var hero: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "lock.open.fill")
                    .font(.footnote.weight(.bold))
                Text("앱 디자인 실습 Pro")
                    .font(.footnote.weight(.bold))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 11)
            .padding(.vertical, 6)
            .background(.hgBrand, in: .capsule)
            .accessibilityElement(children: .combine)

            Text(headline)
                .font(.title.bold())
                .foregroundStyle(.hgText)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityAddTraits(.isHeader)

            Text(reason)
                .font(.callout)
                .foregroundStyle(.hgMuted)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var headline: String {
        String(localized: "결정 하나하나에 이유를 대는 디자이너로")
    }

    /// 방금 부딪힌 것을 그대로 말한다. 막힌 이유를 모르면 결제 화면은 벽처럼 느껴진다.
    private var reason: String {
        switch feature {
        case .lesson(let id):
            let number = Lesson.all.first { $0.id == id }?.number ?? 4
            return String(localized: "\(number)편부터는 Pro에서 이어집니다. 앞에서 해 본 그 방식으로 나머지 \(Lesson.all.count - number + 1)편을 밟습니다.")
        case .mistake(let number):
            return String(localized: "실수 \(number)편은 Pro에서 열립니다. 무엇을 했고, 왜 그게 맞아 보였고, 어떻게 고치는지까지 전부 봅니다.")
        case .lab(let lab):
            return String(localized: "\(lab.title) 실습실은 Pro에서 열립니다. 설정을 바꿀 때마다 그 자리에서 판정을 받습니다.")
        case .quizChapter:
            return String(localized: "이 장의 퀴즈는 Pro에서 열립니다. 모든 장과 훈련 모드로 판단을 손에 익힙니다.")
        case .quizMode, .liveQuiz:
            return String(localized: "이 훈련은 Pro에서 열립니다. 화면을 보고 판단하는 문제를 끝까지 풉니다.")
        case .general:
            return String(localized: "한 번 결제로 모든 레슨과 자료를 엽니다. 무료로 해 본 그 방식 그대로입니다.")
        }
    }

    // MARK: 무엇이 열리는가: 숫자로

    private var benefits: some View {
        VStack(spacing: 0) {
            benefit("graduationcap.fill", .hgAccent,
                    String(localized: "레슨 \(Lesson.all.count)편 전부"),
                    String(localized: "써 보고, 적고, 이유를 보고, 고친 화면과 비교합니다"))
            Divider().overlay(Color.hgLine).padding(.leading, 56)
            benefit("exclamationmark.triangle.fill", .hgAmber,
                    String(localized: "실수 \(MistakeStore.shared.mistakes.count)편과 회고"),
                    String(localized: "그때는 왜 맞아 보였는지까지 읽습니다"))
            Divider().overlay(Color.hgLine).padding(.leading, 56)
            benefit("hammer.fill", .hgGreen,
                    String(localized: "실습실 \(LabID.allCases.count)종"),
                    String(localized: "툴바, 가장자리 효과, 글자 잘림, 탭바, 시트"))
            Divider().overlay(Color.hgLine).padding(.leading, 56)
            benefit("checkmark.circle.fill", .hgRed,
                    String(localized: "퀴즈 \(QuizBank.shared.questions.count)문항과 실전 문제"),
                    String(localized: "모든 장, 모든 훈련 모드, 화면으로 판단하기"))
            Divider().overlay(Color.hgLine).padding(.leading, 56)
            benefit("sparkles", .hgAccent2,
                    String(localized: "앞으로 더해질 레슨까지"),
                    String(localized: "새로 나오는 편도 추가 결제 없이 엽니다"))
        }
        .background(Color.hgCard, in: .rect(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(Color.hgLine, lineWidth: 1))
    }

    private func benefit(_ symbol: String, _ tint: Color, _ title: String, _ detail: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: symbol)
                .font(.callout.weight(.semibold))
                .foregroundStyle(tint)
                .frame(width: 30, height: 30)
                .background(tint.opacity(0.12), in: .rect(cornerRadius: 8))
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(.hgText)
                Text(detail)
                    .font(.footnote)
                    .foregroundStyle(.hgMuted)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .accessibilityElement(children: .combine)
    }

    /// 무료로 남는 것도 분명히 적는다. 결제하지 않아도 잃는 것은 없다.
    private var promise: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("구독이 아닙니다. 한 번 결제하면 계속 씁니다.", systemImage: "infinity")
            Label("항목 68개와 예제, 원칙 7개, 노트는 결제 없이 그대로입니다.", systemImage: "book.closed")
            Label("계정이 없고, 쓴 글은 기기 안에만 남습니다.", systemImage: "lock.shield")
        }
        .font(.footnote)
        .foregroundStyle(.hgMuted)
        .labelStyle(PromiseLabelStyle())
    }

    // MARK: 아래: 결제

    private var purchaseBar: some View {
        VStack(spacing: 10) {
            if pro.hasPro {
                Label("Pro가 열렸습니다", systemImage: "checkmark.seal.fill")
                    .font(.headline)
                    .foregroundStyle(.hgGreen)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
            } else if let product = store.products.first {
                buyButton(price: product.displayPrice) {
                    await store.purchase(product) { try await purchaseAction($0) }
                }
            } else if let price = DebugLaunch.previewPrice {
                // 촬영 전용: UI 시험이 띄운 앱에는 스킴의 StoreKit 설정이 닿지 않는다. 출시 빌드에는 없다.
                buyButton(price: price) {}
            } else if store.isLoadingProducts {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
            } else {
                Button {
                    Task { await store.loadProducts() }
                } label: {
                    Text("가격을 불러오지 못했습니다. 다시 시도")
                        .font(.callout.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                }
                .buttonStyle(.bordered)
                .tint(.hgAccent)
            }

            if let error = store.lastError, DebugLaunch.previewPrice == nil {
                Text(error)
                    .font(.footnote)
                    .foregroundStyle(.hgRed)
                    .multilineTextAlignment(.center)
            }

            HStack(spacing: 18) {
                Button {
                    Task { await store.restore() }
                } label: {
                    if store.isRestoring {
                        ProgressView().controlSize(.small)
                    } else {
                        Text("구매 복원")
                    }
                }
                .disabled(store.isRestoring)

                Button("개인정보처리방침") { openURL(HigGymSpec.legal.privacyURL) }
            }
            .font(.footnote)
            .tint(.hgMuted)
        }
        .padding(.horizontal, 22)
        .padding(.top, 14)
        .padding(.bottom, 12)
        .background(Color.hgBackground)
        .overlay(alignment: .top) { Divider().overlay(Color.hgLine) }
    }

    private func buyButton(price: String, purchase: @escaping () async -> Void) -> some View {
        Button {
            Task { await purchase() }
        } label: {
            VStack(spacing: 2) {
                if store.purchasingProductID != nil {
                    ProgressView().tint(.white)
                        .padding(.vertical, 9)
                } else {
                    Text("평생 이용권 \(price)")
                        .font(.headline)
                    Text("한 번 결제로 모두 열기")
                        .font(.caption.weight(.semibold))
                        .opacity(0.85)
                }
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 11)
            .background(.hgBrand, in: .rect(cornerRadius: 14))
            .contentShape(.rect(cornerRadius: 14))
        }
        .buttonStyle(.plain)
        .disabled(store.purchasingProductID != nil)
        .accessibilityHint("App Store 계정으로 한 번 결제합니다")
    }

    private var closeButton: some View {
        Button {
            if let onClose { onClose() } else { dismiss() }
        } label: {
            Image(systemName: "xmark")
                .font(.callout.weight(.bold))
                .foregroundStyle(.hgMuted)
                .frame(width: 36, height: 36)
                .background(Color.hgCard, in: .circle)
                .overlay(Circle().strokeBorder(Color.hgLine, lineWidth: 1))
        }
        .buttonStyle(.plain)
        .padding(.top, 12)
        .padding(.trailing, 16)
        .accessibilityLabel("닫기")
    }
}

private struct PromiseLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            configuration.icon
                .foregroundStyle(.hgAccent)
                .frame(width: 18)
            configuration.title
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

// MARK: - 잠금 래퍼

/// 열 수 있으면 내용을, 아니면 그 자리에 결제 화면을 띄운다.
/// 결제가 끝나면 같은 자리에서 바로 내용으로 바뀐다 (다시 찾아 들어올 필요가 없다).
///
/// 레슨 · 실습실 · 실수 상세처럼 **여러 곳에서 열리는 화면**을 그 화면 쪽에서 한 번만 막는다.
/// 여는 쪽마다 막으면 새 진입로(단축어, 해설의 실습 링크, 항목의 실수 링크)가 생길 때마다 샌다.
struct ProGate<Content: View>: View {
    let feature: HigGymPro.Feature
    var onClose: (() -> Void)?
    @ViewBuilder var content: () -> Content

    @ObservedObject private var pro = HigGymPro.shared

    var body: some View {
        if pro.allows(feature) {
            content()
        } else {
            HigGymPaywallView(feature: feature, onClose: onClose)
                .toolbar(.hidden, for: .navigationBar)
        }
    }
}

/// 목록에서 잠긴 행 끝에 붙는 작은 표식. 색만이 아니라 자물쇠 모양과 글자로 알린다.
struct ProBadge: View {
    var body: some View {
        Label("Pro", systemImage: "lock.fill")
            .font(.caption2.weight(.bold))
            .foregroundStyle(.hgAccent2)
            .padding(.horizontal, 7)
            .padding(.vertical, 3)
            .background(Color.hgAccent2.opacity(0.12), in: .capsule)
            .labelStyle(.titleAndIcon)
            .accessibilityLabel("Pro에서 열림")
    }
}

extension View {
    /// 잠긴 기능을 눌렀을 때 결제 화면을 시트로 띄운다.
    func proPaywallSheet(_ feature: Binding<HigGymPro.Feature?>) -> some View {
        sheet(item: feature) { feature in
            HigGymPaywallView(feature: feature)
        }
    }
}
