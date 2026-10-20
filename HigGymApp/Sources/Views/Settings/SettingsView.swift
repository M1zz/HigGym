import SwiftUI
import LeeoKit

/// 설정 - 학습 화면 오른쪽 위 톱니바퀴에서 연다.
///
/// 이 앱은 바꿀 설정이 거의 없다. 그래서 여기는 **말을 거는 곳**이다:
/// 앱 안에서 의견 보내기 · 리뷰 남기기 · 메일과 인스타그램 문의 · 사용법 다시 보기.
struct SettingsView: View {
    @State private var showsOnboarding = false
    @State private var showsWhatsNew = false
    @State private var showsPaywall = false
    @ObservedObject private var pro = HigGymPro.shared

    var body: some View {
        List {
            proSection

            Section {
                Button {
                    showsOnboarding = true
                } label: {
                    Label("사용법 다시 보기", systemImage: "questionmark.circle")
                }
                Button {
                    showsWhatsNew = true
                } label: {
                    Label("새로운 기능", systemImage: "sparkles")
                }
            } header: {
                Text("앱 사용")
            }

            Section {
                // 의견 보내기(앱 안 피드백) · 받은 답장 · 리뷰 남기기 · 개인정보처리방침 · 지원 페이지 · 버전
                LeeoSupportSection<HigGymSpec>()
                // 앞으로 만들 기능, 원본은 App/HigGymRoadmap.swift
                NavigationLink(LeeoRoadmapText.entry) { RoadmapScreen() }
            } header: {
                Text("지원")
            }

            Section {
                // 같은 개발자가 만든 다른 앱 - 이 앱 자신은 목록에서 빠진다(appStoreID 대조).
                LeeoFamilySettingsRow<HigGymSpec>()
            }

            Section {
                if let mail = Self.mailURL {
                    Link(destination: mail) {
                        Label("메일로 문의하기", systemImage: "envelope")
                    }
                }
                Link(destination: HigGymSpec.instagramURL) {
                    Label("인스타그램에서 소식 보기", systemImage: "camera")
                }
            } header: {
                Text("문의")
            } footer: {
                Text("내용 오류나 다뤄 줬으면 하는 화면이 있으면 알려 주세요. 메일에는 기기 모델과 iOS 버전을 함께 적어 주시면 빨리 확인할 수 있습니다.")
            }
        }
        .navigationTitle("설정")
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: $showsOnboarding) {
            HigGymOnboardingView { showsOnboarding = false }
        }
        .sheet(isPresented: $showsWhatsNew) {
            WhatsNewView { showsWhatsNew = false }
        }
        .sheet(isPresented: $showsPaywall) {
            HigGymPaywallView()
        }
    }

    /// Pro 상태 한 줄과 구매 복원. 복원은 결제 화면 밖에서도 찾을 수 있어야 한다 (심사 요건).
    private var proSection: some View {
        Section {
            if pro.hasPro {
                Label {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Pro 사용 중")
                            .foregroundStyle(.hgText)
                        Text(pro.isGrandfathered
                             ? "처음부터 함께해 주셔서 모든 기능을 평생 그대로 씁니다."
                             : "모든 레슨과 자료가 열려 있습니다.")
                            .font(.footnote)
                            .foregroundStyle(.hgMuted)
                    }
                } icon: {
                    Image(systemName: "checkmark.seal.fill").foregroundStyle(.hgGreen)
                }
            } else {
                Button {
                    showsPaywall = true
                } label: {
                    Label {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Pro로 모두 열기")
                                .foregroundStyle(.hgText)
                            Text("레슨 \(Lesson.all.count)편, 실수 \(MistakeStore.shared.mistakes.count)편, 실습실, 퀴즈 전부. 한 번 결제.")
                                .font(.footnote)
                                .foregroundStyle(.hgMuted)
                        }
                    } icon: {
                        Image(systemName: "lock.open.fill").foregroundStyle(.hgAccent2)
                    }
                }
                Button {
                    Task { await pro.store.restore() }
                } label: {
                    HStack {
                        Label("구매 복원", systemImage: "arrow.clockwise")
                        if pro.store.isRestoring {
                            Spacer()
                            ProgressView()
                        }
                    }
                }
                .disabled(pro.store.isRestoring)
            }
        } header: {
            Text("Pro")
        }
    }

    /// 개발자 메일 - 받는 사람과 제목을 채워 메일 앱을 연다.
    private static var mailURL: URL? {
        // appName 은 LeeoKit 이 쓰는 식별자라 한국어 그대로다. 제목에는 기기 언어의 표시 이름을 쓴다.
        let name = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ?? HigGymSpec.appName
        let subject = String(localized: "[\(name)] 문의")
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        return URL(string: "mailto:\(HigGymSpec.developerEmail)?subject=\(subject)")
    }
}
