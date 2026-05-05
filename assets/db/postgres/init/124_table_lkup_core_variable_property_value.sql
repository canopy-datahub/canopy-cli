-- TOC entry 423 (class 1259 OID 46776)
-- Name: lkup_core_variable_property_value; Type: TABLE; Schema: public; Owner: canopy_admin
--

CREATE TABLE public.lkup_core_variable_property_value (
    id integer NOT NULL,
    variable_name character varying(256) NOT NULL,
    entity_property_id integer NOT NULL,
    property_value text,
    value_index integer,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by integer DEFAULT 9999,
    modified_at timestamp without time zone,
    modified_by integer
);


ALTER TABLE public.lkup_core_variable_property_value OWNER TO canopy_admin;

--
-- TOC entry 422 (class 1259 OID 46775)
-- Name: lkup_core_variable_property_value_id_seq; Type: SEQUENCE; Schema: public; Owner: canopy_admin
--

CREATE SEQUENCE public.lkup_core_variable_property_value_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.lkup_core_variable_property_value_id_seq OWNER TO canopy_admin;

--
-- TOC entry 5590 (class 0 OID 0)
-- Dependencies: 422
-- Name: lkup_core_variable_property_value_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: canopy_admin
--

ALTER SEQUENCE public.lkup_core_variable_property_value_id_seq OWNED BY public.lkup_core_variable_property_value.id;


--
-- TOC entry 4969 (class 2604 OID 46779)
-- Name: lkup_core_variable_property_value id; Type: DEFAULT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.lkup_core_variable_property_value ALTER COLUMN id SET DEFAULT nextval('public.lkup_core_variable_property_value_id_seq'::regclass);


--
-- TOC entry 5127 (class 2606 OID 46785)
-- Name: lkup_core_variable_property_value lkup_core_variable_property_value_pkey; Type: CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.lkup_core_variable_property_value
    ADD CONSTRAINT lkup_core_variable_property_value_pkey PRIMARY KEY (id);


--
-- TOC entry 5589 (class 0 OID 0)
-- Dependencies: 423
-- Name: TABLE lkup_core_variable_property_value; Type: ACL; Schema: public; Owner: canopy_admin
--



--
