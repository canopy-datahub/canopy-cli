-- TOC entry 307 (class 1259 OID 17242)
-- Name: news_link; Type: TABLE; Schema: public; Owner: canopy_admin
--

CREATE TABLE public.news_link (
    id integer NOT NULL,
    news_id integer NOT NULL,
    link_label character varying(255),
    link_url text,
    display_order integer,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by integer DEFAULT 9999 NOT NULL,
    modified_at timestamp without time zone,
    modified_by integer
);


ALTER TABLE public.news_link OWNER TO canopy_admin;

--
-- TOC entry 306 (class 1259 OID 17241)
-- Name: news_link_id_seq; Type: SEQUENCE; Schema: public; Owner: canopy_admin
--

CREATE SEQUENCE public.news_link_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.news_link_id_seq OWNER TO canopy_admin;

--
-- TOC entry 5515 (class 0 OID 0)
-- Dependencies: 306
-- Name: news_link_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: canopy_admin
--

ALTER SEQUENCE public.news_link_id_seq OWNED BY public.news_link.id;


--
-- TOC entry 4930 (class 2604 OID 17245)
-- Name: news_link id; Type: DEFAULT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.news_link ALTER COLUMN id SET DEFAULT nextval('public.news_link_id_seq'::regclass);


--
-- TOC entry 5077 (class 2606 OID 17251)
-- Name: news_link news_link_pkey; Type: CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.news_link
    ADD CONSTRAINT news_link_pkey PRIMARY KEY (id);


--
-- TOC entry 5514 (class 0 OID 0)
-- Dependencies: 307
-- Name: TABLE news_link; Type: ACL; Schema: public; Owner: canopy_admin
--

GRANT ALL ON TABLE public.news_link TO canopy_user;


--
