-- TOC entry 305 (class 1259 OID 17226)
-- Name: news; Type: TABLE; Schema: public; Owner: canopy_admin
--

CREATE TABLE public.news (
    id integer NOT NULL,
    slug character varying(50) NOT NULL,
    title character varying(1024) NOT NULL,
    description text NOT NULL,
    type_id integer NOT NULL,
    start_date date NOT NULL,
    expiration_date date,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by integer DEFAULT 9999 NOT NULL,
    modified_at timestamp without time zone,
    modified_by integer,
    archived boolean DEFAULT false NOT NULL
);


ALTER TABLE public.news OWNER TO canopy_admin;

--
-- TOC entry 304 (class 1259 OID 17225)
-- Name: news_id_seq; Type: SEQUENCE; Schema: public; Owner: canopy_admin
--

CREATE SEQUENCE public.news_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.news_id_seq OWNER TO canopy_admin;

--
-- TOC entry 5512 (class 0 OID 0)
-- Dependencies: 304
-- Name: news_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: canopy_admin
--

ALTER SEQUENCE public.news_id_seq OWNED BY public.news.id;


--
-- TOC entry 4926 (class 2604 OID 17229)
-- Name: news id; Type: DEFAULT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.news ALTER COLUMN id SET DEFAULT nextval('public.news_id_seq'::regclass);


--
-- TOC entry 5075 (class 2606 OID 17235)
-- Name: news news_pkey; Type: CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.news
    ADD CONSTRAINT news_pkey PRIMARY KEY (id);


--
-- TOC entry 5511 (class 0 OID 0)
-- Dependencies: 305
-- Name: TABLE news; Type: ACL; Schema: public; Owner: canopy_admin
--

GRANT ALL ON TABLE public.news TO canopy_user;


--
