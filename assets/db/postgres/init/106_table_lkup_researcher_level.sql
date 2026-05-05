-- TOC entry 262 (class 1259 OID 16750)
-- Name: lkup_researcher_level; Type: TABLE; Schema: public; Owner: canopy_admin
--

CREATE TABLE public.lkup_researcher_level (
    id integer NOT NULL,
    name character varying(128) NOT NULL,
    description character varying(255)
);


ALTER TABLE public.lkup_researcher_level OWNER TO canopy_admin;

--
-- TOC entry 261 (class 1259 OID 16749)
-- Name: lkup_researcher_level_id_seq; Type: SEQUENCE; Schema: public; Owner: canopy_admin
--

CREATE SEQUENCE public.lkup_researcher_level_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.lkup_researcher_level_id_seq OWNER TO canopy_admin;

--
-- TOC entry 5485 (class 0 OID 0)
-- Dependencies: 261
-- Name: lkup_researcher_level_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: canopy_admin
--

ALTER SEQUENCE public.lkup_researcher_level_id_seq OWNED BY public.lkup_researcher_level.id;


--
-- TOC entry 4890 (class 2604 OID 16753)
-- Name: lkup_researcher_level id; Type: DEFAULT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.lkup_researcher_level ALTER COLUMN id SET DEFAULT nextval('public.lkup_researcher_level_id_seq'::regclass);


--
-- TOC entry 5031 (class 2606 OID 16755)
-- Name: lkup_researcher_level pk_researcher_level; Type: CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.lkup_researcher_level
    ADD CONSTRAINT pk_researcher_level PRIMARY KEY (id);


--
-- TOC entry 5484 (class 0 OID 0)
-- Dependencies: 262
-- Name: TABLE lkup_researcher_level; Type: ACL; Schema: public; Owner: canopy_admin
--



--
