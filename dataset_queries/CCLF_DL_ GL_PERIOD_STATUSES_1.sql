SELECT 'PERIOD' key,
'CREATION_DATE'||'~'||'CREATED_BY'||'~'||'LAST_UPDATE_DATE'||'~'||'LAST_UPDATED_BY'||'~'||'LAST_UPDATE_LOGIN'||'~'||'OBJECT_VERSION_NUMBER'||'~'||'LEDGER_ID'||'~'||'APPLICATION_ID'||'~'||'SET_OF_BOOKS_ID'||'~'||'PERIOD_NAME'||'~'||'CLOSING_STATUS'||'~'||'START_DATE'||'~'||'END_DATE'||'~'||'YEAR_START_DATE'||'~'||'QUARTER_NUM'||'~'||'QUARTER_START_DATE'||'~'||
'PERIOD_TYPE'||'~'||'PERIOD_YEAR'||'~'||'EFFECTIVE_PERIOD_NUM'||'~'||'PERIOD_NUM'||'~'||'ADJUSTMENT_PERIOD_FLAG'||'~'||'MIGRATION_STATUS_CODE'||'~'||'ELIMINATION_CONFIRMED_FLAG' PERIOD_STATUSES
FROM DUAL	
UNION ALL
SELECT 'PERIOD' key, 
CREATION_DATE||'|'||CREATED_BY||'|'||LAST_UPDATE_DATE||'|'||LAST_UPDATED_BY||'|'||LAST_UPDATE_LOGIN||'|'||OBJECT_VERSION_NUMBER||'|'||LEDGER_ID||'|'||APPLICATION_ID||'|'||SET_OF_BOOKS_ID||'|'||PERIOD_NAME||'|'||CLOSING_STATUS||'|'||START_DATE||'|'||END_DATE||'|'||YEAR_START_DATE||'|'||QUARTER_NUM||'|'||QUARTER_START_DATE||'|'||
PERIOD_TYPE||'|'||PERIOD_YEAR||'|'||EFFECTIVE_PERIOD_NUM||'|'||PERIOD_NUM||'|'||ADJUSTMENT_PERIOD_FLAG||'|'||MIGRATION_STATUS_CODE||'|'||ELIMINATION_CONFIRMED_FLAG
FROM GL_PERIOD_STATUSES a
WHERE ((:P_FROM_DATE IS NOT NULL AND :P_TO_DATE IS NOT NULL AND a.last_update_date between :P_FROM_DATE AND :P_TO_DATE) or
			(:P_FROM_DATE IS NULL AND :P_TO_DATE IS NULL AND a.last_update_date > (SELECT MAX(ERH.processstart)
                                         FROM ess_request_history ERH
                                             ,ess_request_property ERP
                                        WHERE ERH.requestid = ERP.requestid
                                          AND ERH.definition = 'JobDefinition://oracle/apps/ess/custom/cclf/CCLF_DL_GL_Period'
                                          AND ERH.executable_status = 'SUCCEEDED'
                                          AND ERP.name = 'submit.argument3'
                             	          AND ERP.value IS NOT NULL)))