-- TOC entry 234 (class 1259 OID 16498)
-- Name: lkup_data_file_category; Type: TABLE; Schema: public; Owner: canopy_admin
--

CREATE TABLE public.lkup_data_file_category (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    description text,
    category_group text,
    display_order integer NOT NULL
);


ALTER TABLE public.lkup_data_file_category OWNER TO canopy_admin;

--
-- TOC entry 233 (class 1259 OID 16497)
-- Name: lkup_data_file_category_id_seq; Type: SEQUENCE; Schema: public; Owner: canopy_admin
--

CREATE SEQUENCE public.lkup_data_file_category_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.lkup_data_file_category_id_seq OWNER TO canopy_admin;

--
-- TOC entry 5455 (class 0 OID 0)
-- Dependencies: 233
-- Name: lkup_data_file_category_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: canopy_admin
--

ALTER SEQUENCE public.lkup_data_file_category_id_seq OWNED BY public.lkup_data_file_category.id;


--
-- TOC entry 4864 (class 2604 OID 16501)
-- Name: lkup_data_file_category id; Type: DEFAULT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.lkup_data_file_category ALTER COLUMN id SET DEFAULT nextval('public.lkup_data_file_category_id_seq'::regclass);


--
-- TOC entry 5003 (class 2606 OID 16505)
-- Name: lkup_data_file_category lkup_data_file_category_pkey; Type: CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.lkup_data_file_category
    ADD CONSTRAINT lkup_data_file_category_pkey PRIMARY KEY (id);


--
-- TOC entry 5454 (class 0 OID 0)
-- Dependencies: 234
-- Name: TABLE lkup_data_file_category; Type: ACL; Schema: public; Owner: canopy_admin
--



--
