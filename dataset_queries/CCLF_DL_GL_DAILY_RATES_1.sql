SELECT 'DAILY_RATES' key,'LAST_UPDATE_DATE'||'~'||'LAST_UPDATED_BY'||'~'||'FROM_CURRENCY'||'~'||'TO_CURRENCY'||'~'||'CONVERSION_DATE'||'~'||'CONVERSION_RATE'||'~'||'STATUS_CODE'||'~'||'RATE_SOURCE_CODE'||'~'||'OBJECT_VERSION_NUMBER'||'~'||'CREATION_DATE'||'~'||'CREATED_BY'||'~'||'CONVERSION_TYPE'||'~'||
'LAST_UPDATE_LOGIN'||'~'||'ENTERPRISE_ID' GL_DAILY_RATES
FROM DUAL 
UNION ALL
SELECT 'DAILY_RATES' key,LAST_UPDATE_DATE||'|'||LAST_UPDATED_BY||'|'||FROM_CURRENCY||'|'||TO_CURRENCY||'|'||CONVERSION_DATE||'|'||CONVERSION_RATE||'|'||STATUS_CODE||'|'||RATE_SOURCE_CODE||'|'||OBJECT_VERSION_NUMBER||'|'||CREATION_DATE||'|'||CREATED_BY||'|'||CONVERSION_TYPE||'|'||
LAST_UPDATE_LOGIN||'|'||ENTERPRISE_ID
FROM GL_DAILY_RATES a
where ((:P_FROM_DATE IS NOT NULL AND :P_TO_DATE IS NOT NULL AND a.last_update_date between :P_FROM_DATE AND :P_TO_DATE) or
			(:P_FROM_DATE IS NULL AND :P_TO_DATE IS NULL AND a.last_update_date > (SELECT MAX(ERH.processstart)
                                         FROM ess_request_history ERH
                                             ,ess_request_property ERP
                                        WHERE ERH.requestid = ERP.requestid
                                          AND ERH.definition = 'JobDefinition://oracle/apps/ess/custom/cclf/CCLF_DL_GL_Daily'
                                          AND ERH.executable_status = 'SUCCEEDED'
                                          AND ERP.name = 'submit.argument1'
                             	          AND ERP.value IS  NULL)))