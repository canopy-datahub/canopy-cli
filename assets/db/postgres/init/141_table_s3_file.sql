-- TOC entry 248 (class 1259 OID 16560)
-- Name: s3_file; Type: TABLE; Schema: public; Owner: canopy_admin
--

CREATE TABLE public.s3_file (
    id integer NOT NULL,
    uuid character varying(36),
    s3_etag character varying(36),
    file_name character varying(255) NOT NULL,
    file_path character varying(255) NOT NULL,
    file_type_id integer,
    description text,
    checksum_hash character varying(1024),
    to_be_removed boolean DEFAULT false NOT NULL,
    uploaded_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    uploaded_by integer DEFAULT 9999 NOT NULL,
    updated_at timestamp without time zone,
    updated_by integer
);


ALTER TABLE public.s3_file OWNER TO canopy_admin;

--
-- TOC entry 247 (class 1259 OID 16559)
-- Name: s3_file_id_seq; Type: SEQUENCE; Schema: public; Owner: canopy_admin
--

CREATE SEQUENCE public.s3_file_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.s3_file_id_seq OWNER TO canopy_admin;

--
-- TOC entry 5530 (class 0 OID 0)
-- Dependencies: 247
-- Name: s3_file_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: canopy_admin
--

ALTER SEQUENCE public.s3_file_id_seq OWNED BY public.s3_file.id;


--
-- TOC entry 4871 (class 2604 OID 16563)
-- Name: s3_file id; Type: DEFAULT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.s3_file ALTER COLUMN id SET DEFAULT nextval('public.s3_file_id_seq'::regclass);


--
-- TOC entry 5017 (class 2606 OID 16570)
-- Name: s3_file s3_file_pkey; Type: CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.s3_file
    ADD CONSTRAINT s3_file_pkey PRIMARY KEY (id);


--
-- TOC entry 5529 (class 0 OID 0)
-- Dependencies: 248
-- Name: TABLE s3_file; Type: ACL; Schema: public; Owner: canopy_admin
--



--
