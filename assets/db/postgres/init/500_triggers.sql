-- TOC entry 5231 (class 2620 OID 28424)
-- Name: data_file data_file_after_operation_trigger; Type: TRIGGER; Schema: public; Owner: canopy_admin
--

CREATE TRIGGER data_file_after_operation_trigger AFTER DELETE OR UPDATE ON public.data_file FOR EACH ROW EXECUTE FUNCTION public.after_operation_trigger_fnc();


--
-- TOC entry 5230 (class 2620 OID 29087)
-- Name: data_submission data_submission_after_operation_trigger; Type: TRIGGER; Schema: public; Owner: canopy_admin
--

CREATE TRIGGER data_submission_after_operation_trigger AFTER DELETE OR UPDATE ON public.data_submission FOR EACH ROW EXECUTE FUNCTION public.after_operation_trigger_fnc();


--
-- TOC entry 5224 (class 2620 OID 29207)
-- Name: institution institution_after_operation_trigger; Type: TRIGGER; Schema: public; Owner: canopy_admin
--

CREATE TRIGGER institution_after_operation_trigger AFTER DELETE OR UPDATE ON public.institution FOR EACH ROW EXECUTE FUNCTION public.after_operation_trigger_fnc();


--
-- TOC entry 5221 (class 2620 OID 29020)
-- Name: s3_file s3_file_after_operation_trigger; Type: TRIGGER; Schema: public; Owner: canopy_admin
--

CREATE TRIGGER s3_file_after_operation_trigger AFTER DELETE OR UPDATE ON public.s3_file FOR EACH ROW EXECUTE FUNCTION public.after_operation_trigger_fnc();


--
-- TOC entry 5233 (class 2620 OID 29700)
-- Name: sas_data_file sas_data_file_after_operation_trigger; Type: TRIGGER; Schema: public; Owner: canopy_admin
--

CREATE TRIGGER sas_data_file_after_operation_trigger AFTER DELETE OR UPDATE ON public.sas_data_file FOR EACH ROW EXECUTE FUNCTION public.after_operation_trigger_fnc();


--
-- TOC entry 5222 (class 2620 OID 29064)
-- Name: study study_after_operation_trigger; Type: TRIGGER; Schema: public; Owner: canopy_admin
--

CREATE TRIGGER study_after_operation_trigger AFTER DELETE OR UPDATE ON public.study FOR EACH ROW EXECUTE FUNCTION public.after_operation_trigger_fnc();


--
-- TOC entry 5223 (class 2620 OID 29094)
-- Name: study_property_value study_property_value_after_operation_trigger; Type: TRIGGER; Schema: public; Owner: canopy_admin
--

CREATE TRIGGER study_property_value_after_operation_trigger AFTER DELETE OR UPDATE ON public.study_property_value FOR EACH ROW EXECUTE FUNCTION public.after_operation_trigger_fnc();


--
-- TOC entry 5232 (class 2620 OID 29669)
-- Name: support_request support_request_after_operation_trigger; Type: TRIGGER; Schema: public; Owner: canopy_admin
--

CREATE TRIGGER support_request_after_operation_trigger AFTER DELETE OR UPDATE ON public.support_request FOR EACH ROW EXECUTE FUNCTION public.after_operation_trigger_fnc();


--
-- TOC entry 5234 (class 2620 OID 43563)
-- Name: user_file_upload user_file_upload_after_operation_trigger; Type: TRIGGER; Schema: public; Owner: canopy_admin
--

CREATE TRIGGER user_file_upload_after_operation_trigger AFTER DELETE OR UPDATE ON public.user_file_upload FOR EACH ROW EXECUTE FUNCTION public.after_operation_trigger_fnc();


--
-- TOC entry 5235 (class 2620 OID 46714)
-- Name: user_referrer user_referrer_after_operation_trigger; Type: TRIGGER; Schema: public; Owner: canopy_admin
--

CREATE TRIGGER user_referrer_after_operation_trigger AFTER DELETE OR UPDATE ON public.user_referrer FOR EACH ROW EXECUTE FUNCTION public.after_operation_trigger_fnc();


--
-- TOC entry 5226 (class 2620 OID 29677)
-- Name: user_role user_role_after_operation_trigger; Type: TRIGGER; Schema: public; Owner: canopy_admin
--

CREATE TRIGGER user_role_after_operation_trigger AFTER DELETE OR UPDATE ON public.user_role FOR EACH ROW EXECUTE FUNCTION public.after_operation_trigger_fnc();


--
-- TOC entry 5225 (class 2620 OID 29101)
-- Name: users users_after_operation_trigger; Type: TRIGGER; Schema: public; Owner: canopy_admin
--

CREATE TRIGGER users_after_operation_trigger AFTER DELETE OR UPDATE ON public.users FOR EACH ROW EXECUTE FUNCTION public.after_operation_trigger_fnc();


--
