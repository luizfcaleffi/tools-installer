#!/bin/bash
set -e

# ============================================================
# install-unlockusert.sh — Instalacao do xOne Agent (macOS)
# Baixa o .pkg do GitHub Releases, injeta token via /tmp/.xone_token
# Detecta arquitetura automaticamente (Apple Silicon / Intel)
# ============================================================

VERSION="2.6.1"
RELEASE_URL="https://github.com/luizfcaleffi/tools-installer/releases/download/v${VERSION}"
LOG_FILE="/tmp/unlockusert_install.log"
TOKEN_FILE="/tmp/.xone_token"
PKG_FILE=""
TOKEN="eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbiI6IjUxYmYxOTc1LWYxYTAtNGM4OC1iMDhiLTdkNTA2ZjZlMWZmMSIsImNvbXBhbnlfaWQiOjI0MCwiZGF0ZSI6IjIwMjYtMDEtMjBUMTI6MDQ6NDIuMTUzWiIsImlhdCI6MTc2ODkxMDY4Mn0.Fl41RP01qcue4r41rXnDhbKbGArWp_CqyfJDrXVXJr1K8ANs_u854vIMANRN_DjnfsYBdTW44UBP3scsqVyQzcyN2z_GeP-ZzVzdpCWIap4obhur5cQjsyyvUdm-dMbUvUoPasNHCo5ftirkyffuIBBA_b9HNG_-M-Af-VyXOJ3Yoq3iNETwcj2qpq1jJMPrbdVNgauUkaRwcJbaLW661tBA_adzeJTCVU_68LYRdxB7-WoS9jn1K7JcBUuaoRFKHcOY8tvKqYrb8ZpHJU4sJzpLj2AEOGaTOE3TTw5c5bho6mE8jsJpkoqit28cy5PixPZtEFNydN47CoczFWa27g"
AUTO_DOWNLOADED=false

# Detecta arquitetura
ARCH=$(uname -m)
case "$ARCH" in
    arm64)  PKG_NAME="xone-setup-${VERSION}-osx-arm64.pkg" ;;
    x86_64) PKG_NAME="xone-setup-${VERSION}-osx-x64.pkg" ;;
    *)
        echo "ERRO: Arquitetura nao suportada: $ARCH"
        exit 1
        ;;
esac

while [[ $# -gt 0 ]]; do
    case "$1" in
        --token)
            TOKEN="$2"
            shift 2
            ;;
        --pkg)
            PKG_FILE="$2"
            shift 2
            ;;
        --help)
            echo "Uso: sudo $0 [--token TOKEN] [--pkg /caminho/pacote.pkg]"
            echo ""
            echo "  --token TOKEN   Token JWT customizado (usa o padrao se nao informado)"
            echo "  --pkg CAMINHO   Caminho local do .pkg (pula download)"
            echo ""
            echo "Arquitetura detectada: $ARCH ($PKG_NAME)"
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
log "Inicio da instalacao do xOne Agent v${VERSION}"
log "Hostname: $(hostname)"
log "Arquitetura: $ARCH ($PKG_NAME)"

# [1/4] Localiza ou baixa o .pkg
log "[1/4] Localizando pacote .pkg..."
if [[ -n "$PKG_FILE" && -f "$PKG_FILE" ]]; then
    log "  Usando pacote informado: $PKG_FILE"
elif [[ -f "/tmp/${PKG_NAME}" ]]; then
    PKG_FILE="/tmp/${PKG_NAME}"
    log "  Pacote encontrado em $PKG_FILE"
else
    log "  Baixando ${PKG_NAME} do GitHub Releases..."
    PKG_FILE="/tmp/${PKG_NAME}"
    curl -L "${RELEASE_URL}/${PKG_NAME}" -o "$PKG_FILE" >> "$LOG_FILE" 2>&1

    if [[ -f "$PKG_FILE" ]]; then
        log "  OK: Download concluido ($(du -h "$PKG_FILE" | cut -f1))"
        AUTO_DOWNLOADED=true
    else
        log_erro "Falha no download do pacote"
        exit 1
    fi
fi

# [2/4] Configura o token via arquivo temporario
# macOS: o postinstall do .pkg le o token de /tmp/.xone_token
log "[2/4] Configurando token..."
echo -n "$TOKEN" > "$TOKEN_FILE"
log "  OK: Token gravado em $TOKEN_FILE"

# [3/4] Instalacao silenciosa
log "[3/4] Instalando xOne Agent v${VERSION}..."
installer -pkg "$PKG_FILE" -target / >> "$LOG_FILE" 2>&1

if [[ $? -eq 0 ]]; then
    log "  OK: Instalacao concluida com sucesso"
else
    log_erro "Falha na instalacao. Verifique o log: $LOG_FILE"
    rm -f "$TOKEN_FILE"
    exit 1
fi

# [4/4] Verificacao e limpeza
log "[4/4] Verificando instalacao..."

# Remove arquivo de token por seguranca
rm -f "$TOKEN_FILE"
log "  Token temporario removido"

# Verifica se o diretorio do agente foi criado
if [[ -d "/Library/xone-agent" ]]; then
    log "  OK: Diretorio /Library/xone-agent presente"
else
    log "  AVISO: Diretorio /Library/xone-agent nao encontrado"
fi

# Remove o .pkg se foi download automatico
if [[ "$AUTO_DOWNLOADED" == true ]]; then
    rm -f "$PKG_FILE"
    log "  Pacote .pkg removido"
fi

# Resumo
log "========================================="
log "INSTALACAO CONCLUIDA"
log "  Software: xOne Agent v${VERSION}"
log "  Arch:     $ARCH"
log "  Log:      $LOG_FILE"
log "========================================="
log ""
log "NOTA: Sem MDM, o usuario precisara aprovar permissoes de Accessibility"
log "      em System Settings > Privacy & Security > Accessibility"
