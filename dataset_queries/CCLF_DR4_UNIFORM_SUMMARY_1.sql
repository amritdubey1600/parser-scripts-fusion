SELECT  'CCLFGL' key,
        SUM(Records_cr),
                                SUM(record_dr),
                                SUM(Reporting_cr_total),
                                SUM(reporting_dr_total)
FROM(SELECT COUNT(1)  Records_cr ,  0 record_dr,  0 Reporting_cr_total , 0 reporting_dr_total
             FROM  gl_je_headers        gjh,
          gl_je_lines          gjl,
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
     AND  ((fvv.attribute5 = 'USD' AND led.name LIKE '%FCY') OR  
           (fvv.attribute5 <> 'USD' AND led.name LIKE '%PRM')) 
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
               and  nvl(accounted_cr,0) <>0
   /*  AND  gjh.posted_date >= 
           NVL((
           SELECT MAX(ERH.processstart)
           FROM   ess_request_history ERH
           WHERE  ERH.definition = 'JobDefinition://oracle/apps/ess/custom/cclf/CCLF_CA_DR4_ENERGY'
           AND    ERH.requestid <> 53735
           AND    ERH.executable_status = 'SUCCEEDED'
                                                ) ,gjh.posted_date) */
     AND  (NVL(entered_dr,0) - NVL(entered_cr,0) <> 0 OR NVL(accounted_dr,0) - NVL(accounted_cr,0) <>0)
     AND  segment1 IN('UC09', 'UC02') ----, 'UC06', 'UC05', 'UC03', 'UC04', 'UC01', 'UC01','UAD1', 'UTCA')
                 /*  AND   EXISTS  ( SELECT 'Y'  
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
                                                                  and b1.FLEX_VALUE = glc.segment1 ) */
UNION
SELECT COUNT(1)  Records_cr, 0 records_dr,  sum(NVL(accounted_dr,0) - NVL(accounted_cr,0)) Reporting_cr_total  , 0  Reporting_dr_Total 
                 FROM  gl_je_headers        gjh,
          gl_je_lines                      gjl,
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
                and  nvl(accounted_cr,0) <>0
   /*  AND  gjh.posted_date >= 
           NVL((
           SELECT MAX(ERH.processstart)
           FROM   ess_request_history ERH
           WHERE  ERH.definition = 'JobDefinition://oracle/apps/ess/custom/cclf/CCLF_CA_DR4_ENERGY'
           AND    ERH.requestid <> 53735
           AND    ERH.executable_status = 'SUCCEEDED'
                                                ) ,gjh.posted_date) 
                                                                                                                                                                                                */
     AND  (NVL(entered_dr,0) - NVL(entered_cr,0) <> 0 OR NVL(accounted_dr,0) - NVL(accounted_cr,0) <>0)
     AND  segment1 IN('UC09', 'UC02') ----, 'UC06', 'UC05', 'UC03', 'UC04', 'UC01', 'UC01','UAD1', 'UTCA')          
               /*    AND   EXISTS  ( SELECT 'Y'  
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
                                                                  and b1.FLEX_VALUE = glc.segment1 ) */
UNION
SELECT COUNT(1)  Records_dr ,  0 record_cr,    0 reporting_cr_total , 0 Reporting_dr_total 
    FROM  gl_je_headers        gjh,
          gl_je_lines          gjl,
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
     AND  ((fvv.attribute5 = 'USD' AND led.name LIKE '%FCY') OR  
           (fvv.attribute5 <> 'USD' AND led.name LIKE '%PRM')) 
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
               and  nvl(accounted_dr,0) <>0
			  -- and accounted_cr<0
     /* AND  gjh.posted_date >= 
           NVL((
           SELECT MAX(ERH.processstart)
           FROM   ess_request_history ERH
           WHERE  ERH.definition = 'JobDefinition://oracle/apps/ess/custom/cclf/CCLF_CA_DR4_ENERGY'
           AND    ERH.requestid <> 53735
           AND    ERH.executable_status = 'SUCCEEDED'
                                                ) ,gjh.posted_date) */
     AND  (NVL(entered_dr,0) - NVL(entered_cr,0) <> 0 OR NVL(accounted_dr,0) - NVL(accounted_cr,0) <>0)
     AND  segment1 IN('UC09', 'UC02') ---, 'UC06', 'UC05', 'UC03', 'UC04', 'UC01', 'UC01','UAD1', 'UTCA')
               /*    AND   EXISTS  ( SELECT 'Y'  
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
                                                                  and b1.FLEX_VALUE = glc.segment1 ) */             
UNION
SELECT COUNT(1)  Records_dr, 0 records_cr,  0  Reporting_cr_Total  , SUM(NVL(accounted_dr,0) - NVL(accounted_cr,0)) Reporting_dr_total  
                 FROM  gl_je_headers        gjh,
          gl_je_lines                      gjl,
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
                and  nvl(accounted_dr,0) <>0
			  -- and accounted_dr>0
  /*   AND  gjh.posted_date >= 
           NVL((
           SELECT MAX(ERH.processstart)
           FROM   ess_request_history ERH
           WHERE  ERH.definition = 'JobDefinition://oracle/apps/ess/custom/cclf/CCLF_CA_DR4_ENERGY'
           AND    ERH.requestid <> 53735
           AND    ERH.executable_status = 'SUCCEEDED'
                                                ) ,gjh.posted_date) 
                                                                                                                                                                                                */
     AND  (NVL(entered_dr,0) - NVL(entered_cr,0) <> 0 OR NVL(accounted_dr,0) - NVL(accounted_cr,0) <>0)
     AND  segment1 IN('UC09', 'UC02')  ----, 'UC06', 'UC05', 'UC03', 'UC04', 'UC01', 'UC01','UAD1', 'UTCA')          
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
)