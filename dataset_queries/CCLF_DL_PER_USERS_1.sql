SELECT 'PERSON_ID' key,'USER_ID'||'~'||'ACTIVE_FLAG'||'~'||'START_DATE'||'~'||'END_DATE'||'~'||'USERNAME'||'~'||'CREATED_BY'||'~'||'CREATION_DATE'||'~'||'LAST_UPDATED_BY'||'~'||'LAST_UPDATE_DATE'||'~'||'PERSON_ID' PER_USER
FROM dual
UNION ALL
SELECT 'PERSON_ID' key,USER_ID||'|'||ACTIVE_FLAG||'|'||START_DATE||'|'||END_DATE||'|'||USERNAME||'|'||CREATED_BY||'|'||CREATION_DATE||'|'||LAST_UPDATED_BY||'|'||LAST_UPDATE_DATE||'|'||PERSON_ID
FROM PER_USERS a
where ((:P_FROM_DATE IS NOT NULL AND :P_TO_DATE IS NOT NULL AND a.last_update_date between :P_FROM_DATE AND :P_TO_DATE) or
			(:P_FROM_DATE IS NULL AND :P_TO_DATE IS NULL AND  a.last_update_date > (SELECT MAX(ERH.processstart)
                                         FROM ess_request_history ERH
                                             ,ess_request_property ERP
                                        WHERE ERH.requestid = ERP.requestid
                                          AND ERH.definition = 'JobDefinition://oracle/apps/ess/custom/cclf/CCLF_DL_Per_Users'
                                          AND ERH.executable_status = 'SUCCEEDED'
                                          AND ERP.name = 'submit.argument3'
                             	          AND ERP.value IS NOT  NULL)))