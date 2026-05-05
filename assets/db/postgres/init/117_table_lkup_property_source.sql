-- TOC entry 244 (class 1259 OID 16544)
-- Name: lkup_property_source; Type: TABLE; Schema: public; Owner: canopy_admin
--

CREATE TABLE public.lkup_property_source (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    description text
);


ALTER TABLE public.lkup_property_source OWNER TO canopy_admin;

--
-- TOC entry 243 (class 1259 OID 16543)
-- Name: lkup_property_source_id_seq; Type: SEQUENCE; Schema: public; Owner: canopy_admin
--

CREATE SEQUENCE public.lkup_property_source_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.lkup_property_source_id_seq OWNER TO canopy_admin;

--
-- TOC entry 5478 (class 0 OID 0)
-- Dependencies: 243
-- Name: lkup_property_source_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: canopy_admin
--

ALTER SEQUENCE public.lkup_property_source_id_seq OWNED BY public.lkup_property_source.id;


--
-- TOC entry 4869 (class 2604 OID 16547)
-- Name: lkup_property_source id; Type: DEFAULT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.lkup_property_source ALTER COLUMN id SET DEFAULT nextval('public.lkup_property_source_id_seq'::regclass);


--
-- TOC entry 5013 (class 2606 OID 16551)
-- Name: lkup_property_source lkup_property_source_pkey; Type: CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.lkup_property_source
    ADD CONSTRAINT lkup_property_source_pkey PRIMARY KEY (id);


--
-- TOC entry 5477 (class 0 OID 0)
-- Dependencies: 244
-- Name: TABLE lkup_property_source; Type: ACL; Schema: public; Owner: canopy_admin
--



--
