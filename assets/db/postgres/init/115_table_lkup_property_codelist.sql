-- TOC entry 230 (class 1259 OID 16475)
-- Name: lkup_property_codelist; Type: TABLE; Schema: public; Owner: canopy_admin
--

CREATE TABLE public.lkup_property_codelist (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    description text
);


ALTER TABLE public.lkup_property_codelist OWNER TO canopy_admin;

--
-- TOC entry 229 (class 1259 OID 16474)
-- Name: lkup_property_codelist_id_seq; Type: SEQUENCE; Schema: public; Owner: canopy_admin
--

CREATE SEQUENCE public.lkup_property_codelist_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.lkup_property_codelist_id_seq OWNER TO canopy_admin;

--
-- TOC entry 5474 (class 0 OID 0)
-- Dependencies: 229
-- Name: lkup_property_codelist_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: canopy_admin
--

ALTER SEQUENCE public.lkup_property_codelist_id_seq OWNED BY public.lkup_property_codelist.id;


--
-- TOC entry 4862 (class 2604 OID 16478)
-- Name: lkup_property_codelist id; Type: DEFAULT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.lkup_property_codelist ALTER COLUMN id SET DEFAULT nextval('public.lkup_property_codelist_id_seq'::regclass);


--
-- TOC entry 4999 (class 2606 OID 16482)
-- Name: lkup_property_codelist lkup_property_codelist_pkey; Type: CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.lkup_property_codelist
    ADD CONSTRAINT lkup_property_codelist_pkey PRIMARY KEY (id);


--
-- TOC entry 5473 (class 0 OID 0)
-- Dependencies: 230
-- Name: TABLE lkup_property_codelist; Type: ACL; Schema: public; Owner: canopy_admin
--



--
