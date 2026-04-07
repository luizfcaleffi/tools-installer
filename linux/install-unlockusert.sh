#!/bin/bash
set -e

# ============================================================
# install-unlockusert.sh — Instalacao do xOne Agent (Linux)
# Baixa o .deb do GitHub Releases e instala com token JWT
# ============================================================

VERSION="2.6.1"
RELEASE_URL="https://github.com/luizfcaleffi/tools-installer/releases/download/v${VERSION}"
DEB_FILE="/tmp/unlockusert-setup-${VERSION}-x64.deb"
LOG_FILE="/var/log/unlockusert_install.log"
CHROME_EXT_ID="ofgdpbaonocecajlocljjeigbfnjleii"
CHROME_POLICY_DIR="/etc/opt/chrome/policies/managed"
SKIP_DEPS=false
SKIP_CHROME=false
TOKEN="eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbiI6IjUxYmYxOTc1LWYxYTAtNGM4OC1iMDhiLTdkNTA2ZjZlMWZmMSIsImNvbXBhbnlfaWQiOjI0MCwiZGF0ZSI6IjIwMjYtMDEtMjBUMTI6MDQ6NDIuMTUzWiIsImlhdCI6MTc2ODkxMDY4Mn0.Fl41RP01qcue4r41rXnDhbKbGArWp_CqyfJDrXVXJr1K8ANs_u854vIMANRN_DjnfsYBdTW44UBP3scsqVyQzcyN2z_GeP-ZzVzdpCWIap4obhur5cQjsyyvUdm-dMbUvUoPasNHCo5ftirkyffuIBBA_b9HNG_-M-Af-VyXOJ3Yoq3iNETwcj2qpq1jJMPrbdVNgauUkaRwcJbaLW661tBA_adzeJTCVU_68LYRdxB7-WoS9jn1K7JcBUuaoRFKHcOY8tvKqYrb8ZpHJU4sJzpLj2AEOGaTOE3TTw5c5bho6mE8jsJpkoqit28cy5PixPZtEFNydN47CoczFWa27g"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --token)
            TOKEN="$2"
            shift 2
            ;;
        --skip-deps)
            SKIP_DEPS=true
            shift
            ;;
        --skip-chrome)
            SKIP_CHROME=true
            shift
            ;;
        --help)
            echo "Uso: sudo $0 [--token TOKEN] [--skip-deps] [--skip-chrome]"
            echo ""
            echo "  --token TOKEN   Token JWT customizado (usa o padrao se nao informado)"
            echo "  --skip-deps     Pula a instalacao de dependencias"
            echo "  --skip-chrome   Pula a policy da extensao Chrome"
            exit 0
            ;;
        *)
            echo "Argumento desconhecido: $1"
            echo "Use --help para ver as opcoes"
            exit 1
            ;;
    esac
done

log() {
    local msg="[$(date '+%Y-%m-%d %H:%M:%S')] $1"
    echo "$msg" | tee -a "$LOG_FILE"
}

log_erro() {
    local msg="[$(date '+%Y-%m-%d %H:%M:%S')] ERRO: $1"
    echo "$msg" | tee -a "$LOG_FILE" >&2
}

# Verifica root
if [[ $EUID -ne 0 ]]; then
    echo "Este script precisa ser executado como root (sudo)."
    exit 1
fi

echo "========================================" >> "$LOG_FILE"
log "Inicio da instalacao do UnlockUserT v${VERSION}"
log "Hostname: $(hostname)"

# [1/5] Dependencias
if [[ "$SKIP_DEPS" == false ]]; then
    log "[1/5] Instalando dependencias (xdotool, xdo, xorg, dotnet-runtime-8.0, jq)..."
    apt update >> "$LOG_FILE" 2>&1
    apt install -y xdo xdotool xorg dotnet-runtime-8.0 jq >> "$LOG_FILE" 2>&1

    if [[ $? -eq 0 ]]; then
        log "  OK: Dependencias instaladas"
    else
        log_erro "Falha ao instalar dependencias. Verifique o log: $LOG_FILE"
        exit 1
    fi
else
    log "[1/5] Dependencias ignoradas (--skip-deps)"
fi

# [2/5] Download do .deb
log "[2/5] Baixando pacote .deb..."
if [[ -f "$DEB_FILE" ]]; then
    log "  Pacote ja existe em $DEB_FILE, pulando download"
else
    wget -q "${RELEASE_URL}/unlockusert-setup-${VERSION}-x64.deb" -O "$DEB_FILE" >> "$LOG_FILE" 2>&1

    if [[ -f "$DEB_FILE" ]]; then
        log "  OK: Download concluido ($(du -h "$DEB_FILE" | cut -f1))"
    else
        log_erro "Falha no download do pacote"
        exit 1
    fi
fi

# [3/5] Instalacao com token via variavel de ambiente
log "[3/5] Instalando UnlockUserT v${VERSION} com token via env..."
TOKEN="$TOKEN" DEBIAN_FRONTEND=noninteractive dpkg -i "$DEB_FILE" >> "$LOG_FILE" 2>&1

if [[ $? -eq 0 ]]; then
    log "  OK: Instalacao concluida com sucesso"
else
    # Tenta corrigir dependencias quebradas e reinstalar
    log "  AVISO: dpkg reportou erro, tentando corrigir dependencias..."
    apt install -f -y >> "$LOG_FILE" 2>&1
    TOKEN="$TOKEN" DEBIAN_FRONTEND=noninteractive dpkg -i "$DEB_FILE" >> "$LOG_FILE" 2>&1

    if [[ $? -eq 0 ]]; then
        log "  OK: Instalacao concluida apos correcao de dependencias"
    else
        log_erro "Falha na instalacao. Verifique o log: $LOG_FILE"
        exit 1
    fi
fi

# [4/5] Verificacao do token no config
log "[4/5] Verificando token no config..."
CONFIG_FILE="/usr/local/etc/xone-agent.config"
if [[ -f "$CONFIG_FILE" ]]; then
    SAVED_TOKEN=$(jq -r '.AgentToken // empty' "$CONFIG_FILE" 2>/dev/null)
    if [[ -n "$SAVED_TOKEN" ]]; then
        log "  OK: Token gravado em $CONFIG_FILE"
    else
        log_erro "Token NAO foi gravado no config. Verifique manualmente."
    fi
else
    log "  AVISO: Config nao encontrado em $CONFIG_FILE"
fi

# [5/5] Extensao Chrome (xOne xTension) via policy de instalacao forcada
if [[ "$SKIP_CHROME" == false ]]; then
    log "[5/5] Configurando extensao xOne xTension no Chrome..."
    if command -v google-chrome &> /dev/null; then
        mkdir -p "$CHROME_POLICY_DIR"
        cat > "$CHROME_POLICY_DIR/xone_xtension.json" <<POLICY
{
  "ExtensionInstallForcelist": [
    "${CHROME_EXT_ID};https://clients2.google.com/service/update2/crx"
  ]
}
POLICY
        chmod 644 "$CHROME_POLICY_DIR/xone_xtension.json"
        log "  OK: Policy criada em $CHROME_POLICY_DIR/xone_xtension.json"
        log "  Extensao sera instalada automaticamente no proximo restart do Chrome"
    else
        log "  AVISO: Google Chrome nao encontrado, pulando extensao"
    fi
else
    log "[5/5] Extensao Chrome ignorada (--skip-chrome)"
fi

# [6/6] Validacao dos processos do agente
log "[6/6] Aguardando inicializacao dos processos do agente (10s)..."
sleep 10

# Componentes esperados no path do agente
EXPECTED_COMPONENTS=(
    "EventSender"
    "HeartBeat"
    "LicenseManager"
    "ProcessRunner"
    "UpdateManager"
)
PROC_FAILED=0
for component in "${EXPECTED_COMPONENTS[@]}"; do
    if pgrep -f "xone-agent/Components/${component}" > /dev/null 2>&1; then
        log "  OK: XOne Agent ${component}"
    else
        log_erro "  AUSENTE: XOne Agent ${component}"
        PROC_FAILED=$((PROC_FAILED + 1))
    fi
done

if [[ $PROC_FAILED -eq 0 ]]; then
    log "  Validacao concluida: todos os processos do agente ativos"
else
    log_erro "  Validacao: $PROC_FAILED processo(s) ausente(s) — verificar manualmente"
fi

# Limpeza
log "Limpeza: removendo $DEB_FILE"
rm -f "$DEB_FILE"

# Resumo
log "========================================="
log "INSTALACAO CONCLUIDA"
log "  Software: UnlockUserT v${VERSION}"
log "  Log:      $LOG_FILE"
log "========================================="
