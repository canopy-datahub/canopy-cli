-- TOC entry 319 (class 1259 OID 17310)
-- Name: support_request; Type: TABLE; Schema: public; Owner: canopy_admin
--

CREATE TABLE public.support_request (
    id integer NOT NULL,
    requestor_user_id integer,
    full_name character varying(200),
    email character varying(255),
    request_title character varying(255),
    request_detail text NOT NULL,
    type_id integer NOT NULL,
    piority smallint,
    status_id integer NOT NULL,
    assignee_user_id integer,
    assignee_email character varying(255),
    assigned_at timestamp with time zone,
    resolved_at timestamp with time zone,
    resolution_type_id integer,
    tech_note text,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by integer,
    update_at timestamp with time zone,
    updated_by integer,
    institution character varying(1024)
);


ALTER TABLE public.support_request OWNER TO canopy_admin;

--
-- TOC entry 318 (class 1259 OID 17309)
-- Name: support_request_id_seq; Type: SEQUENCE; Schema: public; Owner: canopy_admin
--

CREATE SEQUENCE public.support_request_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.support_request_id_seq OWNER TO canopy_admin;

--
-- TOC entry 5551 (class 0 OID 0)
-- Dependencies: 318
-- Name: support_request_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: canopy_admin
--

ALTER SEQUENCE public.support_request_id_seq OWNED BY public.support_request.id;


--
-- TOC entry 4938 (class 2604 OID 17313)
-- Name: support_request id; Type: DEFAULT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.support_request ALTER COLUMN id SET DEFAULT nextval('public.support_request_id_seq'::regclass);



--
-- TOC entry 5089 (class 2606 OID 17318)
-- Name: support_request pk_support_request; Type: CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.support_request
    ADD CONSTRAINT pk_support_request PRIMARY KEY (id);


--
-- TOC entry 5550 (class 0 OID 0)
-- Dependencies: 319
-- Name: TABLE support_request; Type: ACL; Schema: public; Owner: canopy_admin
--



--
