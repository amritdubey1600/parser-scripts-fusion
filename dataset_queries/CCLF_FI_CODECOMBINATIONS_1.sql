SELECT 'CCD' KEY, TO_CHAR(code_combination_id)||'~'||enabled_flag||'~'||summary_flag||'~'||account_type||'~'||
segment1||'~'||segment2||'~'||segment3||'~'||segment4||'~'||segment5||'~'||segment6||'~'||segment7||'~'||segment8||'~'||segment9||'~'||segment10||'~'||segment11||'~'||
segment1||'.'||segment2||'.'||segment3||'.'||segment4||'.'||segment5||'.'||segment6||'.'||segment7||'.'||segment8||'.'||segment9||'.'||segment10||'.'||segment11||'~'||to_char(last_update_date,'yyyymmdd hh24:mi:ss') ccid
FROM GL_CODE_COMBINATIONS GCC
WHERE   detail_posting_allowed_flag = 'Y'

-- REL-015 added  below code

 AND segment1   NOT IN 
                 
          (  SELECT  lookup_code
	        FROM FND_LOOKUP_VALUES
	     WHERE lookup_type  ='CIRRUSGL_ERP_INT_COCO_NAME'
	           AND  language='US'
	           AND enabled_Flag='Y'
	           AND   TRUNC( SYSDATE)  
	                    BETWEEN   NVL ( start_date_active , TRUNC(SYSDATE)) 
                   AND NVL( end_date_active ,TRUNC(SYSDATE)) )
         
         
-- REL-015 added  above code