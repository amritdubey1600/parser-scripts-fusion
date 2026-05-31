--#-----------------------------------------------------------------------------------------------------#
--# MODIFICATION HISTORY:
--# CR#                       Author             Date                Description
--#-----------------------------------------------------------------------------------------------------#
--# REL-047				   Nuri Chetia		   16-Nov-2020		GERITM13412360 restricting triggering bursting
--# REL-053				   Nuri Chetia	       20-FEB-2021	        GERITM20414034 Perfomance tuning in the code
--#-----------------------------------------------------------------------------------------------------#
SELECT 1 AS "KEY"
      ,'text' AS "OUTPUT_FORMAT"
      ,'FTP' AS "DEL_CHANNEL"
      ,(SELECT 'CCLFGL.RECLASS.CCLJEES.SUMFBDI.'||TO_CHAR(absparentID)||'.csv'
			FROM ESS_REQUEST_HISTORY 
			WHERE requestid		=	FND_JOB.REQUEST_ID
		) AS "OUTPUT_NAME"
      ,'true' AS "SAVE_OUTPUT"
      , FND_PROFILE.VALUE('MFT_ICS_SFTP') AS "PARAMETER1"
      ,:P_DEST_DIR AS "PARAMETER4"
      ,(SELECT 'CCLFGL.RECLASS.CCLJEES.SUMFBDI.'||TO_CHAR(absparentID)||'.csv'
			FROM ESS_REQUEST_HISTORY 
			WHERE requestid		=	FND_JOB.REQUEST_ID
		) AS "PARAMETER5"
       ,'true' AS "PARAMETER6"
FROM SYS.DUAL
--REL 047 GERITM13412360 starts
WHERE (SELECT COUNT(1) FROM
(
WITH rec_line AS (
    SELECT
        xah.je_category_name transaction_type,
        glb.name ledger_name,
        fub.bu_name bu_name,
        xah.period_name,
        rcta.trx_number trx_number,
        rcta.trx_date,
        ccd.segment1 segment1,
        ccd.segment2 segment2,
        ccd.segment3 segment3,
        ccd.segment4 segment4,
        ccd.segment5 segment5,
        ccd.segment6 segment6,
        ccd.segment7 segment7,
        ccd.segment8 segment8,
        ccd.segment9 segment9,
        ccd.segment10 segment10,
        ccd.segment11 segment11,
        xah.accounting_date,
        xal.entered_dr,
        xal.accounted_dr,
        xal.entered_cr,
        xal.accounted_cr,
        xal.code_combination_id,
        xah.ledger_id,
        rcta.customer_trx_id,
        rctt.name trx_type_name,
        xah.je_category_name,
        xal.currency_code,
        xah.creation_date,
        gjh.posted_date
    FROM
        XLA_AE_HEADERS xah,
        XLA_AE_LINES xal,
        GL_CODE_COMBINATIONS ccd,
        GL_LEDGERS glb,
        RA_CUSTOMER_TRX_ALL rcta,
        RA_CUST_TRX_TYPES_ALL rctt,
        FUN_ALL_BUSINESS_UNITS_V fub,
        XLA_TRANSACTION_ENTITIES xte,
        XLA_EVENTS xe,
        GL_IMPORT_REFERENCES gir,
        GL_JE_HEADERS gjh
    WHERE
        1 = 1
        AND xah.ledger_id = glb.ledger_id
        AND xah.ae_header_id = xal.ae_header_id
        AND xal.code_combination_id = ccd.code_combination_id
        AND xah.application_id = 222
        AND xah.gl_transfer_status_code = 'Y'
        AND xah.accounting_entry_status_code = 'F'
        AND xal.accounting_class_code IN (
            'RECEIVABLE'
        )
        AND fub.bu_id = rcta.org_id
        AND glb.ledger_id = TO_NUMBER(fub.primary_ledger_id)
        AND fub.bu_id = NVL(:p_bu_name,fub.bu_id)
        AND xte.source_id_int_1 = rcta.customer_trx_id
        AND xe.entity_id = xte.entity_id
        AND xah.event_id = xe.event_id
        AND xe.event_status_code = 'P'
        AND xe.process_status_code = 'P'
        AND rcta.cust_trx_type_seq_id = rctt.cust_trx_type_seq_id
        AND gir.gl_sl_link_table = xal.gl_sl_link_table
        AND gir.gl_sl_link_id = xal.gl_sl_link_id
        AND gir.je_header_id = gjh.je_header_id
        AND gjh.status = 'P'
        AND gjh.ledger_id = xah.ledger_id
		--REL053 GERITM20414034 Starts
		AND rcta.org_id = NVL(:p_bu_name,rcta.org_id)
		AND ( gjh.posted_date > NVL( (
                SELECT
                    MAX(erh.processstart)
                FROM
                    ess_request_history erh,ess_request_property erp1
                WHERE
                    erh.requestid = erp1.requestid
                    AND erh.definition = 'JobDefinition://oracle/apps/ess/custom/GL/CirrusARJournalReclassSummaryReporttoFBDIConvert'
                    AND erh.executable_status = 'SUCCEEDED'
                    AND erp1.name = 'submit.argument4'
					AND erp1.value = NVL(TO_CHAR(:p_bu_name),erp1.value)
            ),TO_DATE('2020-08-01','YYYY-MM-DD') ) )
            --REL053 GERITM20414034 Ends
),rev_line_sum AS (
    SELECT
        rcta.customer_trx_id,
        xah.ledger_id,
        SUM(xal.entered_dr) sum_ent_dr,
        SUM(xal.entered_cr) sum_ent_cr,
        SUM(xal.accounted_cr) sum_acc_cr,
        SUM(xal.accounted_dr) sum_acc_dr
    FROM
        RA_CUSTOMER_TRX_ALL rcta,
        XLA_TRANSACTION_ENTITIES xte,
        XLA_EVENTS xe,
        XLA_AE_HEADERS xah,
        XLA_AE_LINES xal
    WHERE
        1 = 1
        AND xte.source_id_int_1 = rcta.customer_trx_id
        AND xe.entity_id = xte.entity_id
        AND xah.event_id = xe.event_id
        AND xe.event_status_code = 'P'
        AND xe.process_status_code = 'P'
        AND xal.accounting_class_code = 'REVENUE'
        AND xah.ae_header_id = xal.ae_header_id
		AND rcta.org_id = NVL(:p_bu_name,rcta.org_id)--REL053 GERITM20414034 Added
    GROUP BY
        rcta.customer_trx_id,
        xah.ledger_id
),rev_line AS (
    SELECT
        rcta.customer_trx_id,
        xah.ledger_id,
        ccd.segment4 segment4,
        ccd.segment8 segment8,
        xal.entered_dr,
        xal.entered_cr,
        xal.accounted_cr,
        xal.accounted_dr,
        xah.creation_date,
        xah.gl_transfer_date
    FROM
        RA_CUSTOMER_TRX_ALL rcta,
        XLA_TRANSACTION_ENTITIES xte,
        XLA_EVENTS xe,
        XLA_AE_HEADERS xah,
        XLA_AE_LINES xal,
        GL_CODE_COMBINATIONS ccd
    WHERE
        1 = 1
        AND xte.source_id_int_1 = rcta.customer_trx_id
        AND xe.entity_id = xte.entity_id
        AND xah.event_id = xe.event_id
        AND xe.event_status_code = 'P'
        AND xe.process_status_code = 'P'
        AND xal.accounting_class_code = 'REVENUE'
        AND xah.ae_header_id = xal.ae_header_id
        AND xal.code_combination_id = ccd.code_combination_id
		AND rcta.org_id = NVL(:p_bu_name,rcta.org_id)--REL053 GERITM20414034 Added
),receipt_acc AS (
    SELECT DISTINCT
        arca.cash_receipt_id,
        ccd.segment1 segment1,
        ccd.segment2 segment2,
        ccd.segment3 segment3,
        ccd.segment4 segment4,
        ccd.segment5 segment5,
        ccd.segment6 segment6,
        ccd.segment7 segment7,
        ccd.segment8 segment8,
        ccd.segment9 segment9,
        ccd.segment10 segment10,
        ccd.segment11 segment11,
        gjh.posted_date
    FROM
        XLA_AE_HEADERS xah,
        XLA_AE_LINES xal,
        GL_CODE_COMBINATIONS ccd,
        GL_LEDGERS glb,
        AR_CASH_RECEIPTS_ALL arca,
        FUN_ALL_BUSINESS_UNITS_V fub,
        XLA_TRANSACTION_ENTITIES xte,
        XLA_EVENTS xe,
        GL_IMPORT_REFERENCES gir,
        GL_JE_HEADERS gjh
    WHERE
        1 = 1
        AND xah.ledger_id = glb.ledger_id
        AND xah.ae_header_id = xal.ae_header_id
        AND xal.code_combination_id = ccd.code_combination_id
        AND xah.application_id = 222
        AND xah.gl_transfer_status_code = 'Y'
        AND xah.accounting_entry_status_code = 'F'
        AND xal.accounting_class_code IN (
            'RECEIVABLE'
        )
        AND glb.ledger_id = TO_NUMBER(fub.primary_ledger_id)
        AND fub.bu_id = NVL(:p_bu_name,fub.bu_id)
        AND xte.source_id_int_1 = arca.cash_receipt_id
        AND xe.entity_id = xte.entity_id
        AND xah.event_id = xe.event_id
        AND xe.event_status_code = 'P'
        AND xe.process_status_code = 'P'
        AND gir.gl_sl_link_table = xal.gl_sl_link_table
        AND gir.gl_sl_link_id = xal.gl_sl_link_id
        AND gir.je_header_id = gjh.je_header_id
        AND gjh.status = 'P'
        AND gjh.ledger_id = xah.ledger_id
		--REL053 GERITM20414034 Starts
		AND arca.org_id = NVL(:p_bu_name,arca.org_id)
		AND ( gjh.posted_date > NVL( (
                SELECT
                    MAX(erh.processstart)
                FROM
                    ess_request_history erh,ess_request_property erp1
                WHERE
                    erh.requestid = erp1.requestid
                    AND erh.definition ='JobDefinition://oracle/apps/ess/custom/GL/CirrusARJournalReclassSummaryReporttoFBDIConvert'
                    AND erh.executable_status = 'SUCCEEDED'
                    AND erp1.name = 'submit.argument4'
					AND erp1.value = NVL(TO_CHAR(:p_bu_name),erp1.value)
            ),TO_DATE('2020-08-01','YYYY-MM-DD') ) )
            --REL053 GERITM20414034 Ends
) SELECT
    1 AS "KEY",
    'NEW'
    || ','
    ||  --*Status Code
     ledger_id
    || ','
    ||  --*Ledger ID
     TO_CHAR(CAST(substr(SYSDATE,1,10) AS DATE),'YYYY/MM/DD')
    || ','
    ||  --*Effective Date of Transaction
     'Cirrus_AR_Reclass'
    || ','
    || --*Journal Source
     transaction_type
    || ','
    || --*Journal Category
     currency_code
    || ','
    ||  --*Currency Code
     TO_CHAR(CAST(substr(SYSDATE,1,10) AS DATE),'YYYY/MM/DD')
    || ','
    ||  --*Journal Entry Creation Date
     'A'
    || ','
    ||  --*Actual Flag 
     segment1
    || ','
    ||  --Segment1
     segment2
    || ','
    ||  --Segment2
     segment3
    || ','
    ||  --Segment3
     segment4
    || ','
    ||  --Segment4
     segment5
    || ','
    ||  --Segment5
     segment6
    || ','
    ||  --Segment6
     segment7
    || ','
    ||  --Segment7
     segment8
    || ','
    ||  --Segment8
     segment9
    || ','
    ||  --Segment9
     segment10
    || ','
    ||  --Segment10
     segment11
    || ','
    ||  --Segment11
     ','
    ||  --Segment12
     ','
    ||  --Segment13
     ','
    ||  --Segment14
     ','
    ||  --Segment15
     ','
    ||  --Segment16
     ','
    ||  --Segment17
     ','
    ||  --Segment18
     ','
    ||  --Segment19
     ','
    ||  --Segment20
     ','
    ||  --Segment21
     ','
    ||  --Segment22
     ','
    ||  --Segment23
     ','
    ||  --Segment24
     ','
    ||  --Segment25
     ','
    ||  --Segment26
     ','
    ||  --Segment27
     ','
    ||  --Segment28
     ','
    ||  --Segment29
     ','
    ||  --Segment30
     sum_ent_dr
    || ','
    ||  --Entered Debit Amount (Reversal hence assigning credit amount)
     sum_ent_cr
    || ','
    ||  --Entered Credit Amount (Reversal hence assigning debit amount)
     sum_acc_dr
    || ','
    ||  --Converted Debit Amount	(Reversal  hence assigning credit amount)
     sum_acc_cr
    || ','
    ||  --Converted Credit Amount	(Reversal  hence assigning debit amount)
     'AR Reclass'
    || ','
    ||  --REFERENCE1 (Batch Name)
     ','
    ||  --REFERENCE2 (Batch Description)
     ','
    ||  --REFERENCE3
     'AR Reclass'
    || ','
    ||  --REFERENCE4 (Journal Entry Name)
     'AR Reclass'
    || ','
    ||  --REFERENCE5 (Journal Entry Description)
     ','
    ||  --REFERENCE6 (Journal Entry Reference)
     ','
    ||  --REFERENCE7 (Journal Entry Reversal flag)
     ','
    ||  --REFERENCE8 (Journal Entry Reversal Period)
     ','
    ||  --REFERENCE9 (Journal Reversal Method)
     ','
    ||  --REFERENCE10 (Journal Entry Line Description)
     ','
    ||  --Reference column 1
     ','
    ||  --Reference column 2
     ','
    ||  --Reference column 3
     ','
    ||  --Reference column 4
     ','
    ||  --Reference column 5
     ','
    ||  --Reference column 6
     ','
    ||  --Reference column 7
     ','
    ||  --Reference column 8
     ','
    ||  --Reference column 9
     ','
    ||  --Reference column 10
     ','
    ||  --Statistical Amount
     'User'
    || ','
    ||  --Currency Conversion Type
     TO_CHAR(CAST(substr(SYSDATE,1,10) AS DATE),'YYYY/MM/DD')
    || ','
    ||  --Currency Conversion Date
     1
    || ','
    ||  --Currency Conversion Rate
     TO_NUMBER(TO_CHAR(SYSDATE,'YYYYMMDDHH24MI') )
    || ','
    ||  --Interface Group Identifier
     ','
    ||  --Context field for Journal Entry Line DFF
     ','
    ||  --ATTRIBUTE1 Value for Journal Entry Line DFF
     ','
    ||  --ATTRIBUTE2 Value for Journal Entry Line DFF
     ','
    ||  --Attribute3 Value for Journal Entry Line DFF
     ','
    ||  --Attribute4 Value for Journal Entry Line DFF
     ','
    ||  --Attribute5 Value for Journal Entry Line DFF
     ','
    ||  --Attribute6 Value for Journal Entry Line DFF
     ','
    ||  --Attribute7 Value for Journal Entry Line DFF
     ','
    ||  --Attribute8 Value for Journal Entry Line DFF
     ','
    ||  --Attribute9 Value for Journal Entry Line DFF
     ','
    ||  --Attribute10 Value for Journal Entry Line DFF
     ','
    ||  --Attribute11 Value for Captured Information DFF
     ','
    ||  --Attribute12 Value for Captured Information DFF
     ','
    ||  --Attribute13 Value for Captured Information DFF
     ','
    ||  --Attribute14 Value for Captured Information DFF
     ','
    ||  --Attribute15 Value for Captured Information DFF
     ','
    ||  --Attribute16 Value for Captured Information DFF
     ','
    ||  --Attribute17 Value for Captured Information DFF
     ','
    ||  --Attribute18 Value for Captured Information DFF
     ','
    ||  --Attribute19 Value for Captured Information DFF
     ','
    ||  --Attribute20 Value for Captured Information DFF
     ','
    ||  --Context field for Captured Information DFF
     ','
    ||  --Average Journal Flag
     ','
    ||  --Clearing Company
     ','
    ||  --Ledger Name	(optional if ledger_id is provided)
     ','
    ||  --Encumbrance Type ID
     ','
    ||  --Reconciliation Reference
     ','  --period_name
     AS rev
  FROM
    (
        SELECT
            1 AS "KEY",
            transaction_type,
            ledger_name,
            bu_name,
            period_name,
            ledger_id,
            je_category_name,
            currency_code,
            segment1,
            segment2,
            segment3,
            segment4,
            segment5,
            segment6,
            segment7,
            segment8,
            segment9,
            segment10,
            segment11,
            ROUND(SUM(ent_cr),2) sum_ent_cr,
            ROUND(SUM(ent_dr),2) sum_ent_dr,
            ROUND(SUM(acc_cr),2) sum_acc_cr,
            ROUND(SUM(acc_dr),2) sum_acc_dr
        FROM
            (
                SELECT
                    1 AS "KEY",
                    rec_line.je_category_name transaction_type,
                    rec_line.ledger_name,
                    rec_line.bu_name,
                    rec_line.period_name,
                    rec_line.trx_number,
                    rec_line.je_category_name,
                    rec_line.ledger_id,
                    rec_line.currency_code,
                    TO_CHAR(rec_line.trx_date,'DD-MM-YYYY') trx_date,
                    'RECEIVABLE' accounting_class_code,
                    rec_line.segment1,
                    rec_line.segment2,
                    rec_line.segment3,
                    rec_line.segment4,
                    rec_line.segment5,
                    rec_line.segment6,
                    rec_line.segment7,
                    rec_line.segment8,
                    rec_line.segment9,
                    rec_line.segment10,
                    rec_line.segment11,
                    (
                        CASE
                            WHEN NVL(rec_line.entered_dr,0) != 0
                                 AND NVL(rev_line_sum.sum_ent_dr,0) != 0 THEN rev_line_sum.sum_ent_dr
                            WHEN NVL(rec_line.entered_dr,0) != 0
                                 AND NVL(rev_line_sum.sum_ent_cr,0) != 0 THEN rev_line_sum.sum_ent_cr
                        END
                    ) ent_cr,
                    (
                        CASE
                            WHEN NVL(rec_line.accounted_dr,0) != 0
                                 AND NVL(rev_line_sum.sum_acc_dr,0) != 0 THEN rev_line_sum.sum_acc_dr
                            WHEN NVL(rec_line.accounted_dr,0) != 0
                                 AND NVL(rev_line_sum.sum_acc_cr,0) != 0 THEN rev_line_sum.sum_acc_cr
                        END
                    ) acc_cr,
                    (
                        CASE
                            WHEN NVL(rec_line.entered_cr,0) != 0
                                 AND NVL(rev_line_sum.sum_ent_cr,0) != 0 THEN rev_line_sum.sum_ent_cr
                            WHEN NVL(rec_line.entered_cr,0) != 0
                                 AND NVL(rev_line_sum.sum_ent_dr,0) != 0 THEN rev_line_sum.sum_ent_dr
                        END
                    ) ent_dr,
                    (
                        CASE
                            WHEN NVL(rec_line.accounted_cr,0) != 0
                                 AND NVL(rev_line_sum.sum_acc_cr,0) != 0 THEN rev_line_sum.sum_acc_cr
                            WHEN NVL(rec_line.accounted_cr,0) != 0
                                 AND NVL(rev_line_sum.sum_acc_dr,0) != 0 THEN rev_line_sum.sum_acc_dr
                        END
                    ) acc_dr
                FROM
                    REC_LINE,
                    REV_LINE_SUM
                WHERE
                    rec_line.customer_trx_id = rev_line_sum.customer_trx_id
                    AND rec_line.ledger_id = rev_line_sum.ledger_id
--Start Last successful run logic
/*--REL053 GERITM20414034 Starts
                    AND TRUNC(rec_line.accounting_date) BETWEEN NVL(TO_DATE(:p_from_date,'YYYY-MM-DD'),NVL( (
                        SELECT
                            MAX(ERH.processstart)
                        FROM
                            ESS_REQUEST_HISTORY ERH,ESS_REQUEST_PROPERTY ERP1
                        WHERE
                            ERH.requestid = ERP1.requestid
                            AND ERH.definition = 'JobDefinition://oracle/apps/ess/custom/GL/CirrusARJournalReclassSummaryReporttoFBDIConvert'
                            AND ERH.executable_status = 'SUCCEEDED'
                            AND ERP1.name = 'submit.argument4'
                            AND ERP1.value = TO_CHAR(:p_bu_name)
                    ),TO_DATE('2020-08-01','YYYY-MM-DD') ) ) AND NVL(TO_DATE(:p_to_date,'YYYY-MM-DD'),TRUNC(SYSDATE) )
					*/--REL053 GERITM20414034 Ends
                    AND ( rec_line.posted_date > NVL( (
                        SELECT
                            MAX(ERH.processstart)
                        FROM
                            ESS_REQUEST_HISTORY ERH,ESS_REQUEST_PROPERTY ERP1
                        WHERE
                            ERH.requestid = ERP1.requestid
                            AND ERH.definition = 'JobDefinition://oracle/apps/ess/custom/GL/CirrusARJournalReclassSummaryReporttoFBDIConvert'
                            AND ERH.executable_status = 'SUCCEEDED'
                            AND ERP1.name = 'submit.argument4'
                            -- AND ERP1.value = TO_CHAR(:p_bu_name)--REL053 GERITM20414034 Commenetd
						   AND ERP1.value = NVL(TO_CHAR(:p_bu_name),erp1.value)--REL053 GERITM20414034 Added
                    ),TO_DATE('2020-08-01','YYYY-MM-DD') ) )
--End Last successful run logic
                UNION ALL
                SELECT
                    1 AS "KEY",
                    rec_line.je_category_name transaction_type,
                    rec_line.ledger_name,
                    rec_line.bu_name,
                    rec_line.period_name,
                    rec_line.trx_number,
                    rec_line.je_category_name,
                    rec_line.ledger_id,
                    rec_line.currency_code,
                    TO_CHAR(rec_line.trx_date,'DD-MM-YYYY') trx_date,
                    'RECEIVABLE' accounting_class_code,
                    rec_line.segment1,
                    rec_line.segment2,
                    rec_line.segment3,
                    rev_line.segment4,
                    rec_line.segment5,
                    rec_line.segment6,
                    rec_line.segment7,
                    rev_line.segment8,
                    rec_line.segment9,
                    rec_line.segment10,
                    rec_line.segment11,
                    CASE
                            WHEN NVL(rec_line.entered_cr,0) != 0
                                 AND NVL(rev_line.entered_cr,0) != 0 THEN NVL(rev_line.entered_cr,0)
                            WHEN NVL(rec_line.entered_cr,0) != 0
                                 AND NVL(rev_line.entered_dr,0) != 0 THEN rev_line.entered_dr
                        END
                    ent_cr,
                    CASE
                            WHEN NVL(rec_line.accounted_cr,0) != 0
                                 AND NVL(rev_line.accounted_cr,0) != 0 THEN NVL(rev_line.accounted_cr,0)
                            WHEN NVL(rec_line.accounted_cr,0) != 0
                                 AND NVL(rev_line.accounted_dr,0) != 0 THEN rev_line.accounted_dr
                        END
                    acc_cr,
                    CASE
                            WHEN NVL(rec_line.entered_dr,0) != 0
                                 AND NVL(rev_line.entered_dr,0) != 0 THEN NVL(rev_line.entered_dr,0)
                            WHEN NVL(rec_line.entered_dr,0) != 0
                                 AND NVL(rev_line.entered_cr,0) != 0 THEN rev_line.entered_cr
                        END
                    ent_dr,
                    CASE
                            WHEN NVL(rec_line.accounted_dr,0) != 0
                                 AND NVL(rev_line.accounted_dr,0) != 0 THEN NVL(rev_line.accounted_dr,0)
                            WHEN NVL(rec_line.accounted_dr,0) != 0
                                 AND NVL(rev_line.accounted_cr,0) != 0 THEN rev_line.accounted_cr
                        END
                    acc_dr
                FROM
                    REC_LINE,
                    REV_LINE
                WHERE
                    rec_line.customer_trx_id = rev_line.customer_trx_id
                    AND rec_line.ledger_id = rev_line.ledger_id
--Start Last successful run logic
/*--REL053 GERITM20414034 starts
                    AND TRUNC(rec_line.accounting_date) BETWEEN NVL( (TO_DATE(:p_from_date,'YYYY-MM-DD') ),NVL( (
                        SELECT
                            MAX(ERH.processstart)
                        FROM
                            ESS_REQUEST_HISTORY ERH,ESS_REQUEST_PROPERTY ERP1
                        WHERE
                            ERH.requestid = ERP1.requestid
                            AND ERH.definition = 'JobDefinition://oracle/apps/ess/custom/GL/CirrusARJournalReclassSummaryReporttoFBDIConvert'
                            AND ERH.executable_status = 'SUCCEEDED'
                            AND ERP1.name = 'submit.argument4'
                            AND ERP1.value = TO_CHAR(:p_bu_name)
                    ),TO_DATE('2020-08-01','YYYY-MM-DD') ) ) AND NVL(TO_DATE(:p_to_date,'YYYY-MM-DD'),TRUNC(SYSDATE) )
					*/ --REL053 GERITM20414034 Ends
                    AND ( rec_line.posted_date > NVL( (
                        SELECT
                            MAX(ERH.processstart)
                        FROM
                            ESS_REQUEST_HISTORY ERH,ESS_REQUEST_PROPERTY ERP1
                        WHERE
                            ERH.requestid = ERP1.requestid
                            AND ERH.definition = 'JobDefinition://oracle/apps/ess/custom/GL/CirrusARJournalReclassSummaryReporttoFBDIConvert'
                            AND ERH.executable_status = 'SUCCEEDED'
                            AND ERP1.name = 'submit.argument4'
                            -- AND ERP1.value = TO_CHAR(:p_bu_name)--REL053 GERITM20414034 Commenetd
						   AND ERP1.value = NVL(TO_CHAR(:p_bu_name),erp1.value)--REL053 GERITM20414034 Added
                    ),TO_DATE('2020-08-01','YYYY-MM-DD') ) )
--End Last successful run logic
                UNION ALL
                SELECT
                    1 AS "KEY",
                    'Receipts' transaction_type--rec_line.transaction_type
                   ,
                    rec_line.ledger_name,
                    rec_line.bu_name,
                    glp.period_name,--rec_line.period_name,
                    arca.receipt_number,
                    rec_line.je_category_name,
                    rec_line.ledger_id,
                    rec_line.currency_code,
                    TO_CHAR(arca.receipt_date,'DD-MM-YYYY') trx_date,
                    'RECEIVABLE' accounting_class_code,
                    receipt_acc.segment1,
                    receipt_acc.segment2,
                    receipt_acc.segment3,
                    receipt_acc.segment4,
                    receipt_acc.segment5,
                    receipt_acc.segment6,
                    receipt_acc.segment7,
                    receipt_acc.segment8,
                    receipt_acc.segment9,
                    receipt_acc.segment10,
                    receipt_acc.segment11,
                    CASE
                            WHEN ABS(araa.amount_applied - (
                                SELECT
                                    SUM(rcta1.extended_amount)
                                FROM
                                    ra_customer_trx_lines_all rcta1
                                WHERE
                                    rcta1.customer_trx_id = rec_line.customer_trx_id
							) ) > 0.01 --added to consider where amt applied and inv amount having diff 0.01 to be considered from invoice
                             THEN ROUND( ( ( (
                                CASE
                                    WHEN NVL(rec_line.entered_cr,0) != 0
                                         AND NVL(rev_line_sum.sum_ent_cr,0) != 0 THEN rev_line_sum.sum_ent_cr
                                    WHEN NVL(rec_line.entered_cr,0) != 0
                                         AND NVL(rev_line_sum.sum_ent_dr,0) != 0 THEN rev_line_sum.sum_ent_dr
                                END
                            ) * araa.amount_applied) / (
                                SELECT
                                    SUM(rcta1.extended_amount)
                                FROM
                                    ra_customer_trx_lines_all rcta1
                                WHERE
                                    rcta1.customer_trx_id = rec_line.customer_trx_id
                                    AND line_type = 'LINE'
                            ) ),3)
                            ELSE (
                                CASE
                                    WHEN NVL(rec_line.entered_cr,0) != 0
                                         AND NVL(rev_line_sum.sum_ent_cr,0) != 0 THEN rev_line_sum.sum_ent_cr
                                    WHEN NVL(rec_line.entered_cr,0) != 0
                                         AND NVL(rev_line_sum.sum_ent_dr,0) != 0 THEN rev_line_sum.sum_ent_dr
                                END
                            )
                        END
                    ent_cr,
                    CASE
                            WHEN ABS(araa.amount_applied - (
                                SELECT
                                    SUM(rcta1.extended_amount)
                                FROM
                                    ra_customer_trx_lines_all rcta1
                                WHERE
                                    rcta1.customer_trx_id = rec_line.customer_trx_id
							) ) > 0.01 --added to consider where amt applied and inv amount having diff 0.01 to be considered from invoice
                             THEN ROUND( ( ( (
                                CASE
                                    WHEN NVL(rec_line.accounted_cr,0) != 0
                                         AND NVL(rev_line_sum.sum_acc_cr,0) != 0 THEN rev_line_sum.sum_acc_cr
                                    WHEN NVL(rec_line.accounted_cr,0) != 0
                                         AND NVL(rev_line_sum.sum_acc_dr,0) != 0 THEN rev_line_sum.sum_acc_dr
                                END
                            ) * araa.amount_applied) / (
                                SELECT
                                    SUM(rcta1.extended_amount)
                                FROM
                                    ra_customer_trx_lines_all rcta1
                                WHERE
                                    rcta1.customer_trx_id = rec_line.customer_trx_id
                                    AND line_type = 'LINE'
                            ) ),3)
                            ELSE (
                                CASE
                                    WHEN NVL(rec_line.accounted_cr,0) != 0
                                         AND NVL(rev_line_sum.sum_acc_cr,0) != 0 THEN rev_line_sum.sum_acc_cr
                                    WHEN NVL(rec_line.accounted_cr,0) != 0
                                         AND NVL(rev_line_sum.sum_acc_dr,0) != 0 THEN rev_line_sum.sum_acc_dr
                                END
                            )
                        END
                    acc_cr,
                    CASE
                            WHEN ABS(araa.amount_applied - (
                                SELECT
                                    SUM(rcta1.extended_amount)
                                FROM
                                    ra_customer_trx_lines_all rcta1
                                WHERE
                                    rcta1.customer_trx_id = rec_line.customer_trx_id
							) ) > 0.01 --added to consider where amt applied and inv amount having diff 0.01 to be considered from invoice
                             THEN ROUND( ( ( (
                                CASE
                                    WHEN NVL(rec_line.entered_dr,0) != 0
                                         AND NVL(rev_line_sum.sum_ent_dr,0) != 0 THEN rev_line_sum.sum_ent_dr
                                    WHEN NVL(rec_line.entered_dr,0) != 0
                                         AND NVL(rev_line_sum.sum_ent_cr,0) != 0 THEN rev_line_sum.sum_ent_cr
                                END
                            ) * araa.amount_applied) / (
                                SELECT
                                    SUM(rcta1.extended_amount)
                                FROM
                                    ra_customer_trx_lines_all rcta1
                                WHERE
                                    rcta1.customer_trx_id = rec_line.customer_trx_id
                                    AND line_type = 'LINE'
                            ) ),3)
                            ELSE (
                                CASE
                                    WHEN NVL(rec_line.entered_dr,0) != 0
                                         AND NVL(rev_line_sum.sum_ent_dr,0) != 0 THEN rev_line_sum.sum_ent_dr
                                    WHEN NVL(rec_line.entered_dr,0) != 0
                                         AND NVL(rev_line_sum.sum_ent_cr,0) != 0 THEN rev_line_sum.sum_ent_cr
                                END
                            )
                        END
                    ent_dr,
                    CASE
                            WHEN ABS(araa.amount_applied - (
                                SELECT
                                    SUM(rcta1.extended_amount)
                                FROM
                                    ra_customer_trx_lines_all rcta1
                                WHERE
                                    rcta1.customer_trx_id = rec_line.customer_trx_id
							) ) > 0.01 --added to consider where amt applied and inv amount having diff 0.01 to be considered from invoice
                             THEN ROUND( ( ( (
                                CASE
                                    WHEN NVL(rec_line.accounted_dr,0) != 0
                                         AND NVL(rev_line_sum.sum_acc_dr,0) != 0 THEN rev_line_sum.sum_acc_dr
                                    WHEN NVL(rec_line.accounted_dr,0) != 0
                                         AND NVL(rev_line_sum.sum_acc_cr,0) != 0 THEN rev_line_sum.sum_acc_cr
                                END
                            ) * araa.amount_applied) / (
                                SELECT
                                    SUM(rcta1.extended_amount)
                                FROM
                                    ra_customer_trx_lines_all rcta1
                                WHERE
                                    rcta1.customer_trx_id = rec_line.customer_trx_id
                                    AND line_type = 'LINE'
                            ) ),3)
                            ELSE (
                                CASE
                                    WHEN NVL(rec_line.accounted_dr,0) != 0
                                         AND NVL(rev_line_sum.sum_acc_dr,0) != 0 THEN rev_line_sum.sum_acc_dr
                                    WHEN NVL(rec_line.accounted_dr,0) != 0
                                         AND NVL(rev_line_sum.sum_acc_cr,0) != 0 THEN rev_line_sum.sum_acc_cr
                                END
                            )
                        END
                    acc_dr
                FROM
                    REC_LINE,
                    REV_LINE_SUM,
                    RECEIPT_ACC,
                    AR_CASH_RECEIPTS_ALL arca,
                    AR_RECEIVABLE_APPLICATIONS_ALL araa,
                    GL_PERIODS glp
                WHERE
                    rec_line.customer_trx_id = rev_line_sum.customer_trx_id
                    AND rec_line.ledger_id = rev_line_sum.ledger_id
                    AND receipt_acc.cash_receipt_id = arca.cash_Receipt_id
                    AND araa.cash_receipt_id = arca.cash_receipt_id
                    AND araa.applied_customer_trx_id = rec_line.customer_trx_id
                    AND araa.display = 'Y'
                    AND araa.amount_applied != (
                        SELECT
                            SUM(rcta2.extended_amount)
                        FROM
                            ra_customer_trx_lines_all rcta2
                        WHERE
                            rcta2.line_type = 'TAX'
                            AND rcta2.customer_trx_id = rec_line.customer_trx_id
                    )
                    AND araa.gl_date BETWEEN glp.start_date AND glp.end_date
                    AND glp.period_set_name = 'CCL CALENDAR'
                    AND glp.period_name NOT LIKE 'ADJ%'
--Start Last successful run logic
     /*--REL053 GERITM20414034 Starts
                    AND TRUNC(araa.gl_date) BETWEEN NVL( (TO_DATE(:p_from_date,'YYYY-MM-DD') ),NVL( (
                        SELECT
                            MAX(ERH.processstart)
                        FROM
                            ESS_REQUEST_HISTORY ERH,ESS_REQUEST_PROPERTY ERP1
                        WHERE
                            ERH.requestid = ERP1.requestid
                            AND ERH.definition = 'JobDefinition://oracle/apps/ess/custom/GL/CirrusARJournalReclassSummaryReporttoFBDIConvert'
                            AND ERH.executable_status = 'SUCCEEDED'
                            AND ERP1.name = 'submit.argument4'
                            AND ERP1.value = TO_CHAR(:p_bu_name)
                    ),TO_DATE('2020-08-01','YYYY-MM-DD') ) ) AND NVL(TO_DATE(:p_to_date,'YYYY-MM-DD'),TRUNC(SYSDATE) )
					*/--REL053 GERITM20414034 Ends
                    AND ( receipt_acc.posted_date > NVL( (
                        SELECT
                            MAX(ERH.processstart)
                        FROM
                            ESS_REQUEST_HISTORY ERH,ESS_REQUEST_PROPERTY ERP1
                        WHERE
                            ERH.requestid = ERP1.requestid
                            AND ERH.definition = 'JobDefinition://oracle/apps/ess/custom/GL/CirrusARJournalReclassSummaryReporttoFBDIConvert'
                            AND ERH.executable_status = 'SUCCEEDED'
                            AND ERP1.name = 'submit.argument4'
                              -- AND ERP1.value = TO_CHAR(:p_bu_name)--REL053 GERITM20414034 Commenetd
						   AND ERP1.value = NVL(TO_CHAR(:p_bu_name),erp1.value)--REL053 GERITM20414034 Added
                    ),TO_DATE('2020-08-01','YYYY-MM-DD') ) )
--End Last successful run logic
                UNION ALL
                SELECT
                    1 AS "KEY",
                    'Receipts' transaction_type--rec_line.transaction_type
                   ,
                    rec_line.ledger_name,
                    rec_line.bu_name,
                    glp.period_name,--rec_line.period_name,
                    arca.receipt_number,
                    rec_line.je_category_name,
                    rec_line.ledger_id,
                    rec_line.currency_code,
                    TO_CHAR(arca.receipt_date,'DD-MM-YYYY') trx_date,
                    'RECEIVABLE' accounting_class_code,
                    receipt_acc.segment1,
                    receipt_acc.segment2,
                    receipt_acc.segment3,
                    rev_line.segment4,
                    receipt_acc.segment5,
                    receipt_acc.segment6,
                    receipt_acc.segment7,
                    rev_line.segment8,
                    receipt_acc.segment9,
                    receipt_acc.segment10,
                    receipt_acc.segment11,
                    CASE
                            WHEN ABS(araa.amount_applied - (
                                SELECT
                                    SUM(rcta1.extended_amount)
                                FROM
                                    ra_customer_trx_lines_all rcta1
                                WHERE
                                    rcta1.customer_trx_id = rec_line.customer_trx_id
					--AND line_type='LINE'
                            ) ) > 0.01 --added to consider where amt applied and inv amount having diff 0.01 to be considered from invoice
                             THEN ROUND( ( ( (
                                CASE
                                    WHEN NVL(rec_line.entered_dr,0) != 0
                                         AND NVL(rev_line.entered_dr,0) != 0 THEN NVL(rev_line.entered_dr,0)
                                    WHEN NVL(rec_line.entered_dr,0) != 0
                                         AND NVL(rev_line.entered_cr,0) != 0 THEN rev_line.entered_cr
                                END
                            ) * araa.amount_applied) / (
                                SELECT
                                    SUM(rcta1.extended_amount)
                                FROM
                                    ra_customer_trx_lines_all rcta1
                                WHERE
                                    rcta1.customer_trx_id = rec_line.customer_trx_id
                                    AND line_type = 'LINE'
                            ) ),3)
                            ELSE (
                                CASE
                                    WHEN NVL(rec_line.entered_dr,0) != 0
                                         AND NVL(rev_line.entered_dr,0) != 0 THEN NVL(rev_line.entered_dr,0)
                                    WHEN NVL(rec_line.entered_dr,0) != 0
                                         AND NVL(rev_line.entered_cr,0) != 0 THEN rev_line.entered_cr
                                END
                            )
                        END
                    ent_cr,
                    CASE
                            WHEN ABS(araa.amount_applied - (
                                SELECT
                                    SUM(rcta1.extended_amount)
                                FROM
                                    ra_customer_trx_lines_all rcta1
                                WHERE
                                    rcta1.customer_trx_id = rec_line.customer_trx_id
							) ) > 0.01 --added to consider where amt applied and inv amount having diff 0.01 to be considered from invoice
                             THEN ROUND( ( ( (
                                CASE
                                    WHEN NVL(rec_line.accounted_dr,0) != 0
                                         AND NVL(rev_line.accounted_dr,0) != 0 THEN NVL(rev_line.accounted_dr,0)
                                    WHEN NVL(rec_line.accounted_dr,0) != 0
                                         AND NVL(rev_line.accounted_cr,0) != 0 THEN rev_line.accounted_cr
                                END
                            ) * araa.amount_applied) / (
                                SELECT
                                    SUM(rcta1.extended_amount)
                                FROM
                                    ra_customer_trx_lines_all rcta1
                                WHERE
                                    rcta1.customer_trx_id = rec_line.customer_trx_id
                                    AND line_type = 'LINE'
                            ) ),3)
                            ELSE (
                                CASE
                                    WHEN NVL(rec_line.accounted_dr,0) != 0
                                         AND NVL(rev_line.accounted_dr,0) != 0 THEN NVL(rev_line.accounted_dr,0)
                                    WHEN NVL(rec_line.accounted_dr,0) != 0
                                         AND NVL(rev_line.accounted_cr,0) != 0 THEN rev_line.accounted_cr
                                END
                            )
                        END
                    acc_cr,
                    CASE
                            WHEN ABS(araa.amount_applied - (
                                SELECT
                                    SUM(rcta1.extended_amount)
                                FROM
                                    ra_customer_trx_lines_all rcta1
                                WHERE
                                    rcta1.customer_trx_id = rec_line.customer_trx_id
							) ) > 0.01 --added to consider where amt applied and inv amount having diff 0.01 to be considered from invoice
                             THEN ROUND( ( ( (
                                CASE
                                    WHEN NVL(rec_line.entered_cr,0) != 0
                                         AND NVL(rev_line.entered_cr,0) != 0 THEN NVL(rev_line.entered_cr,0)
                                    WHEN NVL(rec_line.entered_cr,0) != 0
                                         AND NVL(rev_line.entered_dr,0) != 0 THEN rev_line.entered_dr
                                END
                            ) * araa.amount_applied) / (
                                SELECT
                                    SUM(rcta1.extended_amount)
                                FROM
                                    ra_customer_trx_lines_all rcta1
                                WHERE
                                    rcta1.customer_trx_id = rec_line.customer_trx_id
                                    AND line_type = 'LINE'
                            ) ),3)
                            ELSE (
                                CASE
                                    WHEN NVL(rec_line.entered_cr,0) != 0
                                         AND NVL(rev_line.entered_cr,0) != 0 THEN NVL(rev_line.entered_cr,0)
                                    WHEN NVL(rec_line.entered_cr,0) != 0
                                         AND NVL(rev_line.entered_dr,0) != 0 THEN rev_line.entered_dr
                                END
                            )
                        END
                    ent_dr,
                    CASE
                            WHEN ABS(araa.amount_applied - (
                                SELECT
                                    SUM(rcta1.extended_amount)
                                FROM
                                    ra_customer_trx_lines_all rcta1
                                WHERE
                                    rcta1.customer_trx_id = rec_line.customer_trx_id
							) ) > 0.01 --added to consider where amt applied and inv amount having diff 0.01 to be considered from invoice
                             THEN ROUND( ( ( (
                                CASE
                                    WHEN NVL(rec_line.accounted_cr,0) != 0
                                         AND NVL(rev_line.accounted_cr,0) != 0 THEN NVL(rev_line.accounted_cr,0)
                                    WHEN NVL(rec_line.accounted_cr,0) != 0
                                         AND NVL(rev_line.accounted_dr,0) != 0 THEN rev_line.accounted_dr
                                END
                            ) * araa.amount_applied) / (
                                SELECT
                                    SUM(rcta1.extended_amount)
                                FROM
                                    ra_customer_trx_lines_all rcta1
                                WHERE
                                    rcta1.customer_trx_id = rec_line.customer_trx_id
                                    AND line_type = 'LINE'
                            ) ),3)
                            ELSE (
                                CASE
                                    WHEN NVL(rec_line.accounted_cr,0) != 0
                                         AND NVL(rev_line.accounted_cr,0) != 0 THEN NVL(rev_line.accounted_cr,0)
                                    WHEN NVL(rec_line.accounted_cr,0) != 0
                                         AND NVL(rev_line.accounted_dr,0) != 0 THEN rev_line.accounted_dr
                                END
                            )
                        END
                    acc_dr
                FROM
                    REC_LINE,
                    REV_LINE,
                    RECEIPT_ACC,
                    AR_CASH_RECEIPTS_ALL arca,
                    AR_RECEIVABLE_APPLICATIONS_ALL araa,
                    GL_PERIODS glp
                WHERE
                    rec_line.customer_trx_id = rev_line.customer_trx_id
                    AND rec_line.ledger_id = rev_line.ledger_id
                    AND receipt_acc.cash_receipt_id = arca.cash_receipt_id
                    AND araa.cash_receipt_id = arca.cash_receipt_id
                    AND araa.applied_customer_trx_id = rec_line.customer_trx_id
                    AND araa.display = 'Y'
                    AND araa.amount_applied != (
                        SELECT
                            SUM(rcta2.extended_amount)
                        FROM
                            ra_customer_trx_lines_all rcta2
                        WHERE
                            rcta2.line_type = 'TAX'
                            AND rcta2.customer_trx_id = rec_line.customer_trx_id
                    )
                    AND araa.gl_date BETWEEN glp.start_date AND glp.end_date
                    AND glp.period_set_name = 'CCL CALENDAR'
                    AND glp.period_name NOT LIKE 'ADJ%'
--Start Last successful run logic
/*--REL053 GERITM20414034 Starts
                    AND TRUNC(araa.gl_date) BETWEEN NVL( (TO_DATE(:p_from_date,'YYYY-MM-DD') ),NVL( (
                        SELECT
                            MAX(ERH.processstart)
                        FROM
                            ESS_REQUEST_HISTORY ERH,ESS_REQUEST_PROPERTY ERP1
                        WHERE
                            ERH.requestid = ERP1.requestid
                            AND ERH.definition = 'JobDefinition://oracle/apps/ess/custom/GL/CirrusARJournalReclassSummaryReporttoFBDIConvert'
                            AND ERH.executable_status = 'SUCCEEDED'
                            AND ERP1.name = 'submit.argument4'
                            AND ERP1.value = TO_CHAR(:p_bu_name)
                    ),TO_DATE('2020-08-01','YYYY-MM-DD') ) ) AND NVL(TO_DATE(:p_to_date,'YYYY-MM-DD'),TRUNC(SYSDATE) )
					*/--REL053 GERITM20414034 Ends
                    AND ( receipt_acc.posted_date > NVL( (
                        SELECT
                            MAX(ERH.processstart)
                        FROM
                            ESS_REQUEST_HISTORY ERH,ESS_REQUEST_PROPERTY ERP1
                        WHERE
                            ERH.requestid = ERP1.requestid
                            AND ERH.definition = 'JobDefinition://oracle/apps/ess/custom/GL/CirrusARJournalReclassSummaryReporttoFBDIConvert'
                            AND ERH.executable_status = 'SUCCEEDED'
                            AND ERP1.name = 'submit.argument4'
                              -- AND ERP1.value = TO_CHAR(:p_bu_name)--REL053 GERITM20414034 Commenetd
						   AND ERP1.value = NVL(TO_CHAR(:p_bu_name),erp1.value)--REL053 GERITM20414034 Added
                    ),TO_DATE('2020-08-01','YYYY-MM-DD') ) )
--End Last successful run logic
--Adjustment start
                UNION ALL
                SELECT
                    1 AS "KEY",
                    'Adjustment' transaction_type,
                    rec_line.ledger_name,
                    rec_line.bu_name,
                    glp.period_name--rec_line.period_name
                   ,
                    aaa.adjustment_number trx_number,
                    rec_line.je_category_name,
                    rec_line.ledger_id,
                    rec_line.currency_code,
                    TO_CHAR(aaa.apply_date,'YYYY-MM-DD') trx_date,
                    'RECEIVABLE' accounting_class_code,
                    rec_line.segment1 segment1,
                    rec_line.segment2 segment2,
                    rec_line.segment3 segment3,
                    rec_line.segment4 segment4,
                    rec_line.segment5 segment5,
                    rec_line.segment6 segment6,
                    rec_line.segment7 segment7,
                    rec_line.segment8 segment8,
                    rec_line.segment9 segment9,
                    rec_line.segment10 segment10,
                    rec_line.segment11 segment11,
                    CASE
                            WHEN ABS(aaa.amount - (
                                SELECT
                                    SUM(rcta1.extended_amount)
                                FROM
                                    ra_customer_trx_lines_all rcta1
                                WHERE
                                    rcta1.customer_trx_id = rec_line.customer_trx_id
							) ) > 0.01 --added to consider where amt applied and inv amount having diff 0.01 to be considered from invoice
                             THEN ROUND( ( ( (
                                CASE
                                    WHEN NVL(rec_line.entered_cr,0) != 0
                                         AND NVL(rev_line_sum.sum_ent_cr,0) != 0 THEN rev_line_sum.sum_ent_cr
                                    WHEN NVL(rec_line.entered_cr,0) != 0
                                         AND NVL(rev_line_sum.sum_ent_dr,0) != 0 THEN rev_line_sum.sum_ent_dr
                                END
                            ) * (aaa.amount *-1) ) --added as adj are negative
                             / (
                                SELECT
                                    SUM(rcta1.extended_amount)
                                FROM
                                    ra_customer_trx_lines_all rcta1
                                WHERE
                                    rcta1.customer_trx_id = rec_line.customer_trx_id
                                    AND line_type = 'LINE'
                            ) ),3)
                            ELSE (
                                CASE
                                    WHEN NVL(rec_line.entered_cr,0) != 0
                                         AND NVL(rev_line_sum.sum_ent_cr,0) != 0 THEN rev_line_sum.sum_ent_cr
                                    WHEN NVL(rec_line.entered_cr,0) != 0
                                         AND NVL(rev_line_sum.sum_ent_dr,0) != 0 THEN rev_line_sum.sum_ent_dr
                                END
                            )
                        END
                    ent_cr,
                    CASE
                            WHEN ABS(aaa.amount - (
                                SELECT
                                    SUM(rcta1.extended_amount)
                                FROM
                                    ra_customer_trx_lines_all rcta1
                                WHERE
                                    rcta1.customer_trx_id = rec_line.customer_trx_id
							) ) > 0.01 --added to consider where amt applied and inv amount having diff 0.01 to be considered from invoice
                             THEN ROUND( ( ( (
                                CASE
                                    WHEN NVL(rec_line.accounted_cr,0) != 0
                                         AND NVL(rev_line_sum.sum_acc_cr,0) != 0 THEN rev_line_sum.sum_acc_cr
                                    WHEN NVL(rec_line.accounted_cr,0) != 0
                                         AND NVL(rev_line_sum.sum_acc_dr,0) != 0 THEN rev_line_sum.sum_acc_dr
                                END
                            ) * (aaa.amount *-1) ) --added as adj are negative
                             / (
                                SELECT
                                    SUM(rcta1.extended_amount)
                                FROM
                                    ra_customer_trx_lines_all rcta1
                                WHERE
                                    rcta1.customer_trx_id = rec_line.customer_trx_id
                                    AND line_type = 'LINE'
                            ) ),3)
                            ELSE (
                                CASE
                                    WHEN NVL(rec_line.accounted_cr,0) != 0
                                         AND NVL(rev_line_sum.sum_acc_cr,0) != 0 THEN rev_line_sum.sum_acc_cr
                                    WHEN NVL(rec_line.accounted_cr,0) != 0
                                         AND NVL(rev_line_sum.sum_acc_dr,0) != 0 THEN rev_line_sum.sum_acc_dr
                                END
                            )
                        END
                    acc_cr,
                    CASE
                            WHEN ABS(aaa.amount - (
                                SELECT
                                    SUM(rcta1.extended_amount)
                                FROM
                                    ra_customer_trx_lines_all rcta1
                                WHERE
                                    rcta1.customer_trx_id = rec_line.customer_trx_id
							) ) > 0.01 --added to consider where amt applied and inv amount having diff 0.01 to be considered from invoice
                             THEN ROUND( ( ( (
                                CASE
                                    WHEN NVL(rec_line.entered_dr,0) != 0
                                         AND NVL(rev_line_sum.sum_ent_dr,0) != 0 THEN rev_line_sum.sum_ent_dr
                                    WHEN NVL(rec_line.entered_dr,0) != 0
                                         AND NVL(rev_line_sum.sum_ent_cr,0) != 0 THEN rev_line_sum.sum_ent_cr
                                END
                            ) * (aaa.amount *-1) ) --added as adj are negative
                             / (
                                SELECT
                                    SUM(rcta1.extended_amount)
                                FROM
                                    ra_customer_trx_lines_all rcta1
                                WHERE
                                    rcta1.customer_trx_id = rec_line.customer_trx_id
                                    AND line_type = 'LINE'
                            ) ),3)
                            ELSE (
                                CASE
                                    WHEN NVL(rec_line.entered_dr,0) != 0
                                         AND NVL(rev_line_sum.sum_ent_dr,0) != 0 THEN rev_line_sum.sum_ent_dr
                                    WHEN NVL(rec_line.entered_dr,0) != 0
                                         AND NVL(rev_line_sum.sum_ent_cr,0) != 0 THEN rev_line_sum.sum_ent_cr
                                END
                            )
                        END
                    ent_dr,
                    CASE
                            WHEN ABS(aaa.amount - (
                                SELECT
                                    SUM(rcta1.extended_amount)
                                FROM
                                    ra_customer_trx_lines_all rcta1
                                WHERE
                                    rcta1.customer_trx_id = rec_line.customer_trx_id
							) ) > 0.01 --added to consider where amt applied and inv amount having diff 0.01 to be considered from invoice
                             THEN ROUND( ( ( (
                                CASE
                                    WHEN NVL(rec_line.accounted_dr,0) != 0
                                         AND NVL(rev_line_sum.sum_acc_dr,0) != 0 THEN rev_line_sum.sum_acc_dr
                                    WHEN NVL(rec_line.accounted_dr,0) != 0
                                         AND NVL(rev_line_sum.sum_acc_cr,0) != 0 THEN rev_line_sum.sum_acc_cr
                                END
                            ) * (aaa.amount *-1) ) --added as adj are negative
                             / (
                                SELECT
                                    SUM(rcta1.extended_amount)
                                FROM
                                    ra_customer_trx_lines_all rcta1
                                WHERE
                                    rcta1.customer_trx_id = rec_line.customer_trx_id
                                    AND line_type = 'LINE'
                            ) ),3)
                            ELSE (
                                CASE
                                    WHEN NVL(rec_line.accounted_dr,0) != 0
                                         AND NVL(rev_line_sum.sum_acc_dr,0) != 0 THEN rev_line_sum.sum_acc_dr
                                    WHEN NVL(rec_line.accounted_dr,0) != 0
                                         AND NVL(rev_line_sum.sum_acc_cr,0) != 0 THEN rev_line_sum.sum_acc_cr
                                END
                            )
                        END
                    acc_dr
                FROM
                    REC_LINE,
                    REV_LINE_SUM,
                    AR_ADJUSTMENTS_ALL aaa,
                    GL_PERIODS glp
                WHERE
                    rec_line.customer_trx_id = rev_line_sum.customer_trx_id
                    AND rec_line.ledger_id = rev_line_sum.ledger_id
                    AND aaa.customer_trx_id = rec_line.customer_trx_id
                    AND aaa.status = 'A'
                    AND aaa.posting_control_id !=-3 --for not picking unposted
                    AND aaa.type != 'TAX'
                    AND aaa.gl_date BETWEEN glp.start_date AND glp.end_date
                    AND glp.period_set_name = 'CCL CALENDAR'
                    AND glp.period_name NOT LIKE 'ADJ%'
--Start Last successful run logic
/*--REL053 GERITM20414034 Starts
                    AND TRUNC(aaa.gl_date) BETWEEN NVL( (TO_DATE(:p_from_date,'YYYY-MM-DD') ),NVL( (
                        SELECT
                            MAX(ERH.processstart)
                        FROM
                            ESS_REQUEST_HISTORY ERH,ESS_REQUEST_PROPERTY ERP1
                        WHERE
                            ERH.requestid = ERP1.requestid
                            AND ERH.definition = 'JobDefinition://oracle/apps/ess/custom/GL/CirrusARJournalReclassSummaryReporttoFBDIConvert'
                            AND ERH.executable_status = 'SUCCEEDED'
                            AND ERP1.name = 'submit.argument4'
                            AND ERP1.value = TO_CHAR(:p_bu_name)
                    ),TO_DATE('2020-08-01','YYYY-MM-DD') ) ) AND NVL(TO_DATE(:p_to_date,'YYYY-MM-DD'),TRUNC(SYSDATE) )
					*/ --REL053 GERITM20414034 Ends
                    AND ( aaa.gl_posted_date > NVL( (
                        SELECT
                            MAX(ERH.processstart)
                        FROM
                            ESS_REQUEST_HISTORY ERH,ESS_REQUEST_PROPERTY ERP1
                        WHERE
                            ERH.requestid = ERP1.requestid
                            AND ERH.definition = 'JobDefinition://oracle/apps/ess/custom/GL/CirrusARJournalReclassSummaryReporttoFBDIConvert'
                            AND ERH.executable_status = 'SUCCEEDED'
                            AND ERP1.name = 'submit.argument4'
                              -- AND ERP1.value = TO_CHAR(:p_bu_name)--REL053 GERITM20414034 Commenetd
						   AND ERP1.value = NVL(TO_CHAR(:p_bu_name),erp1.value)--REL053 GERITM20414034 Added
                    ),TO_DATE('2020-08-01','YYYY-MM-DD') ) )
--End Last successful run logic
                UNION ALL
                SELECT
                    1 AS "KEY",
                    'Adjustment' transaction_type,
                    rec_line.ledger_name,
                    rec_line.bu_name,
                    glp.period_name--rec_line.period_name
                   ,
                    aaa.adjustment_number trx_number,
                    rec_line.je_category_name,
                    rec_line.ledger_id,
                    rec_line.currency_code,
                    TO_CHAR(aaa.apply_date,'YYYY-MM-DD') trx_date,
                    'RECEIVABLE' accounting_class_code,
                    rec_line.segment1,
                    rec_line.segment2,
                    rec_line.segment3,
                    rev_line.segment4,
                    rec_line.segment5,
                    rec_line.segment6,
                    rec_line.segment7,
                    rev_line.segment8,
                    rec_line.segment9,
                    rec_line.segment10,
                    rec_line.segment11,
                    CASE
                            WHEN ABS(aaa.amount - (
                                SELECT
                                    SUM(rcta1.extended_amount)
                                FROM
                                    ra_customer_trx_lines_all rcta1
                                WHERE
                                    rcta1.customer_trx_id = rec_line.customer_trx_id
							) ) > 0.01 --added to consider where amt applied and inv amount having diff 0.01 to be considered from invoice
                             THEN ROUND( ( ( (
                                CASE
                                    WHEN NVL(rec_line.entered_dr,0) != 0
                                         AND NVL(rev_line.entered_dr,0) != 0 THEN NVL(rev_line.entered_dr,0)
                                    WHEN NVL(rec_line.entered_dr,0) != 0
                                         AND NVL(rev_line.entered_cr,0) != 0 THEN rev_line.entered_cr
                                END
                            ) * (aaa.amount *-1) ) --added as adj are negative
                             / (
                                SELECT
                                    SUM(rcta1.extended_amount)
                                FROM
                                    ra_customer_trx_lines_all rcta1
                                WHERE
                                    rcta1.customer_trx_id = rec_line.customer_trx_id
                                    AND line_type = 'LINE'
                            ) ),3)
                            ELSE (
                                CASE
                                    WHEN NVL(rec_line.entered_dr,0) != 0
                                         AND NVL(rev_line.entered_dr,0) != 0 THEN NVL(rev_line.entered_dr,0)
                                    WHEN NVL(rec_line.entered_dr,0) != 0
                                         AND NVL(rev_line.entered_cr,0) != 0 THEN rev_line.entered_cr
                                END
                            )
                        END
                    ent_cr,
                    CASE
                            WHEN ABS(aaa.amount - (
                                SELECT
                                    SUM(rcta1.extended_amount)
                                FROM
                                    ra_customer_trx_lines_all rcta1
                                WHERE
                                    rcta1.customer_trx_id = rec_line.customer_trx_id
							) ) > 0.01 --added to consider where amt applied and inv amount having diff 0.01 to be considered from invoice
                             THEN ROUND( ( ( (
                                CASE
                                    WHEN NVL(rec_line.accounted_dr,0) != 0
                                         AND NVL(rev_line.accounted_dr,0) != 0 THEN NVL(rev_line.accounted_dr,0)
                                    WHEN NVL(rec_line.accounted_dr,0) != 0
                                         AND NVL(rev_line.accounted_cr,0) != 0 THEN rev_line.accounted_cr
                                END
                            ) * (aaa.amount *-1) ) --added as adj are negative
                             / (
                                SELECT
                                    SUM(rcta1.extended_amount)
                                FROM
                                    ra_customer_trx_lines_all rcta1
                                WHERE
                                    rcta1.customer_trx_id = rec_line.customer_trx_id
                                    AND line_type = 'LINE'
                            ) ),3)
                            ELSE (
                                CASE
                                    WHEN NVL(rec_line.accounted_dr,0) != 0
                                         AND NVL(rev_line.accounted_dr,0) != 0 THEN NVL(rev_line.accounted_dr,0)
                                    WHEN NVL(rec_line.accounted_dr,0) != 0
                                         AND NVL(rev_line.accounted_cr,0) != 0 THEN rev_line.accounted_cr
                                END
                            )
                        END
                    acc_cr,
                    CASE
                            WHEN ABS(aaa.amount - (
                                SELECT
                                    SUM(rcta1.extended_amount)
                                FROM
                                    ra_customer_trx_lines_all rcta1
                                WHERE
                                    rcta1.customer_trx_id = rec_line.customer_trx_id
							) ) > 0.01 --added to consider where amt applied and inv amount having diff 0.01 to be considered from invoice
                             THEN ROUND( ( ( (
                                CASE
                                    WHEN NVL(rec_line.entered_cr,0) != 0
                                         AND NVL(rev_line.entered_cr,0) != 0 THEN NVL(rev_line.entered_cr,0)
                                    WHEN NVL(rec_line.entered_cr,0) != 0
                                         AND NVL(rev_line.entered_dr,0) != 0 THEN rev_line.entered_dr
                                END
                            ) * (aaa.amount *-1) ) --added as adj are negative
                             / (
                                SELECT
                                    SUM(rcta1.extended_amount)
                                FROM
                                    ra_customer_trx_lines_all rcta1
                                WHERE
                                    rcta1.customer_trx_id = rec_line.customer_trx_id
                                    AND line_type = 'LINE'
                            ) ),3)
                            ELSE (
                                CASE
                                    WHEN NVL(rec_line.entered_cr,0) != 0
                                         AND NVL(rev_line.entered_cr,0) != 0 THEN NVL(rev_line.entered_cr,0)
                                    WHEN NVL(rec_line.entered_cr,0) != 0
                                         AND NVL(rev_line.entered_dr,0) != 0 THEN rev_line.entered_dr
                                END
                            )
                        END
                    ent_dr,
                    CASE
                            WHEN ABS(aaa.amount - (
                                SELECT
                                    SUM(rcta1.extended_amount)
                                FROM
                                    ra_customer_trx_lines_all rcta1
                                WHERE
                                    rcta1.customer_trx_id = rec_line.customer_trx_id
							) ) > 0.01 --added to consider where amt applied and inv amount having diff 0.01 to be considered from invoice
                             THEN ROUND( ( ( (
                                CASE
                                    WHEN NVL(rec_line.accounted_cr,0) != 0
                                         AND NVL(rev_line.accounted_cr,0) != 0 THEN NVL(rev_line.accounted_cr,0)
                                    WHEN NVL(rec_line.accounted_cr,0) != 0
                                         AND NVL(rev_line.accounted_dr,0) != 0 THEN rev_line.accounted_dr
                                END
                            ) * (aaa.amount *-1) ) --added as adj are negative
                             / (
                                SELECT
                                    SUM(rcta1.extended_amount)
                                FROM
                                    ra_customer_trx_lines_all rcta1
                                WHERE
                                    rcta1.customer_trx_id = rec_line.customer_trx_id
                                    AND line_type = 'LINE'
                            ) ),3)
                            ELSE (
                                CASE
                                    WHEN NVL(rec_line.accounted_cr,0) != 0
                                         AND NVL(rev_line.accounted_cr,0) != 0 THEN NVL(rev_line.accounted_cr,0)
                                    WHEN NVL(rec_line.accounted_cr,0) != 0
                                         AND NVL(rev_line.accounted_dr,0) != 0 THEN rev_line.accounted_dr
                                END
                            )
                        END
                    acc_dr
                FROM
                    REC_LINE,
                    REV_LINE,
                    AR_ADJUSTMENTS_ALL aaa,
                    GL_PERIODS glp
                WHERE
                    rec_line.customer_trx_id = rev_line.customer_trx_id
                    AND rec_line.ledger_id = rev_line.ledger_id
                    AND aaa.customer_trx_id = rec_line.customer_trx_id
                    AND aaa.status = 'A'
                    AND aaa.posting_control_id !=-3 --for not picking unposted
                    AND aaa.type != 'TAX'
                    AND aaa.gl_date BETWEEN glp.start_date AND glp.end_date
                    AND glp.period_set_name = 'CCL CALENDAR'
                    AND glp.period_name NOT LIKE 'ADJ%'
--Start Last successful run logic
/* --REL053 GERITM20414034 Starts
                    AND TRUNC(aaa.gl_date) BETWEEN NVL( (TO_DATE(:p_from_date,'YYYY-MM-DD') ),NVL( (
                        SELECT
                            MAX(ERH.processstart)
                        FROM
                            ESS_REQUEST_HISTORY ERH,ESS_REQUEST_PROPERTY ERP1
                        WHERE
                            ERH.requestid = ERP1.requestid
                            AND ERH.definition = 'JobDefinition://oracle/apps/ess/custom/GL/CirrusARJournalReclassSummaryReporttoFBDIConvert'
                            AND ERH.executable_status = 'SUCCEEDED'
                            AND ERP1.name = 'submit.argument4'
                            AND ERP1.value = TO_CHAR(:p_bu_name)
                    ),TO_DATE('2020-08-01','YYYY-MM-DD') ) ) AND NVL(TO_DATE(:p_to_date,'YYYY-MM-DD'),TRUNC(SYSDATE) )
					*/ --REL053 GERITM20414034 Ends
                    AND ( aaa.gl_posted_date > NVL( (
                        SELECT
                            MAX(ERH.processstart)
                        FROM
                            ESS_REQUEST_HISTORY ERH,ESS_REQUEST_PROPERTY ERP1
                        WHERE
                            ERH.requestid = ERP1.requestid
                            AND ERH.definition = 'JobDefinition://oracle/apps/ess/custom/GL/CirrusARJournalReclassSummaryReporttoFBDIConvert'
                            AND ERH.executable_status = 'SUCCEEDED'
                            AND ERP1.name = 'submit.argument4'
                              -- AND ERP1.value = TO_CHAR(:p_bu_name)--REL053 GERITM20414034 Commenetd
						   AND ERP1.value = NVL(TO_CHAR(:p_bu_name),erp1.value)--REL053 GERITM20414034 Added
                    ),TO_DATE('2020-08-01','YYYY-MM-DD') ) )
--End Last successful run logic
--Adjustment end
            )
        WHERE
            NVL(ent_cr,0) != 0
            OR NVL(ent_dr,0) != 0
            OR NVL(acc_cr,0) != 0
            OR NVL(acc_dr,0) != 0 --to eliminate 0 lines
        GROUP BY
            transaction_type,
            ledger_name,
            bu_name,
            period_name,
            ledger_id,
            je_category_name,
            currency_code,
            segment1,
            segment2,
            segment3,
            segment4,
            segment5,
            segment6,
            segment7,
            segment8,
            segment9,
            segment10,
            segment11
    )))!=0
	--REL 047 GERITM13412360 ends