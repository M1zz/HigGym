import sys, glob
from PIL import Image, ImageDraw, ImageFont, ImageFilter

SP, OUT = sys.argv[1], sys.argv[2]
# 기본은 6.5" iPhone(1242×2688). 6.9" 는 인자로 1320 2868
W, H = (int(sys.argv[3]), int(sys.argv[4])) if len(sys.argv) > 4 else (1242, 2688)
k = W / 1320  # 레이아웃 수치는 1320 기준으로 잡았다
def px(v): return round(v * k)

def font(weight):
    path = '/System/Library/Fonts/AppleSDGothicNeo.ttc'
    for i in range(20):
        try:
            f = ImageFont.truetype(path, 10, index=i)
        except OSError:
            break
        if f.getname()[1] == weight:
            return lambda size, i=i: ImageFont.truetype(path, size, index=i)
    raise SystemExit(f'no {weight}')

bold, medium = font('Bold'), font('Medium')

SHOTS = [
    ('02_use',        '설명보다 화면이 먼저',       '어긴 화면을 직접 만지며 배우는 앱 디자인'),
    ('03_write',      '답을 보기 전에\n느낀 것부터', '이상했던 지점을 먼저 적어봅니다'),
    ('04_reason',     '왜 어색했는지\n기준으로 확인', '어긴 이유와 고치는 방법까지'),
    ('05_compare',    '고친 화면에서\n같은 일을 다시', '무엇이 달라졌는지 손으로 느껴봅니다'),
    ('01_course',     '한 편에 결정 하나',          'HIG를 스물세 편의 워크북으로'),
    ('c_L10',         '사진 위에서도\n버튼이 읽히나요', '최악의 배경에서 확인하는 가장자리 효과'),
    ('c_L11',         '글자가 커져도\n값이 남는가',   '접근성 큰 글씨로 직접 읽어봅니다'),
    ('c_L20',         '탭이 여섯 개가 되면',         '시스템이 More로 접는 순간을 만나봅니다'),
    ('c_L15',         '하단 바는\n누구의 자리인가',  '조작 자리를 차지한 광고를 직접 겪어봅니다'),
]

def background():
    top, bot = (47, 125, 246), (138, 91, 230)
    g = Image.new('RGB', (1, H))
    for y in range(H):
        t = y / (H - 1)
        g.putpixel((0, y), tuple(round(a + (b - a) * t) for a, b in zip(top, bot)))
    return g.resize((W, H))

def rounded(im, r):
    m = Image.new('L', im.size, 0)
    ImageDraw.Draw(m).rounded_rectangle((0, 0, *im.size), r, fill=255)
    return m

SLUG = {'02_use': 'use', '03_write': 'write', '04_reason': 'reason', '05_compare': 'compare', '01_course': 'course',
        'c_L10': 'photo_edge', 'c_L11': 'large_text', 'c_L20': 'six_tabs', 'c_L15': 'ad_bar'}

BG = background()
for n, (name, title, sub) in enumerate(SHOTS, 1):
    canvas = BG.copy()
    d = ImageDraw.Draw(canvas)

    # 문구
    tf, sf = bold(px(112)), medium(px(54))
    DEVICE_TOP = px(660)
    lines = title.split('\n')
    y = (DEVICE_TOP - (len(lines) * px(140) + px(86))) // 2 + px(10)
    for line in title.split('\n'):
        w = d.textlength(line, font=tf)
        d.text(((W - w) / 2, y), line, font=tf, fill='white')
        y += px(140)
    y += px(16)
    w = d.textlength(sub, font=sf)
    d.text(((W - w) / 2, y), sub, font=sf, fill=(255, 255, 255, 220))

    # 기기 — 화면 + 검은 베젤 + 그림자
    scale = 0.78
    raw = Image.open(f'{SP}/raw/{name}.png').convert('RGB')
    sw = round(W * scale)
    sh = round(sw * raw.height / raw.width)  # 화면 비율은 캔버스가 아니라 원본을 따른다
    screen = raw.resize((sw, sh), Image.LANCZOS)
    bezel = px(22)
    bw, bh = sw + bezel * 2, sh + bezel * 2
    bx = (W - bw) // 2
    by = DEVICE_TOP  # 모든 장에서 같은 높이 — 아래는 캔버스 밖으로 조금 잘린다

    shadow = Image.new('L', (W, H), 0)
    ImageDraw.Draw(shadow).rounded_rectangle((bx, by + px(30), bx + bw, by + bh + px(30)), px(170), fill=110)
    shadow = shadow.filter(ImageFilter.GaussianBlur(px(50)))
    canvas.paste(Image.new('RGB', (W, H), (20, 16, 60)), (0, 0), shadow)

    frame = Image.new('RGB', (bw, bh), (18, 18, 20))
    canvas.paste(frame, (bx, by), rounded(frame, px(170)))
    canvas.paste(screen, (bx + bezel, by + bezel), rounded(screen, px(150)))

    canvas.save(f'{OUT}/{n:02d}_{SLUG[name]}.png', optimize=True)
    print(f'{n:02d}', name)
