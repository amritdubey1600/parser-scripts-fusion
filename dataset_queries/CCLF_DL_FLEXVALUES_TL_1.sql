SELECT 'FLEX_VALUE_ID' key,'FLEX_VALUE_ID'||'~'|| 'CREATION_DATE'||'~'|| 'CREATED_BY'||'~'|| 'LAST_UPDATE_DATE'||'~'|| 'LAST_UPDATED_BY'||'~'|| 'LAST_UPDATE_LOGIN'||'~'|| 'LANGUAGE'||'~'|| 'SOURCE_LANG'||'~'||'DESCRIPTION'||'~'||'FLEX_VALUE_MEANING' FLEXVALUES_TL
FROM DUAL
UNION ALL
SELECT 'FLEX_VALUE_ID' key,FLEX_VALUE_ID||'|'|| CREATION_DATE||'|'|| CREATED_BY||'|'|| LAST_UPDATE_DATE||'|'|| LAST_UPDATED_BY||'|'|| LAST_UPDATE_LOGIN||'|'|| LANGUAGE||'|'|| SOURCE_LANG||'|'||REPLACE(DESCRIPTION , '|', '')  ||'|'||FLEX_VALUE_MEANING
FROM FND_FLEX_VALUES_TL a
 WHERE ((:P_FROM_DATE IS NOT NULL AND :P_TO_DATE IS NOT NULL AND a.last_update_date between :P_FROM_DATE AND :P_TO_DATE) or
			(:P_FROM_DATE IS NULL AND :P_TO_DATE IS NULL AND  a.last_update_date > (SELECT MAX(ERH.processstart)
                                         FROM ess_request_history ERH
                                             ,ess_request_property ERP
                                        WHERE ERH.requestid = ERP.requestid
                                          AND ERH.definition = 'JobDefinition://oracle/apps/ess/custom/cclf/CCLF_DL_Flexvalues_Tl'
                                          AND ERH.executable_status = 'SUCCEEDED'
                                          AND ERP.name = 'submit.argument3'
                             	          AND ERP.value IS NOT NULL)))