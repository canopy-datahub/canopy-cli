-- TOC entry 518 (class 1255 OID 29429)
-- Name: sp_generate_hub_content_metrics(); Type: PROCEDURE; Schema: public; Owner: canopy_admin
--

CREATE PROCEDURE public.sp_generate_hub_content_metrics()
    LANGUAGE plpgsql
    AS $$
 declare
 	_report_date date = Now()::DATE;
 	_report_id integer;
 begin
	IF  EXISTS (SELECT FROM metrics_report where report_date = _report_date) THEN
		 select id into _report_id from metrics_report where report_date = _report_date;
	ELSE
		INSERT INTO  metrics_report (report_date, type_id) values(_report_date, 1) returning id into  _report_id;
	END IF;

	Delete from hub_content_metrics where report_id=_report_id;
	INSERT INTO hub_content_metrics(report_id, center, study_id, study_title,study_status, study_create_date,study_has_data_file,
		total_file_count,data_file_count,total_file_size, orig_data_file_count, standardized_data_file_count, metadata_file_count,
		dictionary_file_count,	readme_file_count,	other_file_count )
	SELECT _report_id, d.center, d.study_id, d.study_title, d.study_status, d.study_create_date,
			d.study_has_data_file,
            d.total_file_count,
            d.data_file_count,
            d.total_file_size,
            d.orig_data_file_count,
            d.standardized_data_file_count,
            d.metadata_file_count,
            d.dictionary_file_count,
            d.readme_file_count,
            d.other_file_count
 	FROM view_current_hub_content d
	where study_status='Approved';
END;
$$;


ALTER PROCEDURE public.sp_generate_hub_content_metrics() OWNER TO canopy_admin;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
