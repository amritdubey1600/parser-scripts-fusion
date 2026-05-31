SELECT 'TERRITORY_CODE' key,'ENTERPRISE_ID'||'~'||'TERRITORY_CODE'||'~'||'ISO_NUMERIC_CODE'||'~'||'ISO_TERRITORY_CODE'||'~'||'OBSOLETE_FLAG'||'~'||'ENABLED_FLAG'||'~'||'EU_CODE'||'~'||'CURRENCY_CODE'||'~'||'CREATION_DATE'||'~'||'CREATED_BY'||'~'||'LAST_UPDATE_DATE'||'~'||'LAST_UPDATED_BY'||'~'||'LAST_UPDATE_LOGIN'||'~'||'ALTERNATE_TERRITORY_CODE'||'~'||'NLS_TERRITORY' FND_TERRITORIES
FROM DUAL
UNION ALL
SELECT 'TERRITORY_CODE' key,ENTERPRISE_ID||'|'||TERRITORY_CODE||'|'||ISO_NUMERIC_CODE||'|'||ISO_TERRITORY_CODE||'|'||OBSOLETE_FLAG||'|'||ENABLED_FLAG||'|'||EU_CODE||'|'||CURRENCY_CODE||'|'||CREATION_DATE||'|'||CREATED_BY||'|'||LAST_UPDATE_DATE||'|'||LAST_UPDATED_BY||'|'||LAST_UPDATE_LOGIN||'|'||ALTERNATE_TERRITORY_CODE||'|'||NLS_TERRITORY
FROM FND_TERRITORIES a
WHERE ((:P_FROM_DATE IS NOT NULL AND :P_TO_DATE IS NOT NULL AND a.last_update_date between :P_FROM_DATE AND :P_TO_DATE) or
			(:P_FROM_DATE IS NULL AND :P_TO_DATE IS NULL AND  a.last_update_date >(SELECT MAX(ERH.processstart)
                                         FROM ess_request_history ERH
                                             ,ess_request_property ERP
                                        WHERE ERH.requestid = ERP.requestid
                                          AND ERH.definition = 'JobDefinition://oracle/apps/ess/custom/cclf/CCLF_DL_Territories'
                                          AND ERH.executable_status = 'SUCCEEDED'
                                          AND ERP.name = 'submit.argument3'
                             	          AND ERP.value IS NOT NULL)))