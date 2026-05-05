-- TOC entry 252 (class 1259 OID 16623)
-- Name: entity_property; Type: TABLE; Schema: public; Owner: canopy_admin
--

CREATE TABLE public.entity_property (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    description text,
    entity_type_id integer NOT NULL,
    property_type_id integer NOT NULL,
    property_source_id integer NOT NULL,
    is_group_property boolean DEFAULT false,
    cardinality boolean DEFAULT false,
    code_list_id integer,
    is_hidden boolean
);


ALTER TABLE public.entity_property OWNER TO canopy_admin;

--
-- TOC entry 251 (class 1259 OID 16622)
-- Name: entity_property_id_seq; Type: SEQUENCE; Schema: public; Owner: canopy_admin
--

CREATE SEQUENCE public.entity_property_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.entity_property_id_seq OWNER TO canopy_admin;

--
-- TOC entry 5424 (class 0 OID 0)
-- Dependencies: 251
-- Name: entity_property_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: canopy_admin
--

ALTER SEQUENCE public.entity_property_id_seq OWNED BY public.entity_property.id;


--
-- TOC entry 4878 (class 2604 OID 16626)
-- Name: entity_property id; Type: DEFAULT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.entity_property ALTER COLUMN id SET DEFAULT nextval('public.entity_property_id_seq'::regclass);


--
-- TOC entry 5021 (class 2606 OID 16632)
-- Name: entity_property entity_property_pkey; Type: CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.entity_property
    ADD CONSTRAINT entity_property_pkey PRIMARY KEY (id);


--
-- TOC entry 5421 (class 0 OID 0)
-- Dependencies: 252
-- Name: TABLE entity_property; Type: ACL; Schema: public; Owner: canopy_admin
--



--
