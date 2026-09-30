#!/bin/sh
# 배포 전 게이트. 여기서 실패하면 DeployBar 가 아카이브를 만들지 않는다.
#
# 이 앱에는 단위 테스트가 없다. 대신 이 앱에서 실제로 틀어지는 것들을 본다.
#   1. 콘텐츠 JSON 이 원본(toolbar-annotated.html · mistakes_data.py · Retrospectives)과 같은가
#   2. 엠대시·엔대시가 다시 들어오지 않았는가
#   3. 빌드가 되는가
set -e
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT"

echo "▶︎ 콘텐츠 JSON 재생성 확인"
python3 Tools/extract_content.py >/dev/null
python3 Tools/build_mistakes.py >/dev/null
if ! git diff --quiet -- HigGymApp/Resources/entries.json HigGymApp/Resources/mistakes.json; then
  echo "❌ 원본을 고친 뒤 JSON 을 다시 만들지 않았습니다. 지금 다시 만들었으니 확인하고 커밋하세요."
  git diff --stat -- HigGymApp/Resources/
  exit 1
fi

echo "▶︎ 엠대시·엔대시 검사"
DASH="$(printf '\342\200\224\|\342\200\223')"
if git ls-files | xargs grep -l "$DASH" 2>/dev/null; then
  echo "❌ 위 파일에 엠대시(U+2014) 또는 엔대시(U+2013)가 있습니다."
  exit 1
fi

echo "▶︎ 빌드"
xcodebuild -project HigGym.xcodeproj -scheme HigGym \
  -destination 'generic/platform=iOS Simulator' -quiet build

echo "✅ 배포 전 게이트 통과"
