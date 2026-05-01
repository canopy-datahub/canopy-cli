-- TOC entry 266 (class 1259 OID 16784)
-- Name: user_role; Type: TABLE; Schema: public; Owner: canopy_admin
--

CREATE TABLE public.user_role (
    id integer NOT NULL,
    user_id integer NOT NULL,
    role_id integer NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by integer,
    modified_at timestamp without time zone,
    modified_by integer
);


ALTER TABLE public.user_role OWNER TO canopy_admin;

--
-- TOC entry 265 (class 1259 OID 16783)
-- Name: user_role_id_seq; Type: SEQUENCE; Schema: public; Owner: canopy_admin
--

CREATE SEQUENCE public.user_role_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.user_role_id_seq OWNER TO canopy_admin;

--
-- TOC entry 5575 (class 0 OID 0)
-- Dependencies: 265
-- Name: user_role_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: canopy_admin
--

ALTER SEQUENCE public.user_role_id_seq OWNED BY public.user_role.id;


--
-- TOC entry 4894 (class 2604 OID 16787)
-- Name: user_role id; Type: DEFAULT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.user_role ALTER COLUMN id SET DEFAULT nextval('public.user_role_id_seq'::regclass);


--
-- TOC entry 5035 (class 2606 OID 16790)
-- Name: user_role user_role_pkey; Type: CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.user_role
    ADD CONSTRAINT user_role_pkey PRIMARY KEY (id);


--
-- TOC entry 5574 (class 0 OID 0)
-- Dependencies: 266
-- Name: TABLE user_role; Type: ACL; Schema: public; Owner: canopy_admin
--

GRANT ALL ON TABLE public.user_role TO canopy_user;


--
