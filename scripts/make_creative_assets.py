#!/usr/bin/env python3
"""App Store 크리에이티브 자산(제품 페이지 헤더 · 검색 결과) 생성: HTML → 헤드리스 Chrome.

사용법: python3 scripts/make_creative_assets.py [언어 ...]     (없으면 전부)

자리
  docs/screenshots/creative/<스토어 로케일>/header.png   3840x1646  제품 페이지 맨 위
  docs/screenshots/creative/<스토어 로케일>/search.png   3840x2560  검색 결과 (없으면 스크린샷이 대신 보인다)

⚠️ 안전 영역 밖은 기기에 따라 잘린다. 글은 **반드시** 안전 영역 안에 둔다(배경 · 기기 그림은 넘쳐도 된다).
   수치는 Apple 공식 PSD 템플릿에서 잰 값이다(https://developer.apple.com/app-store/asset-best-practices/).
   아이폰에서 헤더는 가운데만 남고, 검색 결과는 약 385pt 폭으로 줄어 보인다. 그래서 글이 크다.

⚠️ 가격 · 할인 · 주소(URL) · 수상 · 다른 플랫폼 이름은 넣지 않는다(Apple 가이드).
"""
import subprocess, sys, pathlib, tempfile

ROOT = pathlib.Path(__file__).resolve().parent.parent
RAW = ROOT / "docs" / "screenshots" / "raw" / "creative"
OUT = ROOT / "docs" / "screenshots" / "creative"
CHROME = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"


def profile():
    """켜 둔 Chrome 의 프로필, 또는 막 끝난 앞 호출의 프로필과 부딪히면 아무것도 안 그리고 끝난다.
    부를 때마다 새 빈 프로필로 띄운다."""
    return f"--user-data-dir={tempfile.mkdtemp(prefix='higgym-chrome-')}"

# 스토어 언어 = deploy.env LOCALES (ko · en · ja). 폴더 이름이 로케일 그대로라 바꿀 것이 없다.
STORE = {}

# (가로, 세로, 안전 영역 left, top, right, bottom)
SPEC = {
    "header": (3840, 1646, (1097, 493, 2743, 1154)),
    "search": (3840, 2560, (836, 765, 3004, 1795)),
}

# 검색 결과: 눈썹글은 검색창에 칠 말, 헤드라인과 보조 문장은 앱이 하는 일 그대로.
# 앱의 약속: 규칙을 외우는 게 아니라 어긴 화면을 직접 만져 보고 왜 그런지 확인한다.
SEARCH = {
    "ko": ("UI/UX 공부", "직접 만져 보며<br>배우는 UI/UX", "어색한 화면을 써 보고<br>이유를 확인해요"),
    "en": ("UI/UX practice", "Learn UI/UX<br>by touching it", "Use awkward screens,<br>then see why"),
    "en-GB": ("UI/UX practice", "Learn UI/UX<br>by touching it", "Use awkward screens,<br>then see why"),
    "ja": ("UI/UXの勉強", "触って学ぶ<br>UI/UX", "違和感のある画面を使って<br>理由を確かめる"),
}

# 헤더: 처음 온 사람에게 한 가지 약속.
HEADER = {
    "ko": ("앱 디자인 실습", "써 보면 알게 되는<br>좋은 화면의 이유"),
    "en": ("App Design Lab", "Use it, and see why<br>good screens work"),
    "en-GB": ("App Design Lab", "Use it, and see why<br>good screens work"),
    "ja": ("アプリデザイン実習", "使ってわかる<br>良い画面の理由"),
}

# ⚠️ 바탕 · 글자색은 기존 스크린샷(make_marketing_screenshots.py)과 같다. 다르면 페이지에서
#    헤더만 남의 앱처럼 보인다.
BASE_CSS = """
* { margin:0; padding:0; box-sizing:border-box; }
html,body { width:%(W)dpx; height:%(H)dpx; overflow:hidden; }
body { background:#0B0C10; position:relative;
  font-family:-apple-system, "SF Pro Display", "Apple SD Gothic Neo", "Hiragino Sans", "PingFang SC", "Thonburi", sans-serif; }
.glow { position:absolute; border-radius:50%%; filter:blur(160px); pointer-events:none; }
.text { position:absolute; display:flex; flex-direction:column; justify-content:center; }
.eyebrow { font-weight:700; color:#5AA8FF; letter-spacing:-0.01em; line-height:1.15; }
.headline { font-weight:800; color:#E9EDF4; letter-spacing:-0.03em; line-height:1.12; text-wrap:balance; }
.sub { font-weight:500; color:#9AA4B2; letter-spacing:-0.01em; line-height:1.35; text-wrap:balance; }
:lang(th) .headline, :lang(th) .eyebrow, :lang(th) .sub,
:lang(ja) .headline, :lang(zh) .headline { letter-spacing:0; }
:lang(th) .headline { line-height:1.3; }
/* 한국어는 낱말 중간에서 끊지 않는다("키 / 보드"). */
:lang(ko) .headline, :lang(ko) .sub, :lang(ko) .eyebrow { word-break:keep-all; }
.phone { position:absolute; background:#181B22; border:6px solid #2A2F3A; padding:40px; border-radius:190px;
  box-shadow: 0 60px 160px rgba(0,0,0,.6), 0 0 0 2px #1E222B inset; }
.phone img { width:100%%; display:block; border-radius:152px; }
/* 앱 아이콘처럼 생긴 화면 윤곽선(목업)을 장식으로 흩는다. */\n.wire { position:absolute; border:5px solid rgba(90,168,255,.22); border-radius:56px; }\n.wire::before { content:""; position:absolute; left:14%%; right:14%%; top:12%%; height:12%%; border-radius:40px; background:rgba(90,168,255,.18); }\n.wire::after { content:""; position:absolute; left:14%%; right:14%%; top:32%%; height:34%%; border-radius:28px; background:rgba(123,108,255,.12); }
"""

# 글이 상자를 넘지 않을 때까지 줄인다. 잘리는 글은 없다 - 끝까지 안 맞으면 표시하고 멈춘다.
FIT_JS = """
<script>
// 문구에 적은 줄(<br>)보다 더 쪼개지면 "Rispondi / con un / tocco" 처럼 읽기가 끊긴다.
// 적은 줄 수를 지킬 때까지 줄인다.
function lines(el) {
  return Math.round(el.getBoundingClientRect().height / parseFloat(getComputedStyle(el).lineHeight));
}
function fit(box, el, max, min) {
  const want = el.querySelectorAll('br').length + 1;
  let size = max;
  el.style.fontSize = size + 'px';
  while (size > min && (box.scrollHeight > box.clientHeight + 1 || box.scrollWidth > box.clientWidth + 1 ||
         lines(el) > want)) {
    size -= 4; el.style.fontSize = size + 'px';
  }
  if (box.scrollHeight > box.clientHeight + 1 || box.scrollWidth > box.clientWidth + 1 || lines(el) > want)
    document.body.dataset.overflow = '1';
}
document.fonts.ready.then(() => {
  const box = document.querySelector('.text');
  const h = document.querySelector('.headline');
  fit(box, h, +h.dataset.max, +h.dataset.min);
  document.body.dataset.done = '1';
});
</script>
"""


def phone(img, left, top, width, rotate=0):
    return (f'<div class="phone" style="left:{left}px;top:{top}px;width:{width}px;'
            f'transform:rotate({rotate}deg)"><img src="{img}"></div>')


def search_html(lang):
    W, H, (l, t, r, b) = SPEC["search"]
    eyebrow, headline, sub = SEARCH[lang]
    sw, sh = r - l, b - t
    col = int(sw * 0.56)
    # 기기는 안전 영역 오른쪽 몫에 서서, 위아래로 넘쳐 화면 밖까지 이어진다(기기 그림은 잘려도 된다).
    ph_w = 1040
    ph_left = l + col + int(sw * 0.04)
    # 레슨의 '이유 확인' 단계: 방금 만진 화면이 왜 어색했는지 기준과 나란히 보여 준다.
    img = (RAW / lang / "02-reason.png").as_uri()
    return f"""
<div class="glow" style="left:{ph_left - 300}px;top:500px;width:1700px;height:1700px;background:rgba(90,168,255,.18)"></div>
<div class="glow" style="left:{ph_left + 300}px;top:1300px;width:1200px;height:1200px;background:rgba(123,108,255,.14)"></div>
<div class="glow" style="left:{l - 700}px;top:{t - 500}px;width:1400px;height:1000px;background:rgba(90,168,255,.07)"></div>
{phone(img, ph_left, t - 360, ph_w, 0)}
<div class="text" style="left:{l}px;top:{t}px;width:{col}px;height:{sh}px">
  <div class="eyebrow" style="font-size:96px">{eyebrow}</div>
  <div class="headline" data-max="250" data-min="140" style="margin-top:36px">{headline}</div>
  <div class="sub" style="font-size:84px;margin-top:52px">{sub}</div>
</div>"""


def header_html(lang):
    W, H, (l, t, r, b) = SPEC["header"]
    eyebrow, headline = HEADER[lang]
    sw, sh = r - l, b - t
    # 왼쪽은 스물세 편의 코스, 오른쪽은 써 보고 배운 것을 적은 노트.
    left_img = (RAW / lang / "01-course.png").as_uri()
    right_img = (RAW / lang / "03-notebook.png").as_uri()
    # 앱 아이콘처럼 생긴 화면 윤곽선을 안전 영역 바깥에 흩는다. 아이폰에서는 잘려도 되는 장식이다.
    wires = [(-30, 70, 240, -14), (1000, 1250, 200, 10), (3380, 110, 230, 14), (3620, 1100, 250, -10),
             (2700, 1280, 180, -6), (760, 60, 170, 8)]
    keys_html = "".join(f'<div class="wire" style="left:{x}px;top:{y}px;width:{w}px;height:{int(w * 1.3)}px;'
                        f'transform:rotate({rot}deg)"></div>' for x, y, w, rot in wires)
    return f"""
<div class="glow" style="left:{l - 200}px;top:{t - 400}px;width:{sw + 400}px;height:{sh + 800}px;background:rgba(90,168,255,.15)"></div>
<div class="glow" style="left:{l + 300}px;top:{t}px;width:{sw - 600}px;height:{sh + 400}px;background:rgba(123,108,255,.10)"></div>
{keys_html}
{phone(left_img, 300, 360, 640, -9)}
{phone(right_img, 2900, 360, 640, 9)}
<div class="text" style="left:{l}px;top:{t}px;width:{sw}px;height:{sh}px;align-items:center;text-align:center">
  <div class="eyebrow" style="font-size:76px">{eyebrow}</div>
  <div class="headline" data-max="210" data-min="110" style="margin-top:22px">{headline}</div>
</div>"""


def html_lang(lang):
    return {"zh-Hans": "zh-Hans", "zh-Hant": "zh-Hant"}.get(lang, lang)


def render(lang, kind):
    W, H, _ = SPEC[kind]
    body = search_html(lang) if kind == "search" else header_html(lang)
    page = (f'<!doctype html><html lang="{html_lang(lang)}"><head><meta charset="utf-8"><style>'
            f'{BASE_CSS % {"W": W, "H": H}}</style></head><body>{body}{FIT_JS}</body></html>')
    html_path = pathlib.Path(tempfile.gettempdir()) / f"higgym-creative-{lang}-{kind}.html"
    html_path.write_text(page, encoding="utf-8")
    # 글이 끝까지 안 맞으면 그림을 만들지 않는다(잘린 글이 스토어에 올라가는 것보다 낫다).
    dom = subprocess.run([CHROME, "--headless=new", profile(), "--dump-dom", f"--window-size={W},{H}",
                          "--force-device-scale-factor=1", "--disable-gpu", "--virtual-time-budget=3000",
                          html_path.as_uri()], capture_output=True, text=True, timeout=90).stdout
    if 'data-done="1"' not in dom:
        raise SystemExit(f"글 맞추기가 끝나지 않았다: {lang} {kind}")
    if 'data-overflow="1"' in dom:
        raise SystemExit(f"글이 안전 영역을 넘는다: {lang} {kind} - 문구를 줄일 것")
    out_dir = OUT / STORE.get(lang, lang)
    out_dir.mkdir(parents=True, exist_ok=True)
    out_png = out_dir / f"{kind}.png"
    # ⚠️ Chrome 은 가끔 아무것도 안 그리고 끝나거나 멈춘다. 세 번까지 한다.
    for _ in range(3):
        try:
            r = subprocess.run([CHROME, "--headless=new", profile(), f"--screenshot={out_png}",
                                f"--window-size={W},{H}", "--force-device-scale-factor=1",
                                "--hide-scrollbars", "--disable-gpu", "--virtual-time-budget=3000",
                                "--allow-file-access-from-files", html_path.as_uri()],
                               capture_output=True, timeout=90)
        except subprocess.TimeoutExpired:
            continue
        if r.returncode == 0:
            break
    else:
        raise SystemExit(f"Chrome 이 그리지 못했다: {out_png}")
    print(f"rendered {out_png}")


if __name__ == "__main__":
    langs = sys.argv[1:] or list(SEARCH)
    for lang in langs:
        if lang not in SEARCH:
            raise SystemExit(f"모르는 언어: {lang} (아는 것: {', '.join(SEARCH)})")
        for kind in ("header", "search"):
            render(lang, kind)
