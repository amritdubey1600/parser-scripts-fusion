/*************************************************************************************************************************************
   *                           - Copy Right General Electric Company 2008 -
   *
   *************************************************************************************************************************************
   *************************************************************************************************************************************
   * Project            : GE Corporate CCL Project
   * Application        : 
   * Title              : CCLF_ARM_STAT_EXTRACT
   * Program Name       :
   * Description and Purpose: 
   * $Revision          : 33E
   * Utility            :
   * Created by         : Nuri Chetia
   * Creation Date      : 28-Oct-2019
   * Called By          :
   * Parameters         :
   * Dependency         :
   * Frequency          :
   * Related documents  :
   * Change History     :
   *====================================================================================================================================
   *  CR#       Date             |Name                |VERSION        |Remarks
   *====================================================================================================================================
   * REL-33E    28-OCT-2019      |Nuri Chetia         |  33E          | GERITM6025906:job completed with error due to 
   *                                                                   " ORA-01427: single-row subquery returns more than one row"
   * REL-40     26-MAR-2020      |Nuri Chetia         |  40           | GEINC6496063/GERITM8032376 Added condition to exclude CCL_USD_CAL_STA  
   * REL-084    20-JAN-2024      |Kumar Vignesh       |34             | Added Fusion Clone and Convey 																												  
    *************************************************************************************************************************************
   */
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
											   AND period_set_name=:P_PERIOD_SET-- REL 033E GERITM6025906 Added 
											   )
                       AND adjustment_period_flag = 'N'
					   AND period_set_name=:P_PERIOD_SET-- REL 033E GERITM6025906 Added 
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
										 AND period_set_name=:P_PERIOD_SET-- REL 033E GERITM6025906 Added 
										 )AND adjustment_period_flag = 'N'
										 AND period_set_name=:P_PERIOD_SET-- REL 033E GERITM6025906 Added 
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
											   AND period_set_name=:P_PERIOD_SET-- REL 033E GERITM6025906 Added 
											   )
                       AND adjustment_period_flag = 'N'
					   AND period_set_name=:P_PERIOD_SET-- REL 033E GERITM6025906 Added 
					   )
                  prev_1_mth
          FROM gl_periods
         WHERE     1 = 1              
               AND adjustment_period_flag = 'N'
			   AND period_set_name=:P_PERIOD_SET-- REL 033E GERITM6025906 Added 
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
											   AND period_set_name=:P_PERIOD_SET-- REL 033E GERITM6025906 Added 
											   ) 
                       AND adjustment_period_flag = 'N'
					   AND period_set_name=:P_PERIOD_SET-- REL 033E GERITM6025906 Added 
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
										 AND period_set_name=:P_PERIOD_SET-- REL 033E GERITM6025906 Added 
										 )AND adjustment_period_flag = 'N'
										 AND period_set_name=:P_PERIOD_SET-- REL 033E GERITM6025906 Added 
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
											   AND period_set_name=:P_PERIOD_SET-- REL 033E GERITM6025906 Added 
											   )
                       AND adjustment_period_flag = 'N'
					   AND period_set_name=:P_PERIOD_SET-- REL 033E GERITM6025906 Added 
					   )
                  prev_1_mth
          FROM gl_periods
         WHERE     1 = 1              
               AND adjustment_period_flag = 'N'
			   AND period_set_name=:P_PERIOD_SET-- REL 033E GERITM6025906 Added 
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
										 AND period_set_name=:P_PERIOD_SET-- REL 033E GERITM6025906 Added 
										 )AND adjustment_period_flag = 'N'
										  AND period_set_name=:P_PERIOD_SET-- REL 033E GERITM6025906 Added 
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
											   AND period_set_name=:P_PERIOD_SET-- REL 033E GERITM6025906 Added 
											   )
                       AND adjustment_period_flag = 'N'
					   AND period_set_name=:P_PERIOD_SET-- REL 033E GERITM6025906 Added 
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
											   AND period_set_name=:P_PERIOD_SET-- REL 033E GERITM6025906 Added 
											   )
                       AND adjustment_period_flag = 'N'
					   AND period_set_name=:P_PERIOD_SET-- REL 033E GERITM6025906 Added 
					   ) prev_1_mth
					FROM gl_periods  
                    WHERE     1 = 1              
               AND adjustment_period_flag = 'N'
			   AND period_set_name=:P_PERIOD_SET-- REL 033E GERITM6025906 Added 
               AND period_name IN ((SELECT TO_CHAR(SYSDATE,'MON-YY','NLS_DATE_LANGUAGE=AMERICAN') FROM dual))
			   AND ROWNUM <= 1)) b)) AND :P_PERIOD IS NULL))
			   -- Release 03 END
AND    (cc.segment2 LIKE '1%' OR cc.segment2 LIKE '2%' OR cc.segment2 LIKE '3%')  -- Account
AND    b.code_combination_id = cc.code_combination_id 
AND    b.ledger_id           = gl.ledger_id 
AND    b.currency_code       = gl.currency_code
AND    NVL(b.translated_flag,'ZZ') <> 'Y' 
AND    b.currency_code <> 'STAT'   
AND    cc.segment9 IN('P','G','S')  -- Book Type
--- Added for REL 084 Fusion Clone and Convey
 AND cc.segment1 NOT IN          
          (   SELECT  flv.lookup_code
             FROM  FND_LOOKUP_VALUES flv
          WHERE flv.lookup_type  ='CIRRUSGL_ERP_INT_COCO_NAME'
               AND flv.language='US'
               AND flv.enabled_Flag='Y'
               AND   TRUNC( sysdate)  
                              BETWEEN   NVL ( flv.start_date_active , TRUNC(SYSDATE)) 
                                        AND NVL( flv.end_date_active ,TRUNC(SYSDATE)) )
--- Ended for REL 084 Fusion Clone and Convey														 												 
AND    gl.name LIKE '%STA' -- ADD IN Release 03
AND    gl.name NOT LIKE 'CCL%CAL%STA%'  --REL 040 GEINC6496063/GERITM8032376 Added