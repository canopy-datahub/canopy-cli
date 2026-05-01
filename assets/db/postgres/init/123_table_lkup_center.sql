-- TOC entry 236 (class 1259 OID 16507)
-- Name: lkup_center; Type: TABLE; Schema: public; Owner: canopy_admin
--

CREATE TABLE public.lkup_center (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    description text
);


ALTER TABLE public.lkup_center OWNER TO canopy_admin;

--
-- TOC entry 235 (class 1259 OID 16506)
-- Name: lkup_center_id_seq; Type: SEQUENCE; Schema: public; Owner: canopy_admin
--

CREATE SEQUENCE public.lkup_center_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.lkup_center_id_seq OWNER TO canopy_admin;

--
-- TOC entry 5457 (class 0 OID 0)
-- Dependencies: 235
-- Name: lkup_center_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: canopy_admin
--

ALTER SEQUENCE public.lkup_center_id_seq OWNED BY public.lkup_center.id;


--
-- TOC entry 4865 (class 2604 OID 16510)
-- Name: lkup_center id; Type: DEFAULT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.lkup_center ALTER COLUMN id SET DEFAULT nextval('public.lkup_center_id_seq'::regclass);


--
-- TOC entry 5005 (class 2606 OID 16514)
-- Name: lkup_center lkup_center_pkey; Type: CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.lkup_center
    ADD CONSTRAINT lkup_center_pkey PRIMARY KEY (id);


--
-- TOC entry 5456 (class 0 OID 0)
-- Dependencies: 236
-- Name: TABLE lkup_center; Type: ACL; Schema: public; Owner: canopy_admin
--

GRANT ALL ON TABLE public.lkup_center TO canopy_user;


--
