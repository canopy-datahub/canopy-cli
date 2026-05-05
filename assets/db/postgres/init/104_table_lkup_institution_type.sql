-- TOC entry 224 (class 1259 OID 16437)
-- Name: lkup_institution_type; Type: TABLE; Schema: public; Owner: canopy_admin
--

CREATE TABLE public.lkup_institution_type (
    id integer NOT NULL,
    name character varying(256) NOT NULL,
    display_order integer NOT NULL
);


ALTER TABLE public.lkup_institution_type OWNER TO canopy_admin;

--
-- TOC entry 223 (class 1259 OID 16436)
-- Name: lkup_institution_type_id_seq; Type: SEQUENCE; Schema: public; Owner: canopy_admin
--

CREATE SEQUENCE public.lkup_institution_type_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.lkup_institution_type_id_seq OWNER TO canopy_admin;

--
-- TOC entry 5466 (class 0 OID 0)
-- Dependencies: 223
-- Name: lkup_institution_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: canopy_admin
--

ALTER SEQUENCE public.lkup_institution_type_id_seq OWNED BY public.lkup_institution_type.id;


--
-- TOC entry 4859 (class 2604 OID 16440)
-- Name: lkup_institution_type id; Type: DEFAULT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.lkup_institution_type ALTER COLUMN id SET DEFAULT nextval('public.lkup_institution_type_id_seq'::regclass);


--
-- TOC entry 4993 (class 2606 OID 16442)
-- Name: lkup_institution_type lkup_institution_type_pkey; Type: CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.lkup_institution_type
    ADD CONSTRAINT lkup_institution_type_pkey PRIMARY KEY (id);


--
-- TOC entry 5465 (class 0 OID 0)
-- Dependencies: 224
-- Name: TABLE lkup_institution_type; Type: ACL; Schema: public; Owner: canopy_admin
--



--
