# Instruções de Configuração - PC Remoto (trabalho, notebook, etc)

## Visão geral

São DUAS skills do Claude Code que geram notas de estudo no Obsidian do PC principal (casa):

| Skill | Como ativa | O que faz |
|---|---|---|
| **`/study`** (manual) | Usuario digita `/study` | Analise completa: conceitos + sessao + daily digest + MOC + perguntas de revisao |
| **`auto-study`** (automatica) | Claude detecta tarefa tecnica completada | Captura leve: so conceitos novos + daily digest. Sem sessao, sem MOC |

No Obsidian, as notas geradas pela captura automatica tem a tag `#auto-capture`. As notas do `/study` manual tem a tag `#manual-capture`. Assim voce consegue filtrar no Obsidian o que foi capturado de cada forma.

## Arquitetura

```
Este PC → skill /study ou auto-study → curl pro Worker
→ Worker adiciona API key real do Obsidian
→ repassa pro tunnel (obsidian.joaofvp.win)
→ tunnel entrega no Obsidian do PC de casa
```

O tunnel é **estavel** — usa Cloudflare Named Tunnel com dominio proprio. Sobe automaticamente via Agendador de Tarefas quando o PC de casa liga. O dominio nunca muda.

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

```json
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

## Tags no Obsidian

| Tag | Significado |
|---|---|
| `#auto-capture` | Capturado automaticamente pelo Claude |
| `#manual-capture` | Capturado manualmente via `/study` |

No Obsidian, voce pode filtrar por tag para ver so o que foi auto-capturado ou so o que voce pediu manualmente.

## Se nao funcionar

- **Skill nao aparece:** Reinicie o Claude Code.
- **Auto-capture nao dispara:** Verifique se o CLAUDE.md global tem a instrucao de auto-capture.
- **Erro 401:** Verifique se o config tem `"proxy.enabled": true` e a apiKey correta.
- **Erro 530 ou sem resposta:** O PC de casa precisa estar ligado com Obsidian aberto. O tunnel sobe automaticamente via Agendador de Tarefas do Windows.
- **Erro de conexao geral:** Verifique se o PC de casa esta acessivel (obsidian.joaofvp.win responde).
