SELECT b.bank_account_name,
       b.bank_account_num,
       to_char(d.stmt_from_date,'DD-MM-YYYY') transaction_date,	 
	   c.amount "Amount", 
	   decode(c.FLOW_INDICATOR,'DBIT','Debit','CRDT','Credit') item_type, 	
	   d.currency_code "Currency_Code",
     e.trx_code,    
     c.statement_header_id, d.statement_number,--d.currency_code, 
	 d.stmt_from_date, d.stmt_to_date, d.recon_status_code, d.autorec_process_code, 
     d.statement_entry_type,d.statement_type, c.statement_line_id,c.line_number,c.trx_code_id,
     c.trx_type,c.recon_status, c.amount amount1,
	 c.addenda_txt reference1, c.customer_reference reference2,
                        (SELECT NVL((FND_FLEX_XML_PUBLISHER_APIS.PROCESS_KFF_COMBINATION_1('FLEXFIELD','GL','GL#',CHART_OF_ACCOUNTS_ID,NULL,CODE_COMBINATION_ID,'ALL','Y','VALUE')),NULL)
                           FROM   gl_code_combinations, ce_external_transactions a
                  WHERE code_combination_id = a.asset_ccid
				    AND a.statement_line_id = c.statement_line_id
                    AND a.bank_account_id   = b.bank_account_id
					AND a.status = 'REC') AS cash_account, -- Asset_CCID,
                        (SELECT NVL((FND_FLEX_XML_PUBLISHER_APIS.PROCESS_KFF_COMBINATION_1('FLEXFIELD','GL','GL#',CHART_OF_ACCOUNTS_ID,NULL,CODE_COMBINATION_ID,'ALL','Y','VALUE')),NULL)
                   FROM   gl_code_combinations, ce_external_transactions a 
                  WHERE code_combination_id = a.offset_ccid
				    AND a.statement_line_id = c.statement_line_id
                    AND a.bank_account_id   = b.bank_account_id
					AND a.status = 'REC') AS Offset_Account --offset_ccid
FROM ce_bank_accounts b, ce_statement_lines c, ce_statement_headers d ,ce_transaction_codes e
WHERE d.bank_account_id     = b.bank_account_id    
  AND c.statement_header_id = d.statement_header_id 
  AND  c.trx_code_id=e.transaction_code_id 
  AND b.bank_account_name = NVL(:P_BANK_ACC_NAME,b.bank_account_name)
  AND d.stmt_from_date BETWEEN NVL(:P_FROM_DATE,d.statement_date) AND NVL(:P_TO_DATE,d.statement_date)
ORDER BY b.bank_account_name, transaction_date