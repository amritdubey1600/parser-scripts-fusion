--start of funcm
SELECT a.period_name
      ,b.segment1
      ,b.segment2
      ,b.segment3
      ,a.currency_code
      ,'CC32' sender_id
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
--AND c.name IN ('AU_AUD_PRM','NZ_NZD_PRM','BN_BND_PRM','ID_IDR_PRM','JP_JPY_PRM','MY_MYR_PRM','PH_PHP_PRM')
AND c.name IN (SELECT flv.lookup_code
                 FROM fnd_lookup_types flt,
                      fnd_lookup_values flv
                WHERE flt.lookup_type   = 'CCLF_MARS_GBSAAA_LEDGER'
                  AND flt.lookup_type   = flv.lookup_type
                  AND flv.language      = 'US'
                  AND flv.tag           ='PRIMARY')
--AND b.segment1 IN ('GAU1','GAU4','GNZ1','GJP1','GJP3','GJP2','GID2','GID1','GID3','GPH1','GMY1','GBN1') 
AND b.segment1 IN (SELECT flv.lookup_code 
                     FROM fnd_lookup_types flt,
                          fnd_lookup_values flv
                    WHERE flt.lookup_type   = 'CCLF_MARS_GBSAAA_COMPANY'
                      AND flt.lookup_type   = flv.lookup_type
                      AND flv.language      = 'US')
--AND b.segment1 IN ('GNZ1','GJP1','GJP3','GJP2','GID2','GID1','GID3','GPH1','GMY1','GBN1') 
AND segment9 <> 'S'              -- exclude statutory adjustments
AND :P_AMOUNT_TYPE = 'FUNCM'
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
      ,'CC32' sender_id
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
--AND c.name IN('AU_USD_RPT','NZ_USD_RPT','BN_USD_RPT','ID_USD_RPT','JP_USD_RPT','MY_USD_RPT','PH_USD_RPT')
AND c.name IN (SELECT flv.lookup_code
                 FROM fnd_lookup_types flt,
                      fnd_lookup_values flv
                WHERE flt.lookup_type   = 'CCLF_MARS_GBSAAA_LEDGER'
                  AND flt.lookup_type   = flv.lookup_type
                  AND flv.language      = 'US'
                  AND flv.tag ='REPORTING')
AND c.currency_code = 'USD'    -- Include all USD functional currency Reporting books
--AND b.segment1 IN ('GAU1','GAU4','GNZ1','GJP1','GJP3','GJP2','GID2','GID1','GID3','GPH1','GMY1','GBN1') 
AND b.segment1 IN (SELECT flv.lookup_code 
                     FROM fnd_lookup_types flt,
                          fnd_lookup_values flv
                    WHERE flt.lookup_type   = 'CCLF_MARS_GBSAAA_COMPANY'
                      AND flt.lookup_type   = flv.lookup_type
                      AND flv.language      = 'US')
AND segment9 <> 'S' -- exclude Statutory Adjustment
AND :P_AMOUNT_TYPE = 'ORINM'
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
      ,'CC32' sender_id
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
--AND c.name IN('AU_USD_RPT','NZ_USD_RPT','BN_USD_RPT','ID_USD_RPT','JP_USD_RPT','MY_USD_RPT','PH_USD_RPT')
AND c.name IN (SELECT flv.lookup_code
                 FROM fnd_lookup_types flt,
                      fnd_lookup_values flv
                WHERE flt.lookup_type   = 'CCLF_MARS_GBSAAA_LEDGER'
                  AND flt.lookup_type   = flv.lookup_type
                  AND flv.language      = 'US'
                  AND flv.tag ='REPORTING')
AND c.currency_code = 'USD'   -- with functional currency as USD
AND a.currency_code = c.currency_code  -- only USD balances
--AND b.segment1 IN ('GAU1','GAU4','GNZ1','GJP1','GJP3','GJP2','GID2','GID1','GID3','GPH1','GMY1','GBN1') 
AND b.segment1 IN (SELECT flv.lookup_code 
                     FROM fnd_lookup_types flt,
                          fnd_lookup_values flv
                    WHERE flt.lookup_type   = 'CCLF_MARS_GBSAAA_COMPANY'
                      AND flt.lookup_type   = flv.lookup_type
                      AND flv.language      = 'US')
AND b.segment9 <> 'S'  -- exclude statutory adjustments
AND :P_AMOUNT_TYPE IN ('USDRM','USDRQ')
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