--
-- Name: lkup_capability; Type: TABLE; Schema: public; Owner: canopy_admin
--
-- Registry of fine-grained named permissions (e.g. 'submission.create',
-- 'study.delete'). Endpoints check capabilities; roles are bundles of
-- capabilities. See 729_data_role_capability.sql for the bundling.
--

CREATE TABLE public.lkup_capability (
    id integer NOT NULL,
    name character varying(80) NOT NULL,
    description character varying(255)
);


ALTER TABLE public.lkup_capability OWNER TO canopy_admin;

--
-- Name: lkup_capability_id_seq; Type: SEQUENCE; Schema: public; Owner: canopy_admin
--

CREATE SEQUENCE public.lkup_capability_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.lkup_capability_id_seq OWNER TO canopy_admin;

ALTER SEQUENCE public.lkup_capability_id_seq OWNED BY public.lkup_capability.id;

ALTER TABLE ONLY public.lkup_capability ALTER COLUMN id SET DEFAULT nextval('public.lkup_capability_id_seq'::regclass);

ALTER TABLE ONLY public.lkup_capability
    ADD CONSTRAINT pk_lkup_capability PRIMARY KEY (id);

ALTER TABLE ONLY public.lkup_capability
    ADD CONSTRAINT uq_lkup_capability_name UNIQUE (name);


--
