-- Ensina+ — estrutura do banco (MySQL 5.6+ / MariaDB 10+)
-- O instalador (instalar.php) executa este arquivo automaticamente.

CREATE TABLE IF NOT EXISTS usuarios (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  nome VARCHAR(120) NOT NULL,
  email VARCHAR(190) NOT NULL,
  senha_hash VARCHAR(255) NOT NULL,
  papel VARCHAR(20) NOT NULL DEFAULT 'aluno',
  criado_em DATETIME NOT NULL,
  atualizado_em DATETIME NULL,
  ultimo_acesso_em DATETIME NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_usuarios_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS senha_tokens (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  usuario_id INT UNSIGNED NOT NULL,
  token_hash CHAR(64) NOT NULL,
  expira_em DATETIME NOT NULL,
  usado_em DATETIME NULL,
  criado_em DATETIME NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_senha_tokens_hash (token_hash),
  CONSTRAINT fk_senha_tokens_usuario FOREIGN KEY (usuario_id) REFERENCES usuarios (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS login_falhas (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  chave CHAR(64) NOT NULL,
  criado_em DATETIME NOT NULL,
  PRIMARY KEY (id),
  KEY ix_login_falhas (chave, criado_em)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS temas (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  slug VARCHAR(120) NOT NULL,
  nome VARCHAR(120) NOT NULL,
  subtitulo VARCHAR(200) NOT NULL DEFAULT '',
  descricao TEXT NULL,
  icone VARCHAR(40) NOT NULL DEFAULT 'livro',
  ordem INT NOT NULL DEFAULT 0,
  publicado TINYINT(1) NOT NULL DEFAULT 1,
  criado_em DATETIME NOT NULL,
  atualizado_em DATETIME NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_temas_slug (slug)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS modulos (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  tema_id INT UNSIGNED NOT NULL,
  nome VARCHAR(150) NOT NULL,
  descricao TEXT NULL,
  ordem INT NOT NULL DEFAULT 0,
  publicado TINYINT(1) NOT NULL DEFAULT 1,
  criado_em DATETIME NOT NULL,
  atualizado_em DATETIME NULL,
  PRIMARY KEY (id),
  KEY ix_modulos_tema (tema_id, ordem),
  CONSTRAINT fk_modulos_tema FOREIGN KEY (tema_id) REFERENCES temas (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS aulas (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  modulo_id INT UNSIGNED NOT NULL,
  titulo VARCHAR(200) NOT NULL,
  objetivo VARCHAR(300) NOT NULL DEFAULT '',
  resumo TEXT NULL,
  passos TEXT NULL,
  url VARCHAR(2000) NULL,
  arquivo VARCHAR(255) NULL,
  tipo VARCHAR(20) NOT NULL DEFAULT 'artigo',
  fonte_nome VARCHAR(150) NOT NULL DEFAULT '',
  fonte_url VARCHAR(2000) NULL,
  duracao_min INT NULL,
  palavras_chave VARCHAR(300) NOT NULL DEFAULT '',
  busca TEXT NULL,
  busca_titulo VARCHAR(250) NOT NULL DEFAULT '',
  ordem INT NOT NULL DEFAULT 0,
  publicado TINYINT(1) NOT NULL DEFAULT 1,
  criado_em DATETIME NOT NULL,
  atualizado_em DATETIME NULL,
  PRIMARY KEY (id),
  KEY ix_aulas_modulo (modulo_id, ordem),
  CONSTRAINT fk_aulas_modulo FOREIGN KEY (modulo_id) REFERENCES modulos (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS perguntas (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  modulo_id INT UNSIGNED NOT NULL,
  enunciado TEXT NOT NULL,
  tipo VARCHAR(20) NOT NULL DEFAULT 'multipla',
  explicacao TEXT NULL,
  ordem INT NOT NULL DEFAULT 0,
  criado_em DATETIME NOT NULL,
  PRIMARY KEY (id),
  KEY ix_perguntas_modulo (modulo_id, ordem),
  CONSTRAINT fk_perguntas_modulo FOREIGN KEY (modulo_id) REFERENCES modulos (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS alternativas (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  pergunta_id INT UNSIGNED NOT NULL,
  texto VARCHAR(300) NOT NULL,
  correta TINYINT(1) NOT NULL DEFAULT 0,
  ordem INT NOT NULL DEFAULT 0,
  PRIMARY KEY (id),
  KEY ix_alternativas_pergunta (pergunta_id, ordem),
  CONSTRAINT fk_alternativas_pergunta FOREIGN KEY (pergunta_id) REFERENCES perguntas (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS progresso (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  usuario_id INT UNSIGNED NULL,
  visitante CHAR(64) NULL,
  aula_id INT UNSIGNED NOT NULL,
  status VARCHAR(20) NOT NULL DEFAULT 'visto',
  visto_em DATETIME NOT NULL,
  concluido_em DATETIME NULL,
  atualizado_em DATETIME NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_progresso_usuario (usuario_id, aula_id),
  UNIQUE KEY uq_progresso_visitante (visitante, aula_id),
  KEY ix_progresso_aula (aula_id, status),
  CONSTRAINT fk_progresso_usuario FOREIGN KEY (usuario_id) REFERENCES usuarios (id) ON DELETE CASCADE,
  CONSTRAINT fk_progresso_aula FOREIGN KEY (aula_id) REFERENCES aulas (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS resultados (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  usuario_id INT UNSIGNED NULL,
  visitante CHAR(64) NULL,
  modulo_id INT UNSIGNED NOT NULL,
  acertos INT NOT NULL DEFAULT 0,
  total INT NOT NULL DEFAULT 0,
  feito_em DATETIME NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_resultados_usuario (usuario_id, modulo_id),
  UNIQUE KEY uq_resultados_visitante (visitante, modulo_id),
  CONSTRAINT fk_resultados_usuario FOREIGN KEY (usuario_id) REFERENCES usuarios (id) ON DELETE CASCADE,
  CONSTRAINT fk_resultados_modulo FOREIGN KEY (modulo_id) REFERENCES modulos (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS respostas (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  pergunta_id INT UNSIGNED NOT NULL,
  alternativa_id INT UNSIGNED NULL,
  correta TINYINT(1) NOT NULL DEFAULT 0,
  usuario_id INT UNSIGNED NULL,
  criado_em DATETIME NOT NULL,
  PRIMARY KEY (id),
  KEY ix_respostas_pergunta (pergunta_id),
  CONSTRAINT fk_respostas_pergunta FOREIGN KEY (pergunta_id) REFERENCES perguntas (id) ON DELETE CASCADE,
  CONSTRAINT fk_respostas_alternativa FOREIGN KEY (alternativa_id) REFERENCES alternativas (id) ON DELETE SET NULL,
  CONSTRAINT fk_respostas_usuario FOREIGN KEY (usuario_id) REFERENCES usuarios (id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS feedbacks (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  aula_id INT UNSIGNED NOT NULL,
  usuario_id INT UNSIGNED NULL,
  visitante CHAR(64) NULL,
  util TINYINT(1) NULL,
  comentario TEXT NULL,
  lido TINYINT(1) NOT NULL DEFAULT 0,
  criado_em DATETIME NOT NULL,
  atualizado_em DATETIME NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_feedbacks_usuario (usuario_id, aula_id),
  UNIQUE KEY uq_feedbacks_visitante (visitante, aula_id),
  KEY ix_feedbacks_aula (aula_id),
  CONSTRAINT fk_feedbacks_aula FOREIGN KEY (aula_id) REFERENCES aulas (id) ON DELETE CASCADE,
  CONSTRAINT fk_feedbacks_usuario FOREIGN KEY (usuario_id) REFERENCES usuarios (id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS acessos (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  aula_id INT UNSIGNED NOT NULL,
  dia DATE NOT NULL,
  visualizacoes INT NOT NULL DEFAULT 0,
  cliques INT NOT NULL DEFAULT 0,
  PRIMARY KEY (id),
  UNIQUE KEY uq_acessos (aula_id, dia),
  KEY ix_acessos_dia (dia),
  CONSTRAINT fk_acessos_aula FOREIGN KEY (aula_id) REFERENCES aulas (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS mensagens (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  nome VARCHAR(120) NOT NULL,
  contato VARCHAR(190) NOT NULL DEFAULT '',
  mensagem TEXT NOT NULL,
  lida TINYINT(1) NOT NULL DEFAULT 0,
  criado_em DATETIME NOT NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS caixa_saida (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  para VARCHAR(190) NOT NULL,
  assunto VARCHAR(200) NOT NULL,
  corpo TEXT NOT NULL,
  criado_em DATETIME NOT NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
