-- TOC entry 256 (class 1259 OID 16675)
-- Name: study_property_value; Type: TABLE; Schema: public; Owner: canopy_admin
--

CREATE TABLE public.study_property_value (
    id integer NOT NULL,
    study_id integer NOT NULL,
    entity_property_id integer NOT NULL,
    property_value text,
    value_index integer,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by integer DEFAULT 9999,
    modified_at timestamp without time zone,
    modified_by integer
);


ALTER TABLE public.study_property_value OWNER TO canopy_admin;

--
-- TOC entry 255 (class 1259 OID 16674)
-- Name: study_property_value_id_seq; Type: SEQUENCE; Schema: public; Owner: canopy_admin
--

CREATE SEQUENCE public.study_property_value_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.study_property_value_id_seq OWNER TO canopy_admin;

--
-- TOC entry 5548 (class 0 OID 0)
-- Dependencies: 255
-- Name: study_property_value_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: canopy_admin
--

ALTER SEQUENCE public.study_property_value_id_seq OWNED BY public.study_property_value.id;


--
-- TOC entry 4884 (class 2604 OID 16678)
-- Name: study_property_value id; Type: DEFAULT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.study_property_value ALTER COLUMN id SET DEFAULT nextval('public.study_property_value_id_seq'::regclass);


--
-- TOC entry 5025 (class 2606 OID 16684)
-- Name: study_property_value study_property_value_pkey; Type: CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.study_property_value
    ADD CONSTRAINT study_property_value_pkey PRIMARY KEY (id);


--
-- TOC entry 5547 (class 0 OID 0)
-- Dependencies: 256
-- Name: TABLE study_property_value; Type: ACL; Schema: public; Owner: canopy_admin
--



--
