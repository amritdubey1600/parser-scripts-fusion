SELECT 'CONVERSION_TYPE' KEY,
'LAST_UPDATE_DATE'||'~'||'LAST_UPDATED_BY'||'~'||'DESCRIPTION'||'~'||'OBJECT_VERSION_NUMBER'||'~'||'CREATION_DATE'||'~'||'CREATED_BY'||'~'||'LAST_UPDATE_LOGIN'||'~'||'CONVERSION_TYPE'||'~'||'USER_CONVERSION_TYPE'||'~'||'ENABLE_CROSS_RATE_FLAG'||'~'||'USER_OVERRIDE_CROSS_RATE_FLAG'||'~'||
'ENFORCE_INVERSE_RATE_FLAG'||'~'||'SECURITY_FLAG'||'~'||'PIVOT_CURRENCY_CODE'||'~'||'ENTERPRISE_ID' CONVERSION_TYPES
FROM DUAL
UNION ALL
SELECT 'CONVERSION_TYPE' KEY,
LAST_UPDATE_DATE||'|'||LAST_UPDATED_BY||'|'||REPLACE(DESCRIPTION , '|', '')  ||'|'||OBJECT_VERSION_NUMBER||'|'||CREATION_DATE||'|'||CREATED_BY||'|'||LAST_UPDATE_LOGIN||'|'||CONVERSION_TYPE||'|'||USER_CONVERSION_TYPE||'|'||ENABLE_CROSS_RATE_FLAG||'|'||USER_OVERRIDE_CROSS_RATE_FLAG||'|'||
ENFORCE_INVERSE_RATE_FLAG||'|'||SECURITY_FLAG||'|'||PIVOT_CURRENCY_CODE||'|'||ENTERPRISE_ID
FROM GL_DAILY_CONVERSION_TYPES a
WHERE ((:P_FROM_DATE IS NOT NULL AND :P_TO_DATE IS NOT NULL AND a.last_update_date between :P_FROM_DATE AND :P_TO_DATE) or
			(:P_FROM_DATE IS NULL AND :P_TO_DATE IS NULL AND  a.last_update_date > (SELECT MAX(ERH.processstart)
                                         FROM ess_request_history ERH
                                             ,ess_request_property ERP
                                        WHERE ERH.requestid = ERP.requestid
                                          AND ERH.definition = 'JobDefinition://oracle/apps/ess/custom/cclf/CCLF_DL_GL_Conversion'
                                          AND ERH.executable_status = 'SUCCEEDED'
                                          AND ERP.name = 'submit.argument3'
                             	          AND ERP.value IS NOT NULL)))