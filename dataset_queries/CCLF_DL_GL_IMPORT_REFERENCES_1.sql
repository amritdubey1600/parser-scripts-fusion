SELECT 'IMPORT_REF' key,
'JE_BATCH_ID'||'~'||'JE_HEADER_ID'||'~'||'JE_LINE_NUM'||'~'||'CREATION_DATE'||'~'||'CREATED_BY'||'~'||'LAST_UPDATE_DATE'||'~'||'LAST_UPDATED_BY'||'~'||'LAST_UPDATE_LOGIN'||'~'||'OBJECT_VERSION_NUMBER'||'~'||'REFERENCE_1'||'~'||'REFERENCE_2'||'~'||'REFERENCE_3'||'~'||'REFERENCE_4'||'~'||'REFERENCE_5'||'~'||'REFERENCE_6'||'~'||'REFERENCE_7'||'~'||'REFERENCE_8'||'~'||
'REFERENCE_9'||'~'||'REFERENCE_10'||'~'||'SUBLEDGER_DOC_SEQUENCE_ID'||'~'||'SUBLEDGER_DOC_SEQUENCE_VALUE'||'~'||'GL_SL_LINK_ID'||'~'||'GL_SL_LINK_TABLE' IMPORT_REF
FROM DUAL	   
UNION ALL
SELECT 'IMPORT_REF' key,
JE_BATCH_ID||'|'||JE_HEADER_ID||'|'||JE_LINE_NUM||'|'||CREATION_DATE||'|'||CREATED_BY||'|'||LAST_UPDATE_DATE||'|'||LAST_UPDATED_BY||'|'||LAST_UPDATE_LOGIN||'|'||OBJECT_VERSION_NUMBER||'|'||REFERENCE_1||'|'||REFERENCE_2||'|'||REFERENCE_3||'|'||REFERENCE_4||'|'||REFERENCE_5||'|'||REFERENCE_6||'|'||REFERENCE_7||'|'||REFERENCE_8||'|'||
REFERENCE_9||'|'||REFERENCE_10||'|'||SUBLEDGER_DOC_SEQUENCE_ID||'|'||SUBLEDGER_DOC_SEQUENCE_VALUE||'|'||GL_SL_LINK_ID||'|'||GL_SL_LINK_TABLE
FROM GL_IMPORT_REFERENCES a
where ((:P_FROM_DATE IS NOT NULL AND :P_TO_DATE IS NOT NULL AND a.last_update_date between :P_FROM_DATE AND :P_TO_DATE) or
			(:P_FROM_DATE IS NULL AND :P_TO_DATE IS NULL AND a.last_update_date > (SELECT MAX(ERH.processstart)
                                         FROM ess_request_history ERH
                                             ,ess_request_property ERP
                                        WHERE ERH.requestid = ERP.requestid
                                          AND ERH.definition = 'JobDefinition://oracle/apps/ess/custom/cclf/CCLF_DL_GL_Import'
                                          AND ERH.executable_status = 'SUCCEEDED'
                                          AND ERP.name = 'submit.argument1'
                             	          AND ERP.value IS  NULL)))
ORDER BY 1 DESC