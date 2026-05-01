-- TOC entry 1506 (class 1247 OID 41201)
-- Name: variableinfotype; Type: TYPE; Schema: public; Owner: canopy_admin
--

CREATE TYPE public.variableinfotype AS (
	id character varying,
	label character varying,
	description text,
	section character varying,
	cardinality character varying,
	datatype character varying,
	unit character varying,
	enumeration jsonb
);


ALTER TYPE public.variableinfotype OWNER TO canopy_admin;



-- Install hstore extension
CREATE EXTENSION IF NOT EXISTS hstore;

--
