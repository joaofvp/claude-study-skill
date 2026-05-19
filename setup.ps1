# Claude Study Skill - Setup (Windows PowerShell)
#
# Uso:
#   .\setup.ps1
#
# Ou baixando direto:
#   irm https://raw.githubusercontent.com/SEU_USER/claude-study-skill/main/setup.ps1 | iex
#

$ErrorActionPreference = "Stop"

$SKILL_NAME = "study"
$SKILL_DIR = "$env:USERPROFILE\.claude\skills\$SKILL_NAME"
$CONFIG_FILE = "$env:USERPROFILE\.claude\obsidian-study-config.json"
$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host "=== Claude Study Skill - Setup ===" -ForegroundColor Cyan
Write-Host ""

# Criar diretorio da skill
Write-Host "[1/3] Instalando skill em $SKILL_DIR..." -ForegroundColor Yellow
New-Item -ItemType Directory -Path $SKILL_DIR -Force | Out-Null
Copy-Item "$SCRIPT_DIR\SKILL.md" "$SKILL_DIR\SKILL.md" -Force
Write-Host "   OK - SKILL.md copiado" -ForegroundColor Green

# Config
if (Test-Path $CONFIG_FILE) {
    Write-Host ""
    Write-Host "[2/3] Config ja existe em $CONFIG_FILE" -ForegroundColor Yellow
    Write-Host "   Pulando. Se precisar atualizar, delete e rode novamente." -ForegroundColor DarkGray
} else {
    Write-Host ""
    Write-Host "[2/3] Criando config..." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "   Preciso de duas informacoes do seu Obsidian:" -ForegroundColor White
    Write-Host ""

    $API_KEY = Read-Host "   API Key do Local REST Plugin"
    if ([string]::IsNullOrWhiteSpace($API_KEY)) {
        Write-Host "   ERRO: API Key obrigatoria." -ForegroundColor Red
        exit 1
    }

    $PORT = Read-Host "   Porta (27124 para HTTPS, 27123 para HTTP) [27124]"
    if ([string]::IsNullOrWhiteSpace($PORT)) { $PORT = "27124" }

    $PROTOCOL = if ($PORT -eq "27124") { "https" } else { "http" }

    $config = @"
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
"@

    $config | Out-File -FilePath $CONFIG_FILE -Encoding UTF8
    Write-Host "   OK - Config criado em $CONFIG_FILE" -ForegroundColor Green
}

# Verificar Obsidian
Write-Host ""
Write-Host "[3/3] Verificando conexao com Obsidian..." -ForegroundColor Yellow

$configContent = Get-Content $CONFIG_FILE -Raw
$baseUrl = if ($configContent -match '"baseUrl":\s*"([^"]*)"') { $Matches[1] } else { "" }
$apiKey = if ($configContent -match '"apiKey":\s*"([^"]*)"') { $Matches[1] } else { "" }

try {
    $headers = @{ "Authorization" = "Bearer $apiKey" }
    $response = Invoke-WebRequest -Uri "$baseUrl/vault/" -Headers $headers -SkipCertificateCheck -UseBasicParsing -ErrorAction Stop
    Write-Host "   OK - Obsidian respondendo! (HTTP $($response.StatusCode))" -ForegroundColor Green
} catch {
    Write-Host "   AVISO: Nao foi possivel conectar ao Obsidian." -ForegroundColor DarkYellow
    Write-Host "   Verifique se o Obsidian esta aberto e o Local REST Plugin esta ativo." -ForegroundColor DarkGray
}

Write-Host ""
Write-Host "=== Setup completo! ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Proximos passos:" -ForegroundColor White
Write-Host "  1. Reinicie o Claude Code (a skill precisa ser redescoberta)"
Write-Host "  2. Digite /study em qualquer conversa"
Write-Host ""
