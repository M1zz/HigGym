#!/usr/bin/env python3
"""App Store 마케팅 스크린샷: 원본 캡처 + 헤드라인 → 헤드리스 Chrome (appstore-assets 스킬 방식).

사용법: python3 scripts/make_marketing_screenshots.py [ko en ...]   (없으면 전부)

원본    docs/screenshots/raw/<언어>/0N-….png         아이폰 6.9" 캡처(1320×2868)
제출본  docs/screenshots/marketing/<스토어 로케일>/0N-….png        1242×2688

바탕·글자색은 제품 페이지 헤더(make_creative_assets.py)와 같다: 먹색 바탕 + 파랑.
"""
import subprocess, sys, pathlib

ROOT = pathlib.Path(__file__).resolve().parent.parent
RAW = ROOT / "docs" / "screenshots" / "raw"
OUT = ROOT / "docs" / "screenshots" / "marketing"
WORK = pathlib.Path("/tmp") / "higgym-marketing"
CHROME = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
STORE = {"ko": "ko", "en": "en", "en-GB": "en-GB", "ja": "ja"}

# (원본 파일, 헤드라인, 서브카피), 언어마다 따로 쓴다.
SHOTS = {
    "ko": [
        ("01-course.png",  "읽지 말고<br>만져 보세요", "결정 하나씩, 스물세 편의 UI/UX 워크북"),
        ("02-try.png",     "먼저 써 보고", "어긴 화면을 실제 크기로 직접 눌러 봐요"),
        ("03-write.png",   "느낀 걸<br>먼저 적고", "답을 보기 전에 내 손이 겪은 것을 남겨요"),
        ("04-reason.png",  "왜 그랬는지<br>확인하고", "이 앱이 한 결정, 이유, 뒤집으면 생기는 일"),
        ("05-compare.png", "어긴 화면과<br>고친 화면을 비교", "같은 자리에서 바로 바꿔 보며 차이를 봐요"),
        ("06-items.png",   "UI/UX 68개 항목을<br>그림으로", "툴바 · 탭바 · 시트 · 텍스트를 목업으로 훑어요"),
    ],
    "en": [
        ("01-course.png",  "Don't just read it.<br>Touch it.", "One decision per lesson, 23 UI/UX lessons"),
        ("02-try.png",     "Try it first", "Use the rule-breaking screen at full size"),
        ("03-write.png",   "Write down<br>what you felt", "Before the answer, note what your hands noticed"),
        ("04-reason.png",  "Then see why", "The decision, the reason, and what breaks if you flip it"),
        ("05-compare.png", "Broken vs. fixed,<br>side by side", "Swap them in place and spot the difference"),
        ("06-items.png",   "68 UI/UX topics,<br>drawn out", "Toolbars, tab bars, sheets and text as mockups"),
    ],
    "en-GB": [
        ("01-course.png",  "Don't just read it.<br>Touch it.", "One decision per lesson, 23 UI/UX lessons"),
        ("02-try.png",     "Try it first", "Use the rule-breaking screen at full size"),
        ("03-write.png",   "Write down<br>what you felt", "Before the answer, note what your hands noticed"),
        ("04-reason.png",  "Then see why", "The decision, the reason, and what breaks if you flip it"),
        ("05-compare.png", "Broken vs. fixed,<br>side by side", "Swap them in place and spot the difference"),
        ("06-items.png",   "68 UI/UX topics,<br>drawn out", "Toolbars, tab bars, sheets and text as mockups"),
    ],
    "ja": [
        ("01-course.png",  "読むより、<br>触って学ぶ", "1本に1つの判断、23本のUI/UX実習"),
        ("02-try.png",     "まず触ってみる", "ルールを破った画面を実寸で操作します"),
        ("03-write.png",   "感じたことを<br>先に書く", "答えを見る前に、手が気づいたことを残す"),
        ("04-reason.png",  "理由を<br>確かめる", "アプリの判断、その理由、逆にしたら起きること"),
        ("05-compare.png", "破った画面と<br>直した画面を比べる", "同じ場所で切り替えて違いを見る"),
        ("06-items.png",   "UI/UXの68項目を<br>図で見渡す", "ツールバー、タブバー、シート、テキストを図で"),
    ],
}

DEVICES = {
    # 이름: (캔버스, 기기 폭, 기기 top, 모서리, 테두리, 파일 접두사, 원본 하위 폴더)
    "iphone": ((1242, 2688), 900, 820, 112, 24, "", ""),
}

CSS = """
* { margin:0; padding:0; box-sizing:border-box; }
html,body { width:%(W)dpx; height:%(H)dpx; overflow:hidden; }
body { background:#0B0C10; position:relative;
  font-family:-apple-system, "SF Pro Display", "Apple SD Gothic Neo", "Hiragino Sans", sans-serif; }
.glow { position:absolute; left:50%%; top:%(GT)dpx; width:%(GW)dpx; height:%(GW)dpx; margin-left:-%(GH)dpx;
  border-radius:50%%; filter:blur(200px); background:rgba(90,168,255,.22); }
.t { position:absolute; left:80px; right:80px; top:%(TT)dpx; text-align:center; }
.headline { font-size:%(HS)dpx; font-weight:800; color:#E9EDF4; letter-spacing:-0.03em; line-height:1.14; }
.sub { margin-top:40px; font-size:%(SS)dpx; font-weight:500; color:#9AA4B2; letter-spacing:-0.01em; line-height:1.3; }
:lang(ko) .headline, :lang(ko) .sub { word-break:keep-all; }
:lang(ja) .headline { letter-spacing:0; }
:lang(ja) .headline, :lang(ja) .sub { line-break:strict; word-break:keep-all; }
.dev { position:absolute; left:50%%; top:%(DT)dpx; width:%(DW)dpx; margin-left:-%(DH)dpx; background:#181B22;
  border:4px solid #2A2F3A; padding:%(PAD)dpx; border-radius:%(R)dpx; box-shadow:0 60px 160px rgba(0,0,0,.6); }
.dev img { width:100%%; display:block; border-radius:%(IR)dpx; }
"""

HTML = """<!doctype html><html lang="{lang}"><head><meta charset="utf-8"><style>{css}</style></head>
<body><div class="glow"></div><div class="t"><div class="headline">{h}</div><div class="sub">{s}</div></div>
<div class="dev"><img src="{img}"></div></body></html>"""


def render(lang, device):
    (W, H), dw, dt, r, pad, prefix, sub = DEVICES[device]
    src = RAW / sub / lang if sub else RAW / lang
    out = OUT / STORE[lang]
    out.mkdir(parents=True, exist_ok=True)
    WORK.mkdir(exist_ok=True)
    css = CSS % {"W": W, "H": H, "GT": dt + 200, "GW": 1400, "GH": 700, "TT": 230 if device == "iphone" else 210,
                 "HS": 104 if device == "iphone" else 120, "SS": 48 if device == "iphone" else 56,
                 "DT": dt, "DW": dw, "DH": dw // 2, "PAD": pad, "R": r, "IR": r - pad}
    for fname, h, s in SHOTS[lang]:
        img = src / fname
        html = WORK / f"{lang}-{device}-{fname}.html"
        html.write_text(HTML.format(lang=lang, css=css, h=h, s=s, img=img.as_uri()), encoding="utf-8")
        target = out / f"{prefix}{fname}"
        # 다른 세션의 Chrome 과 겹치면 가끔 실패하거나 끝나지 않는다, 새 프로필로 다시 시도한다.
        for attempt in range(4):
            target.unlink(missing_ok=True)
            try:
                subprocess.run([CHROME, "--headless=new", f"--screenshot={target}", f"--window-size={W},{H}",
                                "--force-device-scale-factor=1", "--hide-scrollbars", "--disable-gpu",
                                "--no-first-run", f"--user-data-dir={WORK / f'chrome-{attempt}'}", html.as_uri()],
                               capture_output=True, timeout=40)
            except subprocess.TimeoutExpired:
                pass
            if target.exists() and target.stat().st_size > 0:
                break
        else:
            sys.exit(f"렌더 실패: {target}")
        print("rendered", target.relative_to(ROOT))


if __name__ == "__main__":
    for lang in sys.argv[1:] or list(SHOTS):
        for device in DEVICES:
            render(lang, device)
