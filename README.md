# Claude Study Skill

Skill do Claude Code que analisa conversas e gera notas de estudo automaticamente no Obsidian.

## O que faz

Ao digitar `/study` no Claude Code, a skill:

1. Analisa toda a conversa e extrai conceitos, decisoes, erros e fluxos
2. Consulta um indice de deduplicacao
3. Cria/atualiza notas atomicas por conceito no Obsidian
4. Gera uma nota de sessao
5. Cria/atualiza o Daily Digest (resumo do dia com links)
6. Atualiza o MOC (Map of Content) e o indice

Tambem tem o **auto-study** — captura leve e automatica que roda sem intervencao ao completar tarefas tecnicas.

### Estrutura no Obsidian

```
Study/
  Daily/              <- Daily Digest (ponto de entrada diario)
  Concepts/           <- Notas atomicas (um conceito = uma nota)
  Sessions/           <- Notas por sessao de trabalho
  concepts_index.json <- Indice de deduplicacao
  MOC - Mapa de Estudos.md  <- Mapa central
```

### Tags

| Tag | Significado |
|---|---|
| `#auto-capture` | Capturado automaticamente |
| `#manual-capture` | Capturado via `/study` |

## Instalacao

### Modo local (Obsidian no mesmo PC)

Clone e rode o setup:

```bash
git clone https://github.com/joaofvp/claude-study-skill.git
cd claude-study-skill
bash setup.sh       # Linux/Mac
.\setup.ps1         # Windows PowerShell
```

Ou manual:
1. Copie `SKILL.md` para `~/.claude/skills/study/SKILL.md`
2. Copie `obsidian-study-config.example.json` para `~/.claude/obsidian-study-config.json`
3. Edite o config com sua API Key do Obsidian Local REST Plugin

### Modo remoto (Obsidian em outro PC)

Siga as instrucoes em [SETUP-WORK.md](SETUP-WORK.md).

## Requisitos

- [Claude Code](https://claude.ai/code) instalado
- [Obsidian](https://obsidian.md) com o [Local REST API plugin](https://github.com/coddingtonbear/obsidian-local-rest-api) instalado e ativo
- `curl` disponivel no terminal

## Configuracao do Obsidian

1. Abra Obsidian > Settings > Community Plugins > Local REST API
2. Copie a API Key mostrada la
3. Use essa chave no setup ou no config file

## Uso

Em qualquer conversa do Claude Code, digite:

```
/study
```

Ou com foco em um tema especifico:

```
/study deploy
/study APIs
```

## Auto-capture

Para captura automatica, instale a skill `auto-study`:

```bash
mkdir -p ~/.claude/skills/auto-study
cp auto-study-SKILL.md ~/.claude/skills/auto-study/SKILL.md
```

E adicione ao `~/.claude/CLAUDE.md`:

```markdown
## Auto-capture de conhecimento

Ao completar tarefas tecnicas significativas, ative a skill `auto-study` para capturar conceitos automaticamente.
```

## Notas

- A skill e **global** — funciona em qualquer projeto do Claude Code
- Notas sao deduplicadas automaticamente via indice JSON
- O conteudo e escrito em PT-BR com termos tecnicos em EN
- Estilo didatico com analogias do mundo real
