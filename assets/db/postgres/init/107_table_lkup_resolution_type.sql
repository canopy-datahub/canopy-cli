-- TOC entry 315 (class 1259 OID 17296)
-- Name: lkup_resolution_type; Type: TABLE; Schema: public; Owner: canopy_admin
--

CREATE TABLE public.lkup_resolution_type (
    id integer NOT NULL,
    name character varying(128) NOT NULL,
    description character varying(255),
    display_order integer
);


ALTER TABLE public.lkup_resolution_type OWNER TO canopy_admin;

--
-- TOC entry 314 (class 1259 OID 17295)
-- Name: lkup_resolution_type_id_seq; Type: SEQUENCE; Schema: public; Owner: canopy_admin
--

CREATE SEQUENCE public.lkup_resolution_type_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.lkup_resolution_type_id_seq OWNER TO canopy_admin;

--
-- TOC entry 5487 (class 0 OID 0)
-- Dependencies: 314
-- Name: lkup_resolution_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: canopy_admin
--

ALTER SEQUENCE public.lkup_resolution_type_id_seq OWNED BY public.lkup_resolution_type.id;


--
-- TOC entry 4936 (class 2604 OID 17299)
-- Name: lkup_resolution_type id; Type: DEFAULT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.lkup_resolution_type ALTER COLUMN id SET DEFAULT nextval('public.lkup_resolution_type_id_seq'::regclass);


--
-- TOC entry 5085 (class 2606 OID 17301)
-- Name: lkup_resolution_type pk_lkup_resolution_type; Type: CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.lkup_resolution_type
    ADD CONSTRAINT pk_lkup_resolution_type PRIMARY KEY (id);


--
-- TOC entry 5486 (class 0 OID 0)
-- Dependencies: 315
-- Name: TABLE lkup_resolution_type; Type: ACL; Schema: public; Owner: canopy_admin
--



--
