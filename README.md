# 🖥️ IT Help Desk Ticket Analytics — SQL Project

**Author:** Shreyas Mudliar  
**Database:** PostgreSQL 15+  
**Skill Level:** Beginner → Advanced SQL  
**Domain:** IT Operations / Data Analytics  

---

## 📌 Project Overview

This project models and analyses a **corporate IT Help Desk ticketing system** using SQL. It covers the full data lifecycle — schema design, data loading, and business-driven analysis — simulating the kind of work a Data Analyst would perform inside an IT Operations or Business Intelligence team.

The dataset represents 7 months of IT support activity across multiple departments, agents, and ticket types — answering real operational questions that IT managers and executives care about.

---

## 🗂️ Project Structure

```
it-helpdesk-sql-analysis/
├── 01_schema.sql          # Table definitions, constraints, indexes
├── 02_seed_data.sql       # Realistic sample data (35 tickets)
├── 03_analysis_queries.sql # 20 analytical queries (Basic → Advanced)
├── 04_views.sql           # 4 reusable views for BI/dashboards
└── README.md
```

---

## 🏗️ Database Schema

```
departments ──┐
              ├── users ──────── tickets ──── categories
              └── agents ──────────┘              │
                                                  └── sla_policies
                                    ticket_comments (audit trail)
```

### Tables

| Table | Description |
|-------|-------------|
| `departments` | Organisational units (Finance, HR, Sales, etc.) |
| `agents` | IT support staff with tiering (L1 / L2 / L3) |
| `users` | Employees who raise support tickets |
| `categories` | Ticket classification (Hardware, Network, Security, etc.) |
| `sla_policies` | Response & resolution SLA targets per priority level |
| `tickets` | Core table — all support tickets with timestamps |
| `ticket_comments` | Audit trail for agent/user communications |

---

## 📊 Business Questions Answered

### Section 1 — Basic
| # | Question |
|---|----------|
| Q1 | What is the current breakdown of tickets by status? |
| Q2 | How are tickets distributed across priority levels? |
| Q3 | Which ticket categories generate the most volume? |
| Q4 | What is the monthly ticket volume trend? |
| Q5 | Which tickets are currently open or in progress? |

### Section 2 — Intermediate
| # | Question |
|---|----------|
| Q6 | What is the average resolution time by priority? |
| Q7 | How is each agent performing (workload + closure rate)? |
| Q8 | Did individual tickets meet their SLA resolution target? |
| Q9 | What is the SLA breach rate by priority level? |
| Q10 | Which departments raise the most tickets — and what's their CSAT? |
| Q11 | Are first response time targets being met? |

### Section 3 — Advanced
| # | Question |
|---|----------|
| Q12 | Running total + 3-month rolling average of ticket volume (Window Function) |
| Q13 | Agent performance ranking by CSAT and speed (RANK + CTE) |
| Q14 | Which users are raising repeat tickets in the same category? |
| Q15 | What is the escalation rate by priority and category? |
| Q16 | Monthly CSAT trend with month-over-month change (LAG) |
| Q17 | How old are current open/in-progress tickets (age bucketing)? |
| Q18 | Category heat map — volume vs resolution time vs CSAT |
| Q19 | Security incident response audit — SLA compliance check |
| Q20 | Executive KPI summary dashboard |

---

## 🧠 SQL Concepts Demonstrated

| Concept | Used In |
|---------|---------|
| `GROUP BY` + Aggregates | Q1–Q5, Q7–Q11 |
| `JOIN` (INNER, LEFT) | Q3, Q5, Q7–Q11 |
| `CASE` statements | Q2, Q5, Q8, Q17 |
| Date/time arithmetic | Q6, Q7, Q8, Q11 |
| `FILTER (WHERE ...)` | Q4, Q7, Q9–Q11 |
| `WINDOW FUNCTIONS` (`SUM OVER`, `AVG OVER`, `RANK`, `LAG`) | Q2, Q12–Q13, Q16 |
| `CTEs` (Common Table Expressions) | Q13–Q16, Q20 |
| Subqueries | Q14 |
| `HAVING` | Q14 |
| `NULLIF` / `COALESCE` | Q9, Q15, Views |
| Views | `04_views.sql` |
| Indexes | `01_schema.sql` |

---

## ⚡ Key Findings (from sample data)

- **Critical tickets** had a 100% SLA response rate — all responded within 1 hour
- **Security incidents** were the fastest-resolved category on average
- **Password Reset** and **Access Provisioning** are the highest-volume subcategories
- Agent **Marcus Webb (L3)** and **Liam Murphy (L3)** handled all Critical tickets
- Average CSAT across all closed tickets: **4.3 / 5.0**
- July introduced the first unassigned tickets — indicating a potential staffing gap

---

## 🚀 How to Run

1. Ensure you have **PostgreSQL 15+** installed (or use [DB Fiddle](https://www.db-fiddle.com/) online)
2. Create a new database:
   ```sql
   CREATE DATABASE helpdesk_analytics;
   ```
3. Run the files in order:
   ```bash
   psql -d helpdesk_analytics -f 01_schema.sql
   psql -d helpdesk_analytics -f 02_seed_data.sql
   psql -d helpdesk_analytics -f 03_analysis_queries.sql
   psql -d helpdesk_analytics -f 04_views.sql
   ```
4. Or paste each file into **pgAdmin**, **DBeaver**, or **TablePlus**

---

## 🔮 Potential Extensions

- Connect views to **Power BI** or **Tableau** for a live dashboard
- Add a `ticket_history` table for full SLA audit trail per state change
- Extend with **stored procedures** for automated daily KPI reporting
- Build a **Python script** using `psycopg2` to auto-generate monthly reports

---

## 📬 Contact

**Shreyas Mudliar**  
📧 mudliarshreyas366@gmail.com  
📍 Brisbane, QLD, Australia
