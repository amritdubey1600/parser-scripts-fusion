SELECT 'FLEX_SEGMENTS' key,'ROW_ID'||'~'||'APPLICATION_ID'||'~'||'ID_FLEX_CODE'||'~'||'ID_FLEX_NUM'||'~'||'APPLICATION_COLUMN_NAME'||'~'||'SEGMENT_NAME'||'~'||'SEGMENT_NUM'||'~'||'ENABLED_FLAG'||'~'||'REQUIRED_FLAG'||'~'||'FLEX_VALUE_SET_ID'||'~'||'SECURITY_ENABLED_FLAG'||'~'||'DISPLAY_FLAG'||'~'||'DISPLAY_SIZE'||'~'||'MAXIMUM_DESCRIPTION_LEN'||'~'||'CONCATENATION_DESCRIPTION_LEN'||'~'||'APPLICATION_COLUMN_INDEX_FLAG'||'~'||'CREATION_DATE'||'~'||'CREATED_BY'||'~'||'LAST_UPDATE_DATE'||'~'||'LAST_UPDATED_BY'||'~'||
'LAST_UPDATE_LOGIN'||'~'||'DEFAULT_TYPE'||'~'||'DEFAULT_VALUE'||'~'||'RANGE_CODE'||'~'||'ADDITIONAL_WHERE_CLAUSE' FLEX_SEGMENTS
FROM DUAL
UNION ALL
SELECT 'FLEX_SEGMENTS' key,ROW_ID||'|'||APPLICATION_ID||'|'||ID_FLEX_CODE||'|'||ID_FLEX_NUM||'|'||APPLICATION_COLUMN_NAME||'|'||SEGMENT_NAME||'|'||SEGMENT_NUM||'|'||ENABLED_FLAG||'|'||REQUIRED_FLAG||'|'||FLEX_VALUE_SET_ID||'|'||SECURITY_ENABLED_FLAG||'|'||DISPLAY_FLAG||'|'||DISPLAY_SIZE||'|'||MAXIMUM_DESCRIPTION_LEN||'|'||CONCATENATION_DESCRIPTION_LEN||'|'||APPLICATION_COLUMN_INDEX_FLAG||'|'||CREATION_DATE||'|'||CREATED_BY||'|'||LAST_UPDATE_DATE||'|'||LAST_UPDATED_BY||'|'||
LAST_UPDATE_LOGIN||'|'||   DEFAULT_TYPE||'|'||DEFAULT_VALUE||'|'||RANGE_CODE||'|'||ADDITIONAL_WHERE_CLAUSE
FROM FND_ID_FLEX_SEGMENTS a
 WHERE ((:P_FROM_DATE IS NOT NULL AND :P_TO_DATE IS NOT NULL AND a.last_update_date between :P_FROM_DATE AND :P_TO_DATE) or
			(:P_FROM_DATE IS NULL AND :P_TO_DATE IS NULL AND a.last_update_date >(SELECT MAX(ERH.processstart)
                                         FROM ess_request_history ERH
                                             ,ess_request_property ERP
                                        WHERE ERH.requestid = ERP.requestid
                                          AND ERH.definition = 'JobDefinition://oracle/apps/ess/custom/cclf/CCLF_DL_Flex_Segment'
                                          AND ERH.executable_status = 'SUCCEEDED'
                                          AND ERP.name = 'submit.argument3'
                             	          AND ERP.value IS NOT NULL)))