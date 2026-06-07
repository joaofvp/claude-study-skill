# Instruções de Configuração - PC do Trabalho

## O que foi feito

Foi criada uma skill do Claude Code chamada `/study` que analisa conversas e gera notas de estudo automáticas no Obsidian do PC de casa. O acesso remoto funciona via Cloudflare Worker (proxy autenticado) + Cloudflare Tunnel.

A conexão já foi testada e está funcionando: `curl.exe` no proxy retorna as pastas do vault.

## O que você precisa fazer

### Passo 1: Clonar o repo e rodar o setup

```powershell
cd $HOME
git clone https://github.com/joaofvp/claude-study-skill.git
cd claude-study-skill
.\setup.ps1
```

O setup vai pedir:
- **API Key:** digite qualquer coisa (ex: `x`). Não será usada.
- **Porta:** aperte Enter (padrão 27124). Não será usada.

O que importa é que ele cria `~/.claude/skills/study/SKILL.md`.

### Passo 2: Configurar o modo proxy

Abra o arquivo de config:

```powershell
notepad $HOME\.claude\obsidian-study-config.json
```

Apague todo o conteúdo e cole isso no lugar:

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

O campo importante é `"proxy": { "enabled": true }` — isso diz pra skill usar o Worker ao invés do localhost.

### Passo 3: Reiniciar o Claude Code

Feche completamente o Claude Code e abra de novo. A skill precisa ser redescoberta.

### Passo 4: Testar

Abra qualquer projeto no Claude Code, inicie uma conversa e digite:

```
/study
```

Se a skill foi descoberta, ela vai aparecer no autocomplete quando você digitar `/s`.

A skill vai analisar a conversa, extrair conceitos e criar notas no Obsidian do PC de casa.

## Teste de conexão (opcional)

Para confirmar que o proxy funciona antes de usar a skill:

```powershell
curl.exe -sk -H "Authorization: Bearer study-proxy-sk-6301b6c1a39a336d3ae6e4a5a1fd9599" "https://obsidian-capture.joaof-capture.workers.dev/obsidian/vault/"
```

Deve retornar um JSON com `"files": [...]` listando as pastas do vault.

## Como funciona

```
Este PC → /study skill → curl pro Worker → Worker adiciona API key do Obsidian
→ repassa pro tunnel → tunnel entrega no Obsidian do PC de casa
```

## Se não funcionar

- **Tunnel pode estar down:** O tunnel roda no PC de casa. Se o PC reiniciou e o Obsidian ainda não abriu, o tunnel não conecta. O startup script deve resolver isso automaticamente.
- **Skill não aparece:** Reinicie o Claude Code.
- **Erro 401:** Verifique se o config tem `"proxy.enabled": true` e a apiKey correta.
- **Erro 530:** Tunnel está down. PC de casa precisa estar com Obsidian aberto e tunnel rodando.
