-- TOC entry 384 (class 1259 OID 29095)
-- Name: users_history; Type: TABLE; Schema: canopy_history; Owner: canopy_admin
--

CREATE TABLE canopy_history.users_history (
    id integer NOT NULL,
    column_name character varying(256) NOT NULL,
    old_value text,
    new_value text,
    operation character(1) NOT NULL,
    operated_at timestamp without time zone NOT NULL,
    operated_by integer,
    CONSTRAINT operation_check CHECK (((operation)::text = ANY (ARRAY[('D'::character varying)::text, ('U'::character varying)::text])))
);


ALTER TABLE canopy_history.users_history OWNER TO canopy_admin;

--
-- TOC entry 5627 (class 0 OID 0)
-- Dependencies: 384
-- Name: TABLE users_history; Type: ACL; Schema: canopy_history; Owner: canopy_admin
--



--
