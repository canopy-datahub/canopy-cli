-- TOC entry 254 (class 1259 OID 16654)
-- Name: entity_property_display_setting; Type: TABLE; Schema: public; Owner: canopy_admin
--

CREATE TABLE public.entity_property_display_setting (
    id integer NOT NULL,
    entity_property_id integer NOT NULL,
    page text NOT NULL,
    display_section text,
    display_label text,
    display_order integer,
    is_facet boolean DEFAULT false,
    facet_order integer,
    group_property_id integer,
    group_order integer,
    is_sortable boolean DEFAULT false
);


ALTER TABLE public.entity_property_display_setting OWNER TO canopy_admin;

--
-- TOC entry 253 (class 1259 OID 16653)
-- Name: entity_property_display_setting_id_seq; Type: SEQUENCE; Schema: public; Owner: canopy_admin
--

CREATE SEQUENCE public.entity_property_display_setting_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.entity_property_display_setting_id_seq OWNER TO canopy_admin;

--
-- TOC entry 5423 (class 0 OID 0)
-- Dependencies: 253
-- Name: entity_property_display_setting_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: canopy_admin
--

ALTER SEQUENCE public.entity_property_display_setting_id_seq OWNED BY public.entity_property_display_setting.id;


--
-- TOC entry 4881 (class 2604 OID 16657)
-- Name: entity_property_display_setting id; Type: DEFAULT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.entity_property_display_setting ALTER COLUMN id SET DEFAULT nextval('public.entity_property_display_setting_id_seq'::regclass);


--
-- TOC entry 5023 (class 2606 OID 16663)
-- Name: entity_property_display_setting entity_property_display_setting_pkey; Type: CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.entity_property_display_setting
    ADD CONSTRAINT entity_property_display_setting_pkey PRIMARY KEY (id);


--
-- TOC entry 5422 (class 0 OID 0)
-- Dependencies: 254
-- Name: TABLE entity_property_display_setting; Type: ACL; Schema: public; Owner: canopy_admin
--



--
