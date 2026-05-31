/******************************************************************************
    NAME:       CCLF CA DR4 Uniform Summary Report
	PURPOSE:

	REVISIONS:
	Ver     Date        Author        Description
	------  ----------  ------------  ------------------------------------
	1.0     06.06.2019  502766680     REL-029 GERITM3733839-> Added ledger name 'US_USD_PRM' to get correct Period
******************************************************************************/


SELECT 'CCLFGL' KEY,        
       Sum(record_dr), 
	   Sum(record_cr), 
       Sum(Entered_dr_total), 
       Sum(Entered_cr_total),
	   Sum(Accounted_dr_total), 
       Sum(Accounted_cr_total)	   
FROM   (SELECT 
               Count(1)                record_dr, 
			   0                       record_cr, 
			   Sum(NVL(accounted_dr,0) - NVL(accounted_cr,0)) Entered_dr_total,
			   0                       Entered_cr_total,
			   --0                       Accounted_dr_total -- Commented Mehul 08/28/17
               SUM (CASE WHEN led.NAME LIKE '%USD_FCY' AND NVL(fvv.attribute5,'X') = 'USD' THEN (NVL(accounted_dr,0) - NVL(accounted_cr,0)) ELSE 0 END ) Accounted_dr_total,  ----MEHUL 08/28/2017
			   0                       Accounted_cr_total
        FROM   gl_je_headers gjh, 
               gl_je_lines gjl, 
               gl_je_sources gjs, 
               gl_je_categories gjc, 
               gl_je_batches gjb, 
               gl_code_combinations glc, 
               gl_ledgers led, 
               fnd_flex_value_sets fvs, 
               fnd_flex_values fvv, 
               fnd_flex_value_sets fvs_acc, 
               fnd_flex_values fvv_acc 
        WHERE  gjh.je_header_id = gjl.je_header_id 
               AND fvv.flex_value_set_id = fvs.flex_value_set_id 
               AND fvs.flex_value_set_name = 'CCL_COMPANY_CODES' 
               AND fvv.flex_value = glc.segment1 
               AND fvv_acc.flex_value_set_id = fvs_acc.flex_value_set_id 
               AND fvs_acc.flex_value_set_name = 'CCL_ACCOUNTS' 
			   --- Added NVL REL-006 26-Jul-2017 Migration Month Close Critical Only
               AND ( ( NVL(fvv.attribute5,'X') = 'USD' AND led.NAME LIKE '%FCY' ) 
                      OR ( NVL(fvv.attribute5,'X') <> 'USD' AND led.NAME LIKE '%PRM' ) ) 
               AND glc.segment2 = fvv_acc.flex_value 
               AND gjh.je_source = gjs.je_source_name 
               AND gjh.je_category = gjc.je_category_name 
               AND gjb.je_batch_id = gjh.je_batch_id 
               AND gjl.code_combination_id = glc.code_combination_id 
               AND gjl.period_name = (SELECT DISTINCT REPLACE(latest_opened_period_name,'ADJ','DEC') 
                                      FROM   gl_ledgers 
                                      WHERE  1 = 1
											 --REL-029 GERITM3733839 Commented out --AND name NOT LIKE '%STA'
											--REL-029 GERITM3733839 Commented out --AND  name <>  'US_USD_ERP'
											AND name = 'US_USD_PRM'   --REL-029 GERITM3733839 Added
                                             AND latest_opened_period_name IS 
                                                 NOT NULL) 
               AND gjl.period_name NOT LIKE 'ADJ%' 
               --AND  fvv.flex_value    = 'YWNO'  
               AND gjc.user_je_category_name NOT LIKE '%Topside%' 
               AND gjh.ledger_id = led.ledger_id 
               AND gjh.status = 'P' 
               AND led.NAME NOT LIKE '%STA%' 
               AND NVL(accounted_dr,0) - NVL(accounted_cr,0) > 0 
               AND gjh.posted_date between (SELECT Max(ERH.processstart) 
                                           FROM   ess_request_history ERH 
                                           WHERE  ERH.definition = 
        'JobDefinition://oracle/apps/ess/custom/cclf/CCLF_CA_DR4_ENERGY' 
                AND ERH.requestid <> 53735 
                AND ERH.executable_status = 'SUCCEEDED'
				and ERH.processstart <> (SELECT Max(ERH.processstart) 
                                           FROM   ess_request_history ERH 
                                           WHERE  ERH.definition = 
        'JobDefinition://oracle/apps/ess/custom/cclf/CCLF_CA_DR4_ENERGY' 
                AND ERH.requestid <> 53735 
                AND ERH.executable_status = 'SUCCEEDED')) and (SELECT Max(ERH.processstart) 
                                           FROM   ess_request_history ERH 
                                           WHERE  ERH.definition = 
        'JobDefinition://oracle/apps/ess/custom/cclf/CCLF_CA_DR4_ENERGY' 
                AND ERH.requestid <> 53735 
                AND ERH.executable_status = 'SUCCEEDED')
               AND ( Nvl(entered_dr, 0) - Nvl(entered_cr, 0) <> 0 
                      OR Nvl(accounted_dr, 0) - Nvl(accounted_cr, 0) <> 0 ) 
               AND EXISTS (SELECT 'Y' 
                           FROM   fnd_flex_value_sets a1, 
                                  fnd_flex_values b1, 
                                  fnd_flex_values_tl c1 
                           WHERE  a1.flex_value_set_id = b1.flex_value_set_id 
                                  --  AND a1.flex_value_set_name='CCLF_DR4_ENERGY_GLOBAL_EXTRACT'   
                                  AND a1.flex_value_set_id = 51721 
                                  -- CCLF_DR4_ENERGY_GLOBAL_EXTRACT  
                                  AND b1.value_category = 
                                      'CCLF_DR4_ENERGY_GLOBAL_EXTRACT' 
                                  AND b1.flex_value_id = c1.flex_value_id 
                                  AND c1.language = Userenv('LANG') 
                                  AND b1.enabled_flag = 'Y' 
                                  AND b1.flex_value = glc.segment1) 
        UNION 
        SELECT Count(1)                record_dr, 
			   0                       record_cr, 
			   0                       Entered_dr_total,
			   0                       Entered_cr_total,
              -- Sum(NVL(accounted_dr,0) - NVL(accounted_cr,0)) Accounted_dr_total,  -- Commented Mehul 08/28/2017
			   SUM (CASE WHEN led.NAME LIKE '%USD_RPT' AND NVL(fvv.attribute5,'X') = 'USD' THEN 0 ELSE (NVL(accounted_dr,0) - NVL(accounted_cr,0)) END ) Accounted_dr_total,  ----MEHUL 08/28/2017
			   0                       Accounted_cr_total  
        FROM   gl_je_headers gjh, 
               gl_je_lines gjl, 
               gl_je_sources gjs, 
               gl_je_categories gjc, 
               gl_je_batches gjb, 
               gl_code_combinations glc, 
               gl_ledgers led, 
               fnd_flex_value_sets fvs, 
               fnd_flex_values fvv, 
               fnd_flex_value_sets fvs_acc, 
               fnd_flex_values fvv_acc 
        WHERE  gjh.je_header_id = gjl.je_header_id 
               AND fvv.flex_value_set_id = fvs.flex_value_set_id 
               AND fvs.flex_value_set_name = 'CCL_COMPANY_CODES' 
               AND fvv.flex_value = glc.segment1 
               AND fvv_acc.flex_value_set_id = fvs_acc.flex_value_set_id 
               AND fvs_acc.flex_value_set_name = 'CCL_ACCOUNTS' 
               AND led.NAME LIKE '%USD_RPT' 
               AND glc.segment2 = fvv_acc.flex_value 
               AND gjh.je_source = gjs.je_source_name 
               AND gjh.je_category = gjc.je_category_name 
               AND gjb.je_batch_id = gjh.je_batch_id 
               AND gjl.period_name = (SELECT DISTINCT REPLACE(latest_opened_period_name,'ADJ','DEC') 
                                      FROM   gl_ledgers 
                                      WHERE  1 = 1
											--REL-029 GERITM3733839 Commented out --AND name NOT LIKE '%STA'
											--REL-029 GERITM3733839 Commented out --AND  name <>  'US_USD_ERP'
											AND name = 'US_USD_PRM'   --REL-029 GERITM3733839 Added
                                             AND latest_opened_period_name IS 
                                                 NOT NULL) 
               AND gjl.period_name NOT LIKE 'ADJ%' 
               AND gjc.user_je_category_name NOT LIKE '%Topside%' 
               AND gjl.code_combination_id = glc.code_combination_id 
               AND gjh.ledger_id = led.ledger_id 
               AND gjh.status = 'P' 
               AND NVL(accounted_dr,0) - NVL(accounted_cr,0) > 0 
               AND gjh.posted_date between (SELECT Max(ERH.processstart) 
                                           FROM   ess_request_history ERH 
                                           WHERE  ERH.definition = 
        'JobDefinition://oracle/apps/ess/custom/cclf/CCLF_CA_DR4_ENERGY' 
                AND ERH.requestid <> 53735 
                AND ERH.executable_status = 'SUCCEEDED'
				and ERH.processstart <> (SELECT Max(ERH.processstart) 
                                           FROM   ess_request_history ERH 
                                           WHERE  ERH.definition = 
        'JobDefinition://oracle/apps/ess/custom/cclf/CCLF_CA_DR4_ENERGY' 
                AND ERH.requestid <> 53735 
                AND ERH.executable_status = 'SUCCEEDED')) and (SELECT Max(ERH.processstart) 
                                           FROM   ess_request_history ERH 
                                           WHERE  ERH.definition = 
        'JobDefinition://oracle/apps/ess/custom/cclf/CCLF_CA_DR4_ENERGY' 
                AND ERH.requestid <> 53735 
                AND ERH.executable_status = 'SUCCEEDED')
               AND ( Nvl(entered_dr, 0) - Nvl(entered_cr, 0) <> 0 
                      OR Nvl(accounted_dr, 0) - Nvl(accounted_cr, 0) <> 0 ) 
               AND EXISTS (SELECT 'Y' 
                           FROM   fnd_flex_value_sets a1, 
                                  fnd_flex_values b1, 
                                  fnd_flex_values_tl c1 
                           WHERE  a1.flex_value_set_id = b1.flex_value_set_id 
                                  --  AND a1.flex_value_set_name='CCLF_DR4_ENERGY_GLOBAL_EXTRACT'   
                                  AND a1.flex_value_set_id = 51721 
                                  -- CCLF_DR4_ENERGY_GLOBAL_EXTRACT  
                                  AND b1.value_category = 
                                      'CCLF_DR4_ENERGY_GLOBAL_EXTRACT' 
                                  AND b1.flex_value_id = c1.flex_value_id 
                                  AND c1.language = Userenv('LANG') 
                                  AND b1.enabled_flag = 'Y' 
                                  AND b1.flex_value = glc.segment1)
	UNION
        SELECT 0                       record_dr, 
			   Count(1)                record_cr, 
			   0                       Entered_dr_total,
			   Sum(NVL(accounted_dr,0) - NVL(accounted_cr,0))  Entered_cr_total,
               0                       Accounted_dr_total,
			   --0                       Accounted_cr_total -- Commented Mehul 08/28/17
			   SUM (CASE WHEN led.NAME LIKE '%USD_FCY' AND NVL(fvv.attribute5,'X') = 'USD' THEN (NVL(accounted_dr,0) - NVL(accounted_cr,0)) ELSE 0 END ) Accounted_cr_total   --- MEHUL 08/28/2017
        FROM   gl_je_headers gjh, 
               gl_je_lines gjl, 
               gl_je_sources gjs, 
               gl_je_categories gjc, 
               gl_je_batches gjb, 
               gl_code_combinations glc, 
               gl_ledgers led, 
               fnd_flex_value_sets fvs, 
               fnd_flex_values fvv, 
               fnd_flex_value_sets fvs_acc, 
               fnd_flex_values fvv_acc 
        WHERE  gjh.je_header_id = gjl.je_header_id 
               AND fvv.flex_value_set_id = fvs.flex_value_set_id 
               AND fvs.flex_value_set_name = 'CCL_COMPANY_CODES' 
               AND fvv.flex_value = glc.segment1 
               AND fvv_acc.flex_value_set_id = fvs_acc.flex_value_set_id 
               AND fvs_acc.flex_value_set_name = 'CCL_ACCOUNTS' 
			   --- Added NVL REL-006 26-Jul-2017 Migration Month Close Critical Only
               AND ( ( NVL(fvv.attribute5,'X') = 'USD' AND led.NAME LIKE '%FCY' ) 
                      OR ( NVL(fvv.attribute5,'X') <> 'USD' AND led.NAME LIKE '%PRM' ) ) 
               AND glc.segment2 = fvv_acc.flex_value 
               AND gjh.je_source = gjs.je_source_name 
               AND gjh.je_category = gjc.je_category_name 
               AND gjb.je_batch_id = gjh.je_batch_id 
               AND gjl.code_combination_id = glc.code_combination_id 
               AND gjl.period_name = (SELECT DISTINCT REPLACE(latest_opened_period_name,'ADJ','DEC') 
                                      FROM   gl_ledgers 
                                      WHERE  1 = 1
											 --REL-029 GERITM3733839 Commented out --AND name NOT LIKE '%STA'
											--REL-029 GERITM3733839 Commented out --AND  name <>  'US_USD_ERP'
											AND name = 'US_USD_PRM'   --REL-029 GERITM3733839 Added
                                             AND latest_opened_period_name IS 
                                                 NOT NULL) 
               AND gjl.period_name NOT LIKE 'ADJ%' 
               --AND  fvv.flex_value    = 'YWNO'  
               AND gjc.user_je_category_name NOT LIKE '%Topside%' 
               AND gjh.ledger_id = led.ledger_id 
               AND gjh.status = 'P' 
               AND led.NAME NOT LIKE '%STA%' 
               AND NVL(accounted_dr,0) - NVL(accounted_cr,0) < 0 
               AND gjh.posted_date between (SELECT Max(ERH.processstart) 
                                           FROM   ess_request_history ERH 
                                           WHERE  ERH.definition = 
        'JobDefinition://oracle/apps/ess/custom/cclf/CCLF_CA_DR4_ENERGY' 
                AND ERH.requestid <> 53735 
                AND ERH.executable_status = 'SUCCEEDED'
				and ERH.processstart <> (SELECT Max(ERH.processstart) 
                                           FROM   ess_request_history ERH 
                                           WHERE  ERH.definition = 
        'JobDefinition://oracle/apps/ess/custom/cclf/CCLF_CA_DR4_ENERGY' 
                AND ERH.requestid <> 53735 
                AND ERH.executable_status = 'SUCCEEDED')) and (SELECT Max(ERH.processstart) 
                                           FROM   ess_request_history ERH 
                                           WHERE  ERH.definition = 
        'JobDefinition://oracle/apps/ess/custom/cclf/CCLF_CA_DR4_ENERGY' 
                AND ERH.requestid <> 53735 
                AND ERH.executable_status = 'SUCCEEDED')
               AND ( Nvl(entered_dr, 0) - Nvl(entered_cr, 0) <> 0 
                      OR Nvl(accounted_dr, 0) - Nvl(accounted_cr, 0) <> 0 ) 
               AND EXISTS (SELECT 'Y' 
                           FROM   fnd_flex_value_sets a1, 
                                  fnd_flex_values b1, 
                                  fnd_flex_values_tl c1 
                           WHERE  a1.flex_value_set_id = b1.flex_value_set_id 
                                  --  AND a1.flex_value_set_name='CCLF_DR4_ENERGY_GLOBAL_EXTRACT'   
                                  AND a1.flex_value_set_id = 51721 
                                  -- CCLF_DR4_ENERGY_GLOBAL_EXTRACT  
                                  AND b1.value_category = 
                                      'CCLF_DR4_ENERGY_GLOBAL_EXTRACT' 
                                  AND b1.flex_value_id = c1.flex_value_id 
                                  AND c1.language = Userenv('LANG') 
                                  AND b1.enabled_flag = 'Y' 
                                  AND b1.flex_value = glc.segment1) 
        UNION 
        SELECT 0                       record_dr, 
			   Count(1)                record_cr, 
			   0                       Entered_dr_total,
			   0                       Entered_cr_total,
               0                       Accounted_dr_total,
			  -- Sum(NVL(accounted_dr,0) - NVL(accounted_cr,0))  Accounted_cr_total  -- Mehul 8/28/17
			   SUM (CASE WHEN led.NAME LIKE '%USD_RPT' AND NVL(fvv.attribute5,'X') = 'USD' THEN 0 ELSE (NVL(accounted_dr,0) - NVL(accounted_cr,0)) END ) Accounted_cr_total   --- MEHUL 08/28/2017
        FROM   gl_je_headers gjh, 
               gl_je_lines gjl, 
               gl_je_sources gjs, 
               gl_je_categories gjc, 
               gl_je_batches gjb, 
               gl_code_combinations glc, 
               gl_ledgers led, 
               fnd_flex_value_sets fvs, 
               fnd_flex_values fvv, 
               fnd_flex_value_sets fvs_acc, 
               fnd_flex_values fvv_acc 
        WHERE  gjh.je_header_id = gjl.je_header_id 
               AND fvv.flex_value_set_id = fvs.flex_value_set_id 
               AND fvs.flex_value_set_name = 'CCL_COMPANY_CODES' 
               AND fvv.flex_value = glc.segment1 
               AND fvv_acc.flex_value_set_id = fvs_acc.flex_value_set_id 
               AND fvs_acc.flex_value_set_name = 'CCL_ACCOUNTS' 
               AND led.NAME LIKE '%USD_RPT' 
               AND glc.segment2 = fvv_acc.flex_value 
               AND gjh.je_source = gjs.je_source_name 
               AND gjh.je_category = gjc.je_category_name 
               AND gjb.je_batch_id = gjh.je_batch_id 
               AND gjl.period_name = (SELECT DISTINCT REPLACE(latest_opened_period_name,'ADJ','DEC') 
                                      FROM   gl_ledgers 
                                      WHERE  1 = 1
											 --REL-029 GERITM3733839 Commented out --AND name NOT LIKE '%STA'
											--REL-029 GERITM3733839 Commented out --AND  name <>  'US_USD_ERP'
											AND name = 'US_USD_PRM'   --REL-029 GERITM3733839 Added
                                             AND latest_opened_period_name IS 
                                                 NOT NULL) 
               AND gjl.period_name NOT LIKE 'ADJ%' 
               AND gjc.user_je_category_name NOT LIKE '%Topside%' 
               AND gjl.code_combination_id = glc.code_combination_id 
               AND gjh.ledger_id = led.ledger_id 
               AND gjh.status = 'P' 
               AND NVL(accounted_dr,0) - NVL(accounted_cr,0) < 0 
               AND gjh.posted_date between (SELECT Max(ERH.processstart) 
                                           FROM   ess_request_history ERH 
                                           WHERE  ERH.definition = 
        'JobDefinition://oracle/apps/ess/custom/cclf/CCLF_CA_DR4_ENERGY' 
                AND ERH.requestid <> 53735 
                AND ERH.executable_status = 'SUCCEEDED'
				and ERH.processstart <> (SELECT Max(ERH.processstart) 
                                           FROM   ess_request_history ERH 
                                           WHERE  ERH.definition = 
        'JobDefinition://oracle/apps/ess/custom/cclf/CCLF_CA_DR4_ENERGY' 
                AND ERH.requestid <> 53735 
                AND ERH.executable_status = 'SUCCEEDED')) and (SELECT Max(ERH.processstart) 
                                           FROM   ess_request_history ERH 
                                           WHERE  ERH.definition = 
        'JobDefinition://oracle/apps/ess/custom/cclf/CCLF_CA_DR4_ENERGY' 
                AND ERH.requestid <> 53735 
                AND ERH.executable_status = 'SUCCEEDED')
               AND ( Nvl(entered_dr, 0) - Nvl(entered_cr, 0) <> 0 
                      OR Nvl(accounted_dr, 0) - Nvl(accounted_cr, 0) <> 0 ) 
               AND EXISTS (SELECT 'Y' 
                           FROM   fnd_flex_value_sets a1, 
                                  fnd_flex_values b1, 
                                  fnd_flex_values_tl c1 
                           WHERE  a1.flex_value_set_id = b1.flex_value_set_id 
                                  --  AND a1.flex_value_set_name='CCLF_DR4_ENERGY_GLOBAL_EXTRACT'   
                                  AND a1.flex_value_set_id = 51721 
                                  -- CCLF_DR4_ENERGY_GLOBAL_EXTRACT  
                                  AND b1.value_category = 
                                      'CCLF_DR4_ENERGY_GLOBAL_EXTRACT' 
                                  AND b1.flex_value_id = c1.flex_value_id 
                                  AND c1.language = Userenv('LANG') 
                                  AND b1.enabled_flag = 'Y' 
                                  AND b1.flex_value = glc.segment1))