import SwiftUI

/// 실습을 "실제 크기 화면"으로 띄울 때 붙이는 조작 장치.
///
/// 시스템 크롬(상단 툴바·하단 바)을 가리면 안 되므로 화면 왼쪽 가장자리 중앙에
/// 세로 캡슐로 띄운다 — 5.2.2 가 말하는 "세로 바는 엄지의 호" 자리이기도 하다.
struct StageChrome<Controls: View>: ViewModifier {
    let onClose: () -> Void
    let controls: Controls

    @State private var showControls = false

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .leading) {
                VStack(spacing: 6) {
                    button("xmark", action: onClose)
                    Divider().frame(width: 22)
                    button("slider.horizontal.3") { showControls = true }
                }
                .padding(.vertical, 8)
                .background(.ultraThinMaterial, in: .capsule)
                .overlay(Capsule().strokeBorder(Color.hgHairline, lineWidth: 1))
                .padding(.leading, 10)
                .shadow(color: .black.opacity(0.4), radius: 10, y: 4)
            }
            .sheet(isPresented: $showControls) {
                NavigationStack {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) { controls }
                            .padding(18)
                    }
                    .background(Color.hgBackground)
                    .navigationTitle("설정")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("닫기") { showControls = false }
                        }
                    }
                }
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
                // 시트를 연 채로 뒤 화면을 만지며 비교할 수 있게 — 4.1.5 비모달.
                .presentationBackgroundInteraction(.enabled(upThrough: .medium))
            }
    }

    private func button(_ symbol: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(.white)
                .frame(width: 34, height: 30)
        }
        .buttonStyle(.plain)
    }
}

extension View {
    /// 실제 크기 실습 화면에 닫기·설정 조작을 붙인다.
    func stageChrome<Controls: View>(
        onClose: @escaping () -> Void,
        @ViewBuilder controls: () -> Controls
    ) -> some View {
        modifier(StageChrome(onClose: onClose, controls: controls()))
    }
}

/// 실습 페이지에서 실제 크기 화면을 여는 안내 카드.
struct RunStageCard: View {
    let title: String
    let body_: String
    let action: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.callout.weight(.semibold))
                .foregroundStyle(.hgText)
            Text(body_)
                .font(.subheadline)
                .foregroundStyle(.hgMuted)

            Button(action: action) {
                Label("전체 화면으로 실행", systemImage: "play.fill")
                    .font(.callout.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(.hgBrand, in: .rect(cornerRadius: 12))
                    .foregroundStyle(.white)
            }
            .buttonStyle(.plain)
        }
        .hgCard()
    }
}
