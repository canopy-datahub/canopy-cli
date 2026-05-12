--
-- Data for Name: system_setting; Type: TABLE DATA; Schema: public; Owner: canopy_admin
--
-- Seeds the top_banner row with the previously hardcoded demo-site warning
-- so day-one behavior matches the pre-feature site. An admin can edit the
-- text/color/enabled flag from the System Settings page after deploy.
--

INSERT INTO public.system_setting (key, value, updated_at, updated_by_user_id) VALUES (
    'top_banner',
    '{"enabled": true, "text": "⚠ Demo Site: All studies, datasets, and files on this site are synthetic and intended for demonstration purposes only.", "bgColor": "#ffc107"}'::jsonb,
    now(),
    NULL
);


--
