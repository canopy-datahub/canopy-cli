-- TOC entry 295 (class 1259 OID 17087)
-- Name: entity_property_mta_mapping; Type: TABLE; Schema: public; Owner: canopy_admin
--

CREATE TABLE public.entity_property_mta_mapping (
    id integer NOT NULL,
    entity_property_id integer,
    pdf_field_name text,
    codelist_id integer,
    codelist_value_id integer,
    description text
);


ALTER TABLE public.entity_property_mta_mapping OWNER TO canopy_admin;

--
-- TOC entry 294 (class 1259 OID 17086)
-- Name: entity_property_mta_mapping_id_seq; Type: SEQUENCE; Schema: public; Owner: canopy_admin
--

CREATE SEQUENCE public.entity_property_mta_mapping_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.entity_property_mta_mapping_id_seq OWNER TO canopy_admin;

--
-- TOC entry 5426 (class 0 OID 0)
-- Dependencies: 294
-- Name: entity_property_mta_mapping_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: canopy_admin
--

ALTER SEQUENCE public.entity_property_mta_mapping_id_seq OWNED BY public.entity_property_mta_mapping.id;


--
-- TOC entry 4917 (class 2604 OID 17090)
-- Name: entity_property_mta_mapping id; Type: DEFAULT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.entity_property_mta_mapping ALTER COLUMN id SET DEFAULT nextval('public.entity_property_mta_mapping_id_seq'::regclass);


--
-- TOC entry 5065 (class 2606 OID 17094)
-- Name: entity_property_mta_mapping entity_property_mta_mapping_pkey; Type: CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.entity_property_mta_mapping
    ADD CONSTRAINT entity_property_mta_mapping_pkey PRIMARY KEY (id);


--
-- TOC entry 5425 (class 0 OID 0)
-- Dependencies: 295
-- Name: TABLE entity_property_mta_mapping; Type: ACL; Schema: public; Owner: canopy_admin
--

GRANT ALL ON TABLE public.entity_property_mta_mapping TO canopy_user;


--
