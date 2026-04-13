#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────
# web_quick_scan.sh — Bash 보조 취약점 점검 스크립트
# KISA/MOIS + OWASP 기반  |  의존: curl, nmap, openssl (선택)
# ──────────────────────────────────────────────────────────

set -euo pipefail

# ── 색상 ──
RED='\033[1;31m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'
GREEN='\033[0;32m'; RESET='\033[0m'; BOLD='\033[1m'

# ── 인수 파싱 ──
TARGET_URL=""
REPORT_FILE="bash_scan_$(date +%Y%m%d_%H%M%S).txt"

usage() {
    echo "사용법: $0 -u <URL> [-o <보고서파일>]"
    echo "  예시: $0 -u https://example.com"
    echo "        $0 -u https://example.com -o result.txt"
    exit 1
}

while getopts "u:o:h" opt; do
    case $opt in
        u) TARGET_URL="$OPTARG" ;;
        o) REPORT_FILE="$OPTARG" ;;
        h) usage ;;
        *) usage ;;
    esac
done

[[ -z "$TARGET_URL" ]] && usage

# URL에서 호스트 추출
HOST=$(echo "$TARGET_URL" | sed -E 's|https?://||' | cut -d'/' -f1 | cut -d':' -f1)
SCHEME=$(echo "$TARGET_URL" | grep -oE '^https?')

log_finding() {
    local sev="$1" id="$2" title="$3" detail="$4"
    local color="$RESET"
    [[ "$sev" == "Critical" ]] && color="$RED"
    [[ "$sev" == "High" ]]     && color="$YELLOW"
    [[ "$sev" == "Medium" ]]   && color="$CYAN"

    local line="[${sev}] [${id}] ${title} — ${detail}"
    echo -e "${color}${line}${RESET}"
    echo "$line" >> "$REPORT_FILE"
}

log_ok() {
    echo -e "${GREEN}[OK]${RESET} $*"
    echo "[OK] $*" >> "$REPORT_FILE"
}

section() {
    echo ""
    echo -e "${BOLD}══════════════════════════════════════════${RESET}"
    echo -e "${BOLD}  $*${RESET}"
    echo -e "${BOLD}══════════════════════════════════════════${RESET}"
    echo "" >> "$REPORT_FILE"
    echo "== $* ==" >> "$REPORT_FILE"
}

# 보고서 초기화
echo "Web Quick Scan — $(date)" > "$REPORT_FILE"
echo "대상: $TARGET_URL" >> "$REPORT_FILE"
echo "호스트: $HOST" >> "$REPORT_FILE"
echo "────────────────────────────────────────" >> "$REPORT_FILE"

echo -e "${BOLD}"
echo "════════════════════════════════════════════"
echo "  Web Quick Scan (Bash)  |  대상: $TARGET_URL"
echo "════════════════════════════════════════════"
echo -e "${RESET}"

# ── 1. TLS / HTTPS 점검  (W-047) ─────────────────────────
section "W-047 TLS / HTTPS 점검"

if [[ "$SCHEME" == "http" ]]; then
    log_finding "Critical" "W-047" "HTTP 평문 사용" "대상이 HTTP 스킴 — TLS 적용 확인 필요"
fi

if command -v openssl &>/dev/null; then
    TLS_INFO=$(echo | timeout 5 openssl s_client -connect "${HOST}:443" \
        -brief 2>/dev/null | head -5 || true)
    if echo "$TLS_INFO" | grep -qi "tls 1\.[01]"; then
        log_finding "High" "W-047" "구버전 TLS 감지" "TLS 1.0/1.1 — 최소 TLS 1.2 필요"
    elif echo "$TLS_INFO" | grep -qi "tls 1\.[23]"; then
        log_ok "TLS 버전 적절"
    fi

    # 인증서 만료 확인
    EXPIRE=$(echo | timeout 5 openssl s_client -connect "${HOST}:443" \
        2>/dev/null | openssl x509 -noout -enddate 2>/dev/null \
        | cut -d= -f2 || true)
    if [[ -n "$EXPIRE" ]]; then
        EXPIRE_EPOCH=$(date -d "$EXPIRE" +%s 2>/dev/null || \
                       date -j -f "%b %d %H:%M:%S %Y %Z" "$EXPIRE" +%s 2>/dev/null || echo 0)
        NOW_EPOCH=$(date +%s)
        DAYS_LEFT=$(( (EXPIRE_EPOCH - NOW_EPOCH) / 86400 ))
        if (( DAYS_LEFT < 30 )); then
            log_finding "High" "W-047" "인증서 만료 임박" "잔여 일수: ${DAYS_LEFT}일"
        else
            log_ok "인증서 잔여: ${DAYS_LEFT}일"
        fi
    fi
else
    echo "[주의] openssl 없음 — TLS 상세 점검 생략"
fi

# ── 2. 보안 헤더 점검  (W-002) ──────────────────────────
section "W-002 Security Headers"

HEADERS=$(curl -sk -I --max-time 10 "$TARGET_URL" 2>/dev/null | tr '[:upper:]' '[:lower:]')

check_header() {
    local h="$1" id="$2" desc="$3"
    if echo "$HEADERS" | grep -q "$h"; then
        VAL=$(echo "$HEADERS" | grep "$h" | head -1 | sed 's/.*: //' | tr -d '\r')
        log_ok "${h}: ${VAL:0:60}"
    else
        log_finding "High" "$id" "헤더 누락: $h" "$desc"
    fi
}

check_header "strict-transport-security" "W-047" "HSTS 미설정"
check_header "x-content-type-options"    "W-002" "MIME 스니핑 허용"
check_header "x-frame-options"           "W-002" "Clickjacking 방어 없음"
check_header "content-security-policy"   "W-002" "CSP 미설정"
check_header "referrer-policy"           "W-002" "Referrer 노출 가능"
check_header "permissions-policy"        "W-002" "브라우저 기능 제한 없음"

# 서버 배너 노출 (W-046)
section "W-046 서버 배너 노출"
for banner in "server" "x-powered-by" "x-aspnet-version"; do
    VAL=$(echo "$HEADERS" | grep "^${banner}:" | head -1 | tr -d '\r')
    if [[ -n "$VAL" ]]; then
        log_finding "Medium" "W-046" "배너 노출: $banner" "$VAL"
    else
        log_ok "배너 없음: $banner"
    fi
done

# ── 3. 관리자 경로 노출  (W-044) ────────────────────────
section "W-044 Admin Page Exposure"

ADMIN_PATHS=(
    "/admin" "/admin/" "/manager" "/cpanel" "/phpmyadmin"
    "/.env" "/.git/config" "/config" "/console"
    "/actuator" "/actuator/env" "/actuator/health"
    "/wp-admin" "/server-status" "/api/admin"
    "/.htaccess" "/robots.txt" "/sitemap.xml"
)

for path in "${ADMIN_PATHS[@]}"; do
    STATUS=$(curl -sk -o /dev/null --max-time 6 -w "%{http_code}" \
        "${TARGET_URL%/}${path}" 2>/dev/null || echo "000")
    if [[ "$STATUS" == "200" || "$STATUS" == "301" || "$STATUS" == "302" ]]; then
        log_finding "Critical" "W-044" "관리 경로 접근 가능: ${path}" "HTTP ${STATUS}"
    elif [[ "$STATUS" == "403" ]]; then
        log_finding "Medium"   "W-044" "403 반환 (경로 존재 가능성): ${path}" "HTTP ${STATUS}"
    else
        log_ok "차단: ${path} → ${STATUS}"
    fi
done

# ── 4. 디렉터리 리스팅  (W-028) ─────────────────────────
section "W-028 Directory Listing"

DIR_PATHS=("/uploads/" "/images/" "/static/" "/assets/"
           "/files/" "/backup/" "/logs/" "/tmp/" "/media/")

for path in "${DIR_PATHS[@]}"; do
    BODY=$(curl -sk --max-time 6 "${TARGET_URL%/}${path}" 2>/dev/null | tr '[:upper:]' '[:lower:]')
    if echo "$BODY" | grep -q "index of\|parent directory"; then
        log_finding "Medium" "W-028" "디렉터리 목록 노출: ${path}" "Index of 패턴 감지"
    else
        log_ok "목록 없음: ${path}"
    fi
done

# ── 5. CORS 설정  (W-001) ───────────────────────────────
section "W-001 CORS Misconfiguration"

CORS_RESP=$(curl -sk --max-time 8 -H "Origin: https://evil-attacker.com" \
    -I "$TARGET_URL" 2>/dev/null | tr '[:upper:]' '[:lower:]')

ACAO=$(echo "$CORS_RESP" | grep "access-control-allow-origin" \
    | head -1 | sed 's/.*: //' | tr -d '\r ')
ACAC=$(echo "$CORS_RESP" | grep "access-control-allow-credentials" \
    | head -1 | sed 's/.*: //' | tr -d '\r ')

if [[ "$ACAO" == "*" && "$ACAC" == "true" ]]; then
    log_finding "Critical" "W-001" "CORS 와일드카드+Credentials" \
        "ACAO:* + ACAC:true — 인증 정보 유출 가능"
elif [[ "$ACAO" == "https://evil-attacker.com" ]]; then
    log_finding "High" "W-001" "임의 Origin 반사" "Origin 검증 없음: $ACAO"
elif [[ "$ACAO" == "*" ]]; then
    log_finding "Medium" "W-001" "CORS 와일드카드" "공개 API 여부 확인 필요"
else
    log_ok "CORS: ${ACAO:-없음}"
fi

# ── 6. 쿠키 보안 속성  (W-048) ──────────────────────────
section "W-048 Cookie Security"

COOKIE_HDR=$(curl -sk --max-time 8 -I "$TARGET_URL" 2>/dev/null \
    | grep -i "set-cookie" || true)

if [[ -n "$COOKIE_HDR" ]]; then
    while IFS= read -r line; do
        issues=""
        echo "$line" | grep -qi "httponly"  || issues="${issues}HttpOnly 없음; "
        echo "$line" | grep -qi "secure"    || issues="${issues}Secure 없음; "
        echo "$line" | grep -qi "samesite"  || issues="${issues}SameSite 없음; "
        if [[ -n "$issues" ]]; then
            log_finding "High" "W-048" "쿠키 보안 속성 미흡" "$issues | ${line:0:80}"
        else
            log_ok "쿠키 속성 양호: ${line:0:80}"
        fi
    done <<< "$COOKIE_HDR"
else
    log_ok "Set-Cookie 헤더 없음"
fi

# ── 7. 에러 정보 노출  (W-029) ──────────────────────────
section "W-029 Error Disclosure"

ERROR_PAYLOADS=("/?id='" "/?id=<script>" "/nonexistent_path_xyzabc123")
LEAK_PATTERNS="traceback|exception|syntax error|sqlstate|mysql.*error|\
warning:.*php|fatal error|stack trace|/var/www|c:\\\\inetpub"

for p in "${ERROR_PAYLOADS[@]}"; do
    BODY=$(curl -sk --max-time 8 "${TARGET_URL%/}${p}" 2>/dev/null | tr '[:upper:]' '[:lower:]')
    if echo "$BODY" | grep -qiE "$LEAK_PATTERNS"; then
        MATCHED=$(echo "$BODY" | grep -oiE "$LEAK_PATTERNS" | head -1)
        log_finding "High" "W-029" "에러 정보 노출: ${p}" "패턴: $MATCHED"
    else
        log_ok "에러 노출 없음: ${p}"
    fi
done

# ── 8. 포트 스캔 (선택적 — nmap 있을 때만) ─────────────
section "포트 점검 (불필요한 포트 노출)"

if command -v nmap &>/dev/null; then
    DANGEROUS_PORTS="21,22,23,25,3306,5432,6379,27017,9200,5601,8080,8443,9090"
    echo "[*] nmap 포트 스캔 중... (잠시 대기)"
    NMAP_OUT=$(nmap -p "$DANGEROUS_PORTS" --open -T4 "$HOST" 2>/dev/null | \
        grep -E "^[0-9]+/tcp.*open" || true)
    if [[ -n "$NMAP_OUT" ]]; then
        while IFS= read -r line; do
            PORT=$(echo "$line" | awk '{print $1}')
            SVC=$(echo "$line" | awk '{print $3}')
            case "$PORT" in
                3306/tcp) log_finding "Critical" "W-002" "MySQL 포트 외부 노출" "$line" ;;
                5432/tcp) log_finding "Critical" "W-002" "PostgreSQL 포트 외부 노출" "$line" ;;
                6379/tcp) log_finding "Critical" "W-002" "Redis 포트 외부 노출" "$line" ;;
                27017/tcp) log_finding "Critical" "W-002" "MongoDB 포트 외부 노출" "$line" ;;
                9200/tcp) log_finding "High" "W-002" "Elasticsearch 포트 노출" "$line" ;;
                23/tcp)  log_finding "Critical" "W-047" "Telnet 포트 노출 — 평문 통신" "$line" ;;
                21/tcp)  log_finding "High" "W-047" "FTP 포트 노출" "$line" ;;
                *) log_finding "Medium" "W-002" "포트 오픈: ${PORT} (${SVC})" "$line" ;;
            esac
        done <<< "$NMAP_OUT"
    else
        log_ok "위험 포트 외부 노출 없음"
    fi
else
    echo "[주의] nmap 없음 — 포트 스캔 생략 (apt install nmap 권장)"
fi

# ── 9. robots.txt / 민감 경로 노출 ─────────────────────
section "W-029 robots.txt / 민감 경로 탐색"

ROBOTS=$(curl -sk --max-time 8 "${TARGET_URL%/}/robots.txt" 2>/dev/null)
if [[ -n "$ROBOTS" ]]; then
    DISALLOW=$(echo "$ROBOTS" | grep -i "disallow" | head -10 || true)
    if [[ -n "$DISALLOW" ]]; then
        log_finding "Medium" "W-029" "robots.txt Disallow 경로 노출" \
            "공격자가 내부 경로 파악에 활용 가능"
        echo "$DISALLOW" | head -5 | while IFS= read -r line; do
            echo "    $line"
        done
    else
        log_ok "robots.txt 존재하나 Disallow 없음"
    fi
else
    log_ok "robots.txt 없음"
fi

# ── 최종 요약 ─────────────────────────────────────────
section "점검 완료"
CRITICAL_COUNT=$(grep -c "\[Critical\]" "$REPORT_FILE" 2>/dev/null || echo 0)
HIGH_COUNT=$(grep -c "\[High\]" "$REPORT_FILE" 2>/dev/null || echo 0)
MEDIUM_COUNT=$(grep -c "\[Medium\]" "$REPORT_FILE" 2>/dev/null || echo 0)

echo -e "${RED}${BOLD}  Critical : ${CRITICAL_COUNT}${RESET}"
echo -e "${YELLOW}${BOLD}  High     : ${HIGH_COUNT}${RESET}"
echo -e "${CYAN}  Medium   : ${MEDIUM_COUNT}${RESET}"
echo ""
echo -e "${BOLD}  보고서 저장: ${REPORT_FILE}${RESET}"

echo "" >> "$REPORT_FILE"
echo "────────────────────────────────────────" >> "$REPORT_FILE"
echo "Critical: $CRITICAL_COUNT | High: $HIGH_COUNT | Medium: $MEDIUM_COUNT" >> "$REPORT_FILE"
echo "완료: $(date)" >> "$REPORT_FILE"