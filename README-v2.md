# 👁 EYE GATE v2 — "KEYHOLE"

**Aplicativo Windows de reconhecimento facial para o controle de entrada e saída escolar.**

Identidade visual **Bauhaus**: papel `#F7F7EC`, tinta `#17140F`, vinho `#B21236`, vermelho `#F03812`, laranja `#FE8826`, âmbar `#FEB914`, teal `#2C9FA2` — formas geométricas, bordas grossas e sombras duras. Playfair Display + Space Grotesk (embutidas, zero CDN).

---

## 📦 O que tem aqui

| Pasta/arquivo | O que é |
|---|---|
| `docs/index.html` | **O SITE** — um arquivo só, sem login, sem banco. Apresenta o projeto e aponta o download do instalador (GitHub Pages) |
| `index.html` + `css/` + `js/` | **O app de verdade** (login, dashboard, monitor, cadastro…) |
| `electron/main.js` + `package.json` | Wrapper desktop (Electron): janela própria, câmera liberada, sem navegador |
| `installer/eye-gate-installer.nsi` | Script do instalador Windows (NSIS) |
| `.github/workflows/build-exe.yml` | Gera o instalador automaticamente no GitHub (tag `v*` ou botão) |
| `models/`, `vendor/`, `face-api.min.js` | IA de reconhecimento e bibliotecas — tudo local |
| `supabase/setup-completo.sql` | **RODAR NO SUPABASE** (uma vez só) — tabelas, coluna `bloqueado`, RLS e verificação final |

> O site (`landing/`) e o app são coisas SEPARADAS de propósito: o site não tem
> área de login nem acesso a nada — é vitrine + download. Quem tem login é o
> app instalado no computador da escola.

---

## 🖥️ Instalar o app

1. Baixa **`EyeGate-Setup-2.0.1.exe`**
2. Executa (se o SmartScreen avisar: **Mais informações → Executar assim mesmo**)
3. Atalhos criados no menu iniciar e na área de trabalho; desinstalação pelo Painel de Controle

### Gerar o instalador você mesmo
- **Pelo GitHub:** cria a tag `v2.0.1` (ou aba Actions → "Build Windows Installer" → Run) e pega o `.exe` no artefato da execução
- **Local:** `makensis installer/eye-gate-installer.nsi` (precisa do payload montado em `build/app` — ver o workflow)

---

## 🌐 Publicar o site (GitHub Pages)

O site é **um arquivo só** (`docs/index.html`) — nada de instalar nada.

> O repo precisa estar **público** pro Pages grátis funcionar
> (Settings → General → embaixo, Danger Zone → Change visibility → Public).

1. No GitHub, entra no repositório → botão **Add file → Create new file**
2. No campo do nome, digita `docs/index.html` — a barra cria a pasta sozinha
3. Cola o conteúdo inteiro do arquivo no espaço grande em branco
4. **Commit changes**
5. **Settings → Pages** → Branch: `main` · Folder: **`/docs`** → **Save**
6. Em 1–2 min o site está no ar em `https://vicentexk.github.io/EYE_GATE/`

### ⚠️ Passo único pro botão de download funcionar
O botão do site aponta **direto pro arquivo**:
`https://github.com/vicentexk/EYE_GATE07-/releases/latest/download/EyeGate-Setup-2.0.1.exe`

Pra esse link funcionar, publique o instalador uma vez:
1. GitHub → **Releases → Create a new release** → escolhe uma tag (ex.: `v2.0.1`)
2. Arrasta o arquivo **`EyeGate-Setup-2.0.1.exe`** (o nome tem que ser exatamente esse)
3. Marca **Set as latest release** → Publish

Pronto: o link "latest" sempre entrega o instalador da release mais recente.
Se mudar o nome do arquivo em releases futuras, ajuste o `LINK_DOWNLOAD` no
fim do `docs/index.html`.

---

## 🚀 Antes de usar: banco (uma vez só)

1. https://supabase.com/dashboard → **SQL Editor**
2. Limpa o editor (Ctrl+A → Delete) e cola o **arquivo inteiro** `supabase/setup-completo.sql`
3. **RUN**
4. Avisos `[pula]` = já existia, **não é erro**. No final aparece uma tabela de verificação — tem que estar tudo `true`

O script é à prova de erro: pode rodar quantas vezes quiser, nunca para no meio e **não apaga nenhum dado**.

---

## 🆚 Novidades da v2.0.1

- **📷 CÂMERA CORRIGIDA** — agora liga na hora, ANTES da IA e do banco. Antes, se o banco estivesse fora do ar (ou nenhum aluno tivesse rosto cadastrado), a câmera nem abria
- **Diagnóstico honesto de câmera**: painel grande explicando em português o que está bloqueando (sem webcam, acesso negado no Windows, câmera em uso pelo Zoom/Meet) e como resolver
- **Site 100% separado do app** — sem login, só apresentação + download direto do instalador
- Instalador NSIS com atalhos, desinstalador e "abrir agora?"
- Matcher com média das 5 poses, monitor com loop contínuo e modo de desempenho ajustável
- 0 CDNs: fontes, ícones e IA tudo local (só o banco precisa de internet)

---

**Equipe:** Gian · Julio · Mozer · Raul · Richard · Vicente 💛
