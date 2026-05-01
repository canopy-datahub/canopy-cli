-- TOC entry 412 (class 1259 OID 43523)
-- Name: user_file_upload; Type: TABLE; Schema: public; Owner: canopy_admin
--

CREATE TABLE public.user_file_upload (
    id integer NOT NULL,
    study_id integer NOT NULL,
    file_name character varying(1024) NOT NULL,
    s3_file_id integer,
    upload_by integer NOT NULL,
    upload_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    download_by integer,
    download_at timestamp without time zone,
    delete_by integer,
    delete_at timestamp without time zone
);


ALTER TABLE public.user_file_upload OWNER TO canopy_admin;

--
-- TOC entry 411 (class 1259 OID 43522)
-- Name: user_file_upload_id_seq; Type: SEQUENCE; Schema: public; Owner: canopy_admin
--

CREATE SEQUENCE public.user_file_upload_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.user_file_upload_id_seq OWNER TO canopy_admin;

--
-- TOC entry 5563 (class 0 OID 0)
-- Dependencies: 411
-- Name: user_file_upload_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: canopy_admin
--

ALTER SEQUENCE public.user_file_upload_id_seq OWNED BY public.user_file_upload.id;


--
-- TOC entry 4963 (class 2604 OID 43526)
-- Name: user_file_upload id; Type: DEFAULT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.user_file_upload ALTER COLUMN id SET DEFAULT nextval('public.user_file_upload_id_seq'::regclass);


--
-- TOC entry 5117 (class 2606 OID 43531)
-- Name: user_file_upload pk_user_file_upload_id; Type: CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.user_file_upload
    ADD CONSTRAINT pk_user_file_upload_id PRIMARY KEY (id);


--
-- TOC entry 5562 (class 0 OID 0)
-- Dependencies: 412
-- Name: TABLE user_file_upload; Type: ACL; Schema: public; Owner: canopy_admin
--

GRANT ALL ON TABLE public.user_file_upload TO canopy_user;


--
