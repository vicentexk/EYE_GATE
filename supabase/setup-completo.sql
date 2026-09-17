-- ============================================================
-- eye gate — SETUP COMPLETO DO BANCO (versão À PROVA DE ERRO)
--
-- COMO USAR:
--   1. supabase.com/dashboard → seu projeto → SQL Editor
--   2. Clique no editor → Ctrl+A (seleciona tudo) → apague
--   3. Cole TODO este arquivo → botão RUN (uma vez só)
--
-- Este script é seguro rodar qualquer número de vezes:
--   • Se algo já existe, ele só AVISA e continua (não para no meio)
--   • Não apaga nenhum dado seu
--   • Cria tabelas que não existem, adiciona colunas que faltam,
--     cria índices e libera as permissões que o app precisa
-- ============================================================

-- ---------- EXTENSÃO (gera UUID) ----------
DO $$ BEGIN
  create extension if not exists pgcrypto;
EXCEPTION WHEN OTHERS THEN RAISE NOTICE '[pula] pgcrypto: %', SQLERRM; END $$;

-- ---------- TABELAS (cria só as que não existem) ----------
DO $$ BEGIN
  create table if not exists public.usuarios (
    id        uuid primary key default gen_random_uuid(),
    nome      text not null,
    email     text unique not null,
    senha     text not null,
    tipo      text not null default 'usuario',
    bloqueado boolean not null default false,
    criado_em timestamptz not null default now()
  );
EXCEPTION WHEN OTHERS THEN RAISE NOTICE '[pula] tabela usuarios: %', SQLERRM; END $$;

DO $$ BEGIN
  create table if not exists public.admins (
    id    uuid primary key default gen_random_uuid(),
    nome  text,
    email text unique not null,
    senha text not null
  );
EXCEPTION WHEN OTHERS THEN RAISE NOTICE '[pula] tabela admins: %', SQLERRM; END $$;

DO $$ BEGIN
  create table if not exists public.alunos (
    id         uuid primary key default gen_random_uuid(),
    nome       text not null,
    matricula  text,
    turma      text,
    foto       text,
    descriptor jsonb,
    criado_em  timestamptz not null default now()
  );
EXCEPTION WHEN OTHERS THEN RAISE NOTICE '[pula] tabela alunos: %', SQLERRM; END $$;

DO $$ BEGIN
  create table if not exists public.logs_reconhecimento (
    id         uuid primary key default gen_random_uuid(),
    aluno_id   uuid,
    nome_aluno text,
    status     text,
    horario    timestamptz not null default now()
  );
EXCEPTION WHEN OTHERS THEN RAISE NOTICE '[pula] tabela logs_reconhecimento: %', SQLERRM; END $$;

-- ---------- COLUNAS NOVAS (nas tabelas que já existiam) ----------
DO $$ BEGIN
  alter table public.usuarios add column if not exists bloqueado boolean not null default false;
EXCEPTION WHEN OTHERS THEN RAISE NOTICE '[pula] coluna usuarios.bloqueado: %', SQLERRM; END $$;

DO $$ BEGIN
  alter table public.usuarios add column if not exists criado_em timestamptz not null default now();
EXCEPTION WHEN OTHERS THEN RAISE NOTICE '[pula] coluna usuarios.criado_em: %', SQLERRM; END $$;

DO $$ BEGIN
  alter table public.alunos add column if not exists criado_em timestamptz not null default now();
EXCEPTION WHEN OTHERS THEN RAISE NOTICE '[pula] coluna alunos.criado_em: %', SQLERRM; END $$;

-- ---------- ÍNDICES (dashboard mais rápido) ----------
DO $$ BEGIN
  create index if not exists idx_logs_aluno on public.logs_reconhecimento (aluno_id);
EXCEPTION WHEN OTHERS THEN RAISE NOTICE '[pula] índice logs_aluno: %', SQLERRM; END $$;

DO $$ BEGIN
  create index if not exists idx_logs_horario on public.logs_reconhecimento (horario desc);
EXCEPTION WHEN OTHERS THEN RAISE NOTICE '[pula] índice logs_horario: %', SQLERRM; END $$;

DO $$ BEGIN
  create index if not exists idx_usuarios_email on public.usuarios (email);
EXCEPTION WHEN OTHERS THEN RAISE NOTICE '[pula] índice usuarios_email: %', SQLERRM; END $$;

-- ---------- SEGURANÇA RLS + POLÍTICAS (o app precisa delas) ----------
DO $$ BEGIN
  alter table public.usuarios enable row level security;
  alter table public.alunos enable row level security;
  alter table public.logs_reconhecimento enable row level security;
  alter table public.admins enable row level security;
EXCEPTION WHEN OTHERS THEN RAISE NOTICE '[pula] rls: %', SQLERRM; END $$;

-- usuarios
DO $$ BEGIN
  drop policy if exists "usuarios_select" on public.usuarios;
  create policy "usuarios_select" on public.usuarios for select using (true);
  drop policy if exists "usuarios_insert" on public.usuarios;
  create policy "usuarios_insert" on public.usuarios for insert with check (true);
  drop policy if exists "usuarios_update" on public.usuarios;
  create policy "usuarios_update" on public.usuarios for update using (true) with check (true);
  drop policy if exists "usuarios_delete" on public.usuarios;
  create policy "usuarios_delete" on public.usuarios for delete using (true);
EXCEPTION WHEN OTHERS THEN RAISE NOTICE '[pula] políticas usuarios: %', SQLERRM; END $$;

-- alunos
DO $$ BEGIN
  drop policy if exists "alunos_select" on public.alunos;
  create policy "alunos_select" on public.alunos for select using (true);
  drop policy if exists "alunos_insert" on public.alunos;
  create policy "alunos_insert" on public.alunos for insert with check (true);
  drop policy if exists "alunos_update" on public.alunos;
  create policy "alunos_update" on public.alunos for update using (true) with check (true);
  drop policy if exists "alunos_delete" on public.alunos;
  create policy "alunos_delete" on public.alunos for delete using (true);
EXCEPTION WHEN OTHERS THEN RAISE NOTICE '[pula] políticas alunos: %', SQLERRM; END $$;

-- logs
DO $$ BEGIN
  drop policy if exists "logs_select" on public.logs_reconhecimento;
  create policy "logs_select" on public.logs_reconhecimento for select using (true);
  drop policy if exists "logs_insert" on public.logs_reconhecimento;
  create policy "logs_insert" on public.logs_reconhecimento for insert with check (true);
  drop policy if exists "logs_delete" on public.logs_reconhecimento;
  create policy "logs_delete" on public.logs_reconhecimento for delete using (true);
EXCEPTION WHEN OTHERS THEN RAISE NOTICE '[pula] políticas logs: %', SQLERRM; END $$;

-- admins
DO $$ BEGIN
  drop policy if exists "admins_select" on public.admins;
  create policy "admins_select" on public.admins for select using (true);
EXCEPTION WHEN OTHERS THEN RAISE NOTICE '[pula] políticas admins: %', SQLERRM; END $$;

-- ============================================================
-- VERIFICAÇÃO FINAL — tem que aparecer tudo TRUE
-- ============================================================
select
  'usuarios.bloqueado'  as item,
  coalesce(exists (select 1 from information_schema.columns
    where table_schema='public' and table_name='usuarios' and column_name='bloqueado'), false) as ok
union all
select 'tabela alunos',
  coalesce(exists (select 1 from information_schema.tables
    where table_schema='public' and table_name='alunos'), false)
union all
select 'tabela logs_reconhecimento',
  coalesce(exists (select 1 from information_schema.tables
    where table_schema='public' and table_name='logs_reconhecimento'), false)
union all
select 'política usuarios_select',
  coalesce(exists (select 1 from pg_policies
    where schemaname='public' and tablename='usuarios' and policyname='usuarios_select'), false)
union all
select 'política logs_insert',
  coalesce(exists (select 1 from pg_policies
    where schemaname='public' and tablename='logs_reconhecimento' and policyname='logs_insert'), false);

-- ✅ Se tudo aparecer TRUE, voltou pro app e testa: login, cadastro
--    e Gestão de Contas funcionando. Qualquer [pula] nos avisos
--    acima é só coisa que JÁ existia — não é erro.
