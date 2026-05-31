SELECT 'PERIOD_NAME' KEY,
'LEDGER_ID'||'~'||'CODE_COMBINATION_ID'||'~'||'CURRENCY_CODE'||'~'||'PERIOD_NAME'||'~'||'ACTUAL_FLAG'||'~'||'PERIOD_TYPE'||'~'||'PERIOD_YEAR'||'~'||'PERIOD_NUM'||'~'||'PERIOD_NET_DR'||'~'||'PERIOD_NET_CR'||'~'||'QUARTER_TO_DATE_DR'||'~'||'QUARTER_TO_DATE_CR'||'~'||'PROJECT_TO_DATE_DR'||'~'||'PROJECT_TO_DATE_CR'||'~'||'BEGIN_BALANCE_DR'||'~'||'BEGIN_BALANCE_CR'||'~'||'PERIOD_NET_DR_BEQ'||'~'||'PERIOD_NET_CR_BEQ'||'~'||'QUARTER_TO_DATE_DR_BEQ'||'~'|| 'QUARTER_TO_DATE_CR_BEQ'||'~'|| 'PROJECT_TO_DATE_DR_BEQ'||'~'|| 'PROJECT_TO_DATE_CR_BEQ'||'~'|| 'BEGIN_BALANCE_DR_BEQ'||'~'||'BEGIN_BALANCE_CR_BEQ'||'~'||'OBJECT_VERSION_NUMBER'||'~'||'LAST_UPDATED_BY'||'~'|| 'LAST_UPDATE_DATE'||'~'|| 'TRANSLATED_FLAG'||'~'|| 'BUDGET_VERSION_ID'||'~'||'ENCUMBRANCE_TYPE_ID'||'~'|| 'TEMPLATE_ID' GL_BALANCES
FROM DUAL	
UNION ALL
SELECT 'PERIOD_NAME' KEY,
LEDGER_ID||'|'||CODE_COMBINATION_ID||'|'||CURRENCY_CODE||'|'|| PERIOD_NAME||'|'|| ACTUAL_FLAG||'|'||PERIOD_TYPE||'|'||PERIOD_YEAR||'|'|| PERIOD_NUM||'|'||PERIOD_NET_DR||'|'||PERIOD_NET_CR||'|'|| QUARTER_TO_DATE_DR||'|'|| QUARTER_TO_DATE_CR||'|'|| PROJECT_TO_DATE_DR||'|'|| PROJECT_TO_DATE_CR||'|'||  BEGIN_BALANCE_DR||'|'|| BEGIN_BALANCE_CR||'|'|| PERIOD_NET_DR_BEQ||'|'|| PERIOD_NET_CR_BEQ||'|'|| QUARTER_TO_DATE_DR_BEQ||'|'|| QUARTER_TO_DATE_CR_BEQ||'|'|| PROJECT_TO_DATE_DR_BEQ||'|'|| PROJECT_TO_DATE_CR_BEQ||'|'|| BEGIN_BALANCE_DR_BEQ||'|'||    BEGIN_BALANCE_CR_BEQ||'|'||OBJECT_VERSION_NUMBER||'|'|| LAST_UPDATED_BY||'|'|| LAST_UPDATE_DATE||'|'|| TRANSLATED_FLAG||'|'|| BUDGET_VERSION_ID||'|'|| ENCUMBRANCE_TYPE_ID||'|'|| TEMPLATE_ID
FROM GL_BALANCES a
where ((:P_FROM_DATE IS NOT NULL AND :P_TO_DATE IS NOT NULL AND a.last_update_date between :P_FROM_DATE AND :P_TO_DATE) or
			(:P_FROM_DATE IS NULL AND :P_TO_DATE IS NULL AND a.last_update_date > (SELECT MAX(ERH.processstart)
                                         FROM ess_request_history ERH
                                             ,ess_request_property ERP
                                        WHERE ERH.requestid = ERP.requestid
                                          AND ERH.definition = 'JobDefinition://oracle/apps/ess/custom/cclf/CCLF_DL_GL_Balances'
                                          AND ERH.executable_status = 'SUCCEEDED'
                                          AND ERP.name = 'submit.argument1'
                             	          AND ERP.value IS  NULL)))
ORDER BY 1 DESC