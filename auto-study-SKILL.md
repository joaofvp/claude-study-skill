---
name: auto-study
description: Captura leve e automatica de conceitos tecnicos durante a conversa. Atualiza notas de conceito e Daily Digest no Obsidian sem intervencao do usuario.
disable-model-invocation: false
user-invocable: false
allowed-tools: Bash(curl *), Read, Write, Edit
---

# Auto-Study Capture (leve, automatico)

Voce foi ativado para fazer uma captura leve de conhecimento. Nao interrompa o fluxo da conversa — seja rapido e silencioso.

## O que fazer

Analise a conversa ate agora e extraia APENAS:

1. **Conceitos tecnicos novos** que apareceram
2. **Erros e resolucoes** que ocorreram
3. **Decisoes tecnicas** tomadas

Nao gere nota de sessao. Nao atualize o MOC. So conceitos + daily digest.

## Config

Leia `~/.claude/obsidian-study-config.json` para obter API_KEY e BASE_URL (respeite proxy.enabled).

## Encoding

SEMPRE use Write + `--data-binary @file`. Nunca `curl --data`.
Filenames SEM acentos. Espacos como `%20`.

## Passos

### 1. Leia o indice de conceitos

```bash
curl -sk -H "Authorization: Bearer $API_KEY" "$BASE_URL/vault/Study/concepts_index.json"
```

### 2. Para cada conceito novo ou atualizado

Se nao existe no indice — crie nota em `Study/Concepts/<Nome>.md`:

```markdown
# <Nome do Conceito>

> Primeiro contato: <data>
> Ultima atualizacao: <data>
> Tags: #estudo #<categoria>

## O que e (resumo simples)
<2-3 frases com analogia>

## Aonde apareceu na pratica
- **<data>**: <como apareceu na conversa>

## Conceitos conectados
<lista [[Outro Conceito]]>

## Evolucao do entendimento
- **<data>**: <o que aprendemos>
```

Se ja existe — so adicione nova entrada em "Aonde apareceu na pratica" e "Evolucao do entendimento" via PATCH:

```bash
# Escreva o conteudo novo num temp file, depois:
curl -sk -X PATCH \
  -H "Authorization: Bearer $API_KEY" \
  -H "Operation: append" \
  -H "Target-Type: heading" \
  -H "Target: Aonde apareceu na pratica" \
  -H "Content-Type: text/markdown; charset=utf-8" \
  --data-binary @/tmp/obsidian-patch.md \
  "$BASE_URL/vault/Study/Concepts/<nome>.md"
```

### 3. Atualize o Daily Digest

Verifique se `Study/Daily/<data>.md` existe (GET → 200/404).

Se existe — faca PATCH/append nas secoes relevantes (conceitos novos, erros, perguntas de revisao).

Se nao existe — crie com PUT:

```markdown
# <Dia da semana>, <data por extenso>

## Resumo do dia
<1-2 frases>

---

## Novos conceitos
<lista com [[Conceito]] e resumo de 1 linha>

## Conceitos atualizados
<links [[Conceito#data]]>

## Erros que apareceram
<lista com links>

## Revisar
- [ ] <pergunta 1>
- [ ] <pergunta 2>
```

### 4. Atualize o indice

Atualize `Study/concepts_index.json` com novos conceitos via PUT (escreva temp file + `--data-binary`).

## Importante

- Se a conversa nao teve conteudo tecnico relevante, NAO faca nada. Retorne silenciosamente.
- Maximo de 5 conceitos por captura — priorize os mais importantes.
- Seja rapido. O usuario nao pediu isso, estamos capturando em segundo plano.
- Nao mostre output detalhado. Se tudo deu certo, so retorne: "Auto-capture: <N> conceitos salvos."
- Se der erro, nao interrompa a conversa. Retorne silenciosamente.
