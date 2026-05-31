SELECT a.period_name
      ,b.segment1 company_code
      ,(SELECT parent_PK1_VALUE
               FROM fnd_tree_node ftn
                   ,FND_TREE_VERSION_VL ftv
               WHERE 1=1
               AND ftn.tree_Code =  'ACCOUNT MARS UNPUBLISHED'
               AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
               AND ftv.tree_Code = ftn.tree_code
               AND ftv.tree_structure_code = ftn.tree_structure_code
               AND ftv.TREE_VERSION_NAME = 'CURRENT'
               AND ftn.TREE_VERSION_ID = ftv.TREE_VERSION_ID
               AND pk1_start_value = b.segment2)  mars_account
      ,b.segment2 local_account
      ,b.segment3 trading_partner
      ,a.currency_code
      ,'CC30'  sender_id
      ,'Fusion' local_sender_id
      ,'RECON' amount_type
      ,'USDRQ' mars_amount_type
      ,(SELECT TO_CHAR(Start_Date,'MM')||'15'||TO_CHAR(Start_Date,'YYYY')
        FROM gl_periods
        WHERE period_name = a.period_name
        AND period_set_name = c.period_set_name) effective_date
      ,(SELECT SUBSTR(parent_PK1_VALUE,1)
               FROM fnd_tree_node ftn
                   ,FND_TREE_VERSION_VL ftv
               WHERE 1=1
               --AND ftn.tree_Code =  'Company BU'
               AND ftn.tree_Code =  'COMPANY MARS UNPUBLISHED' -- Changed the hierarchy. 03 Sep
               AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
               AND ftv.tree_Code = ftn.tree_code
               AND ftv.tree_structure_code = ftn.tree_structure_code
               AND ftv.TREE_VERSION_NAME = 'CURRENT'
               AND ftn.TREE_VERSION_ID = ftv.TREE_VERSION_ID
               AND pk1_start_value = b.segment1) business_unit
      ,b.segment1 local_bu
      ,(SELECT SUBSTR(parent_PK1_VALUE,1) -- Changed back from position 4 as the underscores are removed. 19 Oct
               FROM fnd_tree_node ftn
                   ,FND_TREE_VERSION_VL ftv
               WHERE 1=1
               AND ftn.tree_Code =  'Company LE'
               AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
               AND ftv.tree_Code = ftn.tree_code
               AND ftv.tree_structure_code = ftn.tree_structure_code
               AND ftv.TREE_VERSION_NAME = 'CURRENT'
               AND ftn.TREE_VERSION_ID = ftv.TREE_VERSION_ID
               AND pk1_start_value = b.segment1) legal_entity
      /*,(SELECT parent_PK1_VALUE
               FROM fnd_tree_node ftn
                   ,FND_TREE_VERSION_VL ftv
               WHERE 1=1
               AND ftn.tree_Code =  'TP MARS IBU UNPUBLISHED'
               AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
               AND ftv.tree_Code = ftn.tree_code
               AND ftv.tree_structure_code = ftn.tree_structure_code
               AND ftv.TREE_VERSION_NAME = 'CURRENT'
               AND ftn.TREE_VERSION_ID = ftv.TREE_VERSION_ID
               AND pk1_start_value = b.segment3)  ibu
      ,b.segment3 local_ibu
      ,(SELECT parent_PK1_VALUE
        FROM fnd_tree_node ftn
            ,FND_TREE_VERSION_VL ftv
        WHERE 1=1
        AND ftn.tree_Code =  'TP MARS ILE UNPUBLISHED'
        AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
        AND ftv.tree_Code = ftn.tree_code
        AND ftv.tree_structure_code = ftn.tree_structure_code
        AND ftv.TREE_VERSION_NAME = 'CURRENT'
        AND ftn.TREE_VERSION_ID = ftv.TREE_VERSION_ID
        AND pk1_start_value = b.segment3)  ile*/
        ,NVL((SELECT 
        CASE ftn.parent_pk1_value 
           WHEN 'N' THEN '000000' 
            ELSE ( SELECT  parent_PK1_VALUE
                     FROM  fnd_tree_node ftn
                          ,fnd_tree_version_vl ftv
                    WHERE  1=1
                      AND  ftn.tree_Code           = 'TP MARS IBU UNPUBLISHED'
                      AND  ftn.tree_structure_code = 'GL_ACCT_FLEX'
                      AND  ftv.tree_Code           = ftn.tree_code
                      AND  ftv.tree_structure_code = ftn.tree_structure_code
                      AND  ftv.TREE_VERSION_NAME   = 'CURRENT'
                      AND  ftn.TREE_VERSION_ID     = ftv.TREE_VERSION_ID
                      AND  pk1_start_value         = b.segment3 )
            END   
         FROM   fnd_tree_node ftn
               ,fnd_tree_version_vl ftv
         WHERE 1=1
           AND ftn.tree_Code           = 'ACCOUNT MARS IME UNPUBLISHED'
           AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
           AND ftv.tree_Code           = ftn.tree_code
           AND ftv.tree_structure_code = ftn.tree_structure_code
           AND ftv.TREE_VERSION_NAME   = 'CURRENT'
           AND ftn.TREE_VERSION_ID     = ftv.TREE_VERSION_ID
           AND pk1_start_value         = b.segment2),'000000') "IBU" ,
         NVL((SELECT 
        CASE ftn.parent_pk1_value 
           WHEN 'N' THEN '000000' 
            ELSE ( SELECT  parent_PK1_VALUE
                     FROM  fnd_tree_node ftn
                          ,fnd_tree_version_vl ftv
                    WHERE  1=1
                      AND  ftn.tree_Code           = 'TP MARS ILE UNPUBLISHED'
                      AND  ftn.tree_structure_code = 'GL_ACCT_FLEX'
                      AND  ftv.tree_Code           = ftn.tree_code
                      AND  ftv.tree_structure_code = ftn.tree_structure_code
                      AND  ftv.TREE_VERSION_NAME   = 'CURRENT'
                      AND  ftn.TREE_VERSION_ID     = ftv.TREE_VERSION_ID
                      AND  pk1_start_value         = b.segment3 )
            END   
         FROM   fnd_tree_node ftn
               ,fnd_tree_version_vl ftv
         WHERE 1=1
           AND ftn.tree_Code           = 'ACCOUNT MARS ILE UNPUBLISHED'
           AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
           AND ftv.tree_Code           = ftn.tree_code
           AND ftv.tree_structure_code = ftn.tree_structure_code
           AND ftv.TREE_VERSION_NAME   = 'CURRENT'
           AND ftn.TREE_VERSION_ID     = ftv.TREE_VERSION_ID
           AND pk1_start_value         = b.segment2),'000000') "ILE" 
      ,(SELECT REPLACE(SUBSTR(FFVV.description,1,50),',',';')
        FROM fnd_flex_values_vl FFVV,
             FND_FLEX_VALUE_SETS FFVS
        WHERE FFVV.FLEX_VALUE_SET_ID = FFVS.FLEX_VALUE_SET_ID
        AND  FFVS.flex_value_set_name = 'CCL_ACCOUNTS'
        AND  b.segment2 = FFVV.flex_value) local_acct_description
      ,(SELECT REPLACE(SUBSTR(FFVV.description,1,50),',',';') TP_Desc
        FROM fnd_flex_values_vl FFVV,
             FND_FLEX_VALUE_SETS FFVS
        WHERE FFVV.FLEX_VALUE_SET_ID = FFVS.FLEX_VALUE_SET_ID
        AND  FFVS.flex_value_set_name = 'CCL_TRADING_PARTNERS'
        AND  b.segment3 = FFVV.flex_value) local_ibu_description
      ,(SELECT REPLACE(SUBSTR(FFVV.description,1,50),',',';')
        FROM fnd_flex_values_vl FFVV,
             FND_FLEX_VALUE_SETS FFVS
        WHERE FFVV.FLEX_VALUE_SET_ID = FFVS.FLEX_VALUE_SET_ID
        AND  FFVS.flex_value_set_name = 'CCL_COMPANY_CODES'
        AND  b.segment1 = FFVV.flex_value) local_bu_description
      ,NULL analysis
      ,NULL type
      ,:P_RUN_TYPE run_type
      ,(NVL(begin_balance_dr,0)- NVL(begin_balance_cr,0) + NVL(period_net_dr,0) - NVL(period_net_cr,0)) amount
FROM GL_BALANCES a
    ,GL_CODE_COMBINATIONS b
    ,GL_LEDGERS c
WHERE a.code_combination_id = b.code_combination_id
AND a.ledger_id = c.ledger_id
AND c.ledger_category_code = 'ALC'      -- reporting ledger
-- Change to extract only for CA_USD_RPT. 18 Sep
AND c.name = 'CA_USD_RPT'
AND :P_SENDER_ID = 'CC30'
--
AND c.currency_code = 'USD'   -- with functional currency as USD
AND a.currency_code = c.currency_code  -- only USD balances
-- Change to select only records that belong to CANLTD or CANHDQ BU. 17 Sep
AND EXISTS (SELECT 'X'
               FROM fnd_tree_node ftn
                   ,FND_TREE_VERSION_VL ftv
               WHERE 1=1
               AND ftn.tree_Code =  'COMPANY MARS UNPUBLISHED'
               AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
               AND ftv.tree_Code = ftn.tree_code
               AND ftv.tree_structure_code = ftn.tree_structure_code
               AND ftv.TREE_VERSION_NAME = 'CURRENT'
               AND ftn.TREE_VERSION_ID = ftv.TREE_VERSION_ID
               AND pk1_start_value = b.segment1
               AND parent_PK1_VALUE IN ('CANLTD', 'CANHDQ') )
-- End of changes  17 Sep
AND b.segment9 <> 'S'  -- exclude statutory adjustments
AND NVL(begin_balance_dr,0)- NVL(begin_balance_cr,0) + NVL(period_net_dr,0) - NVL(period_net_cr,0) <> 0
-- Changed to use latest open period if Period Name is not passed. 09 Sep.
--AND a.period_name = :P_PERIOD
AND ( (a.period_name = :P_PERIOD AND :P_PERIOD IS NOT NULL) OR
      (a.period_name = c.latest_opened_period_name AND :P_PERIOD IS NULL)
    )
UNION ALL
--GBSAAA
SELECT a.period_name
      ,b.segment1 company_code
      ,(SELECT parent_PK1_VALUE
               FROM fnd_tree_node ftn
                   ,FND_TREE_VERSION_VL ftv
               WHERE 1=1
               AND ftn.tree_Code =  'ACCOUNT MARS UNPUBLISHED'
               AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
               AND ftv.tree_Code = ftn.tree_code
               AND ftv.tree_structure_code = ftn.tree_structure_code
               AND ftv.TREE_VERSION_NAME = 'CURRENT'
               AND ftn.TREE_VERSION_ID = ftv.TREE_VERSION_ID
               AND pk1_start_value = b.segment2)  mars_account
      ,b.segment2 local_account
      ,b.segment3 trading_partner
      ,a.currency_code
      ,'CC32'  sender_id
      ,'Fusion' local_sender_id
      ,'RECON' amount_type
      ,'USDRQ' mars_amount_type
      ,(SELECT TO_CHAR(Start_Date,'MM')||'15'||TO_CHAR(Start_Date,'YYYY')
        FROM gl_periods
        WHERE period_name = a.period_name
        AND period_set_name = c.period_set_name) effective_date
      ,(SELECT SUBSTR(parent_PK1_VALUE,1)
               FROM fnd_tree_node ftn
                   ,FND_TREE_VERSION_VL ftv
               WHERE 1=1
               --AND ftn.tree_Code =  'Company BU'
               AND ftn.tree_Code =  'COMPANY MARS UNPUBLISHED' -- Changed the hierarchy. 03 Sep
               AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
               AND ftv.tree_Code = ftn.tree_code
               AND ftv.tree_structure_code = ftn.tree_structure_code
               AND ftv.TREE_VERSION_NAME = 'CURRENT'
               AND ftn.TREE_VERSION_ID = ftv.TREE_VERSION_ID
               AND pk1_start_value = b.segment1) business_unit
      ,b.segment1 local_bu
      ,(SELECT SUBSTR(parent_PK1_VALUE,1) -- Changed back from position 4 as the underscores are removed. 19 Oct
               FROM fnd_tree_node ftn
                   ,FND_TREE_VERSION_VL ftv
               WHERE 1=1
               AND ftn.tree_Code =  'Company LE'
               AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
               AND ftv.tree_Code = ftn.tree_code
               AND ftv.tree_structure_code = ftn.tree_structure_code
               AND ftv.TREE_VERSION_NAME = 'CURRENT'
               AND ftn.TREE_VERSION_ID = ftv.TREE_VERSION_ID
               AND pk1_start_value = b.segment1) legal_entity
      /*,(SELECT parent_PK1_VALUE
               FROM fnd_tree_node ftn
                   ,FND_TREE_VERSION_VL ftv
               WHERE 1=1
               AND ftn.tree_Code =  'TP MARS IBU UNPUBLISHED'
               AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
               AND ftv.tree_Code = ftn.tree_code
               AND ftv.tree_structure_code = ftn.tree_structure_code
               AND ftv.TREE_VERSION_NAME = 'CURRENT'
               AND ftn.TREE_VERSION_ID = ftv.TREE_VERSION_ID
               AND pk1_start_value = b.segment3)  ibu
      ,b.segment3 local_ibu
      ,(SELECT parent_PK1_VALUE
        FROM fnd_tree_node ftn
            ,FND_TREE_VERSION_VL ftv
        WHERE 1=1
        AND ftn.tree_Code =  'TP MARS ILE UNPUBLISHED'
        AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
        AND ftv.tree_Code = ftn.tree_code
        AND ftv.tree_structure_code = ftn.tree_structure_code
        AND ftv.TREE_VERSION_NAME = 'CURRENT'
        AND ftn.TREE_VERSION_ID = ftv.TREE_VERSION_ID
        AND pk1_start_value = b.segment3)  ile*/
        ,NVL((SELECT 
        CASE ftn.parent_pk1_value 
           WHEN 'N' THEN '000000' 
            ELSE ( SELECT  parent_PK1_VALUE
                     FROM  fnd_tree_node ftn
                          ,fnd_tree_version_vl ftv
                    WHERE  1=1
                      AND  ftn.tree_Code           = 'TP MARS IBU UNPUBLISHED'
                      AND  ftn.tree_structure_code = 'GL_ACCT_FLEX'
                      AND  ftv.tree_Code           = ftn.tree_code
                      AND  ftv.tree_structure_code = ftn.tree_structure_code
                      AND  ftv.TREE_VERSION_NAME   = 'CURRENT'
                      AND  ftn.TREE_VERSION_ID     = ftv.TREE_VERSION_ID
                      AND  pk1_start_value         = b.segment3 )
            END   
         FROM   fnd_tree_node ftn
               ,fnd_tree_version_vl ftv
         WHERE 1=1
           AND ftn.tree_Code           = 'ACCOUNT MARS IME UNPUBLISHED'
           AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
           AND ftv.tree_Code           = ftn.tree_code
           AND ftv.tree_structure_code = ftn.tree_structure_code
           AND ftv.TREE_VERSION_NAME   = 'CURRENT'
           AND ftn.TREE_VERSION_ID     = ftv.TREE_VERSION_ID
           AND pk1_start_value         = b.segment2),'000000') "IBU" ,
         NVL((SELECT 
        CASE ftn.parent_pk1_value 
           WHEN 'N' THEN '000000' 
            ELSE ( SELECT  parent_PK1_VALUE
                     FROM  fnd_tree_node ftn
                          ,fnd_tree_version_vl ftv
                    WHERE  1=1
                      AND  ftn.tree_Code           = 'TP MARS ILE UNPUBLISHED'
                      AND  ftn.tree_structure_code = 'GL_ACCT_FLEX'
                      AND  ftv.tree_Code           = ftn.tree_code
                      AND  ftv.tree_structure_code = ftn.tree_structure_code
                      AND  ftv.TREE_VERSION_NAME   = 'CURRENT'
                      AND  ftn.TREE_VERSION_ID     = ftv.TREE_VERSION_ID
                      AND  pk1_start_value         = b.segment3 )
            END   
         FROM   fnd_tree_node ftn
               ,fnd_tree_version_vl ftv
         WHERE 1=1
           AND ftn.tree_Code           = 'ACCOUNT MARS ILE UNPUBLISHED'
           AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
           AND ftv.tree_Code           = ftn.tree_code
           AND ftv.tree_structure_code = ftn.tree_structure_code
           AND ftv.TREE_VERSION_NAME   = 'CURRENT'
           AND ftn.TREE_VERSION_ID     = ftv.TREE_VERSION_ID
           AND pk1_start_value         = b.segment2),'000000') "ILE" 
      ,(SELECT REPLACE(SUBSTR(FFVV.description,1,50),',',';')
        FROM fnd_flex_values_vl FFVV,
             FND_FLEX_VALUE_SETS FFVS
        WHERE FFVV.FLEX_VALUE_SET_ID = FFVS.FLEX_VALUE_SET_ID
        AND  FFVS.flex_value_set_name = 'CCL_ACCOUNTS'
        AND  b.segment2 = FFVV.flex_value) local_acct_description
      ,(SELECT REPLACE(SUBSTR(FFVV.description,1,50),',',';') TP_Desc
        FROM fnd_flex_values_vl FFVV,
             FND_FLEX_VALUE_SETS FFVS
        WHERE FFVV.FLEX_VALUE_SET_ID = FFVS.FLEX_VALUE_SET_ID
        AND  FFVS.flex_value_set_name = 'CCL_TRADING_PARTNERS'
        AND  b.segment3 = FFVV.flex_value) local_ibu_description
      ,(SELECT REPLACE(SUBSTR(FFVV.description,1,50),',',';')
        FROM fnd_flex_values_vl FFVV,
             FND_FLEX_VALUE_SETS FFVS
        WHERE FFVV.FLEX_VALUE_SET_ID = FFVS.FLEX_VALUE_SET_ID
        AND  FFVS.flex_value_set_name = 'CCL_COMPANY_CODES'
        AND  b.segment1 = FFVV.flex_value) local_bu_description
      ,NULL analysis
      ,NULL type
      ,:P_RUN_TYPE run_type
      ,(NVL(begin_balance_dr,0)- NVL(begin_balance_cr,0) + NVL(period_net_dr,0) - NVL(period_net_cr,0)) amount
FROM GL_BALANCES a
    ,GL_CODE_COMBINATIONS b
    ,GL_LEDGERS c
WHERE a.code_combination_id = b.code_combination_id
AND a.ledger_id = c.ledger_id
AND c.ledger_category_code = 'ALC'      -- reporting ledger
AND :P_SENDER_ID = 'CC32'
-- Change to extract only for CA_USD_RPT. 18 Sep
--AND c.name IN('AU_USD_RPT','NZ_USD_RPT','BN_USD_RPT','ID_USD_RPT','JP_USD_RPT','MY_USD_RPT','PH_USD_RPT')
AND c.name IN (SELECT flv.lookup_code
                 FROM fnd_lookup_types flt,
                      fnd_lookup_values flv
                WHERE flt.lookup_type   = 'CCLF_MARS_GBSAAA_LEDGER'
                  AND flt.lookup_type   = flv.lookup_type
                  AND flv.language      = 'US'
                  AND flv.tag ='REPORTING')
--
AND c.currency_code = 'USD'   -- with functional currency as USD
AND a.currency_code = c.currency_code  -- only USD balances
-- Change to select only records that belong to CANLTD or CANHDQ BU. 17 Sep
--AND b.segment1 IN ('GAU1','GAU4','GNZ1','GJP1','GJP3','GJP2','GID2','GID1','GID3','GPH1','GMY1','GBN1') 
AND b.segment1 IN (SELECT flv.lookup_code 
                     FROM fnd_lookup_types flt,
                          fnd_lookup_values flv
                    WHERE flt.lookup_type   = 'CCLF_MARS_GBSAAA_COMPANY'
                      AND flt.lookup_type   = flv.lookup_type
                      AND flv.language      = 'US')
AND b.segment9 <> 'S'  -- exclude statutory adjustments
AND NVL(begin_balance_dr,0)- NVL(begin_balance_cr,0) + NVL(period_net_dr,0) - NVL(period_net_cr,0) <> 0
-- Changed to use latest open period if Period Name is not passed. 09 Sep.
--AND a.period_name = :P_PERIOD
AND ( (a.period_name = :P_PERIOD AND :P_PERIOD IS NOT NULL) OR
      (a.period_name = c.latest_opened_period_name AND :P_PERIOD IS NULL)
    )
-- JAPANX
UNION ALL
SELECT a.period_name
      ,b.segment1 company_code
      ,(SELECT parent_PK1_VALUE
               FROM fnd_tree_node ftn
                   ,FND_TREE_VERSION_VL ftv
               WHERE 1=1
               AND ftn.tree_Code =  'ACCOUNT MARS UNPUBLISHED'
               AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
               AND ftv.tree_Code = ftn.tree_code
               AND ftv.tree_structure_code = ftn.tree_structure_code
               AND ftv.TREE_VERSION_NAME = 'CURRENT'
               AND ftn.TREE_VERSION_ID = ftv.TREE_VERSION_ID
               AND pk1_start_value = b.segment2)  mars_account
      ,b.segment2 local_account
      ,b.segment3 trading_partner
      ,a.currency_code
      ,'CC46'  sender_id
      ,'Fusion' local_sender_id
      ,'RECON' amount_type
      ,'USDRQ' mars_amount_type
      ,(SELECT TO_CHAR(Start_Date,'MM')||'15'||TO_CHAR(Start_Date,'YYYY')
        FROM gl_periods
        WHERE period_name = a.period_name
        AND period_set_name = c.period_set_name) effective_date
      ,(SELECT SUBSTR(parent_PK1_VALUE,1)
               FROM fnd_tree_node ftn
                   ,FND_TREE_VERSION_VL ftv
               WHERE 1=1
               --AND ftn.tree_Code =  'Company BU'
               AND ftn.tree_Code =  'COMPANY MARS UNPUBLISHED' -- Changed the hierarchy. 03 Sep
               AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
               AND ftv.tree_Code = ftn.tree_code
               AND ftv.tree_structure_code = ftn.tree_structure_code
               AND ftv.TREE_VERSION_NAME = 'CURRENT'
               AND ftn.TREE_VERSION_ID = ftv.TREE_VERSION_ID
               AND pk1_start_value = b.segment1) business_unit
      ,b.segment1 local_bu
      ,(SELECT SUBSTR(parent_PK1_VALUE,1) -- Changed back from position 4 as the underscores are removed. 19 Oct
               FROM fnd_tree_node ftn
                   ,FND_TREE_VERSION_VL ftv
               WHERE 1=1
               AND ftn.tree_Code =  'Company LE'
               AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
               AND ftv.tree_Code = ftn.tree_code
               AND ftv.tree_structure_code = ftn.tree_structure_code
               AND ftv.TREE_VERSION_NAME = 'CURRENT'
               AND ftn.TREE_VERSION_ID = ftv.TREE_VERSION_ID
               AND pk1_start_value = b.segment1) legal_entity
      /*,(SELECT parent_PK1_VALUE
               FROM fnd_tree_node ftn
                   ,FND_TREE_VERSION_VL ftv
               WHERE 1=1
               AND ftn.tree_Code =  'TP MARS IBU UNPUBLISHED'
               AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
               AND ftv.tree_Code = ftn.tree_code
               AND ftv.tree_structure_code = ftn.tree_structure_code
               AND ftv.TREE_VERSION_NAME = 'CURRENT'
               AND ftn.TREE_VERSION_ID = ftv.TREE_VERSION_ID
               AND pk1_start_value = b.segment3)  ibu
      ,b.segment3 local_ibu
      ,(SELECT parent_PK1_VALUE
        FROM fnd_tree_node ftn
            ,FND_TREE_VERSION_VL ftv
        WHERE 1=1
        AND ftn.tree_Code =  'TP MARS ILE UNPUBLISHED'
        AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
        AND ftv.tree_Code = ftn.tree_code
        AND ftv.tree_structure_code = ftn.tree_structure_code
        AND ftv.TREE_VERSION_NAME = 'CURRENT'
        AND ftn.TREE_VERSION_ID = ftv.TREE_VERSION_ID
        AND pk1_start_value = b.segment3)  ile*/
        ,NVL((SELECT 
        CASE ftn.parent_pk1_value 
           WHEN 'N' THEN '000000' 
            ELSE ( SELECT  parent_PK1_VALUE
                     FROM  fnd_tree_node ftn
                          ,fnd_tree_version_vl ftv
                    WHERE  1=1
                      AND  ftn.tree_Code           = 'TP MARS IBU UNPUBLISHED'
                      AND  ftn.tree_structure_code = 'GL_ACCT_FLEX'
                      AND  ftv.tree_Code           = ftn.tree_code
                      AND  ftv.tree_structure_code = ftn.tree_structure_code
                      AND  ftv.TREE_VERSION_NAME   = 'CURRENT'
                      AND  ftn.TREE_VERSION_ID     = ftv.TREE_VERSION_ID
                      AND  pk1_start_value         = b.segment3 )
            END   
         FROM   fnd_tree_node ftn
               ,fnd_tree_version_vl ftv
         WHERE 1=1
           AND ftn.tree_Code           = 'ACCOUNT MARS IME UNPUBLISHED'
           AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
           AND ftv.tree_Code           = ftn.tree_code
           AND ftv.tree_structure_code = ftn.tree_structure_code
           AND ftv.TREE_VERSION_NAME   = 'CURRENT'
           AND ftn.TREE_VERSION_ID     = ftv.TREE_VERSION_ID
           AND pk1_start_value         = b.segment2),'000000') "IBU" ,
         NVL((SELECT 
        CASE ftn.parent_pk1_value 
           WHEN 'N' THEN '000000' 
            ELSE ( SELECT  parent_PK1_VALUE
                     FROM  fnd_tree_node ftn
                          ,fnd_tree_version_vl ftv
                    WHERE  1=1
                      AND  ftn.tree_Code           = 'TP MARS ILE UNPUBLISHED'
                      AND  ftn.tree_structure_code = 'GL_ACCT_FLEX'
                      AND  ftv.tree_Code           = ftn.tree_code
                      AND  ftv.tree_structure_code = ftn.tree_structure_code
                      AND  ftv.TREE_VERSION_NAME   = 'CURRENT'
                      AND  ftn.TREE_VERSION_ID     = ftv.TREE_VERSION_ID
                      AND  pk1_start_value         = b.segment3 )
            END   
         FROM   fnd_tree_node ftn
               ,fnd_tree_version_vl ftv
         WHERE 1=1
           AND ftn.tree_Code           = 'ACCOUNT MARS ILE UNPUBLISHED'
           AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
           AND ftv.tree_Code           = ftn.tree_code
           AND ftv.tree_structure_code = ftn.tree_structure_code
           AND ftv.TREE_VERSION_NAME   = 'CURRENT'
           AND ftn.TREE_VERSION_ID     = ftv.TREE_VERSION_ID
           AND pk1_start_value         = b.segment2),'000000') "ILE" 
      ,(SELECT REPLACE(SUBSTR(FFVV.description,1,50),',',';')
        FROM fnd_flex_values_vl FFVV,
             FND_FLEX_VALUE_SETS FFVS
        WHERE FFVV.FLEX_VALUE_SET_ID = FFVS.FLEX_VALUE_SET_ID
        AND  FFVS.flex_value_set_name = 'CCL_ACCOUNTS'
        AND  b.segment2 = FFVV.flex_value) local_acct_description
      ,(SELECT REPLACE(SUBSTR(FFVV.description,1,50),',',';') TP_Desc
        FROM fnd_flex_values_vl FFVV,
             FND_FLEX_VALUE_SETS FFVS
        WHERE FFVV.FLEX_VALUE_SET_ID = FFVS.FLEX_VALUE_SET_ID
        AND  FFVS.flex_value_set_name = 'CCL_TRADING_PARTNERS'
        AND  b.segment3 = FFVV.flex_value) local_ibu_description
      ,(SELECT REPLACE(SUBSTR(FFVV.description,1,50),',',';')
        FROM fnd_flex_values_vl FFVV,
             FND_FLEX_VALUE_SETS FFVS
        WHERE FFVV.FLEX_VALUE_SET_ID = FFVS.FLEX_VALUE_SET_ID
        AND  FFVS.flex_value_set_name = 'CCL_COMPANY_CODES'
        AND  b.segment1 = FFVV.flex_value) local_bu_description
      ,NULL analysis
      ,NULL type
      ,:P_RUN_TYPE run_type
      ,(NVL(begin_balance_dr,0)- NVL(begin_balance_cr,0) + NVL(period_net_dr,0) - NVL(period_net_cr,0)) amount
FROM GL_BALANCES a
    ,GL_CODE_COMBINATIONS b
    ,GL_LEDGERS c
WHERE a.code_combination_id = b.code_combination_id
AND a.ledger_id = c.ledger_id
AND c.ledger_category_code = 'ALC'      -- reporting ledger
AND :P_SENDER_ID = 'CC46'
-- Change to extract only for 'JP_USD_RPT'. Jun 01
AND c.name = 'JP_USD_RPT'
AND c.currency_code = 'USD'   -- with functional currency as USD
AND a.currency_code = c.currency_code  -- only USD balances
-- Change to select only records that belong to JPN0 or JPN1 BU. Jun 01
AND b.segment1 IN ('JPN0','JPN1') 
-- End of changes  17 Sep
AND b.segment9 <> 'S'  -- exclude statutory adjustments
AND NVL(begin_balance_dr,0)- NVL(begin_balance_cr,0) + NVL(period_net_dr,0) - NVL(period_net_cr,0) <> 0
-- Changed to use latest open period if Period Name is not passed. 09 Sep.
--AND a.period_name = :P_PERIOD
AND ( (a.period_name = :P_PERIOD AND :P_PERIOD IS NOT NULL) OR
      (a.period_name = c.latest_opened_period_name AND :P_PERIOD IS NULL)
    )
UNION ALL
--GED
--
SELECT a.period_name
      ,b.segment1 company_code
      ,(SELECT parent_PK1_VALUE
          FROM fnd_tree_node ftn
              ,fnd_tree_version_vl ftv
         WHERE 1=1
           AND ftn.tree_Code =  'ACCOUNT MARS UNPUBLISHED'
           AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
           AND ftv.tree_Code = ftn.tree_code
           AND ftv.tree_structure_code = ftn.tree_structure_code
           AND ftv.tree_version_name = 'CURRENT'
           AND ftn.tree_version_id = ftv.tree_version_id
           AND pk1_start_value = b.segment2)  mars_account
      ,b.segment2 local_account
      ,b.segment3 trading_partner
      ,a.currency_code
      ,:P_SENDER_ID  sender_id
      ,'Fusion' local_sender_id
      ,'RECON' amount_type
      ,'USDRQ' mars_amount_type
      ,(SELECT TO_CHAR(Start_Date,'MM')||'15'||TO_CHAR(Start_Date,'YYYY')
        FROM gl_periods
        WHERE period_name = a.period_name
        AND period_set_name = c.period_set_name) effective_date
      ,(SELECT SUBSTR(parent_PK1_VALUE,1)
          FROM fnd_tree_node ftn
              ,fnd_tree_version_vl ftv
         WHERE 1=1
           AND ftn.tree_Code =  'COMPANY MARS UNPUBLISHED'
           AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
           AND ftv.tree_Code = ftn.tree_code
           AND ftv.tree_structure_code = ftn.tree_structure_code
           AND ftv.TREE_VERSION_NAME = 'CURRENT'
           AND ftn.TREE_VERSION_ID = ftv.TREE_VERSION_ID
           AND pk1_start_value = b.segment1) business_unit
      ,b.segment1 local_bu
      ,(SELECT SUBSTR(parent_PK1_VALUE,1) -- Changed back from position 4 as the underscores are removed. 19 Oct
          FROM fnd_tree_node ftn
              ,fnd_tree_version_vl ftv
         WHERE 1=1
           AND ftn.tree_Code =  'Company LE'
           AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
           AND ftv.tree_Code = ftn.tree_code
           AND ftv.tree_structure_code = ftn.tree_structure_code
           AND ftv.TREE_VERSION_NAME = 'CURRENT'
           AND ftn.TREE_VERSION_ID = ftv.TREE_VERSION_ID
           AND pk1_start_value = b.segment1) legal_entity
        ,NVL((SELECT 
        CASE ftn.parent_pk1_value 
           WHEN 'N' THEN '000000' 
            ELSE ( SELECT  parent_PK1_VALUE
                     FROM  fnd_tree_node ftn
                          ,fnd_tree_version_vl ftv
                    WHERE  1=1
                      AND  ftn.tree_Code           = 'TP MARS IBU UNPUBLISHED'
                      AND  ftn.tree_structure_code = 'GL_ACCT_FLEX'
                      AND  ftv.tree_Code           = ftn.tree_code
                      AND  ftv.tree_structure_code = ftn.tree_structure_code
                      AND  ftv.TREE_VERSION_NAME   = 'CURRENT'
                      AND  ftn.TREE_VERSION_ID     = ftv.TREE_VERSION_ID
                      AND  pk1_start_value         = b.segment3 )
            END   
         FROM   fnd_tree_node ftn
               ,fnd_tree_version_vl ftv
         WHERE 1=1
           AND ftn.tree_Code           = 'ACCOUNT MARS IME UNPUBLISHED'
           AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
           AND ftv.tree_Code           = ftn.tree_code
           AND ftv.tree_structure_code = ftn.tree_structure_code
           AND ftv.TREE_VERSION_NAME   = 'CURRENT'
           AND ftn.TREE_VERSION_ID     = ftv.TREE_VERSION_ID
           AND pk1_start_value         = b.segment2),'000000') "IBU" ,
         NVL((SELECT 
        CASE ftn.parent_pk1_value 
           WHEN 'N' THEN '000000' 
            ELSE ( SELECT  parent_PK1_VALUE
                     FROM  fnd_tree_node ftn
                          ,fnd_tree_version_vl ftv
                    WHERE  1=1
                      AND  ftn.tree_Code           = 'TP MARS ILE UNPUBLISHED'
                      AND  ftn.tree_structure_code = 'GL_ACCT_FLEX'
                      AND  ftv.tree_Code           = ftn.tree_code
                      AND  ftv.tree_structure_code = ftn.tree_structure_code
                      AND  ftv.TREE_VERSION_NAME   = 'CURRENT'
                      AND  ftn.TREE_VERSION_ID     = ftv.TREE_VERSION_ID
                      AND  pk1_start_value         = b.segment3 )
            END   
         FROM   fnd_tree_node ftn
               ,fnd_tree_version_vl ftv
         WHERE 1=1
           AND ftn.tree_Code           = 'ACCOUNT MARS ILE UNPUBLISHED'
           AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
           AND ftv.tree_Code           = ftn.tree_code
           AND ftv.tree_structure_code = ftn.tree_structure_code
           AND ftv.TREE_VERSION_NAME   = 'CURRENT'
           AND ftn.TREE_VERSION_ID     = ftv.TREE_VERSION_ID
           AND pk1_start_value         = b.segment2),'000000') "ILE" 
      ,(SELECT REPLACE(SUBSTR(FFVV.description,1,50),',',';')
        FROM fnd_flex_values_vl FFVV,
             FND_FLEX_VALUE_SETS FFVS
        WHERE FFVV.FLEX_VALUE_SET_ID = FFVS.FLEX_VALUE_SET_ID
        AND  FFVS.flex_value_set_name = 'CCL_ACCOUNTS'
        AND  b.segment2 = FFVV.flex_value) local_acct_description
      ,(SELECT REPLACE(SUBSTR(FFVV.description,1,50),',',';') TP_Desc
        FROM fnd_flex_values_vl FFVV,
             FND_FLEX_VALUE_SETS FFVS
        WHERE FFVV.FLEX_VALUE_SET_ID = FFVS.FLEX_VALUE_SET_ID
        AND  FFVS.flex_value_set_name = 'CCL_TRADING_PARTNERS'
        AND  b.segment3 = FFVV.flex_value) local_ibu_description
      ,(SELECT REPLACE(SUBSTR(FFVV.description,1,50),',',';')
        FROM fnd_flex_values_vl FFVV,
             FND_FLEX_VALUE_SETS FFVS
        WHERE FFVV.FLEX_VALUE_SET_ID = FFVS.FLEX_VALUE_SET_ID
        AND  FFVS.flex_value_set_name = 'CCL_COMPANY_CODES'
        AND  b.segment1 = FFVV.flex_value) local_bu_description
      ,NULL analysis
      ,NULL type
      ,:P_RUN_TYPE run_type
      ,(NVL(begin_balance_dr,0)- NVL(begin_balance_cr,0) + NVL(period_net_dr,0) - NVL(period_net_cr,0)) amount
FROM gl_balances a
    ,gl_code_combinations b
    ,gl_ledgers c
WHERE a.code_combination_id = b.code_combination_id
AND a.ledger_id             = c.ledger_id
AND c.ledger_category_code  = 'ALC'      -- reporting ledger
AND c.name LIKE '%USD_RPT'
/*
AND c.name IN('US_USD_RPT', 'CA_USD_RPT','FR_USD_RPT','NL_USD_RPT','AE_USD_RPT', 'BR_USD_RPT' , 'CN_USD_RPT' , 'ES_USD_RPT' , 'GB_USD_RPT' , 
'IN_USD_RPT' , 'MT_USD_RPT' , 'MX_USD_RPT',
'SG_USD_RPT','ZA_USD_RPT','AU_USD_RPT','DE_USD_RPT','ZA_USD_RPT','JP_USD_RPT','KR_USD_RPT') */
AND :P_SENDER_ID            = 'CC74'
AND c.currency_code         = 'USD'   -- with functional currency as USD
AND a.currency_code         = c.currency_code  -- only USD balances
AND EXISTS 
              (SELECT 'X'
                 FROM fnd_tree_node ftn
                     ,fnd_tree_version_vl ftv
                WHERE 1=1
                  AND ftn.tree_code           =  'COMPANY MARS UNPUBLISHED'
                  AND ftn.tree_structure_code =  'GL_ACCT_FLEX'
                  AND ftv.tree_Code           =  ftn.tree_code
                  AND ftv.tree_structure_code =  ftn.tree_structure_code
                  AND ftv.tree_version_name   =  'CURRENT'
                  AND ftn.tree_version_id     =  ftv.tree_version_id
                  AND pk1_start_value         =  b.segment1
                  AND parent_pk1_value        =  'DIGTOT' )
AND b.segment9 <> 'S'  -- exclude statutory adjustments
AND NVL(begin_balance_dr,0)- NVL(begin_balance_cr,0) + NVL(period_net_dr,0) - NVL(period_net_cr,0) <> 0
AND ( (a.period_name = :P_PERIOD AND :P_PERIOD IS NOT NULL) OR
      (a.period_name = c.latest_opened_period_name AND :P_PERIOD IS NULL)
    )