--
-- Name: role_capability; Type: TABLE; Schema: public; Owner: canopy_admin
--
-- Join table binding capabilities to roles. A user's effective capabilities
-- are the union over their assigned roles.
--

CREATE TABLE public.role_capability (
    role_id integer NOT NULL,
    capability_id integer NOT NULL
);


ALTER TABLE public.role_capability OWNER TO canopy_admin;

ALTER TABLE ONLY public.role_capability
    ADD CONSTRAINT pk_role_capability PRIMARY KEY (role_id, capability_id);


--
