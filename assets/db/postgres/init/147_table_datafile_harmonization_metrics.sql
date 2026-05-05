-- TOC entry 313 (class 1259 OID 17282)
-- Name: datafile_harmonization_metrics; Type: TABLE; Schema: public; Owner: canopy_admin
--

CREATE TABLE public.datafile_harmonization_metrics (
    id integer NOT NULL,
    report_id integer NOT NULL,
    orig_file_name character varying(1024),
    transform_file_name character varying(1024),
    study_id character varying(10),
    center character varying(128),
    orig_variable_count integer,
    transform_variable_count integer,
    harmonizable_tier_1_variable_count integer,
    harmonized_tier_1_variable_count integer,
    orig_variables text,
    transform_variables text,
    harmonizable_tier_1_variables text,
    harmonized_tier_1_variables text
);


ALTER TABLE public.datafile_harmonization_metrics OWNER TO canopy_admin;

--
-- TOC entry 312 (class 1259 OID 17281)
-- Name: datafile_harmonization_metrics_id_seq; Type: SEQUENCE; Schema: public; Owner: canopy_admin
--

CREATE SEQUENCE public.datafile_harmonization_metrics_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.datafile_harmonization_metrics_id_seq OWNER TO canopy_admin;

--
-- TOC entry 5419 (class 0 OID 0)
-- Dependencies: 312
-- Name: datafile_harmonization_metrics_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: canopy_admin
--

ALTER SEQUENCE public.datafile_harmonization_metrics_id_seq OWNED BY public.datafile_harmonization_metrics.id;


--
-- TOC entry 4935 (class 2604 OID 17285)
-- Name: datafile_harmonization_metrics id; Type: DEFAULT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.datafile_harmonization_metrics ALTER COLUMN id SET DEFAULT nextval('public.datafile_harmonization_metrics_id_seq'::regclass);


--
-- TOC entry 5083 (class 2606 OID 17289)
-- Name: datafile_harmonization_metrics datafile_harmonization_metrics_pkey; Type: CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.datafile_harmonization_metrics
    ADD CONSTRAINT datafile_harmonization_metrics_pkey PRIMARY KEY (id);


--
-- TOC entry 5418 (class 0 OID 0)
-- Dependencies: 313
-- Name: TABLE datafile_harmonization_metrics; Type: ACL; Schema: public; Owner: canopy_admin
--



--
