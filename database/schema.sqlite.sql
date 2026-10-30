-- Ensina+ — estrutura do banco (SQLite 3)
-- O instalador (instalar.php) executa este arquivo automaticamente.

CREATE TABLE IF NOT EXISTS usuarios (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  nome TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE,
  senha_hash TEXT NOT NULL,
  papel TEXT NOT NULL DEFAULT 'aluno',
  criado_em TEXT NOT NULL,
  atualizado_em TEXT NULL,
  ultimo_acesso_em TEXT NULL
);

CREATE TABLE IF NOT EXISTS senha_tokens (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  usuario_id INTEGER NOT NULL REFERENCES usuarios (id) ON DELETE CASCADE,
  token_hash TEXT NOT NULL UNIQUE,
  expira_em TEXT NOT NULL,
  usado_em TEXT NULL,
  criado_em TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS login_falhas (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  chave TEXT NOT NULL,
  criado_em TEXT NOT NULL
);
CREATE INDEX IF NOT EXISTS ix_login_falhas ON login_falhas (chave, criado_em);

CREATE TABLE IF NOT EXISTS temas (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  slug TEXT NOT NULL UNIQUE,
  nome TEXT NOT NULL,
  subtitulo TEXT NOT NULL DEFAULT '',
  descricao TEXT NULL,
  icone TEXT NOT NULL DEFAULT 'livro',
  ordem INTEGER NOT NULL DEFAULT 0,
  publicado INTEGER NOT NULL DEFAULT 1,
  criado_em TEXT NOT NULL,
  atualizado_em TEXT NULL
);

CREATE TABLE IF NOT EXISTS modulos (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  tema_id INTEGER NOT NULL REFERENCES temas (id) ON DELETE CASCADE,
  nome TEXT NOT NULL,
  descricao TEXT NULL,
  ordem INTEGER NOT NULL DEFAULT 0,
  publicado INTEGER NOT NULL DEFAULT 1,
  criado_em TEXT NOT NULL,
  atualizado_em TEXT NULL
);
CREATE INDEX IF NOT EXISTS ix_modulos_tema ON modulos (tema_id, ordem);

CREATE TABLE IF NOT EXISTS aulas (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  modulo_id INTEGER NOT NULL REFERENCES modulos (id) ON DELETE CASCADE,
  titulo TEXT NOT NULL,
  objetivo TEXT NOT NULL DEFAULT '',
  resumo TEXT NULL,
  passos TEXT NULL,
  url TEXT NULL,
  arquivo TEXT NULL,
  tipo TEXT NOT NULL DEFAULT 'artigo',
  fonte_nome TEXT NOT NULL DEFAULT '',
  fonte_url TEXT NULL,
  duracao_min INTEGER NULL,
  palavras_chave TEXT NOT NULL DEFAULT '',
  busca TEXT NULL,
  busca_titulo TEXT NOT NULL DEFAULT '',
  ordem INTEGER NOT NULL DEFAULT 0,
  publicado INTEGER NOT NULL DEFAULT 1,
  criado_em TEXT NOT NULL,
  atualizado_em TEXT NULL
);
CREATE INDEX IF NOT EXISTS ix_aulas_modulo ON aulas (modulo_id, ordem);

CREATE TABLE IF NOT EXISTS perguntas (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  modulo_id INTEGER NOT NULL REFERENCES modulos (id) ON DELETE CASCADE,
  enunciado TEXT NOT NULL,
  tipo TEXT NOT NULL DEFAULT 'multipla',
  explicacao TEXT NULL,
  ordem INTEGER NOT NULL DEFAULT 0,
  criado_em TEXT NOT NULL
);
CREATE INDEX IF NOT EXISTS ix_perguntas_modulo ON perguntas (modulo_id, ordem);

CREATE TABLE IF NOT EXISTS alternativas (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  pergunta_id INTEGER NOT NULL REFERENCES perguntas (id) ON DELETE CASCADE,
  texto TEXT NOT NULL,
  correta INTEGER NOT NULL DEFAULT 0,
  ordem INTEGER NOT NULL DEFAULT 0
);
CREATE INDEX IF NOT EXISTS ix_alternativas_pergunta ON alternativas (pergunta_id, ordem);

CREATE TABLE IF NOT EXISTS progresso (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  usuario_id INTEGER NULL REFERENCES usuarios (id) ON DELETE CASCADE,
  visitante TEXT NULL,
  aula_id INTEGER NOT NULL REFERENCES aulas (id) ON DELETE CASCADE,
  status TEXT NOT NULL DEFAULT 'visto',
  visto_em TEXT NOT NULL,
  concluido_em TEXT NULL,
  atualizado_em TEXT NOT NULL,
  UNIQUE (usuario_id, aula_id),
  UNIQUE (visitante, aula_id)
);
CREATE INDEX IF NOT EXISTS ix_progresso_aula ON progresso (aula_id, status);

CREATE TABLE IF NOT EXISTS resultados (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  usuario_id INTEGER NULL REFERENCES usuarios (id) ON DELETE CASCADE,
  visitante TEXT NULL,
  modulo_id INTEGER NOT NULL REFERENCES modulos (id) ON DELETE CASCADE,
  acertos INTEGER NOT NULL DEFAULT 0,
  total INTEGER NOT NULL DEFAULT 0,
  feito_em TEXT NOT NULL,
  UNIQUE (usuario_id, modulo_id),
  UNIQUE (visitante, modulo_id)
);

CREATE TABLE IF NOT EXISTS respostas (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  pergunta_id INTEGER NOT NULL REFERENCES perguntas (id) ON DELETE CASCADE,
  alternativa_id INTEGER NULL REFERENCES alternativas (id) ON DELETE SET NULL,
  correta INTEGER NOT NULL DEFAULT 0,
  usuario_id INTEGER NULL REFERENCES usuarios (id) ON DELETE SET NULL,
  criado_em TEXT NOT NULL
);
CREATE INDEX IF NOT EXISTS ix_respostas_pergunta ON respostas (pergunta_id);

CREATE TABLE IF NOT EXISTS feedbacks (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  aula_id INTEGER NOT NULL REFERENCES aulas (id) ON DELETE CASCADE,
  usuario_id INTEGER NULL REFERENCES usuarios (id) ON DELETE SET NULL,
  visitante TEXT NULL,
  util INTEGER NULL,
  comentario TEXT NULL,
  lido INTEGER NOT NULL DEFAULT 0,
  criado_em TEXT NOT NULL,
  atualizado_em TEXT NOT NULL,
  UNIQUE (usuario_id, aula_id),
  UNIQUE (visitante, aula_id)
);
CREATE INDEX IF NOT EXISTS ix_feedbacks_aula ON feedbacks (aula_id);

CREATE TABLE IF NOT EXISTS acessos (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  aula_id INTEGER NOT NULL REFERENCES aulas (id) ON DELETE CASCADE,
  dia TEXT NOT NULL,
  visualizacoes INTEGER NOT NULL DEFAULT 0,
  cliques INTEGER NOT NULL DEFAULT 0,
  UNIQUE (aula_id, dia)
);
CREATE INDEX IF NOT EXISTS ix_acessos_dia ON acessos (dia);

CREATE TABLE IF NOT EXISTS mensagens (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  nome TEXT NOT NULL,
  contato TEXT NOT NULL DEFAULT '',
  mensagem TEXT NOT NULL,
  lida INTEGER NOT NULL DEFAULT 0,
  criado_em TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS caixa_saida (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  para TEXT NOT NULL,
  assunto TEXT NOT NULL,
  corpo TEXT NOT NULL,
  criado_em TEXT NOT NULL
);
