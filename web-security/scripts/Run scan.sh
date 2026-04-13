#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────
# run_scan.sh — Python + Bash 통합 실행 래퍼
# ──────────────────────────────────────────────────────────

set -euo pipefail

BOLD='\033[1m'; CYAN='\033[0;36m'; GREEN='\033[0;32m'
YELLOW='\033[1;33m'; RESET='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
REPORT_DIR="${SCRIPT_DIR}/reports/${TIMESTAMP}"
mkdir -p "$REPORT_DIR"

TARGET_URL=""
SOURCE_DIR=""

usage() {
    echo -e "${BOLD}사용법:${RESET}"
    echo "  $0 -u <URL>               URL 동적 점검만"
    echo "  $0 -s <소스경로>           소스코드 정적 분석만"
    echo "  $0 -u <URL> -s <소스경로>  통합 점검"
    echo ""
    echo "예시:"
    echo "  $0 -u https://example.com"
    echo "  $0 -u https://example.com -s ./myapp"
    exit 1
}

while getopts "u:s:h" opt; do
    case $opt in
        u) TARGET_URL="$OPTARG" ;;
        s) SOURCE_DIR="$OPTARG" ;;
        h) usage ;;
        *) usage ;;
    esac
done

[[ -z "$TARGET_URL" && -z "$SOURCE_DIR" ]] && usage

echo -e "${BOLD}"
echo "╔══════════════════════════════════════════════════════╗"
echo "║     Web Security Scanner — 통합 실행                 ║"
echo "║     OWASP:2025 / API / KISA-MOIS / Emerging          ║"
echo "╚══════════════════════════════════════════════════════╝"
echo -e "${RESET}"
echo "  보고서 저장 경로: $REPORT_DIR"
echo ""

# ── 의존성 확인 ──
echo -e "${CYAN}[1/3] 의존성 확인${RESET}"
python3 -c "import requests, colorama" 2>/dev/null || {
    echo "[설치 중] pip install requests colorama"
    pip3 install requests colorama --break-system-packages -q
}
command -v curl  &>/dev/null || { echo "[오류] curl 없음 — apt install curl"; exit 1; }
echo "  OK"

# ── Bash 빠른 점검 ──
if [[ -n "$TARGET_URL" ]]; then
    echo ""
    echo -e "${CYAN}[2/3] Bash 빠른 점검 (헤더, TLS, 포트, 배너)${RESET}"
    BASH_REPORT="${REPORT_DIR}/bash_scan.txt"
    bash "${SCRIPT_DIR}/web_quick_scan.sh" \
        -u "$TARGET_URL" \
        -o "$BASH_REPORT" || true
    echo "  저장: $BASH_REPORT"
fi

# ── Python 심층 점검 ──
echo ""
echo -e "${CYAN}[3/3] Python 심층 점검 (인젝션, 인증, API, 정적분석)${RESET}"
PY_REPORT="${REPORT_DIR}/python_scan.json"

PY_ARGS=()
[[ -n "$TARGET_URL"  ]] && PY_ARGS+=(--url    "$TARGET_URL")
[[ -n "$SOURCE_DIR"  ]] && PY_ARGS+=(--source "$SOURCE_DIR")
PY_ARGS+=(--output "$PY_REPORT")

python3 "${SCRIPT_DIR}/scanner.py" "${PY_ARGS[@]}" || true

# ── 최종 안내 ──
echo ""
echo -e "${BOLD}══════════════════════════════════════════════════════${RESET}"
echo -e "${GREEN}  점검 완료${RESET}"
echo ""
echo "  결과 파일:"
ls "$REPORT_DIR"/ | while read -r f; do
    echo "    $REPORT_DIR/$f"
done
echo ""
echo -e "${YELLOW}  주의사항:${RESET}"
echo "  · 이 스캐너는 1차 스크리닝 도구입니다."
echo "  · Critical/High 항목은 Burp Suite, sqlmap, OWASP ZAP으로"
echo "    수동 검증을 반드시 수행하세요."
echo "  · 허가된 시스템에만 사용하십시오."
echo -e "${BOLD}══════════════════════════════════════════════════════${RESET}"