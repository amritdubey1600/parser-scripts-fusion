SELECT 'ARM' as "KEY"
      ,'text' as "OUTPUT_FORMAT"
      ,'FTP' as "DEL_CHANNEL"
      ,'Fusion_GLBalance_'||'GAAP_'||NVL(:P_PERIOD,(SELECT period_name
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
                       ))||'.txt' as "OUTPUT_NAME"
      ,'true' as "SAVE_OUTPUT"
     -- , FND_PROFILE.VALUE('GLOBALSCAPE_MFT') as "PARAMETER1"
	  ,(SELECT description
				FROM fnd_lookup_values 
				WHERE lookup_type = 'VER_GS_BURST_PROGS'
				AND lookup_code = 'VNF_CCLF_ARM_GAAP_EXTRT'
				AND enabled_flag = 'Y'
				AND Language = 'US') as "PARAMETER1" -- Fusion clone and Convey to Vernova
      ,:P_DEST_DIR as "PARAMETER4"
      ,'Fusion_GLBalance_'||'GAAP_'||NVL(:P_PERIOD,(SELECT period_name
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
                       ))||'.txt' as "PARAMETER5"
       ,'true' as "PARAMETER6"
FROM dual