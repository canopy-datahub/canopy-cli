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
INSERT INTO public.role_capability (role_id, capability_id) VALUES (1,  1);   -- submission.create
INSERT INTO public.role_capability (role_id, capability_id) VALUES (1,  2);   -- submission.read.own
INSERT INTO public.role_capability (role_id, capability_id) VALUES (1,  3);   -- submission.delete.own
INSERT INTO public.role_capability (role_id, capability_id) VALUES (1,  4);   -- submission.submit
INSERT INTO public.role_capability (role_id, capability_id) VALUES (1,  5);   -- submission.file.upload
INSERT INTO public.role_capability (role_id, capability_id) VALUES (1,  6);   -- submission.file.delete
INSERT INTO public.role_capability (role_id, capability_id) VALUES (1,  7);   -- submission.file.replace
INSERT INTO public.role_capability (role_id, capability_id) VALUES (1,  8);   -- submission.file.list
INSERT INTO public.role_capability (role_id, capability_id) VALUES (1,  9);   -- submission.bundle.create
INSERT INTO public.role_capability (role_id, capability_id) VALUES (1, 10);   -- submission.bundle.read
INSERT INTO public.role_capability (role_id, capability_id) VALUES (1, 11);   -- submission.bundle.update
INSERT INTO public.role_capability (role_id, capability_id) VALUES (1, 12);   -- submission.bundle.delete
INSERT INTO public.role_capability (role_id, capability_id) VALUES (1, 13);   -- submission.bundle.previousPage
INSERT INTO public.role_capability (role_id, capability_id) VALUES (1, 14);   -- submission.validate
INSERT INTO public.role_capability (role_id, capability_id) VALUES (1, 15);   -- submission.validation.read
INSERT INTO public.role_capability (role_id, capability_id) VALUES (1, 16);   -- submission.validation.acknowledge
INSERT INTO public.role_capability (role_id, capability_id) VALUES (1, 17);   -- submission.validation.errors.read
INSERT INTO public.role_capability (role_id, capability_id) VALUES (1, 18);   -- submission.config.read
INSERT INTO public.role_capability (role_id, capability_id) VALUES (1, 20);   -- study.center.create
INSERT INTO public.role_capability (role_id, capability_id) VALUES (1, 21);   -- study.center.edit
INSERT INTO public.role_capability (role_id, capability_id) VALUES (1, 22);   -- study.center.list
INSERT INTO public.role_capability (role_id, capability_id) VALUES (1, 26);   -- study.values.read
INSERT INTO public.role_capability (role_id, capability_id) VALUES (1, 27);   -- study.delete
INSERT INTO public.role_capability (role_id, capability_id) VALUES (1, 28);   -- study.uuids.export

-- =========================================================================
-- Role 2: Officer
-- =========================================================================
INSERT INTO public.role_capability (role_id, capability_id) VALUES (2, 60);   -- metrics.hub-content.view
INSERT INTO public.role_capability (role_id, capability_id) VALUES (2, 61);   -- metrics.hub-content.export
INSERT INTO public.role_capability (role_id, capability_id) VALUES (2, 62);   -- metrics.user-activity.view
INSERT INTO public.role_capability (role_id, capability_id) VALUES (2, 63);   -- metrics.user-activity.export
INSERT INTO public.role_capability (role_id, capability_id) VALUES (2, 64);   -- metrics.user-population.view
INSERT INTO public.role_capability (role_id, capability_id) VALUES (2, 65);   -- metrics.user-population.export
INSERT INTO public.role_capability (role_id, capability_id) VALUES (2, 66);   -- metrics.submission-activity.view
INSERT INTO public.role_capability (role_id, capability_id) VALUES (2, 67);   -- metrics.submission-activity.export
INSERT INTO public.role_capability (role_id, capability_id) VALUES (2, 68);   -- metrics.harmonization.view
INSERT INTO public.role_capability (role_id, capability_id) VALUES (2, 69);   -- metrics.harmonization.export
INSERT INTO public.role_capability (role_id, capability_id) VALUES (2, 70);   -- metrics.harmonization.run
INSERT INTO public.role_capability (role_id, capability_id) VALUES (2, 71);   -- metrics.weekly-report.upload
INSERT INTO public.role_capability (role_id, capability_id) VALUES (2, 90);   -- support.list
INSERT INTO public.role_capability (role_id, capability_id) VALUES (2, 91);   -- support.read
INSERT INTO public.role_capability (role_id, capability_id) VALUES (2, 92);   -- support.officer.read
INSERT INTO public.role_capability (role_id, capability_id) VALUES (2, 94);   -- support.report.download
INSERT INTO public.role_capability (role_id, capability_id) VALUES (2, 95);   -- support.lookups.read

-- =========================================================================
-- Role 3: Data Curator
-- =========================================================================
INSERT INTO public.role_capability (role_id, capability_id) VALUES (3, 15);   -- submission.validation.read
INSERT INTO public.role_capability (role_id, capability_id) VALUES (3, 17);   -- submission.validation.errors.read
-- study.curator.create (capability 23) intentionally NOT bound to the Curator
-- role: per platform policy, curators can only approve studies, not create
-- them. The capability remains defined in lkup_capability; re-add this row to
-- restore curator-side study creation.
INSERT INTO public.role_capability (role_id, capability_id) VALUES (3, 24);   -- study.curator.edit
INSERT INTO public.role_capability (role_id, capability_id) VALUES (3, 25);   -- study.curator.list
INSERT INTO public.role_capability (role_id, capability_id) VALUES (3, 26);   -- study.values.read
INSERT INTO public.role_capability (role_id, capability_id) VALUES (3, 27);   -- study.delete
INSERT INTO public.role_capability (role_id, capability_id) VALUES (3, 29);   -- study.unapproved.read
INSERT INTO public.role_capability (role_id, capability_id) VALUES (3, 40);   -- curator.submission.list
INSERT INTO public.role_capability (role_id, capability_id) VALUES (3, 41);   -- curator.submission.read
INSERT INTO public.role_capability (role_id, capability_id) VALUES (3, 42);   -- curator.submission.review
INSERT INTO public.role_capability (role_id, capability_id) VALUES (3, 43);   -- curator.submission.download.bulk
-- The three upload-portal curator capabilities (50 upload-portal.dashboard.view,
-- 51 upload-portal.dashboard.delete, 52 upload-portal.file.download) are
-- intentionally NOT bound to the Curator role: the Uploader role is disabled
-- platform-wide (see UserServiceImpl.BLOCKED_ROLES), so no uploads ever land
-- in the curator queue. The capabilities remain defined in lkup_capability;
-- restore the three role_capability rows here to re-enable the
-- /curator/downloads page when Uploader is resurrected.
INSERT INTO public.role_capability (role_id, capability_id) VALUES (3, 80);   -- report.weekly-study.download

-- =========================================================================
-- Role 4: Support Team
-- =========================================================================
INSERT INTO public.role_capability (role_id, capability_id) VALUES (4, 90);   -- support.list
INSERT INTO public.role_capability (role_id, capability_id) VALUES (4, 91);   -- support.read
INSERT INTO public.role_capability (role_id, capability_id) VALUES (4, 93);   -- support.update
INSERT INTO public.role_capability (role_id, capability_id) VALUES (4, 94);   -- support.report.download
INSERT INTO public.role_capability (role_id, capability_id) VALUES (4, 95);   -- support.lookups.read

-- =========================================================================
-- Role 5: Application Administrator
-- =========================================================================
INSERT INTO public.role_capability (role_id, capability_id) VALUES (5, 90);   -- support.list
INSERT INTO public.role_capability (role_id, capability_id) VALUES (5, 91);   -- support.read
INSERT INTO public.role_capability (role_id, capability_id) VALUES (5, 93);   -- support.update
INSERT INTO public.role_capability (role_id, capability_id) VALUES (5, 94);   -- support.report.download
INSERT INTO public.role_capability (role_id, capability_id) VALUES (5, 95);   -- support.lookups.read
INSERT INTO public.role_capability (role_id, capability_id) VALUES (5, 100);  -- user.admin.list
INSERT INTO public.role_capability (role_id, capability_id) VALUES (5, 101);  -- user.admin.read
INSERT INTO public.role_capability (role_id, capability_id) VALUES (5, 102);  -- user.admin.update
INSERT INTO public.role_capability (role_id, capability_id) VALUES (5, 103);  -- user.admin.config
INSERT INTO public.role_capability (role_id, capability_id) VALUES (5, 110);  -- system-settings.read
INSERT INTO public.role_capability (role_id, capability_id) VALUES (5, 111);  -- system-settings.update
INSERT INTO public.role_capability (role_id, capability_id) VALUES (5, 120);  -- ops.sftp.trigger

-- =========================================================================
-- Role 6: Uploader  (disabled — no capabilities seeded; controller stays on
-- checkAuth(AccessRole.UPLOADER) so the role can be resurrected in five
-- minutes via UserServiceImpl.BLOCKED_ROLES).
-- =========================================================================


--
