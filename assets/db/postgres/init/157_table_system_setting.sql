--
-- Name: system_setting; Type: TABLE; Schema: public; Owner: canopy_admin
--
-- Key/value store for global platform settings (banner, future feature flags,
-- etc.). One row per setting key; the JSONB value's shape is interpreted by
-- the application layer per-key. Adding a new setting = INSERT a new row;
-- no schema migration required.
--

CREATE TABLE public.system_setting (
    key character varying(64) NOT NULL,
    value jsonb NOT NULL,
    updated_at timestamp with time zone NOT NULL DEFAULT now(),
    updated_by_user_id integer
);


ALTER TABLE public.system_setting OWNER TO canopy_admin;

--
-- Name: system_setting pk_system_setting; Type: CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.system_setting
    ADD CONSTRAINT pk_system_setting PRIMARY KEY (key);


--
-- Name: TABLE system_setting; Type: ACL; Schema: public; Owner: canopy_admin
--


--
