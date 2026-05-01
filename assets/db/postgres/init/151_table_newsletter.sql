-- TOC entry 400 (class 1259 OID 40548)
-- Name: newsletter; Type: TABLE; Schema: public; Owner: canopy_admin
--

CREATE TABLE public.newsletter (
    id integer NOT NULL,
    title character varying(1024) NOT NULL,
    url text,
    release_date date NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by integer DEFAULT 9999 NOT NULL,
    modified_at timestamp without time zone,
    modified_by integer
);


ALTER TABLE public.newsletter OWNER TO canopy_admin;

--
-- TOC entry 399 (class 1259 OID 40547)
-- Name: newsletter_id_seq; Type: SEQUENCE; Schema: public; Owner: canopy_admin
--

CREATE SEQUENCE public.newsletter_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.newsletter_id_seq OWNER TO canopy_admin;

--
-- TOC entry 5518 (class 0 OID 0)
-- Dependencies: 399
-- Name: newsletter_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: canopy_admin
--

ALTER SEQUENCE public.newsletter_id_seq OWNED BY public.newsletter.id;


--
-- TOC entry 4956 (class 2604 OID 40551)
-- Name: newsletter id; Type: DEFAULT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.newsletter ALTER COLUMN id SET DEFAULT nextval('public.newsletter_id_seq'::regclass);


--
-- TOC entry 5109 (class 2606 OID 40557)
-- Name: newsletter newsletter_pkey; Type: CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.newsletter
    ADD CONSTRAINT newsletter_pkey PRIMARY KEY (id);


--
-- TOC entry 5517 (class 0 OID 0)
-- Dependencies: 400
-- Name: TABLE newsletter; Type: ACL; Schema: public; Owner: canopy_admin
--

GRANT ALL ON TABLE public.newsletter TO canopy_user;


--
