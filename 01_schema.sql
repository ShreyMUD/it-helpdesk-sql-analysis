-- ============================================================
-- IT HELP DESK TICKET ANALYTICS
-- Schema Definition
-- Author  : Shreyas Mudliar
-- DB      : PostgreSQL 15+
-- Purpose : Model a corporate IT help desk system to support
--           operational reporting and performance analysis
-- ============================================================

-- ── DEPARTMENTS ─────────────────────────────────────────────
CREATE TABLE departments (
    department_id   SERIAL          PRIMARY KEY,
    department_name VARCHAR(100)    NOT NULL,
    location        VARCHAR(100)    NOT NULL
);

-- ── AGENTS (IT Support Staff) ────────────────────────────────
CREATE TABLE agents (
    agent_id        SERIAL          PRIMARY KEY,
    full_name       VARCHAR(100)    NOT NULL,
    email           VARCHAR(150)    UNIQUE NOT NULL,
    tier            VARCHAR(10)     NOT NULL CHECK (tier IN ('L1','L2','L3')),
    department_id   INT             REFERENCES departments(department_id),
    hired_date      DATE            NOT NULL,
    is_active       BOOLEAN         DEFAULT TRUE
);

-- ── END USERS (Employees raising tickets) ───────────────────
CREATE TABLE users (
    user_id         SERIAL          PRIMARY KEY,
    full_name       VARCHAR(100)    NOT NULL,
    email           VARCHAR(150)    UNIQUE NOT NULL,
    department_id   INT             REFERENCES departments(department_id),
    location        VARCHAR(100)
);

-- ── CATEGORIES ──────────────────────────────────────────────
CREATE TABLE categories (
    category_id     SERIAL          PRIMARY KEY,
    category_name   VARCHAR(100)    NOT NULL,
    subcategory     VARCHAR(100)
);

-- ── SLA POLICIES ────────────────────────────────────────────
-- Defines expected response + resolution times per priority level
CREATE TABLE sla_policies (
    sla_id              SERIAL      PRIMARY KEY,
    priority            VARCHAR(10) NOT NULL CHECK (priority IN ('Critical','High','Medium','Low')),
    response_hours      NUMERIC(5,2) NOT NULL,   -- target first-response SLA (business hours)
    resolution_hours    NUMERIC(5,2) NOT NULL    -- target resolution SLA (business hours)
);

-- ── TICKETS ─────────────────────────────────────────────────
CREATE TABLE tickets (
    ticket_id           SERIAL          PRIMARY KEY,
    title               VARCHAR(255)    NOT NULL,
    description         TEXT,
    category_id         INT             REFERENCES categories(category_id),
    priority            VARCHAR(10)     NOT NULL CHECK (priority IN ('Critical','High','Medium','Low')),
    status              VARCHAR(20)     NOT NULL CHECK (status IN ('Open','In Progress','Resolved','Closed','Escalated')),
    user_id             INT             REFERENCES users(user_id),
    assigned_agent_id   INT             REFERENCES agents(agent_id),
    created_at          TIMESTAMP       NOT NULL DEFAULT NOW(),
    first_response_at   TIMESTAMP,
    resolved_at         TIMESTAMP,
    closed_at           TIMESTAMP,
    escalated           BOOLEAN         DEFAULT FALSE,
    satisfaction_score  SMALLINT        CHECK (satisfaction_score BETWEEN 1 AND 5)
);

-- ── TICKET COMMENTS (audit trail) ────────────────────────────
CREATE TABLE ticket_comments (
    comment_id      SERIAL      PRIMARY KEY,
    ticket_id       INT         REFERENCES tickets(ticket_id),
    author_type     VARCHAR(10) CHECK (author_type IN ('Agent','User')),
    author_id       INT         NOT NULL,
    comment_text    TEXT        NOT NULL,
    created_at      TIMESTAMP   NOT NULL DEFAULT NOW()
);

-- ── INDEXES ─────────────────────────────────────────────────
CREATE INDEX idx_tickets_status       ON tickets(status);
CREATE INDEX idx_tickets_priority     ON tickets(priority);
CREATE INDEX idx_tickets_created_at   ON tickets(created_at);
CREATE INDEX idx_tickets_agent        ON tickets(assigned_agent_id);
CREATE INDEX idx_tickets_user         ON tickets(user_id);
CREATE INDEX idx_tickets_category     ON tickets(category_id);
