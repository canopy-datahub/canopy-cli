-- TOC entry 260 (class 1259 OID 16743)
-- Name: lkup_role; Type: TABLE; Schema: public; Owner: canopy_admin
--

CREATE TABLE public.lkup_role (
    id integer NOT NULL,
    name character varying(128) NOT NULL,
    description character varying(255)
);


ALTER TABLE public.lkup_role OWNER TO canopy_admin;

--
-- TOC entry 259 (class 1259 OID 16742)
-- Name: lkup_role_id_seq; Type: SEQUENCE; Schema: public; Owner: canopy_admin
--

CREATE SEQUENCE public.lkup_role_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.lkup_role_id_seq OWNER TO canopy_admin;

--
-- TOC entry 5490 (class 0 OID 0)
-- Dependencies: 259
-- Name: lkup_role_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: canopy_admin
--

ALTER SEQUENCE public.lkup_role_id_seq OWNED BY public.lkup_role.id;


--
-- TOC entry 4889 (class 2604 OID 16746)
-- Name: lkup_role id; Type: DEFAULT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.lkup_role ALTER COLUMN id SET DEFAULT nextval('public.lkup_role_id_seq'::regclass);


--
-- TOC entry 5029 (class 2606 OID 16748)
-- Name: lkup_role pk_role; Type: CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.lkup_role
    ADD CONSTRAINT pk_role PRIMARY KEY (id);


--
-- TOC entry 5489 (class 0 OID 0)
-- Dependencies: 260
-- Name: TABLE lkup_role; Type: ACL; Schema: public; Owner: canopy_admin
--

GRANT ALL ON TABLE public.lkup_role TO canopy_user;


--
