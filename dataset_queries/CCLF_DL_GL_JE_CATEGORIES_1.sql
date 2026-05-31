SELECT 'JE_CATE' key,
'DESCRIPTION'||'~'||'CREATION_DATE'||'~'||'CREATED_BY'||'~'||'LAST_UPDATE_DATE'||'~'||'LAST_UPDATED_BY'||'~'||'LAST_UPDATE_LOGIN'||'~'||'OBJECT_VERSION_NUMBER'||'~'||'JE_CATEGORY_NAME'||'~'||'USER_JE_CATEGORY_NAME'||'~'||'LANGUAGE'||'~'||'SOURCE_LANG' JE_CATE
FROM dual
union all
SELECT 'JE_CATE' key,
REPLACE(DESCRIPTION , '|', '')  ||'|'||CREATION_DATE||'|'||CREATED_BY||'|'||LAST_UPDATE_DATE||'|'||LAST_UPDATED_BY||'|'||LAST_UPDATE_LOGIN||'|'||OBJECT_VERSION_NUMBER||'|'||JE_CATEGORY_NAME||'|'||USER_JE_CATEGORY_NAME||'|'||LANGUAGE||'|'||SOURCE_LANG
FROM GL_JE_CATEGORIES_TL a
WHERE ((:P_FROM_DATE IS NOT NULL AND :P_TO_DATE IS NOT NULL AND a.last_update_date between :P_FROM_DATE AND :P_TO_DATE) or
			(:P_FROM_DATE IS NULL AND :P_TO_DATE IS NULL AND a.last_update_date > (SELECT MAX(ERH.processstart)
                                         FROM ess_request_history ERH
                                             ,ess_request_property ERP
                                        WHERE ERH.requestid = ERP.requestid 
                                          AND ERH.definition = 'JobDefinition://oracle/apps/ess/custom/cclf/CCLF_DL_GL_Catogories'
                                          AND ERH.executable_status = 'SUCCEEDED'
                                          AND ERP.name = 'submit.argument3'
                             	          AND ERP.value IS NOT NULL)))