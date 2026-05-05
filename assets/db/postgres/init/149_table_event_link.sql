-- TOC entry 303 (class 1259 OID 17178)
-- Name: event_link; Type: TABLE; Schema: public; Owner: canopy_admin
--

CREATE TABLE public.event_link (
    id integer NOT NULL,
    event_id integer NOT NULL,
    link_label character varying(255) NOT NULL,
    link_url text NOT NULL,
    display_order integer NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by integer DEFAULT 9999 NOT NULL,
    modified_at timestamp without time zone,
    modified_by integer
);


ALTER TABLE public.event_link OWNER TO canopy_admin;

--
-- TOC entry 302 (class 1259 OID 17177)
-- Name: event_link_id_seq; Type: SEQUENCE; Schema: public; Owner: canopy_admin
--

CREATE SEQUENCE public.event_link_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.event_link_id_seq OWNER TO canopy_admin;

--
-- TOC entry 5429 (class 0 OID 0)
-- Dependencies: 302
-- Name: event_link_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: canopy_admin
--

ALTER SEQUENCE public.event_link_id_seq OWNED BY public.event_link.id;


--
-- TOC entry 4923 (class 2604 OID 17181)
-- Name: event_link id; Type: DEFAULT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.event_link ALTER COLUMN id SET DEFAULT nextval('public.event_link_id_seq'::regclass);


--
-- TOC entry 5073 (class 2606 OID 17187)
-- Name: event_link event_link_pkey; Type: CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.event_link
    ADD CONSTRAINT event_link_pkey PRIMARY KEY (id);


--
-- TOC entry 5428 (class 0 OID 0)
-- Dependencies: 303
-- Name: TABLE event_link; Type: ACL; Schema: public; Owner: canopy_admin
--



--
