import SwiftUI
import LeeoKit

/// 설정 - 학습 화면 오른쪽 위 톱니바퀴에서 연다.
///
/// 이 앱은 바꿀 설정이 거의 없다. 그래서 여기는 **말을 거는 곳**이다:
/// 앱 안에서 의견 보내기 · 리뷰 남기기 · 메일과 인스타그램 문의 · 사용법 다시 보기.
struct SettingsView: View {
    @State private var showsOnboarding = false
    @State private var showsWhatsNew = false

    var body: some View {
        List {
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
    }

    /// 개발자 메일 - 받는 사람과 제목을 채워 메일 앱을 연다.
    private static var mailURL: URL? {
        let subject = "[\(HigGymSpec.appName)] 문의"
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        return URL(string: "mailto:\(HigGymSpec.developerEmail)?subject=\(subject)")
    }
}
