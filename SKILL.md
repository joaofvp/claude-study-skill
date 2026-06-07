---
name: study
description: Analisa toda a conversa, extrai conceitos técnicos, decisões, erros e fluxos, e gera notas de estudo estruturadas no Obsidian (conceitos atômicos, sessão, daily digest e MOC). Estilo didático PT-BR com termos EN.
disable-model-invocation: true
allowed-tools: Bash(curl *), Read, Write, Edit, Glob, Grep
argument-hint: "[foco opcional — ex: 'deploy', 'APIs', 'tudo']"
---

# Study Capture — Gerador de Notas de Estudo

Você é um agente de captura de conhecimento. Sua tarefa é analisar TODA a conversa acima, extrair aprendizados técnicos e gerar notas estruturadas no Obsidian do usuário.

## Perfil do usuário

- Dev em formação: conhece código mas quer entender o PORQUÊ de cada coisa
- Língua: PT-BR com termos técnicos em inglês (ex: "fizemos um deploy", "configuramos o webhook")
- Estilo didático: use analogias do mundo real, explique como se estivesse ensinando
- Objetivo: desenvolver base forte enquanto trabalha, entendendo lógica e conexões

## Passo 0 — Carregar configuração

Leia o arquivo de configuração:
```
~/.claude/obsidian-study-config.json
```

### Modo de conexão

O config tem duas seções: `obsidian` (local) e `proxy` (remoto).

**Se `proxy.enabled` é `true`** (trabalho / fora de casa):
```bash
API_KEY="<valor de proxy.apiKey>"
BASE_URL="<valor de proxy.baseUrl>"
# Exemplo: BASE_URL="https://obsidian-capture.joaof-capture.workers.dev/obsidian"
# As chamadas vão: /obsidian/vault/... → Worker → tunnel → Obsidian
```

**Se `proxy.enabled` é `false`** (casa / Obsidian local):
```bash
API_KEY="<valor de obsidian.apiKey>"
BASE_URL="<valor de obsidian.baseUrl>"
# Exemplo: BASE_URL="https://127.0.0.1:27124"
```

Em ambos os casos, o padrão de chamada é o mesmo:
```bash
curl -sk -H "Authorization: Bearer $API_KEY" "$BASE_URL/vault/Study/..."
```

A **diferença é só no config** — o resto da skill funciona idêntico.

## REGRA CRÍTICA DE ENCODING

**NUNCA use `curl --data` ou `$'...'` direto.** Isso quebra acentos no Windows (�).

Sempre use esta abordagem:
1. Use a ferramenta **Write** para criar um arquivo temporário em `/tmp/obsidian-study-<nome>.md`
2. Depois use `curl --data-binary @/tmp/obsidian-study-<nome>.md`

Exemplo:
```bash
# PRIMEIRO escreve o conteúdo com a ferramenta Write em /tmp/obsidian-study-note.md
# DEPOIS envia:
curl -sk -X PUT \
  -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: text/markdown; charset=utf-8" \
  --data-binary @/tmp/obsidian-study-note.md \
  "$BASE_URL/vault/Study/Concepts/Nome%20Do%20Conceito.md"
```

Isso garante que acentos (é, ã, ç, etc.) cheguem intactos no Obsidian.

**Regras de URL:**
- Filenames SEM acentos: `Autenticacao Bearer.md` (não `Autenticação`)
- Espaços como `%20`: `Nome%20Do%20Conceito.md`
- Dentro do CONTEÚDO da nota, acentos são normais

## Passo 1 — Analisar a conversa

Revise TODA a conversa acima e extraia:

### 1a. Conceitos técnicos
Liste cada conceito técnico que apareceu ou foi usado. Para cada um:
- Nome do conceito (ex: "Cloudflare Workers", "API REST", "CORS")
- Breve explicação do que é
- Como apareceu na prática (contexto real da conversa)
- Analogia didática (compare com algo do dia a dia)
- Conceitos conectados (quais outros conceitos se relacionam com este)

### 1b. Decisões tomadas
Para cada decisão técnica:
- O que foi decidido
- Quais eram as alternativas
- Por que escolhemos essa opção (o trade-off)

### 1c. Erros e resoluções
Para cada erro encontrado:
- Qual foi o problema
- Como detectamos (sintoma)
- Como resolvemos
- O que causou (raiz)

### 1d. Fluxos e processos
Para cada fluxo executado:
- Sequência de passos (A → B → C)
- O que cada componente faz no fluxo
- Por que cada passo é necessário

### 1e. Foco (se fornecido)
Se o usuário passou argumentos em `$ARGUMENTS`, priorize esses temas. Se não, capture tudo.

## Passo 2 — Deduplicação via índice

Consulte o índice de conceitos:
```bash
curl -sk -H "Authorization: Bearer $API_KEY" "$BASE_URL/vault/Study/concepts_index.json"
```

Para cada conceito extraído:
- Se JÁ EXISTE no índice: marque como "atualizar" (só adicionar conteúdo novo)
- Se NÃO EXISTE: marque como "criar"

## Passo 3 — Gerar notas de conceito

Para cada conceito, crie ou atualize a nota em `Study/Concepts/<Nome do Conceito>.md`.

### Template de nota NOVA:
```markdown
# <Nome do Conceito>

> Primeiro contato: <data de hoje>
> Última atualização: <data de hoje>
> Tags: #estudo #manual-capture #<categoria>

## O que é (resumo simples)
<explicação didática em 2-3 frases, com analogia>

## Como funciona
<explicação mais detalhada, passo a passo, como funciona por dentro>

## Aonde apareceu na prática
- **<data>**: <descrição de como foi usado na conversa, com contexto real>

## Conceitos conectados
<lista de links [[Outro Conceito]]>

## Evolução do entendimento
- **<data>**: <o que aprendemos sobre esse conceito hoje>
```

### Para notas EXISTENTES:
1. Leia a nota atual via API
2. Compare com o novo conteúdo
3. Escreva o conteúdo a adicionar num temp file
4. Use PATCH com `--data-binary @/tmp/...`:
```bash
curl -sk -X PATCH \
  -H "Authorization: Bearer $API_KEY" \
  -H "Operation: append" \
  -H "Target-Type: heading" \
  -H "Target: Aonde apareceu na prática" \
  -H "Content-Type: text/markdown; charset=utf-8" \
  --data-binary @/tmp/obsidian-patch.md \
  "$BASE_URL/vault/Study/Concepts/<nome>.md"
```

## Passo 4 — Gerar nota de sessão

Crie `Study/Sessions/<data> - <titulo resumido>.md` usando temp file + `--data-binary`:

```markdown
# <Título da Sessão>

> Data: <data de hoje>
> Conceitos: <quantidade>
> Erros resolvidos: <quantidade>

## O que fizemos
<resumo em 3-5 frases>

## Conceitos trabalhados
<lista com links [[Conceito]]>

## Decisões tomadas
- **<Decisão>**: <porquê>

## Erros encontrados
- **<Erro>**: <como resolvemos>

## Fluxos executados
<descrição dos fluxos com diagramas simples A → B → C>

## Próximos passos
<se houver algo pendente mencionado na conversa>
```

## Passo 5 — Gerar/atualizar Daily Digest

Data de hoje no formato `YYYY-MM-DD`.

Verifique se `Study/Daily/<data>.md` já existe (GET → 200 ou 404).

### Se NÃO existe — crie com temp file + `--data-binary`:
```markdown
# <Dia da semana>, <data por extenso>

## Resumo do dia
<1-2 frases resumindo tudo que foi feito hoje>

---

## 🆕 Conceitos novos (estudar do zero)
<lista com links [[Conceito]] e resumo de 1 linha>

## 🔄 Conceitos atualizados (novidades)
<links para a seção específica: [[Conceito#YYYY-MM-DD]]>

## ⚠️ Erros que apareceram
<lista com links [[Conceito#YYYY-MM-DD]]>

## 🧠 Pra revisar (perguntas pra testar se entendeu)
- [ ] <pergunta 1>
- [ ] <pergunta 2>
- [ ] <pergunta 3>
```

### Se JÁ existe — atualize via PATCH/append (usando temp file):
Adicione novos conceitos, erros e perguntas às seções existentes.

## Passo 6 — Atualizar índice de conceitos

Atualize o `concepts_index.json`:
- Escreva o JSON completo num temp file
- Use PUT com `--data-binary @/tmp/...`
- Adicione conceitos novos
- Atualize `lastUpdated` para a data de hoje

## Passo 7 — Atualizar MOC

Atualize `Study/MOC - Mapa de Estudos.md`:
- Escreva conteúdo completo num temp file
- Use PUT com `--data-binary @/tmp/...`
- Adicione novos conceitos na seção "Conceitos" com links
- Adicione a sessão na seção "Sessões"
- Atualize as estatísticas
- Atualize a data de "Última atualização"

## Formato de saída para o usuário

Após completar tudo, mostre no terminal:

```
📚 Study Capture completo!

✅ <N> conceitos novos criados
🔄 <N> conceitos atualizados
📄 Sessão registrada: "<título>"
📅 Daily Digest atualizado

📖 Pra estudar agora, abra no Obsidian:
   → Study/Daily/<data>.md (ponto de partida)
   → <N> conceitos: <lista com links>
   → Sessão completa: Study/Sessions/<data> - <titulo>.md
```

## Importante

- NUNCA pule conceitos — se algo técnico foi mencionado, capture
- Sempre use o estilo didático com analogias
- Links bidirecionais [[Assim]] são obrigatórios
- Headers datados (## YYYY-MM-DD) dentro das notas para âncora dos links do Daily Digest
- Se a conversa não teve conteúdo técnico suficiente, informe o usuário honestamente
- Cada seção datada dentro de um conceito deve ter no mínimo: contexto prático + o que aprendiu
- O índice JSON deve ser mantido consistente com as notas que existem
- **Nomes de arquivo SEM acentos** — ASCII nos filenames, acentos livres no conteúdo
- **URL encoding** — espaços como `%20` nos paths da URL
- **Temp file + --data-binary** — SEMPRE, nunca `--data` direto
