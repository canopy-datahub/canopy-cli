--
-- Data for Name: lkup_capability; Type: TABLE DATA; Schema: public; Owner: canopy_admin
--
-- Capability registry. Each row is a fine-grained named permission referenced
-- by controllers via checkCapability(jwt, "<name>"). The mapping from roles
-- to these capabilities lives in 729_data_role_capability.sql.
--
-- The Uploader role's capabilities (upload-portal.upload,
-- upload-portal.studies.list) are intentionally omitted; the Uploader role
-- is disabled platform-wide (see UserServiceImpl.BLOCKED_ROLES) and its two
-- controller endpoints remain on role-based checkAuth so the disablement is
-- a five-minute revert.
--

-- submission.* (Data Submitter)
INSERT INTO public.lkup_capability (id, name, description) VALUES (1,  'submission.create',                  'Create a new data submission for a study');
INSERT INTO public.lkup_capability (id, name, description) VALUES (2,  'submission.read.own',                'List own submissions and read submission info');
INSERT INTO public.lkup_capability (id, name, description) VALUES (3,  'submission.delete.own',              'Delete own submission');
INSERT INTO public.lkup_capability (id, name, description) VALUES (4,  'submission.submit',                  'Submit a submission for curator review');
INSERT INTO public.lkup_capability (id, name, description) VALUES (5,  'submission.file.upload',             'Upload data files into a submission');
INSERT INTO public.lkup_capability (id, name, description) VALUES (6,  'submission.file.delete',             'Delete data files from a submission');
INSERT INTO public.lkup_capability (id, name, description) VALUES (7,  'submission.file.replace',            'Replace a data file in a submission');
INSERT INTO public.lkup_capability (id, name, description) VALUES (8,  'submission.file.list',               'List uploaded files for a submission');
INSERT INTO public.lkup_capability (id, name, description) VALUES (9,  'submission.bundle.create',           'Create file bundles for a submission');
INSERT INTO public.lkup_capability (id, name, description) VALUES (10, 'submission.bundle.read',             'Read bundle and bundle-file info');
INSERT INTO public.lkup_capability (id, name, description) VALUES (11, 'submission.bundle.update',           'Update bundle composition');
INSERT INTO public.lkup_capability (id, name, description) VALUES (12, 'submission.bundle.delete',           'Delete a bundle');
INSERT INTO public.lkup_capability (id, name, description) VALUES (13, 'submission.bundle.previousPage',     'Step bundle wizard back to the upload page');
INSERT INTO public.lkup_capability (id, name, description) VALUES (14, 'submission.validate',                'Run schema/CDE validation on submission files');
INSERT INTO public.lkup_capability (id, name, description) VALUES (15, 'submission.validation.read',         'Read validation results');
INSERT INTO public.lkup_capability (id, name, description) VALUES (16, 'submission.validation.acknowledge',  'Acknowledge validation warnings');
INSERT INTO public.lkup_capability (id, name, description) VALUES (17, 'submission.validation.errors.read',  'Download validation error CSVs');
INSERT INTO public.lkup_capability (id, name, description) VALUES (18, 'submission.config.read',             'Read submission lookup config (studies, file categories)');

-- study.* (Data Submitter / Data Curator)
INSERT INTO public.lkup_capability (id, name, description) VALUES (20, 'study.center.create',                'Create a study under the caller''s center');
INSERT INTO public.lkup_capability (id, name, description) VALUES (21, 'study.center.edit',                  'Edit a study under the caller''s center');
INSERT INTO public.lkup_capability (id, name, description) VALUES (22, 'study.center.list',                  'List own-center studies');
INSERT INTO public.lkup_capability (id, name, description) VALUES (23, 'study.curator.create',               'Create a study as a curator (any center)');
INSERT INTO public.lkup_capability (id, name, description) VALUES (24, 'study.curator.edit',                 'Edit a study as a curator (any center)');
INSERT INTO public.lkup_capability (id, name, description) VALUES (25, 'study.curator.list',                 'List studies for curator review');
INSERT INTO public.lkup_capability (id, name, description) VALUES (26, 'study.values.read',                  'Read study registration values');
INSERT INTO public.lkup_capability (id, name, description) VALUES (27, 'study.delete',                       'Delete a study or its files');
INSERT INTO public.lkup_capability (id, name, description) VALUES (28, 'study.uuids.export',                 'Export the study-UUID spreadsheet');
INSERT INTO public.lkup_capability (id, name, description) VALUES (29, 'study.unapproved.read',              'Read an unapproved study via the public-shaped endpoint');

-- curator.* (Data Curator review flow)
INSERT INTO public.lkup_capability (id, name, description) VALUES (40, 'curator.submission.list',            'List submitted submissions awaiting review');
INSERT INTO public.lkup_capability (id, name, description) VALUES (41, 'curator.submission.read',            'Read files for one submission under review');
INSERT INTO public.lkup_capability (id, name, description) VALUES (42, 'curator.submission.review',          'Apply per-file approve/reject decisions');
INSERT INTO public.lkup_capability (id, name, description) VALUES (43, 'curator.submission.download.bulk',   'Bulk-download all files for a submission');

-- upload-portal.* (Curator-side only — Uploader caps intentionally omitted)
INSERT INTO public.lkup_capability (id, name, description) VALUES (50, 'upload-portal.dashboard.view',       'View the upload-portal curator dashboard');
INSERT INTO public.lkup_capability (id, name, description) VALUES (51, 'upload-portal.dashboard.delete',     'Delete an upload-portal upload');
INSERT INTO public.lkup_capability (id, name, description) VALUES (52, 'upload-portal.file.download',        'Download an upload-portal file');

-- metrics.* (Officer)
INSERT INTO public.lkup_capability (id, name, description) VALUES (60, 'metrics.hub-content.view',           'View hub-content metrics dashboards');
INSERT INTO public.lkup_capability (id, name, description) VALUES (61, 'metrics.hub-content.export',         'Export hub-content metrics CSV');
INSERT INTO public.lkup_capability (id, name, description) VALUES (62, 'metrics.user-activity.view',         'View user-activity metrics');
INSERT INTO public.lkup_capability (id, name, description) VALUES (63, 'metrics.user-activity.export',       'Export user-activity metrics CSV');
INSERT INTO public.lkup_capability (id, name, description) VALUES (64, 'metrics.user-population.view',       'View user-population metrics');
INSERT INTO public.lkup_capability (id, name, description) VALUES (65, 'metrics.user-population.export',     'Export user-population metrics CSV');
INSERT INTO public.lkup_capability (id, name, description) VALUES (66, 'metrics.submission-activity.view',   'View submission-activity metrics');
INSERT INTO public.lkup_capability (id, name, description) VALUES (67, 'metrics.submission-activity.export', 'Export submission-activity metrics CSV');
INSERT INTO public.lkup_capability (id, name, description) VALUES (68, 'metrics.harmonization.view',         'View harmonization metrics');
INSERT INTO public.lkup_capability (id, name, description) VALUES (69, 'metrics.harmonization.export',       'Export harmonization metrics CSV');
INSERT INTO public.lkup_capability (id, name, description) VALUES (70, 'metrics.harmonization.run',          'Run the harmonization metrics job');
INSERT INTO public.lkup_capability (id, name, description) VALUES (71, 'metrics.weekly-report.upload',       'Trigger weekly file report upload');

-- report.* (one-off curator export)
INSERT INTO public.lkup_capability (id, name, description) VALUES (80, 'report.weekly-study.download',       'Download the weekly study-by-file report');

-- support.* (Support Team / Officer / Admin)
INSERT INTO public.lkup_capability (id, name, description) VALUES (90, 'support.list',                       'List all support tickets');
INSERT INTO public.lkup_capability (id, name, description) VALUES (91, 'support.read',                       'Read one support ticket');
INSERT INTO public.lkup_capability (id, name, description) VALUES (92, 'support.officer.read',               'Officer view of a support ticket (bundled response)');
INSERT INTO public.lkup_capability (id, name, description) VALUES (93, 'support.update',                     'Update a support ticket (assignee, status, resolution)');
INSERT INTO public.lkup_capability (id, name, description) VALUES (94, 'support.report.download',            'Download the support-tickets CSV report');
INSERT INTO public.lkup_capability (id, name, description) VALUES (95, 'support.lookups.read',               'Read support lookup data (statuses, severities, etc.)');

-- user.admin.* (Admin)
INSERT INTO public.lkup_capability (id, name, description) VALUES (100, 'user.admin.list',                   'List users');
INSERT INTO public.lkup_capability (id, name, description) VALUES (101, 'user.admin.read',                   'Read a user record');
INSERT INTO public.lkup_capability (id, name, description) VALUES (102, 'user.admin.update',                 'Update a user record (roles, status, center)');
INSERT INTO public.lkup_capability (id, name, description) VALUES (103, 'user.admin.config',                 'Read admin-side lookup data (roles, statuses)');

-- system-settings.* (Admin)
INSERT INTO public.lkup_capability (id, name, description) VALUES (110, 'system-settings.read',              'Read admin-side system settings');
INSERT INTO public.lkup_capability (id, name, description) VALUES (111, 'system-settings.update',            'Update system settings');

-- ops.* (Admin)
INSERT INTO public.lkup_capability (id, name, description) VALUES (120, 'ops.sftp.trigger',                  'Manually trigger SFTP processing');

SELECT setval('public.lkup_capability_id_seq', (SELECT MAX(id) FROM public.lkup_capability), true);


--
