SELECT  :P_EXTRACT_TYPE extract_type
      ,a.period_name
      ,b.segment1
      ,b.segment2
      ,b.segment3
      ,a.currency_code
      ,'CC30' sender_id
      ,'USDRQ' amount_type
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
        AND pk1_start_value = b.segment2)  "MARS_Account"
        ,(SELECT parent_PK1_VALUE
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
        AND pk1_start_value = b.segment3) ile
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
AND :P_EXTRACT_TYPE = 'CCA'
AND d.period_name = a.period_name
AND d.period_set_name = c.period_set_name
-- Changed to use latest open period if Period Name is not passed. 09 Sep.
--AND a.period_name = :P_PERIOD
AND ( (a.period_name = :P_PERIOD AND :P_PERIOD IS NOT NULL) OR
      (a.period_name = c.latest_opened_period_name AND :P_PERIOD IS NULL)
    )
--
AND EXISTS (SELECT '1'
        FROM fnd_tree_node ftn
            ,FND_TREE_VERSION_VL ftv
        WHERE 1=1
        AND ftn.tree_Code =  'ACCOUNT MARS UNPUBLISHED'
        AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
        AND ftv.tree_Code = ftn.tree_code
        AND ftv.tree_structure_code = ftn.tree_structure_code
        AND ftv.TREE_VERSION_NAME = 'CURRENT'
        AND ftn.TREE_VERSION_ID = ftv.TREE_VERSION_ID
        AND pk1_start_value = b.segment2
        AND parent_PK1_VALUE = '472003004')
GROUP by a.period_name, segment1, segment2, segment3
        ,a.currency_code, d.start_date
HAVING SUM(NVL(begin_balance_dr,0)- NVL(begin_balance_cr,0) + NVL(period_net_dr,0) - NVL(period_net_cr,0)) <> 0       
UNION
SELECT :P_EXTRACT_TYPE extract_type
      ,a.period_name
      ,b.segment1
      ,b.segment2
      ,b.segment3
      ,a.currency_code
      ,'CC30' sender_id
      ,'USDRQ' amount_type
      ,TO_CHAR(d.Start_Date,'MM')||'15'||TO_CHAR(d.Start_Date,'YYYY') effective_date
      , (SELECT parent_PK1_VALUE
	        FROM fnd_tree_node ftn
	            ,FND_TREE_VERSION_VL ftv
	        WHERE 1=1
	        AND ftn.tree_Code =  'TP MARS IBU UNPUBLISHED'
	        AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
	        AND ftv.tree_Code = ftn.tree_code
	        AND ftv.tree_structure_code = ftn.tree_structure_code
	        AND ftv.TREE_VERSION_NAME = 'CURRENT'
	        AND ftn.TREE_VERSION_ID = ftv.TREE_VERSION_ID
        AND pk1_start_value = b.segment3) "BUSINESS_UNIT" 
        , (SELECT parent_PK1_VALUE
        FROM fnd_tree_node ftn
            ,FND_TREE_VERSION_VL ftv
        WHERE 1=1
        AND ftn.tree_Code =  'TP MARS ILE UNPUBLISHED'
        AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
        AND ftv.tree_Code = ftn.tree_code
        AND ftv.tree_structure_code = ftn.tree_structure_code
        AND ftv.TREE_VERSION_NAME = 'CURRENT'
        AND ftn.TREE_VERSION_ID = ftv.TREE_VERSION_ID
        AND pk1_start_value = b.segment3) "LEGAL_ENTITY"
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
        AND pk1_start_value = b.segment1)  IBU
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
        AND pk1_start_value = b.segment1) ILE
      ,NULL analysis
      ,NULL type
     ,:P_RUN_TYPE run_type
      ,SUM(NVL(a.begin_balance_dr,0)- NVL(a.begin_balance_cr,0) + NVL(a.period_net_dr,0) - NVL(a.period_net_cr,0)) * -1 amount
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
AND :P_EXTRACT_TYPE = 'CCA'
AND d.period_name = a.period_name
AND d.period_set_name = c.period_set_name
-- Changed to use latest open period if Period Name is not passed. 09 Sep.
--AND a.period_name = :P_PERIOD
AND ( (a.period_name = :P_PERIOD AND :P_PERIOD IS NOT NULL) OR
      (a.period_name = c.latest_opened_period_name AND :P_PERIOD IS NULL)
    )
--
AND EXISTS (SELECT '1'
        FROM fnd_tree_node ftn
            ,FND_TREE_VERSION_VL ftv
        WHERE 1=1
        AND ftn.tree_Code =  'ACCOUNT MARS UNPUBLISHED'
        AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
        AND ftv.tree_Code = ftn.tree_code
        AND ftv.tree_structure_code = ftn.tree_structure_code
        AND ftv.TREE_VERSION_NAME = 'CURRENT'
        AND ftn.TREE_VERSION_ID = ftv.TREE_VERSION_ID
        AND pk1_start_value = b.segment2
        AND parent_PK1_VALUE = '472003004')
GROUP by a.period_name, segment1, segment2, segment3
        ,a.currency_code, d.start_date
HAVING SUM(NVL(begin_balance_dr,0)- NVL(begin_balance_cr,0) + NVL(period_net_dr,0) - NVL(period_net_cr,0)) <> 0
-- end of CCA
--start of TCPCAD
UNION
SELECT :P_EXTRACT_TYPE extract_type
      ,a.period_name
      ,b.segment1
      ,b.segment2
      ,b.segment3
      ,a.currency_code
      ,'CC30' sender_id
      ,'USDRQ' amount_type
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
        ,(SELECT parent_PK1_VALUE
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
        AND pk1_start_value = b.segment3) ILE
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
AND :P_EXTRACT_TYPE = 'TCPCAD'
AND d.period_name = a.period_name
AND d.period_set_name = c.period_set_name
-- Changed to use latest open period if Period Name is not passed. 09 Sep.
--AND a.period_name = :P_PERIOD
AND ( (a.period_name = :P_PERIOD AND :P_PERIOD IS NOT NULL) OR
      (a.period_name = c.latest_opened_period_name AND :P_PERIOD IS NULL)
    )
--
AND EXISTS (SELECT '1'
        FROM fnd_tree_node ftn
            ,FND_TREE_VERSION_VL ftv
        WHERE 1=1
        AND ftn.tree_Code =  'ACCOUNT MARS UNPUBLISHED'
        AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
        AND ftv.tree_Code = ftn.tree_code
        AND ftv.tree_structure_code = ftn.tree_structure_code
        AND ftv.TREE_VERSION_NAME = 'CURRENT'
        AND ftn.TREE_VERSION_ID = ftv.TREE_VERSION_ID
        AND pk1_start_value = b.segment2
        AND parent_PK1_VALUE = '313073006')
GROUP by a.period_name, segment1, segment2, segment3
        ,a.currency_code, d.start_date
HAVING SUM(NVL(begin_balance_dr,0)- NVL(begin_balance_cr,0) + NVL(period_net_dr,0) - NVL(period_net_cr,0)) <> 0       
UNION
SELECT :P_EXTRACT_TYPE extract_type
      ,a.period_name
      ,b.segment1
      ,b.segment2
      ,b.segment3
      ,a.currency_code
      ,'CC30' sender_id
      ,'USDRQ' amount_type
      ,TO_CHAR(d.Start_Date,'MM')||'15'||TO_CHAR(d.Start_Date,'YYYY') effective_date
      , (SELECT parent_PK1_VALUE
	        FROM fnd_tree_node ftn
	            ,FND_TREE_VERSION_VL ftv
	        WHERE 1=1
	        AND ftn.tree_Code =  'TP MARS IBU UNPUBLISHED'
	        AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
	        AND ftv.tree_Code = ftn.tree_code
	        AND ftv.tree_structure_code = ftn.tree_structure_code
	        AND ftv.TREE_VERSION_NAME = 'CURRENT'
	        AND ftn.TREE_VERSION_ID = ftv.TREE_VERSION_ID
        AND pk1_start_value = b.segment3) "BUSINESS_UNIT" 
        , (SELECT parent_PK1_VALUE
        FROM fnd_tree_node ftn
            ,FND_TREE_VERSION_VL ftv
        WHERE 1=1
        AND ftn.tree_Code =  'TP MARS ILE UNPUBLISHED'
        AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
        AND ftv.tree_Code = ftn.tree_code
        AND ftv.tree_structure_code = ftn.tree_structure_code
        AND ftv.TREE_VERSION_NAME = 'CURRENT'
        AND ftn.TREE_VERSION_ID = ftv.TREE_VERSION_ID
        AND pk1_start_value = b.segment3) "LEGAL_ENTITY"
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
        AND pk1_start_value = b.segment1)  IBU
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
        AND pk1_start_value = b.segment1) ILE
      ,NULL analysis
      ,NULL type
     ,:P_RUN_TYPE run_type
      ,SUM(NVL(a.begin_balance_dr,0)- NVL(a.begin_balance_cr,0) + NVL(a.period_net_dr,0) - NVL(a.period_net_cr,0)) * -1 amount
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
AND :P_EXTRACT_TYPE = 'TCPCAD'
AND d.period_name = a.period_name
AND d.period_set_name = c.period_set_name
-- Changed to use latest open period if Period Name is not passed. 09 Sep.
--AND a.period_name = :P_PERIOD
AND ( (a.period_name = :P_PERIOD AND :P_PERIOD IS NOT NULL) OR
      (a.period_name = c.latest_opened_period_name AND :P_PERIOD IS NULL)
    )
--
AND EXISTS (SELECT '1'
        FROM fnd_tree_node ftn
            ,FND_TREE_VERSION_VL ftv
        WHERE 1=1
        AND ftn.tree_Code =  'ACCOUNT MARS UNPUBLISHED'
        AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
        AND ftv.tree_Code = ftn.tree_code
        AND ftv.tree_structure_code = ftn.tree_structure_code
        AND ftv.TREE_VERSION_NAME = 'CURRENT'
        AND ftn.TREE_VERSION_ID = ftv.TREE_VERSION_ID
        AND pk1_start_value = b.segment2
        AND parent_PK1_VALUE = '313073006')
AND  (SELECT parent_PK1_VALUE
        FROM fnd_tree_node ftn
            ,FND_TREE_VERSION_VL ftv
        WHERE 1=1
        AND ftn.tree_Code =  'TP MARS IBU UNPUBLISHED'
        AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
        AND ftv.tree_Code = ftn.tree_code
        AND ftv.tree_structure_code = ftn.tree_structure_code
        AND ftv.TREE_VERSION_NAME = 'CURRENT'
        AND ftn.TREE_VERSION_ID = ftv.TREE_VERSION_ID
        AND pk1_start_value = b.segment3) <> 'CANLTD'      
GROUP by a.period_name, segment1, segment2, segment3
        ,a.currency_code, d.start_date
HAVING SUM(NVL(begin_balance_dr,0)- NVL(begin_balance_cr,0) + NVL(period_net_dr,0) - NVL(period_net_cr,0)) <> 0