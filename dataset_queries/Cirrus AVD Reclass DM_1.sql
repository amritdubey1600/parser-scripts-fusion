/*
*************************************************************************************************
-- Name             : Cirrus AVD JE Reclass
-- Date             : 09/14/2020
-- Author           : Himanshu Singh
-- Purpose          : 
-- Type             : Sql
*************************************************************************************************
-- Change history
-- Version         Date          Developer                            Description  
-- 1.0           04/30/2020		 Akash Mohanty  					  Cirrus AVD JE Reclass
*************************************************************************************************
*/
With  
Company_Code_Map as 
       (
           select LOOKUP_CODE source_company_code, DESCRIPTION target_company_code from
			fnd_lookup_values flv
			where 1=1
			AND flv.lookup_type                		= 	'CIRRUS_AVD_GED_RECLASS_COMPANY'
			AND flv.language                   		= 	'US'
			AND flv.enabled_flag               		= 	'Y'             
       ),

Cost_Center_Map as 
       (
           select LOOKUP_CODE source_cost_center, DESCRIPTION target_cost_center from
			fnd_lookup_values flv
			where 1=1
			AND flv.lookup_type                		= 	'CIRRUS_AVD_GED_RECLASS_COSTCEN'
			AND flv.language                   		= 	'US'
			AND flv.enabled_flag               		= 	'Y'            
       ),

Product_Line_Map as 
       (
           select LOOKUP_CODE source_product_line, DESCRIPTION target_product_line from
			fnd_lookup_values flv
			where 1=1
			AND flv.lookup_type                		= 	'CIRRUS_AVD_GED_RECLASS_PRODUCT'
			AND flv.language                   		= 	'US'
			AND flv.enabled_flag               		= 	'Y'            
       ),

Acc_Exclude as 	   
(select distinct gc.segment1,gc.segment2 from GL_CODE_COMBINATIONS gc
WHERE 1=1
AND (gc.segment2 IN ('2012505000','4110302000') AND gc.segment1= 'V926')),

Acc_Exclude2 as 	   
(select distinct gc.segment1,gc.segment3 from GL_CODE_COMBINATIONS gc
WHERE 1=1
AND (gc.segment2='3720102000' AND gc.segment3 LIKE 'DA%'))	   



SELECT 1 AS "KEY",
	   'NEW'	                                                        ||','||  --*Status Code
	   JE.ledger_id                                                     ||','||  --*ledger id
	   JE.Effective_Date_Trx                                            ||','||  --*Effective Date of Transaction
	   JE.Source                                                        ||','||  --*Journal Source
	   JE.Category                                                      ||','||  --*Journal Category
	   JE.currency_code                                                 ||','||  --*Currency Code
	   JE.JE_Creation_Date                                              ||','||  --*Journal Entry Creation Date
	   JE.Actual_Flag                                                   ||','||  --*Actual Flag
	   JE.segment1	                                                    ||','||  --Segment1
	   JE.segment2	                                                    ||','||  --Segment2
	   JE.segment3	                                                    ||','||  --Segment3
	   JE.segment4	                                                    ||','||  --Segment4
	   JE.segment5	                                                    ||','||  --Segment5
	   JE.segment6	                                                    ||','||  --Segment6
	   JE.segment7	                                                    ||','||  --Segment7
	   JE.segment8	                                                    ||','||  --Segment8
	   JE.segment9	                                                    ||','||  --Segment9
	   JE.segment10	                                                    ||','||  --Segment10
	   JE.segment11	                                                    ||','||  --Segment11
	   JE.segment12	                                                    ||','||  --Segment12
	   JE.segment13	                                                    ||','||  --Segment13
	   JE.segment14	                                                    ||','||  --Segment14
	   JE.segment15	                                                    ||','||  --Segment15
	   JE.segment16	                                                    ||','||  --Segment16
	   JE.segment17	                                                    ||','||  --Segment17
	   JE.segment18	                                                    ||','||  --Segment18
	   JE.segment19	                                                    ||','||  --Segment19
	   JE.segment20	                                                    ||','||  --Segment20
	   JE.segment21	                                                    ||','||  --Segment21
	   JE.segment22	                                                    ||','||  --Segment22
	   JE.segment23	                                                    ||','||  --Segment23
	   JE.segment24	                                                    ||','||  --Segment24
	   JE.segment25	                                                    ||','||  --Segment25
	   JE.segment26	                                                    ||','||  --Segment26
	   JE.segment27	                                                    ||','||  --Segment27
	   JE.segment28	                                                    ||','||  --Segment28
	   JE.segment29	                                                    ||','||  --Segment29
	   JE.segment30	                                                    ||','||  --Segment30
	   JE.entered_dr                                                    ||','||  --Entered Debit Amount
	   JE.entered_cr                                                    ||','||  --Entered Credit Amount
	   JE.accounted_dr                                                  ||','||  --Converted Debit Amount
	   JE.accounted_cr                                                  ||','||  --Converted Credit Amount
	   substr(JE.Batch_Name,0,99)                                       ||','||  --REFERENCE1 (Batch Name)
	   substr(JE.Batch_Desc,0,239)                                      ||','||  --REFERENCE2 (Batch Description)
	                                                                      ','||  --REFERENCE3
	   substr(JE.Journal_Name,0,99)                                     ||','||  --REFERENCE4 (Journal Entry Name)
	   substr(JE.Journal_Desc,0,239)                                    ||','||  --REFERENCE5 (Journal Entry Description)
	   JE.je_header_id   	                                            ||','||  --REFERENCE6 (Journal Entry Reference)
			                                                              ','||  --REFERENCE7 (Journal Entry Reversal flag)
			                                                              ','||  --REFERENCE8 (Journal Entry Reversal Period)
			                                                              ','||  --REFERENCE9 (Journal Reversal Method)
	   substr(JE.line_desc,0,239)	                                    ||','||  --REFERENCE10 (Journal Entry Line Description)
			                                                              ','||  --Reference column 1
			                                                              ','||  --Reference column 2
			                                                              ','||  --Reference column 3
			                                                              ','||  --Reference column 4
			                                                              ','||  --Reference column 5
	  JE.JE_LINE_NUM   	                                                ||','||  --Reference column 6
			                                                              ','||  --Reference column 7
			                                                              ','||  --Reference column 8
			                                                              ','||  --Reference column 9
			                                                              ','||  --Reference column 10
			                                                              ','||  --Statistical Amount
	  'User'   	                                                        ||','||  --Currency Conversion Type
	  TO_CHAR(CAST(SUBSTR(CURRENCY_CONVERSION_DATE, 1, 10) AS DATE),'YYYY/MM/DD')     ||','||  --Currency Conversion Date
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
        JE.period_name AS main
  FROM
	(			
			Select 
			'New' Status,
			gl.ledger_id,
			gl.name ledger_name,
			TO_CHAR(gjh.DEFAULT_EFFECTIVE_DATE,'YYYY/MM/DD') Effective_Date_Trx,
			'GED_AVD_RECLASS' Source,
			(case when glc.USER_JE_CATEGORY_NAME in ('ACC','Accrual Reverse Monthly','GE_TAE_ACC')
			     Then 'CIRRUS_AVD_GED_ACCRUAL'
				 ELSE
				 glc.USER_JE_CATEGORY_NAME
			End) Category,
			gjl.currency_code,
			TO_CHAR(CAST(SUBSTR(SYSDATE, 1, 10) AS DATE),'YYYY/MM/DD') JE_Creation_Date,
			'A' Actual_Flag,
			CCM.target_company_code segment1,
			decode(cc.segment2, '1010101000','3810101000',cc.segment2) segment2,  -- Account Mapping
			--cc.segment3,
			NVL(TP.target_company_code,cc.segment3) segment3,
			(CASE 	WHEN cc.segment2 LIKE '40%' THEN 'DG2AVN' 
					WHEN cc.segment2 LIKE '5110201000' THEN 'DGV600' 
					WHEN cc.segment2 LIKE '5110202000' THEN 'DGV600'
					WHEN cc.segment2 LIKE '5110301000' THEN 'DGV600'
					ELSE NVL(COSTCENTERMAP.target_cost_center,'DGV140')
			END) segment4,	
			--NVL(COSTCENTERMAP.target_cost_center,'DGV140') segment4,
			cc.segment5,
			'0000000000' segment6,
			'000000' segment7,
			NVL(PRODUCTLINEMAP.target_product_line,'DGAVHQ') segment8,
			cc.segment9,
			cc.segment10,
			cc.segment11,
			cc.segment12,
			cc.segment13,
			cc.segment14,
			cc.segment15,
			cc.segment16,
			cc.segment17,
			cc.segment18,
			cc.segment19,
			cc.segment20,
			cc.segment21,
			cc.segment22,
			cc.segment23,
			cc.segment24,
			cc.segment25,
			cc.segment26,
			cc.segment27,
			cc.segment28,
			cc.segment29,
			cc.segment30,
			NVL(gjl.entered_dr,0) entered_dr,
			NVL(gjl.entered_cr,0) entered_cr,
			NVL(gjl.accounted_dr,0) accounted_dr ,
			NVL(gjl.accounted_cr,0) accounted_cr,			
			'Reclass-'||replace(replace(replace(gjb.name,CHR(10),''),CHR(13),''),',','') Batch_Name,
			'Reclass-'||replace(replace(replace(gjb.DESCRIPTION,CHR(10),''),CHR(13),''),',','') Batch_Desc,			
			'Reclass-'||replace(replace(replace(gjh.name,CHR(10),''),CHR(13),''),',','') Journal_Name,
			'Reclass-'||replace(replace(replace(gjh.DESCRIPTION,CHR(10),''),CHR(13),''),',','') Journal_Desc,
			gjb.je_batch_id,
			gjh.je_header_id,
			gjl.JE_LINE_NUM,			
			replace(replace(replace(gjl.DESCRIPTION,CHR(10),''),CHR(13),''),',','') line_desc,
			gp.period_name,
			gjl.CURRENCY_CONVERSION_DATE,
			gjl.CURRENCY_CONVERSION_TYPE,
			gjl.CURRENCY_CONVERSION_RATE
			FROM   GL_JE_BATCHES gjb,
				   GL_JE_HEADERS gjh,
				   GL_JE_LINES gjl,
				   GL_LEDGERS   gl,
				   GL_CODE_COMBINATIONS cc,
				   GL_JE_SOURCES GLS,
				   GL_JE_CATEGORIES GLC,
				   GL_PERIOD_STATUSES gp,				
				   Company_Code_Map	CCM,
                   Cost_Center_Map	COSTCENTERMAP,
                   Product_Line_Map PRODUCTLINEMAP,
                   Company_Code_Map TP				   
			WHERE                      1  =  1
			AND gjb.je_batch_id           = gjh.je_batch_id
			AND gjl.je_header_id          = gjh.je_header_id
			AND gjl.code_combination_id   = cc.code_combination_id
			AND gl.ledger_id              = gjl.ledger_id
			AND gls.je_source_name        = gjh.je_source
			AND glc.je_category_name      = gjh.je_category
			AND gjl.period_name           = gp.period_name
			AND gl.name					  = NVL(:p_ledger,gl.name)
			AND gp.period_name            = NVL(:P_PERIOD_NAME,gp.period_name)
			--AND gp.period_set_name	  = 'CCL CALENDAR'
			AND gp.application_id         = 101
			AND gp.ADJUSTMENT_PERIOD_FLAG = 'N'
			AND gp.LEDGER_ID              = gjl.ledger_id
			AND gp.closing_status         = 'O'
			--AND cc.SEGMENT1               LIKE 'V%'
			AND gl.name                   LIKE '%PRM%'
			AND GLS.LANGUAGE              = 'US'
			AND GLC.LANGUAGE              = 'US'
			AND gjh.actual_flag           = 'A'
			AND gjh.STATUS                = 'P'
			AND gls.USER_JE_SOURCE_NAME   not in ('GED_AVD_RECLASS','GED_AVD_REVERSAL')
			AND cc.SEGMENT1               = CCM.source_company_code
			AND cc.segment4               = COSTCENTERMAP.source_cost_center(+)			
			AND cc.segment8               = PRODUCTLINEMAP.source_product_line--(+)
			AND cc.segment3               = TP.source_company_code(+)
			--AND gjh.je_header_id = 11814136
			AND NOT EXISTS
							(
							 SELECT 1 
							 FROM  GL_INTERFACE git
							 WHERE 1=1
							 AND   git.user_je_source_name   = 'GED_AVD_RECLASS'
							 AND   git.reference6            =  TO_CHAR(gjh.je_header_id)
							 --AND   git.status                = 'NEW'
							)
			AND NOT EXISTS
							(
							 SELECT 'N'
							 FROM	gl_je_headers jh, GL_JE_SOURCES gls
							 WHERE	1=1
							 AND	jh.ledger_id	         = gl.ledger_id
							 AND	jh.period_name	         = gp.period_name
							 AND	jh.je_source	         = gls.je_source_name
							 AND    gls.user_je_source_name  = 'GED_AVD_RECLASS'
							 AND    GLS.LANGUAGE              = 'US'
							 AND    jh.external_reference    = TO_CHAR(gjh.je_header_id)	--Already created JV's should not be recreated
							)
			AND NOT EXISTS
							(
							select LOOKUP_CODE from
			fnd_lookup_values flv
			where 1=1
			AND flv.lookup_type                		= 	'CIRRUS_AVDGED_REC_ACCT_EXCLUDE'
			AND flv.language                   		= 	'US'
			AND flv.enabled_flag               		= 	'Y'
		    AND LOOKUP_CODE = cc.segment2
							)
			/*AND NOT EXISTS 
			(SELECT 1 FROM Acc_Exclude)*/
			--AND cc.segment2 NOT IN ('3720102000')	
			--AND (cc.segment2 NOT IN ('2012505000','4110302000') AND cc.segment1 IN ('V926'))
			--AND DECODE(cc.segment1,'V926',DECODE(cc.segment2,'2012505000','2','4110302000','2','1'),'1') ='1'
			--AND DECODE(SUBSTR(cc.segment1,1,2),'DA',DECODE(cc.segment2,'3720102000','2','1'),'1') ='1'
			--AND (cc.segment2 NOT IN ('3720102000') AND cc.segment3 NOT LIKE 'DA%')
			--AND (cc.segment8 NOT IN ('000000') AND cc.segment1 NOT IN ('V895'))
			/*AND NOT EXISTS 
			(
			SELECT 1 FROM GL_CODE_COMBINATIONS gc
			WHERE gc.code_combination_id = cc.code_combination_id
			AND   gc.segment2 = cc.segment2
			AND   gc.segment1 = cc.segment1
			AND gc.segment2 = '3720102000'
			AND gc.segment1 LIKE 'DA%'
			)*/
                           AND NOT EXISTS 
			(SELECT 1 FROM Acc_Exclude
            WHERE segment1=CCM.target_company_code
            AND segment2=cc.segment2)
			              AND NOT EXISTS 
			(SELECT 1 FROM Acc_Exclude2
            WHERE segment2=cc.segment2
            AND segment3=cc.segment3)
			
			UNION ALL
			
			Select 
			'New' Status,
			gl.ledger_id,
			gl.name ledger_name,
			TO_CHAR(gjh.DEFAULT_EFFECTIVE_DATE,'YYYY/MM/DD') Effective_Date_Trx,
			'GED_AVD_REVERSAL' Source,
			(case when glc.USER_JE_CATEGORY_NAME in ('ACC','Accrual Reverse Monthly','GE_TAE_ACC')
			     Then 'CIRRUS_AVD_GED_ACCRUAL'
				 ELSE
				 glc.USER_JE_CATEGORY_NAME
			End) Category,
			gjl.currency_code,
			TO_CHAR(CAST(SUBSTR(SYSDATE, 1, 10) AS DATE),'YYYY/MM/DD') JE_Creation_Date,
			'A' Actual_Flag,
			cc.segment1,
            cc.segment2,			
			cc.segment3,
			cc.segment4,
			cc.segment5,
			cc.segment6,
			cc.segment7,
			cc.segment8,
			cc.segment9,
			cc.segment10,
			cc.segment11,
			cc.segment12,
			cc.segment13,
			cc.segment14,
			cc.segment15,
			cc.segment16,
			cc.segment17,
			cc.segment18,
			cc.segment19,
			cc.segment20,
			cc.segment21,
			cc.segment22,
			cc.segment23,
			cc.segment24,
			cc.segment25,
			cc.segment26,
			cc.segment27,
			cc.segment28,
			cc.segment29,
			cc.segment30,
			NVL(gjl.entered_cr,0) entered_dr,
			NVL(gjl.entered_dr,0) entered_cr,
			NVL(gjl.accounted_cr,0) accounted_dr ,
			NVL(gjl.accounted_dr,0) accounted_cr,
			'Reverse-'||replace(replace(replace(gjb.name,CHR(10),''),CHR(13),''),',','') Batch_Name,
			'Reverse-'||replace(replace(replace(gjb.DESCRIPTION,CHR(10),''),CHR(13),''),',','') Batch_Desc,			
			'Reverse-'||replace(replace(replace(gjh.name,CHR(10),''),CHR(13),''),',','') Journal_Name,
			'Reverse-'||replace(replace(replace(gjh.DESCRIPTION,CHR(10),''),CHR(13),''),',','') Journal_Desc,
			gjb.je_batch_id,
			gjh.je_header_id,
			gjl.JE_LINE_NUM,
			replace(replace(replace(gjl.DESCRIPTION,CHR(10),''),CHR(13),''),',','') line_desc,			
			gp.period_name,
			gjl.CURRENCY_CONVERSION_DATE,
			gjl.CURRENCY_CONVERSION_TYPE,
			gjl.CURRENCY_CONVERSION_RATE
			FROM   GL_JE_BATCHES gjb,
				   GL_JE_HEADERS gjh,
				   GL_JE_LINES gjl,
				   GL_LEDGERS   gl,
				   GL_CODE_COMBINATIONS cc,
				   GL_JE_SOURCES GLS,
				   GL_JE_CATEGORIES GLC,
				   GL_PERIOD_STATUSES gp,
				   Company_Code_Map	CCM,
                   Cost_Center_Map	COSTCENTERMAP,
                   Product_Line_Map PRODUCTLINEMAP,
                   Company_Code_Map TP				   
			WHERE                      1  =  1
			AND gjb.je_batch_id           = gjh.je_batch_id
			AND gjl.je_header_id          = gjh.je_header_id
			AND gjl.code_combination_id   = cc.code_combination_id
			AND gl.ledger_id              = gjl.ledger_id
			AND gls.je_source_name        = gjh.je_source
			AND glc.je_category_name      = gjh.je_category
			AND gjl.period_name           = gp.period_name
			AND gl.name					  = NVL(:p_ledger,gl.name)
			AND gp.period_name            = NVL(:P_PERIOD_NAME,gp.period_name)
			--AND gp.period_set_name	  = 'CCL CALENDAR'
			AND gp.application_id         = 101
			AND gp.ADJUSTMENT_PERIOD_FLAG = 'N'
			AND gp.LEDGER_ID              = gjl.ledger_id
			AND gp.closing_status         = 'O'
			--AND cc.SEGMENT1               LIKE 'V%'
			AND gl.name                   LIKE '%PRM%'			
			AND GLS.LANGUAGE              = 'US'
			AND GLC.LANGUAGE              = 'US'
			AND gjh.actual_flag           = 'A'
			AND gjh.STATUS                = 'P'
			AND gls.USER_JE_SOURCE_NAME   not in ('GED_AVD_RECLASS','GED_AVD_REVERSAL')
			AND cc.SEGMENT1               = CCM.source_company_code
			AND cc.segment4               = COSTCENTERMAP.source_cost_center(+)			
			AND cc.segment8               = PRODUCTLINEMAP.source_product_line--(+)
			AND cc.segment3               = TP.source_company_code(+)
			--AND 1=2
			--AND gjh.je_header_id = 11814136
			AND NOT EXISTS
							(
							 SELECT 1 
							 FROM  GL_INTERFACE git
							 WHERE 1=1
							 AND   git.user_je_source_name   = 'GED_AVD_REVERSAL'
							 AND   git.reference6            =  TO_CHAR(gjh.je_header_id)
							 --AND   git.status                = 'NEW'
							)
			AND NOT EXISTS
							(
							
							SELECT 'N'
							 FROM	gl_je_headers jh, GL_JE_SOURCES gls
							 WHERE	1=1
							 AND	jh.ledger_id	         = gl.ledger_id
							 AND	jh.period_name	         = gp.period_name
							 AND	jh.je_source	         = gls.je_source_name
							 AND    gls.user_je_source_name  = 'GED_AVD_REVERSAL'
							 AND    GLS.LANGUAGE              = 'US'
							 AND    jh.external_reference    = TO_CHAR(gjh.je_header_id)							
							 	--Already created JV's should not be recreated
							)
			AND NOT EXISTS
							(
							select LOOKUP_CODE from
			fnd_lookup_values flv
			where 1=1
			AND flv.lookup_type                		= 	'CIRRUS_AVDGED_REC_ACCT_EXCLUDE'
			AND flv.language                   		= 	'US'
			AND flv.enabled_flag               		= 	'Y'
		    AND LOOKUP_CODE = cc.segment2
							)
                           AND NOT EXISTS 
			(SELECT 1 FROM Acc_Exclude
            WHERE segment1=CCM.target_company_code
            AND segment2=cc.segment2)
			              AND NOT EXISTS 
			(SELECT 1 FROM Acc_Exclude2
            WHERE segment2=cc.segment2
            AND segment3=cc.segment3)
						/*	AND NOT EXISTS 
			(SELECT 1 FROM Acc_Exclude)*/
			--AND (cc.segment2 NOT IN ('2012505000','4110302000') AND cc.segment1 IN ('V926'))
			--AND DECODE(cc.segment1,'V926',DECODE(cc.segment2,'2012505000','2','4110302000','2','1'),'1') ='1'
			--AND DECODE(SUBSTR(cc.segment1,1,2),'DA',DECODE(cc.segment2,'3720102000','2','1'),'1') ='1'
			--AND (cc.segment2 NOT IN ('3720102000') AND cc.segment3 NOT LIKE 'DA%')
			/*AND NOT EXISTS 
			(
			SELECT 1 FROM GL_CODE_COMBINATIONS gc
			WHERE gc.code_combination_id = cc.code_combination_id
			AND   gc.segment2 = cc.segment2
			AND   gc.segment1 = cc.segment1
			AND gc.segment2 = '3720102000'
			AND gc.segment1 LIKE 'DA%'
			)*/
			--AND (cc.segment8 NOT IN ('000000') AND cc.segment1 NOT IN ('V895'))							
	) JE