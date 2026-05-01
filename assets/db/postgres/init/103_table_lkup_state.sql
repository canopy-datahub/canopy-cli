-- TOC entry 226 (class 1259 OID 16444)
-- Name: lkup_state; Type: TABLE; Schema: public; Owner: canopy_admin
--

CREATE TABLE public.lkup_state (
    id integer NOT NULL,
    name character varying(256) NOT NULL,
    abbreviation character varying(2) NOT NULL,
    display_order integer NOT NULL
);


ALTER TABLE public.lkup_state OWNER TO canopy_admin;

--
-- TOC entry 225 (class 1259 OID 16443)
-- Name: lkup_state_id_seq; Type: SEQUENCE; Schema: public; Owner: canopy_admin
--

CREATE SEQUENCE public.lkup_state_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.lkup_state_id_seq OWNER TO canopy_admin;

--
-- TOC entry 5492 (class 0 OID 0)
-- Dependencies: 225
-- Name: lkup_state_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: canopy_admin
--

ALTER SEQUENCE public.lkup_state_id_seq OWNED BY public.lkup_state.id;


--
-- TOC entry 4860 (class 2604 OID 16447)
-- Name: lkup_state id; Type: DEFAULT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.lkup_state ALTER COLUMN id SET DEFAULT nextval('public.lkup_state_id_seq'::regclass);


--
-- TOC entry 4995 (class 2606 OID 16449)
-- Name: lkup_state lkup_state_pkey; Type: CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.lkup_state
    ADD CONSTRAINT lkup_state_pkey PRIMARY KEY (id);


--
-- TOC entry 5491 (class 0 OID 0)
-- Dependencies: 226
-- Name: TABLE lkup_state; Type: ACL; Schema: public; Owner: canopy_admin
--

GRANT ALL ON TABLE public.lkup_state TO canopy_user;


--
