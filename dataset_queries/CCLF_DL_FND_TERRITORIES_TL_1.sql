SELECT 'TERRITORY' key,'ENTERPRISE_ID'||'~'||'TERRITORY_CODE'||'~'||'CREATION_DATE'||'~'||'CREATED_BY'||'~'||'LAST_UPDATE_DATE'||'~'||'LAST_UPDATED_BY'||'~'||'LAST_UPDATE_LOGIN'||'~'||'LANGUAGE'||'~'||'TERRITORY_SHORT_NAME'||'~'||'DESCRIPTION'||'~'||'SOURCE_LANG' FND_TERRITORIES_TL
FROM DUAL
UNION ALL
SELECT 'TERRITORY' key,ENTERPRISE_ID||'|'||TERRITORY_CODE||'|'||CREATION_DATE||'|'||CREATED_BY||'|'||LAST_UPDATE_DATE||'|'||LAST_UPDATED_BY||'|'||LAST_UPDATE_LOGIN||'|'||LANGUAGE||'|'||TERRITORY_SHORT_NAME||'|'||REPLACE(DESCRIPTION , '|', '')||'|'||SOURCE_LANG
FROM FND_TERRITORIES_TL a
WHERE ((:P_FROM_DATE IS NOT NULL AND :P_TO_DATE IS NOT NULL AND a.last_update_date between :P_FROM_DATE AND :P_TO_DATE) or
			(:P_FROM_DATE IS NULL AND :P_TO_DATE IS NULL AND  a.last_update_date > (SELECT MAX(ERH.processstart)
                                         FROM ess_request_history ERH
                                             ,ess_request_property ERP
                                        WHERE ERH.requestid = ERP.requestid
                                          AND ERH.definition = 'JobDefinition://oracle/apps/ess/custom/cclf/CCLF_DL_Territories_Tl'
                                          AND ERH.executable_status = 'SUCCEEDED'
                                          AND ERP.name = 'submit.argument3'
                             	          AND ERP.value IS NOT NULL)))