-- TOC entry 240 (class 1259 OID 16526)
-- Name: lkup_file_type; Type: TABLE; Schema: public; Owner: canopy_admin
--

CREATE TABLE public.lkup_file_type (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    description text
);


ALTER TABLE public.lkup_file_type OWNER TO canopy_admin;

--
-- TOC entry 239 (class 1259 OID 16525)
-- Name: lkup_file_type_id_seq; Type: SEQUENCE; Schema: public; Owner: canopy_admin
--

CREATE SEQUENCE public.lkup_file_type_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.lkup_file_type_id_seq OWNER TO canopy_admin;

--
-- TOC entry 5464 (class 0 OID 0)
-- Dependencies: 239
-- Name: lkup_file_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: canopy_admin
--

ALTER SEQUENCE public.lkup_file_type_id_seq OWNED BY public.lkup_file_type.id;


--
-- TOC entry 4867 (class 2604 OID 16529)
-- Name: lkup_file_type id; Type: DEFAULT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.lkup_file_type ALTER COLUMN id SET DEFAULT nextval('public.lkup_file_type_id_seq'::regclass);


--
-- TOC entry 5009 (class 2606 OID 16533)
-- Name: lkup_file_type lkup_file_type_pkey; Type: CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.lkup_file_type
    ADD CONSTRAINT lkup_file_type_pkey PRIMARY KEY (id);


--
-- TOC entry 5463 (class 0 OID 0)
-- Dependencies: 240
-- Name: TABLE lkup_file_type; Type: ACL; Schema: public; Owner: canopy_admin
--

GRANT ALL ON TABLE public.lkup_file_type TO canopy_user;


--
