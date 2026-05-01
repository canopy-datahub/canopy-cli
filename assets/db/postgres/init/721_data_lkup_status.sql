-- Data for Name: lkup_status; Type: TABLE DATA; Schema: public; Owner: canopy_admin
--

INSERT INTO public.lkup_status VALUES (1, 'active', 'general', 10, NULL);
INSERT INTO public.lkup_status VALUES (2, 'inactive', 'general', 20, NULL);
INSERT INTO public.lkup_status VALUES (4, 'initiated', 'support_request', 100, NULL);
INSERT INTO public.lkup_status VALUES (6, 'in_progress', 'support_request', 120, NULL);
INSERT INTO public.lkup_status VALUES (8, 'closed', 'support_request', 140, NULL);
INSERT INTO public.lkup_status VALUES (9, 'draft', 'file', 10, NULL);
INSERT INTO public.lkup_status VALUES (10, 'approved', 'file', 40, NULL);
INSERT INTO public.lkup_status VALUES (11, 'rejected', 'file', 50, NULL);
INSERT INTO public.lkup_status VALUES (12, 'pending approval', 'file', 20, NULL);
INSERT INTO public.lkup_status VALUES (13, 'approved - pending confirmation', 'file', 30, NULL);
INSERT INTO public.lkup_status VALUES (15, 'submitted', 'data_submission', 70, NULL);
INSERT INTO public.lkup_status VALUES (14, 'in_progress', 'data_submission', 60, NULL);
INSERT INTO public.lkup_status VALUES (18, 'completed', 'data_submission', 100, NULL);
INSERT INTO public.lkup_status VALUES (23, 'active', 'institution', 20, NULL);
INSERT INTO public.lkup_status VALUES (24, 'inactive', 'institution', 30, NULL);
INSERT INTO public.lkup_status VALUES (22, 'pending', 'institution', 10, NULL);
INSERT INTO public.lkup_status VALUES (25, 'Draft', 'study', 10, NULL);
INSERT INTO public.lkup_status VALUES (26, 'In Review', 'study', 20, NULL);
INSERT INTO public.lkup_status VALUES (27, 'Approved', 'study', 30, NULL);


--
