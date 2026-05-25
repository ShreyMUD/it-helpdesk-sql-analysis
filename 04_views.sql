-- ============================================================
-- IT HELP DESK TICKET ANALYTICS
-- Reusable Views  (for BI tools / dashboards)
-- Author  : Shreyas Mudliar
-- ============================================================

-- ── VW 1: Full denormalized ticket detail ────────────────────
CREATE OR REPLACE VIEW vw_ticket_detail AS
SELECT
    t.ticket_id,
    t.title,
    t.priority,
    t.status,
    t.escalated,
    t.satisfaction_score,
    c.category_name,
    c.subcategory,
    u.full_name                                                     AS raised_by,
    ud.department_name                                              AS user_department,
    u.location                                                      AS user_location,
    a.full_name                                                     AS assigned_agent,
    a.tier                                                          AS agent_tier,
    t.created_at,
    t.first_response_at,
    t.resolved_at,
    t.closed_at,
    ROUND(EXTRACT(EPOCH FROM
        (COALESCE(t.first_response_at, NOW()) - t.created_at)
    )/3600::NUMERIC, 2)                                             AS hours_to_first_response,
    ROUND(EXTRACT(EPOCH FROM
        (COALESCE(t.resolved_at, NOW()) - t.created_at)
    )/3600::NUMERIC, 2)                                             AS hours_to_resolve,
    TO_CHAR(t.created_at, 'YYYY-MM')                                AS created_month,
    EXTRACT(DOW FROM t.created_at)                                  AS created_day_of_week,
    EXTRACT(HOUR FROM t.created_at)                                 AS created_hour
FROM tickets       t
JOIN categories    c  ON t.category_id       = c.category_id
JOIN users         u  ON t.user_id           = u.user_id
JOIN departments   ud ON u.department_id     = ud.department_id
LEFT JOIN agents   a  ON t.assigned_agent_id = a.agent_id;


-- ── VW 2: SLA compliance per ticket ─────────────────────────
CREATE OR REPLACE VIEW vw_sla_compliance AS
SELECT
    t.ticket_id,
    t.priority,
    s.response_hours                                                AS response_sla_hrs,
    s.resolution_hours                                              AS resolution_sla_hrs,
    ROUND(EXTRACT(EPOCH FROM
        (t.first_response_at - t.created_at)
    )/3600::NUMERIC, 2)                                             AS actual_response_hrs,
    ROUND(EXTRACT(EPOCH FROM
        (t.resolved_at - t.created_at)
    )/3600::NUMERIC, 2)                                             AS actual_resolution_hrs,
    CASE
        WHEN t.first_response_at IS NULL THEN 'Pending'
        WHEN EXTRACT(EPOCH FROM (t.first_response_at - t.created_at))/3600
             <= s.response_hours THEN 'Met'
        ELSE 'Breached'
    END                                                             AS response_sla_status,
    CASE
        WHEN t.resolved_at IS NULL THEN 'Pending'
        WHEN EXTRACT(EPOCH FROM (t.resolved_at - t.created_at))/3600
             <= s.resolution_hours THEN 'Met'
        ELSE 'Breached'
    END                                                             AS resolution_sla_status
FROM tickets t
JOIN sla_policies s ON t.priority = s.priority;


-- ── VW 3: Agent scorecard ────────────────────────────────────
CREATE OR REPLACE VIEW vw_agent_scorecard AS
SELECT
    a.agent_id,
    a.full_name,
    a.tier,
    COUNT(t.ticket_id)                                              AS total_assigned,
    COUNT(t.ticket_id) FILTER (WHERE t.status = 'Closed')          AS tickets_closed,
    COUNT(t.ticket_id) FILTER (WHERE t.status IN ('Open','In Progress')) AS tickets_active,
    ROUND(
        COUNT(t.ticket_id) FILTER (WHERE t.status = 'Closed') * 100.0
        / NULLIF(COUNT(t.ticket_id), 0), 1
    )                                                               AS closure_rate_pct,
    ROUND(AVG(t.satisfaction_score)
          FILTER (WHERE t.satisfaction_score IS NOT NULL)::NUMERIC, 2)
                                                                    AS avg_csat,
    ROUND(AVG(EXTRACT(EPOCH FROM (t.resolved_at - t.created_at))/3600)
          FILTER (WHERE t.resolved_at IS NOT NULL)::NUMERIC, 1)    AS avg_resolve_hrs,
    COUNT(t.ticket_id) FILTER (WHERE t.escalated = TRUE)           AS escalations_handled
FROM agents a
LEFT JOIN tickets t ON a.agent_id = t.assigned_agent_id
GROUP BY a.agent_id, a.full_name, a.tier;


-- ── VW 4: Monthly KPI summary (for trend charts) ─────────────
CREATE OR REPLACE VIEW vw_monthly_kpis AS
SELECT
    TO_CHAR(created_at, 'YYYY-MM')                                  AS month,
    COUNT(*)                                                        AS total_tickets,
    COUNT(*) FILTER (WHERE status = 'Closed')                       AS closed_tickets,
    COUNT(*) FILTER (WHERE priority = 'Critical')                   AS critical_tickets,
    COUNT(*) FILTER (WHERE escalated = TRUE)                        AS escalations,
    ROUND(AVG(satisfaction_score)
          FILTER (WHERE satisfaction_score IS NOT NULL)::NUMERIC, 2) AS avg_csat,
    ROUND(AVG(EXTRACT(EPOCH FROM (resolved_at - created_at))/3600)
          FILTER (WHERE resolved_at IS NOT NULL)::NUMERIC, 1)       AS avg_resolve_hrs
FROM tickets
GROUP BY TO_CHAR(created_at, 'YYYY-MM')
ORDER BY month;
