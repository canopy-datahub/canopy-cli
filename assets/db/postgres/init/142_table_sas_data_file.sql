-- TOC entry 387 (class 1259 OID 29115)
-- Name: sas_data_file; Type: TABLE; Schema: public; Owner: canopy_admin
--

CREATE TABLE public.sas_data_file (
    id integer NOT NULL,
    parent_data_file_id integer NOT NULL,
    source_file_name text,
    file_category_id integer,
    file_size bigint,
    status_id integer,
    s3_file_id integer,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by integer DEFAULT 9999 NOT NULL,
    modified_at timestamp without time zone,
    modified_by integer
);


ALTER TABLE public.sas_data_file OWNER TO canopy_admin;

--
-- TOC entry 386 (class 1259 OID 29114)
-- Name: sas_data_file_id_seq; Type: SEQUENCE; Schema: public; Owner: canopy_admin
--

CREATE SEQUENCE public.sas_data_file_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.sas_data_file_id_seq OWNER TO canopy_admin;

--
-- TOC entry 5533 (class 0 OID 0)
-- Dependencies: 386
-- Name: sas_data_file_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: canopy_admin
--

ALTER SEQUENCE public.sas_data_file_id_seq OWNED BY public.sas_data_file.id;


--
-- TOC entry 4948 (class 2604 OID 29118)
-- Name: sas_data_file id; Type: DEFAULT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.sas_data_file ALTER COLUMN id SET DEFAULT nextval('public.sas_data_file_id_seq'::regclass);


--
-- TOC entry 5103 (class 2606 OID 29124)
-- Name: sas_data_file sas_data_file_pkey; Type: CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.sas_data_file
    ADD CONSTRAINT sas_data_file_pkey PRIMARY KEY (id);


--
-- TOC entry 5532 (class 0 OID 0)
-- Dependencies: 387
-- Name: TABLE sas_data_file; Type: ACL; Schema: public; Owner: canopy_admin
--

GRANT ALL ON TABLE public.sas_data_file TO canopy_user;


--
