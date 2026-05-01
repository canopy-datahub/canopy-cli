-- TOC entry 283 (class 1259 OID 16921)
-- Name: data_submission; Type: TABLE; Schema: public; Owner: canopy_admin
--

CREATE TABLE public.data_submission (
    id integer NOT NULL,
    study_id integer NOT NULL,
    submitter_user_id integer,
    description text,
    step_id integer NOT NULL,
    is_validated boolean DEFAULT false NOT NULL,
    status_id integer NOT NULL,
    date_submitted timestamp without time zone,
    date_approved timestamp without time zone,
    file_rejection_reason text,
    file_rejected_count integer,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by integer DEFAULT 9999 NOT NULL,
    modified_at timestamp without time zone,
    modified_by integer
);


ALTER TABLE public.data_submission OWNER TO canopy_admin;

--
-- TOC entry 282 (class 1259 OID 16920)
-- Name: data_submission_id_seq; Type: SEQUENCE; Schema: public; Owner: canopy_admin
--

CREATE SEQUENCE public.data_submission_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.data_submission_id_seq OWNER TO canopy_admin;

--
-- TOC entry 5416 (class 0 OID 0)
-- Dependencies: 282
-- Name: data_submission_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: canopy_admin
--

ALTER SEQUENCE public.data_submission_id_seq OWNED BY public.data_submission.id;


--
-- TOC entry 4905 (class 2604 OID 16924)
-- Name: data_submission id; Type: DEFAULT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.data_submission ALTER COLUMN id SET DEFAULT nextval('public.data_submission_id_seq'::regclass);


--
-- TOC entry 5053 (class 2606 OID 16931)
-- Name: data_submission data_submission_pkey; Type: CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.data_submission
    ADD CONSTRAINT data_submission_pkey PRIMARY KEY (id);


--
-- TOC entry 5415 (class 0 OID 0)
-- Dependencies: 283
-- Name: TABLE data_submission; Type: ACL; Schema: public; Owner: canopy_admin
--

GRANT ALL ON TABLE public.data_submission TO canopy_user;


--
