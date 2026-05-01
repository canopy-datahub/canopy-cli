-- TOC entry 222 (class 1259 OID 16430)
-- Name: lkup_country; Type: TABLE; Schema: public; Owner: canopy_admin
--

CREATE TABLE public.lkup_country (
    id integer NOT NULL,
    name character varying(256) NOT NULL,
    display_order integer NOT NULL
);


ALTER TABLE public.lkup_country OWNER TO canopy_admin;

--
-- TOC entry 221 (class 1259 OID 16429)
-- Name: lkup_country_id_seq; Type: SEQUENCE; Schema: public; Owner: canopy_admin
--

CREATE SEQUENCE public.lkup_country_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.lkup_country_id_seq OWNER TO canopy_admin;

--
-- TOC entry 5453 (class 0 OID 0)
-- Dependencies: 221
-- Name: lkup_country_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: canopy_admin
--

ALTER SEQUENCE public.lkup_country_id_seq OWNED BY public.lkup_country.id;


--
-- TOC entry 4858 (class 2604 OID 16433)
-- Name: lkup_country id; Type: DEFAULT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.lkup_country ALTER COLUMN id SET DEFAULT nextval('public.lkup_country_id_seq'::regclass);


--
-- TOC entry 4991 (class 2606 OID 16435)
-- Name: lkup_country lkup_country_pkey; Type: CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.lkup_country
    ADD CONSTRAINT lkup_country_pkey PRIMARY KEY (id);


--
-- TOC entry 5452 (class 0 OID 0)
-- Dependencies: 222
-- Name: TABLE lkup_country; Type: ACL; Schema: public; Owner: canopy_admin
--

GRANT ALL ON TABLE public.lkup_country TO canopy_user;


--
