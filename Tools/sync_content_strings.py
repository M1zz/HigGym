#!/usr/bin/env python3
"""콘텐츠 JSON(entries.json · mistakes.json)의 한국어 문장을 Content.xcstrings 표와 맞춘다.

앱은 JSON 을 읽을 때 한글이 든 문자열을 이 표에서 찾아 기기 언어로 바꾼다(→ ContentLocalization.swift).
그래서 원문이 바뀌면 표에도 그 문장이 있어야 하고, 지원하는 모든 언어로 번역돼 있어야 한다.

  python3 Tools/sync_content_strings.py            # 새 문장을 표에 더하고, JSON 에서 사라진 문장을 지운다
  python3 Tools/sync_content_strings.py --check    # 바꾸지 않고, 번역 빈칸 · 남은 옛 문장 · 예시 구조가 틀리면 실패(배포 게이트)
  python3 Tools/sync_content_strings.py --merge f.json   # {"한국어": {"en": "...", "ja": "..."}} 번역을 표에 넣는다
"""
import json, re, sys, os

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
RES = os.path.join(ROOT, "HigGymApp", "Resources")
TABLE = os.path.join(RES, "Content.xcstrings")
LANGS = ["en", "ja"]
HANGUL = re.compile("[ㄱ-ㆎ가-힣]")


def korean_strings():
    found = []
    def walk(x):
        if isinstance(x, dict):
            for v in x.values(): walk(v)
        elif isinstance(x, list):
            for v in x: walk(v)
        elif isinstance(x, str) and HANGUL.search(x) and x not in seen:
            seen.add(x); found.append(x)
    seen = set()
    for name in ("entries.json", "mistakes.json"):
        with open(os.path.join(RES, name), encoding="utf-8") as f:
            walk(json.load(f))
    return found


def structure_problems():
    """예시는 요약/근거, 원칙 제목은 이름/한 줄 설명으로 나뉘어 있어야 한다.

    둘을 한 문장으로 두면 퀴즈 지문에 근거가 붙어 답이 새어 나가고, 번역문은 언어마다
    구분 기호가 달라 다시 나눌 수 없다. 나뉜 두 부분은 각각 표의 키가 되므로 빈칸 검사도 따로 받는다.
    """
    with open(os.path.join(RES, "entries.json"), encoding="utf-8") as f:
        bundle = json.load(f)
    problems = []
    for e in bundle["entries"] + bundle["principles"]:
        for kind in ("good", "bad"):
            for i, x in enumerate(e[kind]):
                if not isinstance(x, dict) or set(x) != {"headline", "rationale", "quiz"}:
                    problems.append(f"{e['index']} {kind}[{i}] 이 headline/rationale/quiz 객체가 아님")
                elif not x["headline"]:
                    problems.append(f"{e['index']} {kind}[{i}] 요약이 비었음")
                elif x["rationale"] and x["rationale"] in x["headline"]:
                    problems.append(f"{e['index']} {kind}[{i}] 요약에 근거가 들어 있음")
    for p in bundle["principles"]:
        if not p.get("tagline"):
            problems.append(f"원칙 {p['index']} 의 한 줄 설명(tagline)이 비었음")
    return problems


def load_table():
    if os.path.exists(TABLE):
        with open(TABLE, encoding="utf-8") as f:
            return json.load(f)
    return {"sourceLanguage": "ko", "strings": {}, "version": "1.0"}


def save_table(table):
    with open(TABLE, "w", encoding="utf-8") as f:
        json.dump(table, f, ensure_ascii=False, indent=2, sort_keys=True)
        f.write("\n")


def unit(value):
    return {"stringUnit": {"state": "translated", "value": value}}


def main(argv):
    table = load_table()
    strings = table["strings"]
    wanted = korean_strings()

    if "--merge" in argv:
        with open(argv[argv.index("--merge") + 1], encoding="utf-8") as f:
            incoming = json.load(f)
        for ko, langs in incoming.items():
            entry = strings.setdefault(ko, {"extractionState": "manual"})
            locs = entry.setdefault("localizations", {})
            for lang, value in langs.items():
                locs[lang] = unit(value)

    if "--check" not in argv:
        for ko in wanted:
            strings.setdefault(ko, {"extractionState": "manual"})
        for ko in [k for k in strings if k not in set(wanted)]:
            del strings[ko]
        save_table(table)

    missing = {lang: [k for k in wanted
                      if not strings.get(k, {}).get("localizations", {}).get(lang, {}).get("stringUnit", {}).get("value")]
               for lang in LANGS}
    stale = [k for k in strings if k not in set(wanted)]
    broken = structure_problems()
    for line in broken[:10]:
        print(f"  구조: {line}")
    print(f"콘텐츠 문장 {len(wanted)}개 · " + " · ".join(f"{l} 빈칸 {len(m)}" for l, m in missing.items())
          + (f" · 표에만 남은 문장 {len(stale)}" if stale else ""))
    if "--check" in argv and (any(missing.values()) or stale or broken):
        for lang, keys in missing.items():
            for k in keys[:5]:
                print(f"  {lang} 빈칸: {k[:60]}")
        print("❌ Tools/sync_content_strings.py 로 표를 맞추고 빈칸을 번역하세요.")
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
