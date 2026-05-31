SELECT 'COMPANY' KEY,a.flex_value||'~'||
    c.description||'~'||
    a.enabled_flag||'~'||
    TO_CHAR(a.start_date_active,'YYYYMMDD HH24:MI:SS')||'~'||
    TO_CHAR(a.end_date_active,'YYYYMMDD HH24:MI:SS')||'~'||
    a.summary_flag||'~'||
    a.attribute1||'~'||
    a.attribute2||'~'||
    a.attribute3||'~'||
    a.attribute4||'~'||
    a.attribute5||'~'||
    a.attribute7||'~'||
    a.attribute8||'~'||
    a.attribute9||'~'||
    a.attribute10||'~'||
    a.attribute11||'~'||
    a.attribute12||'~'||
    a.attribute16||'~'||
    a.attribute17||'~'||
    a.attribute23||'~'||
    a.attribute24||'~'||
    a.attribute25||'~'||
    a.attribute26||'~'||
    a.attribute31||'~'||
    a.attribute32||'~'||
    a.attribute33||'~'||
    a.attribute34||'~'||
    a.attribute35||'~'||
    a.attribute36||'~'||
    a.attribute37||'~'||
    a.attribute38||'~'||
    a.attribute39||'~'||
    a.attribute40||'~'||
    a.attribute41||'~'||
    a.attribute42||'~'||
    a.attribute43||'~'||
    a.attribute44||'~'||
    a.attribute50||'~'||
    a.created_by||'~'||
    TO_CHAR(a.creation_date,'YYYYMMDD HH24:MI:SS')||'~'||
    TO_CHAR(a.last_update_date,'YYYYMMDD HH24:MI:SS')||'~'||
    a.last_update_login||'~'||
    a.last_updated_by COMPANY,
a.flex_value
  FROM FND_FLEX_VALUES a,
    FND_FLEX_VALUE_SETS b,
    FND_FLEX_VALUES_TL c
  WHERE a.flex_value_set_id = b.flex_value_set_id
  AND b.flex_value_set_name = 'CCL_COMPANY_CODES'
  AND a.flex_value_id       = c.flex_value_id
  AND c.language            = 'US'

 -- REL-015 added  below code

   AND a.flex_value NOT  IN 
           
          (  SELECT  lookup_code
  	       FROM FND_LOOKUP_VALUES
  	      WHERE lookup_type  ='CIRRUSGL_ERP_INT_COCO_NAME'
  	        AND  language='US'
  	        AND enabled_Flag='Y'
  	        AND   TRUNC( SYSDATE)  
                           BETWEEN   NVL ( start_date_active , TRUNC(SYSDATE)) 
                                     AND NVL( end_date_active ,TRUNC(SYSDATE)) )
             
           
           
  -- REL-015 added  above code

order by length(a.flex_value) desc