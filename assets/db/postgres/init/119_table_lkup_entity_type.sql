-- TOC entry 238 (class 1259 OID 16517)
-- Name: lkup_entity_type; Type: TABLE; Schema: public; Owner: canopy_admin
--

CREATE TABLE public.lkup_entity_type (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    description text
);


ALTER TABLE public.lkup_entity_type OWNER TO canopy_admin;

--
-- TOC entry 237 (class 1259 OID 16516)
-- Name: lkup_entity_type_id_seq; Type: SEQUENCE; Schema: public; Owner: canopy_admin
--

CREATE SEQUENCE public.lkup_entity_type_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.lkup_entity_type_id_seq OWNER TO canopy_admin;

--
-- TOC entry 5459 (class 0 OID 0)
-- Dependencies: 237
-- Name: lkup_entity_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: canopy_admin
--

ALTER SEQUENCE public.lkup_entity_type_id_seq OWNED BY public.lkup_entity_type.id;


--
-- TOC entry 4866 (class 2604 OID 16520)
-- Name: lkup_entity_type id; Type: DEFAULT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.lkup_entity_type ALTER COLUMN id SET DEFAULT nextval('public.lkup_entity_type_id_seq'::regclass);


--
-- TOC entry 5007 (class 2606 OID 16524)
-- Name: lkup_entity_type lkup_entity_type_pkey; Type: CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.lkup_entity_type
    ADD CONSTRAINT lkup_entity_type_pkey PRIMARY KEY (id);


--
-- TOC entry 5458 (class 0 OID 0)
-- Dependencies: 238
-- Name: TABLE lkup_entity_type; Type: ACL; Schema: public; Owner: canopy_admin
--

GRANT ALL ON TABLE public.lkup_entity_type TO canopy_user;


--
