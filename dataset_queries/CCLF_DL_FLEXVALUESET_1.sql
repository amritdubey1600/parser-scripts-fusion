SELECT 'LOOKUP_CODE' key,'CREATION_DATE'||'~'||'CREATED_BY'||'~'||'LAST_UPDATE_DATE'||'~'||'LAST_UPDATED_BY'||'~'||'LAST_UPDATE_LOGIN'||'~'||'FLEX_VALUE_SET_ID'||'~'||'FLEX_VALUE_SET_NAME'||'~'||'DESCRIPTION'||'~'||'PROTECTED_FLAG'||'~'||'SECURITY_ENABLED_FLAG'||'~'||'VALIDATION_TYPE'||'~'||'LONGLIST_FLAG'||'~'||'FORMAT_TYPE'||'~'||'ALPHANUMERIC_ALLOWED_FLAG'||'~'||'UPPERCASE_ONLY_FLAG'||'~'||'NUMERIC_MODE_ENABLED_FLAG'||'~'||'MAXIMUM_SIZE'||'~'||'NUMBER_PRECISION'||'~'||'MAXIMUM_VALUE'||'~'||'MINIMUM_VALUE'||'~'||'PARENT_FLEX_VALUE_SET_ID'  VALUE_SET 
FROM DUAL
UNION ALL
SELECT 'LOOKUP_CODE' key,CREATION_DATE||'|'||CREATED_BY||'|'||LAST_UPDATE_DATE||'|'||LAST_UPDATED_BY||'|'||LAST_UPDATE_LOGIN||'|'||FLEX_VALUE_SET_ID||'|'||FLEX_VALUE_SET_NAME||'|'||REPLACE(DESCRIPTION , '|', '') ||'|'||PROTECTED_FLAG||'|'||
SECURITY_ENABLED_FLAG||'|'||VALIDATION_TYPE||'|'||LONGLIST_FLAG||'|'||FORMAT_TYPE||'|'||ALPHANUMERIC_ALLOWED_FLAG||'|'||UPPERCASE_ONLY_FLAG||'|'||NUMERIC_MODE_ENABLED_FLAG||'|'||MAXIMUM_SIZE||'|'||
NUMBER_PRECISION||'|'||MAXIMUM_VALUE||'|'||MINIMUM_VALUE||'|'||PARENT_FLEX_VALUE_SET_ID 
FROM FND_FLEX_VALUE_SETS a
 WHERE  ((:P_FROM_DATE IS NOT NULL AND :P_TO_DATE IS NOT NULL AND a.last_update_date between :P_FROM_DATE AND :P_TO_DATE) or
			(:P_FROM_DATE IS NULL AND :P_TO_DATE IS NULL AND a.last_update_date > (SELECT MAX(ERH.processstart)
                                         FROM ess_request_history ERH
                                             ,ess_request_property ERP
                                        WHERE ERH.requestid = ERP.requestid
                                          AND ERH.definition = 'JobDefinition://oracle/apps/ess/custom/cclf/CCLF_DL_Flexvalueset'
                                          AND ERH.executable_status = 'SUCCEEDED'
                                          AND ERP.name = 'submit.argument3'
                             	          AND ERP.value IS NOT NULL))) 
--ORDER BY 1 DESC