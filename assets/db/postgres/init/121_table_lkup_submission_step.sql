-- TOC entry 246 (class 1259 OID 16553)
-- Name: lkup_submission_step; Type: TABLE; Schema: public; Owner: canopy_admin
--

CREATE TABLE public.lkup_submission_step (
    id integer NOT NULL,
    description character varying(255) NOT NULL
);


ALTER TABLE public.lkup_submission_step OWNER TO canopy_admin;

--
-- TOC entry 245 (class 1259 OID 16552)
-- Name: lkup_submission_step_id_seq; Type: SEQUENCE; Schema: public; Owner: canopy_admin
--

CREATE SEQUENCE public.lkup_submission_step_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.lkup_submission_step_id_seq OWNER TO canopy_admin;

--
-- TOC entry 5496 (class 0 OID 0)
-- Dependencies: 245
-- Name: lkup_submission_step_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: canopy_admin
--

ALTER SEQUENCE public.lkup_submission_step_id_seq OWNED BY public.lkup_submission_step.id;


--
-- TOC entry 4870 (class 2604 OID 16556)
-- Name: lkup_submission_step id; Type: DEFAULT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.lkup_submission_step ALTER COLUMN id SET DEFAULT nextval('public.lkup_submission_step_id_seq'::regclass);


--
-- TOC entry 5015 (class 2606 OID 16558)
-- Name: lkup_submission_step lkup_submission_step_pkey; Type: CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.lkup_submission_step
    ADD CONSTRAINT lkup_submission_step_pkey PRIMARY KEY (id);


--
-- TOC entry 5495 (class 0 OID 0)
-- Dependencies: 246
-- Name: TABLE lkup_submission_step; Type: ACL; Schema: public; Owner: canopy_admin
--

GRANT ALL ON TABLE public.lkup_submission_step TO canopy_user;


--
