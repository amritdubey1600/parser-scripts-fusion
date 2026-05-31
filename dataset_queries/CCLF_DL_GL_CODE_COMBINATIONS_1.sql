SELECT 'CODE_COMBI' key,
'CODE_COMBINATION_ID'||'~'||'LAST_UPDATE_DATE'||'~'||'LAST_UPDATED_BY'||'~'||'CHART_OF_ACCOUNTS_ID'||'~'||'DETAIL_POSTING_ALLOWED_FLAG'||'~'||'DETAIL_BUDGETING_ALLOWED_FLAG'||'~'||'ACCOUNT_TYPE'||'~'||'ENABLED_FLAG'||'~'||'SUMMARY_FLAG'||'~'|| 
'SEGMENT1'||'~'||'SEGMENT2'||'~'||'SEGMENT3'||'~'||'SEGMENT4'||'~'||'SEGMENT5'||'~'||'SEGMENT6'||'~'||'SEGMENT7'||'~'||'SEGMENT8'||'~'||'SEGMENT9'||'~'||'SEGMENT10'||'~'||'SEGMENT11'||'~'||'SEGMENT13'||'~'||'SEGMENT14'||'~'||'SEGMENT15'||'~'||
'START_DATE_ACTIVE'||'~'||'END_DATE_ACTIVE'||'~'||'JGZZ_RECON_FLAG'||'~'||'OBJECT_VERSION_NUMBER'||'~'||'CREATION_DATE'||'~'||'CREATED_BY'||'~'||'LAST_UPDATE_LOGIN'||'~'||'TEMPLATE_ID'||'~'||'REFERENCE1'||'~'||'REFERENCE2'||'~'||'REFERENCE3'||'~'||'REFERENCE4'||'~'||'REFERENCE5' GL_CODE_COMBINATIONS
FROM DUAL
UNION ALL
SELECT 'CODE_COMBI' key,
CODE_COMBINATION_ID||'|'||LAST_UPDATE_DATE||'|'||LAST_UPDATED_BY||'|'||CHART_OF_ACCOUNTS_ID||'|'||DETAIL_POSTING_ALLOWED_FLAG||'|'||DETAIL_BUDGETING_ALLOWED_FLAG||'|'||ACCOUNT_TYPE||'|'||ENABLED_FLAG||'|'||SUMMARY_FLAG||'|'|| 
SEGMENT1||'|'||SEGMENT2||'|'||SEGMENT3||'|'||SEGMENT4||'|'||SEGMENT5||'|'||SEGMENT6||'|'||SEGMENT7||'|'||SEGMENT8||'|'||SEGMENT9||'|'||SEGMENT10||'|'||SEGMENT11||'|'||SEGMENT13||'|'||SEGMENT14||'|'||SEGMENT15||'|'||
START_DATE_ACTIVE||'|'||END_DATE_ACTIVE||'|'||JGZZ_RECON_FLAG||'|'||OBJECT_VERSION_NUMBER||'|'||CREATION_DATE||'|'||CREATED_BY||'|'||LAST_UPDATE_LOGIN||'|'||TEMPLATE_ID||'|'||REFERENCE1||'|'||REFERENCE2||'|'||REFERENCE3||'|'||REFERENCE4||'|'||REFERENCE5
FROM GL_CODE_COMBINATIONS a
 WHERE ((:P_FROM_DATE IS NOT NULL AND :P_TO_DATE IS NOT NULL AND a.last_update_date between :P_FROM_DATE AND :P_TO_DATE) or
			(:P_FROM_DATE IS NULL AND :P_TO_DATE IS NULL AND  a.last_update_date > (SELECT MAX(ERH.processstart)
                                         FROM ess_request_history ERH
                                             ,ess_request_property ERP
                                        WHERE ERH.requestid = ERP.requestid
                                          AND ERH.definition = 'JobDefinition://oracle/apps/ess/custom/cclf/CCLF_DL_GL_Code'
                                          AND ERH.executable_status = 'SUCCEEDED'
                                          AND ERP.name = 'submit.argument3'
                             	          AND ERP.value IS NOT NULL)))