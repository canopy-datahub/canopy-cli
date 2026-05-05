-- TOC entry 285 (class 1259 OID 16953)
-- Name: data_file; Type: TABLE; Schema: public; Owner: canopy_admin
--

CREATE TABLE public.data_file (
    id integer NOT NULL,
    submission_id integer NOT NULL,
    source_file_name text,
    normalized_file_name text,
    version_no integer,
    is_current_version boolean,
    original_data_file_id integer,
    file_category_id integer,
    file_size bigint,
    variable_count integer,
    sample_size integer,
    file_headers text,
    pii_phi boolean,
    pii_phi_validation_result jsonb,
    status_id integer NOT NULL,
    s3_file_id integer,
    dictionary_file_id integer,
    metadata_file_id integer,
    comments text,
    cde_validation boolean,
    validation_result jsonb,
    acknowledged boolean,
    dict_validation boolean,
    meta_validation boolean,
    approval_date timestamp without time zone,
    reject_date timestamp without time zone,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by integer DEFAULT 9999 NOT NULL,
    modified_at timestamp without time zone,
    modified_by integer,
    has_variable boolean
);


ALTER TABLE public.data_file OWNER TO canopy_admin;

--
-- TOC entry 284 (class 1259 OID 16952)
-- Name: data_file_id_seq; Type: SEQUENCE; Schema: public; Owner: canopy_admin
--

CREATE SEQUENCE public.data_file_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.data_file_id_seq OWNER TO canopy_admin;

--
-- TOC entry 5410 (class 0 OID 0)
-- Dependencies: 284
-- Name: data_file_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: canopy_admin
--

ALTER SEQUENCE public.data_file_id_seq OWNED BY public.data_file.id;

--
-- TOC entry 4909 (class 2604 OID 16956)
-- Name: data_file id; Type: DEFAULT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.data_file ALTER COLUMN id SET DEFAULT nextval('public.data_file_id_seq'::regclass);


--
-- TOC entry 5055 (class 2606 OID 16962)
-- Name: data_file data_file_pkey; Type: CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.data_file
    ADD CONSTRAINT data_file_pkey PRIMARY KEY (id);


--
-- TOC entry 5406 (class 0 OID 0)
-- Dependencies: 285
-- Name: TABLE data_file; Type: ACL; Schema: public; Owner: canopy_admin
--



--
