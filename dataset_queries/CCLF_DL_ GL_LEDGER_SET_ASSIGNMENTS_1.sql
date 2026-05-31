SELECT 'LEDGER_SET' key,
'CREATION_DATE'||'~'||'CREATED_BY'||'~'||'LAST_UPDATE_DATE'||'~'||'LAST_UPDATED_BY'||'~'||'LAST_UPDATE_LOGIN'||'~'||'OBJECT_VERSION_NUMBER'||'~'||'LEDGER_SET_ID'||'~'||
'LEDGER_ID'||'~'||'START_DATE'||'~'||'END_DATE'||'~'||'STATUS_CODE' SET_ASSIGNMENTS
FROM DUAL
UNION ALL
SELECT 'LEDGER_SET' key,
CREATION_DATE||'|'||CREATED_BY||'|'||LAST_UPDATE_DATE||'|'||LAST_UPDATED_BY||'|'||LAST_UPDATE_LOGIN||'|'||OBJECT_VERSION_NUMBER||'|'||LEDGER_SET_ID||'|'||
LEDGER_ID||'|'||START_DATE||'|'||END_DATE||'|'||STATUS_CODE
FROM GL_LEDGER_SET_ASSIGNMENTS a
WHERE  ((:P_FROM_DATE IS NOT NULL AND :P_TO_DATE IS NOT NULL AND a.last_update_date between :P_FROM_DATE AND :P_TO_DATE) or
			(:P_FROM_DATE IS NULL AND :P_TO_DATE IS NULL AND a.last_update_date > (SELECT MAX(ERH.processstart)
                                         FROM ess_request_history ERH
                                             ,ess_request_property ERP
                                        WHERE ERH.requestid = ERP.requestid
                                          AND ERH.definition = 'JobDefinition://oracle/apps/ess/custom/cclf/CCLF_DL_GL_Assignments'
                                          AND ERH.executable_status = 'SUCCEEDED'
                                          AND ERP.name = 'submit.argument3'
                             	          AND ERP.value IS NOT NULL)))