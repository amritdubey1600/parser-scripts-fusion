--#------------------------------------------------------------------------------------------------------------------------#
--# MODIFICATION HISTORY:
--# CR#                       Author             Date                Description
--#------------------------------------------------------------------------------------------------------------------------#
--# REL-52                  Nuri Chetia       19-MAY-2021        GERITM22222396 added PWDR4 to get eligible company code --#
--#------------------------------------------------------------------------------------------------------------------------#
WITH 
CCLF_DR4_UNIFORM AS
(
SELECT
sender_id||','||data_type||','||period_name||','||company_code||','||account||','||trading_partner||','||cost_center||','||geography||','||project_code||','||reference_code||','||product_line||','||book_type||','||future1||','||future2||','||
original_currency_code||','||entered_amount||','||functional_currency||','||accounted_amount||','||effective_date||','||posted_date||','||user_je_source_name||','||user_je_category_name||','||
je_batch_name||','||je_batch_description||','||je_header_name||','||je_header_description||','||je_line_description||','||stat_currency_conv_date||','||placeholder1||','||placeholder2||','||
created_by||','||accrual_rev_status||','||accrual_rev_period_name||','||reversal_flag||','||ledger_short_name||','||ccl_journal_id||','||ccl_je_line_num||','||Reversed_Journal_ID||','||context||','||
attribute1||','||attribute2||','||attribute3||','||attribute4||','||attribute5||','||attribute6||','||attribute7||','||attribute8||','||
attribute9||','||attribute10||','||attribute11||','||attribute12||','||attribute13||','||attribute14||','||attribute15||','||attribute16||','||attribute17||','||attribute18||','||
attribute19||','||attribute20  DR4_UNIFORM
FROM
(SELECT   'CCLFGL'          sender_id,
          'CCLJEEXIES'      data_type,
          gjh.period_name   period_name, 
          segment1          company_code,
          segment2          account,
          segment3          trading_partner,
          segment4          cost_center,
          segment5          geography,
          segment6          project_code,
          segment7          reference_code,
          segment8          product_line,
          segment9  	    book_type,
          Segment10         future1,
          Segment11         future2,
--          gjl.currency_code original_currency_code,
          fvv.attribute5    original_currency_code,
--          TO_CHAR(NVL(entered_dr,0) - NVL(entered_cr,0)) entered_amount,
          TO_CHAR(NVL(accounted_dr,0) - NVL(accounted_cr,0)) entered_amount,
--          led.currency_code functional_currency,
          'USD' functional_currency,
--          TO_CHAR(NVL(accounted_dr,0) - NVL(accounted_cr,0)) accounted_amount,
          '0'                accounted_amount,
          TO_CHAR(gjl.effective_date,'YYYYMMDD') effective_date,
          TO_CHAR(gjh.posted_date,'YYYYMMDD') posted_date,
          gjs.user_je_source_name user_je_source_name,
          gjc.user_je_category_name user_je_category_name,
          REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(gjb.name,',',';'), CHR(13), ' '), CHR(10), ' '),CHR(9), ' '),CHR(160),' ') je_batch_name,
          REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(gjb.description,',',';'), CHR(13), ' '), CHR(10), ' '),CHR(9), ' '),CHR(160),' ') je_batch_description,
          REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(gjh.name,',',';'), CHR(13), ' '), CHR(10), ' '),CHR(9), ' '),CHR(160),' ') je_header_name,
          REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(gjh.description,',',';'), CHR(13), ' '), CHR(10), ' '),CHR(9), ' '),CHR(160),' ') je_header_description,
          REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(gjl.description,',',';'), CHR(13), ' '), CHR(10), ' '),CHR(9), ' '),CHR(160),' ') je_line_description,
	  TO_CHAR(gjh.currency_conversion_date ,'YYYYMMDD') stat_currency_conv_date,
	  NULL placeholder1,
	  NULL placeholder2, 
          gjh.accrual_rev_status accrual_rev_status,
          gjh.accrual_rev_period_name accrual_rev_period_name,
          DECODE(gjh.reversed_je_header_id,NULL,NULL,'Y') reversal_flag,
          NULL context, 
          led.name ledger_short_name,
          TO_CHAR(gjh.je_header_id) ccl_journal_id,
          TO_CHAR(gjl.je_line_num) ccl_je_line_num, 
          gjl.attribute1, gjl.attribute2,
          gjl.attribute3, gjl.attribute4,
          gjl.attribute5, gjl.attribute6,
          gjl.attribute7, gjl.attribute8,
          gjl.attribute9, gjl.attribute10,
          gjl.attribute11, gjl.attribute12,
          gjl.attribute13, gjl.attribute14,
          gjl.attribute15, gjl.attribute16,
          gjl.attribute17, gjl.attribute18,
          gjl.attribute19, gjl.attribute20,gjl.created_by,
          NULL Reversed_Journal_ID
    FROM  gl_je_headers        gjh,
          gl_je_lines 	       gjl,
          gl_je_sources        gjs,
          gl_je_categories     gjc,
          gl_je_batches        gjb,
          gl_code_combinations glc,
          gl_ledgers           led  ,
          fnd_flex_value_sets  fvs,
          fnd_flex_values      fvv,
          fnd_flex_value_sets  fvs_acc,
          fnd_flex_values      fvv_acc
    WHERE gjh.je_header_id             = gjl.je_header_id
     AND  fvv.flex_value_set_id        = fvs.flex_value_set_id
     AND  fvs.flex_value_set_name      = 'CCL_COMPANY_CODES'  
     AND  fvv.flex_value               = glc.segment1
     AND  fvv_acc.flex_value_set_id    = fvs_acc.flex_value_set_id
     AND  fvs_acc.flex_value_set_name  = 'CCL_ACCOUNTS'
	 --- Added NVL REL-006 26-Jul-2017 Migration Month Close Critical Only
     AND (
	      (
		    NVL(fvv.attribute5,'X') = 'USD' AND (led.name LIKE '%FCY' OR led.name = 'US_USD_PRM')			
		  )		   
		  OR  
          ( NVL(fvv.attribute5,'X') <> 'USD' AND led.name LIKE '%PRM' )
         )
     AND  glc.segment2                 = fvv_acc.flex_value	  
     AND  gjh.je_source                = gjs.je_source_name
     AND  gjh.je_category              = gjc.je_category_name
     AND  gjb.je_batch_id              = gjh.je_batch_id
     AND  gjl.code_combination_id      = glc.code_combination_id
     AND  gjl.period_name              = NVL(:P_PERIOD,gjl.period_name)
     AND  gjl.period_name NOT LIKE 'ADJ%'
	 --AND  fvv.flex_value    = 'YWNO'
      and gjc.user_je_category_name not like '%Topside%'
     AND  gjh.ledger_id                = led.ledger_id
     AND  gjh.status                   = 'P'
	 AND  led.name not like '%STA%'
   AND  gjh.posted_date >= 
           NVL((
           SELECT MAX(ERH.processstart)
           FROM   ess_request_history ERH
           WHERE  ERH.definition = 'JobDefinition://oracle/apps/ess/custom/cclf/CCLF_CA_DR4_ENERGY'
           AND    ERH.requestid <> 53735
           AND    ERH.executable_status = 'SUCCEEDED'
			) ,gjh.posted_date)
      --Added below date condition REL-011 13-DEC-2017 Migration Month Close Critical Only
     -- REL-011 added below code
      AND  gjh.posted_date < 
           NVL((
           SELECT MAX(ERH.processstart)
           FROM   ess_request_history ERH
           WHERE  ERH.definition = 'JobDefinition://oracle/apps/ess/custom/cclf/CCLF_CA_DR4_ENERGY'
           AND    ERH.state = 3
			) ,gjh.posted_date)	
--REL-011 added above code
     AND  (NVL(entered_dr,0) - NVL(entered_cr,0) <> 0 OR NVL(accounted_dr,0) - NVL(accounted_cr,0) <>0)
     --AND  segment1 IN('UC09', 'UC02', 'UC06', 'UC05', 'UC03', 'UC04', 'UC01', 'UC01','UAD1', 'UTCA')
--REL 052 GERITM22222396 Commented below
/*	 
  AND   EXISTS  ( SELECT 'Y'  
                FROM fnd_flex_value_sets a1,
                     fnd_flex_values b1,
		             fnd_flex_values_tl c1
                WHERE a1.flex_value_set_id=b1.flex_value_set_id
                --  AND a1.flex_value_set_name='CCLF_DR4_ENERGY_GLOBAL_EXTRACT' 
				  AND a1.FLEX_VALUE_SET_ID = 51721 -- CCLF_DR4_ENERGY_GLOBAL_EXTRACT
  		          AND b1.value_category = 'CCLF_DR4_ENERGY_GLOBAL_EXTRACT'
                  and b1.flex_value_id =c1.flex_value_id
                  and c1.language = userenv('LANG')
 		          and b1.ENABLED_FLAG = 'Y'
				  and b1.FLEX_VALUE = glc.segment1 )
*/
--REL 052 GERITM22222396 commented above
--REL 052 GERITM22222396 added below
AND   EXISTS  ( SELECT /*+ PARALLEL_INDEX */  'X'
                       FROM   fnd_tree_node ftn
                             ,fnd_tree_version_vl ftv
                       WHERE 1=1
                       AND ftn.tree_Code           = 'COMPANY UNPUBLISHED'
                       AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
                       AND ftv.tree_Code           = ftn.tree_code
                       AND ftv.tree_structure_code = ftn.tree_structure_code
                       AND ftv.tree_version_name   = 'CURRENT'
                       AND ftn.tree_version_id     = ftv.tree_version_id               
                       AND parent_pk1_value        = 'PWDR4'  
                       AND pk1_start_value         = glc.segment1 ) 
--REL 052 GERITM22222396 added above
UNION ALL
SELECT   'CCLFGL'          sender_id,
          'CCLJEEXIES'      data_type,
          gjh.period_name   period_name, 
          segment1          company_code,
          segment2          account,
          segment3          trading_partner,
          segment4          cost_center,
          segment5          geography,
          segment6          project_code,
          segment7          reference_code,
          segment8          product_line,
          segment9  	    book_type,
          Segment10         future1,
          Segment11         future2,
--          gjl.currency_code original_currency_code,
          fvv.attribute5    original_currency_code,
--          TO_CHAR(NVL(entered_dr,0) - NVL(entered_cr,0)) entered_amount,
          '0' entered_amount,
          led.currency_code functional_currency,
          TO_CHAR(NVL(accounted_dr,0) - NVL(accounted_cr,0)) accounted_amount,
          TO_CHAR(gjl.effective_date,'YYYYMMDD') effective_date,
          TO_CHAR(gjh.posted_date,'YYYYMMDD') posted_date,
          gjs.user_je_source_name user_je_source_name,
          gjc.user_je_category_name user_je_category_name,
          REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(gjb.name,',',';'), CHR(13), ' '), CHR(10), ' '),CHR(9), ' '),CHR(160),' ') je_batch_name,
          REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(gjb.description,',',';'), CHR(13), ' '), CHR(10), ' '),CHR(9), ' '),CHR(160),' ') je_batch_description,
          REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(gjh.name,',',';'), CHR(13), ' '), CHR(10), ' '),CHR(9), ' '),CHR(160),' ') je_header_name,
          REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(gjh.description,',',';'), CHR(13), ' '), CHR(10), ' '),CHR(9), ' '),CHR(160),' ') je_header_description,
          REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(gjl.description,',',';'), CHR(13), ' '), CHR(10), ' '),CHR(9), ' '),CHR(160),' ') je_line_description,
	  TO_CHAR(gjh.currency_conversion_date ,'YYYYMMDD') stat_currency_conv_date,
	  NULL placeholder1,
	  NULL placeholder2, 
          gjh.accrual_rev_status accrual_rev_status,
          gjh.accrual_rev_period_name accrual_rev_period_name,
          DECODE(gjh.reversed_je_header_id,NULL,NULL,'Y') reversal_flag,
          NULL context, 
          led.name ledger_short_name,
          TO_CHAR(gjh.je_header_id) ccl_journal_id,
          TO_CHAR(gjl.je_line_num) ccl_je_line_num, 
          gjl.attribute1, gjl.attribute2,
          gjl.attribute3, gjl.attribute4,
          gjl.attribute5, gjl.attribute6,
          gjl.attribute7, gjl.attribute8,
          gjl.attribute9, gjl.attribute10,
          gjl.attribute11, gjl.attribute12,
          gjl.attribute13, gjl.attribute14,
          gjl.attribute15, gjl.attribute16,
          gjl.attribute17, gjl.attribute18,
          gjl.attribute19, gjl.attribute20,gjl.created_by,
          NULL Reversed_Journal_ID
    FROM  gl_je_headers        gjh,
          gl_je_lines 	       gjl,
          gl_je_sources        gjs,
          gl_je_categories     gjc,
          gl_je_batches        gjb,
          gl_code_combinations glc,
          gl_ledgers           led  ,
          fnd_flex_value_sets  fvs,
          fnd_flex_values      fvv,
          fnd_flex_value_sets  fvs_acc,
          fnd_flex_values      fvv_acc
    WHERE gjh.je_header_id             = gjl.je_header_id
     AND  fvv.flex_value_set_id        = fvs.flex_value_set_id
     AND  fvs.flex_value_set_name      = 'CCL_COMPANY_CODES'  
     AND  fvv.flex_value               = glc.segment1
     AND  fvv_acc.flex_value_set_id    = fvs_acc.flex_value_set_id
     AND  fvs_acc.flex_value_set_name  = 'CCL_ACCOUNTS'
     AND  led.name                     like '%USD_RPT'
	--  AND  fvv.flex_value    = 'YWNO'
     --AND  gjl.currency_code            = 'USD'
     AND  glc.segment2                 = fvv_acc.flex_value	  
     AND  gjh.je_source                = gjs.je_source_name
     AND  gjh.je_category              = gjc.je_category_name
     AND  gjb.je_batch_id              = gjh.je_batch_id
     AND  gjl.period_name              = NVL(:P_PERIOD,gjl.period_name)     
     AND  gjl.period_name NOT LIKE 'ADJ%'
    and gjc.user_je_category_name not like '%Topside%'
     AND  gjl.code_combination_id      = glc.code_combination_id
     AND  gjh.ledger_id                = led.ledger_id
     AND  gjh.status                   = 'P'
     AND  gjh.posted_date >= 
           NVL((
           SELECT MAX(ERH.processstart)
           FROM   ess_request_history ERH
           WHERE  ERH.definition = 'JobDefinition://oracle/apps/ess/custom/cclf/CCLF_CA_DR4_ENERGY'
           AND    ERH.requestid <> 53735
           AND    ERH.executable_status = 'SUCCEEDED'
			) ,gjh.posted_date) 
--Added below date condition REL-011 13-DEC-2017 Migration Month Close Critical Only
--REL-011 added below code     
AND  gjh.posted_date < 
           NVL((
           SELECT MAX(ERH.processstart)
           FROM   ess_request_history ERH
           WHERE  ERH.definition = 'JobDefinition://oracle/apps/ess/custom/cclf/CCLF_CA_DR4_ENERGY'
           AND    ERH.state = 3
			) ,gjh.posted_date)
    --REL-011 added above code
     AND  (NVL(entered_dr,0) - NVL(entered_cr,0) <> 0 OR NVL(accounted_dr,0) - NVL(accounted_cr,0) <>0)
  --   AND  segment1 IN('UC09', 'UC02', 'UC06', 'UC05', 'UC03', 'UC04', 'UC01', 'UC01','UAD1', 'UTCA')	 
--REL 052 GERITM22222396 commented below
/*
	   AND   EXISTS  ( SELECT 'Y'  
                FROM fnd_flex_value_sets a1,
                     fnd_flex_values b1,
		             fnd_flex_values_tl c1
                WHERE a1.flex_value_set_id=b1.flex_value_set_id
                --  AND a1.flex_value_set_name='CCLF_DR4_ENERGY_GLOBAL_EXTRACT' 
				  AND a1.FLEX_VALUE_SET_ID = 51721 -- CCLF_DR4_ENERGY_GLOBAL_EXTRACT
  		          AND b1.value_category = 'CCLF_DR4_ENERGY_GLOBAL_EXTRACT'
                  and b1.flex_value_id =c1.flex_value_id
                  and c1.language = userenv('LANG')
 		          and b1.ENABLED_FLAG = 'Y'
				  and b1.FLEX_VALUE = glc.segment1 )
*/
--REL 052 GERITM22222396 commented above
--REL 052 GERITM22222396 added below
  AND   EXISTS  ( SELECT /*+ PARALLEL_INDEX */  'X'
                       FROM   fnd_tree_node ftn
                             ,fnd_tree_version_vl ftv
                       WHERE 1=1
                       AND ftn.tree_Code           = 'COMPANY UNPUBLISHED'
                       AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
                       AND ftv.tree_Code           = ftn.tree_code
                       AND ftv.tree_structure_code = ftn.tree_structure_code
                       AND ftv.tree_version_name   = 'CURRENT'
                       AND ftn.tree_version_id     = ftv.tree_version_id               
                       AND parent_pk1_value        = 'PWDR4'  
                       AND pk1_start_value         = glc.segment1 ) 
--REL 052 GERITM22222396 added above
	 ))
SELECT 'CCLFGL' key,CCLF_DR4_UNIFORM.DR4_UNIFORM DR4_UNIFORM
FROM CCLF_DR4_UNIFORM
UNION
SELECT 'CCLFGL' key,'CCLFGL,CCLJEEXIES,'||TO_CHAR(SYSDATE,'YYYYMMDD')||',TRAILER,'||TO_CHAR(COUNT(*)) ||',P' DR4_UNIFORM FROM CCLF_DR4_UNIFORM
ORDER BY 2 desc