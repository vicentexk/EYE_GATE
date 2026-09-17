[README.md](https://github.com/user-attachments/files/32341699/README.md)
# EYE GATE — Sistema de Acesso Escolar com Reconhecimento Facial

![versão](https://img.shields.io/badge/vers%C3%A3o-2.0.1-FEB914?style=flat-square) ![plataforma](https://img.shields.io/badge/windows-10%2F11-2C9FA2?style=flat-square) ![turma](https://img.shields.io/badge/turma-3CDS-B21236?style=flat-square)

O EYE GATE é um sistema de controle de acesso escolar que utiliza reconhecimento facial em tempo real para registrar a entrada e a saída de alunos. A identificação ocorre em menos de um segundo por detecção, com registro automático dos acessos, geração de relatórios e controle de contas (bloqueio e permissões). A inferência facial é executada integralmente na máquina cliente, sem dependência de serviços externos de biometria.

O projeto é composto por três módulos:

- **Aplicação desktop** — cliente Windows desenvolvido em Electron, responsável pela operação da portaria: autenticação, monitor de reconhecimento contínuo, cadastro facial, dashboard analítico, registros, relatórios e administração de contas.
- **Módulo web institucional** — página estática publicada via GitHub Pages, destinada à apresentação do projeto e à distribuição do instalador. Não possui autenticação nem acesso ao banco de dados; a separação entre a superfície pública e o sistema é deliberada.
- **Persistência** — PostgreSQL gerenciado (Supabase), com tabelas de usuários, administradores, alunos e logs de reconhecimento, protegidas por Row Level Security.

O fluxo de reconhecimento ocorre da seguinte forma: o quadro capturado pela webcam é processado pela face-api.js (TensorFlow.js/WebGL), que gera um *descriptor* de 128 dimensões do rosto; esse valor é comparado, por distância euclidiana, aos descritores médios dos alunos cadastrados; distâncias abaixo do limiar configurado (0,55) resultam em reconhecimento, com registro de Entrada/Saída persistido no banco e confirmação visual e sonora na interface.

---

## Tecnologias

| Tecnologia | Aplicação |
|---|---|
| **HTML5** | Estrutura da aplicação desktop (`index.html`) e do módulo web (`docs/index.html`) |
| **CSS3** | Estilização completa: `css/app.css` (desktop) e bloco `<style>` embutido no módulo web. Identidade visual própria, de inspiração Bauhaus |
| **JavaScript (ES6+)** | Lógica integral do sistema, organizada em 12 módulos em `js/` |
| **SQL (PostgreSQL)** | Estrutura do banco, políticas RLS e índices (`supabase/setup-completo.sql`) |
| **Node.js / Electron 31** | Processo principal da aplicação desktop (`electron/main.js`) |
| **NSIS** | Geração do instalador Windows (`installer/eye-gate-installer.nsi`) |
| **face-api.js** (local) | Detecção facial, *landmarks* (68 pontos) e reconhecimento (descritores de 128 dimensões) |
| **supabase-js v2** (local) | Comunicação cliente–banco via REST/PostgREST |
| **jsPDF** (local) | Exportação de relatórios em PDF |

Todas as dependências de execução são servidas localmente (fontes embutidas em base64, bibliotecas em `vendor/`, modelos da IA em `models/`). A única dependência de rede em operação é o banco de dados.

---

## Estrutura de diretórios

```
EYE_GATE/
├── docs/
│   ├── index.html                 Módulo web completo (HTML, CSS e JS em um arquivo)
│   └── img/                       Imagens de documentação do sistema
├── css/
│   └── app.css                    Estilização integral da aplicação desktop
├── js/
│   ├── config.js                  Configurações centrais (banco, suporte, parâmetros da IA)
│   ├── auth.js                    Autenticação e sessões
│   ├── camera.js                  Aquisição de vídeo: modo forçado e diagnóstico de falhas
│   ├── monitor.js                 Reconhecimento facial em tempo real
│   ├── cadastro.js                Captura facial em 5 poses com validação por landmarks
│   ├── face-core.js               Núcleo de comparação de descritores
│   ├── data.js                    Camada de acesso a dados (Supabase)
│   ├── charts.js                  Visualizações do dashboard (Canvas)
│   ├── views.js                   Registros e relatórios (PDF/CSV)
│   ├── admin.js                   Administração de contas
│   ├── ui.js                      Componentes de interface (avisos, diálogos)
│   └── app.js                     Inicialização e navegação
├── electron/
│   ├── main.js                    Processo principal: janela, permissões, servidor interno
│   └── preload.js                 Ponte isolada (contextIsolation) entre app e sistema
├── vendor/
│   ├── supabase.js                Cliente Supabase (servido localmente)
│   └── jspdf.min.js               Geração de PDF
├── models/                        Modelos pré-treinados da face-api.js
│   ├── tiny_face_detector_model-*        Detecção de rostos
│   ├── face_landmark_68_model-*          68 pontos faciais (validação de poses)
│   └── face_recognition_model-*          Extração do descriptor de 128 dimensões
├── img/                           Identidade visual (logo.ico, logo.png)
├── installer/
│   └── eye-gate-installer.nsi     Definição do instalador NSIS
├── supabase/
│   └── setup-completo.sql         Provisionamento completo e idempotente do banco
├── .github/workflows/
│   └── build-exe.yml              Pipeline de build do instalador (GitHub Actions)
├── index.html                     Telas da aplicação desktop
├── face-api.min.js                Biblioteca de visão computacional
├── package.json                   Metadados e versão da aplicação
└── README.md
```

**Critério de organização:** `docs/` existe com esse nome por exigência do GitHub Pages e contém exclusivamente o módulo web, isolado da aplicação. A lógica da aplicação desktop é segregada por responsabilidade em `js/` (a ordem de carregamento dos módulos está declarada ao final de `index.html`). Bibliotecas de terceiros e modelos de IA residem dentro do projeto (`vendor/`, `models/`, `face-api.min.js`) para eliminar dependência de CDNs. `electron/` contém o código de processo principal, distinto da interface. `installer/` e `.github/` respondem pela empacotação e automação de build.

---

## Localização de componentes

Referência rápida para localização e edição dos principais componentes (módulo web: `docs/index.html`; aplicação desktop: raiz, `css/` e `js/`):

| Componente | Arquivo | Referência interna |
|---|---|---|
| HTML do módulo web | `docs/index.html` | corpo do documento |
| CSS do módulo web | `docs/index.html` | bloco `<style>` no `<head>` |
| JS do módulo web | `docs/index.html` | bloco `<script>` ao final (link de download, animações) |
| HTML da aplicação (telas) | `index.html` | seções `<section id="screen-...">` e `<div id="view-...">` |
| CSS da aplicação | `css/app.css` | paleta em `:root`; fontes embutidas em base64 |
| Configurações centrais | `js/config.js` | URL/ chave do Supabase, contatos de suporte, `MATCH_THRESHOLD`, intervalos de detecção |
| Regra de autenticação administrativa | `js/auth.js` | método `login()` — valida primeiro na tabela `admins`, depois em `usuarios` |
| Reconhecimento em tempo real | `js/monitor.js` | `iniciar()` e `_loop()` |
| Diagnóstico de câmera | `js/camera.js` | `_traduzir()` (mensagens de erro), `abrir()` (modo forçado) |
| Acesso a dados | `js/data.js` | uma função por operação (`listarAlunos`, `criarUsuario`, etc.) |
| Gráficos | `js/charts.js` | renderização manual em `<canvas>` |
| Administração de contas | `js/admin.js` | bloqueio, promoção e criação de administradores |
| Provisionamento do banco | `supabase/setup-completo.sql` | execução única no SQL Editor do Supabase |
| Ícone e logo | `img/` | `logo.ico` (Windows/instalador), `logo.png` |
| Instalador | `installer/eye-gate-installer.nsi` | comentado por seção |

---

## Instalação e execução

### Provisionamento do banco (execução única)
1. Acessar o SQL Editor do projeto no [Supabase](https://supabase.com/dashboard);
2. Executar o conteúdo integral de `supabase/setup-completo.sql`;
3. Avisos `[pula]` indicam objetos já existentes (script idempotente); a verificação final deve retornar `true` em todos os itens.

O script cria as tabelas `usuarios`, `admins`, `alunos` e `logs_reconhecimento`, a coluna de bloqueio (`usuarios.bloqueado`), políticas RLS, índices de performance e a conta administrativa `professor@gmail.com` (senha definida no próprio script).

### Execução em desenvolvimento
```bash
# interface em navegador (modo de teste)
python3 -m http.server 8090     # http://localhost:8090

# aplicação desktop com janela própria (requer Node.js)
npm install
npm start
```

### Build do instalador
- **Via GitHub Actions:** tag `v*` ou execução manual do workflow *Build Windows Installer* (`.github/workflows/build-exe.yml`); o artefato `EyeGate-Setup-2.0.1.exe` é gerado automaticamente.
- **Local:** montar o payload Electron em `build/app` e executar `makensis installer/eye-gate-installer.nsi`.

### Distribuição
O instalador é publicado na aba **Releases**, e o módulo web o referencia pelo padrão `releases/latest/download/EyeGate-Setup-<versão>.exe`, que aponta sempre para a versão mais recente. Nota: por não possuir assinatura de código, o Windows pode exibir o aviso do SmartScreen na primeira execução.

---

## Funcionalidades

- **Monitor em tempo real** — detecção contínua (3–8 ciclos/s), identificação com nome sobreposto ao rosto, banner e confirmação sonora, *cooldown* anti-duplicação configurável (8 s a 1 min), três perfis de desempenho (224/320/416);
- **Cadastro facial** — cinco poses (frontal, esquerda, direita, superior, inferior) validadas automaticamente por *landmarks*; persistência da média dos descritores para maior estabilidade;
- **Dashboard** — totais em tempo real, acessos dos últimos 7 dias, movimento por hora e feed dos últimos registros (atualização automática a cada 30 s);
- **Registros** — filtragem por nome/tipo/data e exportação CSV;
- **Relatórios** — PDF por aluno;
- **Administração de contas** — bloqueio/desbloqueio (conta bloqueada é recusada no login), promoção/rebaixamento e criação de administradores;
- **Autenticação unificada** — não há interface dedicada a administrador: credenciais registradas como admin recebem os privilégios automaticamente no login comum;
- **Robustez de câmera** — tentativa sequencial por dispositivo (2× cada), diagnóstico das falhas em português, atalho para as configurações de privacidade do Windows e verificação de câmera na primeira execução.

---

## Segurança e LGPD

- Não há armazenamento obrigatório de fotografias: a identidade biométrica é representada unicamente pelo *descriptor* de 128 dimensões, do qual o rosto não é reconstruível;
- Políticas **RLS** ativas nas tabelas;
- O módulo web não possui qualquer conexão com o banco de dados;
- Bloqueio de contas aplicado no momento da autenticação.

---

## Equipe — Turma 3CDS

**Gian · Julio · Mozer · Raul · Richard · Vicente**

Projeto educacional — © 2026 eye gate.
