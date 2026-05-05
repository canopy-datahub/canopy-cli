-- TOC entry 5400 (class 0 OID 0)
-- Dependencies: 8
-- Name: SCHEMA canopy_history; Type: ACL; Schema: -; Owner: canopy_admin
--

GRANT ALL ON SCHEMA canopy_history TO canopy_user;


--
-- TOC entry 5401 (class 0 OID 0)
-- Dependencies: 486
-- Name: FUNCTION after_operation_trigger_fnc(); Type: ACL; Schema: public; Owner: canopy_admin
--

REVOKE ALL ON FUNCTION public.after_operation_trigger_fnc() FROM PUBLIC;
GRANT ALL ON FUNCTION public.after_operation_trigger_fnc() TO canopy_user;


--
-- TOC entry 5402 (class 0 OID 0)
-- Dependencies: 465
-- Name: FUNCTION before_operation_trigger_fnc(); Type: ACL; Schema: public; Owner: canopy_admin
--

REVOKE ALL ON FUNCTION public.before_operation_trigger_fnc() FROM PUBLIC;
GRANT ALL ON FUNCTION public.before_operation_trigger_fnc() TO canopy_user;


--
-- TOC entry 5404 (class 0 OID 0)
-- Dependencies: 518
-- Name: PROCEDURE sp_generate_hub_content_metrics(); Type: ACL; Schema: public; Owner: canopy_admin
--

GRANT ALL ON PROCEDURE public.sp_generate_hub_content_metrics() TO canopy_user;


--
-- TOC entry 5409 (class 0 OID 0)
-- Dependencies: 292
-- Name: SEQUENCE data_file_download_id_seq; Type: ACL; Schema: public; Owner: canopy_admin
--

GRANT ALL ON SEQUENCE public.data_file_download_id_seq TO canopy_user;


--
-- TOC entry 5411 (class 0 OID 0)
-- Dependencies: 284
-- Name: SEQUENCE data_file_id_seq; Type: ACL; Schema: public; Owner: canopy_admin
--

GRANT ALL ON SEQUENCE public.data_file_id_seq TO canopy_user;


--
-- TOC entry 5417 (class 0 OID 0)
-- Dependencies: 282
-- Name: SEQUENCE data_submission_id_seq; Type: ACL; Schema: public; Owner: canopy_admin
--

GRANT ALL ON SEQUENCE public.data_submission_id_seq TO canopy_user;


--
-- TOC entry 5420 (class 0 OID 0)
-- Dependencies: 312
-- Name: SEQUENCE datafile_harmonization_metrics_id_seq; Type: ACL; Schema: public; Owner: canopy_admin
--

GRANT ALL ON SEQUENCE public.datafile_harmonization_metrics_id_seq TO canopy_user;


--
-- TOC entry 5427 (class 0 OID 0)
-- Dependencies: 294
-- Name: SEQUENCE entity_property_mta_mapping_id_seq; Type: ACL; Schema: public; Owner: canopy_admin
--

GRANT ALL ON SEQUENCE public.entity_property_mta_mapping_id_seq TO canopy_user;


--
-- TOC entry 5430 (class 0 OID 0)
-- Dependencies: 302
-- Name: SEQUENCE event_link_id_seq; Type: ACL; Schema: public; Owner: canopy_admin
--

GRANT ALL ON SEQUENCE public.event_link_id_seq TO canopy_user;


--
-- TOC entry 5433 (class 0 OID 0)
-- Dependencies: 300
-- Name: SEQUENCE events_id_seq; Type: ACL; Schema: public; Owner: canopy_admin
--

GRANT ALL ON SEQUENCE public.events_id_seq TO canopy_user;


--
-- TOC entry 5436 (class 0 OID 0)
-- Dependencies: 397
-- Name: SEQUENCE funding_id_seq; Type: ACL; Schema: public; Owner: canopy_admin
--

GRANT ALL ON SEQUENCE public.funding_id_seq TO canopy_user;


--
-- TOC entry 5439 (class 0 OID 0)
-- Dependencies: 329
-- Name: SEQUENCE hub_content_metrics_id_seq; Type: ACL; Schema: public; Owner: canopy_admin
--

GRANT ALL ON SEQUENCE public.hub_content_metrics_id_seq TO canopy_user;


--
-- TOC entry 5442 (class 0 OID 0)
-- Dependencies: 257
-- Name: SEQUENCE institution_id_seq; Type: ACL; Schema: public; Owner: canopy_admin
--

GRANT SELECT,USAGE ON SEQUENCE public.institution_id_seq TO canopy_user;


--
-- TOC entry 5462 (class 0 OID 0)
-- Dependencies: 296
-- Name: SEQUENCE lkup_event_type_id_seq; Type: ACL; Schema: public; Owner: canopy_admin
--

GRANT ALL ON SEQUENCE public.lkup_event_type_id_seq TO canopy_user;


--
-- TOC entry 5469 (class 0 OID 0)
-- Dependencies: 308
-- Name: SEQUENCE lkup_metrics_report_type_id_seq; Type: ACL; Schema: public; Owner: canopy_admin
--

GRANT ALL ON SEQUENCE public.lkup_metrics_report_type_id_seq TO canopy_user;


--
-- TOC entry 5472 (class 0 OID 0)
-- Dependencies: 298
-- Name: SEQUENCE lkup_news_type_id_seq; Type: ACL; Schema: public; Owner: canopy_admin
--

GRANT ALL ON SEQUENCE public.lkup_news_type_id_seq TO canopy_user;


--
-- TOC entry 5483 (class 0 OID 0)
-- Dependencies: 414
-- Name: SEQUENCE lkup_referrer_id_seq; Type: ACL; Schema: public; Owner: canopy_admin
--

GRANT ALL ON SEQUENCE public.lkup_referrer_id_seq TO canopy_user;


--
-- TOC entry 5488 (class 0 OID 0)
-- Dependencies: 314
-- Name: SEQUENCE lkup_resolution_type_id_seq; Type: ACL; Schema: public; Owner: canopy_admin
--

GRANT ALL ON SEQUENCE public.lkup_resolution_type_id_seq TO canopy_user;


--
-- TOC entry 5499 (class 0 OID 0)
-- Dependencies: 316
-- Name: SEQUENCE lkup_support_request_type_id_seq; Type: ACL; Schema: public; Owner: canopy_admin
--

GRANT ALL ON SEQUENCE public.lkup_support_request_type_id_seq TO canopy_user;


--
-- TOC entry 5510 (class 0 OID 0)
-- Dependencies: 310
-- Name: SEQUENCE metrics_report_id_seq; Type: ACL; Schema: public; Owner: canopy_admin
--

GRANT ALL ON SEQUENCE public.metrics_report_id_seq TO canopy_user;


--
-- TOC entry 5513 (class 0 OID 0)
-- Dependencies: 304
-- Name: SEQUENCE news_id_seq; Type: ACL; Schema: public; Owner: canopy_admin
--

GRANT ALL ON SEQUENCE public.news_id_seq TO canopy_user;


--
-- TOC entry 5516 (class 0 OID 0)
-- Dependencies: 306
-- Name: SEQUENCE news_link_id_seq; Type: ACL; Schema: public; Owner: canopy_admin
--

GRANT ALL ON SEQUENCE public.news_link_id_seq TO canopy_user;


--
-- TOC entry 5519 (class 0 OID 0)
-- Dependencies: 399
-- Name: SEQUENCE newsletter_id_seq; Type: ACL; Schema: public; Owner: canopy_admin
--

GRANT ALL ON SEQUENCE public.newsletter_id_seq TO canopy_user;


--
-- TOC entry 5531 (class 0 OID 0)
-- Dependencies: 247
-- Name: SEQUENCE s3_file_id_seq; Type: ACL; Schema: public; Owner: canopy_admin
--

GRANT ALL ON SEQUENCE public.s3_file_id_seq TO canopy_user;


--
-- TOC entry 5534 (class 0 OID 0)
-- Dependencies: 386
-- Name: SEQUENCE sas_data_file_id_seq; Type: ACL; Schema: public; Owner: canopy_admin
--

GRANT ALL ON SEQUENCE public.sas_data_file_id_seq TO canopy_user;


--
-- TOC entry 5537 (class 0 OID 0)
-- Dependencies: 388
-- Name: SEQUENCE sas_file_download_id_seq; Type: ACL; Schema: public; Owner: canopy_admin
--

GRANT ALL ON SEQUENCE public.sas_file_download_id_seq TO canopy_user;


--
-- TOC entry 5540 (class 0 OID 0)
-- Dependencies: 401
-- Name: SEQUENCE search_log_id_seq; Type: ACL; Schema: public; Owner: canopy_admin
--

GRANT ALL ON SEQUENCE public.search_log_id_seq TO canopy_user;


--
-- TOC entry 5544 (class 0 OID 0)
-- Dependencies: 320
-- Name: SEQUENCE study_harmonization_metrics_id_seq; Type: ACL; Schema: public; Owner: canopy_admin
--

GRANT ALL ON SEQUENCE public.study_harmonization_metrics_id_seq TO canopy_user;


--
-- TOC entry 5546 (class 0 OID 0)
-- Dependencies: 249
-- Name: SEQUENCE study_id_seq; Type: ACL; Schema: public; Owner: canopy_admin
--

GRANT ALL ON SEQUENCE public.study_id_seq TO canopy_user;


--
-- TOC entry 5549 (class 0 OID 0)
-- Dependencies: 255
-- Name: SEQUENCE study_property_value_id_seq; Type: ACL; Schema: public; Owner: canopy_admin
--

GRANT SELECT,USAGE ON SEQUENCE public.study_property_value_id_seq TO canopy_user;


--
-- TOC entry 5552 (class 0 OID 0)
-- Dependencies: 318
-- Name: SEQUENCE support_request_id_seq; Type: ACL; Schema: public; Owner: canopy_admin
--

GRANT ALL ON SEQUENCE public.support_request_id_seq TO canopy_user;



--
-- TOC entry 5564 (class 0 OID 0)
-- Dependencies: 411
-- Name: SEQUENCE user_file_upload_id_seq; Type: ACL; Schema: public; Owner: canopy_admin
--

GRANT ALL ON SEQUENCE public.user_file_upload_id_seq TO canopy_user;


--
-- TOC entry 5567 (class 0 OID 0)
-- Dependencies: 274
-- Name: SEQUENCE user_login_id_seq; Type: ACL; Schema: public; Owner: canopy_admin
--

GRANT ALL ON SEQUENCE public.user_login_id_seq TO canopy_user;


--
-- TOC entry 5573 (class 0 OID 0)
-- Dependencies: 416
-- Name: SEQUENCE user_referrer_id_seq; Type: ACL; Schema: public; Owner: canopy_admin
--

GRANT ALL ON SEQUENCE public.user_referrer_id_seq TO canopy_user;


--
-- TOC entry 5576 (class 0 OID 0)
-- Dependencies: 265
-- Name: SEQUENCE user_role_id_seq; Type: ACL; Schema: public; Owner: canopy_admin
--

GRANT SELECT,USAGE ON SEQUENCE public.user_role_id_seq TO canopy_user;


--
-- TOC entry 5582 (class 0 OID 0)
-- Dependencies: 263
-- Name: SEQUENCE users_id_seq; Type: ACL; Schema: public; Owner: canopy_admin
--

GRANT ALL ON SEQUENCE public.users_id_seq TO canopy_user;


--
-- TOC entry 5588 (class 0 OID 0)
-- Dependencies: 420
-- Name: SEQUENCE lkup_core_variable_permissible_value_id_seq; Type: ACL; Schema: public; Owner: canopy_admin
--

GRANT ALL ON SEQUENCE public.lkup_core_variable_permissible_value_id_seq TO canopy_user;


--
-- TOC entry 5591 (class 0 OID 0)
-- Dependencies: 422
-- Name: SEQUENCE lkup_core_variable_property_value_id_seq; Type: ACL; Schema: public; Owner: canopy_admin
--

GRANT ALL ON SEQUENCE public.lkup_core_variable_property_value_id_seq TO canopy_user;


--
-- TOC entry 5594 (class 0 OID 0)
-- Dependencies: 429
-- Name: SEQUENCE variables_id_seq; Type: ACL; Schema: public; Owner: canopy_admin
--

GRANT ALL ON SEQUENCE public.variables_id_seq TO canopy_user;


--
-- TOC entry 5600 (class 0 OID 0)
-- Dependencies: 433
-- Name: TABLE view_study_for_es; Type: ACL; Schema: public; Owner: canopy_admin
--

GRANT ALL ON TABLE public.view_study_for_es TO canopy_user;


--
-- TOC entry 2750 (class 826 OID 16822)
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: public; Owner: canopy_admin
--
-- The deploy runs as the RDS master user (e.g. canopi_postgres_staging),
-- which can't ALTER DEFAULT PRIVILEGES of another role. SET ROLE first.
-- The master role inherits canopy_admin via 010_roles.sql, which makes
-- this SET ROLE legal.

SET ROLE canopy_admin;
ALTER DEFAULT PRIVILEGES FOR ROLE canopy_admin IN SCHEMA public GRANT ALL ON SEQUENCES TO canopy_user;
RESET ROLE;


--
-- TOC entry 2749 (class 826 OID 16823)
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: canopy_admin
--

SET ROLE canopy_admin;
ALTER DEFAULT PRIVILEGES FOR ROLE canopy_admin IN SCHEMA public GRANT ALL ON TABLES TO canopy_user;
RESET ROLE;


-- Completed on 2025-06-24 07:28:04

--
-- PostgreSQL database dump complete
--

-- Let canopy_admin access canopy_user's views
GRANT SELECT ON public.view_study TO canopy_admin;
GRANT SELECT ON public.view_study_all TO canopy_admin;

-- And vice versa
GRANT SELECT ON ALL TABLES IN SCHEMA public TO canopy_admin;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO canopy_user;
