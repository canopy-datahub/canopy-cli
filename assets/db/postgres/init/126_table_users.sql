-- TOC entry 264 (class 1259 OID 16758)
-- Name: users; Type: TABLE; Schema: public; Owner: canopy_admin
--

CREATE TABLE public.users (
    id integer NOT NULL,
    uuid character varying(36),
    first_name character varying(50) NOT NULL,
    middle_initial character varying(1),
    last_name character varying(50) NOT NULL,
    email_address character varying(255) NOT NULL,
    orcid_id character varying(19),
    job_title character varying(256),
    institution_id integer,
    researcher_level_id integer,
    status_id integer NOT NULL,
    internal_user boolean DEFAULT false NOT NULL,
    accept_terms boolean,
    last_dua_date date,
    last_login_at timestamp without time zone,
    sftp_path character varying(128),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    modified_at timestamp without time zone,
    center_id integer
);


ALTER TABLE public.users OWNER TO canopy_admin;

--
-- TOC entry 263 (class 1259 OID 16757)
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: canopy_admin
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_id_seq OWNER TO canopy_admin;

--
-- TOC entry 5581 (class 0 OID 0)
-- Dependencies: 263
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: canopy_admin
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- TOC entry 4891 (class 2604 OID 16761)
-- Name: users id; Type: DEFAULT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- TOC entry 5033 (class 2606 OID 16767)
-- Name: users user_pkey; Type: CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT user_pkey PRIMARY KEY (id);


--
-- TOC entry 5580 (class 0 OID 0)
-- Dependencies: 264
-- Name: TABLE users; Type: ACL; Schema: public; Owner: canopy_admin
--

GRANT ALL ON TABLE public.users TO canopy_user;


--
