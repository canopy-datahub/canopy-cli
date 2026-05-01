-- TOC entry 333 (class 1259 OID 22387)
-- Name: view_study; Type: VIEW; Schema: public; Owner: canopy_user
--

CREATE VIEW public.view_study AS
 SELECT p.study_id,
    p.title,
    p.description,
    p.center,
    p.studystartdate,
    p.studyenddate,
    p.is_multi_center,
    p.multi_center_sites,
    p.pi_name,
    p.estimated_participants,
    p.source,
    p.subject,
    p.types,
    p.institutes_supporting_study,
    p.data_general_types,
    p.acknowledgement_statement,
    p.data_species,
    p.disease_specific_group,
    p.disease_specific_related_conditions,
    p.general_research_group,
    p.grant_number,
    p.health_biomed_group,
    p."study_DOI",
    p.study_citation,
    p.has_data_files,
    p.actual_study_size,
    p.release_date,
    p.updated_at,
    p.study_version,
    p.study_population_focus,
    p.topics,
    p."study_website_URL",
    p."CT_URL",
    p."publication_URL",
    p."FOA_number",
    p."FOA_URL",
    p.estimated_participant_range,
    l.name AS status,
    s.created_at
   FROM ((public.study s
     JOIN public.lkup_status l ON ((s.status_id = l.id)))
     JOIN ( SELECT crosstab.study_id,
            crosstab.title,
            crosstab.description,
            crosstab.center,
            crosstab.studystartdate,
            crosstab.studyenddate,
            crosstab.is_multi_center,
            crosstab.multi_center_sites,
            crosstab.pi_name,
            crosstab.estimated_participants,
            crosstab.source,
            crosstab.subject,
            crosstab.types,
            crosstab.institutes_supporting_study,
            crosstab.data_general_types,
            crosstab.acknowledgement_statement,
            crosstab.data_species,
            crosstab.disease_specific_group,
            crosstab.disease_specific_related_conditions,
            crosstab.general_research_group,
            crosstab.grant_number,
            crosstab.health_biomed_group,
            crosstab."study_DOI",
            crosstab.study_citation,
            crosstab.has_data_files,
            crosstab.actual_study_size,
            crosstab.release_date,
            crosstab.updated_at,
            crosstab.study_version,
            crosstab.study_population_focus,
            crosstab.topics,
            crosstab."study_website_URL",
            crosstab."CT_URL",
            crosstab."publication_URL",
            crosstab."FOA_number",
            crosstab."FOA_URL",
            crosstab.estimated_participant_range
           FROM public.crosstab('select study_id, p.name, case p.cardinality when true then array_agg(v.property_value)::text else string_agg(v.property_value, '','') end as value
        from entity_property p left outer join study_property_value v  on v.entity_property_id = p.id and p.entity_type_id=1 and p.is_hidden = false
		group by study_id, p.id, p.name
        order by study_id, p.id'::text, '
	    values (''title''),
		(''description''),
		(''center''),
		(''studystartdate''),
		(''studyenddate''),
		(''is_multi_center''),
		(''multi_center_sites''),
		(''pi_name''),
		(''estimated_participants''),
		(''source''),
		(''subject''),
		(''types''),
		(''institutes_supporting_study''),
		(''data_general_types''),
		(''acknowledgement_statement''),
		(''data_species''),
		(''disease_specific_group''),
		(''disease_specific_related_conditions''),
		(''general_research_group''),
		(''grant_number''),
		(''health_biomed_group''),
		(''study_DOI''),
		(''study_citation''),
		(''has_data_files''),
		(''actual_study_size''),
		(''release_date''),
		(''updated_at''),
		(''study_version''),
		(''study_population_focus''),
		(''topics''),
		(''study_website_URL''),
		(''CT_URL''),
		(''publication_URL''),
		(''FOA_number''),
		(''FOA_URL''),
		(''estimated_participant_range'')
	'::text) crosstab(study_id integer, title text, description text, center text, studystartdate text, studyenddate text, is_multi_center text, multi_center_sites text, pi_name text, estimated_participants text, source text, subject text, types text, institutes_supporting_study text, data_general_types text, acknowledgement_statement text, data_species text, disease_specific_group text, disease_specific_related_conditions text, general_research_group text, grant_number text, health_biomed_group text, "study_DOI" text, study_citation text, has_data_files text, actual_study_size text, release_date text, updated_at text, study_version text, study_population_focus text, topics text, "study_website_URL" text, "CT_URL" text, "publication_URL" text, "FOA_number" text, "FOA_URL" text, estimated_participant_range text)) p ON ((s.id = p.study_id)));


ALTER VIEW public.view_study OWNER TO canopy_user;

--
-- TOC entry 385 (class 1259 OID 29109)
-- Name: view_current_data_file; Type: VIEW; Schema: public; Owner: canopy_admin
--

CREATE VIEW public.view_current_data_file AS
 SELECT (row_number() OVER ())::integer AS id,
    t.study_id,
    t.title AS study_name,
    s.id AS submission_id,
    k.name AS submission_status,
    d.id AS data_file_id,
    d.source_file_name,
    d.file_category_id,
    l.name AS file_type,
    l.category_group AS file_category_group,
    d.file_size,
    d.version_no,
    d.dictionary_file_id,
    d.metadata_file_id
   FROM (((((public.data_file d
     JOIN public.data_submission s ON ((d.submission_id = s.id)))
     JOIN public.view_study t ON ((s.study_id = t.study_id)))
     LEFT JOIN public.s3_file s3 ON ((d.s3_file_id = s3.id)))
     LEFT JOIN public.lkup_data_file_category l ON ((d.file_category_id = l.id)))
     LEFT JOIN public.lkup_status k ON ((s.status_id = k.id)))
  WHERE ((l.category_group = 'data'::text) AND d.is_current_version);


ALTER VIEW public.view_current_data_file OWNER TO canopy_admin;

--
-- TOC entry 334 (class 1259 OID 22404)
-- Name: view_current_hub_content; Type: VIEW; Schema: public; Owner: canopy_admin
--

CREATE VIEW public.view_current_hub_content AS
 SELECT id,
    center,
    study_id,
    study_title,
    study_status,
    study_create_date,
    total_file_count,
    data_file_count,
    total_file_size,
    orig_data_file_count,
    standardized_data_file_count,
    metadata_file_count,
    dictionary_file_count,
    readme_file_count,
    other_file_count,
    (data_file_count > 0) AS study_has_data_file
   FROM ( SELECT s.study_id AS id,
            s.center,
            s.study_id AS study_id,
            s.title AS study_title,
            s.status AS study_status,
            s.created_at AS study_create_date,
            count(d.id) FILTER (WHERE (l.name IS NOT NULL)) AS total_file_count,
            count(d.id) FILTER (WHERE (l.category_group = 'data'::text)) AS data_file_count,
            (sum(d.file_size) FILTER (WHERE (l.name IS NOT NULL)) / (1048576)::numeric) AS total_file_size,
            count(d.id) FILTER (WHERE ((l.name)::text = ANY ((ARRAY['Tabular Data - Non-harmonized'::character varying, 'Image Data'::character varying, 'Sequence Data'::character varying])::text[]))) AS orig_data_file_count,
            count(d.id) FILTER (WHERE ((l.name)::text = 'Tabular Data - Harmonized'::text)) AS standardized_data_file_count,
            count(d.id) FILTER (WHERE (l.category_group = 'metadata'::text)) AS metadata_file_count,
            count(d.id) FILTER (WHERE (l.category_group = 'dictionary'::text)) AS dictionary_file_count,
            count(d.id) FILTER (WHERE ((l.name)::text = 'Read Me'::text)) AS readme_file_count,
            count(d.id) FILTER (WHERE (l.category_group = 'other'::text)) AS other_file_count
           FROM (((public.view_study s
             LEFT JOIN public.data_submission m ON ((m.study_id = s.study_id)))
             LEFT JOIN public.data_file d ON (((d.submission_id = m.id) AND d.is_current_version)))
             LEFT JOIN public.lkup_data_file_category l ON ((d.file_category_id = l.id)))
          WHERE (s.status = 'Approved'::text)
          GROUP BY s.study_id, s.center, s.title, s.status, s.created_at, s.has_data_files
          ORDER BY s.study_id) a;


ALTER VIEW public.view_current_hub_content OWNER TO canopy_admin;

--
-- TOC entry 336 (class 1259 OID 22419)
-- Name: view_current_hub_content_data; Type: VIEW; Schema: public; Owner: canopy_admin
--

CREATE VIEW public.view_current_hub_content_data AS
 SELECT (row_number() OVER ())::integer AS id,
    CURRENT_DATE AS report_date,
    t.center,
    t.study_id,
    t.title AS study_title,
    t.status AS study_status,
    (t.created_at)::date AS study_create_date,
    s.id AS submission_id,
    (s.created_at)::date AS submission_created_date,
    p.name AS submission_status,
    s3.file_name,
    k.name AS file_status,
    (d.created_at)::date AS file_create_date,
    d.file_size,
    NULL::text AS tier_1_cde,
    NULL::text AS non_tier_1_headers,
    l.name AS file_category,
    d.is_current_version,
    d.source_file_name,
    d.version_no
   FROM ((((((public.view_study t
     LEFT JOIN public.data_submission s ON ((s.study_id = t.study_id)))
     LEFT JOIN public.lkup_status p ON ((s.status_id = p.id)))
     LEFT JOIN public.data_file d ON ((d.submission_id = s.id)))
     LEFT JOIN public.s3_file s3 ON ((d.s3_file_id = s3.id)))
     LEFT JOIN public.lkup_data_file_category l ON ((d.file_category_id = l.id)))
     LEFT JOIN public.lkup_status k ON ((d.status_id = k.id)));


ALTER VIEW public.view_current_hub_content_data OWNER TO canopy_admin;


CREATE OR REPLACE VIEW public.view_variables AS
SELECT DISTINCT
    -- Study information
    y.id AS study_id,
    s.title AS study_name,
    s.center AS center,

    -- File information
    f.id AS file_id,
    s3.file_name AS file_name,

    -- Variable information
    v.id AS variable_id,
    v.name AS variable,
    v.label AS variable_label,
    v.section AS variable_section,
    v.datatype AS variable_datatype,

    -- Category information
    c.id AS category_id,
    c.name AS variable_category,

    -- Tier flag
    ((v.id IS NOT NULL) AND (v.category_id = 1)) AS is_tier1_variable

FROM public.variables v
         LEFT JOIN public.lkup_variable_category c ON (v.category_id = c.id)
         LEFT JOIN public.data_file f ON (
    f.id = v.file_id
        AND f.is_current_version
        AND (v.center_id IS NULL OR f.submission_id IN (
        SELECT m.id
        FROM public.data_submission m
                 JOIN public.study st ON m.study_id = st.id
        WHERE st.center_id = v.center_id
    ))
    )
         LEFT JOIN public.s3_file s3 ON (f.s3_file_id = s3.id)
         LEFT JOIN public.data_submission m ON (f.submission_id = m.id)
         LEFT JOIN public.study y ON (m.study_id = y.id)
         LEFT JOIN public.view_study s ON (y.id = s.study_id);

ALTER VIEW public.view_variables OWNER TO canopy_admin;

--
-- TOC entry 410 (class 1259 OID 42312)
-- Name: view_study_all; Type: VIEW; Schema: public; Owner: canopy_user
--

CREATE VIEW public.view_study_all AS
 SELECT p.study_id,
    p.title,
    p.description,
    p."RAPIDS_link",
    p.center,
    p.studystartdate,
    p.studyenddate,
    p.is_multi_center,
    p.multi_center_sites,
    p.pi_name,
    p.pi_email,
    p.pi_assistant_name,
    p.pi_assistant_email,
    p.pi_institution,
    p.pi_sign_date,
    p.po_name,
    p.officer_sign_date,
    p.estimated_participants,
    p.public_access_data,
    p.source,
    p.subject,
    p.types,
    p.unrestricted_access,
    p.institutes_supporting_study,
    p.needs_institutional_certifications,
    p.data_general_types,
    p.data_genomic,
    p.data_genotype,
    p.data_sample_types,
    p.data_sequencing,
    p.user_agreement_accepted,
    p.data_policy_accepted,
    p.reject_comments,
    p.study_approved_date,
    p.acknowledgement_statement,
    p.aggregate_appropriate_for_general_use,
    p.awardee,
    p.consent_to_add_aggregate,
    p.consent_to_add_individual,
    p.controlled_access,
    p.controlled_access_data,
    p.data_access_points,
    p.data_analyses,
    p.data_array_data,
    p.data_from_repository_name,
    p.data_phenotype,
    p.data_sample_collection,
    p.data_sharing_info,
    p.data_species,
    p.data_storage_size,
    p.data_submission_date,
    p.data_submission_method,
    p.data_submission_timeline_details,
    p.data_target_delivery_date,
    p.data_target_release_date,
    p.disease_specific_group,
    p.disease_specific_related_conditions,
    p.eua,
    p.expected_data_format,
    p.general_research_group,
    p.geno_seq_platform_info,
    p.geno_seq_platform_url,
    p.geno_seq_platform_probes,
    p.geno_seq_platform_vendor,
    p.geno_seq_platform_description,
    p.geno_seq_platform_name_version,
    p.grant_number,
    p.has_era_account,
    p.has_ic,
    p.health_biomed_group,
    p.individual_appropriate_for_general_use,
    p.other_group_description,
    p.project_number,
    p."study_DOI",
    p.study_citation,
    p.has_data_files,
    p.actual_study_size,
    p.release_date,
    p.updated_at,
    p.study_version,
    p.study_population_focus,
    p.topics,
    p.types_other_specify,
    p.source_other_specify,
    p.data_general_types_other_specify,
    p.data_genomic_other_specify,
    p.data_phenotype_other_specify,
    p.data_sample_types_other_specify,
    p.data_genotype_other_specify,
    p.data_sequencing_other_specify,
    p.data_analyses_other_specify,
    p.data_array_data_other_specify,
    p.data_access_points_other,
    p.topics_other_specify,
    p."study_website_URL",
    p."CT_URL",
    p."publication_URL",
    p.access_type,
    p.data_access_type,
    p."FOA_number",
    p."FOA_URL",
    p.estimated_participant_range,
    p.data_use_limitations,
    l.name AS status,
    s.created_at
   FROM ((public.study s
     JOIN public.lkup_status l ON ((s.status_id = l.id)))
     JOIN ( SELECT crosstab.study_id,
            crosstab.title,
            crosstab.description,
            crosstab."RAPIDS_link",
            crosstab.center,
            crosstab.studystartdate,
            crosstab.studyenddate,
            crosstab.is_multi_center,
            crosstab.multi_center_sites,
            crosstab.pi_name,
            crosstab.pi_email,
            crosstab.pi_assistant_name,
            crosstab.pi_assistant_email,
            crosstab.pi_institution,
            crosstab.pi_sign_date,
            crosstab.po_name,
            crosstab.officer_sign_date,
            crosstab.estimated_participants,
            crosstab.public_access_data,
            crosstab.source,
            crosstab.subject,
            crosstab.types,
            crosstab.unrestricted_access,
            crosstab.institutes_supporting_study,
            crosstab.needs_institutional_certifications,
            crosstab.data_general_types,
            crosstab.data_genomic,
            crosstab.data_genotype,
            crosstab.data_sample_types,
            crosstab.data_sequencing,
            crosstab.user_agreement_accepted,
            crosstab.data_policy_accepted,
            crosstab.reject_comments,
            crosstab.study_approved_date,
            crosstab.acknowledgement_statement,
            crosstab.aggregate_appropriate_for_general_use,
            crosstab.awardee,
            crosstab.consent_to_add_aggregate,
            crosstab.consent_to_add_individual,
            crosstab.controlled_access,
            crosstab.controlled_access_data,
            crosstab.data_access_points,
            crosstab.data_analyses,
            crosstab.data_array_data,
            crosstab.data_from_repository_name,
            crosstab.data_phenotype,
            crosstab.data_sample_collection,
            crosstab.data_sharing_info,
            crosstab.data_species,
            crosstab.data_storage_size,
            crosstab.data_submission_date,
            crosstab.data_submission_method,
            crosstab.data_submission_timeline_details,
            crosstab.data_target_delivery_date,
            crosstab.data_target_release_date,
            crosstab.disease_specific_group,
            crosstab.disease_specific_related_conditions,
            crosstab.eua,
            crosstab.expected_data_format,
            crosstab.general_research_group,
            crosstab.geno_seq_platform_info,
            crosstab.geno_seq_platform_url,
            crosstab.geno_seq_platform_probes,
            crosstab.geno_seq_platform_vendor,
            crosstab.geno_seq_platform_description,
            crosstab.geno_seq_platform_name_version,
            crosstab.grant_number,
            crosstab.has_era_account,
            crosstab.has_ic,
            crosstab.health_biomed_group,
            crosstab.individual_appropriate_for_general_use,
            crosstab.other_group_description,
            crosstab.project_number,
            crosstab."study_DOI",
            crosstab.study_citation,
            crosstab.has_data_files,
            crosstab.actual_study_size,
            crosstab.release_date,
            crosstab.updated_at,
            crosstab.study_version,
            crosstab.study_population_focus,
            crosstab.topics,
            crosstab.types_other_specify,
            crosstab.source_other_specify,
            crosstab.data_general_types_other_specify,
            crosstab.data_genomic_other_specify,
            crosstab.data_phenotype_other_specify,
            crosstab.data_sample_types_other_specify,
            crosstab.data_genotype_other_specify,
            crosstab.data_sequencing_other_specify,
            crosstab.data_analyses_other_specify,
            crosstab.data_array_data_other_specify,
            crosstab.data_access_points_other,
            crosstab.topics_other_specify,
            crosstab."study_website_URL",
            crosstab."CT_URL",
            crosstab."publication_URL",
            crosstab.access_type,
            crosstab.data_access_type,
            crosstab."FOA_number",
            crosstab."FOA_URL",
            crosstab.estimated_participant_range,
            crosstab.data_use_limitations
           FROM public.crosstab('select study_id, p.name, case p.cardinality when true then array_agg(v.property_value)::text else string_agg(v.property_value, '','') end as value
        from entity_property p left outer join study_property_value v  on v.entity_property_id = p.id and p.entity_type_id=1
		group by study_id, p.id, p.name
        order by study_id, p.id'::text, '
	    values (''title''),
		(''description''),
		(''RAPIDS_link''),
		(''center''),
		(''studystartdate''),
		(''studyenddate''),
		(''is_multi_center''),
		(''multi_center_sites''),
		(''pi_name''),
		(''pi_email''),
		(''pi_assistant_name''),
		(''pi_assistant_email''),
		(''pi_institution''),
		(''pi_sign_date''),
		(''po_name''),
		(''officer_sign_date''),
		(''estimated_participants''),
		(''public_access_data''),
		(''source''),
		(''subject''),
		(''types''),
		(''unrestricted_access''),
		(''institutes_supporting_study''),
		(''needs_institutional_certifications''),
		(''data_general_types''),
		(''data_genomic''),
		(''data_genotype''),
		(''data_sample_types''),
		(''data_sequencing''),
		(''user_agreement_accepted''),
		(''data_policy_accepted''),
		(''reject_comments''),
		(''study_approved_date''),
		(''acknowledgement_statement''),
		(''aggregate_appropriate_for_general_use''),
		(''awardee''),
		(''consent_to_add_aggregate''),
		(''consent_to_add_individual''),
		(''controlled_access''),
		(''controlled_access_data''),
		(''data_access_points''),
		(''data_analyses''),
		(''data_array_data''),
		(''data_from_repository_name''),
		(''data_phenotype''),
		(''data_sample_collection''),
		(''data_sharing_info''),
		(''data_species''),
		(''data_storage_size''),
		(''data_submission_date''),
		(''data_submission_method''),
		(''data_submission_timeline_details''),
		(''data_target_delivery_date''),
		(''data_target_release_date''),
		(''disease_specific_group''),
		(''disease_specific_related_conditions''),
		(''eua''),
		(''expected_data_format''),
		(''general_research_group''),
		(''geno_seq_platform_info''),
		(''geno_seq_platform_url''),
		(''geno_seq_platform_probes''),
		(''geno_seq_platform_vendor''),
		(''geno_seq_platform_description''),
		(''geno_seq_platform_name_version''),
		(''grant_number''),
		(''has_era_account''),
		(''has_ic''),
		(''health_biomed_group''),
		(''individual_appropriate_for_general_use''),
		(''other_group_description''),
		(''project_number''),
		(''study_DOI''),
		(''study_citation''),
		(''has_data_files''),
		(''actual_study_size''),
		(''release_date''),
		(''updated_at''),
		(''study_version''),
		(''study_population_focus''),
		(''topics''),
		(''types_other_specify''),
		(''source_other_specify''),
		(''data_general_types_other_specify''),
		(''data_genomic_other_specify''),
		(''data_phenotype_other_specify''),
		(''data_sample_types_other_specify''),
		(''data_genotype_other_specify''),
		(''data_sequencing_other_specify''),
		(''data_anlyses_other_specify''),
		(''data_array_data_other_specify''),
		(''data_access_points_other''),
		(''topics_other_specify''),
		(''study_website_URL''),
		(''CT_URL''),
		(''publication_URL''),
		(''access_type''),
		(''data_access_type''),
		(''FOA_number''),
		(''FOA_URL''),
		(''estimated_participant_range''),
		(''data_use_limitations'')
	'::text) crosstab(study_id integer, title text, description text, "RAPIDS_link" text, center text, studystartdate text, studyenddate text, is_multi_center text, multi_center_sites text, pi_name text, pi_email text, pi_assistant_name text, pi_assistant_email text, pi_institution text, pi_sign_date text, po_name text, officer_sign_date text, estimated_participants text, public_access_data text, source text, subject text, types text, unrestricted_access text, institutes_supporting_study text, needs_institutional_certifications text, data_general_types text, data_genomic text, data_genotype text, data_sample_types text, data_sequencing text, user_agreement_accepted text, data_policy_accepted text, reject_comments text, study_approved_date text, acknowledgement_statement text, aggregate_appropriate_for_general_use text, awardee text, consent_to_add_aggregate text, consent_to_add_individual text, controlled_access text, controlled_access_data text, data_access_points text, data_analyses text, data_array_data text, data_from_repository_name text, data_phenotype text, data_sample_collection text, data_sharing_info text, data_species text, data_storage_size text, data_submission_date text, data_submission_method text, data_submission_timeline_details text, data_target_delivery_date text, data_target_release_date text, disease_specific_group text, disease_specific_related_conditions text, eua text, expected_data_format text, general_research_group text, geno_seq_platform_info text, geno_seq_platform_url text, geno_seq_platform_probes text, geno_seq_platform_vendor text, geno_seq_platform_description text, geno_seq_platform_name_version text, grant_number text, has_era_account text, has_ic text, health_biomed_group text, individual_appropriate_for_general_use text, other_group_description text, project_number text, "study_DOI" text, study_citation text, has_data_files text, actual_study_size text, release_date text, updated_at text, study_version text, study_population_focus text, topics text, types_other_specify text, source_other_specify text, data_general_types_other_specify text, data_genomic_other_specify text, data_phenotype_other_specify text, data_sample_types_other_specify text, data_genotype_other_specify text, data_sequencing_other_specify text, data_analyses_other_specify text, data_array_data_other_specify text, data_access_points_other text, topics_other_specify text, "study_website_URL" text, "CT_URL" text, "publication_URL" text, access_type text, data_access_type text, "FOA_number" text, "FOA_URL" text, estimated_participant_range text, data_use_limitations text)) p ON ((s.id = p.study_id)));


ALTER VIEW public.view_study_all OWNER TO canopy_user;


CREATE VIEW public.view_study_for_es AS
SELECT s.study_id,
       s.title,
       s.description,
       s.status,
       s.center,
       s.studystartdate,
       s.studyenddate,
       s.is_multi_center,
       s.multi_center_sites,
       s.pi_name,
       s.estimated_participants,
       s.estimated_participant_range,
       array_to_string((s.study_population_focus)::text[], '; '::text) AS study_population_focus,
       (s.study_population_focus)::text[] AS study_population_focus_array,
    array_to_string((s.topics)::text[], '; '::text) AS topics,
       (s.topics)::text[] AS topics_array,
    array_to_string((s.source)::text[], '; '::text) AS source,
       (s.source)::text[] AS source_array,
    array_to_string((s.subject)::text[], '; '::text) AS subject,
       (s.subject)::text[] AS subject_array,
    array_to_string((s.types)::text[], '; '::text) AS types,
       (s.types)::text[] AS types_array,
    array_to_string((s.institutes_supporting_study)::text[], '; '::text) AS institutes_supporting_study,
       (s.institutes_supporting_study)::text[] AS institutes_supporting_study_array,
    array_to_string((s.data_general_types)::text[], '; '::text) AS data_general_types,
       (s.data_general_types)::text[] AS data_general_types_array,
    array_to_string(v1.study_variables, '; '::text) AS study_variables,
       v1.study_variables AS study_variables_array,
       v2.study_variable_count,
       s.acknowledgement_statement,
       array_to_string((s.data_species)::text[], '; '::text) AS data_species,
       array_to_string((s.disease_specific_group)::text[], '; '::text) AS disease_specific_group,
       s.disease_specific_related_conditions,
       s.general_research_group,
       s.grant_number,
       s.health_biomed_group,
       s."study_DOI",
       s.study_citation,
       s.has_data_files,
       s.actual_study_size,
       s.release_date,
       s.updated_at,
       s.study_version,
       s."study_website_URL",
       s."CT_URL",
       s."publication_URL",
       s."FOA_number",
       s."FOA_URL",
       s.created_at
FROM ((public.view_study s
    LEFT JOIN ( SELECT view_variables.study_id,
                       array_agg(DISTINCT view_variables.variable) AS study_variables
                FROM public.view_variables
                GROUP BY view_variables.study_id) v1 ON ((s.study_id = v1.study_id)))
    LEFT JOIN ( SELECT view_variables.study_id,
                       count(DISTINCT view_variables.variable) AS study_variable_count
                FROM public.view_variables
                GROUP BY view_variables.study_id) v2 ON ((s.study_id = v2.study_id)));


ALTER VIEW public.view_study_for_es OWNER TO canopy_admin;

--
-- TOC entry 326 (class 1259 OID 22038)
-- Name: view_study_mta_import; Type: VIEW; Schema: public; Owner: canopy_user
--

CREATE VIEW public.view_study_mta_import AS
 SELECT p.study_id,
    p.title,
    p.description,
    p.is_multi_center,
    p.multi_center_sites,
    p.pi_name,
    p.pi_email,
    p.pi_assistant_name,
    p.pi_assistant_email,
    p.pi_institution,
    p.pi_sign_date,
    p.po_name,
    p.officer_sign_date,
    p.estimated_participants,
    p.types,
    p.institutes_supporting_study,
    p.needs_institutional_certifications,
    p.data_general_types,
    p.data_genomic,
    p.data_genotype,
    p.data_sample_types,
    p.data_sequencing,
    p.acknowledgement_statement,
    p.aggregate_appropriate_for_general_use,
    p.consent_to_add_aggregate,
    p.consent_to_add_individual,
    p.data_access_points,
    p.data_analyses,
    p.data_array_data,
    p.data_from_repository_name,
    p.data_phenotype,
    p.data_sample_collection,
    p.data_sharing_info,
    p.data_species,
    p.data_storage_size,
    p.data_submission_date,
    p.data_submission_method,
    p.data_submission_timeline_details,
    p.data_target_delivery_date,
    p.data_target_release_date,
    p.disease_specific_group,
    p.disease_specific_related_conditions,
    p.general_research_group,
    p.geno_seq_platform_info,
    p.geno_seq_platform_url,
    p.geno_seq_platform_probes,
    p.geno_seq_platform_vendor,
    p.geno_seq_platform_description,
    p.geno_seq_platform_name_version,
    p.grant_number,
    p.has_era_account,
    p.has_ic,
    p.health_biomed_group,
    p.individual_appropriate_for_general_use,
    p.other_group_description,
    p.types_other_specify,
    p.data_general_types_other_specify,
    p.data_genomic_other_specify,
    p.data_phenotype_other_specify,
    p.data_sample_types_other_specify,
    p.data_genotype_other_specify,
    p.data_sequencing_other_specify,
    p.data_analyses_other_specify,
    p.data_array_data_other_specify,
    p.data_access_points_other,
    p.access_type,
    p.data_access_type,
    s.created_at,
    s.modified_at
   FROM (public.study s
     JOIN ( SELECT crosstab.study_id,
            crosstab.title,
            crosstab.description,
            crosstab.is_multi_center,
            crosstab.multi_center_sites,
            crosstab.pi_name,
            crosstab.pi_email,
            crosstab.pi_assistant_name,
            crosstab.pi_assistant_email,
            crosstab.pi_institution,
            crosstab.pi_sign_date,
            crosstab.po_name,
            crosstab.officer_sign_date,
            crosstab.estimated_participants,
            crosstab.types,
            crosstab.institutes_supporting_study,
            crosstab.needs_institutional_certifications,
            crosstab.data_general_types,
            crosstab.data_genomic,
            crosstab.data_genotype,
            crosstab.data_sample_types,
            crosstab.data_sequencing,
            crosstab.acknowledgement_statement,
            crosstab.aggregate_appropriate_for_general_use,
            crosstab.consent_to_add_aggregate,
            crosstab.consent_to_add_individual,
            crosstab.data_access_points,
            crosstab.data_analyses,
            crosstab.data_array_data,
            crosstab.data_from_repository_name,
            crosstab.data_phenotype,
            crosstab.data_sample_collection,
            crosstab.data_sharing_info,
            crosstab.data_species,
            crosstab.data_storage_size,
            crosstab.data_submission_date,
            crosstab.data_submission_method,
            crosstab.data_submission_timeline_details,
            crosstab.data_target_delivery_date,
            crosstab.data_target_release_date,
            crosstab.disease_specific_group,
            crosstab.disease_specific_related_conditions,
            crosstab.general_research_group,
            crosstab.geno_seq_platform_info,
            crosstab.geno_seq_platform_url,
            crosstab.geno_seq_platform_probes,
            crosstab.geno_seq_platform_vendor,
            crosstab.geno_seq_platform_description,
            crosstab.geno_seq_platform_name_version,
            crosstab.grant_number,
            crosstab.has_era_account,
            crosstab.has_ic,
            crosstab.health_biomed_group,
            crosstab.individual_appropriate_for_general_use,
            crosstab.other_group_description,
            crosstab.types_other_specify,
            crosstab.data_general_types_other_specify,
            crosstab.data_genomic_other_specify,
            crosstab.data_phenotype_other_specify,
            crosstab.data_sample_types_other_specify,
            crosstab.data_genotype_other_specify,
            crosstab.data_sequencing_other_specify,
            crosstab.data_analyses_other_specify,
            crosstab.data_array_data_other_specify,
            crosstab.data_access_points_other,
            crosstab.access_type,
            crosstab.data_access_type
           FROM public.crosstab('select study_id, p.name, case p.cardinality when true then array_agg(v.property_value)::text else string_agg(v.property_value, '','') end as value
        from entity_property p left outer join study_property_value v  on v.entity_property_id = p.id and p.entity_type_id=1 and p.property_source_id=1
		group by study_id, p.id, p.name
        order by study_id, p.id'::text, '
	    values
		(''title''),
		(''description''),
		(''is_multi_center''),
		(''multi_center_sites''),
		(''pi_name''),
		(''pi_email''),
		(''pi_assistant_name''),
		(''pi_assistant_email''),
		(''pi_institution''),
		(''pi_sign_date''),
		(''po_name''),
		(''officer_sign_date''),
		(''estimated_participants''),
		(''types''),
		(''institutes_supporting_study''),
		(''needs_institutional_certifications''),
		(''data_general_types''),
		(''data_genomic''),
		(''data_genotype''),
		(''data_sample_types''),
		(''data_sequencing''),
		(''acknowledgement_statement''),
		(''aggregate_appropriate_for_general_use''),
		(''consent_to_add_aggregate''),
		(''consent_to_add_individual''),
		(''data_access_points''),
		(''data_analyses''),
		(''data_array_data''),
		(''data_from_repository_name''),
		(''data_phenotype''),
		(''data_sample_collection''),
		(''data_sharing_info''),
		(''data_species''),
		(''data_storage_size''),
		(''data_submission_date''),
		(''data_submission_method''),
		(''data_submission_timeline_details''),
		(''data_target_delivery_date''),
		(''data_target_release_date''),
		(''disease_specific_group''),
		(''disease_specific_related_conditions''),
		(''general_research_group''),
		(''geno_seq_platform_info''),
		(''geno_seq_platform_url''),
		(''geno_seq_platform_probes''),
		(''geno_seq_platform_vendor''),
		(''geno_seq_platform_description''),
		(''geno_seq_platform_name_version''),
		(''grant_number''),
		(''has_era_account''),
		(''has_ic''),
		(''health_biomed_group''),
		(''individual_appropriate_for_general_use''),
		(''other_group_description''),
		(''types_other_specify''),
		(''data_general_types_other_specify''),
		(''data_genomic_other_specify''),
		(''data_phenotype_other_specify''),
		(''data_sample_types_other_specify''),
		(''data_genotype_other_specify''),
		(''data_sequencing_other_specify''),
		(''data_analyses_other_specify''),
		(''data_array_data_other_specify''),
		(''data_access_points_other''),
		(''access_type''),
		(''data_access_type'')
	'::text) crosstab(study_id integer, title text, description text, is_multi_center text, multi_center_sites text, pi_name text, pi_email text, pi_assistant_name text, pi_assistant_email text, pi_institution text, pi_sign_date text, po_name text, officer_sign_date text, estimated_participants text, types text, institutes_supporting_study text, needs_institutional_certifications text, data_general_types text, data_genomic text, data_genotype text, data_sample_types text, data_sequencing text, acknowledgement_statement text, aggregate_appropriate_for_general_use text, consent_to_add_aggregate text, consent_to_add_individual text, data_access_points text, data_analyses text, data_array_data text, data_from_repository_name text, data_phenotype text, data_sample_collection text, data_sharing_info text, data_species text, data_storage_size text, data_submission_date text, data_submission_method text, data_submission_timeline_details text, data_target_delivery_date text, data_target_release_date text, disease_specific_group text, disease_specific_related_conditions text, general_research_group text, geno_seq_platform_info text, geno_seq_platform_url text, geno_seq_platform_probes text, geno_seq_platform_vendor text, geno_seq_platform_description text, geno_seq_platform_name_version text, grant_number text, has_era_account text, has_ic text, health_biomed_group text, individual_appropriate_for_general_use text, other_group_description text, types_other_specify text, data_general_types_other_specify text, data_genomic_other_specify text, data_phenotype_other_specify text, data_sample_types_other_specify text, data_genotype_other_specify text, data_sequencing_other_specify text, data_analyses_other_specify text, data_array_data_other_specify text, data_access_points_other text, access_type text, data_access_type text)) p ON ((s.id = p.study_id)));


ALTER VIEW public.view_study_mta_import OWNER TO canopy_user;

--
-- TOC entry 325 (class 1259 OID 22023)
-- Name: view_study_property_value_display; Type: VIEW; Schema: public; Owner: canopy_admin
--

CREATE VIEW public.view_study_property_value_display AS
 SELECT v.id AS study_property_value_id,
    v.study_id,
    v.entity_property_id,
    v.property_value,
    p.name AS entity_property_name,
    p.property_type_id,
    t.name AS entity_property_type,
    st.id AS entity_property_display_setting_id,
    st.page,
    st.display_section,
    st.display_label,
    st.display_order,
    st.is_facet,
    st.facet_order,
    st.is_sortable
   FROM (((public.study_property_value v
     JOIN public.entity_property p ON ((v.entity_property_id = p.id)))
     JOIN public.entity_property_display_setting st ON ((st.entity_property_id = p.id)))
     LEFT JOIN public.lkup_property_type t ON ((p.property_type_id = t.id)));


ALTER VIEW public.view_study_property_value_display OWNER TO canopy_admin;

--
-- TOC entry 335 (class 1259 OID 22409)
-- Name: view_submission_activity; Type: VIEW; Schema: public; Owner: canopy_admin
--

CREATE VIEW public.view_submission_activity AS
 SELECT (row_number() OVER ())::integer AS id,
    s.study_id,
    s.center,
    s.title AS study_name,
    s.created_at AS study_initiated_date,
    (s.release_date)::date AS study_published_date,
    d.id AS data_submission_id,
    d.date_approved AS files_rejected_date,
    d.file_rejected_count,
    f.id AS data_file_id,
    f.created_at AS data_file_created_date,
    f.approval_date AS data_file_approval_date,
    f.reject_date AS data_file_reject_date
   FROM ((public.view_study s
     LEFT JOIN public.data_submission d ON ((d.study_id = s.study_id)))
     LEFT JOIN public.data_file f ON ((f.submission_id = d.id)))
  WHERE (s.center IS NOT NULL);


ALTER VIEW public.view_submission_activity OWNER TO canopy_admin;

--
-- TOC entry 427 (class 1259 OID 54536)
-- Name: view_user_population; Type: VIEW; Schema: public; Owner: canopy_admin
--

CREATE VIEW public.view_user_population AS
 SELECT u.id AS user_id,
    ((((u.first_name)::text || COALESCE((' '::text || upper((u.middle_initial)::text)), ''::text)) || ' '::text) || (u.last_name)::text) AS name,
    u.email_address,
    u.orcid_id,
    i.name AS institution_name,
    u.job_title,
    s.name AS user_status,
    v.name AS user_researcher_level,
    u.created_at,
    p.name AS user_institution_type,
    t.abbreviation AS user_state,
    c.name AS user_country,
    i.province_region,
    i.is_for_profit,
    u.internal_user,
    l.last_login_at,
    l.total_login,
    (d.last_download_at IS NOT NULL) AS has_downloaded_data,
    d.last_download_at,
    d.total_download
   FROM ((((((((public.users u
     JOIN public.lkup_status s ON ((u.status_id = s.id)))
     JOIN public.institution i ON ((u.institution_id = i.id)))
     LEFT JOIN public.lkup_institution_type p ON ((i.institution_type_id = p.id)))
     LEFT JOIN public.lkup_state t ON ((i.state_id = t.id)))
     LEFT JOIN public.lkup_country c ON ((i.country_id = c.id)))
     LEFT JOIN public.lkup_researcher_level v ON ((u.researcher_level_id = v.id)))
     LEFT JOIN ( SELECT user_login.user_id,
            max(user_login.login_at) AS last_login_at,
            count(user_login.id) AS total_login
           FROM public.user_login
          GROUP BY user_login.user_id) l ON ((u.id = l.user_id)))
     LEFT JOIN ( SELECT data_file_download.download_by AS user_id,
            max(data_file_download.download_at) AS last_download_at,
            count(data_file_download.id) AS total_download
           FROM public.data_file_download
          GROUP BY data_file_download.download_by) d ON ((u.id = d.user_id)))
  ORDER BY u.id;


ALTER VIEW public.view_user_population OWNER TO canopy_admin;

--
-- TOC entry 396 (class 1259 OID 29939)
-- Name: view_user_role; Type: VIEW; Schema: public; Owner: canopy_admin
--

CREATE VIEW public.view_user_role AS
 SELECT r.name,
    u.first_name,
    u.last_name,
    u.email_address,
    c.name AS center,
    u.internal_user
   FROM (((public.users u
     JOIN public.user_role ur ON ((ur.user_id = u.id)))
     JOIN public.lkup_role r ON ((ur.role_id = r.id)))
     LEFT JOIN public.lkup_center c ON ((u.center_id = c.id)))
  ORDER BY r.id;


ALTER VIEW public.view_user_role OWNER TO canopy_admin;

--
-- TOC entry 424 (class 1259 OID 46796)
-- Name: view_variable_overview_display; Type: VIEW; Schema: public; Owner: canopy_admin
--

CREATE VIEW public.view_variable_overview_display AS
 SELECT row_number() OVER () AS lkup_core_variable_property_value_id,
    var.id AS variable_id,
    v.entity_property_id,
    v.property_value,
    p.name AS entity_property_name,
    p.property_type_id,
    t.name AS entity_property_type,
    st.id AS entity_property_display_setting_id,
    st.page,
    st.display_section,
    st.display_label,
    st.display_order,
    st.is_facet,
    st.facet_order,
    st.is_sortable
   FROM (((public.lkup_core_variable_property_value v
     JOIN public.variables var ON ((v.variable_name = var.name)))
     JOIN public.entity_property p ON ((v.entity_property_id = p.id)))
     JOIN public.entity_property_display_setting st ON (((st.entity_property_id = p.id) AND (st.page = 'variable_overview'::text))))
     LEFT JOIN public.lkup_property_type t ON ((p.property_type_id = t.id));


ALTER VIEW public.view_variable_overview_display OWNER TO canopy_admin;

--
-- TOC entry 5595 (class 0 OID 0)
-- Dependencies: 385
-- Name: TABLE view_current_data_file; Type: ACL; Schema: public; Owner: canopy_admin
--

GRANT ALL ON TABLE public.view_current_data_file TO canopy_user;


--
-- TOC entry 5596 (class 0 OID 0)
-- Dependencies: 334
-- Name: TABLE view_current_hub_content; Type: ACL; Schema: public; Owner: canopy_admin
--

GRANT ALL ON TABLE public.view_current_hub_content TO canopy_user;


--
-- TOC entry 5597 (class 0 OID 0)
-- Dependencies: 336
-- Name: TABLE view_current_hub_content_data; Type: ACL; Schema: public; Owner: canopy_admin
--

GRANT ALL ON TABLE public.view_current_hub_content_data TO canopy_user;


--
-- TOC entry 5601 (class 0 OID 0)
-- Dependencies: 325
-- Name: TABLE view_study_property_value_display; Type: ACL; Schema: public; Owner: canopy_admin
--

GRANT ALL ON TABLE public.view_study_property_value_display TO canopy_user;


--
-- TOC entry 5602 (class 0 OID 0)
-- Dependencies: 335
-- Name: TABLE view_submission_activity; Type: ACL; Schema: public; Owner: canopy_admin
--

GRANT ALL ON TABLE public.view_submission_activity TO canopy_user;


--
-- TOC entry 5603 (class 0 OID 0)
-- Dependencies: 427
-- Name: TABLE view_user_population; Type: ACL; Schema: public; Owner: canopy_admin
--

GRANT ALL ON TABLE public.view_user_population TO canopy_user;


--
-- TOC entry 5604 (class 0 OID 0)
-- Dependencies: 396
-- Name: TABLE view_user_role; Type: ACL; Schema: public; Owner: canopy_admin
--

GRANT ALL ON TABLE public.view_user_role TO canopy_user;


--
-- TOC entry 5605 (class 0 OID 0)
-- Dependencies: 424
-- Name: TABLE view_variable_overview_display; Type: ACL; Schema: public; Owner: canopy_admin
--

GRANT ALL ON TABLE public.view_variable_overview_display TO canopy_user;


--
