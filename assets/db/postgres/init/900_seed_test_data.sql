-- Create Institution
INSERT INTO institution (
    id, name, status_id, institution_type_id, is_for_profit, ror_id,
    country_id, state_id, province_region, created_by
) VALUES
-- Record 1: Stanford University
(
    1,                              -- id
    'Stanford University',          -- name
    23,                             -- status_id
    10,                             -- institution_type_id (e.g., University)
    false,                          -- is_for_profit
    'https://ror.org/00f54p054',    -- ror_id
    1,                              -- country_id (e.g., USA)
    5,                              -- state_id (e.g., California)
    NULL,                           -- province_region
    1                               -- created_by
),
-- Record 2: Harvard Medical School
(
    2,                              -- id
    'Harvard Medical School',       -- name
    23,                             -- status_id
    10,                             -- institution_type_id
    false,                          -- is_for_profit
    'https://ror.org/03vek6s52',    -- ror_id
    1,                              -- country_id
    22,                             -- state_id (e.g., Massachusetts)
    NULL,                           -- province_region
    1                               -- created_by
),
-- Record 3: NIH
(
    3,                              -- id
    'NIH',                          -- name
    23,                             -- status_id
    5,                              -- institution_type_id (e.g., Government agency)
    false,                          -- is_for_profit
    'https://ror.org/01cwqze88',    -- ror_id
    1,                              -- country_id
    21,                             -- state_id (e.g., Maryland)
    NULL,                           -- province_region
    1                               -- created_by
),
-- Record 4: Mayo Clinic
(
    4,                              -- id
    'Mayo Clinic',                  -- name
    23,                             -- status_id
    8,                              -- institution_type_id (e.g., Healthcare organization)
    false,                          -- is_for_profit
    'https://ror.org/03cpe8v73',    -- ror_id
    1,                              -- country_id
    24,                             -- state_id (e.g., Minnesota)
    NULL,                           -- province_region
    1                               -- created_by
);

----------------------------------- News and Events related --------------------------------

-- Create news entries
INSERT INTO news (id, title, slug, type_id, description, start_date, expiration_date, created_at) VALUES
-- General News
(1, 'Unlock the Power of the RADx Data Hub with Curated YouTube Playlists', 'youtube-playlist',
 2, -- type_id for general news
 'Are you ready to harness the full potential of the RADx Data Hub? The RADx Data Hub Partners curated multiple YouTube playlists to guide users through this powerful platform.',
 CURRENT_DATE - INTERVAL '5 days',
 CURRENT_DATE + INTERVAL '250 days',
 CURRENT_TIMESTAMP),

(2, 'NIH RADx Data Hub announces major functionality and design upgrades', 'major-upgrades',
 2, -- type_id for general news
 'The National Institutes of Health (NIH) Rapid Acceleration of Diagnostics Data Hub (RADx® Data Hub) announces today major functionality and design upgrades to its cloud-enabled platform. These upgrades will provide researchers more dynamic access to explore data from over 150 studies from RADx-rad, RADx-UP, RADx Tech, and RADx DHT programs. Researchers will also be gaining access to an even more robust analytics platform with tools such as Jupyter notebooks, R, Python, and SAS Viya.',
 CURRENT_DATE - INTERVAL '10 days',
 CURRENT_DATE + INTERVAL '200 days',
 CURRENT_TIMESTAMP);

INSERT INTO funding (id, title, slug, description, release_date, expiration_date, created_at) VALUES
-- Funding Opportunities
(1, 'Notice of Funding Opportunity (NOFO): NIH Research Software Engineer (RSE) Award (R50 Clinical Trials Not Allowed)', 'radx-funding-2024',
 'The purpose of this Notice of Funding Opportunity (NOFO) (RFA-OD-24-011) is to support the ability of exceptional Research Software Engineers (RSEs) to contribute their skills in the development and dissemination of NIH-funded biomedical, clinical, behavioral or health related research software, tools, and algorithms as well as to the training of prospective users of these tools.',
 CURRENT_DATE - INTERVAL '2 days',
 CURRENT_DATE + INTERVAL '28 days',
 CURRENT_TIMESTAMP),

(2, 'Notice of Funding Opportunity (NOFO): Building Sustainable Software Tools for Open Science (R03 Clinical Trial Not Allowed)', 'covid-research-grants',
 'The purpose of this Notice of funding opportunity (NOFO) (RFA-OD-24-010) is to enhance the sustainability and impact of research software tools by enabling the use of best practices and design principles in software development and by leveraging continuing advances in computing.',
 CURRENT_DATE - INTERVAL '15 days',
 CURRENT_DATE + INTERVAL '15 days',
 CURRENT_TIMESTAMP);

-- Create News links
INSERT INTO news_link (id, news_id, link_label, link_url, display_order) VALUES
(1, 3, 'View More', 'https://grants.nih.gov/grants/guide/rfa-files/RFA-OD-24-011.html', 1),
(2, 4, 'View More', 'https://grants.nih.gov/grants/guide/rfa-files/RFA-OD-24-010.html', 2);


-- Create events
INSERT INTO events (id, title, slug, description, event_type_id, registration_url, event_date, expiration_date, created_at) VALUES
-- Future events
(1, 'Join Us for Office Hours on July 8! ', 'radx-office-hourse',
 'Annual conference for RADx researchers...',
 3, -- general event
 'https://docs.google.com/document/d/1GzPM6R6CWd10sp0Pdl3RfRw-RIkla4iDbdcKcQJDTlA/edit?tab=t.0#heading=h.1s48q99qxb5x',
 CURRENT_DATE + INTERVAL '30 days',
 CURRENT_DATE + INTERVAL '310 days',
 CURRENT_TIMESTAMP),


(2, 'Center Monthly Meeting', 'center-monthly-meeting',
 'Monthly center coordination meeting...',
 2, -- center meeting
 null,
 CURRENT_DATE + INTERVAL '15 days',
 CURRENT_DATE + INTERVAL '160 days',
 CURRENT_TIMESTAMP),

(3, 'Increasing the Value of RADx Data with Metadata', 'metadata-webinar',
 'The RADx Data Hub represents one of the largest collections of NIH COVID data available to researchers and allows researchers to explore, access, and analyze COVID-related data developed through NIH RADx program initiatives.',
 1, -- webinar
 null,
 CURRENT_DATE + INTERVAL '20 days',
 CURRENT_DATE + INTERVAL '210 days',
 CURRENT_TIMESTAMP),

-- Past events
(5, 'Previous Conference', 'previous-conference',
 'Last year''s conference...',
 3, -- general event
 'https://example.com/previous-conference',
 CURRENT_DATE - INTERVAL '30 days',
 CURRENT_DATE - INTERVAL '29 days',
 CURRENT_TIMESTAMP);

-- Create event links
INSERT INTO event_link (id, event_id, link_label, link_url, display_order) VALUES
(1, 1, 'Join Us for Office Hours on July 8! ', 'https://docs.google.com/document/d/1GzPM6R6CWd10sp0Pdl3RfRw-RIkla4iDbdcKcQJDTlA/edit?tab=t.0#heading=h.1s48q99qxb5x', 1),
(2, 3, 'View Slide', 'https://drive.google.com/file/d/1wP1qs-bwGjnRd-7cPLxEmf5i-tQ_vypF/view', 2);

-- Create a test user for local development
INSERT INTO users (
  id,
  uuid,
  first_name,
  middle_initial,
  last_name,
  email_address,
  orcid_id,
  job_title,
  institution_id,
  researcher_level_id,
  status_id,
  internal_user,
  accept_terms,
  last_dua_date,
  last_login_at,
  sftp_path,
  created_at,
  modified_at,
  center_id
)
VALUES
(
  3,                                          -- id
  '333e4567-e89b-12d3-a456-426614174002',     -- uuid (matches the Test user in the Keycloak realm import)
  'Test',                                    -- first_name
  null,                                        -- middle_initial
  'Test',                                    -- last_name
  'test@test.com',                  -- email_address
  null,                      -- orcid_id
  'Software Developer',                      -- job_title
  1,                                          -- institution_id
  5,                                          -- researcher_level_id
  1,                                          -- status_id
  true,                                       -- internal_user
  true,                                       -- accept_terms
  null,                               -- last_dua_date
  CURRENT_TIMESTAMP,                      -- last_login_at
  'local-yan',                                       -- sftp_path
  CURRENT_TIMESTAMP,                          -- created_at
  NULL,                                       -- modified_at
  1                                           -- center_id
);

INSERT INTO user_role (id, user_id, role_id) VALUES
(1, 3, 1),
(2, 3, 2),
(3, 3, 3),
(4, 3, 4),
(5, 3, 5),
(6, 3, 6);

-- Fix all sequences automatically
DO $$
DECLARE
r RECORD;
    max_id INTEGER;
    seq_name TEXT;
BEGIN
    RAISE NOTICE 'Starting sequence reset...';

FOR r IN
SELECT c.table_name, c.column_name
FROM information_schema.columns c
WHERE c.table_schema = 'public'
  AND c.column_default LIKE 'nextval%'
ORDER BY c.table_name
    LOOP
        seq_name := pg_get_serial_sequence('public.' || r.table_name, r.column_name);

IF seq_name IS NOT NULL THEN
BEGIN
EXECUTE format('SELECT COALESCE(MAX(%I), 0) FROM %I', r.column_name, r.table_name) INTO max_id;
EXECUTE format('SELECT setval(%L, GREATEST(%s, 1))', seq_name, max_id);
RAISE NOTICE 'Table: % | Column: % | Sequence: % | Reset to: %',
                    r.table_name, r.column_name, seq_name, max_id;
EXCEPTION WHEN OTHERS THEN
                RAISE NOTICE 'ERROR on table %.%: %', r.table_name, r.column_name, SQLERRM;
END;
END IF;
END LOOP;

    RAISE NOTICE 'Sequence reset complete!';
END $$;
