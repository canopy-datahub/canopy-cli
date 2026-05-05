-- TOC entry 317 (class 1259 OID 17303)
-- Name: lkup_support_request_type; Type: TABLE; Schema: public; Owner: canopy_admin
--

CREATE TABLE public.lkup_support_request_type (
    id integer NOT NULL,
    name character varying(128) NOT NULL,
    description character varying(255),
    display_order integer
);


ALTER TABLE public.lkup_support_request_type OWNER TO canopy_admin;

--
-- TOC entry 316 (class 1259 OID 17302)
-- Name: lkup_support_request_type_id_seq; Type: SEQUENCE; Schema: public; Owner: canopy_admin
--

CREATE SEQUENCE public.lkup_support_request_type_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.lkup_support_request_type_id_seq OWNER TO canopy_admin;

--
-- TOC entry 5498 (class 0 OID 0)
-- Dependencies: 316
-- Name: lkup_support_request_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: canopy_admin
--

ALTER SEQUENCE public.lkup_support_request_type_id_seq OWNED BY public.lkup_support_request_type.id;


--
-- TOC entry 4937 (class 2604 OID 17306)
-- Name: lkup_support_request_type id; Type: DEFAULT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.lkup_support_request_type ALTER COLUMN id SET DEFAULT nextval('public.lkup_support_request_type_id_seq'::regclass);


--
-- TOC entry 5087 (class 2606 OID 17308)
-- Name: lkup_support_request_type pk_lkup_support_request_type; Type: CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.lkup_support_request_type
    ADD CONSTRAINT pk_lkup_support_request_type PRIMARY KEY (id);


--
-- TOC entry 5497 (class 0 OID 0)
-- Dependencies: 317
-- Name: TABLE lkup_support_request_type; Type: ACL; Schema: public; Owner: canopy_admin
--



--
