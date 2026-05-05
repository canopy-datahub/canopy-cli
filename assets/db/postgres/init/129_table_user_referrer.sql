-- TOC entry 417 (class 1259 OID 46689)
-- Name: user_referrer; Type: TABLE; Schema: public; Owner: canopy_admin
--

CREATE TABLE public.user_referrer (
    id integer NOT NULL,
    user_id integer NOT NULL,
    referrer_id integer,
    referrer_specify character varying(1024),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by integer,
    modified_at timestamp without time zone,
    modified_by integer
);


ALTER TABLE public.user_referrer OWNER TO canopy_admin;

--
-- TOC entry 416 (class 1259 OID 46688)
-- Name: user_referrer_id_seq; Type: SEQUENCE; Schema: public; Owner: canopy_admin
--

CREATE SEQUENCE public.user_referrer_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.user_referrer_id_seq OWNER TO canopy_admin;

--
-- TOC entry 5572 (class 0 OID 0)
-- Dependencies: 416
-- Name: user_referrer_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: canopy_admin
--

ALTER SEQUENCE public.user_referrer_id_seq OWNED BY public.user_referrer.id;


--
-- TOC entry 4966 (class 2604 OID 46692)
-- Name: user_referrer id; Type: DEFAULT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.user_referrer ALTER COLUMN id SET DEFAULT nextval('public.user_referrer_id_seq'::regclass);


--
-- TOC entry 5121 (class 2606 OID 46697)
-- Name: user_referrer pk_user_referrer_id; Type: CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.user_referrer
    ADD CONSTRAINT pk_user_referrer_id PRIMARY KEY (id);


--
-- TOC entry 5571 (class 0 OID 0)
-- Dependencies: 417
-- Name: TABLE user_referrer; Type: ACL; Schema: public; Owner: canopy_admin
--



--
