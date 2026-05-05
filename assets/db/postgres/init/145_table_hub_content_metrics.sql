-- TOC entry 330 (class 1259 OID 22320)
-- Name: hub_content_metrics; Type: TABLE; Schema: public; Owner: canopy_admin
--

CREATE TABLE public.hub_content_metrics (
    id integer NOT NULL,
    report_id integer NOT NULL,
    center text,
    study_id integer,
    study_title text,
    study_status text,
    study_create_date timestamp without time zone,
    study_has_data_file boolean,
    total_file_size numeric,
    total_file_count integer,
    data_file_count integer,
    orig_data_file_count integer,
    standardized_data_file_count integer,
    metadata_file_count integer,
    dictionary_file_count integer,
    readme_file_count integer,
    other_file_count integer
);


ALTER TABLE public.hub_content_metrics OWNER TO canopy_admin;

--
-- TOC entry 329 (class 1259 OID 22319)
-- Name: hub_content_metrics_id_seq; Type: SEQUENCE; Schema: public; Owner: canopy_admin
--

CREATE SEQUENCE public.hub_content_metrics_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.hub_content_metrics_id_seq OWNER TO canopy_admin;

--
-- TOC entry 5438 (class 0 OID 0)
-- Dependencies: 329
-- Name: hub_content_metrics_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: canopy_admin
--

ALTER SEQUENCE public.hub_content_metrics_id_seq OWNED BY public.hub_content_metrics.id;

ALTER TABLE public.hub_content_metrics
    ALTER COLUMN id SET DEFAULT nextval('hub_content_metrics_id_seq'::regclass);


--
-- TOC entry 4942 (class 2604 OID 22323)
-- Name: hub_content_metrics id; Type: DEFAULT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.hub_content_metrics ALTER COLUMN id SET DEFAULT nextval('public.hub_content_metrics_id_seq'::regclass);


--
-- TOC entry 5095 (class 2606 OID 22327)
-- Name: hub_content_metrics hub_content_metrics_pkey; Type: CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.hub_content_metrics
    ADD CONSTRAINT hub_content_metrics_pkey PRIMARY KEY (id);


--
-- TOC entry 5437 (class 0 OID 0)
-- Dependencies: 330
-- Name: TABLE hub_content_metrics; Type: ACL; Schema: public; Owner: canopy_admin
--



--
