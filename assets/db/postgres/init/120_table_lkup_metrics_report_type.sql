-- TOC entry 309 (class 1259 OID 17259)
-- Name: lkup_metrics_report_type; Type: TABLE; Schema: public; Owner: canopy_admin
--

CREATE TABLE public.lkup_metrics_report_type (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    description text
);


ALTER TABLE public.lkup_metrics_report_type OWNER TO canopy_admin;

--
-- TOC entry 308 (class 1259 OID 17258)
-- Name: lkup_metrics_report_type_id_seq; Type: SEQUENCE; Schema: public; Owner: canopy_admin
--

CREATE SEQUENCE public.lkup_metrics_report_type_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.lkup_metrics_report_type_id_seq OWNER TO canopy_admin;

--
-- TOC entry 5468 (class 0 OID 0)
-- Dependencies: 308
-- Name: lkup_metrics_report_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: canopy_admin
--

ALTER SEQUENCE public.lkup_metrics_report_type_id_seq OWNED BY public.lkup_metrics_report_type.id;


--
-- TOC entry 4933 (class 2604 OID 17262)
-- Name: lkup_metrics_report_type id; Type: DEFAULT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.lkup_metrics_report_type ALTER COLUMN id SET DEFAULT nextval('public.lkup_metrics_report_type_id_seq'::regclass);


--
-- TOC entry 5079 (class 2606 OID 17266)
-- Name: lkup_metrics_report_type lkup_metrics_report_type_pkey; Type: CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.lkup_metrics_report_type
    ADD CONSTRAINT lkup_metrics_report_type_pkey PRIMARY KEY (id);


--
-- TOC entry 5467 (class 0 OID 0)
-- Dependencies: 309
-- Name: TABLE lkup_metrics_report_type; Type: ACL; Schema: public; Owner: canopy_admin
--



--
