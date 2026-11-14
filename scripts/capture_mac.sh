#!/bin/zsh
# Mac App Store 스크린샷 — 꾸미지 않은 창 그대로 2880×1800 을 docs/screenshots/marketing/<언어>/mac-0N-<장면>.png 에 둔다.
# (iPhone · iPad 제출본과 한 폴더 — DeployBar 가 크기로 기기를 가른다)
#
# 사용법: zsh scripts/capture_mac.sh [언어 ...]   (언어를 안 주면 24개 모두)
#   - Debug Catalyst 빌드가 build/mac/Build/Products/Debug-maccatalyst/HigGym.app 에 있어야 한다:
#     xcodebuild -project HigGym.xcodeproj -scheme HigGym -destination 'platform=macOS,variant=Mac Catalyst' -derivedDataPath build/mac build
#   - 창 크기는 HG_MAC_WINDOW(DEBUG 전용, MacShotWindow.swift)로 1440×900 pt 에 묶는다. iPad 크기 맞춤(77%) 이라 UIKit 으로는 1871×1169.
#   - 예시 노트(HG_SEED_NOTES)는 이 Mac 의 앱 설정에 들어간다 → 찍기 전 설정을 떠 두었다가 끝나면 되돌린다.
#   - 창이 잠깐씩 앞으로 나온다. screencapture 에 화면 기록 권한이 필요하다.
set -u
cd "$(dirname "$0")/.."
APP=build/mac/Build/Products/Debug-maccatalyst/HigGym.app
WIN=build/winlist
[[ -x $WIN ]] || { mkdir -p build; swiftc -O scripts/winlist.swift -o $WIN; }
ALL=(ko en en-GB ja zh-Hans zh-Hant ru es de fr it pt-BR th vi cs da el fi id nb nl pl sv tr)
if (( $# )); then LANGS=($@); else LANGS=($ALL); fi
SCENES=(course try compare library)

env_of() {   # capture_ipad.sh 와 같은 장면
  case $1 in
    course)  echo "HG_TAB=course HG_SEED_NOTES=1" ;;
    try)     echo "HG_TAB=course HG_SEED_NOTES=1 HG_LESSON=L2 HG_STEP=0" ;;
    compare) echo "HG_TAB=course HG_SEED_NOTES=1 HG_LESSON=L2 HG_STEP=3" ;;
    library) echo "HG_TAB=library HG_SEED_NOTES=1 HG_LIB=entries" ;;
  esac
}
locale_of() {
  case $1 in
    ko) echo ko_KR ;; en) echo en_US ;; en-GB) echo en_GB ;; zh-Hans) echo zh_CN ;; zh-Hant) echo zh_TW ;;
    ja) echo ja_JP ;; ru) echo ru_RU ;; es) echo es_ES ;; de) echo de_DE ;; fr) echo fr_FR ;; it) echo it_IT ;;
    pt-BR) echo pt_BR ;; th) echo th_TH ;; vi) echo vi_VN ;; cs) echo cs_CZ ;; da) echo da_DK ;; el) echo el_GR ;;
    fi) echo fi_FI ;; id) echo id_ID ;; nb) echo nb_NO ;; nl) echo nl_NL ;; pl) echo pl_PL ;; sv) echo sv_SE ;;
    tr) echo tr_TR ;; *) echo en_US ;;
  esac
}


PREFS=~/Library/Containers/com.leeo.higgym/Data/Library/Preferences/com.leeo.higgym.plist
BACKUP=$(mktemp -t higgym-prefs)
had=0; [[ -f $PREFS ]] && { cp $PREFS $BACKUP; had=1; }
restore() { pkill -x HigGym; sleep 1; if (( had )); then cp $BACKUP $PREFS; else rm -f $PREFS; fi; rm -f $BACKUP; }
trap restore EXIT

for lang in $LANGS; do
  echo "▸ $lang"
  out=docs/screenshots/marketing/$lang; mkdir -p $out
  n=0
  for scene in $SCENES; do
    n=$((n+1))
    file=$out/mac-0$n-$scene.png
    envs=(--env HG_MAC_WINDOW=1871,1169); for v in ${=$(env_of $scene)}; do envs+=(--env $v); done
    # 앞 장면이 고른 레슨 · 단계가 남지 않게 매번 같은 설정에서 연다
    if (( had )); then cp $BACKUP $PREFS 2>/dev/null; else rm -f $PREFS; fi
    open -n $APP $envs --args -AppleLanguages "($lang)" -AppleLocale $(locale_of $lang) -ApplePersistenceIgnoreState YES
    pid=""; for i in {1..50}; do pid=$(pgrep -nx HigGym); [[ -n $pid ]] && break; sleep 0.2; done
    [[ -z $pid ]] && { echo "  ✗ $file (실행 안 됨)"; continue; }
    sleep 6; open $APP; sleep 1.5          # 비활성(회색) 창으로 찍히지 않게 한 번 더 앞으로
    win=$($WIN $pid | awk '$6 == 0 && $4 == 1440 {print $1; exit}')
    if [[ -n $win ]] && screencapture -x -o -l $win $file; then echo "  $file"; else echo "  ✗ $file"; fi
    kill $pid; sleep 1
  done
done
