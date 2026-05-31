--#-----------------------------------------------------------------------------------------------------#
--# MODIFICATION HISTORY:
--# CR#                       Author             Date                Description
--#-----------------------------------------------------------------------------------------------------#
--# REL-043				Sowndarya Perumal		14-AUG-2020		Initial Version
--# REL-043-EMG			Sowndarya Perumal		25-AUG-2020		updated p_from_date for first run as '2020-08-01'	
--#	REL-049				Akash Mohanty			05-FEB-2021		Change to ignore accounting date and consider posting date only 
--# REL-053				Nuri Chetia	            20-FEB-2021	    GERITM20414034 Perfomance tuning in the code
--#-----------------------------------------------------------------------------------------------------#
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
        gjh.posted_date,
        gjb.name
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
        GL_JE_HEADERS gjh,
        GL_JE_BATCHES gjb
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
        AND gjh.je_batch_id = gjb.je_batch_id
        --REL-053 GERITM20414034 Starts
		AND rcta.org_id = NVL(:p_bu_name,rcta.org_id)
		AND ( gjh.posted_date > NVL( (
                SELECT
                    MAX(erh.processstart) 
                FROM
                    ess_request_history erh,ess_request_property erp1
                WHERE
                    erh.requestid = erp1.requestid
                    AND erh.definition = 'JobDefinition://oracle/apps/ess/custom/GL/CirrusARJournalReclassDetailReport'
                    AND erh.executable_status = 'SUCCEEDED'
                    AND erp1.name = 'submit.argument4'
					AND erp1.value = NVL(TO_CHAR(:p_bu_name),erp1.value)	
            ),TO_DATE('2020-08-01','YYYY-MM-DD') ) )
         --REL-053 GERITM20414034 Ends
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
        AND rcta.org_id = NVL(:p_bu_name,rcta.org_id)	--REL-053 GERITM20414034 added  
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
        xal.accounted_dr
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
        AND rcta.org_id = NVL(:p_bu_name,rcta.org_id)	--REL-053 GERITM20414034 added
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
      --REL-053 GERITM20414034 Starts
		AND arca.org_id = NVL(:p_bu_name,arca.org_id)
		AND ( gjh.posted_date > NVL( (
                SELECT
                    MAX(erh.processstart)
                FROM
                    ess_request_history erh,ess_request_property erp1
                WHERE
                    erh.requestid = erp1.requestid
                    AND erh.definition = 'JobDefinition://oracle/apps/ess/custom/GL/CirrusARJournalReclassDetailReport'
                    AND erh.executable_status = 'SUCCEEDED'
                    AND erp1.name = 'submit.argument4'
               	AND erp1.value = NVL(TO_CHAR(:p_bu_name),erp1.value)
            ),TO_DATE('2020-08-01','YYYY-MM-DD') ) )
            	--REL-053 GERITM20414034 Ends
) SELECT
    1 AS "KEY",
    transaction_type,
    ledger_name,
    bu_name,
    period_name,
    trx_number,
    trx_date,
    accounting_class_code,
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
    ent_cr,
    acc_cr,
    ent_dr,
    acc_dr,
    name
  FROM
    (
        SELECT
            1 AS "KEY",
            rec_line.trx_type_name transaction_type,
            rec_line.ledger_name,
            rec_line.bu_name,
            rec_line.period_name,
            rec_line.trx_number,
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
            ) acc_dr,
            rec_line.name
        FROM
            REC_LINE,
            REV_LINE_SUM
        WHERE
            rec_line.customer_trx_id = rev_line_sum.customer_trx_id
            AND rec_line.ledger_id = rev_line_sum.ledger_id
--Start Last successful run logic
-- Commented below code for REL-049	
           /* AND TRUNC(rec_line.accounting_date) BETWEEN NVL( (TO_DATE(:p_from_date,'YYYY-MM-DD') ),NVL( (
                SELECT
                    MAX(erh.processstart)
                FROM
                    ESS_REQUEST_HISTORY erh,ESS_REQUEST_PROPERTY erp1
                WHERE
                    erh.requestid = erp1.requestid
                    AND erh.definition = 'JobDefinition://oracle/apps/ess/custom/GL/CirrusARJournalReclassDetailReport'
                    AND erh.executable_status = 'SUCCEEDED'
                    AND erp1.name = 'submit.argument4'
                     --AND erp1.value = TO_CHAR(:p_bu_name)	--REL-053 GERITM20414034 Commenetd
					AND erp1.value = NVL(TO_CHAR(:p_bu_name),erp1.value)	--REL-053 GERITM20414034 Added
            ),TO_DATE('2020-08-01','YYYY-MM-DD') ) ) AND NVL(TO_DATE(:p_to_date,'YYYY-MM-DD'),TRUNC(SYSDATE) )*/
-- End of comment for REL-049            
			AND ( rec_line.posted_date > NVL( (
                SELECT
                    MAX(erh.processstart)
                FROM
                    ESS_REQUEST_HISTORY erh,ESS_REQUEST_PROPERTY erp1
                WHERE
                    erh.requestid = erp1.requestid
                    AND erh.definition = 'JobDefinition://oracle/apps/ess/custom/GL/CirrusARJournalReclassDetailReport'
                    AND erh.executable_status = 'SUCCEEDED'
                    AND erp1.name = 'submit.argument4'
                     --AND erp1.value = TO_CHAR(:p_bu_name)	--REL-053 GERITM20414034 Commenetd
					AND erp1.value = NVL(TO_CHAR(:p_bu_name),erp1.value)	--REL-053 GERITM20414034 Added
            ),TO_DATE('2020-08-01','YYYY-MM-DD') ) )
--End Last successful run logic
        UNION ALL
        SELECT
            1 AS "KEY",
            rec_line.trx_type_name transaction_type,
            rec_line.ledger_name,
            rec_line.bu_name,
            rec_line.period_name,
            rec_line.trx_number,
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
            acc_dr,
            rec_line.name
        FROM
            REC_LINE,
            REV_LINE
        WHERE
            rec_line.customer_trx_id = rev_line.customer_trx_id
            AND rec_line.ledger_id = rev_line.ledger_id
--Start Last successful run logic
-- Commented below code for REL-049	
         /*   AND TRUNC(rec_line.accounting_date) BETWEEN NVL( (TO_DATE(:p_from_date,'YYYY-MM-DD') ),NVL( (
                SELECT
                    MAX(erh.processstart)
                FROM
                    ESS_REQUEST_HISTORY erh,ESS_REQUEST_PROPERTY erp1
                WHERE
                    erh.requestid = erp1.requestid
                    AND erh.definition = 'JobDefinition://oracle/apps/ess/custom/GL/CirrusARJournalReclassDetailReport'
                    AND erh.executable_status = 'SUCCEEDED'
                    AND erp1.name = 'submit.argument4'
                    AND erp1.value = TO_CHAR(:p_bu_name)
            ),TO_DATE('2020-08-01','YYYY-MM-DD') ) ) AND NVL(TO_DATE(:p_to_date,'YYYY-MM-DD'),TRUNC(SYSDATE) )*/
-- End of comment for REL-049		
			AND ( rec_line.posted_date > NVL( (
                SELECT
                    MAX(erh.processstart)
                FROM
                    ESS_REQUEST_HISTORY erh,ESS_REQUEST_PROPERTY erp1
                WHERE
                    erh.requestid = erp1.requestid
                    AND erh.definition = 'JobDefinition://oracle/apps/ess/custom/GL/CirrusARJournalReclassDetailReport'
                    AND erh.executable_status = 'SUCCEEDED'
                    AND erp1.name = 'submit.argument4'
                    --AND erp1.value = TO_CHAR(:p_bu_name)	--REL-053 GERITM20414034 Commenetd
					AND erp1.value = NVL(TO_CHAR(:p_bu_name),erp1.value)	--REL-053 GERITM20414034 Added
            ),TO_DATE('2020-08-01','YYYY-MM-DD') ) )
--End Last successful run logic
        UNION ALL
--Receipt start
        SELECT
            1 AS "KEY",
            'Receipt'--rec_line.transaction_type
           ,
            rec_line.ledger_name,
            rec_line.bu_name,
            glp.period_name--rec_line.period_name
           ,
            arca.receipt_number,
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
            acc_dr,
            rec_line.name
        FROM
            REC_LINE,
            REV_LINE_SUM,
            RECEIPT_ACC,
            AR_RECEIVABLE_APPLICATIONS_ALL araa,
            AR_CASH_RECEIPTS_ALL arca,
            GL_PERIODS glp
        WHERE
            rec_line.customer_trx_id = rev_line_sum.customer_trx_id
            AND rec_line.ledger_id = rev_line_sum.ledger_id
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
            AND period_set_name = 'CCL CALENDAR'
            AND glp.period_name NOT LIKE 'ADJ%'
--Start Last successful run logic
-- Commented below code for REL-049	
           /* AND TRUNC(araa.gl_date) BETWEEN NVL( (TO_DATE(:p_from_date,'YYYY-MM-DD') ),NVL( (
                SELECT
                    MAX(erh.processstart)
                FROM
                    ess_request_history erh,ess_request_property erp1
                WHERE
                    erh.requestid = erp1.requestid
                    AND erh.definition = 'JobDefinition://oracle/apps/ess/custom/GL/CirrusARJournalReclassDetailReport'
                    AND erh.executable_status = 'SUCCEEDED'
                    AND erp1.name = 'submit.argument4'
                    AND erp1.value = TO_CHAR(:p_bu_name)
            ),TO_DATE('2020-08-01','YYYY-MM-DD') ) ) AND NVL(TO_DATE(:p_to_date,'YYYY-MM-DD'),TRUNC(SYSDATE) )*/
-- End of comment for REL-049           
		   AND ( receipt_acc.posted_date > NVL( (
                SELECT
                    MAX(erh.processstart)
                FROM
                    ess_request_history erh,ess_request_property erp1
                WHERE
                    erh.requestid = erp1.requestid
                    AND erh.definition = 'JobDefinition://oracle/apps/ess/custom/GL/CirrusARJournalReclassDetailReport'
                    AND erh.executable_status = 'SUCCEEDED'
                    AND erp1.name = 'submit.argument4'
                    --AND erp1.value = TO_CHAR(:p_bu_name)	--REL-053 GERITM20414034 Commenetd
		AND erp1.value = NVL(TO_CHAR(:p_bu_name),erp1.value)	--REL-053 GERITM20414034 Added
            ),TO_DATE('2020-08-01','YYYY-MM-DD') ) )
--End Last successful run logic
        UNION ALL
        SELECT
            1 AS "KEY",
            'Receipt'--rec_line.transaction_type
           ,
            rec_line.ledger_name,
            rec_line.bu_name,
            glp.period_name--rec_line.period_name
           ,
            arca.receipt_number,
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
            acc_dr,
            rec_line.name
        FROM
            REC_LINE,
            REV_LINE,
            RECEIPT_ACC,
            AR_RECEIVABLE_APPLICATIONS_ALL araa,
            AR_CASH_RECEIPTS_ALL arca,
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
-- Commented below code for REL-049	
          /*  AND TRUNC(araa.gl_date) BETWEEN NVL( (TO_DATE(:p_from_date,'YYYY-MM-DD') ),NVL( (
                SELECT
                    MAX(erh.processstart)
                FROM
                    ESS_REQUEST_HISTORY erh,ESS_REQUEST_PROPERTY erp1
                WHERE
                    erh.requestid = erp1.requestid
                    AND erh.definition = 'JobDefinition://oracle/apps/ess/custom/GL/CirrusARJournalReclassDetailReport'
                    AND erh.executable_status = 'SUCCEEDED'
                    AND erp1.name = 'submit.argument4'
                    AND erp1.value = TO_CHAR(:p_bu_name)
            ),TO_DATE('2020-08-01','YYYY-MM-DD') ) ) AND NVL(TO_DATE(:p_to_date,'YYYY-MM-DD'),TRUNC(SYSDATE) ) */
-- End of comment for REL-049           
			AND ( receipt_acc.posted_date > NVL( (
                SELECT
                    MAX(erh.processstart)
                FROM
                    ESS_REQUEST_HISTORY erh,ESS_REQUEST_PROPERTY erp1
                WHERE
                    erh.requestid = erp1.requestid
                    AND erh.definition = 'JobDefinition://oracle/apps/ess/custom/GL/CirrusARJournalReclassDetailReport'
                    AND erh.executable_status = 'SUCCEEDED'
                    AND erp1.name = 'submit.argument4'
                    --AND erp1.value = TO_CHAR(:p_bu_name)	--REL-053 GERITM20414034 Commented
					AND erp1.value = NVL(TO_CHAR(:p_bu_name),erp1.value)	--REL-053 GERITM20414034 Added
            ),TO_DATE('2020-08-01','YYYY-MM-DD') ) )
--End Last successful run logic
--Adjustments start
        UNION ALL
        SELECT
            1 AS "KEY",
            'Adjustment' transaction_type,
            rec_line.ledger_name,
            rec_line.bu_name,
            glp.period_name--rec_line.period_name
           ,
            aaa.adjustment_number trx_number,
            TO_CHAR(aaa.apply_date,'YYYY-MM-DD') trx_date
           ,
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
            acc_dr,
            rec_line.name
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
            AND aaa.posting_control_id !=-3 --for not posted
            AND aaa.type != 'TAX'
            AND aaa.gl_date BETWEEN glp.start_date AND glp.end_date
            AND glp.period_set_name = 'CCL CALENDAR'
            AND glp.period_name NOT LIKE 'ADJ%'
--Start Last successful run logic
-- Commented below code for REL-049	
         /*   AND TRUNC(aaa.gl_date) BETWEEN NVL( (TO_DATE(:p_from_date,'YYYY-MM-DD') ),NVL( (
                SELECT
                    MAX(erh.processstart)
                FROM
                    ESS_REQUEST_HISTORY erh,ESS_REQUEST_PROPERTY erp1
                WHERE
                    erh.requestid = erp1.requestid
                    AND erh.definition = 'JobDefinition://oracle/apps/ess/custom/GL/CirrusARJournalReclassDetailReport'
                    AND erh.executable_status = 'SUCCEEDED'
                    AND erp1.name = 'submit.argument4'
                    AND erp1.value = TO_CHAR(:p_bu_name)
            ),TO_DATE('2020-08-01','YYYY-MM-DD') ) ) AND NVL(TO_DATE(:p_to_date,'YYYY-MM-DD'),TRUNC(SYSDATE) ) */
-- End of comment for REL-049            
			AND ( aaa.gl_posted_date > NVL( (
                SELECT
                    MAX(erh.processstart)
                FROM
                    ESS_REQUEST_HISTORY erh,ESS_REQUEST_PROPERTY erp1
                WHERE
                    erh.requestid = erp1.requestid
                    AND erh.definition = 'JobDefinition://oracle/apps/ess/custom/GL/CirrusARJournalReclassDetailReport'
                    AND erh.executable_status = 'SUCCEEDED'
                    AND erp1.name = 'submit.argument4'
                    --AND erp1.value = TO_CHAR(:p_bu_name)	--REL-053 GERITM20414034 Commented
					AND erp1.value = NVL(TO_CHAR(:p_bu_name),erp1.value)	--REL-053 GERITM20414034 Added
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
            acc_dr,
            rec_line.name
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
            AND aaa.posting_control_id !=-3 --for not posted
            AND aaa.type != 'TAX'
            AND aaa.gl_date BETWEEN glp.start_date AND glp.end_date
            AND glp.period_set_name = 'CCL CALENDAR'
            AND glp.period_name NOT LIKE 'ADJ%'
--Start Last successful run logic
-- Commented below code for REL-049	
           /* AND TRUNC(aaa.gl_date) BETWEEN NVL( (TO_DATE(:p_from_date,'YYYY-MM-DD') ),NVL( (
                SELECT
                    MAX(erh.processstart)
                FROM
                    ESS_REQUEST_HISTORY erh,ESS_REQUEST_PROPERTY erp1
                WHERE
                    erh.requestid = erp1.requestid
                    AND erh.definition = 'JobDefinition://oracle/apps/ess/custom/GL/CirrusARJournalReclassDetailReport'
                    AND erh.executable_status = 'SUCCEEDED'
                    AND erp1.name = 'submit.argument4'
                    AND erp1.value = TO_CHAR(:p_bu_name)
            ),TO_DATE('2020-08-01','YYYY-MM-DD') ) ) AND NVL(TO_DATE(:p_to_date,'YYYY-MM-DD'),TRUNC(SYSDATE) )*/
-- End of comment for REL-049            
			AND ( aaa.gl_posted_date > NVL( (
                SELECT
                    MAX(erh.processstart)
                FROM
                    ESS_REQUEST_HISTORY erh,ESS_REQUEST_PROPERTY erp1
                WHERE
                    erh.requestid = erp1.requestid
                    AND erh.definition = 'JobDefinition://oracle/apps/ess/custom/GL/CirrusARJournalReclassDetailReport'
                    AND erh.executable_status = 'SUCCEEDED'
                    AND erp1.name = 'submit.argument4'
                    --AND erp1.value = TO_CHAR(:p_bu_name)	--REL-053 GERITM20414034 Commented
					AND erp1.value = NVL(TO_CHAR(:p_bu_name),erp1.value)	--REL-053 GERITM20414034 Added
            ),TO_DATE('2020-08-01','YYYY-MM-DD') ) )
--End Last successful run logic
--Adjustments end
    )
  WHERE
    NVL(ent_cr,0) != 0
    OR NVL(ent_dr,0) != 0
    OR NVL(acc_cr,0) != 0
    OR NVL(acc_dr,0) != 0 --to eliminate 0 lines
ORDER BY
    transaction_type,
    trx_number,
    segment8