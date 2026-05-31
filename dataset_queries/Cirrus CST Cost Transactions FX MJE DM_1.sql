/*
*************************************************************************************************
-- Name             : Cirrus CST Cost Transactions FX MJE Extract
-- Date             : 03/15/18
-- Author           : Himanshu Singh
-- Purpose          : 
-- Type             : Sql
*************************************************************************************************
-- Change history
-- Version         Date          Developer                            Description  
-- 1.0           03/15/18		 Nitin Bhatt  						  REL-015 EMG Cirrus CST Cost Transactions FX MJE Extract
-- 1.1			 07/20/21		 HussainBasha						  REL-055 GERITM22902722 restrict to  sending reporting ledger details file to SOA.																														  
*************************************************************************************************
*/
SELECT 1 AS "KEY",
	   'NEW'	                                                            ||','||  --*Status Code
	   cost.fx_ledger_id                                                    ||','||  --*ledger id
	   TO_CHAR(CAST(cost.end_date AS DATE),'YYYY/MM/DD')                    ||','||  --*Effective Date of Transaction
	   'Cost Accounting'                                                    ||','||  --*Journal Source
	   'GE COSTING FX TRUEUP'                                               ||','||  --*Journal Category
	   cost.currency_code                                                   ||','||  --*Currency Code
	   TO_CHAR(CAST(SUBSTR(SYSDATE, 1, 10) AS DATE),'YYYY/MM/DD')           ||','||  --*Journal Entry Creation Date
	   'A'                                                                  ||','||  --*Actual Flag
	   cost.segment1	                                                    ||','||  --Segment1
	   cost.segment2	                                                    ||','||  --Segment2
	   cost.segment3	                                                    ||','||  --Segment3
	   cost.segment4	                                                    ||','||  --Segment4
	   cost.segment5	                                                    ||','||  --Segment5
	   cost.segment6	                                                    ||','||  --Segment6
	   cost.segment7	                                                    ||','||  --Segment7
	   cost.segment8	                                                    ||','||  --Segment8
	   cost.segment9	                                                    ||','||  --Segment9
	   cost.segment10	                                                    ||','||  --Segment10
	   cost.segment11	                                                    ||','||  --Segment11
	   cost.segment12	                                                    ||','||  --Segment12
	   cost.segment13	                                                    ||','||  --Segment13
	   cost.segment14	                                                    ||','||  --Segment14
	   cost.segment15	                                                    ||','||  --Segment15
	   cost.segment16	                                                    ||','||  --Segment16
	   cost.segment17	                                                    ||','||  --Segment17
	   cost.segment18	                                                    ||','||  --Segment18
	   cost.segment19	                                                    ||','||  --Segment19
	   cost.segment20	                                                    ||','||  --Segment20
	   cost.segment21	                                                    ||','||  --Segment21
	   cost.segment22	                                                    ||','||  --Segment22
	   cost.segment23	                                                    ||','||  --Segment23
	   cost.segment24	                                                    ||','||  --Segment24
	   cost.segment25	                                                    ||','||  --Segment25
	   cost.segment26	                                                    ||','||  --Segment26
	   cost.segment27	                                                    ||','||  --Segment27
	   cost.segment28	                                                    ||','||  --Segment28
	   cost.segment29	                                                    ||','||  --Segment29
	   cost.segment30	                                                    ||','||  --Segment30
	   0                                                                    ||','||  --Entered Debit Amount
	   0                                                                    ||','||  --Entered Credit Amount
	   ((cost.po_receipt_period_mor_rate-cost.mor_rate)*cost.entered_dr)    ||','||  --Converted Debit Amount
	   ((cost.po_receipt_period_mor_rate-cost.mor_rate)*cost.entered_cr)    ||','||  --Converted Credit Amount
	   'FX TRUEUP JE Batch '||cost.fx_ledger_name||' Period '||cost.period_name ||','||  --REFERENCE1 (Batch Name)
	   'FX JE Batch '||cost.fx_ledger_name||' Period '||cost.period_name    ||','||  --REFERENCE2 (Batch Description)
	                                                                          ','||  --REFERENCE3
	   'FX JE Header '||cost.period_name||' Distribution id: '||cost.distribution_id ||','||  --REFERENCE4 (Journal Entry Name)
	   'FX JE Header '||cost.period_name                                    ||','||  --REFERENCE5 (Journal Entry Description)
	   cost.distribution_id	                                                ||','||  --REFERENCE6 (Journal Entry Reference)
			                                                                  ','||  --REFERENCE7 (Journal Entry Reversal flag)
			                                                                  ','||  --REFERENCE8 (Journal Entry Reversal Period)
			                                                                  ','||  --REFERENCE9 (Journal Reversal Method)
		cost.description	                                                ||','||  --REFERENCE10 (Journal Entry Line Description)
			                                                                  ','||  --Reference column 1
			                                                                  ','||  --Reference column 2
			                                                                  ','||  --Reference column 3
			                                                                  ','||  --Reference column 4
			                                                                  ','||  --Reference column 5
		cost.distribution_line_id	                                            ||','||  --Reference column 6
			                                                                  ','||  --Reference column 7
			                                                                  ','||  --Reference column 8
			                                                                  ','||  --Reference column 9
			                                                                  ','||  --Reference column 10
			                                                                  ','||  --Statistical Amount
		'User'	                                                            ||','||  --Currency Conversion Type
		TO_CHAR(CAST(SUBSTR(cost.end_date, 1, 10) AS DATE),'YYYY/MM/DD')	||','||  --Currency Conversion Date
		1	                                                                ||','||  --Currency Conversion Rate
		TO_NUMBER(TO_CHAR(SYSDATE, 'YYYYMMDDHH24MI'))	                    ||','||  --Interface Group Identifier
			                                                                  ','||  --Context field for Journal Entry Line DFF
			                                                                  ','||  --ATTRIBUTE1 Value for Journal Entry Line DFF
			                                                                  ','||  --ATTRIBUTE2 Value for Journal Entry Line DFF
			                                                                  ','||  --Attribute3 Value for Journal Entry Line DFF
			                                                                  ','||  --Attribute4 Value for Journal Entry Line DFF
			                                                                  ','||  --Attribute5 Value for Journal Entry Line DFF
			                                                                  ','||  --Attribute6 Value for Journal Entry Line DFF
			                                                                  ','||  --Attribute7 Value for Journal Entry Line DFF
			                                                                  ','||  --Attribute8 Value for Journal Entry Line DFF
			                                                                  ','||  --Attribute9 Value for Journal Entry Line DFF
			                                                                  ','||  --Attribute10 Value for Journal Entry Line DFF
			                                                                  ','||  --Attribute11 Value for Captured Information DFF
			                                                                  ','||  --Attribute12 Value for Captured Information DFF
			                                                                  ','||  --Attribute13 Value for Captured Information DFF
			                                                                  ','||  --Attribute14 Value for Captured Information DFF
			                                                                  ','||  --Attribute15 Value for Captured Information DFF
			                                                                  ','||  --Attribute16 Value for Captured Information DFF
			                                                                  ','||  --Attribute17 Value for Captured Information DFF
			                                                                  ','||  --Attribute18 Value for Captured Information DFF
			                                                                  ','||  --Attribute19 Value for Captured Information DFF
			                                                                  ','||  --Attribute20 Value for Captured Information DFF
			                                                                  ','||  --Context field for Captured Information DFF
			                                                                  ','||  --Average Journal Flag
			                                                                  ','||  --Clearing Company
			                                                                  ','||  --Ledger Name	(optional if ledger_id is provided)
			                                                                  ','||  --Encumbrance Type ID
			                                                                  ','||  --Reconciliation Reference
        cost.period_name AS main
  FROM
		(SELECT cost_org_code,
		        cost_transaction_type,
		        cost_trx_id,
		        distribution_id,
		        distribution_line_id,
		        transaction_date,
		        --so_number,
		        mor_rate,
		        po_receipt_cost_trx_period,
		        (SELECT gdr.conversion_rate
		           FROM GL_DAILY_RATES            gdr,
		                GL_FISCAL_DAY_V           fiscalday
		          WHERE gdr.conversion_type                       = '300000002138002'  ---conversion type as "MOR"
		            AND gdr.to_currency                           = 'USD'
		            AND gdr.from_currency                         = currency_code
		            AND fiscalday.fiscal_period_set_name          = 'CCL CALENDAR'
		            AND fiscalday.fiscal_period_number            <> '13'
		            AND TO_CHAR(gdr.conversion_date,'MM/DD/YYYY') = TO_CHAR(fiscalday.report_date,'MM/DD/YYYY')
		            AND fiscalday.fiscal_period_name              = po_receipt_cost_trx_period
		            AND ROWNUM                                    = 1
		        ) po_receipt_period_mor_rate,
		        cost_rcv_trx_id,
		        transaction_type_name,
		        description,
		        cost_org_id,
		        currency_code,
		        accounted_cr,
		        accounted_dr,
		        entered_cr,
		        entered_dr,
		        ledger_name,
		        accounting_class_code,
		        period_name,
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
				segment12,
				segment13,
				segment14,
				segment15,
				segment16,
				segment17,
				segment18,
				segment19,
				segment20,
				segment21,
				segment22,
				segment23,
				segment24,
				segment25,
				segment26,
				segment27,
				segment28,
				segment29,
				segment30,
				ledger_id,
				end_date,
				fx_ledger_id,
				fx_ledger_name
	       FROM
				(SELECT --Below query to extract recipt and issue transaction in cost management
				        cco.cost_org_code,
				        cost_distb.cost_transaction_type,
				        ct.transaction_id cost_trx_id,
				        cost_distb.distribution_id,
				        '1-'||cost_dist_lines.distribution_line_id distribution_line_id,
				        ct.transaction_date,
				       (SELECT gdr.conversion_rate
				          FROM GL_DAILY_RATES            gdr,
					           GL_FISCAL_DAY_V           fiscalday
				         WHERE gdr.conversion_type                       = '300000002138002'     ---conversion type as "MOR"
				           AND gdr.to_currency                           = 'USD'
				           AND gdr.from_currency                         = xlalines.currency_code
				           AND fiscalday.fiscal_period_set_name          = 'CCL CALENDAR'
				           AND fiscalday.fiscal_period_number            <> '13'
				           AND TO_CHAR(gdr.conversion_date,'MM/DD/YYYY') = TO_CHAR(fiscalday.report_date,'MM/DD/YYYY')
				           AND fiscalday.fiscal_period_name              = gp.period_name
				           AND ROWNUM                                    = 1
				        ) mor_rate,						
------------------------------------------------PO_RECEIPT_COST_TRX_Period-----------------------------------------------------					
CASE 
WHEN ITT.TRANSACTION_TYPE_NAME IN ('Purchase Order Receipt Adjustment') THEN	
	  (	 

	  NVL((SELECT FiscalDay.fiscal_period_name
      FROM CST_TRANSACTIONS CT1,
        GL_FISCAL_DAY_V FiscalDay,
       CST_COST_DISTRIBUTIONS COST_DISTB1,
	   RCV_TRANSACTIONS RT1,
	   RCV_TRANSACTIONS  RT2	   
      WHERE 1=1
       AND CT1.TRANSACTION_ID                        =  COST_DISTB.REC_TRXN_ID
      AND FiscalDay.FISCAL_PERIOD_SET_NAME          = 'CCL CALENDAR'
      AND fiscalday.fiscal_period_number           <> '13'
      AND CT1.TRANSACTION_ID = COST_DISTB1.TRANSACTION_ID
      AND COST_DISTB1.COST_TRANSACTION_TYPE <> 'ADJUST'
	  AND CT1.RCV_TRANSACTION_ID = RT1.TRANSACTION_ID
	  AND RT1.PARENT_TRANSACTION_ID = RT2.TRANSACTION_ID	  
      AND TO_CHAR(RT2.CREATION_DATE,'MM/DD/YYYY')= TO_CHAR(FiscalDay.Report_DATE,'MM/DD/YYYY')	
      AND rownum =1 ), 
	  (
	  SELECT FiscalDay.fiscal_period_name
      FROM CST_TRANSACTIONS CT1,
        GL_FISCAL_DAY_V FiscalDay,
       CST_COST_DISTRIBUTIONS COST_DISTB1
      WHERE 1=1
      AND CT1.TRANSACTION_ID                        =  COST_DISTB.REC_TRXN_ID
      AND FiscalDay.FISCAL_PERIOD_SET_NAME          = 'CCL CALENDAR'
      AND fiscalday.fiscal_period_number           <> '13'
      AND CT1.TRANSACTION_ID = COST_DISTB1.TRANSACTION_ID
      AND COST_DISTB1.COST_TRANSACTION_TYPE <> 'ADJUST'
      --AND TO_CHAR(CT1.TRANSACTION_DATE,'MM/DD/YYYY')= TO_CHAR(FiscalDay.Report_DATE,'MM/DD/YYYY')
	   AND TO_CHAR(CT1.CREATION_DATE,'MM/DD/YYYY')= TO_CHAR(FiscalDay.Report_DATE,'MM/DD/YYYY')
      AND rownum =1
	  )
	  )
	  )
	  
	  
	  WHEN 
	  (
	  ITT.TRANSACTION_TYPE_NAME IN ('Return to Supplier') 
	  and 
	              ((SELECT ITT1.TRANSACTION_TYPE_NAME
	               FROM CST_TRANSACTIONS CT2,
	               INV_TRANSACTION_TYPES_TL ITT1,
		           CST_INV_TRANSACTIONS CIT1
	               WHERE  CT2.TRANSACTION_ID          =  COST_DISTB.REC_TRXN_ID
	                  AND ITT1.LANGUAGE            = 'US'
                      AND ITT1.TRANSACTION_TYPE_ID = CIT1.BASE_TXN_TYPE_ID
	                  AND CIT1.CST_INV_TRANSACTION_ID = CT2.CST_INV_TRANSACTION_ID
			          AND ROWNUM = 1) <>   ('RMA Receipt'))
	  
	  )
	  THEN	
	  (	  
	  NVL( (SELECT FiscalDay.fiscal_period_name
      FROM CST_TRANSACTIONS CT1,
        GL_FISCAL_DAY_V FiscalDay,
       CST_COST_DISTRIBUTIONS COST_DISTB1,
	   RCV_TRANSACTIONS RT1,
	   RCV_TRANSACTIONS  RT2
       --RCV_TRANSACTIONS  RT3 	   
      WHERE 1=1
       AND CT1.TRANSACTION_ID                        =  COST_DISTB.REC_TRXN_ID
      AND FiscalDay.FISCAL_PERIOD_SET_NAME          = 'CCL CALENDAR'
      AND fiscalday.fiscal_period_number           <> '13'
      AND CT1.TRANSACTION_ID = COST_DISTB1.TRANSACTION_ID
      AND COST_DISTB1.COST_TRANSACTION_TYPE <> 'ADJUST'
	  AND CT1.RCV_TRANSACTION_ID = RT1.TRANSACTION_ID
	  AND RT1.PARENT_TRANSACTION_ID = RT2.TRANSACTION_ID	
     -- AND RT2.PARENT_TRANSACTION_ID = RT3.TRANSACTION_ID	  
      AND TO_CHAR(RT2.CREATION_DATE,'MM/DD/YYYY')= TO_CHAR(FiscalDay.Report_DATE,'MM/DD/YYYY')	
      AND rownum =1 ), 
	  (
	  SELECT FiscalDay.fiscal_period_name
      FROM CST_TRANSACTIONS CT1,
        GL_FISCAL_DAY_V FiscalDay,
       CST_COST_DISTRIBUTIONS COST_DISTB1
      WHERE 1=1
      AND CT1.TRANSACTION_ID                        =  COST_DISTB.REC_TRXN_ID
      AND FiscalDay.FISCAL_PERIOD_SET_NAME          = 'CCL CALENDAR'
      AND fiscalday.fiscal_period_number           <> '13'
      AND CT1.TRANSACTION_ID = COST_DISTB1.TRANSACTION_ID
      AND COST_DISTB1.COST_TRANSACTION_TYPE <> 'ADJUST'
      --AND TO_CHAR(CT1.TRANSACTION_DATE,'MM/DD/YYYY')= TO_CHAR(FiscalDay.Report_DATE,'MM/DD/YYYY')
	   AND TO_CHAR(CT1.CREATION_DATE,'MM/DD/YYYY')= TO_CHAR(FiscalDay.Report_DATE,'MM/DD/YYYY')
      AND rownum =1
	  )
	  
	  )
	  
	  )
	
	   WHEN 
	  (
	  ITT.TRANSACTION_TYPE_NAME IN ('Return to Supplier') 
	  and 
	              ((SELECT ITT1.TRANSACTION_TYPE_NAME
	               FROM CST_TRANSACTIONS CT2,
	               INV_TRANSACTION_TYPES_TL ITT1,
		           CST_INV_TRANSACTIONS CIT1
	               WHERE  CT2.TRANSACTION_ID          =  COST_DISTB.REC_TRXN_ID
	                  AND ITT1.LANGUAGE            = 'US'
                      AND ITT1.TRANSACTION_TYPE_ID = CIT1.BASE_TXN_TYPE_ID
	                  AND CIT1.CST_INV_TRANSACTION_ID = CT2.CST_INV_TRANSACTION_ID
			          AND ROWNUM = 1) =   ('RMA Receipt'))
	  
	  )
	  THEN	
	  (	  
	 NVL(( SELECT FiscalDay.fiscal_period_name
                            FROM CST_TRANSACTIONS CT1,
                                 GL_FISCAL_DAY_V FiscalDay,
                                 CST_COST_DISTRIBUTIONS COST_DISTB1,
	                             RCV_TRANSACTIONS RT1,
	                             RCV_TRANSACTIONS  RT2	   
                           WHERE 1=1
                             AND CT1.TRANSACTION_ID  =  (SELECT COST_DISTB2.REC_TRXN_ID
                                                           FROM CST_TRANSACTIONS CST,  
                                                                CST_TRANSACTIONS CST1, 
	                                                            DOO_DOCUMENT_REFERENCES  DDR,
	                                                            INV_TRANSACTION_TYPES_TL ITT1,
	                                                            CST_COST_DISTRIBUTIONS COST_DISTB2	
                                                         WHERE  CST.DOO_FULLFILL_LINE_ID = DDR.FULFILL_LINE_ID
                                                            --AND CST.TRANSACTION_ID = CT.TRANSACTION_ID
															AND CST.TRANSACTION_ID =  COST_DISTB.REC_TRXN_ID
                                                            AND DDR.DOC_REF_TYPE IN  ('ORIGINAL_ORCHESTRATION_ORDER','ORIGINAL_SALES_ORDER') 
                                                            AND CST1.DOO_FULLFILL_LINE_ID = DDR.DOC_SUBLINE_ID	
                                                            AND CST1.COST_BOOK_ID = CT.COST_BOOK_ID
                                                            AND ITT1.LANGUAGE            = 'US'
                                                            AND CST1.TRANSACTION_ID = COST_DISTB2.TRANSACTION_ID
                                                            AND ITT1.TRANSACTION_TYPE_ID = CST1.BASE_TXN_TYPE_ID
                                                            AND ITT1.TRANSACTION_TYPE_NAME = 'Sales Order Issue'
                                                            AND ROWNUM = 1 )
                            AND FiscalDay.FISCAL_PERIOD_SET_NAME          = 'CCL CALENDAR'
                            AND fiscalday.fiscal_period_number           <> '13'
                            AND CT1.TRANSACTION_ID = COST_DISTB1.TRANSACTION_ID
                            AND COST_DISTB1.COST_TRANSACTION_TYPE <> 'ADJUST'
	                        AND CT1.RCV_TRANSACTION_ID = RT1.TRANSACTION_ID
	                        AND RT1.PARENT_TRANSACTION_ID = RT2.TRANSACTION_ID	  
                            AND TO_CHAR(RT2.CREATION_DATE,'MM/DD/YYYY')= TO_CHAR(FiscalDay.Report_DATE,'MM/DD/YYYY')	
                            AND rownum =1  ), 
                            ( SELECT FiscalDay.fiscal_period_name
                            FROM CST_TRANSACTIONS CT1,
                                 GL_FISCAL_DAY_V FiscalDay,
                                 CST_COST_DISTRIBUTIONS COST_DISTB1	                            
                           WHERE 1=1
                             AND CT1.TRANSACTION_ID  =  (SELECT COST_DISTB2.REC_TRXN_ID
                                                           FROM CST_TRANSACTIONS CST,  
                                                                CST_TRANSACTIONS CST1, 
	                                                            DOO_DOCUMENT_REFERENCES  DDR,
	                                                            INV_TRANSACTION_TYPES_TL ITT1,
	                                                            CST_COST_DISTRIBUTIONS COST_DISTB2	
                                                         WHERE  CST.DOO_FULLFILL_LINE_ID = DDR.FULFILL_LINE_ID
                                                            --AND CST.TRANSACTION_ID = CT.TRANSACTION_ID
															AND CST.TRANSACTION_ID =  COST_DISTB.REC_TRXN_ID
                                                            AND DDR.DOC_REF_TYPE IN  ('ORIGINAL_ORCHESTRATION_ORDER','ORIGINAL_SALES_ORDER') 
                                                            AND CST1.DOO_FULLFILL_LINE_ID = DDR.DOC_SUBLINE_ID	
                                                            AND CST1.COST_BOOK_ID = CT.COST_BOOK_ID
                                                            AND ITT1.LANGUAGE            = 'US'
                                                            AND CST1.TRANSACTION_ID = COST_DISTB2.TRANSACTION_ID
                                                            AND ITT1.TRANSACTION_TYPE_ID = CST1.BASE_TXN_TYPE_ID
                                                            AND ITT1.TRANSACTION_TYPE_NAME = 'Sales Order Issue'
                                                            AND ROWNUM = 1 )
                            AND FiscalDay.FISCAL_PERIOD_SET_NAME          = 'CCL CALENDAR'
                            AND fiscalday.fiscal_period_number           <> '13'
                            AND CT1.TRANSACTION_ID = COST_DISTB1.TRANSACTION_ID
                            AND COST_DISTB1.COST_TRANSACTION_TYPE <> 'ADJUST'
	                        AND TO_CHAR(CT1.CREATION_DATE,'MM/DD/YYYY')= TO_CHAR(FiscalDay.Report_DATE,'MM/DD/YYYY')	
                            AND rownum =1  )
							
							)
	  
	  )
	  
	  
--------------------------------------------------------------------------------------------------------------	  
	  
	  WHEN 	 ( SELECT ITT1.TRANSACTION_TYPE_NAME
	  FROM CST_TRANSACTIONS CT2,
	       INV_TRANSACTION_TYPES_TL ITT1,
		   CST_INV_TRANSACTIONS CIT1
	  WHERE  CT2.TRANSACTION_ID          =  COST_DISTB.REC_TRXN_ID
	        AND ITT1.LANGUAGE            = 'US'
            AND ITT1.TRANSACTION_TYPE_ID = CIT1.BASE_TXN_TYPE_ID
	        AND CIT1.CST_INV_TRANSACTION_ID = CT2.CST_INV_TRANSACTION_ID
			AND ROWNUM = 1) = 	  'Purchase Order Receipt'  THEN
			
	(SELECT FiscalDay.fiscal_period_name
      FROM CST_TRANSACTIONS CT1,
        GL_FISCAL_DAY_V FiscalDay,
       CST_COST_DISTRIBUTIONS COST_DISTB1,
	   RCV_TRANSACTIONS RT1,
	   RCV_TRANSACTIONS  RT2	   
      WHERE 1=1
       AND CT1.TRANSACTION_ID                        =  COST_DISTB.REC_TRXN_ID
      AND FiscalDay.FISCAL_PERIOD_SET_NAME          = 'CCL CALENDAR'
      AND fiscalday.fiscal_period_number           <> '13'
      AND CT1.TRANSACTION_ID = COST_DISTB1.TRANSACTION_ID
      AND COST_DISTB1.COST_TRANSACTION_TYPE <> 'ADJUST'
	  AND CT1.RCV_TRANSACTION_ID = RT1.TRANSACTION_ID
	  AND RT1.PARENT_TRANSACTION_ID = RT2.TRANSACTION_ID	  
      AND TO_CHAR(RT2.CREATION_DATE,'MM/DD/YYYY')= TO_CHAR(FiscalDay.Report_DATE,'MM/DD/YYYY')	
      AND rownum =1  ) 
	  
	  WHEN 	 ( SELECT ITT1.TRANSACTION_TYPE_NAME
	  FROM CST_TRANSACTIONS CT2,
	       INV_TRANSACTION_TYPES_TL ITT1,
		   CST_INV_TRANSACTIONS CIT1
	  WHERE  CT2.TRANSACTION_ID          =  COST_DISTB.REC_TRXN_ID
	        AND ITT1.LANGUAGE            = 'US'
            AND ITT1.TRANSACTION_TYPE_ID = CIT1.BASE_TXN_TYPE_ID
	        AND CIT1.CST_INV_TRANSACTION_ID = CT2.CST_INV_TRANSACTION_ID
			AND ROWNUM = 1) = 	  'Purchase Order Receipt Adjustment'  THEN
			
			(	  SELECT FiscalDay.fiscal_period_name
      FROM CST_TRANSACTIONS CT1,
        GL_FISCAL_DAY_V FiscalDay,
       CST_COST_DISTRIBUTIONS COST_DISTB1,
	   RCV_TRANSACTIONS RT1,
	   RCV_TRANSACTIONS  RT2	   
      WHERE 1=1
       AND CT1.TRANSACTION_ID                        =  COST_DISTB.REC_TRXN_ID
      AND FiscalDay.FISCAL_PERIOD_SET_NAME          = 'CCL CALENDAR'
      AND fiscalday.fiscal_period_number           <> '13'
      AND CT1.TRANSACTION_ID = COST_DISTB1.TRANSACTION_ID
      --AND COST_DISTB1.COST_TRANSACTION_TYPE <> 'ADJUST'
	  AND CT1.RCV_TRANSACTION_ID = RT1.TRANSACTION_ID
	  AND RT1.PARENT_TRANSACTION_ID = RT2.TRANSACTION_ID	  
      AND TO_CHAR(RT2.CREATION_DATE,'MM/DD/YYYY')= TO_CHAR(FiscalDay.Report_DATE,'MM/DD/YYYY')	
      AND rownum =1  ) 	  
	  
---------------------------------Addition for RMA issue-------------------------------				
			WHEN ( SELECT ITT1.TRANSACTION_TYPE_NAME
	               FROM CST_TRANSACTIONS CT2,
	               INV_TRANSACTION_TYPES_TL ITT1,
		           CST_INV_TRANSACTIONS CIT1
	               WHERE  CT2.TRANSACTION_ID          =  COST_DISTB.REC_TRXN_ID
	                  AND ITT1.LANGUAGE            = 'US'
                      AND ITT1.TRANSACTION_TYPE_ID = CIT1.BASE_TXN_TYPE_ID
	                  AND CIT1.CST_INV_TRANSACTION_ID = CT2.CST_INV_TRANSACTION_ID
			          AND ROWNUM = 1) =   ('RMA Receipt') THEN  
	  
	              (    NVL(( SELECT FiscalDay.fiscal_period_name
                            FROM CST_TRANSACTIONS CT1,
                                 GL_FISCAL_DAY_V FiscalDay,
                                 CST_COST_DISTRIBUTIONS COST_DISTB1,
	                             RCV_TRANSACTIONS RT1,
	                             RCV_TRANSACTIONS  RT2	   
                           WHERE 1=1
                             AND CT1.TRANSACTION_ID  =  (SELECT COST_DISTB2.REC_TRXN_ID
                                                           FROM CST_TRANSACTIONS CST,  
                                                                CST_TRANSACTIONS CST1, 
	                                                            DOO_DOCUMENT_REFERENCES  DDR,
	                                                            INV_TRANSACTION_TYPES_TL ITT1,
	                                                            CST_COST_DISTRIBUTIONS COST_DISTB2	
                                                         WHERE  CST.DOO_FULLFILL_LINE_ID = DDR.FULFILL_LINE_ID
                                                            --AND CST.TRANSACTION_ID = CT.TRANSACTION_ID
															AND CST.TRANSACTION_ID =  COST_DISTB.REC_TRXN_ID
                                                            AND DDR.DOC_REF_TYPE IN  ('ORIGINAL_ORCHESTRATION_ORDER','ORIGINAL_SALES_ORDER') 
                                                            AND CST1.DOO_FULLFILL_LINE_ID = DDR.DOC_SUBLINE_ID	
                                                            AND CST1.COST_BOOK_ID = CT.COST_BOOK_ID
                                                            AND ITT1.LANGUAGE            = 'US'
                                                            AND CST1.TRANSACTION_ID = COST_DISTB2.TRANSACTION_ID
                                                            AND ITT1.TRANSACTION_TYPE_ID = CST1.BASE_TXN_TYPE_ID
                                                            AND ITT1.TRANSACTION_TYPE_NAME = 'Sales Order Issue'
                                                            AND ROWNUM = 1 )
                            AND FiscalDay.FISCAL_PERIOD_SET_NAME          = 'CCL CALENDAR'
                            AND fiscalday.fiscal_period_number           <> '13'
                            AND CT1.TRANSACTION_ID = COST_DISTB1.TRANSACTION_ID
                            AND COST_DISTB1.COST_TRANSACTION_TYPE <> 'ADJUST'
	                        AND CT1.RCV_TRANSACTION_ID = RT1.TRANSACTION_ID
	                        AND RT1.PARENT_TRANSACTION_ID = RT2.TRANSACTION_ID	  
                            AND TO_CHAR(RT2.CREATION_DATE,'MM/DD/YYYY')= TO_CHAR(FiscalDay.Report_DATE,'MM/DD/YYYY')	
                            AND rownum =1  ), 
                            ( SELECT FiscalDay.fiscal_period_name
                            FROM CST_TRANSACTIONS CT1,
                                 GL_FISCAL_DAY_V FiscalDay,
                                 CST_COST_DISTRIBUTIONS COST_DISTB1	                            
                           WHERE 1=1
                             AND CT1.TRANSACTION_ID  =  (SELECT COST_DISTB2.REC_TRXN_ID
                                                           FROM CST_TRANSACTIONS CST,  
                                                                CST_TRANSACTIONS CST1, 
	                                                            DOO_DOCUMENT_REFERENCES  DDR,
	                                                            INV_TRANSACTION_TYPES_TL ITT1,
	                                                            CST_COST_DISTRIBUTIONS COST_DISTB2	
                                                         WHERE  CST.DOO_FULLFILL_LINE_ID = DDR.FULFILL_LINE_ID
                                                            --AND CST.TRANSACTION_ID = CT.TRANSACTION_ID
															AND CST.TRANSACTION_ID =  COST_DISTB.REC_TRXN_ID
                                                            AND DDR.DOC_REF_TYPE IN  ('ORIGINAL_ORCHESTRATION_ORDER','ORIGINAL_SALES_ORDER') 
                                                            AND CST1.DOO_FULLFILL_LINE_ID = DDR.DOC_SUBLINE_ID	
                                                            AND CST1.COST_BOOK_ID = CT.COST_BOOK_ID
                                                            AND ITT1.LANGUAGE            = 'US'
                                                            AND CST1.TRANSACTION_ID = COST_DISTB2.TRANSACTION_ID
                                                            AND ITT1.TRANSACTION_TYPE_ID = CST1.BASE_TXN_TYPE_ID
                                                            AND ITT1.TRANSACTION_TYPE_NAME = 'Sales Order Issue'
                                                            AND ROWNUM = 1 )
                            AND FiscalDay.FISCAL_PERIOD_SET_NAME          = 'CCL CALENDAR'
                            AND fiscalday.fiscal_period_number           <> '13'
                            AND CT1.TRANSACTION_ID = COST_DISTB1.TRANSACTION_ID
                            AND COST_DISTB1.COST_TRANSACTION_TYPE <> 'ADJUST'
	                        AND TO_CHAR(CT1.CREATION_DATE,'MM/DD/YYYY')= TO_CHAR(FiscalDay.Report_DATE,'MM/DD/YYYY')	
                            AND rownum =1  )
							
							)
							
							
							)	
							
	        --------------------------------------------------------------------------------------
	  
	  
	  WHEN ITT.TRANSACTION_TYPE_NAME IN ('RMA Receipt') THEN  
	  
	 ( CASE WHEN     (SELECT ITT2.TRANSACTION_TYPE_NAME
                         FROM CST_TRANSACTIONS CST,  
                              CST_TRANSACTIONS CST1, 
	                          DOO_DOCUMENT_REFERENCES  DDR,
	                          INV_TRANSACTION_TYPES_TL ITT1,
	                          CST_COST_DISTRIBUTIONS COST_DISTB2,
	                          CST_TRANSACTIONS CST2,
	                          INV_TRANSACTION_TYPES_TL ITT2,
	                          CST_INV_TRANSACTIONS CIT1
                       WHERE  CST.DOO_FULLFILL_LINE_ID = DDR.FULFILL_LINE_ID
                          AND CST.TRANSACTION_ID = CT.TRANSACTION_ID
                          AND DDR.DOC_REF_TYPE IN  ('ORIGINAL_ORCHESTRATION_ORDER','ORIGINAL_SALES_ORDER') 
                          AND CST1.DOO_FULLFILL_LINE_ID = DDR.DOC_SUBLINE_ID	
                          AND CST1.COST_BOOK_ID = CT.COST_BOOK_ID
                          AND ITT1.LANGUAGE            = 'US'
                          AND CST1.TRANSACTION_ID = COST_DISTB2.TRANSACTION_ID
                          AND ITT1.TRANSACTION_TYPE_ID = CST1.BASE_TXN_TYPE_ID
                          AND CST2.TRANSACTION_ID = COST_DISTB2.REC_TRXN_ID 
                          AND CST2.CST_INV_TRANSACTION_ID = CIT1.CST_INV_TRANSACTION_ID
                          AND ITT2.LANGUAGE            = 'US'
                          AND ITT2.TRANSACTION_TYPE_ID = CIT1.BASE_TXN_TYPE_ID
                          AND ITT1.TRANSACTION_TYPE_NAME = 'Sales Order Issue'
                          AND ROWNUM = 1) = 'Purchase Order Receipt' THEN

                       ( SELECT FiscalDay.fiscal_period_name
                            FROM CST_TRANSACTIONS CT1,
                                 GL_FISCAL_DAY_V FiscalDay,
                                 CST_COST_DISTRIBUTIONS COST_DISTB1,
	                             RCV_TRANSACTIONS RT1,
	                             RCV_TRANSACTIONS  RT2	   
                           WHERE 1=1
                             AND CT1.TRANSACTION_ID  =  (SELECT COST_DISTB2.REC_TRXN_ID
                                                           FROM CST_TRANSACTIONS CST,  
                                                                CST_TRANSACTIONS CST1, 
	                                                            DOO_DOCUMENT_REFERENCES  DDR,
	                                                            INV_TRANSACTION_TYPES_TL ITT1,
	                                                            CST_COST_DISTRIBUTIONS COST_DISTB2	
                                                         WHERE  CST.DOO_FULLFILL_LINE_ID = DDR.FULFILL_LINE_ID
                                                            AND CST.TRANSACTION_ID = CT.TRANSACTION_ID
                                                            AND DDR.DOC_REF_TYPE IN  ('ORIGINAL_ORCHESTRATION_ORDER','ORIGINAL_SALES_ORDER') 
                                                            AND CST1.DOO_FULLFILL_LINE_ID = DDR.DOC_SUBLINE_ID	
                                                            AND CST1.COST_BOOK_ID = CT.COST_BOOK_ID
                                                            AND ITT1.LANGUAGE            = 'US'
                                                            AND CST1.TRANSACTION_ID = COST_DISTB2.TRANSACTION_ID
                                                            AND ITT1.TRANSACTION_TYPE_ID = CST1.BASE_TXN_TYPE_ID
                                                            AND ITT1.TRANSACTION_TYPE_NAME = 'Sales Order Issue'
                                                            AND ROWNUM = 1 )
                            AND FiscalDay.FISCAL_PERIOD_SET_NAME          = 'CCL CALENDAR'
                            AND fiscalday.fiscal_period_number           <> '13'
                            AND CT1.TRANSACTION_ID = COST_DISTB1.TRANSACTION_ID
                            AND COST_DISTB1.COST_TRANSACTION_TYPE <> 'ADJUST'
	                        AND CT1.RCV_TRANSACTION_ID = RT1.TRANSACTION_ID
	                        AND RT1.PARENT_TRANSACTION_ID = RT2.TRANSACTION_ID	  
                            AND TO_CHAR(RT2.CREATION_DATE,'MM/DD/YYYY')= TO_CHAR(FiscalDay.Report_DATE,'MM/DD/YYYY')	
                            AND rownum =1  ) 
	  
           WHEN	   (SELECT ITT2.TRANSACTION_TYPE_NAME
                      FROM CST_TRANSACTIONS CST,  
                           CST_TRANSACTIONS CST1, 
	                       DOO_DOCUMENT_REFERENCES  DDR,
	                       INV_TRANSACTION_TYPES_TL ITT1,
	                       CST_COST_DISTRIBUTIONS COST_DISTB2,
	                       CST_TRANSACTIONS CST2,
	                       INV_TRANSACTION_TYPES_TL ITT2,
	                       CST_INV_TRANSACTIONS CIT1
                    WHERE  CST.DOO_FULLFILL_LINE_ID = DDR.FULFILL_LINE_ID
                       AND CST.TRANSACTION_ID = CT.TRANSACTION_ID
                       AND DDR.DOC_REF_TYPE IN  ('ORIGINAL_ORCHESTRATION_ORDER','ORIGINAL_SALES_ORDER') 
                       AND CST1.DOO_FULLFILL_LINE_ID = DDR.DOC_SUBLINE_ID	
                       AND CST1.COST_BOOK_ID = CT.COST_BOOK_ID
                       AND ITT1.LANGUAGE            = 'US'
                       AND CST1.TRANSACTION_ID = COST_DISTB2.TRANSACTION_ID
                       AND ITT1.TRANSACTION_TYPE_ID = CST1.BASE_TXN_TYPE_ID
                       AND CST2.TRANSACTION_ID = COST_DISTB2.REC_TRXN_ID 
                       AND CST2.CST_INV_TRANSACTION_ID = CIT1.CST_INV_TRANSACTION_ID
                       AND ITT2.LANGUAGE            = 'US'
                       AND ITT2.TRANSACTION_TYPE_ID = CIT1.BASE_TXN_TYPE_ID
                       AND ITT1.TRANSACTION_TYPE_NAME = 'Sales Order Issue'
                       AND ROWNUM = 1) = 'Purchase Order Receipt Adjustment' THEN
	  
	         (	  SELECT FiscalDay.fiscal_period_name
                        FROM CST_TRANSACTIONS CT1,
                             GL_FISCAL_DAY_V FiscalDay,
                             CST_COST_DISTRIBUTIONS COST_DISTB1,
	                         RCV_TRANSACTIONS RT1,
	                         RCV_TRANSACTIONS  RT2	   
                        WHERE 1=1
                         AND CT1.TRANSACTION_ID  =  (SELECT COST_DISTB2.REC_TRXN_ID
                                                       FROM CST_TRANSACTIONS CST,  
                                                            CST_TRANSACTIONS CST1, 
	                                                        DOO_DOCUMENT_REFERENCES  DDR,
	                                                        INV_TRANSACTION_TYPES_TL ITT1,
	                                                        CST_COST_DISTRIBUTIONS COST_DISTB2	
                                                     WHERE  CST.DOO_FULLFILL_LINE_ID = DDR.FULFILL_LINE_ID
                                                        AND CST.TRANSACTION_ID = CT.TRANSACTION_ID
                                                        AND DDR.DOC_REF_TYPE IN  ('ORIGINAL_ORCHESTRATION_ORDER','ORIGINAL_SALES_ORDER') 
                                                        AND CST1.DOO_FULLFILL_LINE_ID = DDR.DOC_SUBLINE_ID	
                                                        AND CST1.COST_BOOK_ID = CT.COST_BOOK_ID
                                                        AND ITT1.LANGUAGE            = 'US'
                                                        AND CST1.TRANSACTION_ID = COST_DISTB2.TRANSACTION_ID
                                                        AND ITT1.TRANSACTION_TYPE_ID = CST1.BASE_TXN_TYPE_ID
                                                        AND ITT1.TRANSACTION_TYPE_NAME = 'Sales Order Issue'
                                                        AND ROWNUM = 1 )
                         AND FiscalDay.FISCAL_PERIOD_SET_NAME          = 'CCL CALENDAR'
                         AND fiscalday.fiscal_period_number           <> '13'
                         AND CT1.TRANSACTION_ID = COST_DISTB1.TRANSACTION_ID
                            --AND COST_DISTB1.COST_TRANSACTION_TYPE <> 'ADJUST'
	                     AND CT1.RCV_TRANSACTION_ID = RT1.TRANSACTION_ID
	                     AND RT1.PARENT_TRANSACTION_ID = RT2.TRANSACTION_ID	  
                         AND TO_CHAR(RT2.CREATION_DATE,'MM/DD/YYYY')= TO_CHAR(FiscalDay.Report_DATE,'MM/DD/YYYY')	
                         AND rownum =1  )

                         ELSE
						 
						  ( SELECT FiscalDay.fiscal_period_name
                                  FROM CST_TRANSACTIONS CT1,
                                       GL_FISCAL_DAY_V FiscalDay,
                                       CST_COST_DISTRIBUTIONS COST_DISTB1
                                 WHERE 1=1
                                   AND CT1.TRANSACTION_ID                        =  (SELECT COST_DISTB2.REC_TRXN_ID
                                                       FROM CST_TRANSACTIONS CST,  
                                                            CST_TRANSACTIONS CST1, 
	                                                        DOO_DOCUMENT_REFERENCES  DDR,
	                                                        INV_TRANSACTION_TYPES_TL ITT1,
	                                                        CST_COST_DISTRIBUTIONS COST_DISTB2	
                                                     WHERE  CST.DOO_FULLFILL_LINE_ID = DDR.FULFILL_LINE_ID
                                                        AND CST.TRANSACTION_ID = CT.TRANSACTION_ID
                                                        AND DDR.DOC_REF_TYPE IN  ('ORIGINAL_ORCHESTRATION_ORDER','ORIGINAL_SALES_ORDER') 
                                                        AND CST1.DOO_FULLFILL_LINE_ID = DDR.DOC_SUBLINE_ID	
                                                        AND CST1.COST_BOOK_ID = CT.COST_BOOK_ID
                                                        AND ITT1.LANGUAGE            = 'US'
                                                        AND CST1.TRANSACTION_ID = COST_DISTB2.TRANSACTION_ID
                                                        AND ITT1.TRANSACTION_TYPE_ID = CST1.BASE_TXN_TYPE_ID
                                                        AND ITT1.TRANSACTION_TYPE_NAME = 'Sales Order Issue'
                                                        AND ROWNUM = 1 )
                                   AND FiscalDay.FISCAL_PERIOD_SET_NAME          = 'CCL CALENDAR'
                                   AND fiscalday.fiscal_period_number           <> '13'
                                   AND CT1.TRANSACTION_ID = COST_DISTB1.TRANSACTION_ID
                                   AND COST_DISTB1.COST_TRANSACTION_TYPE <> 'ADJUST'
                                   AND TO_CHAR(CT1.CREATION_DATE,'MM/DD/YYYY')= TO_CHAR(FiscalDay.Report_DATE,'MM/DD/YYYY')
                                   AND rownum =1
                                     ) 

						 END)   
			
		ELSE	
					
	  
	  ( SELECT FiscalDay.fiscal_period_name
      FROM CST_TRANSACTIONS CT1,
        GL_FISCAL_DAY_V FiscalDay,
       CST_COST_DISTRIBUTIONS COST_DISTB1
      WHERE 1=1
      AND CT1.TRANSACTION_ID                        =  COST_DISTB.REC_TRXN_ID
      AND FiscalDay.FISCAL_PERIOD_SET_NAME          = 'CCL CALENDAR'
      AND fiscalday.fiscal_period_number           <> '13'
      AND CT1.TRANSACTION_ID = COST_DISTB1.TRANSACTION_ID
      AND COST_DISTB1.COST_TRANSACTION_TYPE <> 'ADJUST'
      --AND TO_CHAR(CT1.TRANSACTION_DATE,'MM/DD/YYYY')= TO_CHAR(FiscalDay.Report_DATE,'MM/DD/YYYY')
	   AND TO_CHAR(CT1.CREATION_DATE,'MM/DD/YYYY')= TO_CHAR(FiscalDay.Report_DATE,'MM/DD/YYYY')
      AND rownum =1
      ) END PO_RECEIPT_COST_TRX_Period,  
-----------------------------------------------------	 PO_RECEIPT_COST_TRX_Period ---------------------------------------------- 					
				        cost_distb.rec_trxn_id cost_rcv_trx_id,
				        itt.transaction_type_name,
				        itt.description,
				        cob.cost_org_id,
				        xlalines.currency_code,
				        TO_NUMBER(NVL(xlalines.accounted_cr,0)) accounted_cr,
				        TO_NUMBER(NVL(xlalines.accounted_dr,0)) accounted_dr,
				        TO_NUMBER(NVL(xlalines.entered_cr,0)) entered_cr,
				        TO_NUMBER(NVL(xlalines.entered_dr,0)) entered_dr,
				        xlaglledgers.name AS ledger_name,
				        xlalines.accounting_class_code,
				        gp.period_name,
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
						gcc.segment12,
						gcc.segment13,
						gcc.segment14,
						gcc.segment15,
						gcc.segment16,
						gcc.segment17,
						gcc.segment18,
						gcc.segment19,
						gcc.segment20,
						gcc.segment21,
						gcc.segment22,
						gcc.segment23,
						gcc.segment24,
						gcc.segment25,
						gcc.segment26,
						gcc.segment27,
						gcc.segment28,
						gcc.segment29,
						gcc.segment30,
				        xlahdr.ledger_id,
						gp.end_date,
						gl.ledger_id fx_ledger_id,
						gl.name fx_ledger_name,
						h.ae_header_id,
                        h.ae_line_num
				   FROM CST_COST_ORGS_V                  cco,
						CST_COST_ORG_BOOKS               cob,
						CST_TRANSACTIONS                 ct,
						CST_INV_TRANSACTIONS             cit,
						CST_COST_DISTRIBUTIONS           cost_distb,
						CST_COST_DISTRIBUTION_LINES      cost_dist_lines,
						INV_TRANSACTION_TYPES_TL         itt,
						XLA_DISTRIBUTION_LINKS           h,
						XLA_AE_LINES                     xlalines,
						XLA_AE_HEADERS                   xlahdr,
						GL_CODE_COMBINATIONS             gcc,
						GL_PERIODS                       gp,
						GL_LEDGERS                       xlaglledgers,
						GL_LEDGERS                       gl,
						CST_COST_BOOKS_B                 ccbb
				  WHERE 1                                = 1
				    AND cco.cost_org_id                  = cob.cost_org_id
				    AND ct.cost_org_id                   = cco.cost_org_id
				    AND ct.cost_book_id                  = cob.cost_book_id
					AND cob.cost_book_id                 = ccbb.cost_book_id
				    AND cit.cst_inv_transaction_id       = ct.cst_inv_transaction_id
				    AND cost_distb.transaction_id        = ct.transaction_id
				    AND cost_distb.distribution_id       = cost_dist_lines.distribution_id
				    AND h.source_distribution_type       = cost_distb.entity_code
				    AND h.source_distribution_id_num_1   = cost_dist_lines.distribution_line_id
				    AND xlalines.ae_header_id            = h.ae_header_id
				    AND xlalines.ae_line_num             = h.ae_line_num
				    AND xlahdr.ae_header_id              = h.ae_header_id
				    AND xlahdr.ledger_id                 = cost_distb.ledger_id
				    AND xlalines.accounting_class_code   <> 'EXCHANGE_GAIN_LOSS'
				    AND xlalines.code_combination_id     = GCC.CODE_COMBINATION_ID
				    AND (TRUNC(xlalines.accounting_date) BETWEEN TRUNC(gp.start_date) AND TRUNC(gp.end_date))
				    AND gp.period_set_name               ='CCL CALENDAR'
				    AND xlahdr.gl_transfer_status_code   = 'Y'
				    AND xlalines.ledger_id               = xlaglledgers.ledger_id
				    AND xlaglledgers.name                LIKE '%PRM'
				    AND itt.language                     = 'US'
				    AND itt.transaction_type_id          = cit.base_txn_type_id
					AND gp.period_name                   = DECODE(:p_period, NULL 
                                                                           ,TO_CHAR(LAST_DAY(ADD_MONTHS(SYSDATE,-1)), 'MON-YY', 'NLS_DATE_LANGUAGE = American')
                                                                           ,:p_period
						                                          )
		            AND TRUNC(xlalines.accounting_date)  > TO_DATE('2018-03-31') --Added this condition to stop MJE creation before 31-MAR-2018
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
					--Added below query to get FCY and RPT ledger based on PRM ledger
				    AND (gl.name LIKE '%FCY' 
					--OR gl.name LIKE '%RPT'                            --REL-055 GERITM22902722 commented 
)
				    AND EXISTS(SELECT 'Y' 
							     FROM GL_LEDGER_RELATIONSHIPS  glr 
							    WHERE glr.primary_ledger_id    = xlaglledgers.ledger_id
								  AND glr.application_id       = 101
								  AND glr.target_ledger_id     = gl.ledger_id)
				    --above query ended
					--Added below query to check already created Journals should not be recreated
				    AND NOT EXISTS
								(SELECT 'N'
								   FROM	gl_je_headers jh, gl_je_categories gjc
								  WHERE	1=1
									AND	jh.ledger_id	          = gl.ledger_id
									AND	jh.period_name	          = gp.period_name
									AND jh.je_category            = gjc.je_category_name
									AND gjc.language              = 'US'
									AND	jh.je_source	          = 'Cost Accounting'
									AND	gjc.user_je_category_name = 'GE COSTING FX TRUEUP'
									AND jh.external_reference     = TO_CHAR(cost_distb.distribution_id)	--Already created JV's should not be recreated
								)
					--above query ended
					--Added below query to check already interfaced lines should not be re-interfaced
					AND NOT EXISTS
								(SELECT 1 
								   FROM GL_INTERFACE git
								  WHERE git.user_je_category_name = 'GE COSTING FX TRUEUP'
                                    AND git.user_je_source_name   = 'Cost Accounting'
                                    AND git.reference6            = TO_CHAR(cost_distb.distribution_id)
									AND git.status                = 'NEW'
								 )
					--above query ended
				    -----------------------------------------------------------------------------------------
			UNION ALL
				-----------------------------------------------------------------------------------------
				SELECT --Below query to extract COGS transaction in cost management
				       cco.cost_org_code,
					   'COGS Recognition' cost_transaction_type,
					   cct.transaction_id cost_trx_id,
					   cost_distb.distribution_id,
					   '2-'||cost_dist_lines.distribution_line_id distribution_line_id,
					   cct.transaction_date,
					   (SELECT gdr.conversion_rate
					      FROM GL_DAILY_RATES            gdr,
					   		   GL_FISCAL_DAY_V           fiscalday
					     WHERE gdr.conversion_type                       = '300000002138002'       ---conversion type as "MOR"
					   	   AND gdr.to_currency                           = 'USD'
					   	   AND gdr.from_currency                         =  xlalines.currency_code
					   	   AND fiscalday.fiscal_period_set_name          =  'CCL CALENDAR'
					   	   AND fiscalday.fiscal_period_number            <> '13'
					   	   AND TO_CHAR(GDR.CONVERSION_DATE,'MM/DD/YYYY') =  TO_CHAR(fiscalday.report_date,'MM/DD/YYYY')
					   	   AND FiscalDay.fiscal_period_name              =  gp.period_name
					   	   AND ROWNUM                                    =  1
					    ) mor_rate,						

						-----------------------------------------------------------PO_RECEIPT_COST_TRX_Period---------------------------------  
	  
	  CASE 	  WHEN 	 ( SELECT ITT1.TRANSACTION_TYPE_NAME
	  FROM CST_TRANSACTIONS CT2,
	       INV_TRANSACTION_TYPES_TL ITT1,
		   CST_INV_TRANSACTIONS CIT1
	  WHERE  CT2.TRANSACTION_ID          =  COST_DISTB.REC_TRXN_ID
	        AND ITT1.LANGUAGE            = 'US'
            AND ITT1.TRANSACTION_TYPE_ID = CIT1.BASE_TXN_TYPE_ID
	        AND CIT1.CST_INV_TRANSACTION_ID = CT2.CST_INV_TRANSACTION_ID
			AND ROWNUM = 1) = 	  'Purchase Order Receipt'  THEN
			
			(	  SELECT FiscalDay.fiscal_period_name
      FROM CST_TRANSACTIONS CT1,
        GL_FISCAL_DAY_V FiscalDay,
       CST_COST_DISTRIBUTIONS COST_DISTB1,
	   RCV_TRANSACTIONS RT1,
	   RCV_TRANSACTIONS  RT2	   
      WHERE 1=1
       AND CT1.TRANSACTION_ID                        =  COST_DISTB.REC_TRXN_ID
      AND FiscalDay.FISCAL_PERIOD_SET_NAME          = 'CCL CALENDAR'
      AND fiscalday.fiscal_period_number           <> '13'
      AND CT1.TRANSACTION_ID = COST_DISTB1.TRANSACTION_ID
      AND COST_DISTB1.COST_TRANSACTION_TYPE <> 'ADJUST'
	  AND CT1.RCV_TRANSACTION_ID = RT1.TRANSACTION_ID
	  AND RT1.PARENT_TRANSACTION_ID = RT2.TRANSACTION_ID	  
      AND TO_CHAR(RT2.CREATION_DATE,'MM/DD/YYYY')= TO_CHAR(FiscalDay.Report_DATE,'MM/DD/YYYY')	
      AND rownum =1  ) 
	  
	     WHEN 	 ( SELECT ITT1.TRANSACTION_TYPE_NAME
	  FROM CST_TRANSACTIONS CT2,
	       INV_TRANSACTION_TYPES_TL ITT1,
		   CST_INV_TRANSACTIONS CIT1
	  WHERE  CT2.TRANSACTION_ID          =  COST_DISTB.REC_TRXN_ID
	        AND ITT1.LANGUAGE            = 'US'
            AND ITT1.TRANSACTION_TYPE_ID = CIT1.BASE_TXN_TYPE_ID
	        AND CIT1.CST_INV_TRANSACTION_ID = CT2.CST_INV_TRANSACTION_ID
			AND ROWNUM = 1) = 	  'Purchase Order Receipt Adjustment'  THEN
			
			(SELECT FiscalDay.fiscal_period_name
      FROM CST_TRANSACTIONS CT1,
        GL_FISCAL_DAY_V FiscalDay,
       CST_COST_DISTRIBUTIONS COST_DISTB1,
	   RCV_TRANSACTIONS RT1,
	   RCV_TRANSACTIONS  RT2	   
      WHERE 1=1
       AND CT1.TRANSACTION_ID                        =  COST_DISTB.REC_TRXN_ID
      AND FiscalDay.FISCAL_PERIOD_SET_NAME          = 'CCL CALENDAR'
      AND fiscalday.fiscal_period_number           <> '13'
      AND CT1.TRANSACTION_ID = COST_DISTB1.TRANSACTION_ID
     -- AND COST_DISTB1.COST_TRANSACTION_TYPE <> 'ADJUST'
	  AND CT1.RCV_TRANSACTION_ID = RT1.TRANSACTION_ID
	  AND RT1.PARENT_TRANSACTION_ID = RT2.TRANSACTION_ID	  
      AND TO_CHAR(RT2.CREATION_DATE,'MM/DD/YYYY')= TO_CHAR(FiscalDay.Report_DATE,'MM/DD/YYYY')	
      AND rownum =1  ) 
	  
	  ---------------------------------Addition for RMA issue-------------------------------				
			WHEN ( SELECT ITT1.TRANSACTION_TYPE_NAME
	               FROM CST_TRANSACTIONS CT2,
	               INV_TRANSACTION_TYPES_TL ITT1,
		           CST_INV_TRANSACTIONS CIT1
	               WHERE  CT2.TRANSACTION_ID          =  COST_DISTB.REC_TRXN_ID
	                  AND ITT1.LANGUAGE            = 'US'
                      AND ITT1.TRANSACTION_TYPE_ID = CIT1.BASE_TXN_TYPE_ID
	                  AND CIT1.CST_INV_TRANSACTION_ID = CT2.CST_INV_TRANSACTION_ID
			          AND ROWNUM = 1) =   ('RMA Receipt') THEN  
	  
	              (    NVL(( SELECT FiscalDay.fiscal_period_name
                            FROM CST_TRANSACTIONS CT1,
                                 GL_FISCAL_DAY_V FiscalDay,
                                 CST_COST_DISTRIBUTIONS COST_DISTB1,
	                             RCV_TRANSACTIONS RT1,
	                             RCV_TRANSACTIONS  RT2	   
                           WHERE 1=1
                             AND CT1.TRANSACTION_ID  =  (SELECT COST_DISTB2.REC_TRXN_ID
                                                           FROM CST_TRANSACTIONS CST,  
                                                                CST_TRANSACTIONS CST1, 
	                                                            DOO_DOCUMENT_REFERENCES  DDR,
	                                                            INV_TRANSACTION_TYPES_TL ITT1,
	                                                            CST_COST_DISTRIBUTIONS COST_DISTB2	
                                                         WHERE  CST.DOO_FULLFILL_LINE_ID = DDR.FULFILL_LINE_ID
                                                            --AND CST.TRANSACTION_ID = CT.TRANSACTION_ID
															AND CST.TRANSACTION_ID =  COST_DISTB.REC_TRXN_ID
                                                            AND DDR.DOC_REF_TYPE IN  ('ORIGINAL_ORCHESTRATION_ORDER','ORIGINAL_SALES_ORDER') 
                                                            AND CST1.DOO_FULLFILL_LINE_ID = DDR.DOC_SUBLINE_ID	
                                                            AND CST1.COST_BOOK_ID = CT.COST_BOOK_ID
                                                            AND ITT1.LANGUAGE            = 'US'
                                                            AND CST1.TRANSACTION_ID = COST_DISTB2.TRANSACTION_ID
                                                            AND ITT1.TRANSACTION_TYPE_ID = CST1.BASE_TXN_TYPE_ID
                                                            AND ITT1.TRANSACTION_TYPE_NAME = 'Sales Order Issue'
                                                            AND ROWNUM = 1 )
                            AND FiscalDay.FISCAL_PERIOD_SET_NAME          = 'CCL CALENDAR'
                            AND fiscalday.fiscal_period_number           <> '13'
                            AND CT1.TRANSACTION_ID = COST_DISTB1.TRANSACTION_ID
                            AND COST_DISTB1.COST_TRANSACTION_TYPE <> 'ADJUST'
	                        AND CT1.RCV_TRANSACTION_ID = RT1.TRANSACTION_ID
	                        AND RT1.PARENT_TRANSACTION_ID = RT2.TRANSACTION_ID	  
                            AND TO_CHAR(RT2.CREATION_DATE,'MM/DD/YYYY')= TO_CHAR(FiscalDay.Report_DATE,'MM/DD/YYYY')	
                            AND rownum =1  ), 
                            ( SELECT FiscalDay.fiscal_period_name
                            FROM CST_TRANSACTIONS CT1,
                                 GL_FISCAL_DAY_V FiscalDay,
                                 CST_COST_DISTRIBUTIONS COST_DISTB1	                            
                           WHERE 1=1
                             AND CT1.TRANSACTION_ID  =  (SELECT COST_DISTB2.REC_TRXN_ID
                                                           FROM CST_TRANSACTIONS CST,  
                                                                CST_TRANSACTIONS CST1, 
	                                                            DOO_DOCUMENT_REFERENCES  DDR,
	                                                            INV_TRANSACTION_TYPES_TL ITT1,
	                                                            CST_COST_DISTRIBUTIONS COST_DISTB2	
                                                         WHERE  CST.DOO_FULLFILL_LINE_ID = DDR.FULFILL_LINE_ID
                                                            --AND CST.TRANSACTION_ID = CT.TRANSACTION_ID
															AND CST.TRANSACTION_ID =  COST_DISTB.REC_TRXN_ID
                                                            AND DDR.DOC_REF_TYPE IN  ('ORIGINAL_ORCHESTRATION_ORDER','ORIGINAL_SALES_ORDER') 
                                                            AND CST1.DOO_FULLFILL_LINE_ID = DDR.DOC_SUBLINE_ID	
                                                            AND CST1.COST_BOOK_ID = CT.COST_BOOK_ID
                                                            AND ITT1.LANGUAGE            = 'US'
                                                            AND CST1.TRANSACTION_ID = COST_DISTB2.TRANSACTION_ID
                                                            AND ITT1.TRANSACTION_TYPE_ID = CST1.BASE_TXN_TYPE_ID
                                                            AND ITT1.TRANSACTION_TYPE_NAME = 'Sales Order Issue'
                                                            AND ROWNUM = 1 )
                            AND FiscalDay.FISCAL_PERIOD_SET_NAME          = 'CCL CALENDAR'
                            AND fiscalday.fiscal_period_number           <> '13'
                            AND CT1.TRANSACTION_ID = COST_DISTB1.TRANSACTION_ID
                            AND COST_DISTB1.COST_TRANSACTION_TYPE <> 'ADJUST'
	                        AND TO_CHAR(CT1.CREATION_DATE,'MM/DD/YYYY')= TO_CHAR(FiscalDay.Report_DATE,'MM/DD/YYYY')	
                            AND rownum =1  )
							
							)
							
							
							)	
							
	        --------------------------------------------------------------------------------------

	  
	  
	   WHEN 	 XLALINES.ACCOUNTING_CLASS_CODE IN ('RMA_GAIN_LOSS','DEFERRED_RMA_GAIN_LOSS')  THEN
			
		( CASE WHEN     (SELECT ITT2.TRANSACTION_TYPE_NAME
                         FROM CST_TRANSACTIONS CST,  
                              CST_TRANSACTIONS CST1, 
	                          DOO_DOCUMENT_REFERENCES  DDR,
	                          INV_TRANSACTION_TYPES_TL ITT1,
	                          CST_COST_DISTRIBUTIONS COST_DISTB2,
	                          CST_TRANSACTIONS CST2,
	                          INV_TRANSACTION_TYPES_TL ITT2,
	                          CST_INV_TRANSACTIONS CIT1
                       WHERE  CST.DOO_FULLFILL_LINE_ID = DDR.FULFILL_LINE_ID
                          AND CST.TRANSACTION_ID = CT.TRANSACTION_ID
                          AND DDR.DOC_REF_TYPE IN  ('ORIGINAL_ORCHESTRATION_ORDER','ORIGINAL_SALES_ORDER') 
                          AND CST1.DOO_FULLFILL_LINE_ID = DDR.DOC_SUBLINE_ID	
                          AND CST1.COST_BOOK_ID = CT.COST_BOOK_ID
                          AND ITT1.LANGUAGE            = 'US'
                          AND CST1.TRANSACTION_ID = COST_DISTB2.TRANSACTION_ID
                          AND ITT1.TRANSACTION_TYPE_ID = CST1.BASE_TXN_TYPE_ID
                          AND CST2.TRANSACTION_ID = COST_DISTB2.REC_TRXN_ID 
                          AND CST2.CST_INV_TRANSACTION_ID = CIT1.CST_INV_TRANSACTION_ID
                          AND ITT2.LANGUAGE            = 'US'
                          AND ITT2.TRANSACTION_TYPE_ID = CIT1.BASE_TXN_TYPE_ID
                          AND ITT1.TRANSACTION_TYPE_NAME = 'Sales Order Issue'
                          AND ROWNUM = 1) = 'Purchase Order Receipt' THEN

                       ( SELECT FiscalDay.fiscal_period_name
                            FROM CST_TRANSACTIONS CT1,
                                 GL_FISCAL_DAY_V FiscalDay,
                                 CST_COST_DISTRIBUTIONS COST_DISTB1,
	                             RCV_TRANSACTIONS RT1,
	                             RCV_TRANSACTIONS  RT2	   
                           WHERE 1=1
                             AND CT1.TRANSACTION_ID  =  (SELECT COST_DISTB2.REC_TRXN_ID
                                                           FROM CST_TRANSACTIONS CST,  
                                                                CST_TRANSACTIONS CST1, 
	                                                            DOO_DOCUMENT_REFERENCES  DDR,
	                                                            INV_TRANSACTION_TYPES_TL ITT1,
	                                                            CST_COST_DISTRIBUTIONS COST_DISTB2	
                                                         WHERE  CST.DOO_FULLFILL_LINE_ID = DDR.FULFILL_LINE_ID
                                                            AND CST.TRANSACTION_ID = CT.TRANSACTION_ID
                                                            AND DDR.DOC_REF_TYPE IN  ('ORIGINAL_ORCHESTRATION_ORDER','ORIGINAL_SALES_ORDER') 
                                                            AND CST1.DOO_FULLFILL_LINE_ID = DDR.DOC_SUBLINE_ID	
                                                            AND CST1.COST_BOOK_ID = CT.COST_BOOK_ID
                                                            AND ITT1.LANGUAGE            = 'US'
                                                            AND CST1.TRANSACTION_ID = COST_DISTB2.TRANSACTION_ID
                                                            AND ITT1.TRANSACTION_TYPE_ID = CST1.BASE_TXN_TYPE_ID
                                                            AND ITT1.TRANSACTION_TYPE_NAME = 'Sales Order Issue'
                                                            AND ROWNUM = 1 )
                            AND FiscalDay.FISCAL_PERIOD_SET_NAME          = 'CCL CALENDAR'
                            AND fiscalday.fiscal_period_number           <> '13'
                            AND CT1.TRANSACTION_ID = COST_DISTB1.TRANSACTION_ID
                            AND COST_DISTB1.COST_TRANSACTION_TYPE <> 'ADJUST'
	                        AND CT1.RCV_TRANSACTION_ID = RT1.TRANSACTION_ID
	                        AND RT1.PARENT_TRANSACTION_ID = RT2.TRANSACTION_ID	  
                            AND TO_CHAR(RT2.CREATION_DATE,'MM/DD/YYYY')= TO_CHAR(FiscalDay.Report_DATE,'MM/DD/YYYY')	
                            AND rownum =1  ) 
	  
           WHEN	   (SELECT ITT2.TRANSACTION_TYPE_NAME
                      FROM CST_TRANSACTIONS CST,  
                           CST_TRANSACTIONS CST1, 
	                       DOO_DOCUMENT_REFERENCES  DDR,
	                       INV_TRANSACTION_TYPES_TL ITT1,
	                       CST_COST_DISTRIBUTIONS COST_DISTB2,
	                       CST_TRANSACTIONS CST2,
	                       INV_TRANSACTION_TYPES_TL ITT2,
	                       CST_INV_TRANSACTIONS CIT1
                    WHERE  CST.DOO_FULLFILL_LINE_ID = DDR.FULFILL_LINE_ID
                       AND CST.TRANSACTION_ID = CT.TRANSACTION_ID
                       AND DDR.DOC_REF_TYPE IN  ('ORIGINAL_ORCHESTRATION_ORDER','ORIGINAL_SALES_ORDER') 
                       AND CST1.DOO_FULLFILL_LINE_ID = DDR.DOC_SUBLINE_ID	
                       AND CST1.COST_BOOK_ID = CT.COST_BOOK_ID
                       AND ITT1.LANGUAGE            = 'US'
                       AND CST1.TRANSACTION_ID = COST_DISTB2.TRANSACTION_ID
                       AND ITT1.TRANSACTION_TYPE_ID = CST1.BASE_TXN_TYPE_ID
                       AND CST2.TRANSACTION_ID = COST_DISTB2.REC_TRXN_ID 
                       AND CST2.CST_INV_TRANSACTION_ID = CIT1.CST_INV_TRANSACTION_ID
                       AND ITT2.LANGUAGE            = 'US'
                       AND ITT2.TRANSACTION_TYPE_ID = CIT1.BASE_TXN_TYPE_ID
                       AND ITT1.TRANSACTION_TYPE_NAME = 'Sales Order Issue'
                       AND ROWNUM = 1) = 'Purchase Order Receipt Adjustment' THEN
	  
	         (	  SELECT FiscalDay.fiscal_period_name
                        FROM CST_TRANSACTIONS CT1,
                             GL_FISCAL_DAY_V FiscalDay,
                             CST_COST_DISTRIBUTIONS COST_DISTB1,
	                         RCV_TRANSACTIONS RT1,
	                         RCV_TRANSACTIONS  RT2	   
                        WHERE 1=1
                         AND CT1.TRANSACTION_ID  =  (SELECT COST_DISTB2.REC_TRXN_ID
                                                       FROM CST_TRANSACTIONS CST,  
                                                            CST_TRANSACTIONS CST1, 
	                                                        DOO_DOCUMENT_REFERENCES  DDR,
	                                                        INV_TRANSACTION_TYPES_TL ITT1,
	                                                        CST_COST_DISTRIBUTIONS COST_DISTB2	
                                                     WHERE  CST.DOO_FULLFILL_LINE_ID = DDR.FULFILL_LINE_ID
                                                        AND CST.TRANSACTION_ID = CT.TRANSACTION_ID
                                                        AND DDR.DOC_REF_TYPE IN  ('ORIGINAL_ORCHESTRATION_ORDER','ORIGINAL_SALES_ORDER') 
                                                        AND CST1.DOO_FULLFILL_LINE_ID = DDR.DOC_SUBLINE_ID	
                                                        AND CST1.COST_BOOK_ID = CT.COST_BOOK_ID
                                                        AND ITT1.LANGUAGE            = 'US'
                                                        AND CST1.TRANSACTION_ID = COST_DISTB2.TRANSACTION_ID
                                                        AND ITT1.TRANSACTION_TYPE_ID = CST1.BASE_TXN_TYPE_ID
                                                        AND ITT1.TRANSACTION_TYPE_NAME = 'Sales Order Issue'
                                                        AND ROWNUM = 1 )
                         AND FiscalDay.FISCAL_PERIOD_SET_NAME          = 'CCL CALENDAR'
                         AND fiscalday.fiscal_period_number           <> '13'
                         AND CT1.TRANSACTION_ID = COST_DISTB1.TRANSACTION_ID
                            --AND COST_DISTB1.COST_TRANSACTION_TYPE <> 'ADJUST'
	                     AND CT1.RCV_TRANSACTION_ID = RT1.TRANSACTION_ID
	                     AND RT1.PARENT_TRANSACTION_ID = RT2.TRANSACTION_ID	  
                         AND TO_CHAR(RT2.CREATION_DATE,'MM/DD/YYYY')= TO_CHAR(FiscalDay.Report_DATE,'MM/DD/YYYY')	
                         AND rownum =1  )

                         ELSE
						 
						  ( SELECT FiscalDay.fiscal_period_name
                                  FROM CST_TRANSACTIONS CT1,
                                       GL_FISCAL_DAY_V FiscalDay,
                                       CST_COST_DISTRIBUTIONS COST_DISTB1
                                 WHERE 1=1
                                   AND CT1.TRANSACTION_ID                        =  (SELECT COST_DISTB2.REC_TRXN_ID
                                                       FROM CST_TRANSACTIONS CST,  
                                                            CST_TRANSACTIONS CST1, 
	                                                        DOO_DOCUMENT_REFERENCES  DDR,
	                                                        INV_TRANSACTION_TYPES_TL ITT1,
	                                                        CST_COST_DISTRIBUTIONS COST_DISTB2	
                                                     WHERE  CST.DOO_FULLFILL_LINE_ID = DDR.FULFILL_LINE_ID
                                                        AND CST.TRANSACTION_ID = CT.TRANSACTION_ID
                                                        AND DDR.DOC_REF_TYPE IN  ('ORIGINAL_ORCHESTRATION_ORDER','ORIGINAL_SALES_ORDER') 
                                                        AND CST1.DOO_FULLFILL_LINE_ID = DDR.DOC_SUBLINE_ID	
                                                        AND CST1.COST_BOOK_ID = CT.COST_BOOK_ID
                                                        AND ITT1.LANGUAGE            = 'US'
                                                        AND CST1.TRANSACTION_ID = COST_DISTB2.TRANSACTION_ID
                                                        AND ITT1.TRANSACTION_TYPE_ID = CST1.BASE_TXN_TYPE_ID
                                                        AND ITT1.TRANSACTION_TYPE_NAME = 'Sales Order Issue'
                                                        AND ROWNUM = 1 )
                                   AND FiscalDay.FISCAL_PERIOD_SET_NAME          = 'CCL CALENDAR'
                                   AND fiscalday.fiscal_period_number           <> '13'
                                   AND CT1.TRANSACTION_ID = COST_DISTB1.TRANSACTION_ID
                                   AND COST_DISTB1.COST_TRANSACTION_TYPE <> 'ADJUST'
                                   AND TO_CHAR(CT1.CREATION_DATE,'MM/DD/YYYY')= TO_CHAR(FiscalDay.Report_DATE,'MM/DD/YYYY')
                                   AND rownum =1
                                     ) 

						 END)   
			
		ELSE	
					
	  
	  ( SELECT FiscalDay.fiscal_period_name
      FROM CST_TRANSACTIONS CT1,
        GL_FISCAL_DAY_V FiscalDay,
       CST_COST_DISTRIBUTIONS COST_DISTB1
      WHERE 1=1
      AND CT1.TRANSACTION_ID                        =  COST_DISTB.REC_TRXN_ID
      AND FiscalDay.FISCAL_PERIOD_SET_NAME          = 'CCL CALENDAR'
      AND fiscalday.fiscal_period_number           <> '13'
      AND CT1.TRANSACTION_ID = COST_DISTB1.TRANSACTION_ID
      AND COST_DISTB1.COST_TRANSACTION_TYPE <> 'ADJUST'
      --AND TO_CHAR(CT1.TRANSACTION_DATE,'MM/DD/YYYY')= TO_CHAR(FiscalDay.Report_DATE,'MM/DD/YYYY')
	   AND TO_CHAR(CT1.CREATION_DATE,'MM/DD/YYYY')= TO_CHAR(FiscalDay.Report_DATE,'MM/DD/YYYY')
      AND rownum =1
      ) END 	  PO_RECEIPT_COST_TRX_Period,	  
	------------------------------------------PO_RECEIPT_COST_TRX_Period------------------------------------------------------------						
						cost_distb.rec_trxn_id    cost_rcv_trx_id,
						'COGS Recognition'  transaction_type_name,
						'COGS Recognition'  description,
						cob.cost_org_id,
						xlalines.currency_code,
						TO_NUMBER(NVL(xlalines.accounted_cr,0)) accounted_cr,
						TO_NUMBER(NVL(xlalines.accounted_dr,0)) accounted_dr,
						TO_NUMBER(NVL(xlalines.entered_cr,0)) entered_cr,
						TO_NUMBER(NVL(XLALINES.ENTERED_DR,0)) entered_dr,
						xlaglledgers.name AS ledger_name,
						xlalines.accounting_class_code,
						gp.period_name,
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
						gcc.segment12,
						gcc.segment13,
						gcc.segment14,
						gcc.segment15,
						gcc.segment16,
						gcc.segment17,
						gcc.segment18,
						gcc.segment19,
						gcc.segment20,
						gcc.segment21,
						gcc.segment22,
						gcc.segment23,
						gcc.segment24,
						gcc.segment25,
						gcc.segment26,
						gcc.segment27,
						gcc.segment28,
						gcc.segment29,
						gcc.segment30,
						xlahdr.ledger_id,
						gp.end_date,
						gl.ledger_id fx_ledger_id,
						gl.name fx_ledger_name,
						h.ae_header_id,
                        h.ae_line_num
			      FROM CST_COST_ORGS_V                  cco,
				       CST_COST_ORG_BOOKS               cob,
				       CST_TRANSACTIONS                 ct,
				       CST_COGS_TRANSACTIONS            cct,
				       CST_COST_DISTRIBUTIONS           cost_distb,
				       CST_COST_DISTRIBUTION_LINES      cost_dist_lines,
				       XLA_DISTRIBUTION_LINKS           h,
				       XLA_AE_LINES                     xlalines,
				       XLA_AE_HEADERS                   xlahdr,
				       GL_CODE_COMBINATIONS             gcc,
				       GL_PERIODS                       gp,
				       GL_LEDGERS                       xlaglledgers,
					   GL_LEDGERS                       gl,
					   CST_COST_BOOKS_B                 ccbb
			     WHERE 1                                =  1
				   AND cco.cost_org_id                  =  cob.cost_org_id
				   AND ct.cost_org_id                   =  cco.cost_org_id
				   AND ct.cost_book_id                  =  cob.cost_book_id
				   AND cob.cost_book_id                 =  ccbb.cost_book_id
				   AND cct.cst_transaction_id           =  ct.transaction_id
				   AND cost_distb.transaction_id        =  cct.transaction_id
				   AND cost_distb.distribution_id       =  cost_dist_lines.distribution_id
				   AND h.source_distribution_type       =  cost_distb.entity_code
				   AND h.source_distribution_id_num_1   =  cost_dist_lines.distribution_line_id
				   AND xlalines.ae_header_id            =  h.ae_header_id
				   AND xlalines.ae_line_num             =  h.ae_line_num
				   AND xlahdr.ae_header_id              =  h.ae_header_id
				   AND xlahdr.ledger_id                 =  cost_distb.ledger_id
				   AND xlalines.accounting_class_code   <> 'EXCHANGE_GAIN_LOSS'
				   AND xlalines.code_combination_id     =  gcc.code_combination_id
				   AND (TRUNC(xlalines.accounting_date) BETWEEN TRUNC(gp.start_date) AND TRUNC(gp.end_date))
				   AND gp.period_set_name               ='CCL CALENDAR'
				   AND xlahdr.gl_transfer_status_code   = 'Y'
				   AND xlaglledgers.name                LIKE '%PRM'
				   AND xlalines.ledger_id               = xlaglledgers.ledger_id
				   AND gp.period_name                   = DECODE(:p_period, NULL 
                                                                           ,TO_CHAR(LAST_DAY(ADD_MONTHS(SYSDATE,-1)), 'MON-YY', 'NLS_DATE_LANGUAGE = American')
                                                                           ,:p_period
						                                          )
		           AND TRUNC(xlalines.accounting_date)  > TO_DATE('2018-03-31') --Added this condition to stop MJE creation before 31-MAR-2018
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
					--Added below query to get FCY and RPT ledger based on PRM ledger
				   AND (gl.name LIKE '%FCY' 
				   --OR gl.name LIKE '%RPT'                       --REL-055 GERITM22902722 Commented
				   )
				   AND EXISTS(SELECT 'Y' 
							    FROM GL_LEDGER_RELATIONSHIPS  glr 
							   WHERE glr.primary_ledger_id    = xlaglledgers.ledger_id
								 AND glr.application_id       = 101
								 AND glr.target_ledger_id     = gl.ledger_id)
				   --above query ended
				   --Added below query to check already created Journals should not be recreated
				   AND NOT EXISTS
								(SELECT 'N'
								   FROM	gl_je_headers jh, gl_je_categories gjc
								  WHERE	1=1
									AND	jh.ledger_id	          = gl.ledger_id
									AND	jh.period_name	          = gp.period_name
									AND jh.je_category            = gjc.je_category_name
									AND gjc.language              = 'US'
									AND	jh.je_source	          = 'Cost Accounting'
									AND	gjc.user_je_category_name = 'GE COSTING FX TRUEUP'
									AND jh.external_reference     = TO_CHAR(cost_distb.distribution_id)	--Already created JV's should not be recreated
								)
			       --above query ended
				   --Added below query to check already interfaced lines should not be re-interfaced
					AND NOT EXISTS
								(SELECT 1 
								   FROM GL_INTERFACE git
								  WHERE git.user_je_category_name = 'GE COSTING FX TRUEUP'
                                    AND git.user_je_source_name   = 'Cost Accounting'
                                    AND git.reference6            = TO_CHAR(cost_distb.distribution_id)
									AND git.status                = 'NEW'
								 )
					--above query ended
				)cost_in
	  )cost
	WHERE (((po_receipt_period_mor_rate-mor_rate)*entered_dr) != 0 OR ((po_receipt_period_mor_rate-mor_rate)*entered_cr) !=0)
	ORDER BY cost.distribution_id, cost.ledger_id