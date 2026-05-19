#!/usr/bin/env bash
#
# Claude Study Skill - Setup Script
# Instala a skill /study globalmente no Claude Code
#
# Uso:
#   chmod +x setup.sh
#   ./setup.sh
#
# Ou em uma linha:
#   bash <(curl -sL https://raw.githubusercontent.com/joaofvp/claude-study-skill/main/setup.sh)
#

set -e

SKILL_NAME="study"
SKILL_DIR="$HOME/.claude/skills/$SKILL_NAME"
CONFIG_FILE="$HOME/.claude/obsidian-study-config.json"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== Claude Study Skill - Setup ==="
echo ""

# Criar diretório da skill
echo "[1/3] Instalando skill em $SKILL_DIR..."
mkdir -p "$SKILL_DIR"
cp "$SCRIPT_DIR/SKILL.md" "$SKILL_DIR/SKILL.md"
echo "   OK - SKILL.md copiado"

# Config
if [ -f "$CONFIG_FILE" ]; then
    echo ""
    echo "[2/3] Config ja existe em $CONFIG_FILE"
    echo "   Pulando. Se precisar atualizar, edite manualmente ou delete e rode novamente."
else
    echo ""
    echo "[2/3] Criando config..."
    echo ""
    echo "   Preciso de duas informacoes do seu Obsidian:"
    echo ""

    # API Key
    read -p "   API Key do Local REST Plugin: " API_KEY
    if [ -z "$API_KEY" ]; then
        echo "   ERRO: API Key obrigatoria. Rode novamente."
        exit 1
    fi

    # Porta
    read -p "   Porta (27124 para HTTPS, 27123 para HTTP) [27124]: " PORT
    PORT=${PORT:-27124}

    if [ "$PORT" = "27124" ]; then
        PROTOCOL="https"
    else
        PROTOCOL="http"
    fi

    # Criar config
    cat > "$CONFIG_FILE" << CONFIGEOF
{
  "obsidian": {
    "baseUrl": "$PROTOCOL://127.0.0.1:$PORT",
    "apiKey": "$API_KEY",
    "insecure": true
  },
  "vault": {
    "studyPath": "Study",
    "dailyPath": "Study/Daily",
    "conceptsPath": "Study/Concepts",
    "sessionsPath": "Study/Sessions",
    "indexPath": "Study/concepts_index.json",
    "mocPath": "Study/MOC - Mapa de Estudos.md"
  },
  "language": "pt-BR",
  "includeTechnicalTerms": true,
  "profile": "dev-em-formacao"
}
CONFIGEOF
    echo "   OK - Config criado em $CONFIG_FILE"
fi

# Verificar Obsidian
echo ""
echo "[3/3] Verificando conexao com Obsidian..."
BASE_URL=$(grep -o '"baseUrl": *"[^"]*"' "$CONFIG_FILE" | cut -d'"' -f4)
API_KEY=$(grep -o '"apiKey": *"[^"]*"' "$CONFIG_FILE" | cut -d'"' -f4)

if command -v curl &> /dev/null; then
    HTTP_CODE=$(curl -sk -o /dev/null -w "%{http_code}" -H "Authorization: Bearer $API_KEY" "$BASE_URL/vault/" 2>/dev/null || echo "000")
    if [ "$HTTP_CODE" = "200" ]; then
        echo "   OK - Obsidian respondendo!"
    else
        echo "   AVISO: Obsidian retornou HTTP $HTTP_CODE"
        echo "   Verifique se o Obsidian esta aberto e o Local REST Plugin esta ativo."
    fi
else
    echo "   AVISO: curl nao encontrado. Nao foi possivel testar a conexao."
fi

echo ""
echo "=== Setup completo! ==="
echo ""
echo "Proximos passos:"
echo "  1. Reinicie o Claude Code (a skill precisa ser redescoberta)"
echo "  2. Digite /study em qualquer conversa"
echo ""
