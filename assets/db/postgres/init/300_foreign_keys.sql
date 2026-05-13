-- TOC entry 5171 (class 2606 OID 16983)
-- Name: data_file fk_data_file_dictionary_file_id; Type: FK CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.data_file
    ADD CONSTRAINT fk_data_file_dictionary_file_id FOREIGN KEY (dictionary_file_id) REFERENCES public.data_file(id) NOT VALID;


--
-- TOC entry 5179 (class 2606 OID 17076)
-- Name: data_file_download fk_data_file_download_file_id; Type: FK CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.data_file_download
    ADD CONSTRAINT fk_data_file_download_file_id FOREIGN KEY (data_file_id) REFERENCES public.data_file(id) NOT VALID;


--
-- TOC entry 5180 (class 2606 OID 17081)
-- Name: data_file_download fk_data_file_download_user_id; Type: FK CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.data_file_download
    ADD CONSTRAINT fk_data_file_download_user_id FOREIGN KEY (download_by) REFERENCES public.users(id) NOT VALID;


--
-- TOC entry 5172 (class 2606 OID 16988)
-- Name: data_file fk_data_file_metadata_file_id; Type: FK CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.data_file
    ADD CONSTRAINT fk_data_file_metadata_file_id FOREIGN KEY (metadata_file_id) REFERENCES public.data_file(id) NOT VALID;


--
-- TOC entry 5173 (class 2606 OID 16993)
-- Name: data_file fk_data_file_original_data_file_id; Type: FK CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.data_file
    ADD CONSTRAINT fk_data_file_original_data_file_id FOREIGN KEY (original_data_file_id) REFERENCES public.data_file(id) NOT VALID;


--
-- TOC entry 5174 (class 2606 OID 16968)
-- Name: data_file fk_data_file_s3_file_id; Type: FK CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.data_file
    ADD CONSTRAINT fk_data_file_s3_file_id FOREIGN KEY (s3_file_id) REFERENCES public.s3_file(id) NOT VALID;


--
-- TOC entry 5175 (class 2606 OID 16973)
-- Name: data_file fk_data_file_status_id; Type: FK CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.data_file
    ADD CONSTRAINT fk_data_file_status_id FOREIGN KEY (status_id) REFERENCES public.lkup_status(id) NOT VALID;


--
-- TOC entry 5176 (class 2606 OID 16963)
-- Name: data_file fk_data_file_submission_id; Type: FK CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.data_file
    ADD CONSTRAINT fk_data_file_submission_id FOREIGN KEY (submission_id) REFERENCES public.data_submission(id) NOT VALID;


--
-- TOC entry 5177 (class 2606 OID 16978)
-- Name: data_file fk_data_file_type_id; Type: FK CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.data_file
    ADD CONSTRAINT fk_data_file_type_id FOREIGN KEY (file_category_id) REFERENCES public.lkup_data_file_category(id) NOT VALID;


--
-- TOC entry 5167 (class 2606 OID 16942)
-- Name: data_submission fk_data_submission_status_id; Type: FK CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.data_submission
    ADD CONSTRAINT fk_data_submission_status_id FOREIGN KEY (status_id) REFERENCES public.lkup_status(id) NOT VALID;


--
-- TOC entry 5168 (class 2606 OID 16947)
-- Name: data_submission fk_data_submission_step_id; Type: FK CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.data_submission
    ADD CONSTRAINT fk_data_submission_step_id FOREIGN KEY (step_id) REFERENCES public.lkup_submission_step(id) NOT VALID;


--
-- TOC entry 5169 (class 2606 OID 16932)
-- Name: data_submission fk_data_submission_study_id; Type: FK CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.data_submission
    ADD CONSTRAINT fk_data_submission_study_id FOREIGN KEY (study_id) REFERENCES public.study(id) NOT VALID;


--
-- TOC entry 5170 (class 2606 OID 16937)
-- Name: data_submission fk_data_submission_submitter_user_id; Type: FK CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.data_submission
    ADD CONSTRAINT fk_data_submission_submitter_user_id FOREIGN KEY (submitter_user_id) REFERENCES public.users(id) NOT VALID;


--
-- TOC entry 5189 (class 2606 OID 17290)
-- Name: datafile_harmonization_metrics fk_datafile_harmonization_report_id; Type: FK CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.datafile_harmonization_metrics
    ADD CONSTRAINT fk_datafile_harmonization_report_id FOREIGN KEY (report_id) REFERENCES public.metrics_report(id) NOT VALID;


--
-- TOC entry 5146 (class 2606 OID 16669)
-- Name: entity_property_display_setting fk_display_setting_entity_group_propery_id; Type: FK CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.entity_property_display_setting
    ADD CONSTRAINT fk_display_setting_entity_group_propery_id FOREIGN KEY (group_property_id) REFERENCES public.entity_property(id) NOT VALID;


--
-- TOC entry 5147 (class 2606 OID 16664)
-- Name: entity_property_display_setting fk_display_setting_entity_propery_id; Type: FK CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.entity_property_display_setting
    ADD CONSTRAINT fk_display_setting_entity_propery_id FOREIGN KEY (entity_property_id) REFERENCES public.entity_property(id) NOT VALID;


--
-- TOC entry 5142 (class 2606 OID 16643)
-- Name: entity_property fk_entity_property_code_list_id; Type: FK CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.entity_property
    ADD CONSTRAINT fk_entity_property_code_list_id FOREIGN KEY (code_list_id) REFERENCES public.lkup_property_codelist(id) NOT VALID;


--
-- TOC entry 5143 (class 2606 OID 16638)
-- Name: entity_property fk_entity_property_entity_type_id; Type: FK CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.entity_property
    ADD CONSTRAINT fk_entity_property_entity_type_id FOREIGN KEY (entity_type_id) REFERENCES public.lkup_entity_type(id) NOT VALID;


--
-- TOC entry 5144 (class 2606 OID 16648)
-- Name: entity_property fk_entity_property_source_id; Type: FK CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.entity_property
    ADD CONSTRAINT fk_entity_property_source_id FOREIGN KEY (property_source_id) REFERENCES public.lkup_property_source(id) NOT VALID;


--
-- TOC entry 5145 (class 2606 OID 16633)
-- Name: entity_property fk_entity_property_type_id; Type: FK CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.entity_property
    ADD CONSTRAINT fk_entity_property_type_id FOREIGN KEY (property_type_id) REFERENCES public.lkup_property_type(id) NOT VALID;


--
-- TOC entry 5185 (class 2606 OID 17188)
-- Name: event_link fk_event_link_event_id; Type: FK CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.event_link
    ADD CONSTRAINT fk_event_link_event_id FOREIGN KEY (event_id) REFERENCES public.events(id) NOT VALID;


--
-- TOC entry 5184 (class 2606 OID 17172)
-- Name: events fk_event_type_id; Type: FK CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.events
    ADD CONSTRAINT fk_event_type_id FOREIGN KEY (event_type_id) REFERENCES public.lkup_event_type(id);


--
-- TOC entry 5197 (class 2606 OID 22328)
-- Name: hub_content_metrics fk_hub_content_metrics_report_id; Type: FK CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.hub_content_metrics
    ADD CONSTRAINT fk_hub_content_metrics_report_id FOREIGN KEY (report_id) REFERENCES public.metrics_report(id) NOT VALID;


--
-- TOC entry 5150 (class 2606 OID 16732)
-- Name: institution fk_institution_country_id; Type: FK CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.institution
    ADD CONSTRAINT fk_institution_country_id FOREIGN KEY (country_id) REFERENCES public.lkup_country(id) NOT VALID;


--
-- TOC entry 5151 (class 2606 OID 16737)
-- Name: institution fk_institution_state_id; Type: FK CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.institution
    ADD CONSTRAINT fk_institution_state_id FOREIGN KEY (state_id) REFERENCES public.lkup_state(id) NOT VALID;


--
-- TOC entry 5152 (class 2606 OID 16727)
-- Name: institution fk_institution_status_id; Type: FK CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.institution
    ADD CONSTRAINT fk_institution_status_id FOREIGN KEY (status_id) REFERENCES public.lkup_status(id) NOT VALID;


--
-- TOC entry 5153 (class 2606 OID 16722)
-- Name: institution fk_institution_type_id; Type: FK CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.institution
    ADD CONSTRAINT fk_institution_type_id FOREIGN KEY (institution_type_id) REFERENCES public.lkup_institution_type(id) NOT VALID;


--
-- TOC entry 5188 (class 2606 OID 17276)
-- Name: metrics_report fk_metrics_report_weekly_type_id; Type: FK CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.metrics_report
    ADD CONSTRAINT fk_metrics_report_weekly_type_id FOREIGN KEY (type_id) REFERENCES public.lkup_metrics_report_type(id) NOT VALID;


--
-- TOC entry 5181 (class 2606 OID 17100)
-- Name: entity_property_mta_mapping fk_mta_mapping_codelist_id; Type: FK CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.entity_property_mta_mapping
    ADD CONSTRAINT fk_mta_mapping_codelist_id FOREIGN KEY (codelist_id) REFERENCES public.lkup_property_codelist(id) NOT VALID;


--
-- TOC entry 5182 (class 2606 OID 17105)
-- Name: entity_property_mta_mapping fk_mta_mapping_codelist_value_id; Type: FK CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.entity_property_mta_mapping
    ADD CONSTRAINT fk_mta_mapping_codelist_value_id FOREIGN KEY (codelist_value_id) REFERENCES public.lkup_property_codelist_value(id) NOT VALID;


--
-- TOC entry 5183 (class 2606 OID 17095)
-- Name: entity_property_mta_mapping fk_mta_mapping_entity_propery_id; Type: FK CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.entity_property_mta_mapping
    ADD CONSTRAINT fk_mta_mapping_entity_propery_id FOREIGN KEY (entity_property_id) REFERENCES public.entity_property(id) NOT VALID;


--
-- TOC entry 5187 (class 2606 OID 17252)
-- Name: news_link fk_news_link_news_id; Type: FK CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.news_link
    ADD CONSTRAINT fk_news_link_news_id FOREIGN KEY (news_id) REFERENCES public.news(id) NOT VALID;


--
-- TOC entry 5186 (class 2606 OID 17236)
-- Name: news fk_news_type_id; Type: FK CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.news
    ADD CONSTRAINT fk_news_type_id FOREIGN KEY (type_id) REFERENCES public.lkup_news_type(id) NOT VALID;


--
-- TOC entry 5138 (class 2606 OID 16492)
-- Name: lkup_property_codelist_value fk_property_codelist_value_codelist_id; Type: FK CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.lkup_property_codelist_value
    ADD CONSTRAINT fk_property_codelist_value_codelist_id FOREIGN KEY (property_codelist_id) REFERENCES public.lkup_property_codelist(id) NOT VALID;


--
-- TOC entry 5139 (class 2606 OID 16571)
-- Name: s3_file fk_s3_file_type_id; Type: FK CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.s3_file
    ADD CONSTRAINT fk_s3_file_type_id FOREIGN KEY (file_type_id) REFERENCES public.lkup_file_type(id) NOT VALID;


--
-- TOC entry 5200 (class 2606 OID 29140)
-- Name: sas_data_file fk_sas_data_file_category_id; Type: FK CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.sas_data_file
    ADD CONSTRAINT fk_sas_data_file_category_id FOREIGN KEY (file_category_id) REFERENCES public.lkup_data_file_category(id) NOT VALID;


--
-- TOC entry 5201 (class 2606 OID 29125)
-- Name: sas_data_file fk_sas_data_file_parent_id; Type: FK CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.sas_data_file
    ADD CONSTRAINT fk_sas_data_file_parent_id FOREIGN KEY (parent_data_file_id) REFERENCES public.data_file(id) NOT VALID;


--
-- TOC entry 5202 (class 2606 OID 29130)
-- Name: sas_data_file fk_sas_data_file_s3_file_id; Type: FK CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.sas_data_file
    ADD CONSTRAINT fk_sas_data_file_s3_file_id FOREIGN KEY (s3_file_id) REFERENCES public.s3_file(id) NOT VALID;


--
-- TOC entry 5203 (class 2606 OID 29135)
-- Name: sas_data_file fk_sas_data_file_status_id; Type: FK CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.sas_data_file
    ADD CONSTRAINT fk_sas_data_file_status_id FOREIGN KEY (status_id) REFERENCES public.lkup_status(id) NOT VALID;


--
-- TOC entry 5204 (class 2606 OID 29153)
-- Name: sas_file_download fk_sas_file_download_file_id; Type: FK CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.sas_file_download
    ADD CONSTRAINT fk_sas_file_download_file_id FOREIGN KEY (sas_file_id) REFERENCES public.sas_data_file(id) NOT VALID;


--
-- TOC entry 5205 (class 2606 OID 29158)
-- Name: sas_file_download fk_sas_file_download_user_id; Type: FK CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.sas_file_download
    ADD CONSTRAINT fk_sas_file_download_user_id FOREIGN KEY (download_by) REFERENCES public.users(id) NOT VALID;


--
-- TOC entry 5140 (class 2606 OID 16587)
-- Name: study fk_study_center_id; Type: FK CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.study
    ADD CONSTRAINT fk_study_center_id FOREIGN KEY (center_id) REFERENCES public.lkup_center(id) NOT VALID;


--
-- TOC entry 5195 (class 2606 OID 17365)
-- Name: study_harmonization_metrics fk_study_harmonization_report_id; Type: FK CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.study_harmonization_metrics
    ADD CONSTRAINT fk_study_harmonization_report_id FOREIGN KEY (report_id) REFERENCES public.metrics_report(id) NOT VALID;


--
-- TOC entry 5148 (class 2606 OID 16690)
-- Name: study_property_value fk_study_property_value_entity_property_id; Type: FK CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.study_property_value
    ADD CONSTRAINT fk_study_property_value_entity_property_id FOREIGN KEY (entity_property_id) REFERENCES public.entity_property(id) NOT VALID;


--
-- TOC entry 5149 (class 2606 OID 16685)
-- Name: study_property_value fk_study_property_value_study_id; Type: FK CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.study_property_value
    ADD CONSTRAINT fk_study_property_value_study_id FOREIGN KEY (study_id) REFERENCES public.study(id) NOT VALID;


--
-- TOC entry 5141 (class 2606 OID 16592)
-- Name: study fk_study_status_id; Type: FK CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.study
    ADD CONSTRAINT fk_study_status_id FOREIGN KEY (status_id) REFERENCES public.lkup_status(id) NOT VALID;


--
-- TOC entry 5190 (class 2606 OID 17324)
-- Name: support_request fk_support_request_assignee_user_id; Type: FK CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.support_request
    ADD CONSTRAINT fk_support_request_assignee_user_id FOREIGN KEY (assignee_user_id) REFERENCES public.users(id) DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 5191 (class 2606 OID 17319)
-- Name: support_request fk_support_request_requestor_user_id; Type: FK CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.support_request
    ADD CONSTRAINT fk_support_request_requestor_user_id FOREIGN KEY (requestor_user_id) REFERENCES public.users(id) DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 5192 (class 2606 OID 17339)
-- Name: support_request fk_support_request_resolution_type_id; Type: FK CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.support_request
    ADD CONSTRAINT fk_support_request_resolution_type_id FOREIGN KEY (resolution_type_id) REFERENCES public.lkup_resolution_type(id) DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 5193 (class 2606 OID 17329)
-- Name: support_request fk_support_request_status_id; Type: FK CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.support_request
    ADD CONSTRAINT fk_support_request_status_id FOREIGN KEY (status_id) REFERENCES public.lkup_status(id) DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 5194 (class 2606 OID 17334)
-- Name: support_request fk_support_request_type_id; Type: FK CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.support_request
    ADD CONSTRAINT fk_support_request_type_id FOREIGN KEY (type_id) REFERENCES public.lkup_support_request_type(id) DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 5154 (class 2606 OID 22122)
-- Name: users fk_user_center_id; Type: FK CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT fk_user_center_id FOREIGN KEY (center_id) REFERENCES public.lkup_center(id) DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 5206 (class 2606 OID 43542)
-- Name: user_file_upload fk_user_file_upload_by; Type: FK CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.user_file_upload
    ADD CONSTRAINT fk_user_file_upload_by FOREIGN KEY (upload_by) REFERENCES public.users(id) NOT VALID;


--
-- TOC entry 5207 (class 2606 OID 43552)
-- Name: user_file_upload fk_user_file_upload_delete_by; Type: FK CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.user_file_upload
    ADD CONSTRAINT fk_user_file_upload_delete_by FOREIGN KEY (delete_by) REFERENCES public.users(id) NOT VALID;


--
-- TOC entry 5208 (class 2606 OID 43547)
-- Name: user_file_upload fk_user_file_upload_download_by; Type: FK CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.user_file_upload
    ADD CONSTRAINT fk_user_file_upload_download_by FOREIGN KEY (download_by) REFERENCES public.users(id) NOT VALID;


--
-- TOC entry 5209 (class 2606 OID 43537)
-- Name: user_file_upload fk_user_file_upload_s3_file_id; Type: FK CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.user_file_upload
    ADD CONSTRAINT fk_user_file_upload_s3_file_id FOREIGN KEY (s3_file_id) REFERENCES public.s3_file(id) NOT VALID;


--
-- TOC entry 5210 (class 2606 OID 43532)
-- Name: user_file_upload fk_user_file_upload_study_id; Type: FK CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.user_file_upload
    ADD CONSTRAINT fk_user_file_upload_study_id FOREIGN KEY (study_id) REFERENCES public.study(id) NOT VALID;


--
-- TOC entry 5155 (class 2606 OID 21312)
-- Name: users fk_user_institution_id; Type: FK CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT fk_user_institution_id FOREIGN KEY (institution_id) REFERENCES public.institution(id) DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 5162 (class 2606 OID 16869)
-- Name: user_login fk_user_login_user_id; Type: FK CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.user_login
    ADD CONSTRAINT fk_user_login_user_id FOREIGN KEY (user_id) REFERENCES public.users(id) NOT VALID;


--
-- TOC entry 5211 (class 2606 OID 46703)
-- Name: user_referrer fk_user_referrer_id; Type: FK CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.user_referrer
    ADD CONSTRAINT fk_user_referrer_id FOREIGN KEY (referrer_id) REFERENCES public.lkup_referrer(id) NOT VALID;


--
-- TOC entry 5212 (class 2606 OID 46698)
-- Name: user_referrer fk_user_referrer_user_id; Type: FK CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.user_referrer
    ADD CONSTRAINT fk_user_referrer_user_id FOREIGN KEY (user_id) REFERENCES public.users(id) NOT VALID;


--
-- TOC entry 5156 (class 2606 OID 16778)
-- Name: users fk_user_researcher_level; Type: FK CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT fk_user_researcher_level FOREIGN KEY (researcher_level_id) REFERENCES public.lkup_researcher_level(id) DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 5158 (class 2606 OID 16796)
-- Name: user_role fk_user_role_role_id; Type: FK CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.user_role
    ADD CONSTRAINT fk_user_role_role_id FOREIGN KEY (role_id) REFERENCES public.lkup_role(id) NOT VALID;


--
-- TOC entry 5159 (class 2606 OID 16791)
-- Name: user_role fk_user_role_user_id; Type: FK CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.user_role
    ADD CONSTRAINT fk_user_role_user_id FOREIGN KEY (user_id) REFERENCES public.users(id) NOT VALID;


--
-- TOC entry 5157 (class 2606 OID 16773)
-- Name: users fk_user_status; Type: FK CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT fk_user_status FOREIGN KEY (status_id) REFERENCES public.lkup_status(id) DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 5215 (class 2606 OID 58945)
-- Name: lkup_variable_category fk_variable_category_center_id; Type: FK CONSTRAINT; Schema: public; Owner: canopy_admin
--


--
-- TOC entry 5216 (class 2606 OID 58960)
-- Name: variables fk_variable_category_id; Type: FK CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.variables
    ADD CONSTRAINT fk_variable_category_id FOREIGN KEY (category_id) REFERENCES public.lkup_variable_category(id) NOT VALID;


--
-- TOC entry 5217 (class 2606 OID 58970)
-- Name: variables fk_variable_center_id; Type: FK CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.variables
    ADD CONSTRAINT fk_variable_center_id FOREIGN KEY (center_id) REFERENCES public.lkup_center(id) NOT VALID;


--
-- TOC entry 5213 (class 2606 OID 46791)
-- Name: lkup_core_variable_property_value fk_lkup_core_variable_property_value_entity_property_id; Type: FK CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.lkup_core_variable_property_value
    ADD CONSTRAINT fk_lkup_core_variable_property_value_entity_property_id FOREIGN KEY (entity_property_id) REFERENCES public.entity_property(id) NOT VALID;


--
-- TOC entry 5218 (class 2606 OID 58965)
-- Name: variables fk_variable_study_id; Type: FK CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.variables
    ADD CONSTRAINT fk_variable_study_id FOREIGN KEY (study_id) REFERENCES public.study(id) NOT VALID;


--
-- Name: role_capability fk_role_capability_role_id; Type: FK CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.role_capability
    ADD CONSTRAINT fk_role_capability_role_id FOREIGN KEY (role_id) REFERENCES public.lkup_role(id) ON DELETE CASCADE;


--
-- Name: role_capability fk_role_capability_capability_id; Type: FK CONSTRAINT; Schema: public; Owner: canopy_admin
--

ALTER TABLE ONLY public.role_capability
    ADD CONSTRAINT fk_role_capability_capability_id FOREIGN KEY (capability_id) REFERENCES public.lkup_capability(id) ON DELETE CASCADE;


--
