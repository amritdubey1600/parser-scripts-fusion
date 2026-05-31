SELECT 'FLEX_CODE' key,'APPLICATION_ID'||'~'||'ID_FLEX_CODE'||'~'||'ID_FLEX_NUM'||'~'||'APPLICATION_COLUMN_NAME'||'~'||'SEGMENT_ATTRIBUTE_TYPE'||'~'||'ATTRIBUTE_VALUE'||'~'||'CREATION_DATE'||'~'||'CREATED_BY'||'~'||'LAST_UPDATE_DATE'||'~'||'LAST_UPDATED_BY'||'~'||'LAST_UPDATE_LOGIN' SEGMENT_ATTRIBUTE_VALUES
FROM DUAL		
UNION ALL
SELECT 'FLEX_CODE' key,APPLICATION_ID||'|'||ID_FLEX_CODE||'|'||ID_FLEX_NUM||'|'||APPLICATION_COLUMN_NAME||'|'||SEGMENT_ATTRIBUTE_TYPE||'|'||ATTRIBUTE_VALUE||'|'||CREATION_DATE||'|'||CREATED_BY||'|'||LAST_UPDATE_DATE||'|'||LAST_UPDATED_BY||'|'||LAST_UPDATE_LOGIN
FROM FND_SEGMENT_ATTRIBUTE_VALUES a
WHERE ((:P_FROM_DATE IS NOT NULL AND :P_TO_DATE IS NOT NULL AND a.last_update_date between :P_FROM_DATE AND :P_TO_DATE) or
			(:P_FROM_DATE IS NULL AND :P_TO_DATE IS NULL AND  a.last_update_date >(SELECT MAX(ERH.processstart)
                                         FROM ess_request_history ERH
                                             ,ess_request_property ERP
                                        WHERE ERH.requestid = ERP.requestid
                                          AND ERH.definition = 'JobDefinition://oracle/apps/ess/custom/cclf/CCLF_DL_Segment_Attribute'
                                          AND ERH.executable_status = 'SUCCEEDED'
                                          AND ERP.name = 'submit.argument3'
                             	          AND ERP.value IS NOT NULL)))