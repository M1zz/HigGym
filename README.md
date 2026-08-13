# HigGym

Apple HIG · SwiftUI(iOS 26) 컴포넌트를 목차별로 뜯어보는 주석 노트.
각 항목마다 **WHEN**(언제·어떤 기준) · **WHY**(왜 이런 설계·기본값) · **TIP**(실무 참고)을 답니다.

## 📖 보기

**→ [Toolbar · Text 목차별 주석 (GitHub Pages)](https://m1zz.github.io/HigGym/toolbar-annotated.html)**

**→ [English version](https://m1zz.github.io/HigGym/toolbar-annotated.html?lang=en)**

## 🌐 언어 / Language

한국어와 영어를 모두 지원합니다. 오른쪽 위 **한국어 · EN** 토글로 전환하거나, URL에 `?lang=en`(영어) / `?lang=ko`(한국어)를 붙여 바로 열 수 있습니다. 선택한 언어는 브라우저에 저장되며, 기본값은 한국어입니다.

Available in Korean and English. Use the **한국어 · EN** toggle at the top right, or open a URL with `?lang=en` / `?lang=ko`. Your choice is remembered in the browser; the default is Korean. All English strings live in [`i18n-en.js`](./i18n-en.js) — the Korean text stays in the HTML and is swapped in place at runtime.

## 목차

### 1. Toolbar
- 1.1 Items — 배치 조합 9케이스
- 1.2 Title Display Modes — Large / Inline Large / Inline / Title Menu / Custom
- 1.3 Scroll Edge Effects — Soft / Hard / Thick Material / Hidden
- 1.4 Search — 배치 6케이스

### 2. Text
- 2.1 Text Behavior — Line Limit / Truncation / Scale to fit / Line Limit (Range) / Text Selection
- 2.2 Text Formatting — Format Styles (Units) / Name Formatting
