SELECT 'V360' company_code,
       batch_id||'~'||
       LAST_UPDATE_DATE||'~'||
       LAST_UPDATED_BY||'~'||
       name||'~'||
       status||'~'||
       approval_status_code||'~'||
       creation_date||'~'||
       created_by||'~'||
       description||'~'||
       attribute1||'~'||
       attribute2||'~'||
       attribute3||'~'||
       attribute4||'~'||
       attribute5||'~'||
       attribute6||'~'||
       attribute7||'~'||
       attribute8||'~'||
       attribute9||'~'||
       attribute10 JE_BATCHES
FROM (SELECT 
       'F'||TO_CHAR(gjb.JE_BATCH_ID) BATCH_ID, 
       TO_CHAR(gjb.LAST_UPDATE_DATE,'YYYYMMDD HH24:MI:SS') LAST_UPDATE_DATE, 
       gjb.LAST_UPDATED_BY, 
       replace(gjb.NAME ,'~',' ') Name , 
       gjb.STATUS, 
       gjb.APPROVAL_STATUS_CODE, 
       TO_CHAR(gjb.CREATION_DATE,'YYYYMMDD HH24:MI:SS') CREATION_DATE, 
       gjb.CREATED_BY, 
       REPLACE(REPLACE(REPLACE(REPLACE(REPLACE( replace(gjb.description,'~',' '),',',';'), CHR(13), ' '), CHR(10), ' '),CHR(9), ' '),CHR(160),' ') description ,
       gjb.ATTRIBUTE1, 
       gjb.ATTRIBUTE2, 
       gjb.ATTRIBUTE3, 
       gjb.ATTRIBUTE4, 
       gjb.ATTRIBUTE5, 
       gjb.ATTRIBUTE6, 
       gjb.ATTRIBUTE7, 
       gjb.ATTRIBUTE8, 
       gjb.ATTRIBUTE9, 
       gjb.ATTRIBUTE10
FROM  GL_JE_BATCHES gjb
where trunc(gjb.posted_date) between NVL(:P_FROM_DATE,trunc(sysdate-15)) and NVL(:P_TO_DATE,trunc(sysdate))
)