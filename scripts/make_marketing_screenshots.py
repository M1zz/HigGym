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
STORE = {"ko": "ko", "en": "en", "en-GB": "en-GB", "ja": "ja", "zh-Hans": "zh-Hans", "zh-Hant": "zh-Hant", "ru": "ru", "es": "es", "de": "de", "fr": "fr", "it": "it", "pt-BR": "pt-BR", "th": "th", "vi": "vi", "cs": "cs"}

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
    "zh-Hans": [
        ("01-course.png",  "别只读，<br>动手试试", "每节一个决定，共 23 节 UI/UX 课程"),
        ("02-try.png",     "先用起来", "以实际大小使用违反规范的界面"),
        ("03-write.png",   "先写下<br>你的感受", "看答案之前，记下你的手感受到了什么"),
        ("04-reason.png",  "再看原因", "这个决定、理由，以及颠倒后会出的问题"),
        ("05-compare.png", "出问题的界面<br>和改好的并排对比", "在同一个位置切换，看出差别"),
        ("06-items.png",   "68 个 UI/UX 条目<br>用图呈现", "工具栏、标签栏、弹层、文字，用示意图浏览"),
    ],
    "zh-Hant": [
        ("01-course.png",  "別只讀，<br>動手試試", "每節一個決定，共 23 節 UI/UX 課程"),
        ("02-try.png",     "先用起來", "以實際大小使用違反規範的介面"),
        ("03-write.png",   "先寫下<br>你的感受", "看答案之前，記下你的手感受到了什麼"),
        ("04-reason.png",  "再看原因", "這個決定、理由，以及顛倒後會出的問題"),
        ("05-compare.png", "出問題的介面<br>和改好的並排對比", "在同一個位置切換，看出差別"),
        ("06-items.png",   "68 個 UI/UX 條目<br>用圖呈現", "工具列、標籤列、工作表、文字，用示意圖瀏覽"),
    ],
    "ru": [
        ("01-course.png",  "Не читайте,<br>пробуйте", "Одно решение на урок, 23 урока по UI/UX"),
        ("02-try.png",     "Сначала попробуйте", "Работайте с экраном-нарушителем в натуральную величину"),
        ("03-write.png",   "Сначала запишите,<br>что почувствовали", "Перед ответом отметьте, что заметили ваши руки"),
        ("04-reason.png",  "Затем узнайте почему", "Решение, причина и что сломается, если сделать наоборот"),
        ("05-compare.png", "Сломанный и исправленный<br>рядом", "Переключайтесь на месте и находите разницу"),
        ("06-items.png",   "68 тем UI/UX<br>в картинках", "Панели инструментов, вкладок, шторки и текст в макетах"),
    ],
    "es": [
        ("01-course.png",  "No lo leas,<br>tócalo",  "Una decisión por lección, 23 lecciones de UI/UX"),
        ("02-try.png",  "Pruébalo primero",  "Usa a tamaño real la pantalla que incumple la regla"),
        ("03-write.png",  "Anota<br>lo que sentiste",  "Antes de la respuesta, apunta lo que notaron tus manos"),
        ("04-reason.png",  "Luego entiende por qué",  "La decisión, la razón y lo que se rompe si la inviertes"),
        ("05-compare.png",  "Rota y corregida,<br>lado a lado",  "Alterna en el sitio y detecta la diferencia"),
        ("06-items.png",  "68 temas de UI/UX<br>dibujados",  "Barras de herramientas, pestañas, hojas y texto en maquetas"),
    ],
    "de": [
        ("01-course.png",  "Nicht lesen,<br>anfassen",  "Eine Entscheidung pro Lektion, 23 UI/UX-Lektionen"),
        ("02-try.png",  "Erst ausprobieren",  "Nutze den regelbrechenden Bildschirm in voller Größe"),
        ("03-write.png",  "Schreibe auf,<br>was du gespürt hast",  "Notiere vor der Antwort, was deinen Händen aufgefallen ist"),
        ("04-reason.png",  "Dann verstehe warum",  "Die Entscheidung, der Grund und was kaputtgeht, wenn man sie umdreht"),
        ("05-compare.png",  "Fehlerhaft und korrigiert,<br>nebeneinander",  "Wechsle an Ort und Stelle und erkenne den Unterschied"),
        ("06-items.png",  "68 UI/UX-Themen<br>gezeichnet",  "Symbolleisten, Tab-Leisten, Sheets und Text als Mockups"),
    ],
    "fr": [
        ("01-course.png",  "Ne lisez pas,<br>touchez",  "Une décision par leçon, 23 leçons d'UI/UX"),
        ("02-try.png",  "Essayez d'abord",  "Utilisez en taille réelle l'écran qui enfreint la règle"),
        ("03-write.png",  "Notez ce que<br>vous avez ressenti",  "Avant la réponse, notez ce que vos mains ont remarqué"),
        ("04-reason.png",  "Puis comprenez pourquoi",  "La décision, la raison et ce qui casse si on l'inverse"),
        ("05-compare.png",  "Fautif et corrigé,<br>côte à côte",  "Alternez sur place et repérez la différence"),
        ("06-items.png",  "68 sujets d'UI/UX<br>dessinés",  "Barres d'outils, d'onglets, feuilles et texte en maquettes"),
    ],
    "it": [
        ("01-course.png",  "Non leggere,<br>tocca",  "Una decisione per lezione, 23 lezioni di UI/UX"),
        ("02-try.png",  "Prova prima",  "Usa a dimensione reale la schermata che infrange la regola"),
        ("03-write.png",  "Annota cosa<br>hai sentito",  "Prima della risposta, scrivi cosa hanno notato le tue mani"),
        ("04-reason.png",  "Poi scopri perché",  "La decisione, il motivo e cosa si rompe se la ribalti"),
        ("05-compare.png",  "Sbagliata e corretta,<br>affiancate",  "Passa da una all'altra sul posto e individua la differenza"),
        ("06-items.png",  "68 argomenti di UI/UX<br>disegnati",  "Barre degli strumenti, schede, fogli e testo come mockup"),
    ],
    "pt-BR": [
        ("01-course.png",  "Não leia,<br>toque",  "Uma decisão por lição, 23 lições de UI/UX"),
        ("02-try.png",  "Experimente primeiro",  "Use em tamanho real a tela que infringe a regra"),
        ("03-write.png",  "Anote o que<br>você sentiu",  "Antes da resposta, escreva o que suas mãos notaram"),
        ("04-reason.png",  "Depois entenda o porquê",  "A decisão, o motivo e o que quebra se você a inverter"),
        ("05-compare.png",  "Com erro e corrigida,<br>lado a lado",  "Alterne no mesmo lugar e perceba a diferença"),
        ("06-items.png",  "68 tópicos de UI/UX<br>desenhados",  "Barras de ferramentas, abas, folhas e texto como mockups"),
    ],
    "th": [
        ("01-course.png",  "อย่าอ่าน<br>ให้แตะ",  "หนึ่งบทเรียนหนึ่งการตัดสินใจ 23 บทเรียน UI/UX"),
        ("02-try.png",  "ลองก่อน",  "ใช้หน้าจอที่ฝ่าฝืนกฎในขนาดจริง"),
        ("03-write.png",  "จดสิ่งที่<br>คุณรู้สึก",  "ก่อนเฉลย เขียนสิ่งที่มือของคุณสังเกต"),
        ("04-reason.png",  "แล้วค่อยดูเหตุผล",  "การตัดสินใจ เหตุผล และสิ่งที่พังถ้าพลิกมัน"),
        ("05-compare.png",  "ที่ผิดกับที่แก้แล้ว<br>เคียงกัน",  "สลับในที่เดียวกันแล้วสัมผัสความต่าง"),
        ("06-items.png",  "68 หัวข้อ UI/UX<br>วาดเป็นภาพ",  "แถบเครื่องมือ แท็บ ชีต และข้อความในรูปม็อกอัป"),
    ],
    "vi": [
        ("01-course.png",  "Đừng đọc.<br>Hãy chạm.",  "Mỗi bài một quyết định, 23 bài học UI/UX"),
        ("02-try.png",  "Dùng thử trước",  "Dùng màn hình vi phạm quy tắc ở kích thước thật"),
        ("03-write.png",  "Ghi lại điều<br>bạn cảm thấy",  "Trước đáp án, viết điều tay bạn nhận ra"),
        ("04-reason.png",  "Rồi xem lý do",  "Quyết định, lý do và cái gì hỏng nếu đảo ngược"),
        ("05-compare.png",  "Bản hỏng và bản sửa<br>cạnh nhau",  "Chuyển qua lại ngay tại chỗ để cảm nhận khác biệt"),
        ("06-items.png",  "68 chủ đề UI/UX<br>vẽ thành hình",  "Thanh công cụ, tab, sheet và chữ trong mockup"),
    ],
    "cs": [
        ("01-course.png",  "Nečtěte.<br>Klepejte.",  "Jedna lekce, jedno rozhodnutí, 23 lekcí UI/UX"),
        ("02-try.png",  "Nejdřív to zkuste",  "Používejte obrazovku porušující pravidlo ve skutečné velikosti"),
        ("03-write.png",  "Zapište, co<br>jste cítili",  "Před odpovědí napište, čeho si všimla vaše ruka"),
        ("04-reason.png",  "Pak se podívejte na důvod",  "Rozhodnutí, důvod a co se rozbije, když ho obrátíte"),
        ("05-compare.png",  "Rozbité a opravené<br>vedle sebe",  "Přepínejte na místě a pocítíte rozdíl"),
        ("06-items.png",  "68 témat UI/UX<br>nakreslených",  "Panely nástrojů, karty, sheety a text v mockupech"),
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
  font-family:-apple-system, "SF Pro Display", "Apple SD Gothic Neo", "Hiragino Sans", "PingFang SC", "PingFang TC", sans-serif; }
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
