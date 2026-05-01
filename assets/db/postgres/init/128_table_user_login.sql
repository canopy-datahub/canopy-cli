-- TOC entry 275 (class 1259 OID 16862)
-- Name: user_login; Type: TABLE; Schema: public; Owner: canopy_admin
--

CREATE TABLE public.user_login (
    id integer NOT NULL,
    user_id integer NOT NULL,
    login_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.user_login OWNER TO canopy_admin;

--
-- TOC entry 274 (class 1259 OID 16861)
-- Name: user_login_id_seq; Type: SEQUENCE; Schema: public; Owner: canopy_admin
--

CREATE SEQUENCE public.user_login_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.user_login_id_seq OWNER TO canopy_admin;

--
-- TOC entry 5566 (class 0 OID 0)
-- Dependencies: 274
-- Name: user_login_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: canopy_admin
--

ALTER SEQUENCE public.user_login_id_seq OWNED BY public.user_login.id;


--
-- TOC entry 4900 (class 2604 OID 16865)
-- Name: user_login id; Type: DEFAULT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.user_login ALTER COLUMN id SET DEFAULT nextval('public.user_login_id_seq'::regclass);


--
-- TOC entry 5045 (class 2606 OID 16868)
-- Name: user_login pk_user_login_id; Type: CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.user_login
    ADD CONSTRAINT pk_user_login_id PRIMARY KEY (id);


--
-- TOC entry 5565 (class 0 OID 0)
-- Dependencies: 275
-- Name: TABLE user_login; Type: ACL; Schema: public; Owner: canopy_admin
--

GRANT ALL ON TABLE public.user_login TO canopy_user;


--
