--
-- Data for Name: role_capability; Type: TABLE DATA; Schema: public; Owner: canopy_admin
--
-- Binds capabilities (728_data_lkup_capability.sql) to roles (719_data_lkup_role.sql).
-- A user's effective capabilities are the union over their assigned roles.
--
-- Role IDs:
--   1 = Data Submitter
--   2 = Officer
--   3 = Data Curator
--   4 = Support Team
--   5 = Application Administrator
--   6 = Uploader  (disabled platform-wide; intentionally has zero capabilities here)
--

-- =========================================================================
-- Role 1: Data Submitter
-- =========================================================================
INSERT INTO public.role_capability (role_id, capability_id) VALUES (1,  1) ON CONFLICT (role_id, capability_id) DO NOTHING;   -- submission.create
INSERT INTO public.role_capability (role_id, capability_id) VALUES (1,  2) ON CONFLICT (role_id, capability_id) DO NOTHING;   -- submission.read.own
INSERT INTO public.role_capability (role_id, capability_id) VALUES (1,  3) ON CONFLICT (role_id, capability_id) DO NOTHING;   -- submission.delete.own
INSERT INTO public.role_capability (role_id, capability_id) VALUES (1,  4) ON CONFLICT (role_id, capability_id) DO NOTHING;   -- submission.submit
INSERT INTO public.role_capability (role_id, capability_id) VALUES (1,  5) ON CONFLICT (role_id, capability_id) DO NOTHING;   -- submission.file.upload
INSERT INTO public.role_capability (role_id, capability_id) VALUES (1,  6) ON CONFLICT (role_id, capability_id) DO NOTHING;   -- submission.file.delete
INSERT INTO public.role_capability (role_id, capability_id) VALUES (1,  7) ON CONFLICT (role_id, capability_id) DO NOTHING;   -- submission.file.replace
INSERT INTO public.role_capability (role_id, capability_id) VALUES (1,  8) ON CONFLICT (role_id, capability_id) DO NOTHING;   -- submission.file.list
INSERT INTO public.role_capability (role_id, capability_id) VALUES (1,  9) ON CONFLICT (role_id, capability_id) DO NOTHING;   -- submission.bundle.create
INSERT INTO public.role_capability (role_id, capability_id) VALUES (1, 10) ON CONFLICT (role_id, capability_id) DO NOTHING;   -- submission.bundle.read
INSERT INTO public.role_capability (role_id, capability_id) VALUES (1, 11) ON CONFLICT (role_id, capability_id) DO NOTHING;   -- submission.bundle.update
INSERT INTO public.role_capability (role_id, capability_id) VALUES (1, 12) ON CONFLICT (role_id, capability_id) DO NOTHING;   -- submission.bundle.delete
INSERT INTO public.role_capability (role_id, capability_id) VALUES (1, 13) ON CONFLICT (role_id, capability_id) DO NOTHING;   -- submission.bundle.previousPage
INSERT INTO public.role_capability (role_id, capability_id) VALUES (1, 14) ON CONFLICT (role_id, capability_id) DO NOTHING;   -- submission.validate
INSERT INTO public.role_capability (role_id, capability_id) VALUES (1, 15) ON CONFLICT (role_id, capability_id) DO NOTHING;   -- submission.validation.read
INSERT INTO public.role_capability (role_id, capability_id) VALUES (1, 16) ON CONFLICT (role_id, capability_id) DO NOTHING;   -- submission.validation.acknowledge
INSERT INTO public.role_capability (role_id, capability_id) VALUES (1, 17) ON CONFLICT (role_id, capability_id) DO NOTHING;   -- submission.validation.errors.read
INSERT INTO public.role_capability (role_id, capability_id) VALUES (1, 18) ON CONFLICT (role_id, capability_id) DO NOTHING;   -- submission.config.read
INSERT INTO public.role_capability (role_id, capability_id) VALUES (1, 20) ON CONFLICT (role_id, capability_id) DO NOTHING;   -- study.center.create
INSERT INTO public.role_capability (role_id, capability_id) VALUES (1, 21) ON CONFLICT (role_id, capability_id) DO NOTHING;   -- study.center.edit
INSERT INTO public.role_capability (role_id, capability_id) VALUES (1, 22) ON CONFLICT (role_id, capability_id) DO NOTHING;   -- study.center.list
INSERT INTO public.role_capability (role_id, capability_id) VALUES (1, 26) ON CONFLICT (role_id, capability_id) DO NOTHING;   -- study.values.read
INSERT INTO public.role_capability (role_id, capability_id) VALUES (1, 27) ON CONFLICT (role_id, capability_id) DO NOTHING;   -- study.delete
INSERT INTO public.role_capability (role_id, capability_id) VALUES (1, 28) ON CONFLICT (role_id, capability_id) DO NOTHING;   -- study.uuids.export
INSERT INTO public.role_capability (role_id, capability_id) VALUES (1, 112) ON CONFLICT (role_id, capability_id) DO NOTHING;  -- study.access.update (creator-only enforced by StudyAccessService)

-- =========================================================================
-- Role 2: Officer
-- =========================================================================
INSERT INTO public.role_capability (role_id, capability_id) VALUES (2, 60) ON CONFLICT (role_id, capability_id) DO NOTHING;   -- metrics.hub-content.view
INSERT INTO public.role_capability (role_id, capability_id) VALUES (2, 61) ON CONFLICT (role_id, capability_id) DO NOTHING;   -- metrics.hub-content.export
INSERT INTO public.role_capability (role_id, capability_id) VALUES (2, 62) ON CONFLICT (role_id, capability_id) DO NOTHING;   -- metrics.user-activity.view
INSERT INTO public.role_capability (role_id, capability_id) VALUES (2, 63) ON CONFLICT (role_id, capability_id) DO NOTHING;   -- metrics.user-activity.export
INSERT INTO public.role_capability (role_id, capability_id) VALUES (2, 64) ON CONFLICT (role_id, capability_id) DO NOTHING;   -- metrics.user-population.view
INSERT INTO public.role_capability (role_id, capability_id) VALUES (2, 65) ON CONFLICT (role_id, capability_id) DO NOTHING;   -- metrics.user-population.export
INSERT INTO public.role_capability (role_id, capability_id) VALUES (2, 66) ON CONFLICT (role_id, capability_id) DO NOTHING;   -- metrics.submission-activity.view
INSERT INTO public.role_capability (role_id, capability_id) VALUES (2, 67) ON CONFLICT (role_id, capability_id) DO NOTHING;   -- metrics.submission-activity.export
INSERT INTO public.role_capability (role_id, capability_id) VALUES (2, 68) ON CONFLICT (role_id, capability_id) DO NOTHING;   -- metrics.harmonization.view
INSERT INTO public.role_capability (role_id, capability_id) VALUES (2, 69) ON CONFLICT (role_id, capability_id) DO NOTHING;   -- metrics.harmonization.export
INSERT INTO public.role_capability (role_id, capability_id) VALUES (2, 70) ON CONFLICT (role_id, capability_id) DO NOTHING;   -- metrics.harmonization.run
INSERT INTO public.role_capability (role_id, capability_id) VALUES (2, 71) ON CONFLICT (role_id, capability_id) DO NOTHING;   -- metrics.weekly-report.upload
INSERT INTO public.role_capability (role_id, capability_id) VALUES (2, 90) ON CONFLICT (role_id, capability_id) DO NOTHING;   -- support.list
INSERT INTO public.role_capability (role_id, capability_id) VALUES (2, 91) ON CONFLICT (role_id, capability_id) DO NOTHING;   -- support.read
INSERT INTO public.role_capability (role_id, capability_id) VALUES (2, 92) ON CONFLICT (role_id, capability_id) DO NOTHING;   -- support.officer.read
INSERT INTO public.role_capability (role_id, capability_id) VALUES (2, 94) ON CONFLICT (role_id, capability_id) DO NOTHING;   -- support.report.download
INSERT INTO public.role_capability (role_id, capability_id) VALUES (2, 95) ON CONFLICT (role_id, capability_id) DO NOTHING;   -- support.lookups.read

-- =========================================================================
-- Role 3: Data Curator
-- =========================================================================
INSERT INTO public.role_capability (role_id, capability_id) VALUES (3, 15) ON CONFLICT (role_id, capability_id) DO NOTHING;   -- submission.validation.read
INSERT INTO public.role_capability (role_id, capability_id) VALUES (3, 17) ON CONFLICT (role_id, capability_id) DO NOTHING;   -- submission.validation.errors.read
-- study.curator.create (capability 23) intentionally NOT bound to the Curator
-- role: per platform policy, curators can only approve studies, not create
-- them. The capability remains defined in lkup_capability; re-add this row to
-- restore curator-side study creation.
INSERT INTO public.role_capability (role_id, capability_id) VALUES (3, 24) ON CONFLICT (role_id, capability_id) DO NOTHING;   -- study.curator.edit
INSERT INTO public.role_capability (role_id, capability_id) VALUES (3, 25) ON CONFLICT (role_id, capability_id) DO NOTHING;   -- study.curator.list
INSERT INTO public.role_capability (role_id, capability_id) VALUES (3, 26) ON CONFLICT (role_id, capability_id) DO NOTHING;   -- study.values.read
INSERT INTO public.role_capability (role_id, capability_id) VALUES (3, 27) ON CONFLICT (role_id, capability_id) DO NOTHING;   -- study.delete
INSERT INTO public.role_capability (role_id, capability_id) VALUES (3, 29) ON CONFLICT (role_id, capability_id) DO NOTHING;   -- study.unapproved.read
INSERT INTO public.role_capability (role_id, capability_id) VALUES (3, 40) ON CONFLICT (role_id, capability_id) DO NOTHING;   -- curator.submission.list
INSERT INTO public.role_capability (role_id, capability_id) VALUES (3, 41) ON CONFLICT (role_id, capability_id) DO NOTHING;   -- curator.submission.read
INSERT INTO public.role_capability (role_id, capability_id) VALUES (3, 42) ON CONFLICT (role_id, capability_id) DO NOTHING;   -- curator.submission.review
INSERT INTO public.role_capability (role_id, capability_id) VALUES (3, 43) ON CONFLICT (role_id, capability_id) DO NOTHING;   -- curator.submission.download.bulk
-- The three upload-portal curator capabilities (50 upload-portal.dashboard.view,
-- 51 upload-portal.dashboard.delete, 52 upload-portal.file.download) are
-- intentionally NOT bound to the Curator role: the Uploader role is disabled
-- platform-wide (see UserServiceImpl.BLOCKED_ROLES), so no uploads ever land
-- in the curator queue. The capabilities remain defined in lkup_capability;
-- restore the three role_capability rows here to re-enable the
-- /curator/downloads page when Uploader is resurrected.
INSERT INTO public.role_capability (role_id, capability_id) VALUES (3, 80) ON CONFLICT (role_id, capability_id) DO NOTHING;   -- report.weekly-study.download
INSERT INTO public.role_capability (role_id, capability_id) VALUES (3, 112) ON CONFLICT (role_id, capability_id) DO NOTHING;  -- study.access.update (curator override on any study)

-- =========================================================================
-- Role 4: Support Team
-- =========================================================================
INSERT INTO public.role_capability (role_id, capability_id) VALUES (4, 90) ON CONFLICT (role_id, capability_id) DO NOTHING;   -- support.list
INSERT INTO public.role_capability (role_id, capability_id) VALUES (4, 91) ON CONFLICT (role_id, capability_id) DO NOTHING;   -- support.read
INSERT INTO public.role_capability (role_id, capability_id) VALUES (4, 93) ON CONFLICT (role_id, capability_id) DO NOTHING;   -- support.update
INSERT INTO public.role_capability (role_id, capability_id) VALUES (4, 94) ON CONFLICT (role_id, capability_id) DO NOTHING;   -- support.report.download
INSERT INTO public.role_capability (role_id, capability_id) VALUES (4, 95) ON CONFLICT (role_id, capability_id) DO NOTHING;   -- support.lookups.read

-- =========================================================================
-- Role 5: Application Administrator
-- =========================================================================
INSERT INTO public.role_capability (role_id, capability_id) VALUES (5, 90) ON CONFLICT (role_id, capability_id) DO NOTHING;   -- support.list
INSERT INTO public.role_capability (role_id, capability_id) VALUES (5, 91) ON CONFLICT (role_id, capability_id) DO NOTHING;   -- support.read
INSERT INTO public.role_capability (role_id, capability_id) VALUES (5, 93) ON CONFLICT (role_id, capability_id) DO NOTHING;   -- support.update
INSERT INTO public.role_capability (role_id, capability_id) VALUES (5, 94) ON CONFLICT (role_id, capability_id) DO NOTHING;   -- support.report.download
INSERT INTO public.role_capability (role_id, capability_id) VALUES (5, 95) ON CONFLICT (role_id, capability_id) DO NOTHING;   -- support.lookups.read
INSERT INTO public.role_capability (role_id, capability_id) VALUES (5, 100) ON CONFLICT (role_id, capability_id) DO NOTHING;  -- user.admin.list
INSERT INTO public.role_capability (role_id, capability_id) VALUES (5, 101) ON CONFLICT (role_id, capability_id) DO NOTHING;  -- user.admin.read
INSERT INTO public.role_capability (role_id, capability_id) VALUES (5, 102) ON CONFLICT (role_id, capability_id) DO NOTHING;  -- user.admin.update
INSERT INTO public.role_capability (role_id, capability_id) VALUES (5, 103) ON CONFLICT (role_id, capability_id) DO NOTHING;  -- user.admin.config
INSERT INTO public.role_capability (role_id, capability_id) VALUES (5, 110) ON CONFLICT (role_id, capability_id) DO NOTHING;  -- system-settings.read
INSERT INTO public.role_capability (role_id, capability_id) VALUES (5, 111) ON CONFLICT (role_id, capability_id) DO NOTHING;  -- system-settings.update
INSERT INTO public.role_capability (role_id, capability_id) VALUES (5, 120) ON CONFLICT (role_id, capability_id) DO NOTHING;  -- ops.sftp.trigger
INSERT INTO public.role_capability (role_id, capability_id) VALUES (5, 112) ON CONFLICT (role_id, capability_id) DO NOTHING;  -- study.access.update (admin override on any study)

-- =========================================================================
-- Role 6: Uploader  (disabled — no capabilities seeded; controller stays on
-- checkAuth(AccessRole.UPLOADER) so the role can be resurrected in five
-- minutes via UserServiceImpl.BLOCKED_ROLES).
-- =========================================================================


--
