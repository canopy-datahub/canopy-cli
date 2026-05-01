-- TOC entry 486 (class 1255 OID 28416)
-- Name: after_operation_trigger_fnc(); Type: FUNCTION; Schema: public; Owner: canopy_admin
--

CREATE FUNCTION public.after_operation_trigger_fnc() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
            DECLARE
                _operated_at timestamp := CURRENT_TIMESTAMP AT TIME ZONE 'UTC';
				_history_table_name text :=  'canopy_history.' || TG_TABLE_NAME || '_history';
				_column_name text;
				_new_h hstore = hstore(new);
    			_old_h hstore = hstore(old);
				_created_by text;
				_modified_by text;

            BEGIN
				IF to_jsonb(NEW) ? 'created_by' THEN
					_created_by  := new."created_by";
				END IF;
				IF  (to_jsonb(NEW) ? 'uploaded_by') THEN
					_created_by  := new."uploaded_by";
				END IF;
				IF to_jsonb(NEW) ? 'modified_by' THEN
					_modified_by := new."modified_by";
				END IF;
				IF to_jsonb(NEW) ? 'updated_by' THEN
					_modified_by := new."updated_by";
				END IF;
				IF (TG_OP = 'DELETE') THEN
					FOREACH _column_name in array akeys(_old_h)
					LOOP
						IF _column_name Not in('id','modified_at','modified_by','updated_at','updated_by' ) and  _old_h->_column_name is NOT NULL THEN
							EXECUTE format( 'INSERT INTO %s (id, column_name, old_value, new_value, operation, operated_at, operated_by)
							VALUES (%s, %L, %L, null, ''D'', %L,  ''9999'');', _history_table_name, old.id, _column_name, _old_h->_column_name::TEXT, _operated_at);
						END IF;
					END LOOP;
					RETURN NULL;
				ELSIF (TG_OP = 'UPDATE') THEN
    				FOREACH _column_name in array akeys(_new_h)
					LOOP
        				IF _column_name Not in('id', 'modified_at','modified_by','updated_at','updated_by') and (_new_h->_column_name IS DISTINCT from _old_h->_column_name) then
            				EXECUTE format( 'INSERT INTO %s (id, column_name, old_value, new_value, operation, operated_at, operated_by)
							VALUES (%s, %L, %L, %L, ''U'', %L, %L);', _history_table_name, old.id, _column_name, _old_h->_column_name::TEXT, _new_h->_column_name::TEXT, _operated_at, _modified_by);
    					END IF;
    				END LOOP;
				END IF;
				RETURN NEW;

				EXCEPTION
    			WHEN NO_DATA_FOUND THEN
      			RAISE NOTICE 'No data found';

   				WHEN OTHERS THEN
      			RAISE NOTICE '% %', SQLERRM, SQLSTATE;
			END;
$$;


ALTER FUNCTION public.after_operation_trigger_fnc() OWNER TO canopy_admin;

--
-- TOC entry 465 (class 1255 OID 28415)
-- Name: before_operation_trigger_fnc(); Type: FUNCTION; Schema: public; Owner: canopy_admin
--

CREATE FUNCTION public.before_operation_trigger_fnc() RETURNS trigger
    LANGUAGE plpgsql
    AS $$

        BEGIN
			IF (TG_OP = 'DELETE') THEN
				RETURN NULL;
			ELSIF (TG_OP = 'UPDATE') THEN
				IF to_jsonb(NEW) ? 'modified_at' THEN
						NEW.modified_at := CURRENT_TIMESTAMP AT TIME ZONE 'UTC';
				END IF;
				IF to_jsonb(NEW) ? 'updated_at' THEN
						NEW.updated_at := CURRENT_TIMESTAMP AT TIME ZONE 'UTC';
				END IF;
			ELSIF (TG_OP = 'INSERT' ) THEN
				IF to_jsonb(NEW) ? 'created_at' THEN
					NEW.created_at := CURRENT_TIMESTAMP AT TIME ZONE 'UTC';
				END IF;
				IF  (to_jsonb(NEW) ? 'uploaded_at') THEN
					NEW.uploaded_at := CURRENT_TIMESTAMP AT TIME ZONE 'UTC';
				END IF;

			END IF;

			RETURN NEW;

  			EXCEPTION
    			WHEN NO_DATA_FOUND THEN
      			RAISE NOTICE 'No data found';

   				WHEN OTHERS THEN
      			RAISE NOTICE '% %', SQLERRM, SQLSTATE;

			END;
$$;


ALTER FUNCTION public.before_operation_trigger_fnc() OWNER TO canopy_admin;

--
-- TOC entry 524 (class 1255 OID 61772)
-- Name: get_filename(text); Type: FUNCTION; Schema: public; Owner: canopy_admin
--

CREATE FUNCTION public.get_filename(_path text) RETURNS text
    LANGUAGE plpgsql IMMUTABLE STRICT
    AS $$
begin
  _path := reverse(_path);
  _path := nullif((substring(_path, 0, strpos(_path, '/'))), '');
  return nullif(reverse(_path), '');
end;
$$;


ALTER FUNCTION public.get_filename(_path text) OWNER TO canopy_admin;

--
