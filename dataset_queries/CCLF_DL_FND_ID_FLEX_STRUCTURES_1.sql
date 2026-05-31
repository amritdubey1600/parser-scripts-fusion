SELECT 'FLEX_STRUCTURES' KEY,'ROW_ID'||'~'||'APPLICATION_ID'||'~'||'ID_FLEX_CODE'||'~'||'ID_FLEX_NUM'||'~'||'ENABLED_FLAG'||'~'||'ID_FLEX_STRUCTURE_CODE'||'~'||'FREEZE_FLEX_DEFINITION_FLAG'||'~'||'CONCATENATED_SEGMENT_DELIMITER'||'~'||'DYNAMIC_INSERTS_ALLOWED_FLAG'||'~'||'CROSS_SEGMENT_VALIDATION_FLAG'||'~'||
'FREEZE_STRUCTURED_HIER_FLAG'||'~'||'SHORTHAND_ENABLED_FLAG'||'~'||'SHORTHAND_LENGTH'||'~'||'CREATION_DATE'||'~'||'CREATED_BY'||'~'||'LAST_UPDATE_DATE'||'~'||'LAST_UPDATED_BY'||'~'||'LAST_UPDATE_LOGIN' FLEX_STRUCTURES
FROM DUAL 
UNION ALL
SELECT 'FLEX_STRUCTURES' KEY,ROW_ID||'|'||APPLICATION_ID||'|'||ID_FLEX_CODE||'|'||ID_FLEX_NUM||'|'||ENABLED_FLAG||'|'||ID_FLEX_STRUCTURE_CODE||'|'||FREEZE_FLEX_DEFINITION_FLAG||'|'||CONCATENATED_SEGMENT_DELIMITER||'|'||DYNAMIC_INSERTS_ALLOWED_FLAG||'|'||CROSS_SEGMENT_VALIDATION_FLAG||'|'||
FREEZE_STRUCTURED_HIER_FLAG||'|'||SHORTHAND_ENABLED_FLAG||'|'||SHORTHAND_LENGTH||'|'||CREATION_DATE||'|'||CREATED_BY||'|'||LAST_UPDATE_DATE||'|'||LAST_UPDATED_BY||'|'||LAST_UPDATE_LOGIN
FROM FND_ID_FLEX_STRUCTURES a
WHERE ((:P_FROM_DATE IS NOT NULL AND :P_TO_DATE IS NOT NULL AND a.last_update_date between :P_FROM_DATE AND :P_TO_DATE) or
			(:P_FROM_DATE IS NULL AND :P_TO_DATE IS NULL AND  a.last_update_date > (SELECT MAX(ERH.processstart)
                                         FROM ess_request_history ERH
                                             ,ess_request_property ERP
                                        WHERE ERH.requestid = ERP.requestid
                                          AND ERH.definition = 'JobDefinition://oracle/apps/ess/custom/cclf/CCLF_DL_Flex_Structures'
                                          AND ERH.executable_status = 'SUCCEEDED'
                                          AND ERP.name = 'submit.argument3'
                             	          AND ERP.value IS NOT NULL)))