SELECT 'JE_BATCHES' key,
'JE_BATCH_ID'||'~'||'NAME'||'~'||'STATUS'||'~'||'STATUS_VERIFIED'||'~'||'ACTUAL_FLAG'||'~'||'DEFAULT_EFFECTIVE_DATE'||'~'||'DEFAULT_PERIOD_NAME'||'~'||'EARLIEST_POSTABLE_DATE'||'~'||'POSTED_DATE'||'~'||'DATE_CREATED'||'~'||'DESCRIPTION'||'~'||'RUNNING_TOTAL_DR'||'~'||'RUNNING_TOTAL_CR'||'~'||
'RUNNING_TOTAL_ACCOUNTED_DR'||'~'||'RUNNING_TOTAL_ACCOUNTED_CR'||'~'||'FUNDS_STATUS_CODE'||'~'||'BUDGETARY_CONTROL_STATUS'||'~'||'POSTING_RUN_ID'||'~'||'REQUEST_ID'||'~'||'AVERAGE_JOURNAL_FLAG'||'~'||'APPROVAL_STATUS_CODE'||'~'||'CHART_OF_ACCOUNTS_ID'||'~'||
'PERIOD_SET_NAME'||'~'||'ACCOUNTED_PERIOD_TYPE'||'~'||'GROUP_ID,CREATION_DATE'||'~'||'JE_SOURCE'||'~'||'CREATED_BY'||'~'||'LAST_UPDATE_DATE'||'~'||'LAST_UPDATED_BY'||'~'||'LAST_UPDATE_LOGIN'||'~'||
'OBJECT_VERSION_NUMBER'||'~'||'APPROVER_EMPLOYEE_ID'||'~'||'PARENT_JE_BATCH_ID' JE_BATCHES
FROM DUAL
UNION ALL
SELECT 'JE_BATCHES' key,
JE_BATCH_ID||'|'||REPLACE(REPLACE(REPLACE(NAME,CHR(10),''),CHR(13),''),'|','')||'|'||REPLACE(REPLACE(REPLACE(STATUS,CHR(10),''),CHR(13),''),'|','')||'|'||STATUS_VERIFIED||'|'||ACTUAL_FLAG||'|'||DEFAULT_EFFECTIVE_DATE||'|'||DEFAULT_PERIOD_NAME||'|'||EARLIEST_POSTABLE_DATE||'|'||POSTED_DATE||'|'||DATE_CREATED||'|'||REPLACE(REPLACE(REPLACE(DESCRIPTION,CHR(10),''),CHR(13),''),'|','')||'|'||RUNNING_TOTAL_DR||'|'||RUNNING_TOTAL_CR||'|'||
RUNNING_TOTAL_ACCOUNTED_DR||'|'||RUNNING_TOTAL_ACCOUNTED_CR||'|'||FUNDS_STATUS_CODE||'|'||BUDGETARY_CONTROL_STATUS||'|'||POSTING_RUN_ID||'|'||REQUEST_ID||'|'||AVERAGE_JOURNAL_FLAG||'|'||APPROVAL_STATUS_CODE||'|'||CHART_OF_ACCOUNTS_ID||'|'||
PERIOD_SET_NAME||'|'||ACCOUNTED_PERIOD_TYPE||'|'||GROUP_ID||'|'||CREATION_DATE||'|'||JE_SOURCE||'|'||CREATED_BY||'|'||LAST_UPDATE_DATE||'|'||LAST_UPDATED_BY||'|'||LAST_UPDATE_LOGIN||'|'||
OBJECT_VERSION_NUMBER||'|'||APPROVER_EMPLOYEE_ID||'|'||PARENT_JE_BATCH_ID
FROM GL_JE_BATCHES a
/* where ((:P_FROM_DATE IS NOT NULL AND :P_TO_DATE IS NOT NULL AND a.last_update_date between :P_FROM_DATE AND :P_TO_DATE) or
			(:P_FROM_DATE IS NULL AND :P_TO_DATE IS NULL AND a.last_update_date > (SELECT MAX(ERH.processstart)
                                         FROM ess_request_history ERH
                                             ,ess_request_property ERP
                                        WHERE ERH.requestid = ERP.requestid
                                          AND ERH.definition = 'JobDefinition://oracle/apps/ess/custom/cclf/CCLF_DL_GL_Batches'
                                          AND ERH.executable_status = 'SUCCEEDED'
                                          AND ERP.name = 'submit.argument1'
                             	          AND ERP.value IS  NULL)))
ORDER BY 1 DESC */
where last_update_date between '2016-06-22 05:58:46.662' and '2016-06-24 03:45:08.179'