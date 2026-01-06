-- Initial LNM3 Platform DB schema
-- No `\n` after a `;`, to make the file easy to split in migrations scripts:
-- will be ugly for functions but will stay readable.

-- EXTENSIONS

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- FUNCTIONS

CREATE OR REPLACE FUNCTION is_valid_unit_archetype(unit_archetype text) RETURNS boolean AS $$
BEGIN
    RETURN unit_archetype IN ('B1', 'B2', 'B3', 'B4', 'B5', 'B6', 'B7', 'B8', 
                         'b1', 'b2', 'b3', 'b4', 'b5', 'b6', 'b7', 'b8'); END; $$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION is_valid_battle_log(log jsonb) RETURNS boolean AS $$
BEGIN
    IF jsonb_typeof(log) <> 'array' THEN RETURN FALSE; END IF; RETURN NOT EXISTS (
        SELECT 1 
        FROM jsonb_array_elements(log) AS elem
        WHERE 
            NOT (elem ? 'attacking_unit' AND elem ? 'defending_unit' AND elem ? 'kill_steps')
            OR jsonb_typeof(elem->'kill_steps') <> 'array'
            OR NOT is_valid_unit_archetype(elem->>'attacking_unit')
            OR NOT is_valid_unit_archetype(elem->>'defending_unit')
    ); END; $$ LANGUAGE plpgsql IMMUTABLE;

-- TYPES

CREATE TYPE "platform_theme_enum" AS ENUM (
  'dark',
  'light'
);

-- TABLES

CREATE TABLE "users" (
  "id" uuid PRIMARY KEY,
  "username" varchar(31) UNIQUE NOT NULL,
  "email" varchar(255) UNIQUE NOT NULL,
  "profile_picture" varchar(511),
  "password" varchar(511) NOT NULL,
  "slug" varchar(63) UNIQUE NOT NULL,
  "platform_theme" platform_theme_enum NOT NULL DEFAULT 'dark',
  "is_enabled" bool NOT NULL DEFAULT (true),
  "is_removed" bool NOT NULL DEFAULT (false),
  "inserted_at" timestamp NOT NULL DEFAULT (CURRENT_TIMESTAMP),
  "updated_at" timestamp NOT NULL DEFAULT (CURRENT_TIMESTAMP),
  CONSTRAINT "chk_users_username_format" CHECK (username ~ '^[ a-zA-Z0-9éÉèÈêÊëËäÄâÂàÀïÏöÖôÔüÜûÛçÇ''’\-_\.&]+$'),
  CONSTRAINT "chk_users_email_format" CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
  CONSTRAINT "chk_users_slug_format" CHECK (slug ~ '^[a-z0-9]+(?:-[a-z0-9]+)*$')
);

CREATE TABLE "kingdoms" (
  "id" uuid PRIMARY KEY,
  "user_id" uuid NOT NULL,
  "leader_id" uuid,
  "name" varchar(63) UNIQUE NOT NULL,
  "slug" varchar(127) UNIQUE NOT NULL,
  "fame" numeric(12,3) NOT NULL DEFAULT (30000.0),
  "defense_troup" integer[] NOT NULL DEFAULT '{0, 0, 0, 0, 0, 0, 0, 0}',
  "attack_troup" integer[] NOT NULL DEFAULT '{0, 0, 0, 0, 0, 0, 0, 0}',
  "is_active" bool NOT NULL DEFAULT (false),
  "is_removed" bool NOT NULL DEFAULT (false),
  "inserted_at" timestamp NOT NULL DEFAULT (CURRENT_TIMESTAMP),
  "updated_at" timestamp NOT NULL DEFAULT (CURRENT_TIMESTAMP),
  CONSTRAINT "chk_kingdoms_name_format" CHECK (name ~ '^[ a-zA-Z0-9éÉèÈêÊëËäÄâÂàÀïÏöÖôÔüÜûÛçÇ''’\-]+$'),
  CONSTRAINT "chk_kingdoms_fame_positive" CHECK (fame >= 0.0),
  CONSTRAINT "chk_kingdoms_slug_format" CHECK (slug ~ '^[a-z0-9]+(?:-[a-z0-9]+)*$'),
  CONSTRAINT "chk_kingdoms_attack_troup_structure" CHECK (array_ndims(attack_troup) = 1 AND array_length(attack_troup, 1) = 8),
  CONSTRAINT "chk_kingdoms_attack_troup_positive_integers" CHECK (0 <= ALL(attack_troup)),
  CONSTRAINT "chk_kingdoms_defense_troup_structure" CHECK (array_ndims(defense_troup) = 1 AND array_length(defense_troup, 1) = 8),
  CONSTRAINT "chk_kingdoms_defense_troup_positive_integers" CHECK (0 <= ALL(defense_troup))
);

CREATE TABLE "battles" (
  "id" uuid PRIMARY KEY,
  "attacker_id" uuid,
  "defender_id" uuid,
  "attacker_initial_troup" integer[] NOT NULL,
  "defender_initial_troup" integer[] NOT NULL,
  "log" jsonb NOT NULL,
  "attacker_final_troup" integer[] NOT NULL,
  "defender_final_troup" integer[] NOT NULL,
  "attacker_wins" bool NOT NULL,
  "inserted_at" timestamp NOT NULL DEFAULT (CURRENT_TIMESTAMP),
  CONSTRAINT "chk_battles_attacker_is_not_defender" CHECK (attacker_id <> defender_id),
  CONSTRAINT "chk_battles_attacker_initial_troup_structure" CHECK (array_ndims(attacker_initial_troup) = 1 AND array_length(attacker_initial_troup, 1) = 8),
  CONSTRAINT "chk_battles_defender_initial_troup_structure" CHECK (array_ndims(defender_initial_troup) = 1 AND array_length(defender_initial_troup, 1) = 8),
  CONSTRAINT "chk_battles_attacker_final_troup_structure" CHECK (array_ndims(attacker_final_troup) = 1 AND array_length(attacker_final_troup, 1) = 8),
  CONSTRAINT "chk_battles_defender_final_troup_structure" CHECK (array_ndims(defender_final_troup) = 1 AND array_length(defender_final_troup, 1) = 8),
  CONSTRAINT "chk_battles_attacker_initial_troup_positive_integers" CHECK (0 <= ALL(attacker_initial_troup)),
  CONSTRAINT "chk_battles_defender_initial_troup_positive_integers" CHECK (0 <= ALL(defender_initial_troup)),
  CONSTRAINT "chk_battles_attacker_final_troup_positive_integers" CHECK (0 <= ALL(attacker_final_troup)),
  CONSTRAINT "chk_battles_defender_final_troup_positive_integers" CHECK (0 <= ALL(defender_final_troup)),
  CONSTRAINT "chk_log_integrity" CHECK (is_valid_battle_log(log))
);


CREATE TABLE "protagonists" (
  "id" uuid PRIMARY KEY,
  "user_id" uuid NOT NULL,
  "kingdom_id" uuid,
  "name" varchar(31) UNIQUE NOT NULL,
  "fame" numeric(12,3) NOT NULL DEFAULT (0.0),
  "slug" varchar(63) UNIQUE NOT NULL,
  "anonymous" bool NOT NULL DEFAULT (true),
  "profile_picture" varchar(511),
  "biography" text,
  "is_removed" bool NOT NULL DEFAULT (false),
  "inserted_at" timestamp NOT NULL DEFAULT (CURRENT_TIMESTAMP),
  "updated_at" timestamp NOT NULL DEFAULT (CURRENT_TIMESTAMP),
  CONSTRAINT "chk_protagonists_biography_length" CHECK (char_length(biography) <= 500000),
  CONSTRAINT "chk_protagonists_fame_positive" CHECK (fame >= 0.0),
  CONSTRAINT "chk_protagonists_slug_format" CHECK (slug ~ '^[a-z0-9]+(?:-[a-z0-9]+)*$')
);

CREATE TABLE "missives" (
  "id" uuid PRIMARY KEY,
  "sender_id" uuid NOT NULL,
  "receiver_id" uuid NOT NULL,
  "content" text NOT NULL,
  "is_read" bool NOT NULL DEFAULT (false),
  "inserted_at" timestamp NOT NULL DEFAULT (CURRENT_TIMESTAMP),
  "updated_at" timestamp NOT NULL DEFAULT (CURRENT_TIMESTAMP),
  CONSTRAINT "chk_missives_content_length" CHECK (char_length(content) <= 10000),
  CONSTRAINT "chk_missives_sender_is_not_receiver" CHECK (sender_id <> receiver_id)
);

CREATE TABLE "chronicles" (
  "id" uuid PRIMARY KEY,
  "gm_id" uuid NOT NULL,
  "user_id" uuid NOT NULL,
  "title" varchar(63) UNIQUE NOT NULL,
  "slug" varchar(127) UNIQUE NOT NULL,
  "description" text,
  "is_removed" bool NOT NULL DEFAULT (false),
  "inserted_at" timestamp NOT NULL DEFAULT (CURRENT_TIMESTAMP),
  "updated_at" timestamp NOT NULL DEFAULT (CURRENT_TIMESTAMP),
  CONSTRAINT "chk_chronicles_description_length" CHECK (char_length(description) <= 15000),
  CONSTRAINT "chk_chronicles_title_format" CHECK (title ~ '^[ a-zA-Z0-9éÉèÈêÊëËäÄâÂàÀïÏöÖôÔüÜûÛçÇ''’\-]+$'),
  CONSTRAINT "chk_chronicles_slug_format" CHECK (slug ~ '^[a-z0-9]+(?:-[a-z0-9]+)*$')
);

CREATE TABLE "protagonists_chronicles" (
  "protagonist_id" uuid,
  "chronicle_id" uuid,
  PRIMARY KEY ("protagonist_id", "chronicle_id")
);

CREATE TABLE "chapters" (
  "id" uuid PRIMARY KEY,
  "chronicle_id" uuid NOT NULL,
  "protagonist_id" uuid NOT NULL,
  "content" text NOT NULL,
  "inserted_at" timestamp NOT NULL DEFAULT (CURRENT_TIMESTAMP),
  "updated_at" timestamp NOT NULL DEFAULT (CURRENT_TIMESTAMP),
  CONSTRAINT "chk_chapters_content_length" CHECK (char_length(content) <= 25000)
);

CREATE TABLE "chapters_views" (
  "chapter_id" uuid,
  "user_id" uuid,
  "inserted_at" timestamp NOT NULL DEFAULT (CURRENT_TIMESTAMP),
  PRIMARY KEY ("chapter_id", "user_id")
);

CREATE TABLE "boards" (
  "id" uuid PRIMARY KEY,
  "user_id" uuid NOT NULL,
  "title" varchar(63) UNIQUE NOT NULL,
  "description" varchar(511) NOT NULL,
  "slug" varchar(127) UNIQUE NOT NULL,
  "is_removed" bool NOT NULL DEFAULT (false),
  "inserted_at" timestamp NOT NULL DEFAULT (CURRENT_TIMESTAMP),
  "updated_at" timestamp NOT NULL DEFAULT (CURRENT_TIMESTAMP),
  CONSTRAINT "chk_boards_slug_format" CHECK (slug ~ '^[a-z0-9]+(?:-[a-z0-9]+)*$')
);

CREATE TABLE "threads" (
  "id" uuid PRIMARY KEY,
  "user_id" uuid NOT NULL,
  "board_id" uuid NOT NULL,
  "title" varchar(63) NOT NULL,
  "slug" varchar(127) UNIQUE NOT NULL,
  "is_removed" bool NOT NULL DEFAULT (false),
  "inserted_at" timestamp NOT NULL DEFAULT (CURRENT_TIMESTAMP),
  "updated_at" timestamp NOT NULL DEFAULT (CURRENT_TIMESTAMP),
  CONSTRAINT "chk_threads_slug_format" CHECK (slug ~ '^[a-z0-9]+(?:-[a-z0-9]+)*$')
);

CREATE TABLE "posts" (
  "id" uuid PRIMARY KEY,
  "user_id" uuid NOT NULL,
  "thread_id" uuid NOT NULL,
  "content" text NOT NULL,
  CONSTRAINT "chk_posts_content_length" CHECK (char_length(content) <= 10000)
);

CREATE TABLE "sessions" (
  "id" uuid PRIMARY KEY,
  "user_id" uuid NOT NULL,
  "token" bytea UNIQUE NOT NULL,
  "context" varchar(31) NOT NULL DEFAULT ('session'),
  "ip_address" inet,
  "user_agent" varchar(511),
  "expires_at" timestamp NOT NULL,
  "inserted_at" timestamp NOT NULL DEFAULT (CURRENT_TIMESTAMP)
);

-- INDEXES

CREATE UNIQUE INDEX "idx_only_one_active_kingdom_per_user" ON "kingdoms" ("user_id") WHERE "is_active" = true;

CREATE INDEX "idx_kingdoms_user_id" ON "kingdoms" ("user_id");

CREATE INDEX "idx_kingdoms_leader_id" ON "kingdoms" ("leader_id");

CREATE INDEX "idx_battles_attacker_id" ON "battles" ("attacker_id");

CREATE INDEX "idx_battles_defender_id" ON "battles" ("defender_id");

CREATE UNIQUE INDEX "idx_protagonists_id_user_id" ON "protagonists" ("id", "user_id");

CREATE INDEX "idx_protagonists_user_id" ON "protagonists" ("user_id");

CREATE INDEX "idx_protagonists_kingdom_id" ON "protagonists" ("kingdom_id");

CREATE INDEX "idx_missives_sender_id" ON "missives" ("sender_id");

CREATE INDEX "idx_missives_receiver_id" ON "missives" ("receiver_id");

CREATE INDEX "idx_chronicles_gm_id" ON "chronicles" ("gm_id");

CREATE INDEX "idx_chronicles_user_id" ON "chronicles" ("user_id");

CREATE INDEX "idx_chapters_chronicle_id" ON "chapters" ("chronicle_id");

CREATE INDEX "idx_chapters_protagonist_id" ON "chapters" ("protagonist_id");

CREATE INDEX "idx_boards_user_id" ON "boards" ("user_id");

CREATE INDEX "idx_threads_user_id" ON "threads" ("user_id");

CREATE INDEX "idx_threads_board_id" ON "threads" ("board_id");

CREATE INDEX "idx_posts_user_id" ON "posts" ("user_id");

CREATE INDEX "idx_posts_thread_id" ON "posts" ("thread_id");

CREATE INDEX "sessions_user_id" ON "sessions" ("user_id");

-- FOREIGN KEYS

ALTER TABLE "kingdoms" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id");

ALTER TABLE "kingdoms" ADD FOREIGN KEY ("leader_id") REFERENCES "protagonists" ("id");

ALTER TABLE "kingdoms" ADD FOREIGN KEY ("leader_id", "user_id") REFERENCES "protagonists" ("id", "user_id");

ALTER TABLE "battles" ADD FOREIGN KEY ("attacker_id") REFERENCES "kingdoms" ("id");

ALTER TABLE "battles" ADD FOREIGN KEY ("defender_id") REFERENCES "kingdoms" ("id");

ALTER TABLE "protagonists" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id");

ALTER TABLE "protagonists" ADD FOREIGN KEY ("kingdom_id") REFERENCES "kingdoms" ("id");

ALTER TABLE "missives" ADD FOREIGN KEY ("sender_id") REFERENCES "kingdoms" ("id");

ALTER TABLE "missives" ADD FOREIGN KEY ("receiver_id") REFERENCES "kingdoms" ("id");

ALTER TABLE "chronicles" ADD FOREIGN KEY ("gm_id") REFERENCES "users" ("id");

ALTER TABLE "chronicles" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id");

ALTER TABLE "protagonists_chronicles" ADD FOREIGN KEY ("protagonist_id") REFERENCES "protagonists" ("id");

ALTER TABLE "protagonists_chronicles" ADD FOREIGN KEY ("chronicle_id") REFERENCES "chronicles" ("id");

ALTER TABLE "chapters" ADD FOREIGN KEY ("chronicle_id") REFERENCES "chronicles" ("id");

ALTER TABLE "chapters" ADD FOREIGN KEY ("protagonist_id") REFERENCES "protagonists" ("id");

ALTER TABLE "chapters_views" ADD FOREIGN KEY ("chapter_id") REFERENCES "chapters" ("id");

ALTER TABLE "chapters_views" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id");

ALTER TABLE "boards" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id");

ALTER TABLE "threads" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id");

ALTER TABLE "threads" ADD FOREIGN KEY ("board_id") REFERENCES "boards" ("id");

ALTER TABLE "posts" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id");

ALTER TABLE "posts" ADD FOREIGN KEY ("thread_id") REFERENCES "threads" ("id");

ALTER TABLE "sessions" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id");

-- VIEWS

-- Todo: to be tested
CREATE OR REPLACE VIEW battle_log_notation_view AS
WITH raw_data AS (
  SELECT 
    id AS battle_id,
    attacker_id,
    defender_id,
    split_part(log::text, '\n', 1) as line_initial,
    split_part(log::text, '\n', 2) as line_log,
    split_part(log::text, '\n', 3) as line_final,
    (split_part(log::text, '\n', 4) = '1') as attacker_won
  FROM battles
),
log_steps AS (
  SELECT 
    battle_id,
    trim(s.step) as step_raw,
    s.idx as step_order
  FROM raw_data,
  unnest(string_to_array(trim(line_log), ' ')) WITH ORDINALITY AS s(step, idx)
)
SELECT 
    ls.battle_id,
    ls.step_order,
    split_part(ls.step_raw, '/', 1) as unit_1,
    split_part(ls.step_raw, '/', 2) as unit_2,
    format(
        split_part(ls.step_raw, '/', 1),
        split_part(ls.step_raw, '/', 2),
        array_length(string_to_array(ls.step_raw, '/'), 1) - 2
    ) as summary_text
FROM log_steps ls
WHERE ls.step_raw <> '';
