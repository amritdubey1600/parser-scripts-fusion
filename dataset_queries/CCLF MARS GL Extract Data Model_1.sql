--start of funcm
SELECT a.period_name
      ,b.segment1
      ,b.segment2
      ,b.segment3
      ,a.currency_code
      ,'CC30' sender_id
      ,:P_AMOUNT_TYPE amount_type
      ,TO_CHAR(d.Start_Date,'MM')||'15'||TO_CHAR(d.Start_Date,'YYYY') effective_date
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
               AND pk1_start_value = b.segment1) "BUSINESS_UNIT"
             , (SELECT SUBSTR(parent_PK1_VALUE,1) -- Changed back from position 4 as the underscores are removed. 19 Oct
               FROM fnd_tree_node ftn
                   ,FND_TREE_VERSION_VL ftv
               WHERE 1=1
               AND ftn.tree_Code =  'Company LE'
               AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
               AND ftv.tree_Code = ftn.tree_code
               AND ftv.tree_structure_code = ftn.tree_structure_code
               AND ftv.TREE_VERSION_NAME = 'CURRENT'
               AND ftn.TREE_VERSION_ID = ftv.TREE_VERSION_ID
               AND pk1_start_value = b.segment1) "LEGAL_ENTITY"
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
               AND pk1_start_value = b.segment2)  "MARS_ACCOUNT"
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
               AND pk1_start_value = b.segment3)  IBU
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
        AND pk1_start_value = b.segment3)  "ILE"*/ -- Commented
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
		,NULL analysis
      ,NULL type
     ,:P_RUN_TYPE run_type
     ,SUM(NVL(begin_balance_dr,0)- NVL(begin_balance_cr,0) + NVL(period_net_dr,0) - NVL(period_net_cr,0)) amount
FROM GL_BALANCES a
    ,GL_CODE_COMBINATIONS b
    ,GL_LEDGERS c
    ,GL_PERIODS d
WHERE a.code_combination_id = b.code_combination_id
AND a.ledger_id = c.ledger_id
--AND c.short_name LIKE '%_PRM'    -- all primary books but not statutory books
AND a.currency_code = c.currency_code -- functional currency
-- Included the below conditions to use the Account Hierarchy for the Currency. 31 Aug
AND 'CAD' = (SELECT SUBSTR(parent_PK1_VALUE,4)
               FROM fnd_tree_node ftn
                   ,FND_TREE_VERSION_VL ftv
               WHERE 1=1
               AND ftn.tree_Code =  'Company FCY'
               AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
               AND ftv.tree_Code = ftn.tree_code
               AND ftv.tree_structure_code = ftn.tree_structure_code
               AND ftv.TREE_VERSION_NAME = 'CURRENT'
               AND ftn.TREE_VERSION_ID = ftv.TREE_VERSION_ID
               AND pk1_start_value = b.segment1)
AND c.name = 'CA_CAD_PRM'
-- End of changes 31 Aug
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
AND segment9 <> 'S'              -- exclude statutory adjustments
AND :P_AMOUNT_TYPE = 'FUNCM'
and :P_SENDER_ID =  'CC30'
AND d.period_name = a.period_name
AND d.period_set_name = c.period_set_name
-- Changed to use latest open period if Period Name is not passed. 09 Sep.
--AND a.period_name = :P_PERIOD
AND ( (a.period_name = :P_PERIOD AND :P_PERIOD IS NOT NULL) OR
      (a.period_name = c.latest_opened_period_name AND :P_PERIOD IS NULL)
    )
--
GROUP by a.period_name, segment1, segment2, segment3
        ,a.currency_code, d.start_date
HAVING SUM(NVL(begin_balance_dr,0)- NVL(begin_balance_cr,0) + NVL(period_net_dr,0) - NVL(period_net_cr,0)) <> 0        
UNION
SELECT a.period_name
      ,b.segment1
      ,b.segment2
      ,b.segment3
      ,a.currency_code
      ,'CC30' sender_id
      ,:P_AMOUNT_TYPE amount_type
      ,TO_CHAR(d.Start_Date,'MM')||'15'||TO_CHAR(d.Start_Date,'YYYY') effective_date
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
               AND pk1_start_value = b.segment1) "BUSINESS_UNIT"
             , (SELECT SUBSTR(parent_PK1_VALUE,1) -- Changed back from position 4 as the underscores are removed. 19 Oct
               FROM fnd_tree_node ftn
                   ,FND_TREE_VERSION_VL ftv
               WHERE 1=1
               AND ftn.tree_Code =  'Company LE'
               AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
               AND ftv.tree_Code = ftn.tree_code
               AND ftv.tree_structure_code = ftn.tree_structure_code
               AND ftv.TREE_VERSION_NAME = 'CURRENT'
               AND ftn.TREE_VERSION_ID = ftv.TREE_VERSION_ID
               AND pk1_start_value = b.segment1) "LEGAL_ENTITY"
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
               AND pk1_start_value = b.segment2)  "MARS_ACCOUNT"
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
               AND pk1_start_value = b.segment3)  IBU
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
        AND pk1_start_value = b.segment3)  "ILE" */ -- IME ILE
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
		,NULL analysis
      ,NULL type
     ,:P_RUN_TYPE run_type
     ,DECODE(a.currency_code,c.currency_code,SUM(NVL(begin_balance_dr_beq,0) - NVL(begin_balance_cr_beq,0)
              + NVL(period_net_dr_beq,0) - NVL(period_net_cr_beq,0)),
              SUM(NVL(begin_balance_dr,0)- NVL(begin_balance_cr,0) + NVL(period_net_dr,0) - NVL(period_net_cr,0))) amount
FROM GL_BALANCES a
    ,GL_CODE_COMBINATIONS b
    ,GL_LEDGERS c
    ,GL_PERIODS d
WHERE a.code_combination_id = b.code_combination_id
AND a.ledger_id = c.ledger_id
AND c.ledger_category_code = 'ALC'      -- ALC for Reporting ledger
AND c.currency_code = 'USD'    -- Include all USD functional currency Reporting books
-- Included the below conditions to use the Account Hierarchy for the Currency. 31 Aug
AND 'USD' = (SELECT SUBSTR(parent_PK1_VALUE,4)
               FROM fnd_tree_node ftn
                   ,FND_TREE_VERSION_VL ftv
               WHERE 1=1
               AND ftn.tree_Code =  'Company FCY'
               AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
               AND ftv.tree_Code = ftn.tree_code
               AND ftv.tree_structure_code = ftn.tree_structure_code
               AND ftv.TREE_VERSION_NAME = 'CURRENT'
               AND ftn.TREE_VERSION_ID = ftv.TREE_VERSION_ID
               AND pk1_start_value = b.segment1)
AND c.name = 'CA_USD_FCY'
-- End of changes 31 Aug
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
AND segment9 <> 'S'  -- exclude statutory adjustments
AND :P_AMOUNT_TYPE = 'FUNCM'
and :P_SENDER_ID =  'CC30'
AND d.period_name = a.period_name
AND d.period_set_name = c.period_set_name
-- Changed to use latest open period if Period Name is not passed. 09 Sep.
--AND a.period_name = :P_PERIOD
AND ( (a.period_name = :P_PERIOD AND :P_PERIOD IS NOT NULL) OR
      (a.period_name = c.latest_opened_period_name AND :P_PERIOD IS NULL)
    )
--
GROUP by a.period_name, segment1, segment2, segment3
        ,a.currency_code ,c.currency_code, d.start_date
HAVING SUM(DECODE(a.currency_code,c.currency_code, (NVL(begin_balance_dr_beq,0) - NVL(begin_balance_cr_beq,0)
              + NVL(period_net_dr_beq,0) - NVL(period_net_cr_beq,0)),
              (NVL(begin_balance_dr,0)- NVL(begin_balance_cr,0) + NVL(period_net_dr,0) - NVL(period_net_cr,0)))) <> 0 
--end of funcm
--start of orinm
UNION
SELECT a.period_name
      ,b.segment1
      ,b.segment2
      ,b.segment3
      ,a.currency_code
      ,'CC30' sender_id
      ,:P_AMOUNT_TYPE amount_type
      ,TO_CHAR(d.Start_Date,'MM')||'15'||TO_CHAR(d.Start_Date,'YYYY') effective_date
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
               AND pk1_start_value = b.segment1) "BUSINESS_UNIT"
             , (SELECT SUBSTR(parent_PK1_VALUE,1) -- Changed back from position 4 as the underscores are removed. 19 Oct
               FROM fnd_tree_node ftn
                   ,FND_TREE_VERSION_VL ftv
               WHERE 1=1
               AND ftn.tree_Code =  'Company LE'
               AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
               AND ftv.tree_Code = ftn.tree_code
               AND ftv.tree_structure_code = ftn.tree_structure_code
               AND ftv.TREE_VERSION_NAME = 'CURRENT'
               AND ftn.TREE_VERSION_ID = ftv.TREE_VERSION_ID
               AND pk1_start_value = b.segment1) "LEGAL_ENTITY"
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
               AND pk1_start_value = b.segment2)  "MARS_ACCOUNT"
            /* ,(SELECT parent_PK1_VALUE
               FROM fnd_tree_node ftn
                   ,FND_TREE_VERSION_VL ftv
               WHERE 1=1
               AND ftn.tree_Code =  'TP MARS IBU UNPUBLISHED'
               AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
               AND ftv.tree_Code = ftn.tree_code
               AND ftv.tree_structure_code = ftn.tree_structure_code
               AND ftv.TREE_VERSION_NAME = 'CURRENT'
               AND ftn.TREE_VERSION_ID = ftv.TREE_VERSION_ID
               AND pk1_start_value = b.segment3)  IBU
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
        AND pk1_start_value = b.segment3)  "ILE" */ -- Commented 
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
		,NULL analysis
      ,NULL type
     ,:P_RUN_TYPE run_type
     ,DECODE(a.currency_code,c.currency_code,SUM(NVL(begin_balance_dr_beq,0) - NVL(begin_balance_cr_beq,0)
              + NVL(period_net_dr_beq,0) - NVL(period_net_cr_beq,0)),
              SUM(NVL(begin_balance_dr,0)- NVL(begin_balance_cr,0) + NVL(period_net_dr,0) - NVL(period_net_cr,0))) amount
FROM GL_BALANCES a
    ,GL_CODE_COMBINATIONS b
    ,GL_LEDGERS c
    ,GL_PERIODS d
WHERE a.code_combination_id = b.code_combination_id
AND a.ledger_id = c.ledger_id
AND c.ledger_category_code = 'ALC'      -- ALC for Reporting ledger
-- Change to extract only for CA_USD_RPT. 18 Sep
AND c.name = 'CA_USD_RPT'
--
AND c.currency_code = 'USD'    -- Include all USD functional currency Reporting books
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
AND segment9 <> 'S' -- exclude Statutory Adjustment
AND :P_AMOUNT_TYPE = 'ORINM'
and :P_SENDER_ID =  'CC30'
AND d.period_name = a.period_name
AND d.period_set_name = c.period_set_name
-- Changed to use latest open period if Period Name is not passed. 09 Sep.
--AND a.period_name = :P_PERIOD
AND ( (a.period_name = :P_PERIOD AND :P_PERIOD IS NOT NULL) OR
      (a.period_name = c.latest_opened_period_name AND :P_PERIOD IS NULL)
    )
--
GROUP by a.period_name, segment1, segment2, segment3
        ,a.currency_code, c.currency_code, d.start_date
HAVING SUM(DECODE(a.currency_code,c.currency_code, (NVL(begin_balance_dr_beq,0) - NVL(begin_balance_cr_beq,0)
              + NVL(period_net_dr_beq,0) - NVL(period_net_cr_beq,0)),
              (NVL(begin_balance_dr,0)- NVL(begin_balance_cr,0) + NVL(period_net_dr,0) - NVL(period_net_cr,0)))) <> 0
--end of orinm
--start of usdrm usdrq
UNION
SELECT a.period_name
      ,b.segment1
      ,b.segment2
      ,b.segment3
      ,a.currency_code
      ,'CC30' sender_id
      ,:P_AMOUNT_TYPE amount_type
      ,TO_CHAR(d.Start_Date,'MM')||'15'||TO_CHAR(d.Start_Date,'YYYY') effective_date
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
        AND pk1_start_value = b.segment1) "BUSINESS_UNIT" 
        , (SELECT SUBSTR(parent_PK1_VALUE,1) -- Changed back from position 4 as the underscores are removed. 19 Oct
        FROM fnd_tree_node ftn
            ,FND_TREE_VERSION_VL ftv
        WHERE 1=1
        AND ftn.tree_Code =  'Company LE'
        AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
        AND ftv.tree_Code = ftn.tree_code
        AND ftv.tree_structure_code = ftn.tree_structure_code
        AND ftv.TREE_VERSION_NAME = 'CURRENT'
        AND ftn.TREE_VERSION_ID = ftv.TREE_VERSION_ID
        AND pk1_start_value = b.segment1) "LEGAL_ENTITY" 
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
        AND pk1_start_value = b.segment2)  "MARS_ACCOUNT" 
       /* ,(SELECT parent_PK1_VALUE
        FROM fnd_tree_node ftn
            ,FND_TREE_VERSION_VL ftv
        WHERE 1=1
        AND ftn.tree_Code =  'TP MARS IBU UNPUBLISHED'
        AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
        AND ftv.tree_Code = ftn.tree_code
        AND ftv.tree_structure_code = ftn.tree_structure_code
        AND ftv.TREE_VERSION_NAME = 'CURRENT'
        AND ftn.TREE_VERSION_ID = ftv.TREE_VERSION_ID
        AND pk1_start_value = b.segment3)  "IBU"
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
        AND pk1_start_value = b.segment3)  "ILE" */
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
      ,NULL analysis
      ,NULL type
     ,:P_RUN_TYPE run_type
      ,SUM(NVL(a.begin_balance_dr,0)- NVL(a.begin_balance_cr,0) + NVL(a.period_net_dr,0) - NVL(a.period_net_cr,0)) amount
FROM GL_BALANCES a
    ,GL_CODE_COMBINATIONS b
    ,GL_LEDGERS c
    ,GL_PERIODS d
WHERE a.code_combination_id = b.code_combination_id
AND a.ledger_id = c.ledger_id
AND c.ledger_category_code = 'ALC'      -- reporting ledger
-- Change to extract only for CA_USD_RPT. 18 Sep
AND c.name = 'CA_USD_RPT'
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
AND :P_AMOUNT_TYPE IN ('USDRM','USDRQ')
and :P_SENDER_ID =  'CC30'
AND d.period_name = a.period_name
AND d.period_set_name = c.period_set_name
-- Changed to use latest open period if Period Name is not passed. 09 Sep.
--AND a.period_name = :P_PERIOD
AND ( (a.period_name = :P_PERIOD AND :P_PERIOD IS NOT NULL) OR
      (a.period_name = c.latest_opened_period_name AND :P_PERIOD IS NULL)
    )
--
GROUP by a.period_name, segment1, segment2, segment3
        ,a.currency_code, d.start_date
HAVING SUM(NVL(begin_balance_dr,0)- NVL(begin_balance_cr,0) + NVL(period_net_dr,0) - NVL(period_net_cr,0)) <> 0
union
--start of funcm
SELECT a.period_name
      ,b.segment1
      ,b.segment2
      ,b.segment3
      ,a.currency_code
      ,'CC46' sender_id
      ,:P_AMOUNT_TYPE amount_type
      ,TO_CHAR(d.Start_Date,'MM')||'15'||TO_CHAR(d.Start_Date,'YYYY') effective_date
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
               AND pk1_start_value = b.segment1) "BUSINESS_UNIT"
             , (SELECT SUBSTR(parent_PK1_VALUE,1) -- Changed back from position 4 as the underscores are removed. 19 Oct
               FROM fnd_tree_node ftn
                   ,FND_TREE_VERSION_VL ftv
               WHERE 1=1
               AND ftn.tree_Code =  'Company LE'
               AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
               AND ftv.tree_Code = ftn.tree_code
               AND ftv.tree_structure_code = ftn.tree_structure_code
               AND ftv.TREE_VERSION_NAME = 'CURRENT'
               AND ftn.TREE_VERSION_ID = ftv.TREE_VERSION_ID
               AND pk1_start_value = b.segment1) "LEGAL_ENTITY"
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
               AND pk1_start_value = b.segment2)  "MARS_ACCOUNT"
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
      ,NULL analysis
      ,NULL type
     ,:P_RUN_TYPE run_type
     ,SUM(NVL(begin_balance_dr,0)- NVL(begin_balance_cr,0) + NVL(period_net_dr,0) - NVL(period_net_cr,0)) amount
FROM GL_BALANCES a
    ,GL_CODE_COMBINATIONS b
    ,GL_LEDGERS c
    ,GL_PERIODS d
WHERE a.code_combination_id = b.code_combination_id
AND a.ledger_id = c.ledger_id
AND a.currency_code = c.currency_code -- functional currency
AND c.name IN ('JP_JPY_PRM')
AND b.segment1 IN ('JPN0','JPN1') 
AND segment9 <> 'S'              -- exclude statutory adjustments
AND :P_AMOUNT_TYPE = 'FUNCM'
and :P_SENDER_ID =  'CC46'
AND d.period_name = a.period_name
AND d.period_set_name = c.period_set_name
AND ( (a.period_name = :P_PERIOD AND :P_PERIOD IS NOT NULL) OR
      (a.period_name = c.latest_opened_period_name AND :P_PERIOD IS NULL)
    )
--
GROUP by a.period_name, segment1, segment2, segment3
        ,a.currency_code, d.start_date
HAVING SUM(NVL(begin_balance_dr,0)- NVL(begin_balance_cr,0) + NVL(period_net_dr,0) - NVL(period_net_cr,0)) <> 0        
--end of funcm
--start of orinm
UNION
SELECT a.period_name
      ,b.segment1
      ,b.segment2
      ,b.segment3
      ,a.currency_code
      ,'CC46' sender_id
      ,:P_AMOUNT_TYPE amount_type
      ,TO_CHAR(d.Start_Date,'MM')||'15'||TO_CHAR(d.Start_Date,'YYYY') effective_date
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
               AND pk1_start_value = b.segment1) "BUSINESS_UNIT"
             , (SELECT SUBSTR(parent_PK1_VALUE,1) -- Changed back from position 4 as the underscores are removed. 19 Oct
               FROM fnd_tree_node ftn
                   ,FND_TREE_VERSION_VL ftv
               WHERE 1=1
               AND ftn.tree_Code =  'Company LE'
               AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
               AND ftv.tree_Code = ftn.tree_code
               AND ftv.tree_structure_code = ftn.tree_structure_code
               AND ftv.TREE_VERSION_NAME = 'CURRENT'
               AND ftn.TREE_VERSION_ID = ftv.TREE_VERSION_ID
               AND pk1_start_value = b.segment1) "LEGAL_ENTITY"
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
               AND pk1_start_value = b.segment2)  "MARS_ACCOUNT"
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
      ,NULL analysis
      ,NULL type
     ,:P_RUN_TYPE run_type
     ,DECODE(a.currency_code,c.currency_code,SUM(NVL(begin_balance_dr_beq,0) - NVL(begin_balance_cr_beq,0)
              + NVL(period_net_dr_beq,0) - NVL(period_net_cr_beq,0)),
              SUM(NVL(begin_balance_dr,0)- NVL(begin_balance_cr,0) + NVL(period_net_dr,0) - NVL(period_net_cr,0))) amount
FROM GL_BALANCES a
    ,GL_CODE_COMBINATIONS b
    ,GL_LEDGERS c
    ,GL_PERIODS d
WHERE a.code_combination_id = b.code_combination_id
AND a.ledger_id = c.ledger_id
AND c.ledger_category_code = 'ALC'      -- ALC for Reporting ledger
AND c.name IN('JP_USD_RPT')
AND c.currency_code = 'USD'    -- Include all USD functional currency Reporting books
AND b.segment1 IN ('JPN0','JPN1') 
AND segment9 <> 'S' -- exclude Statutory Adjustment
AND :P_AMOUNT_TYPE = 'ORINM'
and :P_SENDER_ID =  'CC46'
AND d.period_name = a.period_name
AND d.period_set_name = c.period_set_name
--AND a.period_name = :P_PERIOD
AND ( (a.period_name = :P_PERIOD AND :P_PERIOD IS NOT NULL) OR
      (a.period_name = c.latest_opened_period_name AND :P_PERIOD IS NULL)
    ) 
--
GROUP by a.period_name, segment1, segment2, segment3
        ,a.currency_code, c.currency_code, d.start_date
HAVING SUM(DECODE(a.currency_code,c.currency_code, (NVL(begin_balance_dr_beq,0) - NVL(begin_balance_cr_beq,0)
              + NVL(period_net_dr_beq,0) - NVL(period_net_cr_beq,0)),
              (NVL(begin_balance_dr,0)- NVL(begin_balance_cr,0) + NVL(period_net_dr,0) - NVL(period_net_cr,0)))) <> 0
--end of orinm
--start of usdrm usdrq
UNION
SELECT a.period_name
      ,b.segment1
      ,b.segment2
      ,b.segment3
      ,a.currency_code
      ,'CC46' sender_id
      ,:P_AMOUNT_TYPE amount_type
      ,TO_CHAR(d.Start_Date,'MM')||'15'||TO_CHAR(d.Start_Date,'YYYY') effective_date
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
        AND pk1_start_value = b.segment1) "BUSINESS_UNIT" 
        , (SELECT SUBSTR(parent_PK1_VALUE,1) -- Changed back from position 4 as the underscores are removed. 19 Oct
        FROM fnd_tree_node ftn
            ,FND_TREE_VERSION_VL ftv
        WHERE 1=1
        AND ftn.tree_Code =  'Company LE'
        AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
        AND ftv.tree_Code = ftn.tree_code
        AND ftv.tree_structure_code = ftn.tree_structure_code
        AND ftv.TREE_VERSION_NAME = 'CURRENT'
        AND ftn.TREE_VERSION_ID = ftv.TREE_VERSION_ID
        AND pk1_start_value = b.segment1) "LEGAL_ENTITY" 
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
        AND pk1_start_value = b.segment2)  "MARS_ACCOUNT" 
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
      ,NULL analysis
      ,NULL type
     ,:P_RUN_TYPE run_type
      ,SUM(NVL(a.begin_balance_dr,0)- NVL(a.begin_balance_cr,0) + NVL(a.period_net_dr,0) - NVL(a.period_net_cr,0)) amount
FROM GL_BALANCES a
    ,GL_CODE_COMBINATIONS b
    ,GL_LEDGERS c
    ,GL_PERIODS d
WHERE a.code_combination_id = b.code_combination_id
AND a.ledger_id = c.ledger_id
AND c.ledger_category_code = 'ALC'      -- reporting ledger
AND c.name IN('JP_USD_RPT')
AND c.currency_code = 'USD'   -- with functional currency as USD
AND a.currency_code = c.currency_code  -- only USD balances
AND b.segment1 IN  ('JPN0','JPN1') 
AND b.segment9 <> 'S'  -- exclude statutory adjustments
AND :P_AMOUNT_TYPE IN ('USDRM','USDRQ')
and :P_SENDER_ID =  'CC46'
AND d.period_name = a.period_name
AND d.period_set_name = c.period_set_name
--AND a.period_name = :P_PERIOD
AND ( (a.period_name = :P_PERIOD AND :P_PERIOD IS NOT NULL) OR
      (a.period_name = c.latest_opened_period_name AND :P_PERIOD IS NULL)
    ) 
--
GROUP by a.period_name, segment1, segment2, segment3
        ,a.currency_code, d.start_date
HAVING SUM(NVL(begin_balance_dr,0)- NVL(begin_balance_cr,0) + NVL(period_net_dr,0) - NVL(period_net_cr,0)) <> 0
UNION ALL
--GED CANADA
--start of FUNCM
SELECT a.period_name
      ,b.segment1
      ,b.segment2
      ,b.segment3
      ,a.currency_code
      ,'CC74' sender_id
      ,:P_AMOUNT_TYPE amount_type
      ,TO_CHAR(d.Start_Date,'MM')||'15'||TO_CHAR(d.Start_Date,'YYYY') effective_date
      ,(SELECT SUBSTR(parent_PK1_VALUE,1)
          FROM fnd_tree_node ftn
              ,fnd_tree_version_vl ftv
         WHERE 1=1
           AND ftn.tree_Code             = 'COMPANY MARS UNPUBLISHED' -- Changed the hierarchy. 03 Sep
           AND ftn.tree_structure_code   = 'GL_ACCT_FLEX'
           AND ftv.tree_Code             = ftn.tree_code
           AND ftv.tree_structure_code   = ftn.tree_structure_code
           AND ftv.tree_version_name     = 'CURRENT'
           AND ftn.tree_version_id       = ftv.tree_version_id
           AND pk1_start_value           = b.segment1) "BUSINESS_UNIT"
       , (SELECT SUBSTR(parent_pk1_value,1) -- Changed back from position 4 as the underscores are removed. 19 Oct
            FROM fnd_tree_node ftn
                 ,fnd_tree_version_vl ftv
           WHERE 1=1
             AND ftn.tree_Code           = 'Company LE'
             AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
             AND ftv.tree_Code           = ftn.tree_code
             AND ftv.tree_structure_code = ftn.tree_structure_code
             AND ftv.tree_version_name   = 'CURRENT'
             AND ftn.tree_version_id     = ftv.tree_version_id
             AND pk1_start_value         = b.segment1) "LEGAL_ENTITY"
       ,(SELECT parent_pk1_value
           FROM fnd_tree_node ftn
               ,fnd_tree_version_vl ftv
          WHERE 1=1
            AND ftn.tree_Code            = 'ACCOUNT MARS UNPUBLISHED'
            AND ftn.tree_structure_code  = 'GL_ACCT_FLEX'
            AND ftv.tree_Code            = ftn.tree_code
            AND ftv.tree_structure_code  = ftn.tree_structure_code
            AND ftv.tree_version_name    = 'CURRENT'
            AND ftn.tree_version_id      = ftv.tree_version_id
            AND pk1_start_value          = b.segment2)  "MARS_ACCOUNT"
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
                      AND  ftv.tree_version_name   = 'CURRENT'
                      AND  ftn.tree_version_id     = ftv.tree_version_id
                      AND  pk1_start_value         = b.segment3 )
            END   
         FROM   fnd_tree_node ftn
               ,fnd_tree_version_vl ftv
         WHERE 1=1
           AND ftn.tree_Code           = 'ACCOUNT MARS IME UNPUBLISHED'
           AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
           AND ftv.tree_Code           = ftn.tree_code
           AND ftv.tree_structure_code = ftn.tree_structure_code
           AND ftv.tree_version_name   = 'CURRENT'
           AND ftn.tree_version_id     = ftv.tree_version_id
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
                      AND  ftv.tree_version_name   = 'CURRENT'
                      AND  ftn.tree_version_id     = ftv.TREE_VERSION_ID
                      AND  pk1_start_value         = b.segment3 )
            END   
         FROM   fnd_tree_node ftn
               ,fnd_tree_version_vl ftv
         WHERE 1=1
           AND ftn.tree_Code           = 'ACCOUNT MARS ILE UNPUBLISHED'
           AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
           AND ftv.tree_Code           = ftn.tree_code
           AND ftv.tree_structure_code = ftn.tree_structure_code
           AND ftv.tree_version_name   = 'CURRENT'
           AND ftn.tree_version_id     = ftv.TREE_VERSION_ID
           AND pk1_start_value         = b.segment2),'000000') "ILE" 
      ,NULL analysis
      ,NULL type
      ,:P_RUN_TYPE run_type
      ,SUM(NVL(begin_balance_dr,0)- NVL(begin_balance_cr,0) + NVL(period_net_dr,0) - NVL(period_net_cr,0)) amount
FROM gl_balances a
    ,gl_code_combinations b
    ,gl_ledgers c
    ,gl_periods d
WHERE a.code_combination_id = b.code_combination_id
  AND a.ledger_id = c.ledger_id
  AND a.currency_code = c.currency_code -- functional currency
  AND 'CAD' = (SELECT SUBSTR(parent_PK1_VALUE,4)
               FROM   fnd_tree_node ftn
                     ,fnd_tree_version_vl ftv
               WHERE 1=1
                 AND ftn.tree_Code           =  'Company FCY'
                 AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
                 AND ftv.tree_Code           = ftn.tree_code
                 AND ftv.tree_structure_code = ftn.tree_structure_code
                 AND ftv.tree_version_name   = 'CURRENT'
                 AND ftn.tree_version_id     = ftv.tree_version_id
                 AND pk1_start_value         = b.segment1)
  AND c.name = 'CA_CAD_PRM'
  AND EXISTS  (SELECT 'X'
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
  AND segment9 <> 'S'              -- exclude statutory adjustments
  AND :P_AMOUNT_TYPE = 'FUNCM'
  AND :P_SENDER_ID =  'CC74'
  AND d.period_name = a.period_name
  AND d.period_set_name = c.period_set_name
  AND ( (a.period_name = :P_PERIOD AND :P_PERIOD IS NOT NULL) OR
        (a.period_name = c.latest_opened_period_name AND :P_PERIOD IS NULL))
  GROUP by a.period_name, segment1, segment2, segment3,a.currency_code, d.start_date
  HAVING SUM(NVL(begin_balance_dr,0)- NVL(begin_balance_cr,0) + NVL(period_net_dr,0) - NVL(period_net_cr,0)) <> 0
UNION
  SELECT a.period_name
        ,b.segment1
      ,b.segment2
      ,b.segment3
      ,a.currency_code
      ,'CC74' sender_id
      ,:P_AMOUNT_TYPE amount_type
      ,TO_CHAR(d.Start_Date,'MM')||'15'||TO_CHAR(d.Start_Date,'YYYY') effective_date
      ,(SELECT SUBSTR(parent_pk1_value,1)
          FROM fnd_tree_node ftn
              ,fnd_tree_version_vl ftv
         WHERE 1=1
           AND ftn.tree_code           =  'COMPANY MARS UNPUBLISHED' -- Changed the hierarchy. 03 Sep
           AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
           AND ftv.tree_Code           = ftn.tree_code
           AND ftv.tree_structure_code = ftn.tree_structure_code
           AND ftv.tree_version_name   = 'CURRENT'
           AND ftn.tree_version_id     = ftv.tree_version_id
           AND pk1_start_value         = b.segment1) "BUSINESS_UNIT"
      , (SELECT SUBSTR(parent_PK1_VALUE,1) -- Changed back from position 4 as the underscores are removed. 19 Oct
           FROM fnd_tree_node ftn
               ,fnd_tree_version_vl ftv
          WHERE 1=1
            AND ftn.tree_Code           =  'Company LE'
            AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
            AND ftv.tree_Code           = ftn.tree_code
            AND ftv.tree_structure_code = ftn.tree_structure_code
            AND ftv.tree_version_name   = 'CURRENT'
            AND ftn.tree_version_id     = ftv.tree_version_id
            AND pk1_start_value         = b.segment1) "LEGAL_ENTITY"
      ,(SELECT parent_pk1_value
          FROM fnd_tree_node ftn
              ,fnd_tree_version_vl ftv
         WHERE 1=1
           AND ftn.tree_Code            =  'ACCOUNT MARS UNPUBLISHED'
           AND ftn.tree_structure_code  = 'GL_ACCT_FLEX'
           AND ftv.tree_Code            = ftn.tree_code
           AND ftv.tree_structure_code  = ftn.tree_structure_code
           AND ftv.tree_version_name    = 'CURRENT'
           AND ftn.tree_version_id      = ftv.tree_version_id
           AND pk1_start_value          = b.segment2)  "MARS_ACCOUNT"
        ,NVL((SELECT 
        CASE ftn.parent_pk1_value 
           WHEN 'N' THEN '000000' 
            ELSE ( SELECT  parent_pk1_value
                     FROM  fnd_tree_node ftn
                          ,fnd_tree_version_vl ftv
                    WHERE  1=1
                      AND  ftn.tree_Code           = 'TP MARS IBU UNPUBLISHED'
                      AND  ftn.tree_structure_code = 'GL_ACCT_FLEX'
                      AND  ftv.tree_Code           = ftn.tree_code
                      AND  ftv.tree_structure_code = ftn.tree_structure_code
                      AND  ftv.tree_version_name   = 'CURRENT'
                      AND  ftn.tree_version_id     = ftv.tree_version_id
                      AND  pk1_start_value         = b.segment3 )
            END   
         FROM   fnd_tree_node ftn
               ,fnd_tree_version_vl ftv
         WHERE 1=1
           AND ftn.tree_Code           = 'ACCOUNT MARS IME UNPUBLISHED'
           AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
           AND ftv.tree_Code           = ftn.tree_code
           AND ftv.tree_structure_code = ftn.tree_structure_code
           AND ftv.tree_version_name   = 'CURRENT'
           AND ftn.tree_version_id     = ftv.tree_version_id
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
                      AND  ftv.tree_version_name   = 'CURRENT'
                      AND  ftn.tree_version_id     = ftv.tree_version_id
                      AND  pk1_start_value         = b.segment3 )
            END   
         FROM   fnd_tree_node ftn
               ,fnd_tree_version_vl ftv
         WHERE 1=1
           AND ftn.tree_Code           = 'ACCOUNT MARS ILE UNPUBLISHED'
           AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
           AND ftv.tree_Code           = ftn.tree_code
           AND ftv.tree_structure_code = ftn.tree_structure_code
           AND ftv.tree_version_name   = 'CURRENT'
           AND ftn.tree_version_id     = ftv.tree_version_id
           AND pk1_start_value         = b.segment2),'000000') "ILE" 
     ,NULL analysis
     ,NULL type
     ,:P_RUN_TYPE run_type
     ,DECODE(a.currency_code,c.currency_code,SUM(NVL(begin_balance_dr_beq,0) - NVL(begin_balance_cr_beq,0)
              + NVL(period_net_dr_beq,0) - NVL(period_net_cr_beq,0)),
              SUM(NVL(begin_balance_dr,0)- NVL(begin_balance_cr,0) + NVL(period_net_dr,0) - NVL(period_net_cr,0))) amount
FROM gl_balances a
    ,gl_code_combinations b
    ,gl_ledgers c
    ,gl_periods d
WHERE a.code_combination_id = b.code_combination_id
  AND a.ledger_id = c.ledger_id
  AND c.ledger_category_code = 'ALC'      -- ALC for Reporting ledger
  AND c.currency_code = 'USD'    -- Include all USD functional currency Reporting books
-- Included the below conditions to use the Account Hierarchy for the Currency. 31 Aug
  AND 'USD' = (SELECT SUBSTR(parent_PK1_VALUE,4)
                 FROM fnd_tree_node ftn
                     ,fnd_tree_version_vl ftv
                WHERE 1=1
                  AND ftn.tree_Code           =  'Company FCY'
                  AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
                  AND ftv.tree_Code           = ftn.tree_code
                  AND ftv.tree_structure_code = ftn.tree_structure_code
                  AND ftv.tree_version_name   = 'CURRENT'
                  AND ftn.tree_version_id     = ftv.tree_version_id
                  AND pk1_start_value         = b.segment1)
  AND c.name = 'CA_USD_FCY'
  AND EXISTS (SELECT 'X'
                FROM fnd_tree_node ftn
                    ,fnd_tree_version_vl ftv
               WHERE 1=1
                 AND ftn.tree_Code           = 'COMPANY MARS UNPUBLISHED'
                 AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
                 AND ftv.tree_Code           = ftn.tree_code
                 AND ftv.tree_structure_code = ftn.tree_structure_code
                 AND ftv.tree_version_name   = 'CURRENT'
                 AND ftn.tree_version_id     = ftv.tree_version_id
                 AND pk1_start_value         = b.segment1
                 AND parent_pk1_value        = 'DIGTOT' )
  AND segment9 <> 'S'  -- exclude statutory adjustments
  AND :P_AMOUNT_TYPE = 'FUNCM'
  AND :P_SENDER_ID   =  'CC74'
  AND d.period_name  = a.period_name
  AND d.period_set_name = c.period_set_name
  AND ( (a.period_name = :P_PERIOD AND :P_PERIOD IS NOT NULL) OR
        (a.period_name = c.latest_opened_period_name AND :P_PERIOD IS NULL))
--
GROUP by a.period_name, segment1, segment2, segment3,a.currency_code ,c.currency_code, d.start_date
HAVING SUM(DECODE(a.currency_code,c.currency_code, (NVL(begin_balance_dr_beq,0) - NVL(begin_balance_cr_beq,0) + NVL(period_net_dr_beq,0) - NVL(period_net_cr_beq,0)),
              (NVL(begin_balance_dr,0)- NVL(begin_balance_cr,0) + NVL(period_net_dr,0) - NVL(period_net_cr,0)))) <> 0 
--end of FUNCM
--start of ORINM
UNION
SELECT a.period_name
      ,b.segment1
      ,b.segment2
      ,b.segment3
      ,a.currency_code
      ,'CC74' sender_id
      ,:P_AMOUNT_TYPE amount_type
      ,TO_CHAR(d.Start_Date,'MM')||'15'||TO_CHAR(d.Start_Date,'YYYY') effective_date
      ,(SELECT SUBSTR(parent_pk1_value,1)
          FROM fnd_tree_node ftn
              ,fnd_tree_version_vl ftv
         WHERE 1=1
           AND ftn.tree_code             = 'COMPANY MARS UNPUBLISHED' -- Changed the hierarchy. 03 Sep
           AND ftn.tree_structure_code   = 'GL_ACCT_FLEX'
           AND ftv.tree_code             = ftn.tree_code
           AND ftv.tree_structure_code   = ftn.tree_structure_code
           AND ftv.tree_version_name     = 'CURRENT'
           AND ftn.tree_version_id       = ftv.tree_version_id
           AND pk1_start_value           = b.segment1) "BUSINESS_UNIT"
      ,(SELECT SUBSTR(parent_pk1_value,1) -- Changed back from position 4 as the underscores are removed. 19 Oct
          FROM fnd_tree_node ftn
              ,FND_TREE_VERSION_VL ftv
         WHERE 1=1
           AND ftn.tree_code           = 'Company LE'
           AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
           AND ftv.tree_code           = ftn.tree_code
           AND ftv.tree_structure_code = ftn.tree_structure_code
           AND ftv.tree_version_name   = 'CURRENT'
           AND ftn.tree_version_id     = ftv.tree_version_id
           AND pk1_start_value         = b.segment1) "LEGAL_ENTITY"
      ,(SELECT parent_pk1_value
          FROM fnd_tree_node ftn
              ,fnd_tree_version_vl ftv
         WHERE 1=1
           AND ftn.tree_Code           =  'ACCOUNT MARS UNPUBLISHED'
           AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
           AND ftv.tree_Code           = ftn.tree_code
           AND ftv.tree_structure_code = ftn.tree_structure_code
           AND ftv.tree_version_name   = 'CURRENT'
           AND ftn.tree_version_id     = ftv.tree_version_id
           AND pk1_start_value         = b.segment2)  "MARS_ACCOUNT"
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
		,NULL analysis
     ,NULL type
     ,:P_RUN_TYPE run_type
     ,DECODE(a.currency_code,c.currency_code,SUM(NVL(begin_balance_dr_beq,0) - NVL(begin_balance_cr_beq,0)
              + NVL(period_net_dr_beq,0) - NVL(period_net_cr_beq,0)),
              SUM(NVL(begin_balance_dr,0)- NVL(begin_balance_cr,0) + NVL(period_net_dr,0) - NVL(period_net_cr,0))) amount
FROM gl_balances a
    ,gl_code_combinations b
    ,gl_ledgers c
    ,gl_periods d
WHERE a.code_combination_id = b.code_combination_id
  AND a.ledger_id = c.ledger_id
  AND c.ledger_category_code = 'ALC'      -- ALC for Reporting ledger
  AND c.name = 'CA_USD_RPT'
  AND c.currency_code = 'USD'    -- Include all USD functional currency Reporting books
  AND EXISTS  (SELECT 'X'
               FROM fnd_tree_node ftn
                   ,fnd_tree_version_vl ftv
               WHERE 1=1
               AND ftn.tree_Code           =  'COMPANY MARS UNPUBLISHED'
               AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
               AND ftv.tree_Code           = ftn.tree_code
               AND ftv.tree_structure_code = ftn.tree_structure_code
               AND ftv.tree_version_name   = 'CURRENT'
               AND ftn.tree_version_id     = ftv.tree_version_id
               AND pk1_start_value         = b.segment1
               AND parent_pk1_value        = 'DIGTOT' )
  AND segment9 <> 'S' -- exclude Statutory Adjustment
  AND :P_AMOUNT_TYPE    = 'ORINM'
  AND :P_SENDER_ID      =  'CC74'
  AND d.period_name     = a.period_name
  AND d.period_set_name = c.period_set_name
  AND ( (a.period_name = :P_PERIOD AND :P_PERIOD IS NOT NULL) OR
        (a.period_name = c.latest_opened_period_name AND :P_PERIOD IS NULL))
GROUP by a.period_name, segment1, segment2, segment3,a.currency_code, c.currency_code, d.start_date
HAVING SUM(DECODE(a.currency_code,c.currency_code, (NVL(begin_balance_dr_beq,0) - NVL(begin_balance_cr_beq,0) + NVL(period_net_dr_beq,0) - NVL(period_net_cr_beq,0)),
              (NVL(begin_balance_dr,0)- NVL(begin_balance_cr,0) + NVL(period_net_dr,0) - NVL(period_net_cr,0)))) <> 0
--end of ORINM
--start of USDRM USDRQ
UNION
SELECT a.period_name
      ,b.segment1
      ,b.segment2
      ,b.segment3
      ,a.currency_code
      ,'CC74' sender_id
      ,:P_AMOUNT_TYPE amount_type
      ,TO_CHAR(d.Start_Date,'MM')||'15'||TO_CHAR(d.Start_Date,'YYYY') effective_date
      ,(SELECT SUBSTR(parent_PK1_VALUE,1)
        FROM fnd_tree_node ftn
            ,fnd_tree_version_vl ftv
        WHERE 1=1
          AND ftn.tree_Code           =  'COMPANY MARS UNPUBLISHED' -- Changed the hierarchy. 03 Sep
          AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
          AND ftv.tree_Code           = ftn.tree_code
          AND ftv.tree_structure_code = ftn.tree_structure_code
          AND ftv.tree_version_name   = 'CURRENT'
          AND ftn.tree_version_id     = ftv.tree_version_id
          AND pk1_start_value         = b.segment1) "BUSINESS_UNIT" 
      ,(SELECT SUBSTR(parent_PK1_VALUE,1) -- Changed back from position 4 as the underscores are removed. 19 Oct
          FROM fnd_tree_node ftn
              ,fnd_tree_version_vl ftv
         WHERE 1=1
           AND ftn.tree_Code           =  'Company LE'
           AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
           AND ftv.tree_Code           = ftn.tree_code
           AND ftv.tree_structure_code = ftn.tree_structure_code
           AND ftv.tree_version_name   = 'CURRENT'
           AND ftn.tree_version_id     = ftv.tree_version_id
           AND pk1_start_value         = b.segment1) "LEGAL_ENTITY" 
      ,(SELECT parent_pk1_value
          FROM fnd_tree_node ftn
              ,fnd_tree_version_vl ftv
         WHERE 1=1
           AND ftn.tree_Code           =  'ACCOUNT MARS UNPUBLISHED'
           AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
           AND ftv.tree_Code           = ftn.tree_code
           AND ftv.tree_structure_code = ftn.tree_structure_code
           AND ftv.tree_version_name   = 'CURRENT'
           AND ftn.tree_version_id     = ftv.tree_version_id
           AND pk1_start_value         = b.segment2)  "MARS_ACCOUNT" 
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
                      AND  ftv.tree_version_name   = 'CURRENT'
                      AND  ftn.tree_version_id     = ftv.tree_version_id
                      AND  pk1_start_value         = b.segment3 )
            END   
         FROM   fnd_tree_node ftn
               ,fnd_tree_version_vl ftv
         WHERE 1=1
           AND ftn.tree_Code           = 'ACCOUNT MARS IME UNPUBLISHED'
           AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
           AND ftv.tree_Code           = ftn.tree_code
           AND ftv.tree_structure_code = ftn.tree_structure_code
           AND ftv.tree_version_name   = 'CURRENT'
           AND ftn.tree_version_id     = ftv.tree_version_id
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
                      AND  ftv.tree_version_name   = 'CURRENT'
                      AND  ftn.tree_version_id     = ftv.tree_version_id
                      AND  pk1_start_value         = b.segment3 )
            END   
         FROM   fnd_tree_node ftn
               ,fnd_tree_version_vl ftv
         WHERE 1=1
           AND ftn.tree_Code           = 'ACCOUNT MARS ILE UNPUBLISHED'
           AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
           AND ftv.tree_Code           = ftn.tree_code
           AND ftv.tree_structure_code = ftn.tree_structure_code
           AND ftv.tree_version_name   = 'CURRENT'
           AND ftn.tree_version_id     = ftv.tree_version_id
           AND pk1_start_value         = b.segment2),'000000') "ILE" 
      ,NULL analysis
      ,NULL type
     ,:P_RUN_TYPE run_type
      ,SUM(NVL(a.begin_balance_dr,0)- NVL(a.begin_balance_cr,0) + NVL(a.period_net_dr,0) - NVL(a.period_net_cr,0)) amount
FROM gl_balances a
    ,gl_code_combinations b
    ,gl_ledgers c
    ,gl_periods d
WHERE a.code_combination_id = b.code_combination_id
  AND a.ledger_id     = c.ledger_id
  AND c.ledger_category_code = 'ALC'      -- reporting ledger
  AND c.name          = 'CA_USD_RPT'
  AND c.currency_code = 'USD'   -- with functional currency as USD
  AND a.currency_code = c.currency_code  -- only USD balances
  AND EXISTS (SELECT 'X'
               FROM fnd_tree_node ftn
                   ,fnd_tree_version_vl ftv
               WHERE 1=1
               AND ftn.tree_Code           =  'COMPANY MARS UNPUBLISHED'
               AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
               AND ftv.tree_Code           = ftn.tree_code
               AND ftv.tree_structure_code = ftn.tree_structure_code
               AND ftv.tree_version_name   = 'CURRENT'
               AND ftn.tree_version_id     = ftv.tree_version_id
               AND pk1_start_value         = b.segment1
               AND parent_pk1_value IN ('DIGTOT') )
  AND b.segment9 <> 'S'  -- exclude statutory adjustments
  AND :P_AMOUNT_TYPE IN ('USDRM','USDRQ')
  AND :P_SENDER_ID      =  'CC74'
  AND d.period_name     = a.period_name
  AND d.period_set_name = c.period_set_name
  AND ( (a.period_name = :P_PERIOD AND :P_PERIOD IS NOT NULL) OR
        (a.period_name = c.latest_opened_period_name AND :P_PERIOD IS NULL))
--
GROUP by a.period_name, segment1, segment2, segment3 ,a.currency_code, d.start_date
HAVING SUM(NVL(begin_balance_dr,0)- NVL(begin_balance_cr,0) + NVL(period_net_dr,0) - NVL(period_net_cr,0)) <> 0
UNION
--
-- End of GED Canada
--
---GED US
--start of FUNCM
SELECT a.period_name
      ,b.segment1
      ,b.segment2
      ,b.segment3
      ,a.currency_code
      ,'CC74' sender_id
      ,:P_AMOUNT_TYPE amount_type
      ,TO_CHAR(d.Start_Date,'MM')||'15'||TO_CHAR(d.Start_Date,'YYYY') effective_date
      ,(SELECT SUBSTR(parent_PK1_VALUE,1)
          FROM fnd_tree_node ftn
              ,fnd_tree_version_vl ftv
         WHERE 1=1
           AND ftn.tree_Code             = 'COMPANY MARS UNPUBLISHED' -- Changed the hierarchy. 03 Sep
           AND ftn.tree_structure_code   = 'GL_ACCT_FLEX'
           AND ftv.tree_Code             = ftn.tree_code
           AND ftv.tree_structure_code   = ftn.tree_structure_code
           AND ftv.tree_version_name     = 'CURRENT'
           AND ftn.tree_version_id       = ftv.tree_version_id
           AND pk1_start_value           = b.segment1) "BUSINESS_UNIT"
       , (SELECT SUBSTR(parent_pk1_value,1) -- Changed back from position 4 as the underscores are removed. 19 Oct
            FROM fnd_tree_node ftn
                 ,fnd_tree_version_vl ftv
           WHERE 1=1
             AND ftn.tree_Code           = 'Company LE'
             AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
             AND ftv.tree_Code           = ftn.tree_code
             AND ftv.tree_structure_code = ftn.tree_structure_code
             AND ftv.tree_version_name   = 'CURRENT'
             AND ftn.tree_version_id     = ftv.tree_version_id
             AND pk1_start_value         = b.segment1) "LEGAL_ENTITY"
       ,(SELECT parent_pk1_value
           FROM fnd_tree_node ftn
               ,fnd_tree_version_vl ftv
          WHERE 1=1
            AND ftn.tree_Code            = 'ACCOUNT MARS UNPUBLISHED'
            AND ftn.tree_structure_code  = 'GL_ACCT_FLEX'
            AND ftv.tree_Code            = ftn.tree_code
            AND ftv.tree_structure_code  = ftn.tree_structure_code
            AND ftv.tree_version_name    = 'CURRENT'
            AND ftn.tree_version_id      = ftv.tree_version_id
            AND pk1_start_value          = b.segment2)  "MARS_ACCOUNT"
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
                      AND  ftv.tree_version_name   = 'CURRENT'
                      AND  ftn.tree_version_id     = ftv.tree_version_id
                      AND  pk1_start_value         = b.segment3 )
            END   
         FROM   fnd_tree_node ftn
               ,fnd_tree_version_vl ftv
         WHERE 1=1
           AND ftn.tree_Code           = 'ACCOUNT MARS IME UNPUBLISHED'
           AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
           AND ftv.tree_Code           = ftn.tree_code
           AND ftv.tree_structure_code = ftn.tree_structure_code
           AND ftv.tree_version_name   = 'CURRENT'
           AND ftn.tree_version_id     = ftv.tree_version_id
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
                      AND  ftv.tree_version_name   = 'CURRENT'
                      AND  ftn.tree_version_id     = ftv.TREE_VERSION_ID
                      AND  pk1_start_value         = b.segment3 )
            END   
         FROM   fnd_tree_node ftn
               ,fnd_tree_version_vl ftv
         WHERE 1=1
           AND ftn.tree_Code           = 'ACCOUNT MARS ILE UNPUBLISHED'
           AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
           AND ftv.tree_Code           = ftn.tree_code
           AND ftv.tree_structure_code = ftn.tree_structure_code
           AND ftv.tree_version_name   = 'CURRENT'
           AND ftn.tree_version_id     = ftv.TREE_VERSION_ID
           AND pk1_start_value         = b.segment2),'000000') "ILE" 
      ,NULL analysis
      ,NULL type
      ,:P_RUN_TYPE run_type
      ,SUM(NVL(begin_balance_dr,0)- NVL(begin_balance_cr,0) + NVL(period_net_dr,0) - NVL(period_net_cr,0)) amount
FROM gl_balances a
    ,gl_code_combinations b
    ,gl_ledgers c
    ,gl_periods d
WHERE a.code_combination_id = b.code_combination_id
  AND a.ledger_id = c.ledger_id
  AND a.currency_code = c.currency_code -- functional currency
  AND 'USD' = (SELECT SUBSTR(parent_PK1_VALUE,4)
               FROM   fnd_tree_node ftn
                     ,fnd_tree_version_vl ftv
               WHERE 1=1
                 AND ftn.tree_Code           =  'Company FCY'
                 AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
                 AND ftv.tree_Code           = ftn.tree_code
                 AND ftv.tree_structure_code = ftn.tree_structure_code
                 AND ftv.tree_version_name   = 'CURRENT'
                 AND ftn.tree_version_id     = ftv.tree_version_id
                 AND pk1_start_value         = b.segment1)
  AND c.name = 'US_USD_PRM'
  AND EXISTS  (SELECT 'X'
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
  AND segment9 <> 'S'              -- exclude statutory adjustments
  AND :P_AMOUNT_TYPE = 'FUNCM'
  AND :P_SENDER_ID =  'CC74'
  AND d.period_name = a.period_name
  AND d.period_set_name = c.period_set_name
  AND ( (a.period_name = :P_PERIOD AND :P_PERIOD IS NOT NULL) OR
      (a.period_name = c.latest_opened_period_name AND :P_PERIOD IS NULL))
GROUP by a.period_name, segment1, segment2, segment3 ,a.currency_code, d.start_date
HAVING SUM(NVL(begin_balance_dr,0)- NVL(begin_balance_cr,0) + NVL(period_net_dr,0) - NVL(period_net_cr,0)) <> 0        
UNION
SELECT a.period_name
      ,b.segment1
      ,b.segment2
      ,b.segment3
      ,a.currency_code
      ,'CC74' sender_id
      ,:P_AMOUNT_TYPE amount_type
      ,TO_CHAR(d.Start_Date,'MM')||'15'||TO_CHAR(d.Start_Date,'YYYY') effective_date
      ,(SELECT SUBSTR(parent_pk1_value,1)
          FROM fnd_tree_node ftn
              ,fnd_tree_version_vl ftv
         WHERE 1=1
           AND ftn.tree_code           =  'COMPANY MARS UNPUBLISHED' -- Changed the hierarchy. 03 Sep
           AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
           AND ftv.tree_Code           = ftn.tree_code
           AND ftv.tree_structure_code = ftn.tree_structure_code
           AND ftv.tree_version_name   = 'CURRENT'
           AND ftn.tree_version_id     = ftv.tree_version_id
           AND pk1_start_value         = b.segment1) "BUSINESS_UNIT"
      , (SELECT SUBSTR(parent_PK1_VALUE,1) -- Changed back from position 4 as the underscores are removed. 19 Oct
           FROM fnd_tree_node ftn
               ,fnd_tree_version_vl ftv
          WHERE 1=1
            AND ftn.tree_Code           =  'Company LE'
            AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
            AND ftv.tree_Code           = ftn.tree_code
            AND ftv.tree_structure_code = ftn.tree_structure_code
            AND ftv.tree_version_name   = 'CURRENT'
            AND ftn.tree_version_id     = ftv.tree_version_id
            AND pk1_start_value         = b.segment1) "LEGAL_ENTITY"
      ,(SELECT parent_pk1_value
          FROM fnd_tree_node ftn
              ,fnd_tree_version_vl ftv
         WHERE 1=1
           AND ftn.tree_Code            =  'ACCOUNT MARS UNPUBLISHED'
           AND ftn.tree_structure_code  = 'GL_ACCT_FLEX'
           AND ftv.tree_Code            = ftn.tree_code
           AND ftv.tree_structure_code  = ftn.tree_structure_code
           AND ftv.tree_version_name    = 'CURRENT'
           AND ftn.tree_version_id      = ftv.tree_version_id
           AND pk1_start_value          = b.segment2)  "MARS_ACCOUNT"
        ,NVL((SELECT 
        CASE ftn.parent_pk1_value 
           WHEN 'N' THEN '000000' 
            ELSE ( SELECT  parent_pk1_value
                     FROM  fnd_tree_node ftn
                          ,fnd_tree_version_vl ftv
                    WHERE  1=1
                      AND  ftn.tree_Code           = 'TP MARS IBU UNPUBLISHED'
                      AND  ftn.tree_structure_code = 'GL_ACCT_FLEX'
                      AND  ftv.tree_Code           = ftn.tree_code
                      AND  ftv.tree_structure_code = ftn.tree_structure_code
                      AND  ftv.tree_version_name   = 'CURRENT'
                      AND  ftn.tree_version_id     = ftv.tree_version_id
                      AND  pk1_start_value         = b.segment3 )
            END   
         FROM   fnd_tree_node ftn
               ,fnd_tree_version_vl ftv
         WHERE 1=1
           AND ftn.tree_Code           = 'ACCOUNT MARS IME UNPUBLISHED'
           AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
           AND ftv.tree_Code           = ftn.tree_code
           AND ftv.tree_structure_code = ftn.tree_structure_code
           AND ftv.tree_version_name   = 'CURRENT'
           AND ftn.tree_version_id     = ftv.tree_version_id
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
                      AND  ftv.tree_version_name   = 'CURRENT'
                      AND  ftn.tree_version_id     = ftv.tree_version_id
                      AND  pk1_start_value         = b.segment3 )
            END   
         FROM   fnd_tree_node ftn
               ,fnd_tree_version_vl ftv
         WHERE 1=1
           AND ftn.tree_Code           = 'ACCOUNT MARS ILE UNPUBLISHED'
           AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
           AND ftv.tree_Code           = ftn.tree_code
           AND ftv.tree_structure_code = ftn.tree_structure_code
           AND ftv.tree_version_name   = 'CURRENT'
           AND ftn.tree_version_id     = ftv.tree_version_id
           AND pk1_start_value         = b.segment2),'000000') "ILE" 
     ,NULL analysis
     ,NULL type
     ,:P_RUN_TYPE run_type
     ,DECODE(a.currency_code,c.currency_code,SUM(NVL(begin_balance_dr_beq,0) - NVL(begin_balance_cr_beq,0)
              + NVL(period_net_dr_beq,0) - NVL(period_net_cr_beq,0)),
              SUM(NVL(begin_balance_dr,0)- NVL(begin_balance_cr,0) + NVL(period_net_dr,0) - NVL(period_net_cr,0))) amount
FROM gl_balances a
    ,gl_code_combinations b
    ,gl_ledgers c
    ,gl_periods d
WHERE a.code_combination_id = b.code_combination_id
  AND a.ledger_id = c.ledger_id
  AND c.ledger_category_code = 'ALC'      -- ALC for Reporting ledger
  AND c.currency_code = 'USD'    -- Include all USD functional currency Reporting books
  AND 'USD' = (SELECT SUBSTR(parent_PK1_VALUE,4)
                 FROM fnd_tree_node ftn
                     ,fnd_tree_version_vl ftv
                WHERE 1=1
                  AND ftn.tree_Code           =  'Company FCY'
                  AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
                  AND ftv.tree_Code           = ftn.tree_code
                  AND ftv.tree_structure_code = ftn.tree_structure_code
                  AND ftv.tree_version_name   = 'CURRENT'
                  AND ftn.tree_version_id     = ftv.tree_version_id
                  AND pk1_start_value         = b.segment1)
  AND c.name = 'US_USD_PRM'
  AND EXISTS (SELECT 'X'
                FROM fnd_tree_node ftn
                    ,fnd_tree_version_vl ftv
               WHERE 1=1
                 AND ftn.tree_Code           = 'COMPANY MARS UNPUBLISHED'
                 AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
                 AND ftv.tree_Code           = ftn.tree_code
                 AND ftv.tree_structure_code = ftn.tree_structure_code
                 AND ftv.tree_version_name   = 'CURRENT'
                 AND ftn.tree_version_id     = ftv.tree_version_id
                 AND pk1_start_value         = b.segment1
                 AND parent_pk1_value        = 'DIGTOT' )
  AND segment9 <> 'S'  -- exclude statutory adjustments
  AND :P_AMOUNT_TYPE = 'FUNCM'
  AND :P_SENDER_ID   =  'CC74'
  AND d.period_name  = a.period_name
  AND d.period_set_name = c.period_set_name
  AND ( (a.period_name = :P_PERIOD AND :P_PERIOD IS NOT NULL) OR
        (a.period_name = c.latest_opened_period_name AND :P_PERIOD IS NULL))
--
GROUP by a.period_name, segment1, segment2, segment3 ,a.currency_code ,c.currency_code, d.start_date
HAVING SUM(DECODE(a.currency_code,c.currency_code, (NVL(begin_balance_dr_beq,0) - NVL(begin_balance_cr_beq,0)
              + NVL(period_net_dr_beq,0) - NVL(period_net_cr_beq,0)),
              (NVL(begin_balance_dr,0)- NVL(begin_balance_cr,0) + NVL(period_net_dr,0) - NVL(period_net_cr,0)))) <> 0 
--end of FUNCM
--start of ORINM
UNION
SELECT a.period_name
      ,b.segment1
      ,b.segment2
      ,b.segment3
      ,a.currency_code
      ,'CC74' sender_id
      ,:P_AMOUNT_TYPE amount_type
      ,TO_CHAR(d.Start_Date,'MM')||'15'||TO_CHAR(d.Start_Date,'YYYY') effective_date
      ,(SELECT SUBSTR(parent_pk1_value,1)
          FROM fnd_tree_node ftn
              ,fnd_tree_version_vl ftv
         WHERE 1=1
           AND ftn.tree_code             = 'COMPANY MARS UNPUBLISHED' -- Changed the hierarchy. 03 Sep
           AND ftn.tree_structure_code   = 'GL_ACCT_FLEX'
           AND ftv.tree_code             = ftn.tree_code
           AND ftv.tree_structure_code   = ftn.tree_structure_code
           AND ftv.tree_version_name     = 'CURRENT'
           AND ftn.tree_version_id       = ftv.tree_version_id
           AND pk1_start_value           = b.segment1) "BUSINESS_UNIT"
      ,(SELECT SUBSTR(parent_pk1_value,1) -- Changed back from position 4 as the underscores are removed. 19 Oct
          FROM fnd_tree_node ftn
              ,FND_TREE_VERSION_VL ftv
         WHERE 1=1
           AND ftn.tree_code           = 'Company LE'
           AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
           AND ftv.tree_code           = ftn.tree_code
           AND ftv.tree_structure_code = ftn.tree_structure_code
           AND ftv.tree_version_name   = 'CURRENT'
           AND ftn.tree_version_id     = ftv.tree_version_id
           AND pk1_start_value         = b.segment1) "LEGAL_ENTITY"
      ,(SELECT parent_pk1_value
          FROM fnd_tree_node ftn
              ,fnd_tree_version_vl ftv
         WHERE 1=1
           AND ftn.tree_Code           =  'ACCOUNT MARS UNPUBLISHED'
           AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
           AND ftv.tree_Code           = ftn.tree_code
           AND ftv.tree_structure_code = ftn.tree_structure_code
           AND ftv.tree_version_name   = 'CURRENT'
           AND ftn.tree_version_id     = ftv.tree_version_id
           AND pk1_start_value         = b.segment2)  "MARS_ACCOUNT"
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
		,NULL analysis
     ,NULL type
     ,:P_RUN_TYPE run_type
     ,DECODE(a.currency_code,c.currency_code,SUM(NVL(begin_balance_dr_beq,0) - NVL(begin_balance_cr_beq,0)
              + NVL(period_net_dr_beq,0) - NVL(period_net_cr_beq,0)),
              SUM(NVL(begin_balance_dr,0)- NVL(begin_balance_cr,0) + NVL(period_net_dr,0) - NVL(period_net_cr,0))) amount
FROM gl_balances a
    ,gl_code_combinations b
    ,gl_ledgers c
    ,gl_periods d
WHERE a.code_combination_id = b.code_combination_id
  AND a.ledger_id            = c.ledger_id
  AND c.ledger_category_code = 'ALC'      -- ALC for Reporting ledger
  AND c.name                 = 'US_USD_RPT'
  AND c.currency_code        = 'USD'    -- Include all USD functional currency Reporting books
  AND EXISTS  (SELECT 'X'
               FROM fnd_tree_node ftn
                   ,fnd_tree_version_vl ftv
               WHERE 1=1
               AND ftn.tree_Code           =  'COMPANY MARS UNPUBLISHED'
               AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
               AND ftv.tree_Code           = ftn.tree_code
               AND ftv.tree_structure_code = ftn.tree_structure_code
               AND ftv.tree_version_name   = 'CURRENT'
               AND ftn.tree_version_id     = ftv.tree_version_id
               AND pk1_start_value         = b.segment1
               AND parent_pk1_value        = 'DIGTOT' )
  AND segment9 <> 'S' -- exclude Statutory Adjustment
  AND :P_AMOUNT_TYPE    = 'ORINM'
  AND :P_SENDER_ID      =  'CC74'
  AND d.period_name     = a.period_name
  AND d.period_set_name = c.period_set_name
-- Changed to use latest open period if Period Name is not passed. 09 Sep.
  AND ( (a.period_name = :P_PERIOD AND :P_PERIOD IS NOT NULL) OR
        (a.period_name = c.latest_opened_period_name AND :P_PERIOD IS NULL))
--
GROUP by a.period_name, segment1, segment2, segment3 ,a.currency_code, c.currency_code, d.start_date
HAVING SUM(DECODE(a.currency_code,c.currency_code, (NVL(begin_balance_dr_beq,0) - NVL(begin_balance_cr_beq,0)
              + NVL(period_net_dr_beq,0) - NVL(period_net_cr_beq,0)),
              (NVL(begin_balance_dr,0)- NVL(begin_balance_cr,0) + NVL(period_net_dr,0) - NVL(period_net_cr,0)))) <> 0
--end of ORINM
--start of USDRM USDRQ
UNION
SELECT a.period_name
      ,b.segment1
      ,b.segment2
      ,b.segment3
      ,a.currency_code
      ,'CC74' sender_id
      ,:P_AMOUNT_TYPE amount_type
      ,TO_CHAR(d.Start_Date,'MM')||'15'||TO_CHAR(d.Start_Date,'YYYY') effective_date
      ,(SELECT SUBSTR(parent_PK1_VALUE,1)
        FROM fnd_tree_node ftn
            ,fnd_tree_version_vl ftv
        WHERE 1=1
          AND ftn.tree_Code           =  'COMPANY MARS UNPUBLISHED' -- Changed the hierarchy. 03 Sep
          AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
          AND ftv.tree_Code           = ftn.tree_code
          AND ftv.tree_structure_code = ftn.tree_structure_code
          AND ftv.tree_version_name   = 'CURRENT'
          AND ftn.tree_version_id     = ftv.tree_version_id
          AND pk1_start_value         = b.segment1) "BUSINESS_UNIT" 
      ,(SELECT SUBSTR(parent_PK1_VALUE,1) -- Changed back from position 4 as the underscores are removed. 19 Oct
          FROM fnd_tree_node ftn
              ,fnd_tree_version_vl ftv
         WHERE 1=1
           AND ftn.tree_Code           =  'Company LE'
           AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
           AND ftv.tree_Code           = ftn.tree_code
           AND ftv.tree_structure_code = ftn.tree_structure_code
           AND ftv.tree_version_name   = 'CURRENT'
           AND ftn.tree_version_id     = ftv.tree_version_id
           AND pk1_start_value         = b.segment1) "LEGAL_ENTITY" 
      ,(SELECT parent_pk1_value
          FROM fnd_tree_node ftn
              ,fnd_tree_version_vl ftv
         WHERE 1=1
           AND ftn.tree_Code           =  'ACCOUNT MARS UNPUBLISHED'
           AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
           AND ftv.tree_Code           = ftn.tree_code
           AND ftv.tree_structure_code = ftn.tree_structure_code
           AND ftv.tree_version_name   = 'CURRENT'
           AND ftn.tree_version_id     = ftv.tree_version_id
           AND pk1_start_value         = b.segment2)  "MARS_ACCOUNT" 
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
                      AND  ftv.tree_version_name   = 'CURRENT'
                      AND  ftn.tree_version_id     = ftv.tree_version_id
                      AND  pk1_start_value         = b.segment3 )
            END   
         FROM   fnd_tree_node ftn
               ,fnd_tree_version_vl ftv
         WHERE 1=1
           AND ftn.tree_Code           = 'ACCOUNT MARS IME UNPUBLISHED'
           AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
           AND ftv.tree_Code           = ftn.tree_code
           AND ftv.tree_structure_code = ftn.tree_structure_code
           AND ftv.tree_version_name   = 'CURRENT'
           AND ftn.tree_version_id     = ftv.tree_version_id
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
                      AND  ftv.tree_version_name   = 'CURRENT'
                      AND  ftn.tree_version_id     = ftv.tree_version_id
                      AND  pk1_start_value         = b.segment3 )
            END   
         FROM   fnd_tree_node ftn
               ,fnd_tree_version_vl ftv
         WHERE 1=1
           AND ftn.tree_Code           = 'ACCOUNT MARS ILE UNPUBLISHED'
           AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
           AND ftv.tree_Code           = ftn.tree_code
           AND ftv.tree_structure_code = ftn.tree_structure_code
           AND ftv.tree_version_name   = 'CURRENT'
           AND ftn.tree_version_id     = ftv.tree_version_id
           AND pk1_start_value         = b.segment2),'000000') "ILE" 
      ,NULL analysis
      ,NULL type
     ,:P_RUN_TYPE run_type
      ,SUM(NVL(a.begin_balance_dr,0)- NVL(a.begin_balance_cr,0) + NVL(a.period_net_dr,0) - NVL(a.period_net_cr,0)) amount
FROM gl_balances a
    ,gl_code_combinations b
    ,gl_ledgers c
    ,gl_periods d
WHERE a.code_combination_id  = b.code_combination_id
  AND a.ledger_id            = c.ledger_id
  AND c.ledger_category_code = 'ALC'      -- reporting ledger
  AND c.name          = 'US_USD_RPT'
  AND c.currency_code = 'USD'   -- with functional currency as USD
  AND a.currency_code = c.currency_code  -- only USD balances
  AND EXISTS (SELECT 'X'
               FROM fnd_tree_node ftn
                   ,fnd_tree_version_vl ftv
               WHERE 1=1
               AND ftn.tree_Code           =  'COMPANY MARS UNPUBLISHED'
               AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
               AND ftv.tree_Code           = ftn.tree_code
               AND ftv.tree_structure_code = ftn.tree_structure_code
               AND ftv.tree_version_name   = 'CURRENT'
               AND ftn.tree_version_id     = ftv.tree_version_id
               AND pk1_start_value         = b.segment1
               AND parent_pk1_value IN ('DIGTOT') )
  AND b.segment9 <> 'S'  -- exclude statutory adjustments
  AND :P_AMOUNT_TYPE IN ('USDRM','USDRQ')
  AND :P_SENDER_ID      =  'CC74'
  AND d.period_name     = a.period_name
  AND d.period_set_name = c.period_set_name
  AND ( (a.period_name = :P_PERIOD AND :P_PERIOD IS NOT NULL) OR
        (a.period_name = c.latest_opened_period_name AND :P_PERIOD IS NULL))
--
GROUP by a.period_name, segment1, segment2, segment3 ,a.currency_code, d.start_date
HAVING SUM(NVL(begin_balance_dr,0)- NVL(begin_balance_cr,0) + NVL(period_net_dr,0) - NVL(period_net_cr,0)) <> 0
UNION
--End of US GED
--
-- GED FRANCE
--
--start of FUNCM
SELECT a.period_name
      ,b.segment1
      ,b.segment2
      ,b.segment3
      ,a.currency_code
      ,'CC74' sender_id
      ,:P_AMOUNT_TYPE amount_type
      ,TO_CHAR(d.Start_Date,'MM')||'15'||TO_CHAR(d.Start_Date,'YYYY') effective_date
      ,(SELECT SUBSTR(parent_PK1_VALUE,1)
          FROM fnd_tree_node ftn
              ,fnd_tree_version_vl ftv
         WHERE 1=1
           AND ftn.tree_Code             = 'COMPANY MARS UNPUBLISHED' -- Changed the hierarchy. 03 Sep
           AND ftn.tree_structure_code   = 'GL_ACCT_FLEX'
           AND ftv.tree_Code             = ftn.tree_code
           AND ftv.tree_structure_code   = ftn.tree_structure_code
           AND ftv.tree_version_name     = 'CURRENT'
           AND ftn.tree_version_id       = ftv.tree_version_id
           AND pk1_start_value           = b.segment1) "BUSINESS_UNIT"
       ,(SELECT SUBSTR(parent_pk1_value,1) -- Changed back from position 4 as the underscores are removed. 19 Oct
           FROM fnd_tree_node ftn
                ,fnd_tree_version_vl ftv
          WHERE 1=1
            AND ftn.tree_Code           = 'Company LE'
            AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
            AND ftv.tree_Code           = ftn.tree_code
            AND ftv.tree_structure_code = ftn.tree_structure_code
            AND ftv.tree_version_name   = 'CURRENT'
            AND ftn.tree_version_id     = ftv.tree_version_id
            AND pk1_start_value         = b.segment1) "LEGAL_ENTITY"
       ,(SELECT parent_pk1_value
           FROM fnd_tree_node ftn
               ,fnd_tree_version_vl ftv
          WHERE 1=1
            AND ftn.tree_Code            = 'ACCOUNT MARS UNPUBLISHED'
            AND ftn.tree_structure_code  = 'GL_ACCT_FLEX'
            AND ftv.tree_Code            = ftn.tree_code
            AND ftv.tree_structure_code  = ftn.tree_structure_code
            AND ftv.tree_version_name    = 'CURRENT'
            AND ftn.tree_version_id      = ftv.tree_version_id
            AND pk1_start_value          = b.segment2)  "MARS_ACCOUNT"
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
                      AND  ftv.tree_version_name   = 'CURRENT'
                      AND  ftn.tree_version_id     = ftv.tree_version_id
                      AND  pk1_start_value         = b.segment3 )
            END   
         FROM   fnd_tree_node ftn
               ,fnd_tree_version_vl ftv
         WHERE 1=1
           AND ftn.tree_Code           = 'ACCOUNT MARS IME UNPUBLISHED'
           AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
           AND ftv.tree_Code           = ftn.tree_code
           AND ftv.tree_structure_code = ftn.tree_structure_code
           AND ftv.tree_version_name   = 'CURRENT'
           AND ftn.tree_version_id     = ftv.tree_version_id
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
                      AND  ftv.tree_version_name   = 'CURRENT'
                      AND  ftn.tree_version_id     = ftv.TREE_VERSION_ID
                      AND  pk1_start_value         = b.segment3 )
            END   
         FROM   fnd_tree_node ftn
               ,fnd_tree_version_vl ftv
         WHERE 1=1
           AND ftn.tree_Code           = 'ACCOUNT MARS ILE UNPUBLISHED'
           AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
           AND ftv.tree_Code           = ftn.tree_code
           AND ftv.tree_structure_code = ftn.tree_structure_code
           AND ftv.tree_version_name   = 'CURRENT'
           AND ftn.tree_version_id     = ftv.TREE_VERSION_ID
           AND pk1_start_value         = b.segment2),'000000') "ILE" 
      ,NULL analysis
      ,NULL type
      ,:P_RUN_TYPE run_type
      ,SUM(NVL(begin_balance_dr,0)- NVL(begin_balance_cr,0) + NVL(period_net_dr,0) - NVL(period_net_cr,0)) amount
FROM gl_balances a
    ,gl_code_combinations b
    ,gl_ledgers c
    ,gl_periods d
WHERE a.code_combination_id = b.code_combination_id
  AND a.ledger_id = c.ledger_id
  AND a.currency_code = c.currency_code -- functional currency
  AND 'EUR' = (SELECT SUBSTR(parent_PK1_VALUE,4)
               FROM   fnd_tree_node ftn
                     ,fnd_tree_version_vl ftv
               WHERE 1=1
                 AND ftn.tree_Code           =  'Company FCY'
                 AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
                 AND ftv.tree_Code           = ftn.tree_code
                 AND ftv.tree_structure_code = ftn.tree_structure_code
                 AND ftv.tree_version_name   = 'CURRENT'
                 AND ftn.tree_version_id     = ftv.tree_version_id
                 AND pk1_start_value         = b.segment1)
  AND c.name = 'FR_EUR_PRM'
  AND EXISTS  (SELECT 'X'
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
  AND segment9 <> 'S'              -- exclude statutory adjustments
  AND :P_AMOUNT_TYPE = 'FUNCM'
  AND :P_SENDER_ID =  'CC74'
  AND d.period_name = a.period_name
  AND d.period_set_name = c.period_set_name
  AND ( (a.period_name = :P_PERIOD AND :P_PERIOD IS NOT NULL) OR
        (a.period_name = c.latest_opened_period_name AND :P_PERIOD IS NULL))
--
  GROUP by a.period_name, segment1, segment2, segment3,a.currency_code, d.start_date
  HAVING SUM(NVL(begin_balance_dr,0)- NVL(begin_balance_cr,0) + NVL(period_net_dr,0) - NVL(period_net_cr,0)) <> 0
UNION
  SELECT a.period_name
        ,b.segment1
      ,b.segment2
      ,b.segment3
      ,a.currency_code
      ,'CC74' sender_id
      ,:P_AMOUNT_TYPE amount_type
      ,TO_CHAR(d.Start_Date,'MM')||'15'||TO_CHAR(d.Start_Date,'YYYY') effective_date
      ,(SELECT SUBSTR(parent_pk1_value,1)
          FROM fnd_tree_node ftn
              ,fnd_tree_version_vl ftv
         WHERE 1=1
           AND ftn.tree_code           =  'COMPANY MARS UNPUBLISHED' -- Changed the hierarchy. 03 Sep
           AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
           AND ftv.tree_Code           = ftn.tree_code
           AND ftv.tree_structure_code = ftn.tree_structure_code
           AND ftv.tree_version_name   = 'CURRENT'
           AND ftn.tree_version_id     = ftv.tree_version_id
           AND pk1_start_value         = b.segment1) "BUSINESS_UNIT"
      , (SELECT SUBSTR(parent_PK1_VALUE,1) -- Changed back from position 4 as the underscores are removed. 19 Oct
           FROM fnd_tree_node ftn
               ,fnd_tree_version_vl ftv
          WHERE 1=1
            AND ftn.tree_Code           =  'Company LE'
            AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
            AND ftv.tree_Code           = ftn.tree_code
            AND ftv.tree_structure_code = ftn.tree_structure_code
            AND ftv.tree_version_name   = 'CURRENT'
            AND ftn.tree_version_id     = ftv.tree_version_id
            AND pk1_start_value         = b.segment1) "LEGAL_ENTITY"
      ,(SELECT parent_pk1_value
          FROM fnd_tree_node ftn
              ,fnd_tree_version_vl ftv
         WHERE 1=1
           AND ftn.tree_Code            =  'ACCOUNT MARS UNPUBLISHED'
           AND ftn.tree_structure_code  = 'GL_ACCT_FLEX'
           AND ftv.tree_Code            = ftn.tree_code
           AND ftv.tree_structure_code  = ftn.tree_structure_code
           AND ftv.tree_version_name    = 'CURRENT'
           AND ftn.tree_version_id      = ftv.tree_version_id
           AND pk1_start_value          = b.segment2)  "MARS_ACCOUNT"
        ,NVL((SELECT 
        CASE ftn.parent_pk1_value 
           WHEN 'N' THEN '000000' 
            ELSE ( SELECT  parent_pk1_value
                     FROM  fnd_tree_node ftn
                          ,fnd_tree_version_vl ftv
                    WHERE  1=1
                      AND  ftn.tree_Code           = 'TP MARS IBU UNPUBLISHED'
                      AND  ftn.tree_structure_code = 'GL_ACCT_FLEX'
                      AND  ftv.tree_Code           = ftn.tree_code
                      AND  ftv.tree_structure_code = ftn.tree_structure_code
                      AND  ftv.tree_version_name   = 'CURRENT'
                      AND  ftn.tree_version_id     = ftv.tree_version_id
                      AND  pk1_start_value         = b.segment3 )
            END   
         FROM   fnd_tree_node ftn
               ,fnd_tree_version_vl ftv
         WHERE 1=1
           AND ftn.tree_Code           = 'ACCOUNT MARS IME UNPUBLISHED'
           AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
           AND ftv.tree_Code           = ftn.tree_code
           AND ftv.tree_structure_code = ftn.tree_structure_code
           AND ftv.tree_version_name   = 'CURRENT'
           AND ftn.tree_version_id     = ftv.tree_version_id
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
                      AND  ftv.tree_version_name   = 'CURRENT'
                      AND  ftn.tree_version_id     = ftv.tree_version_id
                      AND  pk1_start_value         = b.segment3 )
            END   
         FROM   fnd_tree_node ftn
               ,fnd_tree_version_vl ftv
         WHERE 1=1
           AND ftn.tree_Code           = 'ACCOUNT MARS ILE UNPUBLISHED'
           AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
           AND ftv.tree_Code           = ftn.tree_code
           AND ftv.tree_structure_code = ftn.tree_structure_code
           AND ftv.tree_version_name   = 'CURRENT'
           AND ftn.tree_version_id     = ftv.tree_version_id
           AND pk1_start_value         = b.segment2),'000000') "ILE" 
     ,NULL analysis
     ,NULL type
     ,:P_RUN_TYPE run_type
     ,DECODE(a.currency_code,c.currency_code,SUM(NVL(begin_balance_dr_beq,0) - NVL(begin_balance_cr_beq,0)
              + NVL(period_net_dr_beq,0) - NVL(period_net_cr_beq,0)),
              SUM(NVL(begin_balance_dr,0)- NVL(begin_balance_cr,0) + NVL(period_net_dr,0) - NVL(period_net_cr,0))) amount
FROM gl_balances a
    ,gl_code_combinations b
    ,gl_ledgers c
    ,gl_periods d
WHERE a.code_combination_id = b.code_combination_id
  AND a.ledger_id = c.ledger_id
  AND c.ledger_category_code = 'ALC'      -- ALC for Reporting ledger
  AND c.currency_code = 'USD'    -- Include all USD functional currency Reporting books
  AND 'USD' = (SELECT SUBSTR(parent_PK1_VALUE,4)
                 FROM fnd_tree_node ftn
                     ,fnd_tree_version_vl ftv
                WHERE 1=1
                  AND ftn.tree_Code           =  'Company FCY'
                  AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
                  AND ftv.tree_Code           = ftn.tree_code
                  AND ftv.tree_structure_code = ftn.tree_structure_code
                  AND ftv.tree_version_name   = 'CURRENT'
                  AND ftn.tree_version_id     = ftv.tree_version_id
                  AND pk1_start_value         = b.segment1)
  AND c.name = 'FR_USD_FCY'
  AND EXISTS (SELECT 'X'
                FROM fnd_tree_node ftn
                    ,fnd_tree_version_vl ftv
               WHERE 1=1
                 AND ftn.tree_Code           = 'COMPANY MARS UNPUBLISHED'
                 AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
                 AND ftv.tree_Code           = ftn.tree_code
                 AND ftv.tree_structure_code = ftn.tree_structure_code
                 AND ftv.tree_version_name   = 'CURRENT'
                 AND ftn.tree_version_id     = ftv.tree_version_id
                 AND pk1_start_value         = b.segment1
                 AND parent_pk1_value        = 'DIGTOT' )
  AND segment9 <> 'S'  -- exclude statutory adjustments
  AND :P_AMOUNT_TYPE = 'FUNCM'
  AND :P_SENDER_ID   =  'CC74'
  AND d.period_name  = a.period_name
  AND d.period_set_name = c.period_set_name
  AND ( (a.period_name = :P_PERIOD AND :P_PERIOD IS NOT NULL) OR
        (a.period_name = c.latest_opened_period_name AND :P_PERIOD IS NULL))
--
GROUP by a.period_name, segment1, segment2, segment3,a.currency_code ,c.currency_code, d.start_date
HAVING SUM(DECODE(a.currency_code,c.currency_code, (NVL(begin_balance_dr_beq,0) - NVL(begin_balance_cr_beq,0) + NVL(period_net_dr_beq,0) - NVL(period_net_cr_beq,0)),
              (NVL(begin_balance_dr,0)- NVL(begin_balance_cr,0) + NVL(period_net_dr,0) - NVL(period_net_cr,0)))) <> 0 
--end of FUNCM
--start of ORINM
UNION
SELECT a.period_name
      ,b.segment1
      ,b.segment2
      ,b.segment3
      ,a.currency_code
      ,'CC74' sender_id
      ,:P_AMOUNT_TYPE amount_type
      ,TO_CHAR(d.Start_Date,'MM')||'15'||TO_CHAR(d.Start_Date,'YYYY') effective_date
      ,(SELECT SUBSTR(parent_pk1_value,1)
          FROM fnd_tree_node ftn
              ,fnd_tree_version_vl ftv
         WHERE 1=1
           AND ftn.tree_code             = 'COMPANY MARS UNPUBLISHED' -- Changed the hierarchy. 03 Sep
           AND ftn.tree_structure_code   = 'GL_ACCT_FLEX'
           AND ftv.tree_code             = ftn.tree_code
           AND ftv.tree_structure_code   = ftn.tree_structure_code
           AND ftv.tree_version_name     = 'CURRENT'
           AND ftn.tree_version_id       = ftv.tree_version_id
           AND pk1_start_value           = b.segment1) "BUSINESS_UNIT"
      ,(SELECT SUBSTR(parent_pk1_value,1) -- Changed back from position 4 as the underscores are removed. 19 Oct
          FROM fnd_tree_node ftn
              ,FND_TREE_VERSION_VL ftv
         WHERE 1=1
           AND ftn.tree_code           = 'Company LE'
           AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
           AND ftv.tree_code           = ftn.tree_code
           AND ftv.tree_structure_code = ftn.tree_structure_code
           AND ftv.tree_version_name   = 'CURRENT'
           AND ftn.tree_version_id     = ftv.tree_version_id
           AND pk1_start_value         = b.segment1) "LEGAL_ENTITY"
      ,(SELECT parent_pk1_value
          FROM fnd_tree_node ftn
              ,fnd_tree_version_vl ftv
         WHERE 1=1
           AND ftn.tree_Code           =  'ACCOUNT MARS UNPUBLISHED'
           AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
           AND ftv.tree_Code           = ftn.tree_code
           AND ftv.tree_structure_code = ftn.tree_structure_code
           AND ftv.tree_version_name   = 'CURRENT'
           AND ftn.tree_version_id     = ftv.tree_version_id
           AND pk1_start_value         = b.segment2)  "MARS_ACCOUNT"
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
		,NULL analysis
     ,NULL type
     ,:P_RUN_TYPE run_type
     ,DECODE(a.currency_code,c.currency_code,SUM(NVL(begin_balance_dr_beq,0) - NVL(begin_balance_cr_beq,0)
              + NVL(period_net_dr_beq,0) - NVL(period_net_cr_beq,0)),
              SUM(NVL(begin_balance_dr,0)- NVL(begin_balance_cr,0) + NVL(period_net_dr,0) - NVL(period_net_cr,0))) amount
FROM gl_balances a
    ,gl_code_combinations b
    ,gl_ledgers c
    ,gl_periods d
WHERE a.code_combination_id = b.code_combination_id
  AND a.ledger_id = c.ledger_id
  AND c.ledger_category_code = 'ALC'      -- ALC for Reporting ledger
  AND c.name = 'FR_USD_RPT'
  AND c.currency_code = 'USD'    -- Include all USD functional currency Reporting books
  AND EXISTS  (SELECT 'X'
               FROM fnd_tree_node ftn
                   ,fnd_tree_version_vl ftv
               WHERE 1=1
               AND ftn.tree_Code           =  'COMPANY MARS UNPUBLISHED'
               AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
               AND ftv.tree_Code           = ftn.tree_code
               AND ftv.tree_structure_code = ftn.tree_structure_code
               AND ftv.tree_version_name   = 'CURRENT'
               AND ftn.tree_version_id     = ftv.tree_version_id
               AND pk1_start_value         = b.segment1
               AND parent_pk1_value        = 'DIGTOT' )
  AND segment9 <> 'S' -- exclude Statutory Adjustment
  AND :P_AMOUNT_TYPE    = 'ORINM'
  AND :P_SENDER_ID      =  'CC74'
  AND d.period_name     = a.period_name
  AND d.period_set_name = c.period_set_name
  AND ( (a.period_name = :P_PERIOD AND :P_PERIOD IS NOT NULL) OR
        (a.period_name = c.latest_opened_period_name AND :P_PERIOD IS NULL))
--
GROUP by a.period_name, segment1, segment2, segment3,a.currency_code, c.currency_code, d.start_date
HAVING SUM(DECODE(a.currency_code,c.currency_code, (NVL(begin_balance_dr_beq,0) - NVL(begin_balance_cr_beq,0) + NVL(period_net_dr_beq,0) - NVL(period_net_cr_beq,0)),
              (NVL(begin_balance_dr,0)- NVL(begin_balance_cr,0) + NVL(period_net_dr,0) - NVL(period_net_cr,0)))) <> 0
--end of ORINM
--start of USDRM USDRQ
UNION
SELECT a.period_name
      ,b.segment1
      ,b.segment2
      ,b.segment3
      ,a.currency_code
      ,'CC74' sender_id
      ,:P_AMOUNT_TYPE amount_type
      ,TO_CHAR(d.Start_Date,'MM')||'15'||TO_CHAR(d.Start_Date,'YYYY') effective_date
      ,(SELECT SUBSTR(parent_PK1_VALUE,1)
        FROM fnd_tree_node ftn
            ,fnd_tree_version_vl ftv
        WHERE 1=1
          AND ftn.tree_Code           =  'COMPANY MARS UNPUBLISHED' -- Changed the hierarchy. 03 Sep
          AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
          AND ftv.tree_Code           = ftn.tree_code
          AND ftv.tree_structure_code = ftn.tree_structure_code
          AND ftv.tree_version_name   = 'CURRENT'
          AND ftn.tree_version_id     = ftv.tree_version_id
          AND pk1_start_value         = b.segment1) "BUSINESS_UNIT" 
      ,(SELECT SUBSTR(parent_PK1_VALUE,1) -- Changed back from position 4 as the underscores are removed. 19 Oct
          FROM fnd_tree_node ftn
              ,fnd_tree_version_vl ftv
         WHERE 1=1
           AND ftn.tree_Code           =  'Company LE'
           AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
           AND ftv.tree_Code           = ftn.tree_code
           AND ftv.tree_structure_code = ftn.tree_structure_code
           AND ftv.tree_version_name   = 'CURRENT'
           AND ftn.tree_version_id     = ftv.tree_version_id
           AND pk1_start_value         = b.segment1) "LEGAL_ENTITY" 
      ,(SELECT parent_pk1_value
          FROM fnd_tree_node ftn
              ,fnd_tree_version_vl ftv
         WHERE 1=1
           AND ftn.tree_Code           =  'ACCOUNT MARS UNPUBLISHED'
           AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
           AND ftv.tree_Code           = ftn.tree_code
           AND ftv.tree_structure_code = ftn.tree_structure_code
           AND ftv.tree_version_name   = 'CURRENT'
           AND ftn.tree_version_id     = ftv.tree_version_id
           AND pk1_start_value         = b.segment2)  "MARS_ACCOUNT" 
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
                      AND  ftv.tree_version_name   = 'CURRENT'
                      AND  ftn.tree_version_id     = ftv.tree_version_id
                      AND  pk1_start_value         = b.segment3 )
            END   
         FROM   fnd_tree_node ftn
               ,fnd_tree_version_vl ftv
         WHERE 1=1
           AND ftn.tree_Code           = 'ACCOUNT MARS IME UNPUBLISHED'
           AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
           AND ftv.tree_Code           = ftn.tree_code
           AND ftv.tree_structure_code = ftn.tree_structure_code
           AND ftv.tree_version_name   = 'CURRENT'
           AND ftn.tree_version_id     = ftv.tree_version_id
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
                      AND  ftv.tree_version_name   = 'CURRENT'
                      AND  ftn.tree_version_id     = ftv.tree_version_id
                      AND  pk1_start_value         = b.segment3 )
            END   
         FROM   fnd_tree_node ftn
               ,fnd_tree_version_vl ftv
         WHERE 1=1
           AND ftn.tree_Code           = 'ACCOUNT MARS ILE UNPUBLISHED'
           AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
           AND ftv.tree_Code           = ftn.tree_code
           AND ftv.tree_structure_code = ftn.tree_structure_code
           AND ftv.tree_version_name   = 'CURRENT'
           AND ftn.tree_version_id     = ftv.tree_version_id
           AND pk1_start_value         = b.segment2),'000000') "ILE" 
      ,NULL analysis
      ,NULL type
     ,:P_RUN_TYPE run_type
      ,SUM(NVL(a.begin_balance_dr,0)- NVL(a.begin_balance_cr,0) + NVL(a.period_net_dr,0) - NVL(a.period_net_cr,0)) amount
FROM gl_balances a
    ,gl_code_combinations b
    ,gl_ledgers c
    ,gl_periods d
WHERE a.code_combination_id = b.code_combination_id
  AND a.ledger_id     = c.ledger_id
  AND c.ledger_category_code = 'ALC'      -- reporting ledger
  AND c.name          = 'FR_USD_RPT'
  AND c.currency_code = 'USD'   -- with functional currency as USD
  AND a.currency_code = c.currency_code  -- only USD balances
  AND EXISTS (SELECT 'X'
               FROM fnd_tree_node ftn
                   ,fnd_tree_version_vl ftv
               WHERE 1=1
               AND ftn.tree_Code           =  'COMPANY MARS UNPUBLISHED'
               AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
               AND ftv.tree_Code           = ftn.tree_code
               AND ftv.tree_structure_code = ftn.tree_structure_code
               AND ftv.tree_version_name   = 'CURRENT'
               AND ftn.tree_version_id     = ftv.tree_version_id
               AND pk1_start_value         = b.segment1
               AND parent_pk1_value IN ('DIGTOT') )
  AND b.segment9 <> 'S'  -- exclude statutory adjustments
  AND :P_AMOUNT_TYPE IN ('USDRM','USDRQ')
  AND :P_SENDER_ID      =  'CC74'
  AND d.period_name     = a.period_name
  AND d.period_set_name = c.period_set_name
  AND ( (a.period_name = :P_PERIOD AND :P_PERIOD IS NOT NULL) OR
        (a.period_name = c.latest_opened_period_name AND :P_PERIOD IS NULL))
--
GROUP by a.period_name, segment1, segment2, segment3 ,a.currency_code, d.start_date
HAVING SUM(NVL(begin_balance_dr,0)- NVL(begin_balance_cr,0) + NVL(period_net_dr,0) - NVL(period_net_cr,0)) <> 0
--
--End of France
--
UNION
--
--Netherlands
--
--start of FUNCM
SELECT a.period_name
      ,b.segment1
      ,b.segment2
      ,b.segment3
      ,a.currency_code
      ,'CC74' sender_id
      ,:P_AMOUNT_TYPE amount_type
      ,TO_CHAR(d.Start_Date,'MM')||'15'||TO_CHAR(d.Start_Date,'YYYY') effective_date
      ,(SELECT SUBSTR(parent_PK1_VALUE,1)
          FROM fnd_tree_node ftn
              ,fnd_tree_version_vl ftv
         WHERE 1=1
           AND ftn.tree_Code             = 'COMPANY MARS UNPUBLISHED' -- Changed the hierarchy. 03 Sep
           AND ftn.tree_structure_code   = 'GL_ACCT_FLEX'
           AND ftv.tree_Code             = ftn.tree_code
           AND ftv.tree_structure_code   = ftn.tree_structure_code
           AND ftv.tree_version_name     = 'CURRENT'
           AND ftn.tree_version_id       = ftv.tree_version_id
           AND pk1_start_value           = b.segment1) "BUSINESS_UNIT"
       ,(SELECT SUBSTR(parent_pk1_value,1) -- Changed back from position 4 as the underscores are removed. 19 Oct
           FROM fnd_tree_node ftn
                ,fnd_tree_version_vl ftv
          WHERE 1=1
            AND ftn.tree_Code           = 'Company LE'
            AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
            AND ftv.tree_Code           = ftn.tree_code
            AND ftv.tree_structure_code = ftn.tree_structure_code
            AND ftv.tree_version_name   = 'CURRENT'
            AND ftn.tree_version_id     = ftv.tree_version_id
            AND pk1_start_value         = b.segment1) "LEGAL_ENTITY"
       ,(SELECT parent_pk1_value
           FROM fnd_tree_node ftn
               ,fnd_tree_version_vl ftv
          WHERE 1=1
            AND ftn.tree_Code            = 'ACCOUNT MARS UNPUBLISHED'
            AND ftn.tree_structure_code  = 'GL_ACCT_FLEX'
            AND ftv.tree_Code            = ftn.tree_code
            AND ftv.tree_structure_code  = ftn.tree_structure_code
            AND ftv.tree_version_name    = 'CURRENT'
            AND ftn.tree_version_id      = ftv.tree_version_id
            AND pk1_start_value          = b.segment2)  "MARS_ACCOUNT"
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
                      AND  ftv.tree_version_name   = 'CURRENT'
                      AND  ftn.tree_version_id     = ftv.tree_version_id
                      AND  pk1_start_value         = b.segment3 )
            END   
         FROM   fnd_tree_node ftn
               ,fnd_tree_version_vl ftv
         WHERE 1=1
           AND ftn.tree_Code           = 'ACCOUNT MARS IME UNPUBLISHED'
           AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
           AND ftv.tree_Code           = ftn.tree_code
           AND ftv.tree_structure_code = ftn.tree_structure_code
           AND ftv.tree_version_name   = 'CURRENT'
           AND ftn.tree_version_id     = ftv.tree_version_id
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
                      AND  ftv.tree_version_name   = 'CURRENT'
                      AND  ftn.tree_version_id     = ftv.TREE_VERSION_ID
                      AND  pk1_start_value         = b.segment3 )
            END   
         FROM   fnd_tree_node ftn
               ,fnd_tree_version_vl ftv
         WHERE 1=1
           AND ftn.tree_Code           = 'ACCOUNT MARS ILE UNPUBLISHED'
           AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
           AND ftv.tree_Code           = ftn.tree_code
           AND ftv.tree_structure_code = ftn.tree_structure_code
           AND ftv.tree_version_name   = 'CURRENT'
           AND ftn.tree_version_id     = ftv.TREE_VERSION_ID
           AND pk1_start_value         = b.segment2),'000000') "ILE" 
      ,NULL analysis
      ,NULL type
      ,:P_RUN_TYPE run_type
      ,SUM(NVL(begin_balance_dr,0)- NVL(begin_balance_cr,0) + NVL(period_net_dr,0) - NVL(period_net_cr,0)) amount
FROM gl_balances a
    ,gl_code_combinations b
    ,gl_ledgers c
    ,gl_periods d
WHERE a.code_combination_id = b.code_combination_id
  AND a.ledger_id = c.ledger_id
  AND a.currency_code = c.currency_code -- functional currency
  AND 'EUR' = (SELECT SUBSTR(parent_PK1_VALUE,4)
               FROM   fnd_tree_node ftn
                     ,fnd_tree_version_vl ftv
               WHERE 1=1
                 AND ftn.tree_Code           =  'Company FCY'
                 AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
                 AND ftv.tree_Code           = ftn.tree_code
                 AND ftv.tree_structure_code = ftn.tree_structure_code
                 AND ftv.tree_version_name   = 'CURRENT'
                 AND ftn.tree_version_id     = ftv.tree_version_id
                 AND pk1_start_value         = b.segment1)
  AND c.name = 'NL_EUR_PRM'
  AND EXISTS  (SELECT 'X'
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
  AND segment9 <> 'S'              -- exclude statutory adjustments
  AND :P_AMOUNT_TYPE = 'FUNCM'
  AND :P_SENDER_ID =  'CC74'
  AND d.period_name = a.period_name
  AND d.period_set_name = c.period_set_name
  AND ( (a.period_name = :P_PERIOD AND :P_PERIOD IS NOT NULL) OR
        (a.period_name = c.latest_opened_period_name AND :P_PERIOD IS NULL))
--
  GROUP by a.period_name, segment1, segment2, segment3,a.currency_code, d.start_date
  HAVING SUM(NVL(begin_balance_dr,0)- NVL(begin_balance_cr,0) + NVL(period_net_dr,0) - NVL(period_net_cr,0)) <> 0
UNION
  SELECT a.period_name
        ,b.segment1
      ,b.segment2
      ,b.segment3
      ,a.currency_code
      ,'CC74' sender_id
      ,:P_AMOUNT_TYPE amount_type
      ,TO_CHAR(d.Start_Date,'MM')||'15'||TO_CHAR(d.Start_Date,'YYYY') effective_date
      ,(SELECT SUBSTR(parent_pk1_value,1)
          FROM fnd_tree_node ftn
              ,fnd_tree_version_vl ftv
         WHERE 1=1
           AND ftn.tree_code           =  'COMPANY MARS UNPUBLISHED' -- Changed the hierarchy. 03 Sep
           AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
           AND ftv.tree_Code           = ftn.tree_code
           AND ftv.tree_structure_code = ftn.tree_structure_code
           AND ftv.tree_version_name   = 'CURRENT'
           AND ftn.tree_version_id     = ftv.tree_version_id
           AND pk1_start_value         = b.segment1) "BUSINESS_UNIT"
      , (SELECT SUBSTR(parent_PK1_VALUE,1) -- Changed back from position 4 as the underscores are removed. 19 Oct
           FROM fnd_tree_node ftn
               ,fnd_tree_version_vl ftv
          WHERE 1=1
            AND ftn.tree_Code           =  'Company LE'
            AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
            AND ftv.tree_Code           = ftn.tree_code
            AND ftv.tree_structure_code = ftn.tree_structure_code
            AND ftv.tree_version_name   = 'CURRENT'
            AND ftn.tree_version_id     = ftv.tree_version_id
            AND pk1_start_value         = b.segment1) "LEGAL_ENTITY"
      ,(SELECT parent_pk1_value
          FROM fnd_tree_node ftn
              ,fnd_tree_version_vl ftv
         WHERE 1=1
           AND ftn.tree_Code            =  'ACCOUNT MARS UNPUBLISHED'
           AND ftn.tree_structure_code  = 'GL_ACCT_FLEX'
           AND ftv.tree_Code            = ftn.tree_code
           AND ftv.tree_structure_code  = ftn.tree_structure_code
           AND ftv.tree_version_name    = 'CURRENT'
           AND ftn.tree_version_id      = ftv.tree_version_id
           AND pk1_start_value          = b.segment2)  "MARS_ACCOUNT"
        ,NVL((SELECT 
        CASE ftn.parent_pk1_value 
           WHEN 'N' THEN '000000' 
            ELSE ( SELECT  parent_pk1_value
                     FROM  fnd_tree_node ftn
                          ,fnd_tree_version_vl ftv
                    WHERE  1=1
                      AND  ftn.tree_Code           = 'TP MARS IBU UNPUBLISHED'
                      AND  ftn.tree_structure_code = 'GL_ACCT_FLEX'
                      AND  ftv.tree_Code           = ftn.tree_code
                      AND  ftv.tree_structure_code = ftn.tree_structure_code
                      AND  ftv.tree_version_name   = 'CURRENT'
                      AND  ftn.tree_version_id     = ftv.tree_version_id
                      AND  pk1_start_value         = b.segment3 )
            END   
         FROM   fnd_tree_node ftn
               ,fnd_tree_version_vl ftv
         WHERE 1=1
           AND ftn.tree_Code           = 'ACCOUNT MARS IME UNPUBLISHED'
           AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
           AND ftv.tree_Code           = ftn.tree_code
           AND ftv.tree_structure_code = ftn.tree_structure_code
           AND ftv.tree_version_name   = 'CURRENT'
           AND ftn.tree_version_id     = ftv.tree_version_id
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
                      AND  ftv.tree_version_name   = 'CURRENT'
                      AND  ftn.tree_version_id     = ftv.tree_version_id
                      AND  pk1_start_value         = b.segment3 )
            END   
         FROM   fnd_tree_node ftn
               ,fnd_tree_version_vl ftv
         WHERE 1=1
           AND ftn.tree_Code           = 'ACCOUNT MARS ILE UNPUBLISHED'
           AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
           AND ftv.tree_Code           = ftn.tree_code
           AND ftv.tree_structure_code = ftn.tree_structure_code
           AND ftv.tree_version_name   = 'CURRENT'
           AND ftn.tree_version_id     = ftv.tree_version_id
           AND pk1_start_value         = b.segment2),'000000') "ILE" 
     ,NULL analysis
     ,NULL type
     ,:P_RUN_TYPE run_type
     ,DECODE(a.currency_code,c.currency_code,SUM(NVL(begin_balance_dr_beq,0) - NVL(begin_balance_cr_beq,0)
              + NVL(period_net_dr_beq,0) - NVL(period_net_cr_beq,0)),
              SUM(NVL(begin_balance_dr,0)- NVL(begin_balance_cr,0) + NVL(period_net_dr,0) - NVL(period_net_cr,0))) amount
FROM gl_balances a
    ,gl_code_combinations b
    ,gl_ledgers c
    ,gl_periods d
WHERE a.code_combination_id = b.code_combination_id
  AND a.ledger_id = c.ledger_id
  AND c.ledger_category_code = 'ALC'      -- ALC for Reporting ledger
  AND c.currency_code = 'USD'    -- Include all USD functional currency Reporting books
  AND 'USD' = (SELECT SUBSTR(parent_PK1_VALUE,4)
                 FROM fnd_tree_node ftn
                     ,fnd_tree_version_vl ftv
                WHERE 1=1
                  AND ftn.tree_Code           =  'Company FCY'
                  AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
                  AND ftv.tree_Code           = ftn.tree_code
                  AND ftv.tree_structure_code = ftn.tree_structure_code
                  AND ftv.tree_version_name   = 'CURRENT'
                  AND ftn.tree_version_id     = ftv.tree_version_id
                  AND pk1_start_value         = b.segment1)
  AND c.name = 'NL_USD_FCY'
  AND EXISTS (SELECT 'X'
                FROM fnd_tree_node ftn
                    ,fnd_tree_version_vl ftv
               WHERE 1=1
                 AND ftn.tree_Code           = 'COMPANY MARS UNPUBLISHED'
                 AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
                 AND ftv.tree_Code           = ftn.tree_code
                 AND ftv.tree_structure_code = ftn.tree_structure_code
                 AND ftv.tree_version_name   = 'CURRENT'
                 AND ftn.tree_version_id     = ftv.tree_version_id
                 AND pk1_start_value         = b.segment1
                 AND parent_pk1_value        = 'DIGTOT' )
  AND segment9 <> 'S'  -- exclude statutory adjustments
  AND :P_AMOUNT_TYPE = 'FUNCM'
  AND :P_SENDER_ID   =  'CC74'
  AND d.period_name  = a.period_name
  AND d.period_set_name = c.period_set_name
  AND ( (a.period_name = :P_PERIOD AND :P_PERIOD IS NOT NULL) OR
        (a.period_name = c.latest_opened_period_name AND :P_PERIOD IS NULL))
--
GROUP by a.period_name, segment1, segment2, segment3,a.currency_code ,c.currency_code, d.start_date
HAVING SUM(DECODE(a.currency_code,c.currency_code, (NVL(begin_balance_dr_beq,0) - NVL(begin_balance_cr_beq,0) + NVL(period_net_dr_beq,0) - NVL(period_net_cr_beq,0)),
              (NVL(begin_balance_dr,0)- NVL(begin_balance_cr,0) + NVL(period_net_dr,0) - NVL(period_net_cr,0)))) <> 0 
--end of FUNCM
--start of ORINM
UNION
SELECT a.period_name
      ,b.segment1
      ,b.segment2
      ,b.segment3
      ,a.currency_code
      ,'CC74' sender_id
      ,:P_AMOUNT_TYPE amount_type
      ,TO_CHAR(d.Start_Date,'MM')||'15'||TO_CHAR(d.Start_Date,'YYYY') effective_date
      ,(SELECT SUBSTR(parent_pk1_value,1)
          FROM fnd_tree_node ftn
              ,fnd_tree_version_vl ftv
         WHERE 1=1
           AND ftn.tree_code             = 'COMPANY MARS UNPUBLISHED' -- Changed the hierarchy. 03 Sep
           AND ftn.tree_structure_code   = 'GL_ACCT_FLEX'
           AND ftv.tree_code             = ftn.tree_code
           AND ftv.tree_structure_code   = ftn.tree_structure_code
           AND ftv.tree_version_name     = 'CURRENT'
           AND ftn.tree_version_id       = ftv.tree_version_id
           AND pk1_start_value           = b.segment1) "BUSINESS_UNIT"
      ,(SELECT SUBSTR(parent_pk1_value,1) -- Changed back from position 4 as the underscores are removed. 19 Oct
          FROM fnd_tree_node ftn
              ,FND_TREE_VERSION_VL ftv
         WHERE 1=1
           AND ftn.tree_code           = 'Company LE'
           AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
           AND ftv.tree_code           = ftn.tree_code
           AND ftv.tree_structure_code = ftn.tree_structure_code
           AND ftv.tree_version_name   = 'CURRENT'
           AND ftn.tree_version_id     = ftv.tree_version_id
           AND pk1_start_value         = b.segment1) "LEGAL_ENTITY"
      ,(SELECT parent_pk1_value
          FROM fnd_tree_node ftn
              ,fnd_tree_version_vl ftv
         WHERE 1=1
           AND ftn.tree_Code           =  'ACCOUNT MARS UNPUBLISHED'
           AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
           AND ftv.tree_Code           = ftn.tree_code
           AND ftv.tree_structure_code = ftn.tree_structure_code
           AND ftv.tree_version_name   = 'CURRENT'
           AND ftn.tree_version_id     = ftv.tree_version_id
           AND pk1_start_value         = b.segment2)  "MARS_ACCOUNT"
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
		,NULL analysis
     ,NULL type
     ,:P_RUN_TYPE run_type
     ,DECODE(a.currency_code,c.currency_code,SUM(NVL(begin_balance_dr_beq,0) - NVL(begin_balance_cr_beq,0)
              + NVL(period_net_dr_beq,0) - NVL(period_net_cr_beq,0)),
              SUM(NVL(begin_balance_dr,0)- NVL(begin_balance_cr,0) + NVL(period_net_dr,0) - NVL(period_net_cr,0))) amount
FROM gl_balances a
    ,gl_code_combinations b
    ,gl_ledgers c
    ,gl_periods d
WHERE a.code_combination_id = b.code_combination_id
  AND a.ledger_id = c.ledger_id
  AND c.ledger_category_code = 'ALC'      -- ALC for Reporting ledger
  AND c.name IN ('NL_USD_RPT','AE_USD_RPT', 'BR_USD_RPT' , 'CN_USD_RPT' , 'ES_USD_RPT' , 'GB_USD_RPT' , 'IN_USD_RPT' , 'MT_USD_RPT' , 'MX_USD_RPT',
'SG_USD_RPT','ZA_USD_RPT','AU_USD_RPT','DE_USD_RPT','JP_USD_RPT','KR_USD_RPT')
  AND c.currency_code = 'USD'    -- Include all USD functional currency Reporting books
  AND EXISTS  (SELECT 'X'
               FROM fnd_tree_node ftn
                   ,fnd_tree_version_vl ftv
               WHERE 1=1
               AND ftn.tree_Code           =  'COMPANY MARS UNPUBLISHED'
               AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
               AND ftv.tree_Code           = ftn.tree_code
               AND ftv.tree_structure_code = ftn.tree_structure_code
               AND ftv.tree_version_name   = 'CURRENT'
               AND ftn.tree_version_id     = ftv.tree_version_id
               AND pk1_start_value         = b.segment1
               AND parent_pk1_value        = 'DIGTOT' )
  AND segment9 <> 'S' -- exclude Statutory Adjustment
  AND :P_AMOUNT_TYPE    = 'ORINM'
  AND :P_SENDER_ID      =  'CC74'
  AND d.period_name     = a.period_name
  AND d.period_set_name = c.period_set_name
  AND ( (a.period_name = :P_PERIOD AND :P_PERIOD IS NOT NULL) OR
        (a.period_name = c.latest_opened_period_name AND :P_PERIOD IS NULL))
--
GROUP by a.period_name, segment1, segment2, segment3,a.currency_code, c.currency_code, d.start_date
HAVING SUM(DECODE(a.currency_code,c.currency_code, (NVL(begin_balance_dr_beq,0) - NVL(begin_balance_cr_beq,0) + NVL(period_net_dr_beq,0) - NVL(period_net_cr_beq,0)),
              (NVL(begin_balance_dr,0)- NVL(begin_balance_cr,0) + NVL(period_net_dr,0) - NVL(period_net_cr,0)))) <> 0
--end of ORINM
--start of USDRM USDRQ
UNION
SELECT a.period_name
      ,b.segment1
      ,b.segment2
      ,b.segment3
      ,a.currency_code
      ,'CC74' sender_id
      ,:P_AMOUNT_TYPE amount_type
      ,TO_CHAR(d.Start_Date,'MM')||'15'||TO_CHAR(d.Start_Date,'YYYY') effective_date
      ,(SELECT SUBSTR(parent_PK1_VALUE,1)
        FROM fnd_tree_node ftn
            ,fnd_tree_version_vl ftv
        WHERE 1=1
          AND ftn.tree_Code           =  'COMPANY MARS UNPUBLISHED' -- Changed the hierarchy. 03 Sep
          AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
          AND ftv.tree_Code           = ftn.tree_code
          AND ftv.tree_structure_code = ftn.tree_structure_code
          AND ftv.tree_version_name   = 'CURRENT'
          AND ftn.tree_version_id     = ftv.tree_version_id
          AND pk1_start_value         = b.segment1) "BUSINESS_UNIT" 
      ,(SELECT SUBSTR(parent_PK1_VALUE,1) -- Changed back from position 4 as the underscores are removed. 19 Oct
          FROM fnd_tree_node ftn
              ,fnd_tree_version_vl ftv
         WHERE 1=1
           AND ftn.tree_Code           =  'Company LE'
           AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
           AND ftv.tree_Code           = ftn.tree_code
           AND ftv.tree_structure_code = ftn.tree_structure_code
           AND ftv.tree_version_name   = 'CURRENT'
           AND ftn.tree_version_id     = ftv.tree_version_id
           AND pk1_start_value         = b.segment1) "LEGAL_ENTITY" 
      ,(SELECT parent_pk1_value
          FROM fnd_tree_node ftn
              ,fnd_tree_version_vl ftv
         WHERE 1=1
           AND ftn.tree_Code           =  'ACCOUNT MARS UNPUBLISHED'
           AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
           AND ftv.tree_Code           = ftn.tree_code
           AND ftv.tree_structure_code = ftn.tree_structure_code
           AND ftv.tree_version_name   = 'CURRENT'
           AND ftn.tree_version_id     = ftv.tree_version_id
           AND pk1_start_value         = b.segment2)  "MARS_ACCOUNT" 
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
                      AND  ftv.tree_version_name   = 'CURRENT'
                      AND  ftn.tree_version_id     = ftv.tree_version_id
                      AND  pk1_start_value         = b.segment3 )
            END   
         FROM   fnd_tree_node ftn
               ,fnd_tree_version_vl ftv
         WHERE 1=1
           AND ftn.tree_Code           = 'ACCOUNT MARS IME UNPUBLISHED'
           AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
           AND ftv.tree_Code           = ftn.tree_code
           AND ftv.tree_structure_code = ftn.tree_structure_code
           AND ftv.tree_version_name   = 'CURRENT'
           AND ftn.tree_version_id     = ftv.tree_version_id
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
                      AND  ftv.tree_version_name   = 'CURRENT'
                      AND  ftn.tree_version_id     = ftv.tree_version_id
                      AND  pk1_start_value         = b.segment3 )
            END   
         FROM   fnd_tree_node ftn
               ,fnd_tree_version_vl ftv
         WHERE 1=1
           AND ftn.tree_Code           = 'ACCOUNT MARS ILE UNPUBLISHED'
           AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
           AND ftv.tree_Code           = ftn.tree_code
           AND ftv.tree_structure_code = ftn.tree_structure_code
           AND ftv.tree_version_name   = 'CURRENT'
           AND ftn.tree_version_id     = ftv.tree_version_id
           AND pk1_start_value         = b.segment2),'000000') "ILE" 
      ,NULL analysis
      ,NULL type
     ,:P_RUN_TYPE run_type
      ,SUM(NVL(a.begin_balance_dr,0)- NVL(a.begin_balance_cr,0) + NVL(a.period_net_dr,0) - NVL(a.period_net_cr,0)) amount
FROM gl_balances a
    ,gl_code_combinations b
    ,gl_ledgers c
    ,gl_periods d
WHERE a.code_combination_id = b.code_combination_id
  AND a.ledger_id     = c.ledger_id
  AND c.ledger_category_code = 'ALC'      -- reporting ledger
  AND c.name IN('NL_USD_RPT','AE_USD_RPT', 'BR_USD_RPT' , 'CN_USD_RPT' , 'ES_USD_RPT' , 'GB_USD_RPT' , 'IN_USD_RPT' , 'MT_USD_RPT' , 'MX_USD_RPT',
'SG_USD_RPT','ZA_USD_RPT','AU_USD_RPT','DE_USD_RPT','JP_USD_RPT','KR_USD_RPT')
  AND c.currency_code = 'USD'   -- with functional currency as USD
  AND a.currency_code = c.currency_code  -- only USD balances
  AND EXISTS (SELECT 'X'
               FROM fnd_tree_node ftn
                   ,fnd_tree_version_vl ftv
               WHERE 1=1
               AND ftn.tree_Code           =  'COMPANY MARS UNPUBLISHED'
               AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
               AND ftv.tree_Code           = ftn.tree_code
               AND ftv.tree_structure_code = ftn.tree_structure_code
               AND ftv.tree_version_name   = 'CURRENT'
               AND ftn.tree_version_id     = ftv.tree_version_id
               AND pk1_start_value         = b.segment1
               AND parent_pk1_value IN ('DIGTOT') )
  AND b.segment9 <> 'S'  -- exclude statutory adjustments
  AND :P_AMOUNT_TYPE IN ('USDRM','USDRQ')
  AND :P_SENDER_ID      =  'CC74'
  AND d.period_name     = a.period_name
  AND d.period_set_name = c.period_set_name
  AND ( (a.period_name = :P_PERIOD AND :P_PERIOD IS NOT NULL) OR
        (a.period_name = c.latest_opened_period_name AND :P_PERIOD IS NULL))
--
GROUP by a.period_name, segment1, segment2, segment3 ,a.currency_code, d.start_date
HAVING SUM(NVL(begin_balance_dr,0)- NVL(begin_balance_cr,0) + NVL(period_net_dr,0) - NVL(period_net_cr,0)) <> 0
UNION
--
--Spain, Malta EUR
--
--start of FUNCM
SELECT a.period_name
      ,b.segment1
      ,b.segment2
      ,b.segment3
      ,a.currency_code
      ,'CC74' sender_id
      ,:P_AMOUNT_TYPE amount_type
      ,TO_CHAR(d.Start_Date,'MM')||'15'||TO_CHAR(d.Start_Date,'YYYY') effective_date
      ,(SELECT SUBSTR(parent_PK1_VALUE,1)
          FROM fnd_tree_node ftn
              ,fnd_tree_version_vl ftv
         WHERE 1=1
           AND ftn.tree_Code             = 'COMPANY MARS UNPUBLISHED' -- Changed the hierarchy. 03 Sep
           AND ftn.tree_structure_code   = 'GL_ACCT_FLEX'
           AND ftv.tree_Code             = ftn.tree_code
           AND ftv.tree_structure_code   = ftn.tree_structure_code
           AND ftv.tree_version_name     = 'CURRENT'
           AND ftn.tree_version_id       = ftv.tree_version_id
           AND pk1_start_value           = b.segment1) "BUSINESS_UNIT"
       ,(SELECT SUBSTR(parent_pk1_value,1) -- Changed back from position 4 as the underscores are removed. 19 Oct
           FROM fnd_tree_node ftn
                ,fnd_tree_version_vl ftv
          WHERE 1=1
            AND ftn.tree_Code           = 'Company LE'
            AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
            AND ftv.tree_Code           = ftn.tree_code
            AND ftv.tree_structure_code = ftn.tree_structure_code
            AND ftv.tree_version_name   = 'CURRENT'
            AND ftn.tree_version_id     = ftv.tree_version_id
            AND pk1_start_value         = b.segment1) "LEGAL_ENTITY"
       ,(SELECT parent_pk1_value
           FROM fnd_tree_node ftn
               ,fnd_tree_version_vl ftv
          WHERE 1=1
            AND ftn.tree_Code            = 'ACCOUNT MARS UNPUBLISHED'
            AND ftn.tree_structure_code  = 'GL_ACCT_FLEX'
            AND ftv.tree_Code            = ftn.tree_code
            AND ftv.tree_structure_code  = ftn.tree_structure_code
            AND ftv.tree_version_name    = 'CURRENT'
            AND ftn.tree_version_id      = ftv.tree_version_id
            AND pk1_start_value          = b.segment2)  "MARS_ACCOUNT"
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
                      AND  ftv.tree_version_name   = 'CURRENT'
                      AND  ftn.tree_version_id     = ftv.tree_version_id
                      AND  pk1_start_value         = b.segment3 )
            END   
         FROM   fnd_tree_node ftn
               ,fnd_tree_version_vl ftv
         WHERE 1=1
           AND ftn.tree_Code           = 'ACCOUNT MARS IME UNPUBLISHED'
           AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
           AND ftv.tree_Code           = ftn.tree_code
           AND ftv.tree_structure_code = ftn.tree_structure_code
           AND ftv.tree_version_name   = 'CURRENT'
           AND ftn.tree_version_id     = ftv.tree_version_id
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
                      AND  ftv.tree_version_name   = 'CURRENT'
                      AND  ftn.tree_version_id     = ftv.TREE_VERSION_ID
                      AND  pk1_start_value         = b.segment3 )
            END   
         FROM   fnd_tree_node ftn
               ,fnd_tree_version_vl ftv
         WHERE 1=1
           AND ftn.tree_Code           = 'ACCOUNT MARS ILE UNPUBLISHED'
           AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
           AND ftv.tree_Code           = ftn.tree_code
           AND ftv.tree_structure_code = ftn.tree_structure_code
           AND ftv.tree_version_name   = 'CURRENT'
           AND ftn.tree_version_id     = ftv.TREE_VERSION_ID
           AND pk1_start_value         = b.segment2),'000000') "ILE" 
      ,NULL analysis
      ,NULL type
      ,:P_RUN_TYPE run_type
      ,SUM(NVL(begin_balance_dr,0)- NVL(begin_balance_cr,0) + NVL(period_net_dr,0) - NVL(period_net_cr,0)) amount
FROM gl_balances a
    ,gl_code_combinations b
    ,gl_ledgers c
    ,gl_periods d
WHERE a.code_combination_id = b.code_combination_id
  AND a.ledger_id = c.ledger_id
  AND a.currency_code = c.currency_code -- functional currency
  AND 'EUR' = (SELECT SUBSTR(parent_PK1_VALUE,4)
               FROM   fnd_tree_node ftn
                     ,fnd_tree_version_vl ftv
               WHERE 1=1
                 AND ftn.tree_Code           =  'Company FCY'
                 AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
                 AND ftv.tree_Code           = ftn.tree_code
                 AND ftv.tree_structure_code = ftn.tree_structure_code
                 AND ftv.tree_version_name   = 'CURRENT'
                 AND ftn.tree_version_id     = ftv.tree_version_id
                 AND pk1_start_value         = b.segment1)
  AND c.name IN('ES_EUR_PRM', 'MT_EUR_PRM','DE_EUR_PRM')
  AND EXISTS  (SELECT 'X'
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
  AND segment9 <> 'S'              -- exclude statutory adjustments
  AND :P_AMOUNT_TYPE = 'FUNCM'
  AND :P_SENDER_ID =  'CC74'
  AND d.period_name = a.period_name
  AND d.period_set_name = c.period_set_name
  AND ( (a.period_name = :P_PERIOD AND :P_PERIOD IS NOT NULL) OR
        (a.period_name = c.latest_opened_period_name AND :P_PERIOD IS NULL))
--
  GROUP by a.period_name, segment1, segment2, segment3,a.currency_code, d.start_date
  HAVING SUM(NVL(begin_balance_dr,0)- NVL(begin_balance_cr,0) + NVL(period_net_dr,0) - NVL(period_net_cr,0)) <> 0
--
--
UNION
--
--UAE Primary
--
--start of FUNCM
SELECT a.period_name
      ,b.segment1
      ,b.segment2
      ,b.segment3
      ,a.currency_code
      ,'CC74' sender_id
      ,:P_AMOUNT_TYPE amount_type
      ,TO_CHAR(d.Start_Date,'MM')||'15'||TO_CHAR(d.Start_Date,'YYYY') effective_date
      ,(SELECT SUBSTR(parent_PK1_VALUE,1)
          FROM fnd_tree_node ftn
              ,fnd_tree_version_vl ftv
         WHERE 1=1
           AND ftn.tree_Code             = 'COMPANY MARS UNPUBLISHED' -- Changed the hierarchy. 03 Sep
           AND ftn.tree_structure_code   = 'GL_ACCT_FLEX'
           AND ftv.tree_Code             = ftn.tree_code
           AND ftv.tree_structure_code   = ftn.tree_structure_code
           AND ftv.tree_version_name     = 'CURRENT'
           AND ftn.tree_version_id       = ftv.tree_version_id
           AND pk1_start_value           = b.segment1) "BUSINESS_UNIT"
       ,(SELECT SUBSTR(parent_pk1_value,1) -- Changed back from position 4 as the underscores are removed. 19 Oct
           FROM fnd_tree_node ftn
                ,fnd_tree_version_vl ftv
          WHERE 1=1
            AND ftn.tree_Code           = 'Company LE'
            AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
            AND ftv.tree_Code           = ftn.tree_code
            AND ftv.tree_structure_code = ftn.tree_structure_code
            AND ftv.tree_version_name   = 'CURRENT'
            AND ftn.tree_version_id     = ftv.tree_version_id
            AND pk1_start_value         = b.segment1) "LEGAL_ENTITY"
       ,(SELECT parent_pk1_value
           FROM fnd_tree_node ftn
               ,fnd_tree_version_vl ftv
          WHERE 1=1
            AND ftn.tree_Code            = 'ACCOUNT MARS UNPUBLISHED'
            AND ftn.tree_structure_code  = 'GL_ACCT_FLEX'
            AND ftv.tree_Code            = ftn.tree_code
            AND ftv.tree_structure_code  = ftn.tree_structure_code
            AND ftv.tree_version_name    = 'CURRENT'
            AND ftn.tree_version_id      = ftv.tree_version_id
            AND pk1_start_value          = b.segment2)  "MARS_ACCOUNT"
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
                      AND  ftv.tree_version_name   = 'CURRENT'
                      AND  ftn.tree_version_id     = ftv.tree_version_id
                      AND  pk1_start_value         = b.segment3 )
            END   
         FROM   fnd_tree_node ftn
               ,fnd_tree_version_vl ftv
         WHERE 1=1
           AND ftn.tree_Code           = 'ACCOUNT MARS IME UNPUBLISHED'
           AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
           AND ftv.tree_Code           = ftn.tree_code
           AND ftv.tree_structure_code = ftn.tree_structure_code
           AND ftv.tree_version_name   = 'CURRENT'
           AND ftn.tree_version_id     = ftv.tree_version_id
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
                      AND  ftv.tree_version_name   = 'CURRENT'
                      AND  ftn.tree_version_id     = ftv.TREE_VERSION_ID
                      AND  pk1_start_value         = b.segment3 )
            END   
         FROM   fnd_tree_node ftn
               ,fnd_tree_version_vl ftv
         WHERE 1=1
           AND ftn.tree_Code           = 'ACCOUNT MARS ILE UNPUBLISHED'
           AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
           AND ftv.tree_Code           = ftn.tree_code
           AND ftv.tree_structure_code = ftn.tree_structure_code
           AND ftv.tree_version_name   = 'CURRENT'
           AND ftn.tree_version_id     = ftv.TREE_VERSION_ID
           AND pk1_start_value         = b.segment2),'000000') "ILE" 
      ,NULL analysis
      ,NULL type
      ,:P_RUN_TYPE run_type
      ,SUM(NVL(begin_balance_dr,0)- NVL(begin_balance_cr,0) + NVL(period_net_dr,0) - NVL(period_net_cr,0)) amount
FROM gl_balances a
    ,gl_code_combinations b
    ,gl_ledgers c
    ,gl_periods d
WHERE a.code_combination_id = b.code_combination_id
  AND a.ledger_id = c.ledger_id
  AND a.currency_code = c.currency_code -- functional currency
  AND 'AED' = (SELECT SUBSTR(parent_PK1_VALUE,4)
               FROM   fnd_tree_node ftn
                     ,fnd_tree_version_vl ftv
               WHERE 1=1
                 AND ftn.tree_Code           =  'Company FCY'
                 AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
                 AND ftv.tree_Code           = ftn.tree_code
                 AND ftv.tree_structure_code = ftn.tree_structure_code
                 AND ftv.tree_version_name   = 'CURRENT'
                 AND ftn.tree_version_id     = ftv.tree_version_id
                 AND pk1_start_value         = b.segment1)
  AND c.name = 'AE_AED_PRM'
  AND EXISTS  (SELECT 'X'
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
  AND segment9 <> 'S'              -- exclude statutory adjustments
  AND :P_AMOUNT_TYPE = 'FUNCM'
  AND :P_SENDER_ID =  'CC74'
  AND d.period_name = a.period_name
  AND d.period_set_name = c.period_set_name
  AND ( (a.period_name = :P_PERIOD AND :P_PERIOD IS NOT NULL) OR
        (a.period_name = c.latest_opened_period_name AND :P_PERIOD IS NULL))
--
  GROUP by a.period_name, segment1, segment2, segment3,a.currency_code, d.start_date
  HAVING SUM(NVL(begin_balance_dr,0)- NVL(begin_balance_cr,0) + NVL(period_net_dr,0) - NVL(period_net_cr,0)) <> 0
--
UNION
--
--AUD Primary
--
--start of FUNCM
SELECT a.period_name
      ,b.segment1
      ,b.segment2
      ,b.segment3
      ,a.currency_code
      ,'CC74' sender_id
      ,:P_AMOUNT_TYPE amount_type
      ,TO_CHAR(d.Start_Date,'MM')||'15'||TO_CHAR(d.Start_Date,'YYYY') effective_date
      ,(SELECT SUBSTR(parent_PK1_VALUE,1)
          FROM fnd_tree_node ftn
              ,fnd_tree_version_vl ftv
         WHERE 1=1
           AND ftn.tree_Code             = 'COMPANY MARS UNPUBLISHED' -- Changed the hierarchy. 03 Sep
           AND ftn.tree_structure_code   = 'GL_ACCT_FLEX'
           AND ftv.tree_Code             = ftn.tree_code
           AND ftv.tree_structure_code   = ftn.tree_structure_code
           AND ftv.tree_version_name     = 'CURRENT'
           AND ftn.tree_version_id       = ftv.tree_version_id
           AND pk1_start_value           = b.segment1) "BUSINESS_UNIT"
       ,(SELECT SUBSTR(parent_pk1_value,1) -- Changed back from position 4 as the underscores are removed. 19 Oct
           FROM fnd_tree_node ftn
                ,fnd_tree_version_vl ftv
          WHERE 1=1
            AND ftn.tree_Code           = 'Company LE'
            AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
            AND ftv.tree_Code           = ftn.tree_code
            AND ftv.tree_structure_code = ftn.tree_structure_code
            AND ftv.tree_version_name   = 'CURRENT'
            AND ftn.tree_version_id     = ftv.tree_version_id
            AND pk1_start_value         = b.segment1) "LEGAL_ENTITY"
       ,(SELECT parent_pk1_value
           FROM fnd_tree_node ftn
               ,fnd_tree_version_vl ftv
          WHERE 1=1
            AND ftn.tree_Code            = 'ACCOUNT MARS UNPUBLISHED'
            AND ftn.tree_structure_code  = 'GL_ACCT_FLEX'
            AND ftv.tree_Code            = ftn.tree_code
            AND ftv.tree_structure_code  = ftn.tree_structure_code
            AND ftv.tree_version_name    = 'CURRENT'
            AND ftn.tree_version_id      = ftv.tree_version_id
            AND pk1_start_value          = b.segment2)  "MARS_ACCOUNT"
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
                      AND  ftv.tree_version_name   = 'CURRENT'
                      AND  ftn.tree_version_id     = ftv.tree_version_id
                      AND  pk1_start_value         = b.segment3 )
            END   
         FROM   fnd_tree_node ftn
               ,fnd_tree_version_vl ftv
         WHERE 1=1
           AND ftn.tree_Code           = 'ACCOUNT MARS IME UNPUBLISHED'
           AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
           AND ftv.tree_Code           = ftn.tree_code
           AND ftv.tree_structure_code = ftn.tree_structure_code
           AND ftv.tree_version_name   = 'CURRENT'
           AND ftn.tree_version_id     = ftv.tree_version_id
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
                      AND  ftv.tree_version_name   = 'CURRENT'
                      AND  ftn.tree_version_id     = ftv.TREE_VERSION_ID
                      AND  pk1_start_value         = b.segment3 )
            END   
         FROM   fnd_tree_node ftn
               ,fnd_tree_version_vl ftv
         WHERE 1=1
           AND ftn.tree_Code           = 'ACCOUNT MARS ILE UNPUBLISHED'
           AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
           AND ftv.tree_Code           = ftn.tree_code
           AND ftv.tree_structure_code = ftn.tree_structure_code
           AND ftv.tree_version_name   = 'CURRENT'
           AND ftn.tree_version_id     = ftv.TREE_VERSION_ID
           AND pk1_start_value         = b.segment2),'000000') "ILE" 
      ,NULL analysis
      ,NULL type
      ,:P_RUN_TYPE run_type
      ,SUM(NVL(begin_balance_dr,0)- NVL(begin_balance_cr,0) + NVL(period_net_dr,0) - NVL(period_net_cr,0)) amount
FROM gl_balances a
    ,gl_code_combinations b
    ,gl_ledgers c
    ,gl_periods d
WHERE a.code_combination_id = b.code_combination_id
  AND a.ledger_id = c.ledger_id
  AND a.currency_code = c.currency_code -- functional currency
  AND 'AUD' = (SELECT SUBSTR(parent_PK1_VALUE,4)
               FROM   fnd_tree_node ftn
                     ,fnd_tree_version_vl ftv
               WHERE 1=1
                 AND ftn.tree_Code           =  'Company FCY'
                 AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
                 AND ftv.tree_Code           = ftn.tree_code
                 AND ftv.tree_structure_code = ftn.tree_structure_code
                 AND ftv.tree_version_name   = 'CURRENT'
                 AND ftn.tree_version_id     = ftv.tree_version_id
                 AND pk1_start_value         = b.segment1)
  AND c.name = 'AU_AUD_PRM'
  AND EXISTS  (SELECT 'X'
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
  AND segment9 <> 'S'              -- exclude statutory adjustments
  AND :P_AMOUNT_TYPE = 'FUNCM'
  AND :P_SENDER_ID =  'CC74'
  AND d.period_name = a.period_name
  AND d.period_set_name = c.period_set_name
  AND ( (a.period_name = :P_PERIOD AND :P_PERIOD IS NOT NULL) OR
        (a.period_name = c.latest_opened_period_name AND :P_PERIOD IS NULL))
--
  GROUP by a.period_name, segment1, segment2, segment3,a.currency_code, d.start_date
  HAVING SUM(NVL(begin_balance_dr,0)- NVL(begin_balance_cr,0) + NVL(period_net_dr,0) - NVL(period_net_cr,0)) <> 0
--
UNION
--
--BRL Primary
--
--start of FUNCM
SELECT a.period_name
      ,b.segment1
      ,b.segment2
      ,b.segment3
      ,a.currency_code
      ,'CC74' sender_id
      ,:P_AMOUNT_TYPE amount_type
      ,TO_CHAR(d.Start_Date,'MM')||'15'||TO_CHAR(d.Start_Date,'YYYY') effective_date
      ,(SELECT SUBSTR(parent_PK1_VALUE,1)
          FROM fnd_tree_node ftn
              ,fnd_tree_version_vl ftv
         WHERE 1=1
           AND ftn.tree_Code             = 'COMPANY MARS UNPUBLISHED' -- Changed the hierarchy. 03 Sep
           AND ftn.tree_structure_code   = 'GL_ACCT_FLEX'
           AND ftv.tree_Code             = ftn.tree_code
           AND ftv.tree_structure_code   = ftn.tree_structure_code
           AND ftv.tree_version_name     = 'CURRENT'
           AND ftn.tree_version_id       = ftv.tree_version_id
           AND pk1_start_value           = b.segment1) "BUSINESS_UNIT"
       ,(SELECT SUBSTR(parent_pk1_value,1) -- Changed back from position 4 as the underscores are removed. 19 Oct
           FROM fnd_tree_node ftn
                ,fnd_tree_version_vl ftv
          WHERE 1=1
            AND ftn.tree_Code           = 'Company LE'
            AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
            AND ftv.tree_Code           = ftn.tree_code
            AND ftv.tree_structure_code = ftn.tree_structure_code
            AND ftv.tree_version_name   = 'CURRENT'
            AND ftn.tree_version_id     = ftv.tree_version_id
            AND pk1_start_value         = b.segment1) "LEGAL_ENTITY"
       ,(SELECT parent_pk1_value
           FROM fnd_tree_node ftn
               ,fnd_tree_version_vl ftv
          WHERE 1=1
            AND ftn.tree_Code            = 'ACCOUNT MARS UNPUBLISHED'
            AND ftn.tree_structure_code  = 'GL_ACCT_FLEX'
            AND ftv.tree_Code            = ftn.tree_code
            AND ftv.tree_structure_code  = ftn.tree_structure_code
            AND ftv.tree_version_name    = 'CURRENT'
            AND ftn.tree_version_id      = ftv.tree_version_id
            AND pk1_start_value          = b.segment2)  "MARS_ACCOUNT"
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
                      AND  ftv.tree_version_name   = 'CURRENT'
                      AND  ftn.tree_version_id     = ftv.tree_version_id
                      AND  pk1_start_value         = b.segment3 )
            END   
         FROM   fnd_tree_node ftn
               ,fnd_tree_version_vl ftv
         WHERE 1=1
           AND ftn.tree_Code           = 'ACCOUNT MARS IME UNPUBLISHED'
           AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
           AND ftv.tree_Code           = ftn.tree_code
           AND ftv.tree_structure_code = ftn.tree_structure_code
           AND ftv.tree_version_name   = 'CURRENT'
           AND ftn.tree_version_id     = ftv.tree_version_id
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
                      AND  ftv.tree_version_name   = 'CURRENT'
                      AND  ftn.tree_version_id     = ftv.TREE_VERSION_ID
                      AND  pk1_start_value         = b.segment3 )
            END   
         FROM   fnd_tree_node ftn
               ,fnd_tree_version_vl ftv
         WHERE 1=1
           AND ftn.tree_Code           = 'ACCOUNT MARS ILE UNPUBLISHED'
           AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
           AND ftv.tree_Code           = ftn.tree_code
           AND ftv.tree_structure_code = ftn.tree_structure_code
           AND ftv.tree_version_name   = 'CURRENT'
           AND ftn.tree_version_id     = ftv.TREE_VERSION_ID
           AND pk1_start_value         = b.segment2),'000000') "ILE" 
      ,NULL analysis
      ,NULL type
      ,:P_RUN_TYPE run_type
      ,SUM(NVL(begin_balance_dr,0)- NVL(begin_balance_cr,0) + NVL(period_net_dr,0) - NVL(period_net_cr,0)) amount
FROM gl_balances a
    ,gl_code_combinations b
    ,gl_ledgers c
    ,gl_periods d
WHERE a.code_combination_id = b.code_combination_id
  AND a.ledger_id = c.ledger_id
  AND a.currency_code = c.currency_code -- functional currency
  AND 'BRL' = (SELECT SUBSTR(parent_PK1_VALUE,4)
               FROM   fnd_tree_node ftn
                     ,fnd_tree_version_vl ftv
               WHERE 1=1
                 AND ftn.tree_Code           =  'Company FCY'
                 AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
                 AND ftv.tree_Code           = ftn.tree_code
                 AND ftv.tree_structure_code = ftn.tree_structure_code
                 AND ftv.tree_version_name   = 'CURRENT'
                 AND ftn.tree_version_id     = ftv.tree_version_id
                 AND pk1_start_value         = b.segment1)
  AND c.name = 'BR_BRL_PRM'
  AND EXISTS  (SELECT 'X'
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
  AND segment9 <> 'S'              -- exclude statutory adjustments
  AND :P_AMOUNT_TYPE = 'FUNCM'
  AND :P_SENDER_ID =  'CC74'
  AND d.period_name = a.period_name
  AND d.period_set_name = c.period_set_name
  AND ( (a.period_name = :P_PERIOD AND :P_PERIOD IS NOT NULL) OR
        (a.period_name = c.latest_opened_period_name AND :P_PERIOD IS NULL))
--
  GROUP by a.period_name, segment1, segment2, segment3,a.currency_code, d.start_date
  HAVING SUM(NVL(begin_balance_dr,0)- NVL(begin_balance_cr,0) + NVL(period_net_dr,0) - NVL(period_net_cr,0)) <> 0
--
UNION
--
--CNY Primary
--
--start of FUNCM
SELECT a.period_name
      ,b.segment1
      ,b.segment2
      ,b.segment3
      ,a.currency_code
      ,'CC74' sender_id
      ,:P_AMOUNT_TYPE amount_type
      ,TO_CHAR(d.Start_Date,'MM')||'15'||TO_CHAR(d.Start_Date,'YYYY') effective_date
      ,(SELECT SUBSTR(parent_PK1_VALUE,1)
          FROM fnd_tree_node ftn
              ,fnd_tree_version_vl ftv
         WHERE 1=1
           AND ftn.tree_Code             = 'COMPANY MARS UNPUBLISHED' -- Changed the hierarchy. 03 Sep
           AND ftn.tree_structure_code   = 'GL_ACCT_FLEX'
           AND ftv.tree_Code             = ftn.tree_code
           AND ftv.tree_structure_code   = ftn.tree_structure_code
           AND ftv.tree_version_name     = 'CURRENT'
           AND ftn.tree_version_id       = ftv.tree_version_id
           AND pk1_start_value           = b.segment1) "BUSINESS_UNIT"
       ,(SELECT SUBSTR(parent_pk1_value,1) -- Changed back from position 4 as the underscores are removed. 19 Oct
           FROM fnd_tree_node ftn
                ,fnd_tree_version_vl ftv
          WHERE 1=1
            AND ftn.tree_Code           = 'Company LE'
            AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
            AND ftv.tree_Code           = ftn.tree_code
            AND ftv.tree_structure_code = ftn.tree_structure_code
            AND ftv.tree_version_name   = 'CURRENT'
            AND ftn.tree_version_id     = ftv.tree_version_id
            AND pk1_start_value         = b.segment1) "LEGAL_ENTITY"
       ,(SELECT parent_pk1_value
           FROM fnd_tree_node ftn
               ,fnd_tree_version_vl ftv
          WHERE 1=1
            AND ftn.tree_Code            = 'ACCOUNT MARS UNPUBLISHED'
            AND ftn.tree_structure_code  = 'GL_ACCT_FLEX'
            AND ftv.tree_Code            = ftn.tree_code
            AND ftv.tree_structure_code  = ftn.tree_structure_code
            AND ftv.tree_version_name    = 'CURRENT'
            AND ftn.tree_version_id      = ftv.tree_version_id
            AND pk1_start_value          = b.segment2)  "MARS_ACCOUNT"
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
                      AND  ftv.tree_version_name   = 'CURRENT'
                      AND  ftn.tree_version_id     = ftv.tree_version_id
                      AND  pk1_start_value         = b.segment3 )
            END   
         FROM   fnd_tree_node ftn
               ,fnd_tree_version_vl ftv
         WHERE 1=1
           AND ftn.tree_Code           = 'ACCOUNT MARS IME UNPUBLISHED'
           AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
           AND ftv.tree_Code           = ftn.tree_code
           AND ftv.tree_structure_code = ftn.tree_structure_code
           AND ftv.tree_version_name   = 'CURRENT'
           AND ftn.tree_version_id     = ftv.tree_version_id
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
                      AND  ftv.tree_version_name   = 'CURRENT'
                      AND  ftn.tree_version_id     = ftv.TREE_VERSION_ID
                      AND  pk1_start_value         = b.segment3 )
            END   
         FROM   fnd_tree_node ftn
               ,fnd_tree_version_vl ftv
         WHERE 1=1
           AND ftn.tree_Code           = 'ACCOUNT MARS ILE UNPUBLISHED'
           AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
           AND ftv.tree_Code           = ftn.tree_code
           AND ftv.tree_structure_code = ftn.tree_structure_code
           AND ftv.tree_version_name   = 'CURRENT'
           AND ftn.tree_version_id     = ftv.TREE_VERSION_ID
           AND pk1_start_value         = b.segment2),'000000') "ILE" 
      ,NULL analysis
      ,NULL type
      ,:P_RUN_TYPE run_type
      ,SUM(NVL(begin_balance_dr,0)- NVL(begin_balance_cr,0) + NVL(period_net_dr,0) - NVL(period_net_cr,0)) amount
FROM gl_balances a
    ,gl_code_combinations b
    ,gl_ledgers c
    ,gl_periods d
WHERE a.code_combination_id = b.code_combination_id
  AND a.ledger_id = c.ledger_id
  AND a.currency_code = c.currency_code -- functional currency
  AND 'CNY' = (SELECT SUBSTR(parent_PK1_VALUE,4)
               FROM   fnd_tree_node ftn
                     ,fnd_tree_version_vl ftv
               WHERE 1=1
                 AND ftn.tree_Code           =  'Company FCY'
                 AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
                 AND ftv.tree_Code           = ftn.tree_code
                 AND ftv.tree_structure_code = ftn.tree_structure_code
                 AND ftv.tree_version_name   = 'CURRENT'
                 AND ftn.tree_version_id     = ftv.tree_version_id
                 AND pk1_start_value         = b.segment1)
  AND c.name = 'CN_CNY_PRM'
  AND EXISTS  (SELECT 'X'
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
  AND segment9 <> 'S'              -- exclude statutory adjustments
  AND :P_AMOUNT_TYPE = 'FUNCM'
  AND :P_SENDER_ID =  'CC74'
  AND d.period_name = a.period_name
  AND d.period_set_name = c.period_set_name
  AND ( (a.period_name = :P_PERIOD AND :P_PERIOD IS NOT NULL) OR
        (a.period_name = c.latest_opened_period_name AND :P_PERIOD IS NULL))
--
  GROUP by a.period_name, segment1, segment2, segment3,a.currency_code, d.start_date
  HAVING SUM(NVL(begin_balance_dr,0)- NVL(begin_balance_cr,0) + NVL(period_net_dr,0) - NVL(period_net_cr,0)) <> 0
--
UNION
--
--GBP Primary
--
--start of FUNCM
SELECT a.period_name
      ,b.segment1
      ,b.segment2
      ,b.segment3
      ,a.currency_code
      ,'CC74' sender_id
      ,:P_AMOUNT_TYPE amount_type
      ,TO_CHAR(d.Start_Date,'MM')||'15'||TO_CHAR(d.Start_Date,'YYYY') effective_date
      ,(SELECT SUBSTR(parent_PK1_VALUE,1)
          FROM fnd_tree_node ftn
              ,fnd_tree_version_vl ftv
         WHERE 1=1
           AND ftn.tree_Code             = 'COMPANY MARS UNPUBLISHED' -- Changed the hierarchy. 03 Sep
           AND ftn.tree_structure_code   = 'GL_ACCT_FLEX'
           AND ftv.tree_Code             = ftn.tree_code
           AND ftv.tree_structure_code   = ftn.tree_structure_code
           AND ftv.tree_version_name     = 'CURRENT'
           AND ftn.tree_version_id       = ftv.tree_version_id
           AND pk1_start_value           = b.segment1) "BUSINESS_UNIT"
       ,(SELECT SUBSTR(parent_pk1_value,1) -- Changed back from position 4 as the underscores are removed. 19 Oct
           FROM fnd_tree_node ftn
                ,fnd_tree_version_vl ftv
          WHERE 1=1
            AND ftn.tree_Code           = 'Company LE'
            AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
            AND ftv.tree_Code           = ftn.tree_code
            AND ftv.tree_structure_code = ftn.tree_structure_code
            AND ftv.tree_version_name   = 'CURRENT'
            AND ftn.tree_version_id     = ftv.tree_version_id
            AND pk1_start_value         = b.segment1) "LEGAL_ENTITY"
       ,(SELECT parent_pk1_value
           FROM fnd_tree_node ftn
               ,fnd_tree_version_vl ftv
          WHERE 1=1
            AND ftn.tree_Code            = 'ACCOUNT MARS UNPUBLISHED'
            AND ftn.tree_structure_code  = 'GL_ACCT_FLEX'
            AND ftv.tree_Code            = ftn.tree_code
            AND ftv.tree_structure_code  = ftn.tree_structure_code
            AND ftv.tree_version_name    = 'CURRENT'
            AND ftn.tree_version_id      = ftv.tree_version_id
            AND pk1_start_value          = b.segment2)  "MARS_ACCOUNT"
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
                      AND  ftv.tree_version_name   = 'CURRENT'
                      AND  ftn.tree_version_id     = ftv.tree_version_id
                      AND  pk1_start_value         = b.segment3 )
            END   
         FROM   fnd_tree_node ftn
               ,fnd_tree_version_vl ftv
         WHERE 1=1
           AND ftn.tree_Code           = 'ACCOUNT MARS IME UNPUBLISHED'
           AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
           AND ftv.tree_Code           = ftn.tree_code
           AND ftv.tree_structure_code = ftn.tree_structure_code
           AND ftv.tree_version_name   = 'CURRENT'
           AND ftn.tree_version_id     = ftv.tree_version_id
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
                      AND  ftv.tree_version_name   = 'CURRENT'
                      AND  ftn.tree_version_id     = ftv.TREE_VERSION_ID
                      AND  pk1_start_value         = b.segment3 )
            END   
         FROM   fnd_tree_node ftn
               ,fnd_tree_version_vl ftv
         WHERE 1=1
           AND ftn.tree_Code           = 'ACCOUNT MARS ILE UNPUBLISHED'
           AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
           AND ftv.tree_Code           = ftn.tree_code
           AND ftv.tree_structure_code = ftn.tree_structure_code
           AND ftv.tree_version_name   = 'CURRENT'
           AND ftn.tree_version_id     = ftv.TREE_VERSION_ID
           AND pk1_start_value         = b.segment2),'000000') "ILE" 
      ,NULL analysis
      ,NULL type
      ,:P_RUN_TYPE run_type
      ,SUM(NVL(begin_balance_dr,0)- NVL(begin_balance_cr,0) + NVL(period_net_dr,0) - NVL(period_net_cr,0)) amount
FROM gl_balances a
    ,gl_code_combinations b
    ,gl_ledgers c
    ,gl_periods d
WHERE a.code_combination_id = b.code_combination_id
  AND a.ledger_id = c.ledger_id
  AND a.currency_code = c.currency_code -- functional currency
  AND 'GBP' = (SELECT SUBSTR(parent_PK1_VALUE,4)
               FROM   fnd_tree_node ftn
                     ,fnd_tree_version_vl ftv
               WHERE 1=1
                 AND ftn.tree_Code           =  'Company FCY'
                 AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
                 AND ftv.tree_Code           = ftn.tree_code
                 AND ftv.tree_structure_code = ftn.tree_structure_code
                 AND ftv.tree_version_name   = 'CURRENT'
                 AND ftn.tree_version_id     = ftv.tree_version_id
                 AND pk1_start_value         = b.segment1)
  AND c.name = 'GB_GBP_PRM'
  AND EXISTS  (SELECT 'X'
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
  AND segment9 <> 'S'              -- exclude statutory adjustments
  AND :P_AMOUNT_TYPE = 'FUNCM'
  AND :P_SENDER_ID =  'CC74'
  AND d.period_name = a.period_name
  AND d.period_set_name = c.period_set_name
  AND ( (a.period_name = :P_PERIOD AND :P_PERIOD IS NOT NULL) OR
        (a.period_name = c.latest_opened_period_name AND :P_PERIOD IS NULL))
--
  GROUP by a.period_name, segment1, segment2, segment3,a.currency_code, d.start_date
  HAVING SUM(NVL(begin_balance_dr,0)- NVL(begin_balance_cr,0) + NVL(period_net_dr,0) - NVL(period_net_cr,0)) <> 0
--
UNION
--
--IND Primary
--
--start of FUNCM
SELECT a.period_name
      ,b.segment1
      ,b.segment2
      ,b.segment3
      ,a.currency_code
      ,'CC74' sender_id
      ,:P_AMOUNT_TYPE amount_type
      ,TO_CHAR(d.Start_Date,'MM')||'15'||TO_CHAR(d.Start_Date,'YYYY') effective_date
      ,(SELECT SUBSTR(parent_PK1_VALUE,1)
          FROM fnd_tree_node ftn
              ,fnd_tree_version_vl ftv
         WHERE 1=1
           AND ftn.tree_Code             = 'COMPANY MARS UNPUBLISHED' -- Changed the hierarchy. 03 Sep
           AND ftn.tree_structure_code   = 'GL_ACCT_FLEX'
           AND ftv.tree_Code             = ftn.tree_code
           AND ftv.tree_structure_code   = ftn.tree_structure_code
           AND ftv.tree_version_name     = 'CURRENT'
           AND ftn.tree_version_id       = ftv.tree_version_id
           AND pk1_start_value           = b.segment1) "BUSINESS_UNIT"
       ,(SELECT SUBSTR(parent_pk1_value,1) -- Changed back from position 4 as the underscores are removed. 19 Oct
           FROM fnd_tree_node ftn
                ,fnd_tree_version_vl ftv
          WHERE 1=1
            AND ftn.tree_Code           = 'Company LE'
            AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
            AND ftv.tree_Code           = ftn.tree_code
            AND ftv.tree_structure_code = ftn.tree_structure_code
            AND ftv.tree_version_name   = 'CURRENT'
            AND ftn.tree_version_id     = ftv.tree_version_id
            AND pk1_start_value         = b.segment1) "LEGAL_ENTITY"
       ,(SELECT parent_pk1_value
           FROM fnd_tree_node ftn
               ,fnd_tree_version_vl ftv
          WHERE 1=1
            AND ftn.tree_Code            = 'ACCOUNT MARS UNPUBLISHED'
            AND ftn.tree_structure_code  = 'GL_ACCT_FLEX'
            AND ftv.tree_Code            = ftn.tree_code
            AND ftv.tree_structure_code  = ftn.tree_structure_code
            AND ftv.tree_version_name    = 'CURRENT'
            AND ftn.tree_version_id      = ftv.tree_version_id
            AND pk1_start_value          = b.segment2)  "MARS_ACCOUNT"
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
                      AND  ftv.tree_version_name   = 'CURRENT'
                      AND  ftn.tree_version_id     = ftv.tree_version_id
                      AND  pk1_start_value         = b.segment3 )
            END   
         FROM   fnd_tree_node ftn
               ,fnd_tree_version_vl ftv
         WHERE 1=1
           AND ftn.tree_Code           = 'ACCOUNT MARS IME UNPUBLISHED'
           AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
           AND ftv.tree_Code           = ftn.tree_code
           AND ftv.tree_structure_code = ftn.tree_structure_code
           AND ftv.tree_version_name   = 'CURRENT'
           AND ftn.tree_version_id     = ftv.tree_version_id
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
                      AND  ftv.tree_version_name   = 'CURRENT'
                      AND  ftn.tree_version_id     = ftv.TREE_VERSION_ID
                      AND  pk1_start_value         = b.segment3 )
            END   
         FROM   fnd_tree_node ftn
               ,fnd_tree_version_vl ftv
         WHERE 1=1
           AND ftn.tree_Code           = 'ACCOUNT MARS ILE UNPUBLISHED'
           AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
           AND ftv.tree_Code           = ftn.tree_code
           AND ftv.tree_structure_code = ftn.tree_structure_code
           AND ftv.tree_version_name   = 'CURRENT'
           AND ftn.tree_version_id     = ftv.TREE_VERSION_ID
           AND pk1_start_value         = b.segment2),'000000') "ILE" 
      ,NULL analysis
      ,NULL type
      ,:P_RUN_TYPE run_type
      ,SUM(NVL(begin_balance_dr,0)- NVL(begin_balance_cr,0) + NVL(period_net_dr,0) - NVL(period_net_cr,0)) amount
FROM gl_balances a
    ,gl_code_combinations b
    ,gl_ledgers c
    ,gl_periods d
WHERE a.code_combination_id = b.code_combination_id
  AND a.ledger_id = c.ledger_id
  AND a.currency_code = c.currency_code -- functional currency
  AND 'INR' = (SELECT SUBSTR(parent_PK1_VALUE,4)
               FROM   fnd_tree_node ftn
                     ,fnd_tree_version_vl ftv
               WHERE 1=1
                 AND ftn.tree_Code           =  'Company FCY'
                 AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
                 AND ftv.tree_Code           = ftn.tree_code
                 AND ftv.tree_structure_code = ftn.tree_structure_code
                 AND ftv.tree_version_name   = 'CURRENT'
                 AND ftn.tree_version_id     = ftv.tree_version_id
                 AND pk1_start_value         = b.segment1)
  AND c.name = 'IN_INR_PRM'
  AND EXISTS  (SELECT 'X'
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
  AND segment9 <> 'S'              -- exclude statutory adjustments
  AND :P_AMOUNT_TYPE = 'FUNCM'
  AND :P_SENDER_ID =  'CC74'
  AND d.period_name = a.period_name
  AND d.period_set_name = c.period_set_name
  AND ( (a.period_name = :P_PERIOD AND :P_PERIOD IS NOT NULL) OR
        (a.period_name = c.latest_opened_period_name AND :P_PERIOD IS NULL))
--
  GROUP by a.period_name, segment1, segment2, segment3,a.currency_code, d.start_date
  HAVING SUM(NVL(begin_balance_dr,0)- NVL(begin_balance_cr,0) + NVL(period_net_dr,0) - NVL(period_net_cr,0)) <> 0
--
UNION
--
--MX Primary
--
--start of FUNCM
SELECT a.period_name
      ,b.segment1
      ,b.segment2
      ,b.segment3
      ,a.currency_code
      ,'CC74' sender_id
      ,:P_AMOUNT_TYPE amount_type
      ,TO_CHAR(d.Start_Date,'MM')||'15'||TO_CHAR(d.Start_Date,'YYYY') effective_date
      ,(SELECT SUBSTR(parent_PK1_VALUE,1)
          FROM fnd_tree_node ftn
              ,fnd_tree_version_vl ftv
         WHERE 1=1
           AND ftn.tree_Code             = 'COMPANY MARS UNPUBLISHED' -- Changed the hierarchy. 03 Sep
           AND ftn.tree_structure_code   = 'GL_ACCT_FLEX'
           AND ftv.tree_Code             = ftn.tree_code
           AND ftv.tree_structure_code   = ftn.tree_structure_code
           AND ftv.tree_version_name     = 'CURRENT'
           AND ftn.tree_version_id       = ftv.tree_version_id
           AND pk1_start_value           = b.segment1) "BUSINESS_UNIT"
       ,(SELECT SUBSTR(parent_pk1_value,1) -- Changed back from position 4 as the underscores are removed. 19 Oct
           FROM fnd_tree_node ftn
                ,fnd_tree_version_vl ftv
          WHERE 1=1
            AND ftn.tree_Code           = 'Company LE'
            AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
            AND ftv.tree_Code           = ftn.tree_code
            AND ftv.tree_structure_code = ftn.tree_structure_code
            AND ftv.tree_version_name   = 'CURRENT'
            AND ftn.tree_version_id     = ftv.tree_version_id
            AND pk1_start_value         = b.segment1) "LEGAL_ENTITY"
       ,(SELECT parent_pk1_value
           FROM fnd_tree_node ftn
               ,fnd_tree_version_vl ftv
          WHERE 1=1
            AND ftn.tree_Code            = 'ACCOUNT MARS UNPUBLISHED'
            AND ftn.tree_structure_code  = 'GL_ACCT_FLEX'
            AND ftv.tree_Code            = ftn.tree_code
            AND ftv.tree_structure_code  = ftn.tree_structure_code
            AND ftv.tree_version_name    = 'CURRENT'
            AND ftn.tree_version_id      = ftv.tree_version_id
            AND pk1_start_value          = b.segment2)  "MARS_ACCOUNT"
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
                      AND  ftv.tree_version_name   = 'CURRENT'
                      AND  ftn.tree_version_id     = ftv.tree_version_id
                      AND  pk1_start_value         = b.segment3 )
            END   
         FROM   fnd_tree_node ftn
               ,fnd_tree_version_vl ftv
         WHERE 1=1
           AND ftn.tree_Code           = 'ACCOUNT MARS IME UNPUBLISHED'
           AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
           AND ftv.tree_Code           = ftn.tree_code
           AND ftv.tree_structure_code = ftn.tree_structure_code
           AND ftv.tree_version_name   = 'CURRENT'
           AND ftn.tree_version_id     = ftv.tree_version_id
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
                      AND  ftv.tree_version_name   = 'CURRENT'
                      AND  ftn.tree_version_id     = ftv.TREE_VERSION_ID
                      AND  pk1_start_value         = b.segment3 )
            END   
         FROM   fnd_tree_node ftn
               ,fnd_tree_version_vl ftv
         WHERE 1=1
           AND ftn.tree_Code           = 'ACCOUNT MARS ILE UNPUBLISHED'
           AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
           AND ftv.tree_Code           = ftn.tree_code
           AND ftv.tree_structure_code = ftn.tree_structure_code
           AND ftv.tree_version_name   = 'CURRENT'
           AND ftn.tree_version_id     = ftv.TREE_VERSION_ID
           AND pk1_start_value         = b.segment2),'000000') "ILE" 
      ,NULL analysis
      ,NULL type
      ,:P_RUN_TYPE run_type
      ,SUM(NVL(begin_balance_dr,0)- NVL(begin_balance_cr,0) + NVL(period_net_dr,0) - NVL(period_net_cr,0)) amount
FROM gl_balances a
    ,gl_code_combinations b
    ,gl_ledgers c
    ,gl_periods d
WHERE a.code_combination_id = b.code_combination_id
  AND a.ledger_id = c.ledger_id
  AND a.currency_code = c.currency_code -- functional currency
  AND 'MXN' = (SELECT SUBSTR(parent_PK1_VALUE,4)
               FROM   fnd_tree_node ftn
                     ,fnd_tree_version_vl ftv
               WHERE 1=1
                 AND ftn.tree_Code           =  'Company FCY'
                 AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
                 AND ftv.tree_Code           = ftn.tree_code
                 AND ftv.tree_structure_code = ftn.tree_structure_code
                 AND ftv.tree_version_name   = 'CURRENT'
                 AND ftn.tree_version_id     = ftv.tree_version_id
                 AND pk1_start_value         = b.segment1)
  AND c.name = 'MX_MXN_PRM'
  AND EXISTS  (SELECT 'X'
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
  AND segment9 <> 'S'              -- exclude statutory adjustments
  AND :P_AMOUNT_TYPE = 'FUNCM'
  AND :P_SENDER_ID =  'CC74'
  AND d.period_name = a.period_name
  AND d.period_set_name = c.period_set_name
  AND ( (a.period_name = :P_PERIOD AND :P_PERIOD IS NOT NULL) OR
        (a.period_name = c.latest_opened_period_name AND :P_PERIOD IS NULL))
--
  GROUP by a.period_name, segment1, segment2, segment3,a.currency_code, d.start_date
  HAVING SUM(NVL(begin_balance_dr,0)- NVL(begin_balance_cr,0) + NVL(period_net_dr,0) - NVL(period_net_cr,0)) <> 0
--
UNION
--
--SG Primary
--
--start of FUNCM
SELECT a.period_name
      ,b.segment1
      ,b.segment2
      ,b.segment3
      ,a.currency_code
      ,'CC74' sender_id
      ,:P_AMOUNT_TYPE amount_type
      ,TO_CHAR(d.Start_Date,'MM')||'15'||TO_CHAR(d.Start_Date,'YYYY') effective_date
      ,(SELECT SUBSTR(parent_PK1_VALUE,1)
          FROM fnd_tree_node ftn
              ,fnd_tree_version_vl ftv
         WHERE 1=1
           AND ftn.tree_Code             = 'COMPANY MARS UNPUBLISHED' -- Changed the hierarchy. 03 Sep
           AND ftn.tree_structure_code   = 'GL_ACCT_FLEX'
           AND ftv.tree_Code             = ftn.tree_code
           AND ftv.tree_structure_code   = ftn.tree_structure_code
           AND ftv.tree_version_name     = 'CURRENT'
           AND ftn.tree_version_id       = ftv.tree_version_id
           AND pk1_start_value           = b.segment1) "BUSINESS_UNIT"
       ,(SELECT SUBSTR(parent_pk1_value,1) -- Changed back from position 4 as the underscores are removed. 19 Oct
           FROM fnd_tree_node ftn
                ,fnd_tree_version_vl ftv
          WHERE 1=1
            AND ftn.tree_Code           = 'Company LE'
            AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
            AND ftv.tree_Code           = ftn.tree_code
            AND ftv.tree_structure_code = ftn.tree_structure_code
            AND ftv.tree_version_name   = 'CURRENT'
            AND ftn.tree_version_id     = ftv.tree_version_id
            AND pk1_start_value         = b.segment1) "LEGAL_ENTITY"
       ,(SELECT parent_pk1_value
           FROM fnd_tree_node ftn
               ,fnd_tree_version_vl ftv
          WHERE 1=1
            AND ftn.tree_Code            = 'ACCOUNT MARS UNPUBLISHED'
            AND ftn.tree_structure_code  = 'GL_ACCT_FLEX'
            AND ftv.tree_Code            = ftn.tree_code
            AND ftv.tree_structure_code  = ftn.tree_structure_code
            AND ftv.tree_version_name    = 'CURRENT'
            AND ftn.tree_version_id      = ftv.tree_version_id
            AND pk1_start_value          = b.segment2)  "MARS_ACCOUNT"
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
                      AND  ftv.tree_version_name   = 'CURRENT'
                      AND  ftn.tree_version_id     = ftv.tree_version_id
                      AND  pk1_start_value         = b.segment3 )
            END   
         FROM   fnd_tree_node ftn
               ,fnd_tree_version_vl ftv
         WHERE 1=1
           AND ftn.tree_Code           = 'ACCOUNT MARS IME UNPUBLISHED'
           AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
           AND ftv.tree_Code           = ftn.tree_code
           AND ftv.tree_structure_code = ftn.tree_structure_code
           AND ftv.tree_version_name   = 'CURRENT'
           AND ftn.tree_version_id     = ftv.tree_version_id
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
                      AND  ftv.tree_version_name   = 'CURRENT'
                      AND  ftn.tree_version_id     = ftv.TREE_VERSION_ID
                      AND  pk1_start_value         = b.segment3 )
            END   
         FROM   fnd_tree_node ftn
               ,fnd_tree_version_vl ftv
         WHERE 1=1
           AND ftn.tree_Code           = 'ACCOUNT MARS ILE UNPUBLISHED'
           AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
           AND ftv.tree_Code           = ftn.tree_code
           AND ftv.tree_structure_code = ftn.tree_structure_code
           AND ftv.tree_version_name   = 'CURRENT'
           AND ftn.tree_version_id     = ftv.TREE_VERSION_ID
           AND pk1_start_value         = b.segment2),'000000') "ILE" 
      ,NULL analysis
      ,NULL type
      ,:P_RUN_TYPE run_type
      ,SUM(NVL(begin_balance_dr,0)- NVL(begin_balance_cr,0) + NVL(period_net_dr,0) - NVL(period_net_cr,0)) amount
FROM gl_balances a
    ,gl_code_combinations b
    ,gl_ledgers c
    ,gl_periods d
WHERE a.code_combination_id = b.code_combination_id
  AND a.ledger_id = c.ledger_id
  AND a.currency_code = c.currency_code -- functional currency
  AND 'SGD' = (SELECT SUBSTR(parent_PK1_VALUE,4)
               FROM   fnd_tree_node ftn
                     ,fnd_tree_version_vl ftv
               WHERE 1=1
                 AND ftn.tree_Code           =  'Company FCY'
                 AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
                 AND ftv.tree_Code           = ftn.tree_code
                 AND ftv.tree_structure_code = ftn.tree_structure_code
                 AND ftv.tree_version_name   = 'CURRENT'
                 AND ftn.tree_version_id     = ftv.tree_version_id
                 AND pk1_start_value         = b.segment1)
  AND c.name = 'SG_SGD_PRM'
  AND EXISTS  (SELECT 'X'
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
  AND segment9 <> 'S'              -- exclude statutory adjustments
  AND :P_AMOUNT_TYPE = 'FUNCM'
  AND :P_SENDER_ID =  'CC74'
  AND d.period_name = a.period_name
  AND d.period_set_name = c.period_set_name
  AND ( (a.period_name = :P_PERIOD AND :P_PERIOD IS NOT NULL) OR
        (a.period_name = c.latest_opened_period_name AND :P_PERIOD IS NULL))
--
  GROUP by a.period_name, segment1, segment2, segment3,a.currency_code, d.start_date
  HAVING SUM(NVL(begin_balance_dr,0)- NVL(begin_balance_cr,0) + NVL(period_net_dr,0) - NVL(period_net_cr,0)) <> 0
--
UNION
--
--ZAR Primary
--
--start of FUNCM
SELECT a.period_name
      ,b.segment1
      ,b.segment2
      ,b.segment3
      ,a.currency_code
      ,'CC74' sender_id
      ,:P_AMOUNT_TYPE amount_type
      ,TO_CHAR(d.Start_Date,'MM')||'15'||TO_CHAR(d.Start_Date,'YYYY') effective_date
      ,(SELECT SUBSTR(parent_PK1_VALUE,1)
          FROM fnd_tree_node ftn
              ,fnd_tree_version_vl ftv
         WHERE 1=1
           AND ftn.tree_Code             = 'COMPANY MARS UNPUBLISHED' -- Changed the hierarchy. 03 Sep
           AND ftn.tree_structure_code   = 'GL_ACCT_FLEX'
           AND ftv.tree_Code             = ftn.tree_code
           AND ftv.tree_structure_code   = ftn.tree_structure_code
           AND ftv.tree_version_name     = 'CURRENT'
           AND ftn.tree_version_id       = ftv.tree_version_id
           AND pk1_start_value           = b.segment1) "BUSINESS_UNIT"
       ,(SELECT SUBSTR(parent_pk1_value,1) -- Changed back from position 4 as the underscores are removed. 19 Oct
           FROM fnd_tree_node ftn
                ,fnd_tree_version_vl ftv
          WHERE 1=1
            AND ftn.tree_Code           = 'Company LE'
            AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
            AND ftv.tree_Code           = ftn.tree_code
            AND ftv.tree_structure_code = ftn.tree_structure_code
            AND ftv.tree_version_name   = 'CURRENT'
            AND ftn.tree_version_id     = ftv.tree_version_id
            AND pk1_start_value         = b.segment1) "LEGAL_ENTITY"
       ,(SELECT parent_pk1_value
           FROM fnd_tree_node ftn
               ,fnd_tree_version_vl ftv
          WHERE 1=1
            AND ftn.tree_Code            = 'ACCOUNT MARS UNPUBLISHED'
            AND ftn.tree_structure_code  = 'GL_ACCT_FLEX'
            AND ftv.tree_Code            = ftn.tree_code
            AND ftv.tree_structure_code  = ftn.tree_structure_code
            AND ftv.tree_version_name    = 'CURRENT'
            AND ftn.tree_version_id      = ftv.tree_version_id
            AND pk1_start_value          = b.segment2)  "MARS_ACCOUNT"
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
                      AND  ftv.tree_version_name   = 'CURRENT'
                      AND  ftn.tree_version_id     = ftv.tree_version_id
                      AND  pk1_start_value         = b.segment3 )
            END   
         FROM   fnd_tree_node ftn
               ,fnd_tree_version_vl ftv
         WHERE 1=1
           AND ftn.tree_Code           = 'ACCOUNT MARS IME UNPUBLISHED'
           AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
           AND ftv.tree_Code           = ftn.tree_code
           AND ftv.tree_structure_code = ftn.tree_structure_code
           AND ftv.tree_version_name   = 'CURRENT'
           AND ftn.tree_version_id     = ftv.tree_version_id
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
                      AND  ftv.tree_version_name   = 'CURRENT'
                      AND  ftn.tree_version_id     = ftv.TREE_VERSION_ID
                      AND  pk1_start_value         = b.segment3 )
            END   
         FROM   fnd_tree_node ftn
               ,fnd_tree_version_vl ftv
         WHERE 1=1
           AND ftn.tree_Code           = 'ACCOUNT MARS ILE UNPUBLISHED'
           AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
           AND ftv.tree_Code           = ftn.tree_code
           AND ftv.tree_structure_code = ftn.tree_structure_code
           AND ftv.tree_version_name   = 'CURRENT'
           AND ftn.tree_version_id     = ftv.TREE_VERSION_ID
           AND pk1_start_value         = b.segment2),'000000') "ILE" 
      ,NULL analysis
      ,NULL type
      ,:P_RUN_TYPE run_type
      ,SUM(NVL(begin_balance_dr,0)- NVL(begin_balance_cr,0) + NVL(period_net_dr,0) - NVL(period_net_cr,0)) amount
FROM gl_balances a
    ,gl_code_combinations b
    ,gl_ledgers c
    ,gl_periods d
WHERE a.code_combination_id = b.code_combination_id
  AND a.ledger_id = c.ledger_id
  AND a.currency_code = c.currency_code -- functional currency
  AND 'ZAR' = (SELECT SUBSTR(parent_PK1_VALUE,4)
               FROM   fnd_tree_node ftn
                     ,fnd_tree_version_vl ftv
               WHERE 1=1
                 AND ftn.tree_Code           =  'Company FCY'
                 AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
                 AND ftv.tree_Code           = ftn.tree_code
                 AND ftv.tree_structure_code = ftn.tree_structure_code
                 AND ftv.tree_version_name   = 'CURRENT'
                 AND ftn.tree_version_id     = ftv.tree_version_id
                 AND pk1_start_value         = b.segment1)
  AND c.name = 'ZA_ZAR_PRM'
  AND EXISTS  (SELECT 'X'
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
  AND segment9 <> 'S'              -- exclude statutory adjustments
  AND :P_AMOUNT_TYPE = 'FUNCM'
  AND :P_SENDER_ID =  'CC74'
  AND d.period_name = a.period_name
  AND d.period_set_name = c.period_set_name
  AND ( (a.period_name = :P_PERIOD AND :P_PERIOD IS NOT NULL) OR
        (a.period_name = c.latest_opened_period_name AND :P_PERIOD IS NULL))
--
  GROUP by a.period_name, segment1, segment2, segment3,a.currency_code, d.start_date
  HAVING SUM(NVL(begin_balance_dr,0)- NVL(begin_balance_cr,0) + NVL(period_net_dr,0) - NVL(period_net_cr,0)) <> 0
--
-- USD FCY For UAE,AUS,BRASIL,CHINA,GB,INDIA,MEXICO,SINGAPORE,SOUTHAFRICA
UNION
  SELECT a.period_name
        ,b.segment1
      ,b.segment2
      ,b.segment3
      ,a.currency_code
      ,'CC74' sender_id
      ,:P_AMOUNT_TYPE amount_type
      ,TO_CHAR(d.Start_Date,'MM')||'15'||TO_CHAR(d.Start_Date,'YYYY') effective_date
      ,(SELECT SUBSTR(parent_pk1_value,1)
          FROM fnd_tree_node ftn
              ,fnd_tree_version_vl ftv
         WHERE 1=1
           AND ftn.tree_code           =  'COMPANY MARS UNPUBLISHED' -- Changed the hierarchy. 03 Sep
           AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
           AND ftv.tree_Code           = ftn.tree_code
           AND ftv.tree_structure_code = ftn.tree_structure_code
           AND ftv.tree_version_name   = 'CURRENT'
           AND ftn.tree_version_id     = ftv.tree_version_id
           AND pk1_start_value         = b.segment1) "BUSINESS_UNIT"
      , (SELECT SUBSTR(parent_PK1_VALUE,1) -- Changed back from position 4 as the underscores are removed. 19 Oct
           FROM fnd_tree_node ftn
               ,fnd_tree_version_vl ftv
          WHERE 1=1
            AND ftn.tree_Code           =  'Company LE'
            AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
            AND ftv.tree_Code           = ftn.tree_code
            AND ftv.tree_structure_code = ftn.tree_structure_code
            AND ftv.tree_version_name   = 'CURRENT'
            AND ftn.tree_version_id     = ftv.tree_version_id
            AND pk1_start_value         = b.segment1) "LEGAL_ENTITY"
      ,(SELECT parent_pk1_value
          FROM fnd_tree_node ftn
              ,fnd_tree_version_vl ftv
         WHERE 1=1
           AND ftn.tree_Code            =  'ACCOUNT MARS UNPUBLISHED'
           AND ftn.tree_structure_code  = 'GL_ACCT_FLEX'
           AND ftv.tree_Code            = ftn.tree_code
           AND ftv.tree_structure_code  = ftn.tree_structure_code
           AND ftv.tree_version_name    = 'CURRENT'
           AND ftn.tree_version_id      = ftv.tree_version_id
           AND pk1_start_value          = b.segment2)  "MARS_ACCOUNT"
        ,NVL((SELECT 
        CASE ftn.parent_pk1_value 
           WHEN 'N' THEN '000000' 
            ELSE ( SELECT  parent_pk1_value
                     FROM  fnd_tree_node ftn
                          ,fnd_tree_version_vl ftv
                    WHERE  1=1
                      AND  ftn.tree_Code           = 'TP MARS IBU UNPUBLISHED'
                      AND  ftn.tree_structure_code = 'GL_ACCT_FLEX'
                      AND  ftv.tree_Code           = ftn.tree_code
                      AND  ftv.tree_structure_code = ftn.tree_structure_code
                      AND  ftv.tree_version_name   = 'CURRENT'
                      AND  ftn.tree_version_id     = ftv.tree_version_id
                      AND  pk1_start_value         = b.segment3 )
            END   
         FROM   fnd_tree_node ftn
               ,fnd_tree_version_vl ftv
         WHERE 1=1
           AND ftn.tree_Code           = 'ACCOUNT MARS IME UNPUBLISHED'
           AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
           AND ftv.tree_Code           = ftn.tree_code
           AND ftv.tree_structure_code = ftn.tree_structure_code
           AND ftv.tree_version_name   = 'CURRENT'
           AND ftn.tree_version_id     = ftv.tree_version_id
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
                      AND  ftv.tree_version_name   = 'CURRENT'
                      AND  ftn.tree_version_id     = ftv.tree_version_id
                      AND  pk1_start_value         = b.segment3 )
            END   
         FROM   fnd_tree_node ftn
               ,fnd_tree_version_vl ftv
         WHERE 1=1
           AND ftn.tree_Code           = 'ACCOUNT MARS ILE UNPUBLISHED'
           AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
           AND ftv.tree_Code           = ftn.tree_code
           AND ftv.tree_structure_code = ftn.tree_structure_code
           AND ftv.tree_version_name   = 'CURRENT'
           AND ftn.tree_version_id     = ftv.tree_version_id
           AND pk1_start_value         = b.segment2),'000000') "ILE" 
     ,NULL analysis
     ,NULL type
     ,:P_RUN_TYPE run_type
     ,DECODE(a.currency_code,c.currency_code,SUM(NVL(begin_balance_dr_beq,0) - NVL(begin_balance_cr_beq,0)
              + NVL(period_net_dr_beq,0) - NVL(period_net_cr_beq,0)),
              SUM(NVL(begin_balance_dr,0)- NVL(begin_balance_cr,0) + NVL(period_net_dr,0) - NVL(period_net_cr,0))) amount
FROM gl_balances a
    ,gl_code_combinations b
    ,gl_ledgers c
    ,gl_periods d
WHERE a.code_combination_id = b.code_combination_id
  AND a.ledger_id = c.ledger_id
  AND c.ledger_category_code = 'ALC'      -- ALC for Reporting ledger
  AND c.currency_code = 'USD'    -- Include all USD functional currency Reporting books
  AND 'USD' = (SELECT SUBSTR(parent_PK1_VALUE,4)
                 FROM fnd_tree_node ftn
                     ,fnd_tree_version_vl ftv
                WHERE 1=1
                  AND ftn.tree_Code           =  'Company FCY'
                  AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
                  AND ftv.tree_Code           = ftn.tree_code
                  AND ftv.tree_structure_code = ftn.tree_structure_code
                  AND ftv.tree_version_name   = 'CURRENT'
                  AND ftn.tree_version_id     = ftv.tree_version_id
                  AND pk1_start_value         = b.segment1)
  AND c.name IN ('ES_USD_FCY','MT_USD_FCY','AE_USD_FCY','AU_USD_FCY','BR_USD_FCY','CN_USD_FCY','GB_USD_FCY','IN_USD_FCY', 'MX_USD_FCY','SG_USD_FCY',
                 'ZA_USD_FCY','DE_USD_FCY','JP_USD_FCY','KR_USD_FCY') 
  AND EXISTS (SELECT 'X'
                FROM fnd_tree_node ftn
                    ,fnd_tree_version_vl ftv
               WHERE 1=1
                 AND ftn.tree_Code           = 'COMPANY MARS UNPUBLISHED'
                 AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
                 AND ftv.tree_Code           = ftn.tree_code
                 AND ftv.tree_structure_code = ftn.tree_structure_code
                 AND ftv.tree_version_name   = 'CURRENT'
                 AND ftn.tree_version_id     = ftv.tree_version_id
                 AND pk1_start_value         = b.segment1
                 AND parent_pk1_value        = 'DIGTOT' )
  AND segment9 <> 'S'  -- exclude statutory adjustments
  AND :P_AMOUNT_TYPE = 'FUNCM'
  AND :P_SENDER_ID   =  'CC74'
  AND d.period_name  = a.period_name
  AND d.period_set_name = c.period_set_name
  AND ( (a.period_name = :P_PERIOD AND :P_PERIOD IS NOT NULL) OR
        (a.period_name = c.latest_opened_period_name AND :P_PERIOD IS NULL))
--
GROUP by a.period_name, segment1, segment2, segment3,a.currency_code ,c.currency_code, d.start_date
HAVING SUM(DECODE(a.currency_code,c.currency_code, (NVL(begin_balance_dr_beq,0) - NVL(begin_balance_cr_beq,0) + NVL(period_net_dr_beq,0) - NVL(period_net_cr_beq,0)),
              (NVL(begin_balance_dr,0)- NVL(begin_balance_cr,0) + NVL(period_net_dr,0) - NVL(period_net_cr,0)))) <> 0
UNION
--
--GED Korea
--
--start of FUNCM
SELECT a.period_name
      ,b.segment1
      ,b.segment2
      ,b.segment3
      ,a.currency_code
      ,'CC74' sender_id
      ,:P_AMOUNT_TYPE amount_type
      ,TO_CHAR(d.Start_Date,'MM')||'15'||TO_CHAR(d.Start_Date,'YYYY') effective_date
      ,(SELECT SUBSTR(parent_PK1_VALUE,1)
          FROM fnd_tree_node ftn
              ,fnd_tree_version_vl ftv
         WHERE 1=1
           AND ftn.tree_Code             = 'COMPANY MARS UNPUBLISHED' -- Changed the hierarchy. 03 Sep
           AND ftn.tree_structure_code   = 'GL_ACCT_FLEX'
           AND ftv.tree_Code             = ftn.tree_code
           AND ftv.tree_structure_code   = ftn.tree_structure_code
           AND ftv.tree_version_name     = 'CURRENT'
           AND ftn.tree_version_id       = ftv.tree_version_id
           AND pk1_start_value           = b.segment1) "BUSINESS_UNIT"
       ,(SELECT SUBSTR(parent_pk1_value,1) -- Changed back from position 4 as the underscores are removed. 19 Oct
           FROM fnd_tree_node ftn
                ,fnd_tree_version_vl ftv
          WHERE 1=1
            AND ftn.tree_Code           = 'Company LE'
            AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
            AND ftv.tree_Code           = ftn.tree_code
            AND ftv.tree_structure_code = ftn.tree_structure_code
            AND ftv.tree_version_name   = 'CURRENT'
            AND ftn.tree_version_id     = ftv.tree_version_id
            AND pk1_start_value         = b.segment1) "LEGAL_ENTITY"
       ,(SELECT parent_pk1_value
           FROM fnd_tree_node ftn
               ,fnd_tree_version_vl ftv
          WHERE 1=1
            AND ftn.tree_Code            = 'ACCOUNT MARS UNPUBLISHED'
            AND ftn.tree_structure_code  = 'GL_ACCT_FLEX'
            AND ftv.tree_Code            = ftn.tree_code
            AND ftv.tree_structure_code  = ftn.tree_structure_code
            AND ftv.tree_version_name    = 'CURRENT'
            AND ftn.tree_version_id      = ftv.tree_version_id
            AND pk1_start_value          = b.segment2)  "MARS_ACCOUNT"
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
                      AND  ftv.tree_version_name   = 'CURRENT'
                      AND  ftn.tree_version_id     = ftv.tree_version_id
                      AND  pk1_start_value         = b.segment3 )
            END   
         FROM   fnd_tree_node ftn
               ,fnd_tree_version_vl ftv
         WHERE 1=1
           AND ftn.tree_Code           = 'ACCOUNT MARS IME UNPUBLISHED'
           AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
           AND ftv.tree_Code           = ftn.tree_code
           AND ftv.tree_structure_code = ftn.tree_structure_code
           AND ftv.tree_version_name   = 'CURRENT'
           AND ftn.tree_version_id     = ftv.tree_version_id
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
                      AND  ftv.tree_version_name   = 'CURRENT'
                      AND  ftn.tree_version_id     = ftv.TREE_VERSION_ID
                      AND  pk1_start_value         = b.segment3 )
            END   
         FROM   fnd_tree_node ftn
               ,fnd_tree_version_vl ftv
         WHERE 1=1
           AND ftn.tree_Code           = 'ACCOUNT MARS ILE UNPUBLISHED'
           AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
           AND ftv.tree_Code           = ftn.tree_code
           AND ftv.tree_structure_code = ftn.tree_structure_code
           AND ftv.tree_version_name   = 'CURRENT'
           AND ftn.tree_version_id     = ftv.TREE_VERSION_ID
           AND pk1_start_value         = b.segment2),'000000') "ILE" 
      ,NULL analysis
      ,NULL type
      ,:P_RUN_TYPE run_type
      ,SUM(NVL(begin_balance_dr,0)- NVL(begin_balance_cr,0) + NVL(period_net_dr,0) - NVL(period_net_cr,0)) amount
FROM gl_balances a
    ,gl_code_combinations b
    ,gl_ledgers c
    ,gl_periods d
WHERE a.code_combination_id = b.code_combination_id
  AND a.ledger_id = c.ledger_id
  AND a.currency_code = c.currency_code -- functional currency
  AND 'KRW' = (SELECT SUBSTR(parent_PK1_VALUE,4)
               FROM   fnd_tree_node ftn
                     ,fnd_tree_version_vl ftv
               WHERE 1=1
                 AND ftn.tree_Code           =  'Company FCY'
                 AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
                 AND ftv.tree_Code           = ftn.tree_code
                 AND ftv.tree_structure_code = ftn.tree_structure_code
                 AND ftv.tree_version_name   = 'CURRENT'
                 AND ftn.tree_version_id     = ftv.tree_version_id
                 AND pk1_start_value         = b.segment1)
  AND c.name = 'KR_KRW_PRM'
  AND EXISTS  (SELECT 'X'
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
  AND segment9 <> 'S'              -- exclude statutory adjustments
  AND :P_AMOUNT_TYPE = 'FUNCM'
  AND :P_SENDER_ID =  'CC74'
  AND d.period_name = a.period_name
  AND d.period_set_name = c.period_set_name
  AND ( (a.period_name = :P_PERIOD AND :P_PERIOD IS NOT NULL) OR
        (a.period_name = c.latest_opened_period_name AND :P_PERIOD IS NULL))
--
  GROUP by a.period_name, segment1, segment2, segment3,a.currency_code, d.start_date
  HAVING SUM(NVL(begin_balance_dr,0)- NVL(begin_balance_cr,0) + NVL(period_net_dr,0) - NVL(period_net_cr,0)) <> 0
 UNION
--
--GED Japan
--
--start of FUNCM
SELECT a.period_name
      ,b.segment1
      ,b.segment2
      ,b.segment3
      ,a.currency_code
      ,'CC74' sender_id
      ,:P_AMOUNT_TYPE amount_type
      ,TO_CHAR(d.Start_Date,'MM')||'15'||TO_CHAR(d.Start_Date,'YYYY') effective_date
      ,(SELECT SUBSTR(parent_PK1_VALUE,1)
          FROM fnd_tree_node ftn
              ,fnd_tree_version_vl ftv
         WHERE 1=1
           AND ftn.tree_Code             = 'COMPANY MARS UNPUBLISHED' -- Changed the hierarchy. 03 Sep
           AND ftn.tree_structure_code   = 'GL_ACCT_FLEX'
           AND ftv.tree_Code             = ftn.tree_code
           AND ftv.tree_structure_code   = ftn.tree_structure_code
           AND ftv.tree_version_name     = 'CURRENT'
           AND ftn.tree_version_id       = ftv.tree_version_id
           AND pk1_start_value           = b.segment1) "BUSINESS_UNIT"
       ,(SELECT SUBSTR(parent_pk1_value,1) -- Changed back from position 4 as the underscores are removed. 19 Oct
           FROM fnd_tree_node ftn
                ,fnd_tree_version_vl ftv
          WHERE 1=1
            AND ftn.tree_Code           = 'Company LE'
            AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
            AND ftv.tree_Code           = ftn.tree_code
            AND ftv.tree_structure_code = ftn.tree_structure_code
            AND ftv.tree_version_name   = 'CURRENT'
            AND ftn.tree_version_id     = ftv.tree_version_id
            AND pk1_start_value         = b.segment1) "LEGAL_ENTITY"
       ,(SELECT parent_pk1_value
           FROM fnd_tree_node ftn
               ,fnd_tree_version_vl ftv
          WHERE 1=1
            AND ftn.tree_Code            = 'ACCOUNT MARS UNPUBLISHED'
            AND ftn.tree_structure_code  = 'GL_ACCT_FLEX'
            AND ftv.tree_Code            = ftn.tree_code
            AND ftv.tree_structure_code  = ftn.tree_structure_code
            AND ftv.tree_version_name    = 'CURRENT'
            AND ftn.tree_version_id      = ftv.tree_version_id
            AND pk1_start_value          = b.segment2)  "MARS_ACCOUNT"
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
                      AND  ftv.tree_version_name   = 'CURRENT'
                      AND  ftn.tree_version_id     = ftv.tree_version_id
                      AND  pk1_start_value         = b.segment3 )
            END   
         FROM   fnd_tree_node ftn
               ,fnd_tree_version_vl ftv
         WHERE 1=1
           AND ftn.tree_Code           = 'ACCOUNT MARS IME UNPUBLISHED'
           AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
           AND ftv.tree_Code           = ftn.tree_code
           AND ftv.tree_structure_code = ftn.tree_structure_code
           AND ftv.tree_version_name   = 'CURRENT'
           AND ftn.tree_version_id     = ftv.tree_version_id
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
                      AND  ftv.tree_version_name   = 'CURRENT'
                      AND  ftn.tree_version_id     = ftv.TREE_VERSION_ID
                      AND  pk1_start_value         = b.segment3 )
            END   
         FROM   fnd_tree_node ftn
               ,fnd_tree_version_vl ftv
         WHERE 1=1
           AND ftn.tree_Code           = 'ACCOUNT MARS ILE UNPUBLISHED'
           AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
           AND ftv.tree_Code           = ftn.tree_code
           AND ftv.tree_structure_code = ftn.tree_structure_code
           AND ftv.tree_version_name   = 'CURRENT'
           AND ftn.tree_version_id     = ftv.TREE_VERSION_ID
           AND pk1_start_value         = b.segment2),'000000') "ILE" 
      ,NULL analysis
      ,NULL type
      ,:P_RUN_TYPE run_type
      ,SUM(NVL(begin_balance_dr,0)- NVL(begin_balance_cr,0) + NVL(period_net_dr,0) - NVL(period_net_cr,0)) amount
FROM gl_balances a
    ,gl_code_combinations b
    ,gl_ledgers c
    ,gl_periods d
WHERE a.code_combination_id = b.code_combination_id
  AND a.ledger_id = c.ledger_id
  AND a.currency_code = c.currency_code -- functional currency
  AND 'JPY' = (SELECT SUBSTR(parent_PK1_VALUE,4)
               FROM   fnd_tree_node ftn
                     ,fnd_tree_version_vl ftv
               WHERE 1=1
                 AND ftn.tree_Code           =  'Company FCY'
                 AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
                 AND ftv.tree_Code           = ftn.tree_code
                 AND ftv.tree_structure_code = ftn.tree_structure_code
                 AND ftv.tree_version_name   = 'CURRENT'
                 AND ftn.tree_version_id     = ftv.tree_version_id
                 AND pk1_start_value         = b.segment1)
  AND c.name = 'JP_JPY_PRM'
  AND EXISTS  (SELECT 'X'
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
  AND segment9 <> 'S'              -- exclude statutory adjustments
  AND :P_AMOUNT_TYPE = 'FUNCM'
  AND :P_SENDER_ID =  'CC74'
  AND d.period_name = a.period_name
  AND d.period_set_name = c.period_set_name
  AND ( (a.period_name = :P_PERIOD AND :P_PERIOD IS NOT NULL) OR
        (a.period_name = c.latest_opened_period_name AND :P_PERIOD IS NULL))
--
  GROUP by a.period_name, segment1, segment2, segment3,a.currency_code, d.start_date
  HAVING SUM(NVL(begin_balance_dr,0)- NVL(begin_balance_cr,0) + NVL(period_net_dr,0) - NVL(period_net_cr,0)) <> 0