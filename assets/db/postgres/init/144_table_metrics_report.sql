-- TOC entry 311 (class 1259 OID 17268)
-- Name: metrics_report; Type: TABLE; Schema: public; Owner: canopy_admin
--

CREATE TABLE public.metrics_report (
    id integer NOT NULL,
    report_date date NOT NULL,
    type_id integer NOT NULL,
    description text
);


ALTER TABLE public.metrics_report OWNER TO canopy_admin;

--
-- TOC entry 310 (class 1259 OID 17267)
-- Name: metrics_report_id_seq; Type: SEQUENCE; Schema: public; Owner: canopy_admin
--

CREATE SEQUENCE public.metrics_report_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.metrics_report_id_seq OWNER TO canopy_admin;

--
-- TOC entry 5509 (class 0 OID 0)
-- Dependencies: 310
-- Name: metrics_report_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: canopy_admin
--

ALTER SEQUENCE public.metrics_report_id_seq OWNED BY public.metrics_report.id;


--
-- TOC entry 4934 (class 2604 OID 17271)
-- Name: metrics_report id; Type: DEFAULT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.metrics_report ALTER COLUMN id SET DEFAULT nextval('public.metrics_report_id_seq'::regclass);


--
-- TOC entry 5081 (class 2606 OID 17275)
-- Name: metrics_report metrics_report_pkey; Type: CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.metrics_report
    ADD CONSTRAINT metrics_report_pkey PRIMARY KEY (id);


--
-- TOC entry 5508 (class 0 OID 0)
-- Dependencies: 311
-- Name: TABLE metrics_report; Type: ACL; Schema: public; Owner: canopy_admin
--



--
