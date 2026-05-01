-- TOC entry 242 (class 1259 OID 16535)
-- Name: lkup_property_type; Type: TABLE; Schema: public; Owner: canopy_admin
--

CREATE TABLE public.lkup_property_type (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    description text
);


ALTER TABLE public.lkup_property_type OWNER TO canopy_admin;

--
-- TOC entry 241 (class 1259 OID 16534)
-- Name: lkup_property_type_id_seq; Type: SEQUENCE; Schema: public; Owner: canopy_admin
--

CREATE SEQUENCE public.lkup_property_type_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.lkup_property_type_id_seq OWNER TO canopy_admin;

--
-- TOC entry 5480 (class 0 OID 0)
-- Dependencies: 241
-- Name: lkup_property_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: canopy_admin
--

ALTER SEQUENCE public.lkup_property_type_id_seq OWNED BY public.lkup_property_type.id;


--
-- TOC entry 4868 (class 2604 OID 16538)
-- Name: lkup_property_type id; Type: DEFAULT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.lkup_property_type ALTER COLUMN id SET DEFAULT nextval('public.lkup_property_type_id_seq'::regclass);


--
-- TOC entry 5011 (class 2606 OID 16542)
-- Name: lkup_property_type lkup_property_type_pkey; Type: CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.lkup_property_type
    ADD CONSTRAINT lkup_property_type_pkey PRIMARY KEY (id);


--
-- TOC entry 5479 (class 0 OID 0)
-- Dependencies: 242
-- Name: TABLE lkup_property_type; Type: ACL; Schema: public; Owner: canopy_admin
--

GRANT ALL ON TABLE public.lkup_property_type TO canopy_user;


--
