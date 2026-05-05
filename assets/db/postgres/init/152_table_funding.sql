-- TOC entry 398 (class 1259 OID 40537)
-- Name: funding; Type: TABLE; Schema: public; Owner: canopy_admin
--

CREATE TABLE public.funding (
    id integer NOT NULL,
    slug character varying(50) NOT NULL,
    title character varying(1024) NOT NULL,
    description text,
    notice_number character varying(256),
    activity_code character varying(256),
    url character varying(1024),
    release_date date NOT NULL,
    expiration_date date,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by integer DEFAULT 9999 NOT NULL,
    modified_at timestamp without time zone,
    modified_by integer
);


ALTER TABLE public.funding OWNER TO canopy_admin;

--
-- TOC entry 397 (class 1259 OID 40536)
-- Name: funding_id_seq; Type: SEQUENCE; Schema: public; Owner: canopy_admin
--

CREATE SEQUENCE public.funding_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.funding_id_seq OWNER TO canopy_admin;

--
-- TOC entry 5435 (class 0 OID 0)
-- Dependencies: 397
-- Name: funding_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: canopy_admin
--

ALTER SEQUENCE public.funding_id_seq OWNED BY public.funding.id;


--
-- TOC entry 4953 (class 2604 OID 40540)
-- Name: funding id; Type: DEFAULT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.funding ALTER COLUMN id SET DEFAULT nextval('public.funding_id_seq'::regclass);


--
-- TOC entry 5107 (class 2606 OID 40546)
-- Name: funding funding_pkey; Type: CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.funding
    ADD CONSTRAINT funding_pkey PRIMARY KEY (id);


--
-- TOC entry 5434 (class 0 OID 0)
-- Dependencies: 398
-- Name: TABLE funding; Type: ACL; Schema: public; Owner: canopy_admin
--



--
