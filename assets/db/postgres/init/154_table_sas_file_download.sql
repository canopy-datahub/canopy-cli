-- TOC entry 389 (class 1259 OID 29146)
-- Name: sas_file_download; Type: TABLE; Schema: public; Owner: canopy_admin
--

CREATE TABLE public.sas_file_download (
    id integer NOT NULL,
    sas_file_id integer NOT NULL,
    download_by integer NOT NULL,
    download_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.sas_file_download OWNER TO canopy_admin;

--
-- TOC entry 388 (class 1259 OID 29145)
-- Name: sas_file_download_id_seq; Type: SEQUENCE; Schema: public; Owner: canopy_admin
--

CREATE SEQUENCE public.sas_file_download_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.sas_file_download_id_seq OWNER TO canopy_admin;

--
-- TOC entry 5536 (class 0 OID 0)
-- Dependencies: 388
-- Name: sas_file_download_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: canopy_admin
--

ALTER SEQUENCE public.sas_file_download_id_seq OWNED BY public.sas_file_download.id;


--
-- TOC entry 4951 (class 2604 OID 29149)
-- Name: sas_file_download id; Type: DEFAULT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.sas_file_download ALTER COLUMN id SET DEFAULT nextval('public.sas_file_download_id_seq'::regclass);


--
-- TOC entry 5105 (class 2606 OID 29152)
-- Name: sas_file_download sas_file_download_pkey; Type: CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.sas_file_download
    ADD CONSTRAINT sas_file_download_pkey PRIMARY KEY (id);


--
-- TOC entry 5535 (class 0 OID 0)
-- Dependencies: 389
-- Name: TABLE sas_file_download; Type: ACL; Schema: public; Owner: canopy_admin
--

GRANT ALL ON TABLE public.sas_file_download TO canopy_user;


--
