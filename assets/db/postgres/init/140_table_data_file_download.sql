-- TOC entry 293 (class 1259 OID 17069)
-- Name: data_file_download; Type: TABLE; Schema: public; Owner: canopy_admin
--

CREATE TABLE public.data_file_download (
    id integer NOT NULL,
    data_file_id integer NOT NULL,
    download_by integer NOT NULL,
    download_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.data_file_download OWNER TO canopy_admin;

--
-- TOC entry 292 (class 1259 OID 17068)
-- Name: data_file_download_id_seq; Type: SEQUENCE; Schema: public; Owner: canopy_admin
--

CREATE SEQUENCE public.data_file_download_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.data_file_download_id_seq OWNER TO canopy_admin;

--
-- TOC entry 5408 (class 0 OID 0)
-- Dependencies: 292
-- Name: data_file_download_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: canopy_admin
--

ALTER SEQUENCE public.data_file_download_id_seq OWNED BY public.data_file_download.id;


--
-- TOC entry 4915 (class 2604 OID 17072)
-- Name: data_file_download id; Type: DEFAULT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.data_file_download ALTER COLUMN id SET DEFAULT nextval('public.data_file_download_id_seq'::regclass);


--
-- TOC entry 5063 (class 2606 OID 17075)
-- Name: data_file_download data_file_download_pkey; Type: CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.data_file_download
    ADD CONSTRAINT data_file_download_pkey PRIMARY KEY (id);


--
-- TOC entry 5407 (class 0 OID 0)
-- Dependencies: 293
-- Name: TABLE data_file_download; Type: ACL; Schema: public; Owner: canopy_admin
--



--
