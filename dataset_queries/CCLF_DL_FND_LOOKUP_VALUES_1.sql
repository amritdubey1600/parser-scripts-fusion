SELECT  'LOOKUP_CODE' KEY,'LANGUAGE'||'~'||'SOURCE_LANG'||'~'||'ROW_ID'||'~'||'MEANING'||'~'||'LOOKUP_CODE'||'~'||'ENABLED_FLAG'||'~'||'START_DATE_ACTIVE'||'~'||'END_DATE_ACTIVE'||'~'||'LOOKUP_TYPE'||'~'||'VIEW_APPLICATION_ID'||'~'||'SET_ID'||'~'||'CREATION_DATE'||'~'||'CREATED_BY'||'~'||'LAST_UPDATE_DATE'||'~'||'LAST_UPDATED_BY'||'~'||'LAST_UPDATE_LOGIN'||'~'||'DESCRIPTION'||'~'||'TAG' LOOKUP_VALUES
FROM DUAL
UNION ALL
SELECT 'LOOKUP_CODE' KEY,LANGUAGE||'~'||SOURCE_LANG||'~'||ROW_ID||'~'||MEANING||'~'||REPLACE(REPLACE(LOOKUP_CODE,CHR(10),''),CHR(13),'')||'~'||ENABLED_FLAG||'~'||REPLACE(REPLACE(START_DATE_ACTIVE,CHR(10),''),CHR(13),'')||'~'||REPLACE(REPLACE(END_DATE_ACTIVE,CHR(10),''),CHR(13),'')||'~'||LOOKUP_TYPE||'~'||VIEW_APPLICATION_ID||'~'||SET_ID||'~'||CREATION_DATE||'~'||REPLACE(REPLACE(CREATED_BY,CHR(10),''),CHR(13),'')||'~'||LAST_UPDATE_DATE||'~'||LAST_UPDATED_BY||'~'||LAST_UPDATE_LOGIN||'~'||REPLACE(REPLACE(REPLACE(DESCRIPTION,CHR(10),''),CHR(13),''),'~',' ')||'~'||TAG
FROM FND_LOOKUP_VALUES a
WHERE ((:P_FROM_DATE IS NOT NULL AND :P_TO_DATE IS NOT NULL AND a.last_update_date between :P_FROM_DATE AND :P_TO_DATE) or
			(:P_FROM_DATE IS NULL AND :P_TO_DATE IS NULL AND  a.last_update_date >(SELECT MAX(ERH.processstart)
                                         FROM ess_request_history ERH
                                             ,ess_request_property ERP
                                        WHERE ERH.requestid = ERP.requestid
                                          AND ERH.definition = 'JobDefinition://oracle/apps/ess/custom/cclf/CCLF_DL_Fnd_Lookup_Types'
                                          AND ERH.executable_status = 'SUCCEEDED'
                                          AND ERP.name = 'submit.argument3'
                             	          AND ERP.value IS NOT NULL)))