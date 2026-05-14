-- TOC entry 250 (class 1259 OID 16577)
-- Name: study; Type: TABLE; Schema: public; Owner: canopy_admin
--

CREATE TABLE public.study (
    id integer NOT NULL,
    uuid character varying(36),
    private_key_url character varying(255),
    public_key_url character varying(255),
    file_name character varying(255),
    file_url character varying(255),
    center_id integer NOT NULL,
    center_admin_uuid character varying(36),
    status_id integer,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by integer DEFAULT 9999 NOT NULL,
    modified_at timestamp without time zone,
    modified_by integer,
    access_level character varying(16) NOT NULL DEFAULT 'PUBLIC'
        CHECK (access_level IN ('PUBLIC', 'LIMITED', 'PRIVATE'))
);

CREATE INDEX IF NOT EXISTS idx_study_access_level ON public.study (access_level);
CREATE INDEX IF NOT EXISTS idx_study_created_by   ON public.study (created_by);


ALTER TABLE public.study OWNER TO canopy_admin;

--
-- TOC entry 249 (class 1259 OID 16576)
-- Name: study_id_seq; Type: SEQUENCE; Schema: public; Owner: canopy_admin
--

CREATE SEQUENCE public.study_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.study_id_seq OWNER TO canopy_admin;

--
-- TOC entry 5545 (class 0 OID 0)
-- Dependencies: 249
-- Name: study_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: canopy_admin
--

ALTER SEQUENCE public.study_id_seq OWNED BY public.study.id;


--
-- TOC entry 4875 (class 2604 OID 16580)
-- Name: study id; Type: DEFAULT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.study ALTER COLUMN id SET DEFAULT nextval('public.study_id_seq'::regclass);


--
-- TOC entry 5019 (class 2606 OID 16586)
-- Name: study study_pkey; Type: CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.study
    ADD CONSTRAINT study_pkey PRIMARY KEY (id);


--
-- TOC entry 5541 (class 0 OID 0)
-- Dependencies: 250
-- Name: TABLE study; Type: ACL; Schema: public; Owner: canopy_admin
--



--
