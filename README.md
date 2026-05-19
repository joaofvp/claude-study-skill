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

### Estrutura no Obsidian

```
Study/
  Daily/              <- Daily Digest (ponto de entrada diario)
  Concepts/           <- Notas atomicas (um conceito = uma nota)
  Sessions/           <- Notas por sessao de trabalho
  concepts_index.json <- Indice de deduplicacao
  MOC - Mapa de Estudos.md  <- Mapa central
```

## Instalacao

### Opcao 1: Clone + setup (recomendado)

```bash
git clone https://github.com/SEU_USER/claude-study-skill.git
cd claude-study-skill
bash setup.sh
```

No Windows PowerShell:
```powershell
git clone https://github.com/SEU_USER/claude-study-skill.git
cd claude-study-skill
.\setup.ps1
```

### Opcao 2: Manual

1. Copie `SKILL.md` para `~/.claude/skills/study/SKILL.md`
2. Copie `obsidian-study-config.example.json` para `~/.claude/obsidian-study-config.json`
3. Edite o config com sua API Key do Obsidian Local REST Plugin

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

## Notas

- A skill e **global** — funciona em qualquer projeto do Claude Code
- Notas sao deduplicadas automaticamente via indice JSON
- O conteudo e escrito em PT-BR com termos tecnicos em EN
- Estilo didatico com analogias do mundo real
