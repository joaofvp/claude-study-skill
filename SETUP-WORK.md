# Instruções de Configuração - PC do Trabalho

## O que foi feito

Foram criadas DUAS skills do Claude Code que geram notas de estudo no Obsidian do PC de casa:

| Skill | Como ativa | O que faz |
|---|---|---|
| **`/study`** (manual) | Usuario digita `/study` | Analise completa: conceitos + sessao + daily digest + MOC + perguntas de revisao |
| **`auto-study`** (automatica) | Claude detecta tarefa tecnica completada | Captura leve: so conceitos novos + daily digest. Sem sessao, sem MOC |

No Obsidian, as notas geradas pela captura automatica tem a tag `#auto-capture`. As notas do `/study` manual tem a tag `#manual-capture`. Assim voce consegue filtrar no Obsidian o que foi capturado de cada forma.

O acesso remoto funciona via Cloudflare Worker (proxy autenticado) + Cloudflare Tunnel.

## O que voce precisa fazer

### Passo 1: Clonar o repo e rodar o setup

```powershell
cd $HOME
git clone https://github.com/joaofvp/claude-study-skill.git
cd claude-study-skill
.\setup.ps1
```

O setup vai pedir:
- **API Key:** digite qualquer coisa (ex: `x`). Nao sera usada.
- **Porta:** aperte Enter (padrao 27124). Nao sera usada.

O que importa e que ele cria `~/.claude/skills/study/SKILL.md`.

### Passo 2: Instalar a skill de auto-capture

```powershell
mkdir -Force "$HOME\.claude\skills\auto-study"
Copy-Item "auto-study-SKILL.md" "$HOME\.claude\skills\auto-study\SKILL.md"
```

### Passo 3: Configurar o modo proxy

Abra o arquivo de config:

```powershell
notepad $HOME\.claude\obsidian-study-config.json
```

Apague todo o conteudo e cole isso no lugar:

```
{
  "obsidian": {
    "baseUrl": "https://127.0.0.1:27124",
    "apiKey": "nao-usado",
    "insecure": true
  },
  "proxy": {
    "enabled": true,
    "baseUrl": "https://obsidian-capture.joaof-capture.workers.dev/obsidian",
    "apiKey": "study-proxy-sk-6301b6c1a39a336d3ae6e4a5a1fd9599"
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
```

Salve e feche o notepad.

O campo importante e `"proxy": { "enabled": true }` — isso diz pra skill usar o Worker ao inves do localhost.

### Passo 4: Configurar o auto-capture

Para o Claude ativar o auto-study automaticamente, adicione uma instrucao no CLAUDE.md global.

Abra (crie se nao existir):

```powershell
notepad $HOME\.claude\CLAUDE.md
```

Adicione este conteudo:

```markdown
## Auto-capture de conhecimento

Ao completar tarefas tecnicas significativas (resolver bugs, implementar features, configurar infraestrutura, fazer deploys), ative a skill `auto-study` para capturar conceitos e salvar no Obsidian automaticamente.

Nao faca isso para tarefas triviais (typo fixes, renames, etc). Priorize momentos onde houve aprendizado real.
```

### Passo 5: Reiniciar o Claude Code

Feche completamente o Claude Code e abra de novo. As skills precisam ser redescobertas.

### Passo 6: Testar

**Teste manual:** abra qualquer projeto no Claude Code e digite:

```
/study
```

A skill vai aparecer no autocomplete quando voce digitar `/s`.

**Teste automatico:** faca uma tarefa tecnica com o Claude (ex: criar uma funcao, resolver um bug). Ao completar, o Claude deve ativar o auto-study sozinho e salvar os conceitos no Obsidian.

## Teste de conexao (opcional)

Para confirmar que o proxy funciona antes de usar a skill:

```powershell
curl.exe -sk -H "Authorization: Bearer study-proxy-sk-6301b6c1a39a336d3ae6e4a5a1fd9599" "https://obsidian-capture.joaof-capture.workers.dev/obsidian/vault/"
```

Deve retornar um JSON com `"files": [...]` listando as pastas do vault.

## Como funciona

```
Este PC → /study ou auto-study → curl pro Worker → Worker adiciona API key do Obsidian
→ repassa pro tunnel → tunnel entrega no Obsidian do PC de casa
```

## Tags no Obsidian

| Tag | Significado |
|---|---|
| `#auto-capture` | Capturado automaticamente pelo Claude |
| `#manual-capture` | Capturado manualmente via `/study` |

No Obsidian, voce pode filtrar por tag para ver so o que foi auto-capturado ou so o que voce pediu manualmente.

## Se nao funcionar

- **Tunnel pode estar down:** O tunnel roda no PC de casa. Se o PC reiniciou e o Obsidian ainda nao abriu, o tunnel nao conecta. O startup script deve resolver isso automaticamente.
- **Skill nao aparece:** Reinicie o Claude Code.
- **Auto-capture nao dispara:** Verifique se o CLAUDE.md global tem a instrucao de auto-capture.
- **Erro 401:** Verifique se o config tem `"proxy.enabled": true` e a apiKey correta.
- **Erro 530:** Tunnel esta down. PC de casa precisa estar com Obsidian aberto e tunnel rodando.
