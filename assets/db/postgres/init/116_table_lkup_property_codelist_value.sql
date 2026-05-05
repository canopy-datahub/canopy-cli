-- TOC entry 232 (class 1259 OID 16484)
-- Name: lkup_property_codelist_value; Type: TABLE; Schema: public; Owner: canopy_admin
--

CREATE TABLE public.lkup_property_codelist_value (
    id integer NOT NULL,
    property_codelist_id integer,
    value text NOT NULL,
    display_order integer
);


ALTER TABLE public.lkup_property_codelist_value OWNER TO canopy_admin;

--
-- TOC entry 231 (class 1259 OID 16483)
-- Name: lkup_property_codelist_value_id_seq; Type: SEQUENCE; Schema: public; Owner: canopy_admin
--

CREATE SEQUENCE public.lkup_property_codelist_value_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.lkup_property_codelist_value_id_seq OWNER TO canopy_admin;

--
-- TOC entry 5476 (class 0 OID 0)
-- Dependencies: 231
-- Name: lkup_property_codelist_value_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: canopy_admin
--

ALTER SEQUENCE public.lkup_property_codelist_value_id_seq OWNED BY public.lkup_property_codelist_value.id;


--
-- TOC entry 4863 (class 2604 OID 16487)
-- Name: lkup_property_codelist_value id; Type: DEFAULT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.lkup_property_codelist_value ALTER COLUMN id SET DEFAULT nextval('public.lkup_property_codelist_value_id_seq'::regclass);


--
-- TOC entry 5001 (class 2606 OID 16491)
-- Name: lkup_property_codelist_value lkup_property_codelist_value_pkey; Type: CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.lkup_property_codelist_value
    ADD CONSTRAINT lkup_property_codelist_value_pkey PRIMARY KEY (id);


--
-- TOC entry 5475 (class 0 OID 0)
-- Dependencies: 232
-- Name: TABLE lkup_property_codelist_value; Type: ACL; Schema: public; Owner: canopy_admin
--



--
