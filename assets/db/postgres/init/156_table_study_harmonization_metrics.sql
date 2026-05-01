-- TOC entry 321 (class 1259 OID 17359)
-- Name: study_harmonization_metrics; Type: TABLE; Schema: public; Owner: canopy_admin
--

CREATE TABLE public.study_harmonization_metrics (
    id integer NOT NULL,
    report_id integer NOT NULL,
    study_id integer,
    center character varying(128),
    orig_transform_pairs_count integer,
    variable_count integer,
    harmonizable_tier_1_variable_count integer,
    harmonized_tier_1_variable_count integer,
    harmonizable_tier_1_variables text,
    harmonized_tier_1_variables text,
    variables text
);


ALTER TABLE public.study_harmonization_metrics OWNER TO canopy_admin;

--
-- TOC entry 320 (class 1259 OID 17358)
-- Name: study_harmonization_metrics_id_seq; Type: SEQUENCE; Schema: public; Owner: canopy_admin
--

CREATE SEQUENCE public.study_harmonization_metrics_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.study_harmonization_metrics_id_seq OWNER TO canopy_admin;

--
-- TOC entry 5543 (class 0 OID 0)
-- Dependencies: 320
-- Name: study_harmonization_metrics_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: canopy_admin
--

ALTER SEQUENCE public.study_harmonization_metrics_id_seq OWNED BY public.study_harmonization_metrics.id;


--
-- TOC entry 4940 (class 2604 OID 17362)
-- Name: study_harmonization_metrics id; Type: DEFAULT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.study_harmonization_metrics ALTER COLUMN id SET DEFAULT nextval('public.study_harmonization_metrics_id_seq'::regclass);


--
-- TOC entry 5091 (class 2606 OID 17364)
-- Name: study_harmonization_metrics study_harmonization_metrics_pkey; Type: CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.study_harmonization_metrics
    ADD CONSTRAINT study_harmonization_metrics_pkey PRIMARY KEY (id);


--
-- TOC entry 5542 (class 0 OID 0)
-- Dependencies: 321
-- Name: TABLE study_harmonization_metrics; Type: ACL; Schema: public; Owner: canopy_admin
--

GRANT ALL ON TABLE public.study_harmonization_metrics TO canopy_user;


--
