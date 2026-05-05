-- TOC entry 258 (class 1259 OID 16713)
-- Name: institution; Type: TABLE; Schema: public; Owner: canopy_admin
--

CREATE TABLE public.institution (
    id integer NOT NULL,
    ror_id character varying(36),
    name character varying(256) NOT NULL,
    acronym character varying(50),
    alternate_name text,
    institution_type_id integer,
    is_for_profit boolean,
    country_id integer,
    state_id integer,
    province_region character varying(256),
    status_id integer NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by integer,
    modified_at timestamp without time zone,
    modified_by integer
);


ALTER TABLE public.institution OWNER TO canopy_admin;

--
-- TOC entry 257 (class 1259 OID 16712)
-- Name: institution_id_seq; Type: SEQUENCE; Schema: public; Owner: canopy_admin
--

CREATE SEQUENCE public.institution_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.institution_id_seq OWNER TO canopy_admin;

--
-- TOC entry 5441 (class 0 OID 0)
-- Dependencies: 257
-- Name: institution_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: canopy_admin
--

ALTER SEQUENCE public.institution_id_seq OWNED BY public.institution.id;


--
-- TOC entry 4887 (class 2604 OID 16716)
-- Name: institution id; Type: DEFAULT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.institution ALTER COLUMN id SET DEFAULT nextval('public.institution_id_seq'::regclass);


--
-- TOC entry 5027 (class 2606 OID 16721)
-- Name: institution institution_pkey; Type: CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.institution
    ADD CONSTRAINT institution_pkey PRIMARY KEY (id);


--
-- TOC entry 5440 (class 0 OID 0)
-- Dependencies: 258
-- Name: TABLE institution; Type: ACL; Schema: public; Owner: canopy_admin
--



--
