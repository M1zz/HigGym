import SwiftUI

/// 업데이트 뒤 처음 열 때 한 번 뜨는 "새로 생긴 것" 시트. 설정 ▸ 새로운 기능에서 다시 볼 수 있다.
///
/// ⚠️ **처음 받은 사람에게는 뜨지 않는다.** 그 사람은 첫 실행 안내가 맞이한다(→ RootView).
///    새로 온 사람에게 "새로워졌어요"는 무슨 말인지 알 수 없는 말이다.
enum WhatsNewContent {
    /// 이 안내가 소개하는 버전. ⚠️ 내용을 바꿀 때 이 값도 같이 올린다.
    /// 안 올리면 업데이트한 사람은 이미 본 것으로 기록돼 있어 새 안내를 한 번도 못 본다.
    static let version = "1.0.3"

    /// 마지막으로 본 안내의 버전을 담는 UserDefaults 키.
    static let seenVersionKey = "higgym.whatsNewSeenVersion"

    /// 이번 실행에 안내를 띄울지. 처음 온 사람이면 본 것으로만 표시하고 띄우지 않는다.
    static func shouldPresent(isNewcomer: Bool, defaults: UserDefaults = .standard) -> Bool {
        guard defaults.string(forKey: seenVersionKey) != version else { return false }
        if isNewcomer {
            markSeen(defaults: defaults)
            return false
        }
        return true
    }

    static func markSeen(defaults: UserDefaults = .standard) {
        defaults.set(version, forKey: seenVersionKey)
    }
}

struct WhatsNewView: View {
    let onClose: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 10) {
                        Image(systemName: "sparkles")
                            .font(.largeTitle.weight(.light))
                            .imageScale(.large)
                            .foregroundStyle(.hgAccent)
                            .padding(.top, 28)
                            .accessibilityHidden(true)
                        Text("새로워진 앱 디자인 실습")
                            .font(.title2.bold())
                            .foregroundStyle(.hgText)
                            .multilineTextAlignment(.center)
                            .accessibilityAddTraits(.isHeader)
                        Text("버전 \(WhatsNewContent.version)")
                            .font(.subheadline)
                            .foregroundStyle(.hgMuted)
                    }

                    VStack(alignment: .leading, spacing: 18) {
                        // 이 안내는 이미 쓰던 사람에게만 뜬다(→ shouldPresent). 그 사람들은 모두
                        // 무료판으로 받은 사람이라 평생 Pro 다(→ HigGymPro.lastFreeBuild).
                        row("gift",
                            "쓰던 기능은 평생 그대로입니다",
                            "이번 버전부터 새로 받는 분께는 일부가 유료로 바뀝니다. 그동안 함께해 주신 분은 결제 없이 모든 레슨과 자료를 계속 씁니다.")
                        row("globe",
                            "영어와 일본어로도 배웁니다",
                            "레슨, 항목, 실수 100편, 퀴즈까지 앱 전체가 기기 언어를 따라갑니다.")
                        row("accessibility",
                            "손쉬운 사용 설정을 따릅니다",
                            "대비 증가, 투명도 줄이기, 동작 줄이기, 색상 없이 구별을 켜면 화면이 그에 맞게 바뀝니다.")
                        row("square.stack.3d.up",
                            "단축어로 이어서 학습",
                            "단축어와 Spotlight에서 멈춘 레슨을 바로 열거나 노트를 펼칠 수 있습니다.")
                        row("bubble.left.and.text.bubble.right",
                            "설정에서 의견과 계획을 나눕니다",
                            "앱 안에서 의견을 보내고 답장을 받고, 앞으로 만들 기능을 미리 볼 수 있습니다.")
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.bottom, 16)
            }

            Button {
                onClose()
            } label: {
                Text("계속")
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(.hgBrand, in: .rect(cornerRadius: 14))
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
        }
        .background(Color.hgBackground)
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }

    private func row(_ symbol: String, _ title: LocalizedStringKey, _ detail: LocalizedStringKey) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: symbol)
                .font(.title3)
                .foregroundStyle(.hgAccent)
                .frame(width: 32, height: 32)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.hgText)
                Text(detail)
                    .font(.subheadline)
                    .foregroundStyle(.hgMuted)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .accessibilityElement(children: .combine)
    }
}
