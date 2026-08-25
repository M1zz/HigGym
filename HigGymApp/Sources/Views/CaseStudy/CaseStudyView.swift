import SwiftUI

/// 표본 앱의 결정 하나. 뜯어보기 목록의 한 줄이자, 화면 고르기 퀴즈의 한 문항이 된다.
struct NoteAppDecision: Identifiable, Hashable {
    var id: String { knob.rawValue }
    let knob: NoteAppConfig.Knob
    /// 어디를 보라는 안내.
    let place: String
    /// 무엇을 했는가.
    let decision: String
    /// 왜 그렇게 했는가 — 뜯어보기의 핵심.
    let why: String
    /// 이 결정을 뒤집으면 어떤 실수가 되는가.
    let ifFlipped: String
    /// 근거가 되는 본문 항목 번호.
    let sources: [String]

    static let all: [NoteAppDecision] = [
        .init(
            knob: .compose, place: "화면 아래 오른쪽 · 새 노트",
            decision: "이 화면에서 가장 자주 하는 일을 하단 오른쪽 끝에 뒀다.",
            why: "빈도가 높을수록 엄지에 가깝게. 목록 화면에서 반복되는 액션은 새 노트 하나뿐이라 그 자리를 그것에 줬다.",
            ifFlipped: "상단으로 올리면 누를 때마다 기기를 고쳐 쥐게 되고, 그만큼 덜 쓰인다.",
            sources: ["1.1.4", "8.1.2"]
        ),
        .init(
            knob: .deletion, place: "목록의 행 · 왼쪽으로 밀기",
            decision: "삭제를 툴바가 아니라 행 위에 뒀다.",
            why: "액션은 대상 위에 있어야 무엇을 지우는지가 분명하다. 미는 동작이 한 단계 역할을 해서 오탭도 막는다.",
            ifFlipped: "하단 바에 삭제를 단독으로 두면 엄지가 지나가다 눌러 되돌릴 수 없는 일이 벌어진다.",
            sources: ["8.1.7", "1.1.4"]
        ),
        .init(
            knob: .grouping, place: "오른쪽 위 · 편집",
            decision: "상단에는 확정 액션 하나만 남기고 도구는 넣지 않았다.",
            why: "한 캡슐에 든 것들은 한 세트로 읽힌다. 성격이 다른 것을 섞지 않으려면 애초에 자리를 나눈다.",
            ifFlipped: "삭제·정렬·편집을 한 캡슐에 묶으면 삭제가 도구처럼 보여 잘못 눌린다.",
            sources: ["1.1.2", "8.1.3"]
        ),
        .init(
            knob: .title, place: "제목 · 노트 ⌄",
            decision: "폴더 전환을 제목 자체에 붙였다.",
            why: "제목이 곧 \"지금 무엇을 보고 있는가\"이므로, 그것을 바꾸는 액션은 제목 위에 있는 게 맞다.",
            ifFlipped: "별도 폴더 버튼을 만들면 대상과 액션이 떨어져 사용자가 둘을 머릿속에서 이어야 한다.",
            sources: ["1.2.5", "8.1.7"]
        ),
        .init(
            knob: .search, place: "화면 아래 · 검색 캡슐",
            decision: "검색을 상단 서랍이 아니라 하단 툴바에 뒀다.",
            why: "검색은 한 손으로 자주 여는 입구다. iOS 26이 검색을 아래로 내린 것과 같은 이유 — 엄지 도달성.",
            ifFlipped: "항상 보이는 상단 서랍에 두면 세로 한 줄을 상시로 먹고, 손은 화면 위까지 올라가야 한다.",
            sources: ["1.4.1", "1.4.4"]
        ),
        .init(
            knob: .date, place: "행 오른쪽 · 수정 시각",
            decision: "날짜를 문자열로 조립하지 않고 값으로 들고 있다.",
            why: "표기 규칙은 문화권의 것이다. 값만 들고 있으면 로케일이 바뀌어도 앱 코드는 그대로다.",
            ifFlipped: "\"8월 21일\"처럼 굳혀 두면 다른 언어 사용자에게도 그 표기가 그대로 나간다.",
            sources: ["2.2.1", "8.1.6"]
        ),
        .init(
            knob: .selection, place: "노트 상세 · 본문",
            decision: "본문을 길게 눌러 선택·복사할 수 있게 열어 뒀다.",
            why: "운송장 번호처럼 다른 앱으로 옮겨질 값이 본문에 있다. 옮길 방법이 없으면 사용자가 눈으로 받아 적는다.",
            ifFlipped: "막아 두면 사용자가 화면을 보며 손으로 옮겨 적고, 그 과정에서 오타가 난다.",
            sources: ["2.1.5"]
        ),
        .init(
            knob: .editorExit, place: "새 노트 · 취소 / 완료",
            decision: "전체 화면 편집기에 출구를 직접 만들었다.",
            why: "전체 화면 커버는 일부러 쓸어내려 닫히지 않는다. 작성 중인 글을 지키는 대신 출구를 만들 의무가 따라온다.",
            ifFlipped: "닫기 버튼이 없으면 사용자는 앱이 멈춘 줄 알고 강제 종료한다.",
            sources: ["4.2.1"]
        ),
    ]

    static func of(_ knob: NoteAppConfig.Knob) -> NoteAppDecision {
        all.first { $0.knob == knob }!
    }
}

/// 샘플 앱 체험 — 먼저 **그냥 써보고**, 그다음 결정을 하나씩 짚어본다.
///
/// 안내는 비모달 시트라 읽으면서 앱을 그대로 만질 수 있다. 결정을 고르면
/// 그 자리에 테두리가 켜지므로 "어디를 말하는 건지"를 찾을 필요가 없다.
struct CaseStudyView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var showNotes = true
    @State private var spotlight: NoteAppConfig.Knob?

    var body: some View {
        SampleNoteApp(config: .recommended, spotlight: spotlight)
            .overlay(alignment: .bottom) { chrome }
            .sheet(isPresented: $showNotes) {
                DecisionSheet(spotlight: $spotlight)
            }
    }

    private var chrome: some View {
        HStack(spacing: 4) {
            button("xmark") { dismiss() }
            Divider().frame(height: 18)
            button("list.bullet.rectangle") { showNotes = true }
        }
        .padding(.horizontal, 7)
        .background(.ultraThinMaterial, in: .capsule)
        .overlay(Capsule().strokeBorder(Color.hgHairline, lineWidth: 1))
        .shadow(color: .black.opacity(0.35), radius: 10, y: 4)
        .padding(.bottom, 10)
    }

    private func button(_ symbol: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(.primary)
                .frame(width: 32, height: 28)
                .contentShape(.rect)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 결정 목록

private struct DecisionSheet: View {
    @Binding var spotlight: NoteAppConfig.Knob?
    @Environment(\.dismiss) private var dismiss

    @State private var expanded: NoteAppConfig.Knob?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    intro

                    ForEach(NoteAppDecision.all) { decision in
                        DecisionCard(
                            decision: decision,
                            expanded: expanded == decision.knob
                        ) {
                            withAnimation(.snappy(duration: 0.22)) {
                                if expanded == decision.knob {
                                    expanded = nil
                                    spotlight = nil
                                } else {
                                    expanded = decision.knob
                                    spotlight = decision.knob
                                }
                            }
                        }
                    }
                }
                .padding(18)
            }
            .background(Color.hgBackground)
            .navigationTitle("이 앱은 왜 이렇게 생겼나")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("닫기") { spotlight = nil; dismiss() }
                }
            }
        }
        .presentationDetents([.height(220), .medium, .large])
        .presentationDragIndicator(.visible)
        // 읽으면서 뒤의 앱을 그대로 쓸 수 있게 — 이 앱이 4.1.5에서 가르치는 그 동작.
        .presentationBackgroundInteraction(.enabled(upThrough: .medium))
    }

    private var intro: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("먼저 그냥 써보세요")
                .font(.headline.weight(.bold))
                .foregroundStyle(.hgText)
            Text("노트를 열고, 쓰고, 밀어서 지우고, 검색해 보세요. 이 시트를 내려도 앱은 그대로 동작합니다. 그다음 아래 결정을 하나씩 눌러 **왜 그 자리인지** 확인하세요 — 누르면 그 자리에 테두리가 켜집니다.")
                .font(.subheadline)
                .foregroundStyle(.hgMuted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct DecisionCard: View {
    let decision: NoteAppDecision
    let expanded: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 9) {
                HStack(spacing: 8) {
                    Image(systemName: expanded ? "smallcircle.filled.circle" : "circle")
                        .font(.subheadline)
                        .foregroundStyle(expanded ? .hgAmber : .hgDim)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(decision.place)
                            .font(.caption.weight(.bold))
                            .foregroundStyle(expanded ? .hgAmber : .hgDim)
                        Text(decision.decision)
                            .font(.callout.weight(.semibold))
                            .foregroundStyle(.hgText)
                            .multilineTextAlignment(.leading)
                    }
                    Spacer(minLength: 0)
                }

                if expanded {
                    VStack(alignment: .leading, spacing: 9) {
                        labeled("왜", decision.why, .hgAccent2)
                        labeled("뒤집으면", decision.ifFlipped, .hgRed)
                        HStack(spacing: 5) {
                            ForEach(decision.sources, id: \.self) { Pill(text: $0) }
                        }
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(Color.hgCard, in: .rect(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(expanded ? Color.hgAmber.opacity(0.5) : Color.hgLine, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private func labeled(_ title: String, _ body: String, _ tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(.caption.weight(.bold))
                .foregroundStyle(tint)
            MarkdownText(raw: body, font: .subheadline, color: .hgMuted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
