-- lines
SELECT  'V360' company_code,
LEDGER_NAME||'~'||LEDGER_ID||'~'||LEDGER_SHORT_NAME||'~'||LEDGER_CATEGORY_CODE||'~'||LEDGER_CURRENCY_CODE||'~'||BATCH_ID||'~'||BATCH_NAME||'~'||
BATCH_DESCRIPTION||'~'||JOURNAL_ID||'~'||JOURNAL_NAME||'~'||JOURNAL_DESCRIPTION||'~'||USER_JE_SOURCE_NAME||'~'||
USER_JE_CATEGORY_NAME||'~'||DOCUMENT_SEQUENCE_ID||'~'||DOCUMENT_SEQUENCE_VALUE||'~'||CLOSE_ACCT_SEQ_ASSIGN_ID||'~'||CLOSE_ACCT_SEQ_VALUE||'~'||PERIOD_NAME||'~'||
STAT_PERIOD||'~'||EFFECTIVE_DATE||'~'||POSTED_BY||'~'||POSTED_DATE||'~'||STATUS||'~'||CURRENCY_CODE||'~'||
USER_CURRENCY_CONVERSION_TYPE||'~'||CURRENCY_CONVERSION_RATE||'~'||CURRENCY_CONVERSION_DATE||'~'||JE_LINE_NUM||'~'||LINE_EFFECTIVE_DATE||'~'||
CODE_COMBINATION_ID||'~'||COMPANY_CODE||'~'||ACCOUNT||'~'||TRADING_PARTNER||'~'||COST_CENTER||'~'||
  GEOGRAPHY||'~'||PROJECT_CODE||'~'||REFERENCE_CODE||'~'||PRODUCT_LINE||'~'||BOOK_TYPE||'~'||FUTURE1||'~'||FUTURE2||'~'||ENTERED_DEBIT||'~'||ENTERED_CREDIT||'~'||
ACCOUNTED_DEBIT||'~'||ACCOUNTED_CREDIT||'~'||ENTERED_AMOUNT||'~'||ACCOUNTED_AMOUNT||'~'||LINE_DESCRIPTION||'~'||
  DXL_FILE_NAME||'~'||ACCRUAL_REVERSAL_STATUS||'~'||REVERSAL_PERIOD||'~'||REVERSAL_FLAG||'~'||ACCRUAL_REV_JE_HEADER_ID||'~'||PARENT_JE_HEADER_ID||'~'||
REVERSED_JE_HEADER_ID||'~'||CONVERSION_FLAG||'~'||APPROVAL_STATUS_CODE||'~'||APPROVAL_STATUS_MEANING||'~'||
  APPROVER_EMPLOYEE_ID||'~'||GROUP_ID||'~'||STAT_CURRENCY_CONV_DATE||'~'||CONTEXT||'~'||ATTRIBUTE1||'~'||ATTRIBUTE2||'~'||ATTRIBUTE3||'~'||ATTRIBUTE4||'~'||
ATTRIBUTE5||'~'||ATTRIBUTE6||'~'||ATTRIBUTE7||'~'||ATTRIBUTE8||'~'||ATTRIBUTE9||'~'||ATTRIBUTE10||'~'||
  ATTRIBUTE11||'~'||ATTRIBUTE12||'~'||ATTRIBUTE13||'~'||ATTRIBUTE14||'~'||ATTRIBUTE15||'~'||ATTRIBUTE16||'~'||ATTRIBUTE17||'~'||ATTRIBUTE18||'~'||ATTRIBUTE19||'~'||
ATTRIBUTE20||'~'||REFERENCE_1||'~'||REFERENCE_2||'~'||REFERENCE_3||'~'||REFERENCE_4||'~'||
  REFERENCE_5||'~'||REFERENCE_6||'~'||REFERENCE_7||'~'||REFERENCE_8||'~'||REFERENCE_9||'~'||REFERENCE_10||'~'||CREATED_BY||'~'||CREATION_DATE||'~'||
LAST_UPDATED_BY||'~'||LAST_UPDATE_DATE||'~'||SUBMITTED_FOR_VALIDATION_BY||'~'||SUBMITTED_FOR_VALIDATION_DATE 
  FI_JE_ENTRY
  FROM (  SELECT  G.name LEDGER_NAME,
          TO_CHAR(G.ledger_id) LEDGER_ID,
          G.short_name LEDGER_SHORT_NAME,
          G.ledger_category_code LEDGER_CATEGORY_CODE,
          G.currency_code LEDGER_CURRENCY_CODE,
          TO_CHAR(E.je_batch_id) BATCH_ID,
          replace(E.name,'~',' ') BATCH_NAME,
          REPLACE(REPLACE(REPLACE(REPLACE(REPLACE( replace(E.description,'~',' '),',',';'), CHR(13), ' '), CHR(10), ' '),CHR(9), ' '),CHR(160),' ') BATCH_DESCRIPTION ,
          TO_CHAR(A.je_header_id) JOURNAL_ID,
          replace(A.name,'~',' ') JOURNAL_NAME,
          REPLACE(REPLACE(REPLACE(REPLACE(REPLACE( replace(a.description,'~',' '),',',';'), CHR(13), ' '), CHR(10), ' '),CHR(9), ' '),CHR(160),' ') JOURNAL_DESCRIPTION,
          C.user_je_source_name USER_JE_SOURCE_NAME,
          D.user_je_category_name USER_JE_CATEGORY_NAME,
          TO_CHAR(A.doc_sequence_id) DOCUMENT_SEQUENCE_ID,
          TO_CHAR(A.doc_sequence_value) DOCUMENT_SEQUENCE_VALUE,
          TO_CHAR(A.close_acct_seq_assign_id) CLOSE_ACCT_SEQ_ASSIGN_ID,
          TO_CHAR(A.close_acct_seq_value) CLOSE_ACCT_SEQ_VALUE,
          A.period_name PERIOD_NAME,
          A.attribute1 STAT_PERIOD,
          TO_CHAR(A.default_effective_date,'YYYYMMDD HH24:MI:SS') EFFECTIVE_DATE,
          E.last_updated_by POSTED_BY,
          TO_CHAR(A.posted_date,'YYYYMMDD HH24:MI:SS') POSTED_DATE,
          A.status STATUS,
          b.currency_code CURRENCY_CODE,
          DECODE(A.currency_conversion_type,'Corporate', 'Corporate', 'EMU FIXED', 'EMU FIXED','Spot', 'Spot','User','User','30000000134004','MOR','30000000134004','GAP') USER_CURRENCY_CONVERSION_TYPE,
          A.currency_conversion_rate CURRENCY_CONVERSION_RATE,
          A.currency_conversion_date CURRENCY_CONVERSION_DATE,
          TO_CHAR(B.je_line_num) JE_LINE_NUM,
          TO_CHAR(B.effective_date,'YYYYMMDD HH24:MI:SS') LINE_EFFECTIVE_DATE,
          TO_CHAR(B.code_combination_id) CODE_COMBINATION_ID,
          F.segment1 COMPANY_CODE,
          F.segment2 ACCOUNT,
          F.segment3 TRADING_PARTNER,
          F.segment4 COST_CENTER,
          F.segment5 GEOGRAPHY,
          F.segment6 PROJECT_CODE,
          F.segment7 REFERENCE_CODE,
          F.segment8 PRODUCT_LINE,
          F.segment9 BOOK_TYPE,
          F.segment10 FUTURE1,
          F.segment11 FUTURE2,
          TO_CHAR(entered_dr) ENTERED_DEBIT,
          TO_CHAR(entered_cr) ENTERED_CREDIT,
          TO_CHAR(accounted_dr) ACCOUNTED_DEBIT,
          TO_CHAR(accounted_cr) ACCOUNTED_CREDIT,
          TO_CHAR(NVL (entered_dr, 0) - NVL (entered_cr, 0)) entered_amount,
          TO_CHAR(NVL (accounted_dr, 0) - NVL (accounted_cr, 0)) accounted_amount,
	  REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(replace(B.description,'~',' '),',',';'), CHR(13), ' '), CHR(10), ' '),CHR(9), ' '),CHR(160),' ') LINE_DESCRIPTION,
          B.reference_1 DXL_FILE_NAME,
          A.accrual_rev_status ACCRUAL_REVERSAL_STATUS,
          A.accrual_rev_period_name REVERSAL_PERIOD,
          DECODE (A.reversed_je_header_id, NULL, NULL, 'Y') REVERSAL_FLAG,
          TO_CHAR(A.accrual_rev_je_header_id) ACCRUAL_REV_JE_HEADER_ID,
          TO_CHAR(A.parent_je_header_id) PARENT_JE_HEADER_ID,
          TO_CHAR(A.reversed_je_header_id) REVERSED_JE_HEADER_ID,
          A.conversion_flag CONVERSION_FLAG,
          E.approval_status_code APPROVAL_STATUS_CODE,
          K.meaning APPROVAL_STATUS_MEANING,
          TO_CHAR(E.approver_employee_id) APPROVER_EMPLOYEE_ID,
          TO_CHAR(E.GROUP_ID) GROUP_ID,
          DECODE (SUBSTR (b.reference_1, 1, 6),'CCLGL.', b.reference_7,NULL) STAT_CURRENCY_CONV_DATE,
          null context,
          B.attribute1,
          B.attribute2,
          B.attribute3,
          B.attribute4,
          B.attribute5,
          B.attribute6,
          B.attribute7,
          B.attribute8,
          B.attribute9,
          B.attribute10,
          B.attribute11,
          B.attribute12 ,
          B.attribute13 ,
          B.attribute14 ,
          B.attribute15 ,
          B.attribute16 ,
          B.attribute17 ,
          B.attribute18 ,
          B.attribute19 ,
          B.attribute20 ,
          B.reference_1,
          B.reference_2,
          B.reference_3,
          B.reference_4,
          B.reference_5,
          B.reference_6,
          B.reference_7,
          B.reference_8,
          B.reference_9,
          B.reference_10,
          0 CREATED_BY, 
          TO_CHAR(A.creation_date,'YYYYMMDD HH24:MI:SS') CREATION_DATE,
          B.LAST_UPDATED_BY LAST_UPDATED_BY,
          TO_CHAR(E.last_update_date,'YYYYMMDD HH24:MI:SS') LAST_UPDATE_DATE,
          NULL SUBMITTED_FOR_VALIDATION_BY,
          NULL SUBMITTED_FOR_VALIDATION_DATE
     FROM gl_je_headers a,
          gl_je_lines b,
          gl_je_sources c,
          gl_je_categories d,
          gl_je_batches e,
          gl_code_combinations f,
          gl_ledgers g,
          fnd_flex_values fvv,          
          fnd_flex_value_sets fvs,
          gl_lookups k
    WHERE A.je_header_id = B.je_header_id
     AND  fvv.flex_value_set_id   =  fvs.flex_value_set_id
     AND  fvs.flex_value_set_name = 'CCL_COMPANY_CODES'  
     AND  fvv.flex_value  = f.segment1
     AND A.je_source = C.je_source_name
     AND A.je_category = D.je_category_name
     AND E.je_batch_id = A.je_batch_id
     AND B.code_combination_id = F.code_combination_id
--     AND  ((fvv.attribute5 = 'USD' AND g.name LIKE '%FCY') OR  (fvv.attribute5 <> 'USD' AND g.name LIKE '%PRM'))      
   AND ( 
         (g.name LIKE '%FCY' AND fvv.attribute5 = SUBSTR(g.name,4,3) 
		 ) OR 
         (g.name LIKE '%PRM' AND fvv.attribute5 = SUBSTR(g.name,4,3) 
		 )
        )
     AND A.ledger_id = G.ledger_id
     AND K.lookup_code = E.approval_status_code
	-- AND b.period_name = g.latest_opened_period_name
     AND e.status  = 'P'
     AND K.lookup_type = 'JE_BATCH_APPROVAL_STATUS'
    -- AND NVL(:P_LAST_RUN_DATE,TRUNC(SYSDATE)) = NVL(:P_LAST_RUN_DATE,TRUNC(SYSDATE))
     AND TRUNC(A.posted_date) BETWEEN NVL(:P_FROM_DATE,TRUNC(SYSDATE-4)) AND NVL(:P_TO_DATE,TRUNC(SYSDATE))
    UNION ALL
    SELECT   
                 G.name LEDGER_NAME,
                 TO_CHAR(G.ledger_id) LEDGER_ID,
                 G.short_name LEDGER_SHORT_NAME,
                 G.ledger_category_code LEDGER_CATEGORY_CODE,
                 G.currency_code LEDGER_CURRENCY_CODE,
                 TO_CHAR(E.je_batch_id) BATCH_ID,
                 replace(E.name,'~',' ') BATCH_NAME,
                 REPLACE(REPLACE(REPLACE(REPLACE(REPLACE( replace(E.description,'~',' '),',',';'), CHR(13), ' '), CHR(10), ' '),CHR(9), ' '),CHR(160),' ') BATCH_DESCRIPTION ,
                 TO_CHAR(A.je_header_id) JOURNAL_ID,
                 replace(A.name,'~',' ') JOURNAL_NAME,
                 REPLACE(REPLACE(REPLACE(REPLACE(REPLACE( replace(a.description,'~',' '),',',';'), CHR(13), ' '), CHR(10), ' '),CHR(9), ' '),CHR(160),' ') JOURNAL_DESCRIPTION,
                 C.user_je_source_name USER_JE_SOURCE_NAME,
                 D.user_je_category_name USER_JE_CATEGORY_NAME,
                 TO_CHAR(A.doc_sequence_id) DOCUMENT_SEQUENCE_ID,
                 TO_CHAR(A.doc_sequence_value) DOCUMENT_SEQUENCE_VALUE,
                 TO_CHAR(A.close_acct_seq_assign_id) CLOSE_ACCT_SEQ_ASSIGN_ID,
                 TO_CHAR(A.close_acct_seq_value) CLOSE_ACCT_SEQ_VALUE,
                 A.period_name PERIOD_NAME,
                 A.attribute1 STAT_PERIOD,
                 TO_CHAR(A.default_effective_date,'YYYYMMDD HH24:MI:SS') EFFECTIVE_DATE,
                 E.last_updated_by POSTED_BY,
                 TO_CHAR(A.posted_date,'YYYYMMDD HH24:MI:SS') POSTED_DATE,
                 A.status STATUS,
                 b.currency_code CURRENCY_CODE,
                 DECODE(A.currency_conversion_type,'Corporate', 'Corporate', 'EMU FIXED', 'EMU FIXED','Spot', 'Spot','User','User','30000000134004','MOR','30000000134004','GAP') USER_CURRENCY_CONVERSION_TYPE,
                 A.currency_conversion_rate CURRENCY_CONVERSION_RATE,
                 A.currency_conversion_date CURRENCY_CONVERSION_DATE,
                 TO_CHAR(B.je_line_num) JE_LINE_NUM,
                 TO_CHAR(B.effective_date,'YYYYMMDD HH24:MI:SS') LINE_EFFECTIVE_DATE,
                 TO_CHAR(B.code_combination_id) CODE_COMBINATION_ID,
                 F.segment1 COMPANY_CODE,
                 F.segment2 ACCOUNT,
                 F.segment3 TRADING_PARTNER,
                 F.segment4 COST_CENTER,
                 F.segment5 GEOGRAPHY,
                 F.segment6 PROJECT_CODE,
                 F.segment7 REFERENCE_CODE,
                 F.segment8 PRODUCT_LINE,
                 F.segment9 BOOK_TYPE,
                 F.segment10 FUTURE1,
                 F.segment11 FUTURE2,
                 TO_CHAR(entered_dr) ENTERED_DEBIT,
                 TO_CHAR(entered_cr) ENTERED_CREDIT,
                 TO_CHAR(accounted_dr) ACCOUNTED_DEBIT,
                 TO_CHAR(accounted_cr) ACCOUNTED_CREDIT,
                 TO_CHAR(NVL (entered_dr, 0) - NVL (entered_cr, 0)) entered_amount,
                 TO_CHAR(NVL (accounted_dr, 0) - NVL (accounted_cr, 0)) accounted_amount,
       		  REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(replace(B.description,'~',' '),',',';'), CHR(13), ' '), CHR(10), ' '),CHR(9), ' '),CHR(160),' ') LINE_DESCRIPTION,
                 B.reference_1 DXL_FILE_NAME,
                 A.accrual_rev_status ACCRUAL_REVERSAL_STATUS,
                 A.accrual_rev_period_name REVERSAL_PERIOD,
                 DECODE (A.reversed_je_header_id, NULL, NULL, 'Y') REVERSAL_FLAG,
                 TO_CHAR(A.accrual_rev_je_header_id) ACCRUAL_REV_JE_HEADER_ID,
                 TO_CHAR(A.parent_je_header_id) PARENT_JE_HEADER_ID,
                 TO_CHAR(A.reversed_je_header_id) REVERSED_JE_HEADER_ID,
                 A.conversion_flag CONVERSION_FLAG,
                 E.approval_status_code APPROVAL_STATUS_CODE,
                 K.meaning APPROVAL_STATUS_MEANING,
                 TO_CHAR(E.approver_employee_id) APPROVER_EMPLOYEE_ID,
                 TO_CHAR(E.GROUP_ID) GROUP_ID,
                 DECODE (SUBSTR (b.reference_1, 1, 6),'CCLGL.', b.reference_7,NULL) STAT_CURRENCY_CONV_DATE,
                 B.global_ATTRIBUTE_CATEGORY context,
                 B.attribute1,
                 B.attribute2,
                 B.attribute3,
                 B.attribute4,
                 B.attribute5,
                 B.attribute6,
                 B.attribute7,
                 B.attribute8,
                 B.attribute9,
                 B.attribute10,
				 B.attribute11,
                 B.attribute12 ,
                 B.attribute13  ,
                 B.attribute14 ,
                 B.attribute15 ,
                 B.attribute16 ,
                 B.attribute17 ,
                 B.attribute18 ,
                 B.attribute19 ,
                 B.attribute20 ,
                 B.reference_1,
                 B.reference_2,
                 B.reference_3,
                 B.reference_4,
                 B.reference_5,
                 B.reference_6,
                 B.reference_7,
                 B.reference_8,
                 B.reference_9,
                 B.reference_10,
                 0 CREATED_BY, 
                 TO_CHAR(A.creation_date,'YYYYMMDD HH24:MI:SS') CREATION_DATE,
                 B.LAST_UPDATED_BY LAST_UPDATED_BY,
                 TO_CHAR(E.last_update_date,'YYYYMMDD HH24:MI:SS') LAST_UPDATE_DATE,
                 NULL SUBMITTED_FOR_VALIDATION_BY,
                 NULL SUBMITTED_FOR_VALIDATION_DATE
            FROM gl_je_headers a,
                 gl_je_lines b,
                 gl_je_sources c,
                 gl_je_categories d,
                 gl_je_batches e,
                 gl_code_combinations f,
                 gl_ledgers g,
                 gl_lookups k
           WHERE A.je_header_id = B.je_header_id
            AND A.je_source = C.je_source_name
            AND A.je_category = D.je_category_name
            AND E.je_batch_id = A.je_batch_id
            AND B.code_combination_id = F.code_combination_id
            --AND b.period_name = g.latest_opened_period_name
            AND g.name like '%RPT'
            AND g.currency_code='USD'
            AND g.ledger_category_code     =   'ALC' 
            AND upper(g.description)   LIKE '%REPORTING%'		
            AND A.ledger_id = G.ledger_id
            AND K.lookup_code = E.approval_status_code
            AND e.status  = 'P'
     AND K.lookup_type = 'JE_BATCH_APPROVAL_STATUS'
     AND NVL(:P_LAST_RUN_DATE,TRUNC(SYSDATE)) = NVL(:P_LAST_RUN_DATE,TRUNC(SYSDATE))
     AND TRUNC(A.posted_date) BETWEEN NVL(:P_FROM_DATE,TRUNC(SYSDATE-4)) AND NVL(:P_TO_DATE,TRUNC(SYSDATE))
    UNION ALL
 SELECT   
              G.name LEDGER_NAME,
              TO_CHAR(G.ledger_id) LEDGER_ID,
              G.short_name LEDGER_SHORT_NAME,
              G.ledger_category_code LEDGER_CATEGORY_CODE,
              G.currency_code LEDGER_CURRENCY_CODE,
              TO_CHAR(E.je_batch_id) BATCH_ID,
              replace(E.name,'~',' ') BATCH_NAME,
              REPLACE(REPLACE(REPLACE(REPLACE(REPLACE( replace(E.description,'~',' '),',',';'), CHR(13), ' '), CHR(10), ' '),CHR(9), ' '),CHR(160),' ') BATCH_DESCRIPTION ,
              TO_CHAR(A.je_header_id) JOURNAL_ID,
              replace(A.name,'~',' ') JOURNAL_NAME,
              REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(replace(a.description,'~',' '),',',';'), CHR(13), ' '), CHR(10), ' '),CHR(9), ' '),CHR(160),' ') JOURNAL_DESCRIPTION,
              C.user_je_source_name USER_JE_SOURCE_NAME,
              D.user_je_category_name USER_JE_CATEGORY_NAME,
              TO_CHAR(A.doc_sequence_id) DOCUMENT_SEQUENCE_ID,
              TO_CHAR(A.doc_sequence_value) DOCUMENT_SEQUENCE_VALUE,
              TO_CHAR(A.close_acct_seq_assign_id) CLOSE_ACCT_SEQ_ASSIGN_ID,
              TO_CHAR(A.close_acct_seq_value) CLOSE_ACCT_SEQ_VALUE,
              A.period_name PERIOD_NAME,
              A.attribute1 STAT_PERIOD,
              TO_CHAR(A.default_effective_date,'YYYYMMDD HH24:MI:SS') EFFECTIVE_DATE,
              E.last_updated_by POSTED_BY,
              TO_CHAR(A.posted_date,'YYYYMMDD HH24:MI:SS') POSTED_DATE,
              A.status STATUS,
              b.CURRENCY_CODE CURRENCY_CODE,
              DECODE(A.currency_conversion_type,'Corporate', 'Corporate', 'EMU FIXED', 'EMU FIXED','Spot', 'Spot','User', 'User','30000000134004','MOR','30000000134004','GAP') USER_CURRENCY_CONVERSION_TYPE,
              A.currency_conversion_rate CURRENCY_CONVERSION_RATE,
              A.currency_conversion_date CURRENCY_CONVERSION_DATE,
              TO_CHAR(B.je_line_num) JE_LINE_NUM,
              TO_CHAR(B.effective_date,'YYYYMMDD HH24:MI:SS') LINE_EFFECTIVE_DATE,
              TO_CHAR(B.code_combination_id) CODE_COMBINATION_ID,
              F.segment1 COMPANY_CODE,
              F.segment2 ACCOUNT,
              F.segment3 TRADING_PARTNER,
              F.segment4 COST_CENTER,
              F.segment5 GEOGRAPHY,
              F.segment6 PROJECT_CODE,
              F.segment7 REFERENCE_CODE,
              F.segment8 PRODUCT_LINE,
              F.segment9 BOOK_TYPE,
              F.segment10 FUTURE1,
              F.segment11 FUTURE2,
              TO_CHAR(entered_dr) ENTERED_DEBIT,
              TO_CHAR(entered_cr) ENTERED_CREDIT,
              TO_CHAR(accounted_dr) ACCOUNTED_DEBIT,
              TO_CHAR(accounted_cr) ACCOUNTED_CREDIT,
              TO_CHAR(NVL (entered_dr, 0) - NVL (entered_cr, 0)) entered_amount,
              TO_CHAR(NVL (accounted_dr, 0) - NVL (accounted_cr, 0)) accounted_amount,
    		  REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(replace(B.description,'~',' '),',',';'), CHR(13), ' '), CHR(10), ' '),CHR(9), ' '),CHR(160),' ') LINE_DESCRIPTION,
              B.reference_1 DXL_FILE_NAME,
              A.accrual_rev_status ACCRUAL_REVERSAL_STATUS,
              A.accrual_rev_period_name REVERSAL_PERIOD,
              DECODE (A.reversed_je_header_id, NULL, NULL, 'Y') REVERSAL_FLAG,
              TO_CHAR(A.accrual_rev_je_header_id) ACCRUAL_REV_JE_HEADER_ID,
              TO_CHAR(A.parent_je_header_id) PARENT_JE_HEADER_ID,
              TO_CHAR(A.reversed_je_header_id) REVERSED_JE_HEADER_ID,
              A.conversion_flag CONVERSION_FLAG,
              E.approval_status_code APPROVAL_STATUS_CODE,
              K.meaning APPROVAL_STATUS_MEANING,
              TO_CHAR(E.approver_employee_id) APPROVER_EMPLOYEE_ID,
              TO_CHAR(E.GROUP_ID) GROUP_ID,
              DECODE (SUBSTR (b.reference_1, 1, 6),'CCLGL.', b.reference_7,NULL) STAT_CURRENCY_CONV_DATE,
              B.ATTRIBUTE_CATEGORY context,
              B.attribute1,
              B.attribute2,
              B.attribute3,
              B.attribute4,
              B.attribute5,
              B.attribute6,
              B.attribute7,
              B.attribute8,
              B.attribute9,
              B.attribute10,
              B.attribute11,
              B.attribute12 ,
              B.attribute13  ,
              B.attribute14  ,
              B.attribute15  ,
              B.attribute16  ,
              B.attribute17  ,
              B.attribute18  ,
              B.attribute19  ,
              B.attribute20  ,
              B.reference_1,
              B.reference_2,
              B.reference_3,
              B.reference_4,
              B.reference_5,
              B.reference_6,
              B.reference_7,
              B.reference_8,
              B.reference_9,
              B.reference_10,
              0 CREATED_BY, 
              TO_CHAR(A.creation_date,'YYYYMMDD HH24:MI:SS') CREATION_DATE,
              B.LAST_UPDATED_BY LAST_UPDATED_BY,
              TO_CHAR(E.last_update_date,'YYYYMMDD HH24:MI:SS') LAST_UPDATE_DATE,
              NULL SUBMITTED_FOR_VALIDATION_BY,
              NULL SUBMITTED_FOR_VALIDATION_DATE
         FROM gl_je_headers a,
              gl_je_lines b,
              gl_je_sources c,
              gl_je_categories d,
              gl_je_batches e,
              gl_code_combinations f,
              gl_ledgers g,
              gl_lookups k
        WHERE A.je_header_id = B.je_header_id
         AND A.je_source = C.je_source_name
         AND A.je_category = D.je_category_name
         AND E.je_batch_id = A.je_batch_id
         AND B.code_combination_id = F.code_combination_id
         AND g.name like '%STA'
         AND g.ledger_category_code     =   'SECONDARY' 
         AND upper(g.description)   LIKE '%STATUTORY%'		
         AND A.ledger_id = G.ledger_id
         AND K.lookup_code = E.approval_status_code
         AND e.status  = 'P'
     AND K.lookup_type = 'JE_BATCH_APPROVAL_STATUS'
     AND NVL(:P_LAST_RUN_DATE,TRUNC(SYSDATE)) = NVL(:P_LAST_RUN_DATE,TRUNC(SYSDATE))
     AND TRUNC(A.posted_date) BETWEEN NVL(:P_FROM_DATE,TRUNC(SYSDATE-4)) AND NVL(:P_TO_DATE,TRUNC(SYSDATE))
         )