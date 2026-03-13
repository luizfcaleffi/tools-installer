#!/bin/bash
# ============================================================
# fix-chrome-extension.sh — Ativa extensao xOne xTension no Chrome
# Para maquinas que ja tem o xOne instalado mas faltou a extensao
# Execucao: sudo bash fix-chrome-extension.sh
# ============================================================

CHROME_EXT_ID="ofgdpbaonocecajlocljjeigbfnjleii"
CHROME_POLICY_DIR="/etc/opt/chrome/policies/managed"
POLICY_FILE="$CHROME_POLICY_DIR/xone_xtension.json"

if [[ $EUID -ne 0 ]]; then
    echo "Este script precisa ser executado como root (sudo)."
    exit 1
fi

# Verifica se o Chrome esta instalado
if ! command -v google-chrome &> /dev/null; then
    echo "ERRO: Google Chrome nao encontrado."
    exit 1
fi

# Verifica se a policy ja existe
if [[ -f "$POLICY_FILE" ]]; then
    echo "Policy ja existe em $POLICY_FILE"
    echo "Conteudo atual:"
    cat "$POLICY_FILE"
    echo ""
    echo "Se a extensao nao esta ativa, reinicie o Chrome."
    exit 0
fi

# Cria diretorio de policies e arquivo
mkdir -p "$CHROME_POLICY_DIR"
cat > "$POLICY_FILE" <<EOF
{
  "ExtensionInstallForcelist": [
    "${CHROME_EXT_ID};https://clients2.google.com/service/update2/crx"
  ]
}
EOF
chmod 644 "$POLICY_FILE"

echo "Policy criada em: $POLICY_FILE"
echo "Reinicie o Chrome para ativar a extensao xOne xTension."

# Verifica se a policy foi registrada
if google-chrome --policy-print 2>/dev/null | grep -q "$CHROME_EXT_ID"; then
    echo "OK: Extensao registrada nas policies do Chrome."
else
    echo "AVISO: Reinicie o Chrome e verifique em chrome://extensions/"
fi
