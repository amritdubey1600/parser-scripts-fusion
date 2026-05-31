SELECT 'CATEGORY' KEY,
       je_category_name||'~'||
       language||'~'||
       source_lang||'~'||
       user_je_category_name||'~'||
       last_update_date||'~'||
       last_updated_by||'~'||
       creation_date||'~'||
       created_by||'~'||
       description  JE_CATEGORY
FROM (
SELECT cat.je_category_name je_category_name, 
       cat.language language, 
       cat.source_lang source_lang, 
       cat.user_je_category_name user_je_category_name, 
       TO_CHAR(cat.last_update_date,'YYYYMMDD HH24:MI:SS') last_update_date,
       cat.last_updated_by last_updated_by, 
       TO_CHAR(cat.creation_date,'YYYYMMDD HH24:MI:SS') creation_date, 
       cat.created_by, 
       REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(cat.description,',',';'), CHR(13), ' '), CHR(10), ' '),CHR(9), ' '),CHR(160),' ') description
FROM  gl_je_categories_vl cat)