-- TOC entry 421 (class 1259 OID 46759)
-- Name: lkup_core_variable_permissible_value; Type: TABLE; Schema: public; Owner: canopy_admin
--

CREATE TABLE public.lkup_core_variable_permissible_value (
    id integer NOT NULL,
    variable_name character varying(256) NOT NULL,
    value integer NOT NULL,
    label character varying(256) NOT NULL,
    map_to_id integer
);


ALTER TABLE public.lkup_core_variable_permissible_value OWNER TO canopy_admin;

--
-- TOC entry 420 (class 1259 OID 46758)
-- Name: lkup_core_variable_permissible_value_id_seq; Type: SEQUENCE; Schema: public; Owner: canopy_admin
--

CREATE SEQUENCE public.lkup_core_variable_permissible_value_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.lkup_core_variable_permissible_value_id_seq OWNER TO canopy_admin;

--
-- TOC entry 5587 (class 0 OID 0)
-- Dependencies: 420
-- Name: lkup_core_variable_permissible_value_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: canopy_admin
--

ALTER SEQUENCE public.lkup_core_variable_permissible_value_id_seq OWNED BY public.lkup_core_variable_permissible_value.id;


--
-- TOC entry 4968 (class 2604 OID 46762)
-- Name: lkup_core_variable_permissible_value id; Type: DEFAULT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.lkup_core_variable_permissible_value ALTER COLUMN id SET DEFAULT nextval('public.lkup_core_variable_permissible_value_id_seq'::regclass);


--
-- TOC entry 5125 (class 2606 OID 46764)
-- Name: lkup_core_variable_permissible_value lkup_core_variable_permissible_value_pkey; Type: CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.lkup_core_variable_permissible_value
    ADD CONSTRAINT lkup_core_variable_permissible_value_pkey PRIMARY KEY (id);


--
-- TOC entry 5586 (class 0 OID 0)
-- Dependencies: 421
-- Name: TABLE lkup_core_variable_permissible_value; Type: ACL; Schema: public; Owner: canopy_admin
--



--
