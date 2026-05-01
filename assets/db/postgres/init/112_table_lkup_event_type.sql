-- TOC entry 297 (class 1259 OID 17111)
-- Name: lkup_event_type; Type: TABLE; Schema: public; Owner: canopy_admin
--

CREATE TABLE public.lkup_event_type (
    id integer NOT NULL,
    name character varying(1024) NOT NULL
);


ALTER TABLE public.lkup_event_type OWNER TO canopy_admin;

--
-- TOC entry 296 (class 1259 OID 17110)
-- Name: lkup_event_type_id_seq; Type: SEQUENCE; Schema: public; Owner: canopy_admin
--

CREATE SEQUENCE public.lkup_event_type_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.lkup_event_type_id_seq OWNER TO canopy_admin;

--
-- TOC entry 5461 (class 0 OID 0)
-- Dependencies: 296
-- Name: lkup_event_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: canopy_admin
--

ALTER SEQUENCE public.lkup_event_type_id_seq OWNED BY public.lkup_event_type.id;


--
-- TOC entry 4918 (class 2604 OID 17114)
-- Name: lkup_event_type id; Type: DEFAULT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.lkup_event_type ALTER COLUMN id SET DEFAULT nextval('public.lkup_event_type_id_seq'::regclass);


--
-- TOC entry 5067 (class 2606 OID 17118)
-- Name: lkup_event_type lkup_event_type_pkey; Type: CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.lkup_event_type
    ADD CONSTRAINT lkup_event_type_pkey PRIMARY KEY (id);


--
-- TOC entry 5460 (class 0 OID 0)
-- Dependencies: 297
-- Name: TABLE lkup_event_type; Type: ACL; Schema: public; Owner: canopy_admin
--

GRANT ALL ON TABLE public.lkup_event_type TO canopy_user;


--
