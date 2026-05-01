-- TOC entry 228 (class 1259 OID 16466)
-- Name: lkup_status; Type: TABLE; Schema: public; Owner: canopy_admin
--

CREATE TABLE public.lkup_status (
    id integer NOT NULL,
    name text NOT NULL,
    usage text,
    display_order integer,
    description text
);


ALTER TABLE public.lkup_status OWNER TO canopy_admin;

--
-- TOC entry 227 (class 1259 OID 16465)
-- Name: lkup_status_id_seq; Type: SEQUENCE; Schema: public; Owner: canopy_admin
--

CREATE SEQUENCE public.lkup_status_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.lkup_status_id_seq OWNER TO canopy_admin;

--
-- TOC entry 5494 (class 0 OID 0)
-- Dependencies: 227
-- Name: lkup_status_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: canopy_admin
--

ALTER SEQUENCE public.lkup_status_id_seq OWNED BY public.lkup_status.id;


--
-- TOC entry 4861 (class 2604 OID 16469)
-- Name: lkup_status id; Type: DEFAULT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.lkup_status ALTER COLUMN id SET DEFAULT nextval('public.lkup_status_id_seq'::regclass);


--
-- TOC entry 4997 (class 2606 OID 16473)
-- Name: lkup_status lkup_status_pkey; Type: CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.lkup_status
    ADD CONSTRAINT lkup_status_pkey PRIMARY KEY (id);


--
-- TOC entry 5493 (class 0 OID 0)
-- Dependencies: 228
-- Name: TABLE lkup_status; Type: ACL; Schema: public; Owner: canopy_admin
--

GRANT ALL ON TABLE public.lkup_status TO canopy_user;


--
