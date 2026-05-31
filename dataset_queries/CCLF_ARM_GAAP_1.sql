/*--#-----------------------------------------------------------------------------------------------------------------#
--# CCLF ARM GAAP Extract
--# DESCRIPTION  : This data model query used to get the invoice archival extract for Alfresco
--#
--# CREATION DATE   :
--# CREATED BY      : 
--#
--# MODIFICATION HISTORY:
--# CR#                 Author            Date                  Description
--# -----------------------------------------------------------------------------------------------------------------#
--# REL-034           Nuri Chetia        01-NOV-2019            Added Period Set name as parameter
--# REL-072          Vidyasagar           21-DEC-2022             Created for Captial project                       -#
--# REL-084			Vignesh Kumar		20-Jan-2024				Added logic to restrict Non Aerospace Coco data
---# -----------------------------------------------------------------------------------------------------------------#*/
---Added for REL -072
with fcur AS
(
select a.flex_value COMPANY,a.attribute5 currency
FROM fnd_flex_values a, fnd_flex_value_sets b, fnd_flex_values_tl c
WHERE a.flex_value_set_id   = b.flex_value_set_id
AND b.flex_value_set_name = 'CCL_COMPANY_CODES'
AND a.flex_value_id       = c.flex_value_id
AND c.language            = 'US'
)
---Added End for REL -072
SELECT 'ARM' KEY,
       b.period_year c1_year, 
       b.period_name c2_period, 
       b.period_num c3_period_num, 
       b.currency_code c4_currency, 
       gl.name c5_ledger_name, 
       cc.segment1 c6_company_code, 
       cc.segment2 c7_account, 
       cc.segment3 c8_trading_partner, 
       cc.segment4 c9_cost_center, 
       cc.segment5 c10_geo, 
       cc.segment6 c11_project, 
       cc.segment7 c12_reference, 
       cc.segment8 c13_product_line, 
       cc.segment9 c14_book_type, 
       cc.segment10 c15_flex1, 
       cc.segment11 c16_flex2, 
       b.begin_balance_dr c17_begin_balance_dr, 
       b.begin_balance_cr c18_begin_balance_cr, 
       b.period_net_dr c19_period_net_dr, 
       b.period_net_cr c20_period_net_cr, 
       ((b.begin_balance_dr-b.begin_balance_cr)+(b.period_net_dr-b.period_net_cr)) c21_amount, 
       cc.segment1||'-'||cc.segment2||'-'||cc.segment3||'-'||cc.segment4||'-'||cc.segment5||'-'||cc.segment6||'-'||cc.segment7||'-'||cc.segment8||'-'||cc.segment9||'-'||cc.segment10||'-'||cc.segment11 c22_profile 
FROM   gl_balances b,
       gl_code_combinations cc,
       gl_ledgers gl
WHERE  1=1 
AND    b.period_num <> 13 
        -- Release 03 START
AND   ((b.period_name in (:P_PERIOD,(SELECT period_name
                  FROM gl_periods
                 WHERE     END_DATE IN (SELECT MIN (START_DATE) - 1
                                          FROM gl_periods
                                         WHERE     PERIOD_YEAR =
                                                      (SELECT period_year
                                                         FROM gl_periods
                                                        WHERE     period_name =:P_PERIOD
                                                              AND ROWNUM <= 1) 
                                               AND period_num =
                                                      (SELECT period_num
                                                         FROM gl_periods
                                                        WHERE     period_name =:P_PERIOD 
                                                              AND ROWNUM <= 1) 
                                               AND adjustment_period_flag ='N'
                                               AND period_set_name=:P_PERIOD_SET--REL034 GEINC5327851/GERITM6074631 Added
                                               )
                       AND adjustment_period_flag = 'N'
                       AND period_set_name=:P_PERIOD_SET--REL034 GEINC5327851/GERITM6074631 Added
                       ),( SELECT (SELECT period_name
            FROM gl_periods
           WHERE     end_DATE IN (SELECT MIN (START_DATE) - 1
                                    FROM gl_periods
                                   WHERE     PERIOD_YEAR =
                                                (SELECT period_year
                                                   FROM gl_periods
                                                  WHERE     period_name =prev_1_mth
                                                        AND ROWNUM <= 1) 
                                         AND period_num =
                                                (SELECT period_num
                                                   FROM gl_periods
                                                  WHERE     period_name =prev_1_mth AND ROWNUM <= 1)
                                         AND adjustment_period_flag = 'N'
                                         AND period_set_name=:P_PERIOD_SET--REL034 GEINC5327851/GERITM6074631 Added
                                         )AND adjustment_period_flag = 'N'
                                         AND period_set_name=:P_PERIOD_SET--REL034 GEINC5327851/GERITM6074631 Added
                                         ) prev_2_mth
  FROM (SELECT period_name,               
               (SELECT period_name
                  FROM gl_periods
                 WHERE     END_DATE IN (SELECT MIN (START_DATE) - 1
                                          FROM gl_periods
                                         WHERE     PERIOD_YEAR =
                                                      (SELECT period_year
                                                         FROM gl_periods
                                                        WHERE     period_name =:P_PERIOD
                                                              AND ROWNUM <= 1) 
                                               AND period_num =
                                                      (SELECT period_num
                                                         FROM gl_periods
                                                        WHERE     period_name =:P_PERIOD 
                                                              AND ROWNUM <= 1) 
                                               AND adjustment_period_flag ='N'
                                               AND period_set_name=:P_PERIOD_SET--REL034 GEINC5327851/GERITM6074631 Added
                                               )
                       AND adjustment_period_flag = 'N'
                       AND period_set_name=:P_PERIOD_SET--REL034 GEINC5327851/GERITM6074631 Added
                       )
                  prev_1_mth
          FROM gl_periods
         WHERE     1 = 1              
               AND adjustment_period_flag = 'N'
               AND period_set_name=:P_PERIOD_SET--REL034 GEINC5327851/GERITM6074631 Added
               AND period_name IN (:P_PERIOD)) a)) AND :P_PERIOD IS NOT NULL) OR
       (b.period_name in ((SELECT period_name
                  FROM gl_periods
                 WHERE     END_DATE IN (SELECT MIN (START_DATE) - 1
                                          FROM gl_periods
                                         WHERE     PERIOD_YEAR =
                                                      (SELECT period_year
                                                         FROM gl_periods
                                                        WHERE     period_name =(SELECT TO_CHAR(SYSDATE,'MON-YY','NLS_DATE_LANGUAGE=AMERICAN') FROM dual)
                                                              AND ROWNUM <= 1) 
                                               AND period_num =
                                                      (SELECT period_num
                                                         FROM gl_periods
                                                        WHERE     period_name =(SELECT TO_CHAR(SYSDATE,'MON-YY','NLS_DATE_LANGUAGE=AMERICAN') FROM dual)
                                                              AND ROWNUM <= 1) 
                                               AND adjustment_period_flag ='N'
                                               AND period_set_name=:P_PERIOD_SET--REL034 GEINC5327851/GERITM6074631 Added
                                               )                                               
                       AND adjustment_period_flag = 'N'
                       AND period_set_name=:P_PERIOD_SET--REL034 GEINC5327851/GERITM6074631 Added
                       ),(SELECT (SELECT period_name
            FROM gl_periods
           WHERE     end_DATE IN (SELECT MIN (START_DATE) - 1
                                    FROM gl_periods
                                   WHERE     PERIOD_YEAR =
                                                (SELECT period_year
                                                   FROM gl_periods
                                                  WHERE     period_name =prev_1_mth
                                                        AND ROWNUM <= 1) 
                                         AND period_num =
                                                (SELECT period_num
                                                   FROM gl_periods
                                                  WHERE     period_name =prev_1_mth AND ROWNUM <= 1)
                                         AND adjustment_period_flag = 'N'
                                         AND period_set_name=:P_PERIOD_SET--REL034 GEINC5327851/GERITM6074631 Added
                                         )AND adjustment_period_flag = 'N'
                                         AND period_set_name=:P_PERIOD_SET--REL034 GEINC5327851/GERITM6074631 Added
                                         ) prev_2_mth
  FROM (SELECT period_name,               
               (SELECT period_name
                  FROM gl_periods
                 WHERE     END_DATE IN (SELECT MIN (START_DATE) - 1
                                          FROM gl_periods
                                         WHERE     PERIOD_YEAR =
                                                      (SELECT period_year
                                                         FROM gl_periods
                                                        WHERE     period_name =(SELECT TO_CHAR(SYSDATE,'MON-YY','NLS_DATE_LANGUAGE=AMERICAN') FROM dual)
                                                              AND ROWNUM <= 1) 
                                               AND period_num =
                                                      (SELECT period_num
                                                         FROM gl_periods
                                                        WHERE     period_name =(SELECT TO_CHAR(SYSDATE,'MON-YY','NLS_DATE_LANGUAGE=AMERICAN') FROM dual) 
                                                              AND ROWNUM <= 1) 
                                               AND adjustment_period_flag ='N'
                                               AND period_set_name=:P_PERIOD_SET--REL034 GEINC5327851/GERITM6074631 Added
                                               )
                       AND adjustment_period_flag = 'N'
                       AND period_set_name=:P_PERIOD_SET--REL034 GEINC5327851/GERITM6074631 Added
                       )
                  prev_1_mth
          FROM gl_periods
         WHERE     1 = 1              
               AND adjustment_period_flag = 'N'
               AND period_set_name=:P_PERIOD_SET--REL034 GEINC5327851/GERITM6074631 Added
               AND period_name IN ((SELECT TO_CHAR(SYSDATE,'MON-YY','NLS_DATE_LANGUAGE=AMERICAN') FROM dual))
			   AND ROWNUM <= 1) a),(SELECT (SELECT period_name
            FROM gl_periods
           WHERE     end_DATE IN (SELECT MIN (START_DATE) - 1
                                    FROM gl_periods
                                   WHERE     PERIOD_YEAR =
                                                (SELECT period_year
                                                   FROM gl_periods
                                                  WHERE     period_name =prev_2_mth
                                                        AND ROWNUM <= 1) 
                                         AND period_num =
                                                (SELECT period_num
                                                   FROM gl_periods
                                                  WHERE     period_name =prev_2_mth AND ROWNUM <= 1)
                                         AND adjustment_period_flag = 'N'
                                         AND period_set_name=:P_PERIOD_SET--REL034 GEINC5327851/GERITM6074631 Added
                                         )AND adjustment_period_flag = 'N'
                                         AND period_set_name=:P_PERIOD_SET--REL034 GEINC5327851/GERITM6074631 Added
                                         ) prev_3_mth
  FROM (SELECT period_name,               
               (SELECT period_name
                  FROM gl_periods
                 WHERE     END_DATE IN (SELECT MIN (START_DATE) - 1
                                          FROM gl_periods
                                         WHERE     PERIOD_YEAR =
                                                      (SELECT period_year
                                                         FROM gl_periods
                                                        WHERE     period_name = prev_1_mth
                                                              AND ROWNUM <= 1) 
                                               AND period_num =
                                                      (SELECT period_num
                                                         FROM gl_periods
                                                        WHERE     period_name = prev_1_mth 
                                                              AND ROWNUM <= 1) 
                                               AND adjustment_period_flag ='N'
                                               AND period_set_name=:P_PERIOD_SET--REL034 GEINC5327851/GERITM6074631 Added
                                               )
                       AND adjustment_period_flag = 'N'
                       AND period_set_name=:P_PERIOD_SET--REL034 GEINC5327851/GERITM6074631 Added
                       ) prev_2_mth
          FROM (SELECT period_name,
		             (SELECT period_name
                  FROM gl_periods
                 WHERE     END_DATE IN (SELECT MIN (START_DATE) - 1
                                          FROM gl_periods
                                         WHERE     PERIOD_YEAR =
                                                      (SELECT period_year
                                                         FROM gl_periods
                                                        WHERE     period_name = (SELECT TO_CHAR(SYSDATE,'MON-YY','NLS_DATE_LANGUAGE=AMERICAN') FROM dual)
                                                              AND ROWNUM <= 1) 
                                               AND period_num =
                                                      (SELECT period_num
                                                         FROM gl_periods
                                                        WHERE     period_name = (SELECT TO_CHAR(SYSDATE,'MON-YY','NLS_DATE_LANGUAGE=AMERICAN') FROM dual) 
                                                              AND ROWNUM <= 1) 
                                               AND adjustment_period_flag ='N'
                                               AND period_set_name=:P_PERIOD_SET--REL034 GEINC5327851/GERITM6074631 Added
                                               )
                       AND adjustment_period_flag = 'N'
                       AND period_set_name=:P_PERIOD_SET--REL034 GEINC5327851/GERITM6074631 Added
                       ) prev_1_mth
					FROM gl_periods  
                    WHERE     1 = 1              
               AND adjustment_period_flag = 'N'
               AND period_set_name=:P_PERIOD_SET--REL034 GEINC5327851/GERITM6074631 Added
               AND period_name IN ((SELECT TO_CHAR(SYSDATE,'MON-YY','NLS_DATE_LANGUAGE=AMERICAN') FROM dual))
			   AND ROWNUM <= 1)) b)) AND :P_PERIOD IS NULL))
			   -- Release 03 END
AND    (cc.segment2 LIKE '1%' OR cc.segment2 LIKE '2%' OR cc.segment2 LIKE '3%')  -- Account
AND    b.code_combination_id = cc.code_combination_id 
--and  cc.code_combination_id  = 11069 --300000003378458
AND    b.ledger_id           = gl.ledger_id 
AND    b.currency_code       = gl.currency_code
AND    NVL(b.translated_flag,'ZZ') <> 'Y' 
AND    b.currency_code <> 'STAT'   
AND    cc.segment9 IN('P','G','S')  -- Book Type
-- Added for REL 084 Fusion Clone and Convey  
 AND cc.segment1 NOT IN          
          (   SELECT  flv.lookup_code
             FROM  FND_LOOKUP_VALUES flv
          WHERE flv.lookup_type  ='CIRRUSGL_ERP_INT_COCO_NAME'
               AND flv.language='US'
               AND flv.enabled_Flag='Y'
               AND   TRUNC( sysdate)  
                              BETWEEN   NVL ( flv.start_date_active , TRUNC(SYSDATE)) 
                                        AND NVL( flv.end_date_active ,TRUNC(SYSDATE)) )
---- Ended for REL 084 Fusion Clone and Convey											  
	AND (gl.name LIKE '%PRM' OR gl.name LIKE '%FCY' OR gl.name LIKE '%RPT')  -- ADD IN Release 03
--Added in REl-072
UNION
SELECT 'ARM' KEY,
       b.period_year c1_year, 
       b.period_name c2_period, 
       b.period_num c3_period_num, 
       b.currency_code c4_currency, 
       REPLACE(REPLACE(gl.name,'PRM','ENT'),'FCY','ENT') c5_ledger_name, 
       cc.segment1 c6_company_code, 
       cc.segment2 c7_account, 
       cc.segment3 c8_trading_partner, 
       cc.segment4 c9_cost_center, 
       cc.segment5 c10_geo, 
       cc.segment6 c11_project, 
       cc.segment7 c12_reference, 
       cc.segment8 c13_product_line, 
       cc.segment9 c14_book_type, 
       cc.segment10 c15_flex1, 
       cc.segment11 c16_flex2, 
       b.begin_balance_dr_beq c17_begin_balance_dr, 
       b.begin_balance_cr_beq c18_begin_balance_cr, 
       b.period_net_dr_beq c19_period_net_dr, 
       b.period_net_cr_beq c20_period_net_cr, 
       ((b.begin_balance_dr_beq-b.begin_balance_cr_beq)+(b.period_net_dr_beq-b.period_net_cr_beq)) c21_amount, 
       cc.segment1||'-'||cc.segment2||'-'||cc.segment3||'-'||cc.segment4||'-'||cc.segment5||'-'||cc.segment6||'-'||cc.segment7||'-'||cc.segment8||'-'||cc.segment9||'-'||cc.segment10||'-'||cc.segment11 c22_profile 
FROM   gl_balances b,
       gl_code_combinations cc,
       gl_ledgers gl,
	   fcur fcy
WHERE  1=1 
--AND   b.currency_code = fcy.currency
AND   cc.segment1     = fcy.company
-- Added for REL 084 Fusion Clone and Convey 
 AND cc.segment1 NOT IN          
          (   SELECT  flv.lookup_code
             FROM  FND_LOOKUP_VALUES flv
          WHERE flv.lookup_type  ='CIRRUSGL_ERP_INT_COCO_NAME'
               AND flv.language='US'
               AND flv.enabled_Flag='Y'
               AND   TRUNC( sysdate)  
                              BETWEEN   NVL ( flv.start_date_active , TRUNC(SYSDATE)) 
                                        AND NVL( flv.end_date_active ,TRUNC(SYSDATE)) )
---- Ended for REL 084 Fusion Clone and Convey 														 									   
AND   (gl.name LIKE '%_'||FCY.currency||'_FCY' OR
       gl.name LIKE '%_'||FCY.currency||'_PRM')	   
AND    b.period_num <> 13 
AND   ((b.period_name in (:P_PERIOD,(SELECT period_name
                  FROM gl_periods
                 WHERE     END_DATE IN (SELECT MIN (START_DATE) - 1
                                          FROM gl_periods
                                         WHERE     PERIOD_YEAR =
                                                      (SELECT period_year
                                                         FROM gl_periods
                                                        WHERE     period_name =:P_PERIOD
                                                              AND ROWNUM <= 1) 
                                               AND period_num =
                                                      (SELECT period_num
                                                         FROM gl_periods
                                                        WHERE     period_name =:P_PERIOD 
                                                              AND ROWNUM <= 1) 
                                               AND adjustment_period_flag ='N'
                                               AND period_set_name=:P_PERIOD_SET
                                               )
                       AND adjustment_period_flag = 'N'
                       AND period_set_name=:P_PERIOD_SET
                       ),( SELECT (SELECT period_name
            FROM gl_periods
           WHERE     end_DATE IN (SELECT MIN (START_DATE) - 1
                                    FROM gl_periods
                                   WHERE     PERIOD_YEAR =
                                                (SELECT period_year
                                                   FROM gl_periods
                                                  WHERE     period_name =prev_1_mth
                                                        AND ROWNUM <= 1) 
                                         AND period_num =
                                                (SELECT period_num
                                                   FROM gl_periods
                                                  WHERE     period_name =prev_1_mth AND ROWNUM <= 1)
                                         AND adjustment_period_flag = 'N'
                                         AND period_set_name=:P_PERIOD_SET
                                         )AND adjustment_period_flag = 'N'
                                         AND period_set_name=:P_PERIOD_SET
                                         ) prev_2_mth
  FROM (SELECT period_name,               
               (SELECT period_name
                  FROM gl_periods
                 WHERE     END_DATE IN (SELECT MIN (START_DATE) - 1
                                          FROM gl_periods
                                         WHERE     PERIOD_YEAR =
                                                      (SELECT period_year
                                                         FROM gl_periods
                                                        WHERE     period_name =:P_PERIOD
                                                              AND ROWNUM <= 1) 
                                               AND period_num =
                                                      (SELECT period_num
                                                         FROM gl_periods
                                                        WHERE     period_name =:P_PERIOD 
                                                              AND ROWNUM <= 1) 
                                               AND adjustment_period_flag ='N'
                                               AND period_set_name=:P_PERIOD_SET
                                               )
                       AND adjustment_period_flag = 'N'
                       AND period_set_name=:P_PERIOD_SET
                       )
                  prev_1_mth
          FROM gl_periods
         WHERE     1 = 1              
               AND adjustment_period_flag = 'N'
               AND period_set_name=:P_PERIOD_SET
               AND period_name IN (:P_PERIOD)) a)) AND :P_PERIOD IS NOT NULL) OR
       (b.period_name in ((SELECT period_name
                  FROM gl_periods
                 WHERE     END_DATE IN (SELECT MIN (START_DATE) - 1
                                          FROM gl_periods
                                         WHERE     PERIOD_YEAR =
                                                      (SELECT period_year
                                                         FROM gl_periods
                                                        WHERE     period_name =(SELECT TO_CHAR(SYSDATE,'MON-YY','NLS_DATE_LANGUAGE=AMERICAN') FROM dual)
                                                              AND ROWNUM <= 1) 
                                               AND period_num =
                                                      (SELECT period_num
                                                         FROM gl_periods
                                                        WHERE     period_name =(SELECT TO_CHAR(SYSDATE,'MON-YY','NLS_DATE_LANGUAGE=AMERICAN') FROM dual)
                                                              AND ROWNUM <= 1) 
                                               AND adjustment_period_flag ='N'
                                               AND period_set_name=:P_PERIOD_SET
                                               )                                               
                       AND adjustment_period_flag = 'N'
                       AND period_set_name=:P_PERIOD_SET
                       ),(SELECT (SELECT period_name
            FROM gl_periods
           WHERE     end_DATE IN (SELECT MIN (START_DATE) - 1
                                    FROM gl_periods
                                   WHERE     PERIOD_YEAR =
                                                (SELECT period_year
                                                   FROM gl_periods
                                                  WHERE     period_name =prev_1_mth
                                                        AND ROWNUM <= 1) 
                                         AND period_num =
                                                (SELECT period_num
                                                   FROM gl_periods
                                                  WHERE     period_name =prev_1_mth AND ROWNUM <= 1)
                                         AND adjustment_period_flag = 'N'
                                         AND period_set_name=:P_PERIOD_SET
                                         )AND adjustment_period_flag = 'N'
                                         AND period_set_name=:P_PERIOD_SET
                                         ) prev_2_mth
  FROM (SELECT period_name,               
               (SELECT period_name
                  FROM gl_periods
                 WHERE     END_DATE IN (SELECT MIN (START_DATE) - 1
                                          FROM gl_periods
                                         WHERE     PERIOD_YEAR =
                                                      (SELECT period_year
                                                         FROM gl_periods
                                                        WHERE     period_name =(SELECT TO_CHAR(SYSDATE,'MON-YY','NLS_DATE_LANGUAGE=AMERICAN') FROM dual)
                                                              AND ROWNUM <= 1) 
                                               AND period_num =
                                                      (SELECT period_num
                                                         FROM gl_periods
                                                        WHERE     period_name =(SELECT TO_CHAR(SYSDATE,'MON-YY','NLS_DATE_LANGUAGE=AMERICAN') FROM dual) 
                                                              AND ROWNUM <= 1) 
                                               AND adjustment_period_flag ='N'
                                               AND period_set_name=:P_PERIOD_SET
                                               )
                       AND adjustment_period_flag = 'N'
                       AND period_set_name=:P_PERIOD_SET
                       )
                  prev_1_mth
          FROM gl_periods
         WHERE     1 = 1              
               AND adjustment_period_flag = 'N'
               AND period_set_name=:P_PERIOD_SET
               AND period_name IN ((SELECT TO_CHAR(SYSDATE,'MON-YY','NLS_DATE_LANGUAGE=AMERICAN') FROM dual))
			   AND ROWNUM <= 1) a),(SELECT (SELECT period_name
            FROM gl_periods
           WHERE     end_DATE IN (SELECT MIN (START_DATE) - 1
                                    FROM gl_periods
                                   WHERE     PERIOD_YEAR =
                                                (SELECT period_year
                                                   FROM gl_periods
                                                  WHERE     period_name =prev_2_mth
                                                        AND ROWNUM <= 1) 
                                         AND period_num =
                                                (SELECT period_num
                                                   FROM gl_periods
                                                  WHERE     period_name =prev_2_mth AND ROWNUM <= 1)
                                         AND adjustment_period_flag = 'N'
                                         AND period_set_name=:P_PERIOD_SET
                                         )AND adjustment_period_flag = 'N'
                                         AND period_set_name=:P_PERIOD_SET
                                         ) prev_3_mth
  FROM (SELECT period_name,               
               (SELECT period_name
                  FROM gl_periods
                 WHERE     END_DATE IN (SELECT MIN (START_DATE) - 1
                                          FROM gl_periods
                                         WHERE     PERIOD_YEAR =
                                                      (SELECT period_year
                                                         FROM gl_periods
                                                        WHERE     period_name = prev_1_mth
                                                              AND ROWNUM <= 1) 
                                               AND period_num =
                                                      (SELECT period_num
                                                         FROM gl_periods
                                                        WHERE     period_name = prev_1_mth 
                                                              AND ROWNUM <= 1) 
                                               AND adjustment_period_flag ='N'
                                               AND period_set_name=:P_PERIOD_SET
                                               )
                       AND adjustment_period_flag = 'N'
                       AND period_set_name=:P_PERIOD_SET
                       ) prev_2_mth
          FROM (SELECT period_name,
		             (SELECT period_name
                  FROM gl_periods
                 WHERE     END_DATE IN (SELECT MIN (START_DATE) - 1
                                          FROM gl_periods
                                         WHERE     PERIOD_YEAR =
                                                      (SELECT period_year
                                                         FROM gl_periods
                                                        WHERE     period_name = (SELECT TO_CHAR(SYSDATE,'MON-YY','NLS_DATE_LANGUAGE=AMERICAN') FROM dual)
                                                              AND ROWNUM <= 1) 
                                               AND period_num =
                                                      (SELECT period_num
                                                         FROM gl_periods
                                                        WHERE     period_name = (SELECT TO_CHAR(SYSDATE,'MON-YY','NLS_DATE_LANGUAGE=AMERICAN') FROM dual) 
                                                              AND ROWNUM <= 1) 
                                               AND adjustment_period_flag ='N'
                                               AND period_set_name=:P_PERIOD_SET
                                               )
                       AND adjustment_period_flag = 'N'
                       AND period_set_name=:P_PERIOD_SET
                       ) prev_1_mth
					FROM gl_periods  
                    WHERE     1 = 1              
               AND adjustment_period_flag = 'N'
               AND period_set_name=:P_PERIOD_SET
               AND period_name IN ((SELECT TO_CHAR(SYSDATE,'MON-YY','NLS_DATE_LANGUAGE=AMERICAN') FROM dual))
			   AND ROWNUM <= 1)) b)) AND :P_PERIOD IS NULL))			  
AND    (cc.segment2 LIKE '1%' OR cc.segment2 LIKE '2%' OR cc.segment2 LIKE '3%')  -- Account
AND    b.code_combination_id = cc.code_combination_id 
AND    b.ledger_id           = gl.ledger_id 
AND    b.currency_code       = gl.currency_code
AND    NVL(b.translated_flag,'ZZ') <> 'Y' 
AND    b.currency_code <> 'STAT'   
AND    cc.segment9 IN('P','G','S')  -- Book Type
AND   (gl.name LIKE '%PRM' OR gl.name LIKE '%FCY') 
UNION
SELECT 'ARM' KEY,
       b.period_year c1_year, 
       b.period_name c2_period, 
       b.period_num c3_period_num, 
       b.currency_code c4_currency, 
       REPLACE(REPLACE(gl.name,'PRM','ENT'),'FCY','ENT') c5_ledger_name, 
       cc.segment1 c6_company_code, 
       cc.segment2 c7_account, 
       cc.segment3 c8_trading_partner, 
       cc.segment4 c9_cost_center, 
       cc.segment5 c10_geo, 
       cc.segment6 c11_project, 
       cc.segment7 c12_reference, 
       cc.segment8 c13_product_line, 
       cc.segment9 c14_book_type, 
       cc.segment10 c15_flex1, 
       cc.segment11 c16_flex2, 
         b.begin_balance_dr c17_begin_balance_dr, 
       b.begin_balance_cr c18_begin_balance_cr, 
       b.period_net_dr c19_period_net_dr, 
       b.period_net_cr c20_period_net_cr, 
       ((b.begin_balance_dr-b.begin_balance_cr)+(b.period_net_dr-b.period_net_cr)) c21_amount, 
       cc.segment1||'-'||cc.segment2||'-'||cc.segment3||'-'||cc.segment4||'-'||cc.segment5||'-'||cc.segment6||'-'||cc.segment7||'-'||cc.segment8||'-'||cc.segment9||'-'||cc.segment10||'-'||cc.segment11 c22_profile 
FROM   gl_balances b,
       gl_code_combinations cc,
       gl_ledgers gl,
	   fcur fcy
WHERE  1=1 
AND   cc.segment1     = fcy.company
-- Added for REL 084 Fusion Clone and Convey 
 AND cc.segment1 NOT IN          
          (   SELECT  flv.lookup_code
             FROM  FND_LOOKUP_VALUES flv
          WHERE flv.lookup_type  ='CIRRUSGL_ERP_INT_COCO_NAME'
               AND flv.language='US'
               AND flv.enabled_Flag='Y'
               AND   TRUNC( sysdate)  
                              BETWEEN   NVL ( flv.start_date_active , TRUNC(SYSDATE)) 
                                        AND NVL( flv.end_date_active ,TRUNC(SYSDATE)) )
-- Ended for REL 084 Fusion Clone and Convey 														 												 
AND   (gl.name LIKE '%_'||FCY.currency||'_FCY' OR
       gl.name LIKE '%_'||FCY.currency||'_PRM')	
AND    b.period_num <> 13 
        AND   ((b.period_name in (:P_PERIOD,(SELECT period_name
                  FROM gl_periods
                 WHERE     END_DATE IN (SELECT MIN (START_DATE) - 1
                                          FROM gl_periods
                                         WHERE     PERIOD_YEAR =
                                                      (SELECT period_year
                                                         FROM gl_periods
                                                        WHERE     period_name =:P_PERIOD
                                                              AND ROWNUM <= 1) 
                                               AND period_num =
                                                      (SELECT period_num
                                                         FROM gl_periods
                                                        WHERE     period_name =:P_PERIOD 
                                                              AND ROWNUM <= 1) 
                                               AND adjustment_period_flag ='N'
                                               AND period_set_name=:P_PERIOD_SET
                                               )
                       AND adjustment_period_flag = 'N'
                       AND period_set_name=:P_PERIOD_SET
                       ),( SELECT (SELECT period_name
            FROM gl_periods
           WHERE     end_DATE IN (SELECT MIN (START_DATE) - 1
                                    FROM gl_periods
                                   WHERE     PERIOD_YEAR =
                                                (SELECT period_year
                                                   FROM gl_periods
                                                  WHERE     period_name =prev_1_mth
                                                        AND ROWNUM <= 1) 
                                         AND period_num =
                                                (SELECT period_num
                                                   FROM gl_periods
                                                  WHERE     period_name =prev_1_mth AND ROWNUM <= 1)
                                         AND adjustment_period_flag = 'N'
                                         AND period_set_name=:P_PERIOD_SET
                                         )AND adjustment_period_flag = 'N'
                                         AND period_set_name=:P_PERIOD_SET
                                         ) prev_2_mth
  FROM (SELECT period_name,               
               (SELECT period_name
                  FROM gl_periods
                 WHERE     END_DATE IN (SELECT MIN (START_DATE) - 1
                                          FROM gl_periods
                                         WHERE     PERIOD_YEAR =
                                                      (SELECT period_year
                                                         FROM gl_periods
                                                        WHERE     period_name =:P_PERIOD
                                                              AND ROWNUM <= 1) 
                                               AND period_num =
                                                      (SELECT period_num
                                                         FROM gl_periods
                                                        WHERE     period_name =:P_PERIOD 
                                                              AND ROWNUM <= 1) 
                                               AND adjustment_period_flag ='N'
                                               AND period_set_name=:P_PERIOD_SET
                                               )
                       AND adjustment_period_flag = 'N'
                       AND period_set_name=:P_PERIOD_SET
                       )
                  prev_1_mth
          FROM gl_periods
         WHERE     1 = 1              
               AND adjustment_period_flag = 'N'
               AND period_set_name=:P_PERIOD_SET
               AND period_name IN (:P_PERIOD)) a)) AND :P_PERIOD IS NOT NULL) OR
       (b.period_name in ((SELECT period_name
                  FROM gl_periods
                 WHERE     END_DATE IN (SELECT MIN (START_DATE) - 1
                                          FROM gl_periods
                                         WHERE     PERIOD_YEAR =
                                                      (SELECT period_year
                                                         FROM gl_periods
                                                        WHERE     period_name =(SELECT TO_CHAR(SYSDATE,'MON-YY','NLS_DATE_LANGUAGE=AMERICAN') FROM dual)
                                                              AND ROWNUM <= 1) 
                                               AND period_num =
                                                      (SELECT period_num
                                                         FROM gl_periods
                                                        WHERE     period_name =(SELECT TO_CHAR(SYSDATE,'MON-YY','NLS_DATE_LANGUAGE=AMERICAN') FROM dual)
                                                              AND ROWNUM <= 1) 
                                               AND adjustment_period_flag ='N'
                                               AND period_set_name=:P_PERIOD_SET
                                               )                                               
                       AND adjustment_period_flag = 'N'
                       AND period_set_name=:P_PERIOD_SET
                       ),(SELECT (SELECT period_name
            FROM gl_periods
           WHERE     end_DATE IN (SELECT MIN (START_DATE) - 1
                                    FROM gl_periods
                                   WHERE     PERIOD_YEAR =
                                                (SELECT period_year
                                                   FROM gl_periods
                                                  WHERE     period_name =prev_1_mth
                                                        AND ROWNUM <= 1) 
                                         AND period_num =
                                                (SELECT period_num
                                                   FROM gl_periods
                                                  WHERE     period_name =prev_1_mth AND ROWNUM <= 1)
                                         AND adjustment_period_flag = 'N'
                                         AND period_set_name=:P_PERIOD_SET
                                         )AND adjustment_period_flag = 'N'
                                         AND period_set_name=:P_PERIOD_SET
                                         ) prev_2_mth
  FROM (SELECT period_name,               
               (SELECT period_name
                  FROM gl_periods
                 WHERE     END_DATE IN (SELECT MIN (START_DATE) - 1
                                          FROM gl_periods
                                         WHERE     PERIOD_YEAR =
                                                      (SELECT period_year
                                                         FROM gl_periods
                                                        WHERE     period_name =(SELECT TO_CHAR(SYSDATE,'MON-YY','NLS_DATE_LANGUAGE=AMERICAN') FROM dual)
                                                              AND ROWNUM <= 1) 
                                               AND period_num =
                                                      (SELECT period_num
                                                         FROM gl_periods
                                                        WHERE     period_name =(SELECT TO_CHAR(SYSDATE,'MON-YY','NLS_DATE_LANGUAGE=AMERICAN') FROM dual) 
                                                              AND ROWNUM <= 1) 
                                               AND adjustment_period_flag ='N'
                                               AND period_set_name=:P_PERIOD_SET
                                               )
                       AND adjustment_period_flag = 'N'
                       AND period_set_name=:P_PERIOD_SET
                       )
                  prev_1_mth
          FROM gl_periods
         WHERE     1 = 1              
               AND adjustment_period_flag = 'N'
               AND period_set_name=:P_PERIOD_SET
               AND period_name IN ((SELECT TO_CHAR(SYSDATE,'MON-YY','NLS_DATE_LANGUAGE=AMERICAN') FROM dual))
			   AND ROWNUM <= 1) a),(SELECT (SELECT period_name
            FROM gl_periods
           WHERE     end_DATE IN (SELECT MIN (START_DATE) - 1
                                    FROM gl_periods
                                   WHERE     PERIOD_YEAR =
                                                (SELECT period_year
                                                   FROM gl_periods
                                                  WHERE     period_name =prev_2_mth
                                                        AND ROWNUM <= 1) 
                                         AND period_num =
                                                (SELECT period_num
                                                   FROM gl_periods
                                                  WHERE     period_name =prev_2_mth AND ROWNUM <= 1)
                                         AND adjustment_period_flag = 'N'
                                         AND period_set_name=:P_PERIOD_SET
                                         )AND adjustment_period_flag = 'N'
                                         AND period_set_name=:P_PERIOD_SET
                                         ) prev_3_mth
  FROM (SELECT period_name,               
               (SELECT period_name
                  FROM gl_periods
                 WHERE     END_DATE IN (SELECT MIN (START_DATE) - 1
                                          FROM gl_periods
                                         WHERE     PERIOD_YEAR =
                                                      (SELECT period_year
                                                         FROM gl_periods
                                                        WHERE     period_name = prev_1_mth
                                                              AND ROWNUM <= 1) 
                                               AND period_num =
                                                      (SELECT period_num
                                                         FROM gl_periods
                                                        WHERE     period_name = prev_1_mth 
                                                              AND ROWNUM <= 1) 
                                               AND adjustment_period_flag ='N'
                                               AND period_set_name=:P_PERIOD_SET
                                               )
                       AND adjustment_period_flag = 'N'
                       AND period_set_name=:P_PERIOD_SET
                       ) prev_2_mth
          FROM (SELECT period_name,
		             (SELECT period_name
                  FROM gl_periods
                 WHERE     END_DATE IN (SELECT MIN (START_DATE) - 1
                                          FROM gl_periods
                                         WHERE     PERIOD_YEAR =
                                                      (SELECT period_year
                                                         FROM gl_periods
                                                        WHERE     period_name = (SELECT TO_CHAR(SYSDATE,'MON-YY','NLS_DATE_LANGUAGE=AMERICAN') FROM dual)
                                                              AND ROWNUM <= 1) 
                                               AND period_num =
                                                      (SELECT period_num
                                                         FROM gl_periods
                                                        WHERE     period_name = (SELECT TO_CHAR(SYSDATE,'MON-YY','NLS_DATE_LANGUAGE=AMERICAN') FROM dual) 
                                                              AND ROWNUM <= 1) 
                                               AND adjustment_period_flag ='N'
                                               AND period_set_name=:P_PERIOD_SET
                                               )
                       AND adjustment_period_flag = 'N'
                       AND period_set_name=:P_PERIOD_SET  
                       ) prev_1_mth
					FROM gl_periods  
                    WHERE     1 = 1              
               AND adjustment_period_flag = 'N'
               AND period_set_name=:P_PERIOD_SET
               AND period_name IN ((SELECT TO_CHAR(SYSDATE,'MON-YY','NLS_DATE_LANGUAGE=AMERICAN') FROM dual))
			   AND ROWNUM <= 1)) b)) AND :P_PERIOD IS NULL))			   
AND    (cc.segment2 LIKE '1%' OR cc.segment2 LIKE '2%' OR cc.segment2 LIKE '3%')  
AND    b.code_combination_id = cc.code_combination_id 
AND    b.ledger_id           = gl.ledger_id 
AND    b.currency_code       <> gl.currency_code
AND    NVL(b.translated_flag,'ZZ') <> 'Y' 
AND    b.currency_code <> 'STAT'   
AND    cc.segment9 IN('P','G','S')  
AND   (gl.name LIKE '%PRM' OR gl.name LIKE '%FCY') 
--Added end for REl-072