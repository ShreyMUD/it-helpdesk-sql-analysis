-- ============================================================
-- IT HELP DESK TICKET ANALYTICS
-- Seed Data
-- ============================================================

-- ── DEPARTMENTS ─────────────────────────────────────────────
INSERT INTO departments (department_name, location) VALUES
('IT Operations',       'Brisbane'),
('Finance',             'Brisbane'),
('Human Resources',     'Sydney'),
('Sales',               'Melbourne'),
('Marketing',           'Brisbane'),
('Engineering',         'Sydney'),
('Customer Success',    'Melbourne'),
('Legal & Compliance',  'Brisbane');

-- ── SLA POLICIES ────────────────────────────────────────────
INSERT INTO sla_policies (priority, response_hours, resolution_hours) VALUES
('Critical',  1.0,   4.0),
('High',      4.0,  24.0),
('Medium',    8.0,  72.0),
('Low',      24.0, 120.0);

-- ── AGENTS ──────────────────────────────────────────────────
INSERT INTO agents (full_name, email, tier, department_id, hired_date) VALUES
('Marcus Webb',     'marcus.webb@company.com',      'L3', 1, '2019-03-15'),
('Priya Nair',      'priya.nair@company.com',       'L2', 1, '2020-07-01'),
('Jake Thomson',    'jake.thomson@company.com',     'L2', 1, '2021-01-20'),
('Sara Chen',       'sara.chen@company.com',        'L1', 1, '2022-06-10'),
('Daniel Osei',     'daniel.osei@company.com',      'L1', 1, '2022-09-05'),
('Fatima Al-Harbi', 'fatima.alharbi@company.com',   'L1', 1, '2023-02-14'),
('Liam Murphy',     'liam.murphy@company.com',      'L3', 1, '2018-11-30'),
('Aisha Patel',     'aisha.patel@company.com',      'L2', 1, '2021-08-22');

-- ── USERS ───────────────────────────────────────────────────
INSERT INTO users (full_name, email, department_id, location) VALUES
('Tom Richards',    'tom.r@company.com',        2, 'Brisbane'),
('Emily Zhang',     'emily.z@company.com',      3, 'Sydney'),
('Carlos Vega',     'carlos.v@company.com',     4, 'Melbourne'),
('Natalie Brooks',  'natalie.b@company.com',    5, 'Brisbane'),
('James O''Brien',  'james.ob@company.com',     6, 'Sydney'),
('Mei Lin',         'mei.lin@company.com',      7, 'Melbourne'),
('Kevin Hart',      'kevin.h@company.com',      8, 'Brisbane'),
('Sandra Reeves',   'sandra.r@company.com',     2, 'Brisbane'),
('Omar Hassan',     'omar.h@company.com',       4, 'Melbourne'),
('Lucy Tran',       'lucy.t@company.com',       5, 'Brisbane'),
('Brad Wilson',     'brad.w@company.com',       6, 'Sydney'),
('Nina Johansson',  'nina.j@company.com',       3, 'Sydney'),
('Raj Sharma',      'raj.s@company.com',        7, 'Melbourne'),
('Claire DuPont',   'claire.d@company.com',     8, 'Brisbane'),
('Henry Okonkwo',   'henry.o@company.com',      2, 'Brisbane');

-- ── CATEGORIES ──────────────────────────────────────────────
INSERT INTO categories (category_name, subcategory) VALUES
('Hardware',        'Laptop / Desktop'),
('Hardware',        'Peripherals'),
('Software',        'Installation & Licensing'),
('Software',        'Application Error'),
('Network',         'Connectivity'),
('Network',         'VPN Access'),
('Access & Identity','Password Reset'),
('Access & Identity','Account Provisioning'),
('Email & Calendar','Email Configuration'),
('Email & Calendar','Calendar Sync'),
('Security',        'Malware / Virus'),
('Security',        'Phishing Report'),
('Data & Backup',   'Data Recovery'),
('Data & Backup',   'Backup Failure'),
('Telephony',       'Softphone / Headset');

-- ── TICKETS ─────────────────────────────────────────────────
INSERT INTO tickets
  (title, description, category_id, priority, status,
   user_id, assigned_agent_id, created_at, first_response_at,
   resolved_at, closed_at, escalated, satisfaction_score)
VALUES
-- Jan
('Laptop won''t boot after Windows update',
 'Black screen on startup after forced update KB5034441.',
 1, 'High', 'Closed', 1, 4,
 '2024-01-03 08:15', '2024-01-03 09:20', '2024-01-04 11:00', '2024-01-05 09:00', FALSE, 5),

('Password reset – locked out of AD account',
 'User locked out after 5 failed attempts.',
 7, 'Medium', 'Closed', 2, 6,
 '2024-01-05 10:00', '2024-01-05 10:25', '2024-01-05 10:55', '2024-01-06 08:00', FALSE, 5),

('VPN not connecting from home',
 'Cisco AnyConnect throws "Authentication failed" despite correct credentials.',
 6, 'High', 'Closed', 3, 3,
 '2024-01-08 07:50', '2024-01-08 09:30', '2024-01-09 14:00', '2024-01-10 08:00', FALSE, 4),

('Suspected phishing email received',
 'Received email from external sender asking for credentials.',
 12, 'Critical', 'Closed', 4, 1,
 '2024-01-10 09:05', '2024-01-10 09:08', '2024-01-10 11:00', '2024-01-10 13:00', FALSE, 5),

('Microsoft 365 licence not assigned',
 'New employee cannot access Teams or Outlook.',
 8, 'Medium', 'Closed', 5, 5,
 '2024-01-12 11:30', '2024-01-12 13:00', '2024-01-13 09:30', '2024-01-14 08:00', FALSE, 4),

-- Feb
('Printer offline – Finance floor',
 'HP LaserJet shows offline on network print queue.',
 2, 'Low', 'Closed', 6, 5,
 '2024-02-01 08:45', '2024-02-01 10:30', '2024-02-02 09:00', '2024-02-03 08:00', FALSE, 3),

('Excel crashing on large pivot tables',
 'Application closes without error when refreshing pivot cache > 500k rows.',
 4, 'Medium', 'Closed', 7, 3,
 '2024-02-06 13:15', '2024-02-06 15:00', '2024-02-08 11:00', '2024-02-09 08:00', FALSE, 4),

('Server room temperature alert',
 'Monitoring system flagged rack temp above 28°C.',
 1, 'Critical', 'Closed', 8, 1,
 '2024-02-12 03:22', '2024-02-12 03:25', '2024-02-12 05:30', '2024-02-12 08:00', FALSE, 5),

('Email not syncing on iPhone',
 'Outlook mobile not receiving new emails; last sync 3 days ago.',
 9, 'Low', 'Closed', 9, 6,
 '2024-02-15 09:00', '2024-02-15 11:45', '2024-02-16 14:00', '2024-02-17 08:00', FALSE, 3),

('Malware detected on workstation',
 'Windows Defender quarantined Trojan.GenericKD on finance PC.',
 11, 'Critical', 'Closed', 10, 7,
 '2024-02-20 10:40', '2024-02-20 10:43', '2024-02-20 13:00', '2024-02-20 16:00', FALSE, 5),

-- Mar
('Cannot access shared network drive',
 'Permission denied on \\\\server\\shared\\Finance after role change.',
 8, 'Medium', 'Closed', 11, 2,
 '2024-03-04 08:30', '2024-03-04 10:00', '2024-03-05 09:00', '2024-03-06 08:00', FALSE, 4),

('New software installation request – Power BI Desktop',
 'Analyst requires Power BI Desktop for dashboard development.',
 3, 'Low', 'Closed', 12, 4,
 '2024-03-07 14:00', '2024-03-08 09:00', '2024-03-10 11:00', '2024-03-11 08:00', FALSE, 4),

('Backup job failed – overnight run',
 'Veeam backup of DB server failed with error: "Unable to truncate log".',
 14, 'High', 'Closed', 13, 7,
 '2024-03-11 07:00', '2024-03-11 07:45', '2024-03-11 12:00', '2024-03-12 08:00', TRUE, 5),

('Zoom audio not working in meetings',
 'Microphone not detected by Zoom after Windows update.',
 4, 'Medium', 'Closed', 14, 5,
 '2024-03-15 10:20', '2024-03-15 11:00', '2024-03-16 09:30', '2024-03-17 08:00', FALSE, 3),

('User account not found – new starter',
 'New HR employee cannot log in; AD account not created.',
 8, 'High', 'Closed', 15, 3,
 '2024-03-18 08:55', '2024-03-18 09:30', '2024-03-18 11:00', '2024-03-19 08:00', FALSE, 5),

-- Apr
('Slow internet speed reported across Melbourne office',
 'Multiple users reporting < 2 Mbps download since morning.',
 5, 'High', 'Closed', 3, 2,
 '2024-04-02 09:10', '2024-04-02 09:40', '2024-04-02 14:00', '2024-04-03 08:00', FALSE, 4),

('Data recovery needed – accidental file deletion',
 'User accidentally deleted Q1 financial reports from shared drive.',
 13, 'Critical', 'Closed', 1, 1,
 '2024-04-05 11:00', '2024-04-05 11:05', '2024-04-05 14:30', '2024-04-05 16:00', FALSE, 5),

('Software licence expired – Adobe Acrobat',
 'Legal team cannot open PDFs; licence expired 01/04.',
 3, 'High', 'Closed', 7, 8,
 '2024-04-07 09:30', '2024-04-07 10:15', '2024-04-08 09:00', '2024-04-09 08:00', FALSE, 4),

('Password reset request',
 'Self-service portal not working; manual reset required.',
 7, 'Low', 'Closed', 9, 6,
 '2024-04-12 14:00', '2024-04-12 14:30', '2024-04-12 15:00', '2024-04-13 08:00', FALSE, 5),

('Dual monitor not detected',
 'Second display not recognized after dock firmware update.',
 2, 'Medium', 'Closed', 11, 4,
 '2024-04-16 10:45', '2024-04-16 11:30', '2024-04-17 14:00', '2024-04-18 08:00', FALSE, 3),

-- May
('Network switch failure – Floor 3',
 'Port 12 on Cisco Catalyst unresponsive; 4 workstations offline.',
 5, 'Critical', 'Closed', 13, 7,
 '2024-05-03 07:30', '2024-05-03 07:33', '2024-05-03 10:00', '2024-05-03 14:00', FALSE, 5),

('Outlook calendar not syncing with Teams',
 'Meetings created in Teams not appearing in Outlook calendar.',
 10, 'Medium', 'Closed', 14, 3,
 '2024-05-09 13:00', '2024-05-09 14:30', '2024-05-11 09:00', '2024-05-12 08:00', FALSE, 4),

('VPN speed degradation',
 'Remote users on VPN experiencing < 5 Mbps throughput.',
 6, 'High', 'Closed', 2, 2,
 '2024-05-14 08:00', '2024-05-14 09:00', '2024-05-15 12:00', '2024-05-16 08:00', TRUE, 3),

('Laptop battery won''t charge past 40%',
 'Battery health shows 38% capacity; requires replacement.',
 1, 'Low', 'Closed', 5, 5,
 '2024-05-20 10:30', '2024-05-21 09:00', '2024-05-24 11:00', '2024-05-25 08:00', FALSE, 3),

('Ransomware alert on marketing workstation',
 'EDR flagged encryption activity; machine isolated immediately.',
 11, 'Critical', 'Closed', 10, 1,
 '2024-05-22 09:15', '2024-05-22 09:17', '2024-05-22 12:00', '2024-05-22 17:00', FALSE, 5),

-- Jun
('New employee onboarding – access setup',
 'Create AD account, assign M365 licence, configure email.',
 8, 'Medium', 'Resolved', 4, 3,
 '2024-06-03 09:00', '2024-06-03 10:30', '2024-06-04 11:00', NULL, FALSE, 5),

('Softphone not registering with PBX',
 'Cisco Jabber shows "Connection failed to CUCM".',
 15, 'Medium', 'Resolved', 6, 8,
 '2024-06-10 11:00', '2024-06-10 13:00', '2024-06-12 10:00', NULL, FALSE, 4),

('BSOD on developer workstation',
 'MEMORY_MANAGEMENT stop error after RAM upgrade.',
 1, 'High', 'Closed', 12, 7,
 '2024-06-14 15:00', '2024-06-14 15:30', '2024-06-15 12:00', '2024-06-16 08:00', FALSE, 5),

('Password expired – cannot change',
 'Password expiry prompt loops back; cannot set new password.',
 7, 'Medium', 'Closed', 8, 6,
 '2024-06-18 08:30', '2024-06-18 09:00', '2024-06-18 09:45', '2024-06-19 08:00', FALSE, 5),

('Backup failed – cloud sync',
 'Azure Backup job error: "Insufficient permissions on storage account".',
 14, 'High', 'In Progress', 15, 7,
 '2024-06-25 06:00', '2024-06-25 07:00', NULL, NULL, FALSE, NULL),

-- Jul - current open tickets
('Wi-Fi dropping every 30 min on Level 2',
 'Multiple users affected; AP logs show channel congestion.',
 5, 'High', 'In Progress', 9, 2,
 '2024-07-01 10:00', '2024-07-01 11:00', NULL, NULL, FALSE, NULL),

('Suspicious login attempt from overseas IP',
 'Azure AD flagged sign-in from IP geolocated to Eastern Europe.',
 12, 'Critical', 'Escalated', 1, 1,
 '2024-07-03 04:45', '2024-07-03 04:47', NULL, NULL, TRUE, NULL),

('Software request – Tableau licence',
 'Senior analyst requires Tableau Creator licence for BI project.',
 3, 'Low', 'Open', 11, NULL,
 '2024-07-05 14:00', NULL, NULL, NULL, FALSE, NULL),

('Cannot log into ERP system after update',
 'SAP login fails with "User does not have authorisation for plant".',
 4, 'High', 'In Progress', 13, 8,
 '2024-07-08 09:00', '2024-07-08 10:00', NULL, NULL, FALSE, NULL),

('Mouse and keyboard unresponsive after resume from sleep',
 'USB devices require replug after every suspend/resume cycle.',
 2, 'Low', 'Open', 14, NULL,
 '2024-07-10 11:30', NULL, NULL, NULL, FALSE, NULL);
