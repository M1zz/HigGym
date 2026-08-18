#!/usr/bin/env python3
"""toolbar-annotated.html -> HigGymApp/Resources/entries.json

문서(HTML)를 단일 진실 소스로 두고 앱이 쓰는 JSON을 뽑아낸다.
문서를 고치면 이 스크립트만 다시 돌리면 앱 콘텐츠와 퀴즈가 함께 갱신된다.
"""

import html
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SRC = ROOT / "toolbar-annotated.html"
OUT = ROOT / "HigGymApp" / "Resources" / "entries.json"

# 본문에서 번호 매김에 쓰는 원문자 — ok/ng 예시를 개별 항목으로 쪼갤 때 구분자로 쓴다.
CIRCLED = "①②③④⑤⑥⑦⑧⑨"


def to_markdown(fragment: str) -> str:
    """인라인 HTML을 SwiftUI가 렌더할 수 있는 마크다운으로 바꾼다."""
    s = fragment
    s = re.sub(r"<a\s[^>]*href=\"([^\"]+)\"[^>]*>(.*?)</a>", r"[\2](\1)", s, flags=re.S)
    s = re.sub(r"</?(?:b|strong)>", "**", s)
    s = re.sub(r"</?code>", "`", s)
    s = re.sub(r"<br\s*/?>", "\n", s)
    s = re.sub(r"<[^>]+>", "", s)          # 남은 태그(span 등)는 제거
    s = html.unescape(s)
    s = re.sub(r"[ \t]+", " ", s)
    return s.strip()


def split_examples(markdown: str) -> list[str]:
    """"① … ② …" 형태의 예시 묶음을 개별 예시로 분리한다."""
    if not markdown:
        return []
    parts = re.split(f"(?=[{CIRCLED}])", markdown)
    items = [p.strip().lstrip(CIRCLED).strip() for p in parts if p.strip()]
    return [i for i in items if i]


# ---------------------------------------------------------------- 프리뷰 목업

VOID_TAGS = {"br", "img", "hr"}
# 목업에서 의미를 갖는 태그만 남긴다.
MOCKUP_TAGS = {"div", "span", "i", "b", "em", "small"}


def parse_style(raw: str) -> dict:
    out = {}
    for decl in (raw or "").split(";"):
        if ":" not in decl:
            continue
        key, _, value = decl.partition(":")
        out[key.strip()] = value.strip()
    return out


def parse_mockup(fragment: str) -> list:
    """프리뷰의 <div class="phone">… 를 {tag, classes, style, text, children} 트리로.

    CSS 클래스 어휘가 닫혀 있어서 앱이 같은 목업을 그대로 그릴 수 있다.
    """
    token = re.compile(r"<(/?)(\w+)([^>]*?)(/?)>|([^<]+)")
    root = {"tag": "root", "classes": [], "style": {}, "text": None, "children": []}
    stack = [root]

    for match in token.finditer(fragment):
        closing, tag, attrs, self_closing, text = match.groups()

        if text is not None:
            content = html.unescape(text).strip()
            if content:
                stack[-1]["children"].append(
                    {"tag": "text", "classes": [], "style": {}, "text": content, "children": []}
                )
            continue

        if tag not in MOCKUP_TAGS:
            continue

        if closing:
            if len(stack) > 1:
                stack.pop()
            continue

        class_match = re.search(r'class="([^"]*)"', attrs)
        style_match = re.search(r'style="([^"]*)"', attrs)
        node = {
            "tag": tag,
            "classes": class_match.group(1).split() if class_match else [],
            "style": parse_style(style_match.group(1) if style_match else ""),
            "text": None,
            "children": [],
        }
        stack[-1]["children"].append(node)
        if not self_closing and tag not in VOID_TAGS:
            stack.append(node)

    return root["children"]


ROW_LABELS = {
    "when": "when",
    "why": "why",
    "tip": "tip",
    "u27": "ios27",
    "ok": "ok",
    "ng": "ng",
    "crit": "criterion",
    "ref": "ref",
}


def parse_rows(block: str) -> dict:
    rows: dict[str, str] = {}
    for kind, body in re.findall(
        r"<div class=\"r ([a-z0-9]+)\"><div class=\"k\">.*?</div><div class=\"v\">(.*?)</div></div>",
        block,
        flags=re.S,
    ):
        key = ROW_LABELS.get(kind)
        if key:
            rows[key] = to_markdown(body)
    return rows


def parse_refs(markdown: str) -> list[dict]:
    return [
        {"title": t.strip(), "url": u.strip()}
        for t, u in re.findall(r"\[([^\]]+)\]\(([^)]+)\)", markdown or "")
    ]


def main() -> int:
    doc = SRC.read_text(encoding="utf-8")

    # 챕터 헤더 위치 — 각 entry가 어느 챕터에 속하는지 오프셋으로 판정한다.
    chapters = []
    for m in re.finditer(
        r"<div class=\"ch-head\" id=\"(ch\d+)\">\s*<div class=\"ch-num\">(\d+)</div>\s*<h2>(.*?)</h2>",
        doc,
        flags=re.S,
    ):
        raw = m.group(3)
        sub = re.search(r"<span class=\"ch-sub\">(.*?)</span>", raw, flags=re.S)
        chapters.append(
            {
                "id": m.group(1),
                "number": int(m.group(2)),
                "title": to_markdown(re.sub(r"<span class=\"ch-sub\">.*?</span>", "", raw, flags=re.S)),
                "subtitle": to_markdown(sub.group(1)).lstrip("— ").strip() if sub else "",
                "pos": m.start(),
            }
        )

    # 섹션 헤더 위치
    sections = []
    for m in re.finditer(
        r"<div class=\"sec-head\">\s*<div class=\"sec-num\">([\d.]+)</div>\s*<h2>(.*?)</h2>"
        r"(?:\s*<p class=\"sec-desc\">(.*?)</p>)?",
        doc,
        flags=re.S,
    ):
        sections.append(
            {
                "number": m.group(1),
                "title": to_markdown(m.group(2)),
                "desc": to_markdown(m.group(3) or ""),
                "pos": m.start(),
            }
        )

    def owner(table, pos):
        found = None
        for item in table:
            if item["pos"] <= pos:
                found = item
            else:
                break
        return found

    entries = []
    principles = []

    # entry 단위로 먼저 자른다 — 중첩 div 때문에 한 방에 정규식으로 뜨면 경계가 어긋난다.
    starts = [m.start() for m in re.finditer(r"<div class=\"entry\" id=\"", doc)]
    bounds = list(zip(starts, starts[1:] + [len(doc)]))

    for start, end in bounds:
        block = doc[start:end]
        head = re.search(
            r"<div class=\"entry\" id=\"([^\"]+)\">\s*"
            r"<div class=\"idx\">([\d.]+)</div>\s*"
            r"<h3>(.*?)</h3>\s*"
            r"<p class=\"what\">(.*?)</p>",
            block,
            flags=re.S,
        )
        if not head:
            continue
        eid, idx, title_raw, what = head.groups()
        cap = re.search(r"<figcaption>(.*?)</figcaption>", block, flags=re.S)
        caption = cap.group(1) if cap else ""
        fig = re.search(r'<figure class="preview">(.*?)<figcaption>', block, flags=re.S)
        mockup = parse_mockup(fig.group(1)) if fig else []
        rows = parse_rows(block)
        ch = owner(chapters, start)
        sec = owner(sections, start)

        record = {
            "id": eid,
            "index": idx,
            "chapter": ch["number"] if ch else 0,
            "chapterTitle": ch["title"] if ch else "",
            "section": sec["number"] if sec else "",
            "sectionTitle": sec["title"] if sec else "",
            "title": to_markdown(title_raw),
            "summary": to_markdown(what),
            "caption": to_markdown(caption or ""),
            "mockup": mockup,
            "when": rows.get("when", ""),
            "why": rows.get("why", ""),
            "tip": rows.get("tip", ""),
            "ios27": rows.get("ios27", ""),
            "criterion": rows.get("criterion", ""),
            "good": split_examples(rows.get("ok", "")),
            "bad": split_examples(rows.get("ng", "")),
            "refs": parse_refs(rows.get("ref", "")),
        }

        if record["chapter"] == 8:
            principles.append(record)
        else:
            entries.append(record)

    payload = {
        "generatedFrom": SRC.name,
        "chapters": [
            {k: c[k] for k in ("id", "number", "title", "subtitle")}
            for c in chapters
            if c["number"] != 8
        ],
        "sections": [
            {k: s[k] for k in ("number", "title", "desc")}
            for s in sections
            if not s["number"].startswith("8")
        ],
        "entries": entries,
        "principles": principles,
    }

    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(json.dumps(payload, ensure_ascii=False, indent=1), encoding="utf-8")

    print(f"chapters={len(payload['chapters'])} sections={len(payload['sections'])} "
          f"entries={len(entries)} principles={len(principles)} -> {OUT.relative_to(ROOT)}")

    missing = [e["index"] for e in entries if not e["when"] or not e["good"] or not e["bad"]]
    if missing:
        print("불완전한 항목:", missing, file=sys.stderr)

    no_mockup = [e["index"] for e in entries if not e["mockup"]]
    if no_mockup:
        print("프리뷰 없는 항목:", no_mockup, file=sys.stderr)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
