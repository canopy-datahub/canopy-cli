-- TOC entry 428 (class 1259 OID 58938)
-- Name: lkup_variable_category; Type: TABLE; Schema: public; Owner: canopy_admin
--

CREATE TABLE public.lkup_variable_category (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    description text
);


ALTER TABLE public.lkup_variable_category OWNER TO canopy_admin;

--
-- TOC entry 5131 (class 2606 OID 58944)
-- Name: lkup_variable_category lkup_variable_category_pkey; Type: CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.lkup_variable_category
    ADD CONSTRAINT lkup_variable_category_pkey PRIMARY KEY (id);


--
-- TOC entry 5500 (class 0 OID 0)
-- Dependencies: 428
-- Name: TABLE lkup_variable_category; Type: ACL; Schema: public; Owner: canopy_admin
--



--
