--# --------------------------------------------------------------------------------------------------------------#
--# DESCRIPTION     : Send file to GS server
--# CREATION DATE   : 22-MAR-2022
--#
--# MODIFICATION HISTORY:
--# CR#           Author              Date              Description
--# REL063    Nuri Chetia    22-MAR-22       GERITM29897336 changed filename format in bursting and modified parameter condition for better performance
--# REL076    Venkatesh Sarangam 15-MAY-23   REL076-STAT ledger selection logic change    
--# REL078    Abinay Baineni     30-JUN-23   REL078-Commented STAT ledger description logic    
--#-----------------------------------------------------------------------------------------------------------------------
WITH 
CCLFUS_STAT_HFM AS
(
SELECT sender_id||','||data_type||','||period_name||','||company_code||','||account||','||trading_partner||','||cost_center||','||geography||','||project_code||','||reference_code||','||
product_line||','||book_type||','||future1||','||future2||','||functional_currency_code||','||to_char(ytd_func_equivalent)||','||TO_CHAR(begin_func_equivalent)||','||TO_CHAR(ptd_func_equivalent)||','||
reporting_currency_code||','||TO_CHAR(NVL(rep_curr_ytd_balance,0))||','||TO_CHAR(NVL(rep_curr_begin_balance,0))||','||TO_CHAR(NVL(rep_curr_ptd_balance,0))||','||rep_ledg_short_name STATHFM
FROM (
SELECT  'CCLFST' sender_id,
        'CCLBALEXFCES' data_type, 
        glb.period_name ,glc.segment1 company_code,glc.segment2 account,glc.segment3 trading_partner,glc.segment4 cost_center,glc.segment5 geography,glc.segment6 project_code,glc.segment7 reference_code,
        glc.segment8 product_line,glc.segment9 book_type,glc.segment10 future1,glc.segment11 future2, 
        glb.currency_code functional_currency_code,
        'USD'  reporting_currency_code,
        (NVL(begin_balance_dr,0) - NVL(begin_balance_cr,0) + NVL(period_net_dr,0) - NVL(period_net_cr,0)) ytd_func_equivalent,
                                NVL(begin_balance_dr,0) - NVL(begin_balance_cr,0) begin_func_equivalent,
        NVL(period_net_dr,0) - NVL(period_net_cr,0) ptd_func_equivalent,
        /*NULL rep_curr_ytd_balance,
                                NULL rep_curr_begin_balance, 
                                NULL rep_curr_ptd_balance, */
(SELECT NVL(begin_balance_dr,0) - NVL(begin_balance_cr,0) + NVL(period_net_dr,0) - NVL(period_net_cr,0) 
FROM   gl_balances glb_rep,
       gl_ledgers  led_rep
WHERE led_rep.ledger_id               = glb_rep.ledger_id
  AND led_rep.ledger_category_code    = 'ALC' 
  AND led_rep.name like '%RPT'
  AND glb_rep.code_combination_id = glb.code_combination_id 
  AND glb_rep.currency_code       = led_rep.currency_code
  AND glb_rep.period_name         = glb.period_name 
  AND led_rep.currency_code       = 'USD') rep_curr_ytd_balance,
(SELECT NVL(period_net_dr,0) - NVL(period_net_cr,0) 
FROM   gl_balances glb_rep,
       gl_ledgers  led_rep
WHERE led_rep.ledger_id               = glb_rep.ledger_id
  AND led_rep.ledger_category_code    = 'ALC' 
  AND led_rep.name like '%RPT'
  AND glb_rep.code_combination_id = glb.code_combination_id 
  AND glb_rep.currency_code       = led_rep.currency_code
  AND glb_rep.period_name         = glb.period_name 
  AND led_rep.currency_code       = 'USD') rep_curr_ptd_balance,
  (SELECT NVL(begin_balance_dr,0) - NVL(begin_balance_cr,0)
FROM   gl_balances glb_rep,
       gl_ledgers  led_rep
WHERE led_rep.ledger_id               = glb_rep.ledger_id
  AND led_rep.ledger_category_code    = 'ALC' 
  AND led_rep.name like '%RPT'
  AND glb_rep.code_combination_id = glb.code_combination_id 
  AND glb_rep.currency_code       = led_rep.currency_code
  AND glb_rep.period_name         = glb.period_name 
  AND led_rep.currency_code       = 'USD') rep_curr_begin_balance          ,               
        led.ledger_id pri_ledg_id, led.short_name pri_ledg_short_name,
      /* (SELECT  led_rep.short_name
          FROM  gl_ledgers led_rep
         WHERE  led_rep.ledger_category_code = 'ALC'
                       AND upper(led_rep.description)   LIKE '%REPORTING%'
                                   AND upper(led_rep.name) like '%RPT'
                                   AND  rownum = 1) rep_ledg_short_name*/
		--  added by vijay						   
		 ( select  glp.short_name   from 
GL_LEDGER_RELATIONSHIPS A , gl_ledgers gl2 ,   GL_LEDGER_RELATIONSHIPS P,     gl_ledgers glp
where A.target_ledger_id in 
(select  ledger_id from gl_ledgers gl
where gl.Ledger_id      =led.ledger_id
and gl2.ledger_id = A.Primary_ledger_id
and gl2.name like '%PRM%'
and p.primary_ledger_id=gl2.ledger_id
and p.target_ledger_id= glp.ledger_id
and glp.name like '%RPT%'))	 rep_ledg_short_name 

FROM   gl_balances glb,
       gl_code_combinations glc,
       (SELECT a.flex_value COMPANY_CODE,a.attribute5 functional_currency
          FROM fnd_flex_values a, fnd_flex_value_sets b, fnd_flex_values_tl c
         WHERE a.flex_value_set_id = b.flex_value_set_id
           AND b.flex_value_set_name = 'CCL_COMPANY_CODES'
           AND a.flex_value_id       = c.flex_value_id
           AND c.language            = 'US') ccv,
       gl_ledgers  led
WHERE led.ledger_id = glb.ledger_id
AND led.ledger_category_code = 'SECONDARY' 
--AND led.name                 LIKE '%STA'
---AND led.name        = 'CA_CAD_STA'
-- Below logic added by Vijay

AND led.name     in (
select lookup_code from fnd_lookup_values flv
where  flv.language        ='US'
AND flv.ENABLED_FLAG    ='Y'
AND flv.lookup_type     ='CCL_GED_AVIATION_STAT_HFM'
and trunc(sysdate)  between   trunc( nvl( flv.start_date_active, sysdate) ) and trunc ( nvl( flv.end_date_active, sysdate))
)

-- Below logic added by Venkatesh--REL076
AND ( ((glc.segment1 in (
select lookup_code from fnd_lookup_values flv
where  flv.language        ='US'
AND flv.ENABLED_FLAG    ='Y'
AND flv.lookup_type     ='CCL_STATHFM_COCO_EXCLUDE'
and trunc(sysdate)  between   trunc( nvl( flv.start_date_active, sysdate) ) and trunc ( nvl( flv.end_date_active, sysdate))
)) AND (led.name  not   in (
select description from fnd_lookup_values flv
where  flv.language        ='US'
AND flv.ENABLED_FLAG    ='Y'
AND flv.lookup_type     ='CCL_STATHFM_COCO_EXCLUDE'
and trunc(sysdate)  between   trunc( nvl( flv.start_date_active, sysdate) ) and trunc ( nvl( flv.end_date_active, sysdate))
)))
OR
(glc.segment1 not in (
select lookup_code from fnd_lookup_values flv
where  flv.language        ='US'
AND flv.ENABLED_FLAG    ='Y'
AND flv.lookup_type     ='CCL_STATHFM_COCO_EXCLUDE'
and trunc(sysdate)  between   trunc( nvl( flv.start_date_active, sysdate) ) and trunc ( nvl( flv.end_date_active, sysdate))
)) 
)

--AND upper(led.description)   LIKE '%STATUTORY%' --Commented for REL078 
--REL063 GERITM29897336 Commented below         
/*AND ( (glb.period_name = :P_PERIOD AND :P_PERIOD IS NOT NULL) OR
      (glb.period_name = led.latest_opened_period_name AND :P_PERIOD IS NULL)
    )*/
--REL063 GERITM29897336 Commented above
	AND glb.period_name = nvl(:P_PERIOD,led.latest_opened_period_name) --REL063 GERITM29897336 Added
AND ccv.company_code         = glc.segment1
AND glc.code_combination_id  = glb.code_combination_id
AND glb.currency_code        = led.currency_code
--AND glc.segment9             <> 'S'
AND glc.segment1 NOT IN ('WCPN')
AND (NVL(begin_balance_dr,0) - NVL(begin_balance_cr,0)<> 0 OR  NVL(period_net_dr,0) - NVL(period_net_cr,0) <>0)))
SELECT CCLFUS_STAT_HFM.*, 'CCLFST' KEY
FROM CCLFUS_STAT_HFM
UNION
SELECT 'CCLFST,CCLBALEXFCES,'||TO_CHAR(SYSDATE,'YYYYMMDD')||',TRAILER,'||TO_CHAR(COUNT(*)) ||',P' DR4_STAT_HFM ,'CCLFST' KEY FROM CCLFUS_STAT_HFM
ORDER BY 1 desc