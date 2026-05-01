-- TOC entry 301 (class 1259 OID 17162)
-- Name: events; Type: TABLE; Schema: public; Owner: canopy_admin
--

CREATE TABLE public.events (
    id integer NOT NULL,
    title character varying(1024) NOT NULL,
    slug character varying(50) NOT NULL,
    description text NOT NULL,
    event_type_id integer NOT NULL,
    registration_url text,
    event_date timestamp with time zone NOT NULL,
    expiration_date timestamp without time zone,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by integer DEFAULT 9999 NOT NULL,
    modified_at timestamp without time zone,
    modified_by integer
);


ALTER TABLE public.events OWNER TO canopy_admin;

--
-- TOC entry 300 (class 1259 OID 17161)
-- Name: events_id_seq; Type: SEQUENCE; Schema: public; Owner: canopy_admin
--

CREATE SEQUENCE public.events_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.events_id_seq OWNER TO canopy_admin;

--
-- TOC entry 5432 (class 0 OID 0)
-- Dependencies: 300
-- Name: events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: canopy_admin
--

ALTER SEQUENCE public.events_id_seq OWNED BY public.events.id;


--
-- TOC entry 4920 (class 2604 OID 17165)
-- Name: events id; Type: DEFAULT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.events ALTER COLUMN id SET DEFAULT nextval('public.events_id_seq'::regclass);


--
-- TOC entry 5071 (class 2606 OID 17171)
-- Name: events events_pkey; Type: CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.events
    ADD CONSTRAINT events_pkey PRIMARY KEY (id);


--
-- TOC entry 5431 (class 0 OID 0)
-- Dependencies: 301
-- Name: TABLE events; Type: ACL; Schema: public; Owner: canopy_admin
--

GRANT ALL ON TABLE public.events TO canopy_user;


--
