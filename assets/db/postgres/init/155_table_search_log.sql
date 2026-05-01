-- TOC entry 402 (class 1259 OID 40559)
-- Name: search_log; Type: TABLE; Schema: public; Owner: canopy_admin
--

CREATE TABLE public.search_log (
    id bigint NOT NULL,
    query text NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.search_log OWNER TO canopy_admin;

--
-- TOC entry 401 (class 1259 OID 40558)
-- Name: search_log_id_seq; Type: SEQUENCE; Schema: public; Owner: canopy_admin
--

CREATE SEQUENCE public.search_log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.search_log_id_seq OWNER TO canopy_admin;

--
-- TOC entry 5539 (class 0 OID 0)
-- Dependencies: 401
-- Name: search_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: canopy_admin
--

ALTER SEQUENCE public.search_log_id_seq OWNED BY public.search_log.id;


--
-- TOC entry 4959 (class 2604 OID 40562)
-- Name: search_log id; Type: DEFAULT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.search_log ALTER COLUMN id SET DEFAULT nextval('public.search_log_id_seq'::regclass);


--
-- TOC entry 5111 (class 2606 OID 40567)
-- Name: search_log search_log_pkey; Type: CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.search_log
    ADD CONSTRAINT search_log_pkey PRIMARY KEY (id);


--
-- TOC entry 5538 (class 0 OID 0)
-- Dependencies: 402
-- Name: TABLE search_log; Type: ACL; Schema: public; Owner: canopy_admin
--

GRANT ALL ON TABLE public.search_log TO canopy_user;


--
