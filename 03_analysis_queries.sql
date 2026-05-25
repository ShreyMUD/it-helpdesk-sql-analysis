-- ============================================================
-- IT HELP DESK TICKET ANALYTICS
-- Analysis Queries  (Basic → Intermediate → Advanced)
-- Author  : Shreyas Mudliar
-- ============================================================


-- ════════════════════════════════════════════════════════════
-- SECTION 1 — BASIC  (Aggregations, Filtering, Sorting)
-- ════════════════════════════════════════════════════════════

-- ── Q1: Total tickets by current status ─────────────────────
SELECT
    status,
    COUNT(*) AS ticket_count
FROM tickets
GROUP BY status
ORDER BY ticket_count DESC;


-- ── Q2: Ticket volume by priority ───────────────────────────
SELECT
    priority,
    COUNT(*) AS total_tickets,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 1) AS pct_of_total
FROM tickets
GROUP BY priority
ORDER BY
    CASE priority
        WHEN 'Critical' THEN 1
        WHEN 'High'     THEN 2
        WHEN 'Medium'   THEN 3
        WHEN 'Low'      THEN 4
    END;


-- ── Q3: Top 5 ticket categories by volume ───────────────────
SELECT
    c.category_name,
    c.subcategory,
    COUNT(t.ticket_id) AS ticket_count
FROM tickets t
JOIN categories c ON t.category_id = c.category_id
GROUP BY c.category_name, c.subcategory
ORDER BY ticket_count DESC
LIMIT 5;


-- ── Q4: Monthly ticket volume trend (2024) ──────────────────
SELECT
    TO_CHAR(created_at, 'YYYY-MM') AS month,
    COUNT(*)                        AS tickets_raised,
    COUNT(*) FILTER (WHERE priority = 'Critical') AS critical_count,
    COUNT(*) FILTER (WHERE status IN ('Open','In Progress','Escalated')) AS still_open
FROM tickets
WHERE created_at >= '2024-01-01'
GROUP BY month
ORDER BY month;


-- ── Q5: All open and in-progress tickets with agent info ─────
SELECT
    t.ticket_id,
    t.title,
    t.priority,
    t.status,
    a.full_name     AS assigned_agent,
    a.tier          AS agent_tier,
    t.created_at,
    NOW() - t.created_at AS age
FROM tickets t
LEFT JOIN agents a ON t.assigned_agent_id = a.agent_id
WHERE t.status IN ('Open', 'In Progress', 'Escalated')
ORDER BY
    CASE t.priority WHEN 'Critical' THEN 1 WHEN 'High' THEN 2 WHEN 'Medium' THEN 3 ELSE 4 END,
    t.created_at;


-- ════════════════════════════════════════════════════════════
-- SECTION 2 — INTERMEDIATE  (JOINs, CASE, Date Functions)
-- ════════════════════════════════════════════════════════════

-- ── Q6: Average resolution time by priority (hours) ─────────
SELECT
    priority,
    COUNT(*)                                                        AS resolved_tickets,
    ROUND(AVG(EXTRACT(EPOCH FROM (resolved_at - created_at))/3600)::NUMERIC, 2)
                                                                    AS avg_resolution_hrs,
    ROUND(MIN(EXTRACT(EPOCH FROM (resolved_at - created_at))/3600)::NUMERIC, 2)
                                                                    AS min_resolution_hrs,
    ROUND(MAX(EXTRACT(EPOCH FROM (resolved_at - created_at))/3600)::NUMERIC, 2)
                                                                    AS max_resolution_hrs
FROM tickets
WHERE resolved_at IS NOT NULL
GROUP BY priority
ORDER BY
    CASE priority WHEN 'Critical' THEN 1 WHEN 'High' THEN 2 WHEN 'Medium' THEN 3 ELSE 4 END;


-- ── Q7: Agent workload and resolution performance ────────────
SELECT
    a.full_name,
    a.tier,
    COUNT(t.ticket_id)                                              AS total_assigned,
    COUNT(t.ticket_id) FILTER (WHERE t.status = 'Closed')          AS closed_count,
    COUNT(t.ticket_id) FILTER (WHERE t.status IN ('Open','In Progress')) AS active_count,
    ROUND(
        COUNT(t.ticket_id) FILTER (WHERE t.status = 'Closed') * 100.0
        / NULLIF(COUNT(t.ticket_id), 0), 1
    )                                                               AS closure_rate_pct,
    ROUND(
        AVG(EXTRACT(EPOCH FROM (t.resolved_at - t.created_at))/3600
        ) FILTER (WHERE t.resolved_at IS NOT NULL)::NUMERIC, 1
    )                                                               AS avg_resolve_hrs
FROM agents a
LEFT JOIN tickets t ON a.agent_id = t.assigned_agent_id
GROUP BY a.agent_id, a.full_name, a.tier
ORDER BY total_assigned DESC;


-- ── Q8: SLA compliance — did we meet the resolution target? ──
SELECT
    t.ticket_id,
    t.priority,
    s.resolution_hours                                              AS sla_target_hrs,
    ROUND(
        EXTRACT(EPOCH FROM (t.resolved_at - t.created_at))/3600
    ::NUMERIC, 2)                                                   AS actual_hrs,
    CASE
        WHEN EXTRACT(EPOCH FROM (t.resolved_at - t.created_at))/3600
             <= s.resolution_hours THEN 'Met'
        ELSE 'Breached'
    END                                                             AS sla_status
FROM tickets t
JOIN sla_policies s ON t.priority = s.priority
WHERE t.resolved_at IS NOT NULL
ORDER BY t.priority, actual_hrs DESC;


-- ── Q9: SLA breach rate by priority ─────────────────────────
SELECT
    t.priority,
    COUNT(*)                                                        AS resolved_tickets,
    COUNT(*) FILTER (
        WHERE EXTRACT(EPOCH FROM (t.resolved_at - t.created_at))/3600 > s.resolution_hours
    )                                                               AS breached,
    ROUND(
        COUNT(*) FILTER (
            WHERE EXTRACT(EPOCH FROM (t.resolved_at - t.created_at))/3600 > s.resolution_hours
        ) * 100.0 / COUNT(*), 1
    )                                                               AS breach_rate_pct
FROM tickets t
JOIN sla_policies s ON t.priority = s.priority
WHERE t.resolved_at IS NOT NULL
GROUP BY t.priority
ORDER BY
    CASE t.priority WHEN 'Critical' THEN 1 WHEN 'High' THEN 2 WHEN 'Medium' THEN 3 ELSE 4 END;


-- ── Q10: Tickets per department — raised vs resolved ─────────
SELECT
    d.department_name,
    COUNT(t.ticket_id)                                              AS tickets_raised,
    COUNT(t.ticket_id) FILTER (WHERE t.status = 'Closed')          AS tickets_resolved,
    ROUND(AVG(t.satisfaction_score) FILTER (
        WHERE t.satisfaction_score IS NOT NULL), 2)                 AS avg_satisfaction
FROM departments d
JOIN users u       ON d.department_id = u.department_id
JOIN tickets t     ON u.user_id       = t.user_id
GROUP BY d.department_name
ORDER BY tickets_raised DESC;


-- ── Q11: First Response Time vs SLA target ───────────────────
SELECT
    t.priority,
    s.response_hours                                                AS response_sla_hrs,
    ROUND(
        AVG(EXTRACT(EPOCH FROM (t.first_response_at - t.created_at))/3600
        )::NUMERIC, 2)                                              AS avg_first_response_hrs,
    COUNT(*) FILTER (
        WHERE EXTRACT(EPOCH FROM (t.first_response_at - t.created_at))/3600
              > s.response_hours
    )                                                               AS response_sla_breaches
FROM tickets t
JOIN sla_policies s ON t.priority = s.priority
WHERE t.first_response_at IS NOT NULL
GROUP BY t.priority, s.response_hours
ORDER BY
    CASE t.priority WHEN 'Critical' THEN 1 WHEN 'High' THEN 2 WHEN 'Medium' THEN 3 ELSE 4 END;


-- ════════════════════════════════════════════════════════════
-- SECTION 3 — ADVANCED  (CTEs, Window Functions, Subqueries)
-- ════════════════════════════════════════════════════════════

-- ── Q12: Running total of tickets per month (Window Function) ─
SELECT
    TO_CHAR(created_at, 'YYYY-MM')   AS month,
    COUNT(*)                          AS monthly_tickets,
    SUM(COUNT(*)) OVER (
        ORDER BY TO_CHAR(created_at, 'YYYY-MM')
    )                                 AS running_total,
    ROUND(
        AVG(COUNT(*)) OVER (
            ORDER BY TO_CHAR(created_at, 'YYYY-MM')
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ), 1
    )                                 AS rolling_3m_avg
FROM tickets
GROUP BY TO_CHAR(created_at, 'YYYY-MM')
ORDER BY month;


-- ── Q13: Agent performance ranking using RANK() ──────────────
WITH agent_stats AS (
    SELECT
        a.full_name,
        a.tier,
        COUNT(t.ticket_id) FILTER (WHERE t.status = 'Closed')  AS closed_tickets,
        ROUND(AVG(t.satisfaction_score)
              FILTER (WHERE t.satisfaction_score IS NOT NULL)
              ::NUMERIC, 2)                                     AS avg_csat,
        ROUND(AVG(
            EXTRACT(EPOCH FROM (t.resolved_at - t.created_at))/3600
        ) FILTER (WHERE t.resolved_at IS NOT NULL)::NUMERIC, 1) AS avg_resolve_hrs
    FROM agents a
    LEFT JOIN tickets t ON a.agent_id = t.assigned_agent_id
    GROUP BY a.agent_id, a.full_name, a.tier
)
SELECT
    full_name,
    tier,
    closed_tickets,
    avg_csat,
    avg_resolve_hrs,
    RANK() OVER (ORDER BY avg_csat DESC NULLS LAST)       AS csat_rank,
    RANK() OVER (ORDER BY avg_resolve_hrs ASC NULLS LAST) AS speed_rank
FROM agent_stats
ORDER BY csat_rank;


-- ── Q14: Repeat issue detection (same user, same category) ───
WITH repeat_users AS (
    SELECT
        u.full_name          AS user_name,
        c.category_name,
        c.subcategory,
        COUNT(t.ticket_id)   AS ticket_count,
        MIN(t.created_at)    AS first_ticket,
        MAX(t.created_at)    AS latest_ticket
    FROM tickets t
    JOIN users      u ON t.user_id      = u.user_id
    JOIN categories c ON t.category_id  = c.category_id
    GROUP BY u.full_name, c.category_name, c.subcategory
    HAVING COUNT(t.ticket_id) > 1
)
SELECT *
FROM repeat_users
ORDER BY ticket_count DESC;


-- ── Q15: Escalation rate and profile ─────────────────────────
WITH esc_summary AS (
    SELECT
        t.priority,
        c.category_name,
        COUNT(*)                                            AS total,
        COUNT(*) FILTER (WHERE t.escalated = TRUE)         AS escalated_count
    FROM tickets t
    JOIN categories c ON t.category_id = c.category_id
    GROUP BY t.priority, c.category_name
)
SELECT
    priority,
    category_name,
    total,
    escalated_count,
    ROUND(escalated_count * 100.0 / NULLIF(total,0), 1)    AS escalation_pct
FROM esc_summary
WHERE escalated_count > 0
ORDER BY escalation_pct DESC;


-- ── Q16: Monthly CSAT trend with MoM change ──────────────────
WITH monthly_csat AS (
    SELECT
        TO_CHAR(created_at, 'YYYY-MM')          AS month,
        ROUND(AVG(satisfaction_score)::NUMERIC, 2) AS avg_csat
    FROM tickets
    WHERE satisfaction_score IS NOT NULL
    GROUP BY TO_CHAR(created_at, 'YYYY-MM')
)
SELECT
    month,
    avg_csat,
    LAG(avg_csat) OVER (ORDER BY month)   AS prev_month_csat,
    ROUND(avg_csat - LAG(avg_csat) OVER (ORDER BY month), 2) AS mom_change
FROM monthly_csat
ORDER BY month;


-- ── Q17: Ticket age buckets — outstanding tickets ────────────
SELECT
    CASE
        WHEN NOW() - created_at < INTERVAL '1 day'   THEN '< 1 day'
        WHEN NOW() - created_at < INTERVAL '3 days'  THEN '1–3 days'
        WHEN NOW() - created_at < INTERVAL '7 days'  THEN '3–7 days'
        WHEN NOW() - created_at < INTERVAL '14 days' THEN '7–14 days'
        ELSE '> 14 days'
    END                         AS age_bucket,
    priority,
    COUNT(*)                    AS ticket_count
FROM tickets
WHERE status IN ('Open', 'In Progress', 'Escalated')
GROUP BY age_bucket, priority
ORDER BY
    CASE age_bucket
        WHEN '> 14 days' THEN 1  WHEN '7–14 days' THEN 2
        WHEN '3–7 days'  THEN 3  WHEN '1–3 days'  THEN 4
        ELSE 5 END,
    CASE priority WHEN 'Critical' THEN 1 WHEN 'High' THEN 2 WHEN 'Medium' THEN 3 ELSE 4 END;


-- ── Q18: Category heat map — volume vs resolution time ───────
SELECT
    c.category_name,
    c.subcategory,
    COUNT(t.ticket_id)                                                  AS total_tickets,
    COUNT(t.ticket_id) FILTER (WHERE t.status = 'Closed')               AS closed,
    ROUND(AVG(
        EXTRACT(EPOCH FROM (t.resolved_at - t.created_at))/3600
    ) FILTER (WHERE t.resolved_at IS NOT NULL)::NUMERIC, 1)             AS avg_resolve_hrs,
    ROUND(AVG(t.satisfaction_score)
          FILTER (WHERE t.satisfaction_score IS NOT NULL)::NUMERIC, 2)  AS avg_csat,
    ROUND(
        COUNT(t.ticket_id) FILTER (WHERE t.status = 'Closed') * 100.0
        / NULLIF(COUNT(t.ticket_id), 0), 1
    )                                                                    AS closure_pct
FROM categories c
JOIN tickets t ON c.category_id = t.category_id
GROUP BY c.category_name, c.subcategory
ORDER BY total_tickets DESC;


-- ── Q19: Security incident response audit ────────────────────
-- Identifies all security-related tickets and checks Critical SLA
SELECT
    t.ticket_id,
    t.title,
    t.priority,
    t.status,
    a.full_name                                                     AS agent,
    t.created_at,
    t.first_response_at,
    ROUND(
        EXTRACT(EPOCH FROM (t.first_response_at - t.created_at))/60
    ::NUMERIC, 1)                                                   AS first_response_mins,
    CASE
        WHEN t.first_response_at IS NULL THEN 'No Response Yet'
        WHEN EXTRACT(EPOCH FROM (t.first_response_at - t.created_at))/3600
             <= s.response_hours THEN 'SLA Met'
        ELSE 'SLA Breached'
    END                                                             AS response_sla
FROM tickets t
JOIN categories   c ON t.category_id        = c.category_id
JOIN sla_policies s ON t.priority           = s.priority
LEFT JOIN agents  a ON t.assigned_agent_id  = a.agent_id
WHERE c.category_name = 'Security'
ORDER BY t.created_at DESC;


-- ── Q20: Executive summary — KPI dashboard view ──────────────
WITH kpis AS (
    SELECT
        COUNT(*)                                            AS total_tickets,
        COUNT(*) FILTER (WHERE status = 'Closed')          AS closed_tickets,
        COUNT(*) FILTER (WHERE status IN ('Open','In Progress','Escalated'))
                                                            AS open_tickets,
        COUNT(*) FILTER (WHERE priority = 'Critical')      AS critical_tickets,
        COUNT(*) FILTER (WHERE escalated = TRUE)           AS escalations,
        ROUND(AVG(satisfaction_score)
              FILTER (WHERE satisfaction_score IS NOT NULL)::NUMERIC, 2)
                                                            AS avg_csat,
        ROUND(AVG(
            EXTRACT(EPOCH FROM (resolved_at - created_at))/3600
        ) FILTER (WHERE resolved_at IS NOT NULL)::NUMERIC, 1)
                                                            AS avg_resolve_hrs
    FROM tickets
)
SELECT
    total_tickets,
    closed_tickets,
    open_tickets,
    ROUND(closed_tickets * 100.0 / NULLIF(total_tickets, 0), 1) AS closure_rate_pct,
    critical_tickets,
    escalations,
    ROUND(escalations * 100.0 / NULLIF(total_tickets, 0), 1)    AS escalation_rate_pct,
    avg_csat,
    avg_resolve_hrs
FROM kpis;
