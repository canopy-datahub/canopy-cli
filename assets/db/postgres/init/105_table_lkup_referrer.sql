-- TOC entry 415 (class 1259 OID 46679)
-- Name: lkup_referrer; Type: TABLE; Schema: public; Owner: canopy_admin
--

CREATE TABLE public.lkup_referrer (
    id integer NOT NULL,
    name character varying(256) NOT NULL,
    specify_prompt character varying(256),
    description character varying(255),
    display_order integer
);


ALTER TABLE public.lkup_referrer OWNER TO canopy_admin;

--
-- TOC entry 414 (class 1259 OID 46678)
-- Name: lkup_referrer_id_seq; Type: SEQUENCE; Schema: public; Owner: canopy_admin
--

CREATE SEQUENCE public.lkup_referrer_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.lkup_referrer_id_seq OWNER TO canopy_admin;

--
-- TOC entry 5482 (class 0 OID 0)
-- Dependencies: 414
-- Name: lkup_referrer_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: canopy_admin
--

ALTER SEQUENCE public.lkup_referrer_id_seq OWNED BY public.lkup_referrer.id;


--
-- TOC entry 4965 (class 2604 OID 46682)
-- Name: lkup_referrer id; Type: DEFAULT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.lkup_referrer ALTER COLUMN id SET DEFAULT nextval('public.lkup_referrer_id_seq'::regclass);


--
-- TOC entry 5119 (class 2606 OID 46686)
-- Name: lkup_referrer pk_referrer; Type: CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.lkup_referrer
    ADD CONSTRAINT pk_referrer PRIMARY KEY (id);


--
-- TOC entry 5481 (class 0 OID 0)
-- Dependencies: 415
-- Name: TABLE lkup_referrer; Type: ACL; Schema: public; Owner: canopy_admin
--

GRANT ALL ON TABLE public.lkup_referrer TO canopy_user;


--
