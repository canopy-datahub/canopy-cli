-- TOC entry 383 (class 1259 OID 29088)
-- Name: study_property_value_history; Type: TABLE; Schema: canopy_history; Owner: canopy_admin
--

CREATE TABLE canopy_history.study_property_value_history (
    id integer NOT NULL,
    column_name character varying(256) NOT NULL,
    old_value text,
    new_value text,
    operation character(1) NOT NULL,
    operated_at timestamp without time zone NOT NULL,
    operated_by integer,
    CONSTRAINT operation_check CHECK (((operation)::text = ANY (ARRAY[('D'::character varying)::text, ('U'::character varying)::text])))
);


ALTER TABLE canopy_history.study_property_value_history OWNER TO canopy_admin;

--
-- TOC entry 5622 (class 0 OID 0)
-- Dependencies: 383
-- Name: TABLE study_property_value_history; Type: ACL; Schema: canopy_history; Owner: canopy_admin
--



--
