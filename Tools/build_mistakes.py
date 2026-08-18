#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""mistakes_data.py(직접 쓴 100편) + entries.json(문서에서 뽑은 근거) → mistakes.json

실수 카드 한 장에 필요한 것 중
  - 실수 · 그때는 왜 · 고친 모습  → mistakes_data.py 에서 (직접 쓴 것)
  - 판단 기준 · 근거 항목 제목 · 체험할 예제 · 참고 자료 → entries.json 에서 (문서가 원본)
을 여기서 잇는다. 문서를 고치면 extract_content.py → 이 스크립트 순으로 다시 돌리면 된다.

    python3 Tools/extract_content.py
    python3 Tools/build_mistakes.py
"""

from __future__ import annotations

import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
ENTRIES = ROOT / "HigGymApp" / "Resources" / "entries.json"
OUT = ROOT / "HigGymApp" / "Resources" / "mistakes.json"
STORIES = ROOT / "Retrospectives"

sys.path.insert(0, str(ROOT / "Tools"))
from mistakes_data import CATEGORIES, MISTAKES  # noqa: E402

def read_story(mistake_id: str, title: str) -> list[dict]:
    """Retrospectives/<id>.md 를 절(節) 단위로 쪼갠다.

    회고는 발행용 마크다운으로 두고(그대로 블로그에 올릴 수 있게), 앱에는
    여기서 잘라 넣는다. 원본이 두 벌이 되지 않게 하기 위해서다.
    """
    path = STORIES / f"{mistake_id}.md"
    if not path.exists():
        return []

    raw = path.read_text(encoding="utf-8")
    if raw.startswith("---"):
        _, front, raw = raw.split("---", 2)
        for line in front.strip().splitlines():
            if line.startswith("title:"):
                written = line.split(":", 1)[1].strip()
                if written != title:
                    print(f"[경고] {path.name} 의 제목이 현재 실수와 다릅니다:\n  원고 {written}\n  실수 {title}")

    sections: list[dict] = []
    heading, body = None, []
    for line in raw.strip().splitlines():
        if line.startswith("## "):
            if heading:
                sections.append({"heading": heading, "body": "\n".join(body).strip()})
            heading, body = line[3:].strip(), []
        elif heading:
            body.append(line)
    if heading:
        sections.append({"heading": heading, "body": "\n".join(body).strip()})
    return sections


SEVERITY_LABEL = {
    "common": "자주 밟는다",
    "critical": "사고로 이어진다",
    "subtle": "놓치기 쉽다",
}


def main() -> int:
    if not ENTRIES.exists():
        print(f"entries.json 이 없습니다: {ENTRIES}\n먼저 Tools/extract_content.py 를 실행하세요.")
        return 1

    bundle = json.loads(ENTRIES.read_text(encoding="utf-8"))
    by_index = {e["index"]: e for e in bundle["entries"] + bundle["principles"]}

    categories = []
    for key, title, principle, desc in CATEGORIES:
        criterion = ""
        if principle and principle in by_index:
            criterion = by_index[principle]["criterion"]
        categories.append(
            {"id": key, "title": title, "desc": desc, "principle": principle or "", "criterion": criterion}
        )
    criterion_of = {c["id"]: c["criterion"] for c in categories}

    live = [m for m in MISTAKES if not m.get("spare")]
    out = []
    for number, m in enumerate(live, start=1):
        sources = []
        for index in m["src"]:
            entry = by_index.get(index)
            if entry is None:
                print(f"[에러] {m['t']}: 근거 항목 {index} 를 entries.json 에서 찾지 못했습니다.")
                return 1
            sources.append({"index": index, "title": entry["title"], "entryID": entry["id"]})

        # 체험할 예제 — 원칙(8.x)보다 본문 항목을 우선한다. 그림이 있는 쪽이기 때문.
        demo = next((s["entryID"] for s in sources if not s["index"].startswith("8.")), sources[0]["entryID"])

        refs, seen = [], set()
        for index in m["src"]:
            for ref in by_index[index].get("refs", []):
                if ref["url"] in seen:
                    continue
                seen.add(ref["url"])
                refs.append(ref)

        out.append(
            {
                "id": f"m{number:03d}",
                "number": number,
                "title": m["t"],
                "why": m["why"],
                "fix": m["fix"],
                "category": m["c"],
                "severity": m["s"],
                "severityLabel": SEVERITY_LABEL[m["s"]],
                "criterion": criterion_of[m["c"]],
                "sources": sources,
                "demoEntryID": demo,
                "refs": refs[:2],
                "story": read_story(f"m{number:03d}", m["t"]),
            }
        )

    if len(out) != 100:
        print(f"[에러] 본편이 {len(out)}편입니다. spare 플래그로 정확히 100편을 맞추세요.")
        return 1

    OUT.write_text(
        json.dumps(
            {"generatedFrom": "toolbar-annotated.html + Tools/mistakes_data.py", "categories": categories, "mistakes": out},
            ensure_ascii=False,
            indent=2,
        )
        + "\n",
        encoding="utf-8",
    )

    from collections import Counter

    print(f"→ {OUT.relative_to(ROOT)}  실수 {len(out)}편 · 분류 {len(categories)}개")
    for key, count in Counter(m["category"] for m in out).most_common():
        title = next(c["title"] for c in categories if c["id"] == key)
        print(f"   {title:<14} {count:>3}편")
    print("   심각도:", dict(Counter(m["severityLabel"] for m in out)))
    covered = {s["index"] for m in out for s in m["sources"]}
    print(f"   근거로 쓴 본문 항목 {len(covered)} / {len(by_index)}개")
    with_story = [m["number"] for m in out if m["story"]]
    print(f"   회고 원고 {len(with_story)}편: {with_story}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
