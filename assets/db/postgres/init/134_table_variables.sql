-- TOC entry 430 (class 1259 OID 58952)
-- Name: variables; Type: TABLE; Schema: public; Owner: canopy_admin
--

CREATE TABLE public.variables (
    id integer NOT NULL,
    category_id integer NOT NULL,
    center_id integer,
    study_id integer,
    file_id integer,
    name character varying(256) NOT NULL,
    label text,
    section text,
    datatype text,
    description text,
    unit text,
    cardinality text,
    terms text,
    keywords text
);


ALTER TABLE public.variables OWNER TO canopy_admin;

--
-- TOC entry 429 (class 1259 OID 58951)
-- Name: variables_id_seq; Type: SEQUENCE; Schema: public; Owner: canopy_admin
--

CREATE SEQUENCE public.variables_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.variables_id_seq OWNER TO canopy_admin;

--
-- TOC entry 5593 (class 0 OID 0)
-- Dependencies: 429
-- Name: variables_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: canopy_admin
--

ALTER SEQUENCE public.variables_id_seq OWNED BY public.variables.id;


--
-- TOC entry 4973 (class 2604 OID 58955)
-- Name: variables id; Type: DEFAULT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.variables ALTER COLUMN id SET DEFAULT nextval('public.variables_id_seq'::regclass);


--
-- TOC entry 5133 (class 2606 OID 58959)
-- Name: variables variables_pkey; Type: CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.variables
    ADD CONSTRAINT variables_pkey PRIMARY KEY (id);


--
-- TOC entry 5592 (class 0 OID 0)
-- Dependencies: 430
-- Name: TABLE variables; Type: ACL; Schema: public; Owner: canopy_admin
--



--
