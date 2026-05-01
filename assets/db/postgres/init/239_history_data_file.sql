-- TOC entry 379 (class 1259 OID 28417)
-- Name: data_file_history; Type: TABLE; Schema: canopy_history; Owner: canopy_admin
--

CREATE TABLE canopy_history.data_file_history (
    id integer NOT NULL,
    column_name character varying(256) NOT NULL,
    old_value text,
    new_value text,
    operation character(1) NOT NULL,
    operated_at timestamp without time zone NOT NULL,
    operated_by integer,
    CONSTRAINT operation_check CHECK (((operation)::text = ANY (ARRAY[('D'::character varying)::text, ('U'::character varying)::text])))
);


ALTER TABLE canopy_history.data_file_history OWNER TO canopy_admin;

--
-- TOC entry 5615 (class 0 OID 0)
-- Dependencies: 379
-- Name: TABLE data_file_history; Type: ACL; Schema: canopy_history; Owner: canopy_admin
--

GRANT SELECT,INSERT ON TABLE canopy_history.data_file_history TO canopy_user;


--
