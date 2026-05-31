/*
*************************************************************************************************
-- Name             : Cirrus CST FX MJE Reconciliation Report
-- Date             : 03/26/18
-- Author           : Himanshu Singh
-- Purpose          : 
-- Type             : Sql
*************************************************************************************************
-- Change history
-- Version         Date          Developer                            Description  
-- 1.0           03/26/18		 Nitin Bhatt  						  REL-015 EMG Cirrus CST FX MJE Reconciliation Report
*************************************************************************************************
*/
SELECT gl.name ledger_name, gjc.user_je_category_name category_name, gjs.user_je_source_name source_name, gjh.period_name, gjb.name batch_name, 
       gjh.name journal_name, gjl.je_line_num, gjh.external_reference distribution_id, SUBSTR(gjl.reference_6, 3) distribution_line_id, 
       gcc.segment1,
	   gcc.segment2,
	   gcc.segment3,
	   gcc.segment4,
	   gcc.segment5,
	   gcc.segment6,
	   gcc.segment7,
	   gcc.segment8,
	   gcc.segment9,
	   gcc.segment10,
	   gcc.segment11,
       gjl.accounted_dr, gjl.accounted_cr,
	   DECODE(gjh.status, 'U', 'Unposted', 
						'P', 'Posted',
						'1', 'Invalid currency code',
						'2', 'Invalid source',
						'3', 'Invalid category',
						'4', 'Invalid ledger',
						'5', 'Invalid period name',
						'6', '(Actual) Unopened period',
						'6', '(Budget) Invalid budget version',
						'6', '(Encumbrance) Invalid encumbrance type',
						'7', 'Invalid entry',
						'8', 'Invalid entry',
						'A', 'Code combination does not exist',
						'C', 'Code combination: detail posting not allowed',
						'F', 'Code combination not enabled',
						'G', 'Invalid or inactive suspense account',
						'H', 'Invalid or inactive reserve for encumbrance account',
						'J', 'Code combination not yet valid on effective date',
						'K', 'Unbalanced intercompany journal entry',
						'L', 'Unbalanced journal entry by account category',
						'M', 'Code combination past effective date',
						'N', 'Intercompany processing error',
						'O', 'Missing conversion rate to replicate journal',
						'V', 'Multiple lines have code combination errors',
						'W', 'Frozen budget',
						'X', 'Frozen budget organization',
						'Y', 'Frozen budget account',
						'Z', 'Multiple lines have code combination errors',
						'-', 'Invalid or inactive rounding differences account',
						'<', 'Sequence assignment failed',
						'>', 'Cutoff rule was violated',
						'+', 'CTA account failed validation',
						'b', 'No write access to generated ledger account',
						'd', 'No write access to reporting currency/segment',
						'e', 'Invalid segment in generated ledger account',
						'h', 'Invalid account in chart of accounts mapping',
						'i', 'Unable to determine journal effective date',
						 gjh.status)status,
		TO_CHAR(gjl.creation_date, 'dd-Mon-yyyy HH24:MI:SS', 'NLS_DATE_LANGUAGE = American')creation_date, gjh.created_by,
		gjl.currency_code,
		---
		cco.cost_org_code,
		ccbb.cost_book_code,
		TO_CHAR(ct.creation_date, 'dd-Mon-yyyy HH24:MI:SS', 'NLS_DATE_LANGUAGE = American') transaction_creation_date,
		TO_CHAR(ct.transaction_date, 'dd-Mon-yyyy HH24:MI:SS', 'NLS_DATE_LANGUAGE = American')transaction_date,
		NVL(
			(SELECT pha.segment1
               FROM PO_HEADERS_ALL         pha, 
			        PO_LINES_ALL           pla, 
					PO_DISTRIBUTIONS_ALL   pod
              WHERE pha.po_header_id       = pod.po_header_id
                AND pha.po_header_id       = pla.po_header_id
                AND pod.po_line_id         = pla.po_line_id
                AND pod.po_distribution_id = ct.po_distribution_id                                                                
                AND ROWNUM                 = 1
		    ),
				(SELECT pha.segment1
                   FROM PO_HEADERS_ALL          pha, 
				        PO_LINES_ALL            pla, 
					    PO_DISTRIBUTIONS_ALL    pod,
					    CST_TRANSACTIONS        rcpt_trx
                  WHERE pha.po_header_id        = pod.po_header_id
                    AND pha.po_header_id        = pla.po_header_id
                    AND pod.po_line_id          = pla.po_line_id
                    AND pla.item_id             = rcpt_trx.inventory_item_id
                    AND pod.po_distribution_id  = rcpt_trx.po_distribution_id
                    AND rcpt_trx.transaction_id = cost_distb.rec_trxn_id 
                    AND ROWNUM                  = 1
				)
			) purchase_order_number,
		
		NVL(
			(SELECT rsh.receipt_num
               FROM RCV_SHIPMENT_HEADERS    rsh,
                    RCV_SHIPMENT_LINES      rsl,
                    RCV_TRANSACTIONS        rt
              WHERE rsh.shipment_header_id  = rsl.shipment_header_id
                AND rsh.shipment_header_id  = rt.shipment_header_id
                AND rt.shipment_line_id     = rsl.shipment_line_id
                AND rt.transaction_id       = ct.rcv_transaction_id                            
                AND ROWNUM                  = 1
			), 
				(SELECT rsh.receipt_num
                   FROM RCV_SHIPMENT_HEADERS    rsh,
                        RCV_SHIPMENT_LINES      rsl,
                        RCV_TRANSACTIONS        rt,
                        CST_TRANSACTIONS        rcpt_trx
                  WHERE rsh.shipment_header_id  = rsl.shipment_header_id
                    AND rsh.shipment_header_id  = rt.shipment_header_id
                    AND rt.shipment_line_id     = rsl.shipment_line_id
                    AND rt.transaction_id       = rcpt_trx.rcv_transaction_id
                    AND rcpt_trx.transaction_id = cost_distb.rec_trxn_id
                    AND ROWNUM                  = 1
				)
		   ) receipt_number,
		(SELECT dha.order_number
           FROM DOO_HEADERS_ALL DHA,
                DOO_FULFILL_LINES_ALL DFLA,
                DOO_LINES_ALL DLA
          WHERE 1                    = 1
            AND dha.header_id        = dla.header_id
            AND dha.header_id        = dfla.header_id
            AND dla.line_id          = dfla.line_id
            AND dfla.fulfill_line_id = cit.doo_fullfill_line_id
            AND ROWNUM               = 1
        )so_number,
		ct.txn_source_doc_number transaction_number,
		cost_dist_lines.entered_currency_amount transaction_amount,
		cost_dist_lines.entered_currency_code transaction_currency,
		itt.transaction_type_name,
		itt.description,
		cost_distb.cost_transaction_type
		---
  FROM GL_JE_HEADERS                   gjh,
       GL_JE_LINES                     gjl,
	   GL_LEDGERS                      gl,
	   GL_JE_CATEGORIES                gjc,
	   GL_JE_SOURCES                   gjs,
	   GL_JE_BATCHES                   gjb,
	   GL_CODE_COMBINATIONS            gcc,
	   ---
	   CST_COST_DISTRIBUTIONS          cost_distb,
	   CST_COST_DISTRIBUTION_LINES     cost_dist_lines,
	   CST_COST_ORGS_V                 cco,
	   CST_COST_ORG_BOOKS              cob,
	   CST_TRANSACTIONS                ct,
	   CST_INV_TRANSACTIONS            cit,
	   INV_TRANSACTION_TYPES_TL        itt,
	   CST_COST_BOOKS_B                ccbb
	   ---
 WHERE gjh.period_name                 =   :p_period
   AND gl.name                         =   DECODE(:p_ledger, NULL, gl.name, :p_ledger)
   --AND gcc.segment1                    =   DECODE(:p_company, NULL, gcc.segment1, :p_company)
   --AND gcc.segment2                    =   DECODE(:p_account, NULL, gcc.segment2, :p_account)
   --AND gjh.status                      =   DECODE(:p_status, NULL, gjh.status, :p_status)              --Journal status
   AND gjh.ledger_id                   =   gl.ledger_id
   AND gjh.je_header_id                =   gjl.je_header_id
   AND gjh.je_category                 =   gjc.je_category_name
   AND gjh.je_source                   =   gjs.je_source_name
   AND gjh.je_batch_id                 =   gjb.je_batch_id
   AND gjc.language                    =   'US'
   AND gjs.language                    =   'US'
   --AND gjh.created_by                =   '502451734'
   AND gjh.je_source	               =   'Cost Accounting'
   AND gjc.user_je_category_name       =   'GE COSTING FX TRUEUP'
   AND gjl.code_combination_id         =   gcc.code_combination_id
   AND gjh.external_reference          =   TO_CHAR(cost_distb.distribution_id)
   AND gjl.reference_6                 =   '1-'||cost_dist_lines.distribution_line_id
   ---
   AND cco.cost_org_id                  = cob.cost_org_id
   AND ct.cost_org_id                   = cco.cost_org_id
   AND ct.cost_book_id                  = cob.cost_book_id
   AND cob.cost_book_id                 = ccbb.cost_book_id
   AND cit.cst_inv_transaction_id       = ct.cst_inv_transaction_id
   AND cost_distb.transaction_id        = ct.transaction_id
   AND cost_distb.distribution_id       = cost_dist_lines.distribution_id
   AND itt.language                     = 'US'
   AND itt.transaction_type_id          = cit.base_txn_type_id
   AND EXISTS(SELECT 'Y' 
                FROM GL_LEDGER_RELATIONSHIPS  glr 
               WHERE glr.primary_ledger_id    = cost_distb.ledger_id
                 AND glr.application_id       = 101
                 AND glr.target_ledger_id     = gl.ledger_id)
   --Added below query to consider transaction for defined cost org in lookup
   AND EXISTS(SELECT 'Y'
			    FROM FND_LOOKUP_VALUES flv
			   WHERE flv.lookup_type   = 'GE_FX_TRUEUP_COST_ORGANIZATION'
			     AND flv.language      = 'US'
			     AND flv.enabled_flag  = 'Y'
			     AND flv.lookup_code   = cco.cost_org_code
			     AND NVL(flv.start_date_active, SYSDATE) <= SYSDATE
			     AND NVL(flv.end_date_active, SYSDATE)   >= SYSDATE
		      )
   --above query ended
   --Added below query to consider transaction for defined cost book in lookup
   AND EXISTS(SELECT 'Y'
                FROM FND_LOOKUP_VALUES flv
               WHERE flv.lookup_type   = 'GE_FX_TRUEUP_COST_BOOKS'
                 AND flv.language      = 'US'
                 AND flv.enabled_flag  = 'Y'
				 AND flv.lookup_code   = ccbb.cost_book_code
                 AND nvl(flv.start_date_active, SYSDATE) <= SYSDATE
                 AND nvl(flv.end_date_active, SYSDATE)   >= SYSDATE
              )
   --above query ended
UNION ALL
SELECT gl.name ledger_name, gjc.user_je_category_name category_name, gjs.user_je_source_name source_name, gjh.period_name, gjb.name batch_name, 
       gjh.name journal_name, gjl.je_line_num, gjh.external_reference distribution_id, SUBSTR(gjl.reference_6, 3) distribution_line_id, 
	   gcc.segment1,
	   gcc.segment2,
	   gcc.segment3,
	   gcc.segment4,
	   gcc.segment5,
	   gcc.segment6,
	   gcc.segment7,
	   gcc.segment8,
	   gcc.segment9,
	   gcc.segment10,
	   gcc.segment11,	   
       gjl.accounted_dr, gjl.accounted_cr,
	   DECODE(gjh.status, 'U', 'Unposted', 
						'P', 'Posted',
						'1', 'Invalid currency code',
						'2', 'Invalid source',
						'3', 'Invalid category',
						'4', 'Invalid ledger',
						'5', 'Invalid period name',
						'6', '(Actual) Unopened period',
						'6', '(Budget) Invalid budget version',
						'6', '(Encumbrance) Invalid encumbrance type',
						'7', 'Invalid entry',
						'8', 'Invalid entry',
						'A', 'Code combination does not exist',
						'C', 'Code combination: detail posting not allowed',
						'F', 'Code combination not enabled',
						'G', 'Invalid or inactive suspense account',
						'H', 'Invalid or inactive reserve for encumbrance account',
						'J', 'Code combination not yet valid on effective date',
						'K', 'Unbalanced intercompany journal entry',
						'L', 'Unbalanced journal entry by account category',
						'M', 'Code combination past effective date',
						'N', 'Intercompany processing error',
						'O', 'Missing conversion rate to replicate journal',
						'V', 'Multiple lines have code combination errors',
						'W', 'Frozen budget',
						'X', 'Frozen budget organization',
						'Y', 'Frozen budget account',
						'Z', 'Multiple lines have code combination errors',
						'-', 'Invalid or inactive rounding differences account',
						'<', 'Sequence assignment failed',
						'>', 'Cutoff rule was violated',
						'+', 'CTA account failed validation',
						'b', 'No write access to generated ledger account',
						'd', 'No write access to reporting currency/segment',
						'e', 'Invalid segment in generated ledger account',
						'h', 'Invalid account in chart of accounts mapping',
						'i', 'Unable to determine journal effective date',
						 gjh.status)status,
		TO_CHAR(gjl.creation_date, 'dd-Mon-yyyy HH24:MI:SS', 'NLS_DATE_LANGUAGE = American')creation_date, gjh.created_by,
		gjl.currency_code,
		---
		cco.cost_org_code,
		ccbb.cost_book_code,
		TO_CHAR(cct.creation_date, 'dd-Mon-yyyy HH24:MI:SS', 'NLS_DATE_LANGUAGE = American') transaction_creation_date,
		TO_CHAR(cct.transaction_date, 'dd-Mon-yyyy HH24:MI:SS', 'NLS_DATE_LANGUAGE = American')transaction_date,
		NVL(
			(SELECT pha.segment1
			   FROM PO_HEADERS_ALL          pha, 
			        PO_LINES_ALL            pla, 
					PO_DISTRIBUTIONS_ALL    pod
              WHERE pha.po_header_id        = pod.po_header_id
                AND pha.po_header_id        = pla.po_header_id
                AND pod.po_line_id          = pla.po_line_id
                AND pod.po_distribution_id  = ct.po_distribution_id
                AND ROWNUM                  = 1
		    ),
			(SELECT pha.segment1
               FROM PO_HEADERS_ALL          pha, 
			        PO_LINES_ALL            pla, 
					PO_DISTRIBUTIONS_ALL    pod,
					CST_TRANSACTIONS        rcpt_trx
              WHERE pha.po_header_id        = pod.po_header_id
                AND pha.po_header_id        = pla.po_header_id
                AND pod.po_line_id          = pla.po_line_id
                AND pla.item_id             = rcpt_trx.inventory_item_id
                AND pod.po_distribution_id  = rcpt_trx.po_distribution_id
                AND rcpt_trx.transaction_id = cost_distb.rec_trxn_id 
                AND ROWNUM                  = 1
		    )
		   ) purchase_order_number,		
		NVL(
			(SELECT rsh.receipt_num
               FROM RCV_SHIPMENT_HEADERS    rsh,
                    RCV_SHIPMENT_LINES      rsl,
                    RCV_TRANSACTIONS        rt
              WHERE rsh.shipment_header_id  = rsl.shipment_header_id
                AND rsh.shipment_header_id  = rt.shipment_header_id
                AND rt.shipment_line_id     = rsl.shipment_line_id
                AND rt.transaction_id       = ct.rcv_transaction_id                            
                AND ROWNUM                  = 1
			 ),
			(SELECT rsh.receipt_num
               FROM RCV_SHIPMENT_HEADERS    rsh,
                    RCV_SHIPMENT_LINES      rsl,
                    RCV_TRANSACTIONS        rt,
                    CST_TRANSACTIONS        rcpt_trx
              WHERE rsh.shipment_header_id  = rsl.shipment_header_id
                AND rsh.shipment_header_id  = rt.shipment_header_id
                AND rt.shipment_line_id     = rsl.shipment_line_id
                AND rt.transaction_id       = rcpt_trx.rcv_transaction_id
                AND rcpt_trx.transaction_id = cost_distb.rec_trxn_id                                
                AND ROWNUM <= 1
			)
		   ) receipt_number,
		(SELECT dha.order_number
           FROM DOO_HEADERS_ALL DHA,
                DOO_FULFILL_LINES_ALL DFLA,
                DOO_LINES_ALL DLA
          WHERE 1                    = 1
            AND dha.header_id        = dla.header_id
            AND dha.header_id        = dfla.header_id
            AND dla.line_id          = dfla.line_id
            AND dfla.fulfill_line_id = cct.shipment_fullfill_line_id
            AND ROWNUM               = 1
        )so_number,
		ct.txn_source_doc_number transaction_number,
		cost_dist_lines.entered_currency_amount transaction_amount,
		cost_dist_lines.entered_currency_code transaction_currency,
		'COGS Recognition' transaction_type_name,
		'COGS Recognition' description,
		'COGS Recognition' cost_transaction_type
		---
  FROM GL_JE_HEADERS                   gjh,
       GL_JE_LINES                     gjl,
	   GL_LEDGERS                      gl,
	   GL_JE_CATEGORIES                gjc,
	   GL_JE_SOURCES                   gjs,
	   GL_JE_BATCHES                   gjb,
	   GL_CODE_COMBINATIONS            gcc,
	   ---
	   CST_COST_DISTRIBUTIONS          cost_distb,
	   CST_COST_DISTRIBUTION_LINES     cost_dist_lines,
	   CST_COST_ORGS_V                 cco,
	   CST_COST_ORG_BOOKS              cob,
	   CST_TRANSACTIONS                ct,
	   CST_COGS_TRANSACTIONS           cct,
	   CST_COST_BOOKS_B                ccbb
	   ---
 WHERE gjh.period_name                 =   :p_period   
   AND gl.name                         =   DECODE(:p_ledger, NULL, gl.name, :p_ledger)
   --AND gcc.segment1                    =   DECODE(:p_company, NULL, gcc.segment1, :p_company)
   --AND gcc.segment2                    =   DECODE(:p_account, NULL, gcc.segment2, :p_account)
   --AND gjh.status                      =   DECODE(:p_status, NULL, gjh.status, :p_status)              --Journal status
   AND gjh.ledger_id                   =   gl.ledger_id
   AND gjh.je_header_id                =   gjl.je_header_id
   AND gjh.je_category                 =   gjc.je_category_name
   AND gjh.je_source                   =   gjs.je_source_name
   AND gjh.je_batch_id                 =   gjb.je_batch_id
   AND gjc.language                    =   'US'
   AND gjs.language                    =   'US'
   --AND gjh.created_by                =   '502451734'
   AND gjh.je_source	               =   'Cost Accounting'
   AND gjc.user_je_category_name       =   'GE COSTING FX TRUEUP'
   AND gjl.code_combination_id         =   gcc.code_combination_id
   AND gjh.external_reference          =   TO_CHAR(cost_distb.distribution_id)
   AND gjl.reference_6                 =   '2-'||cost_dist_lines.distribution_line_id
   ---
   AND cco.cost_org_id                 =  cob.cost_org_id
   AND ct.cost_org_id                  =  cco.cost_org_id
   AND ct.cost_book_id                 =  cob.cost_book_id
   AND cob.cost_book_id                =  ccbb.cost_book_id
   AND cct.cst_transaction_id          =  ct.transaction_id
   AND cost_distb.transaction_id       =  cct.transaction_id
   AND cost_distb.distribution_id      =  cost_dist_lines.distribution_id
   AND EXISTS(SELECT 'Y' 
                FROM GL_LEDGER_RELATIONSHIPS  glr 
               WHERE glr.primary_ledger_id    = cost_distb.ledger_id
                 AND glr.application_id       = 101
                 AND glr.target_ledger_id     = gl.ledger_id)
   --Added below query to consider transaction for defined cost org in lookup
   AND EXISTS(SELECT 'Y'
			    FROM FND_LOOKUP_VALUES flv
			   WHERE flv.lookup_type   = 'GE_FX_TRUEUP_COST_ORGANIZATION'
			     AND flv.language      = 'US'
			     AND flv.enabled_flag  = 'Y'
			     AND flv.lookup_code   = cco.cost_org_code
			     AND NVL(flv.start_date_active, SYSDATE) <= SYSDATE
			     AND NVL(flv.end_date_active, SYSDATE)   >= SYSDATE
		      )
   --above query ended
   --Added below query to consider transaction for defined cost book in lookup
   AND EXISTS(SELECT 'Y'
                FROM FND_LOOKUP_VALUES flv
               WHERE flv.lookup_type   = 'GE_FX_TRUEUP_COST_BOOKS'
                 AND flv.language      = 'US'
                 AND flv.enabled_flag  = 'Y'
				 AND flv.lookup_code   = ccbb.cost_book_code
                 AND nvl(flv.start_date_active, SYSDATE) <= SYSDATE
                 AND nvl(flv.end_date_active, SYSDATE)   >= SYSDATE
              )
   --above query ended
 ORDER BY ledger_name, distribution_id, distribution_line_id