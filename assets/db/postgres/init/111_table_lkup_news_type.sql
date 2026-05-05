-- TOC entry 299 (class 1259 OID 17120)
-- Name: lkup_news_type; Type: TABLE; Schema: public; Owner: canopy_admin
--

CREATE TABLE public.lkup_news_type (
    id integer NOT NULL,
    name character varying(1024) NOT NULL
);


ALTER TABLE public.lkup_news_type OWNER TO canopy_admin;

--
-- TOC entry 298 (class 1259 OID 17119)
-- Name: lkup_news_type_id_seq; Type: SEQUENCE; Schema: public; Owner: canopy_admin
--

CREATE SEQUENCE public.lkup_news_type_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.lkup_news_type_id_seq OWNER TO canopy_admin;

--
-- TOC entry 5471 (class 0 OID 0)
-- Dependencies: 298
-- Name: lkup_news_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: canopy_admin
--

ALTER SEQUENCE public.lkup_news_type_id_seq OWNED BY public.lkup_news_type.id;


--
-- TOC entry 4919 (class 2604 OID 17123)
-- Name: lkup_news_type id; Type: DEFAULT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.lkup_news_type ALTER COLUMN id SET DEFAULT nextval('public.lkup_news_type_id_seq'::regclass);


--
-- TOC entry 5069 (class 2606 OID 17127)
-- Name: lkup_news_type lkup_news_type_pkey; Type: CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.lkup_news_type
    ADD CONSTRAINT lkup_news_type_pkey PRIMARY KEY (id);


--
-- TOC entry 5470 (class 0 OID 0)
-- Dependencies: 299
-- Name: TABLE lkup_news_type; Type: ACL; Schema: public; Owner: canopy_admin
--



--
