SELECT 'JEHEAD' KEY,
je_header_id||'~'||
       last_update_date||'~'||
       last_updated_by||'~'||
       name||'~'||
       status||'~'||
       creation_date||'~'||
       created_by||'~'||
       accrual_rev_period_name||'~'||
       accrual_rev_status||'~'||
       accrual_rev_je_header_id||'~'||
       description||'~'||
       currency_conversion_rate||'~'||
       currency_conversion_type||'~'||
       currency_conversion_date||'~'||
       parent_je_header_id||'~'||
       reversed_je_header_id||'~'||
       attribute1||'~'||
       doc_sequence_id||'~'||
       doc_sequence_value JE_HEADERS
FROM (SELECT gjh.je_header_id, 
             TO_CHAR(gjh.last_update_date,'YYYYMMDD HH24:MI:SS') last_update_date, 
             gjh.last_updated_by, replace(gjh.name,'~',' ') name, 
             gjh.status, 
             TO_CHAR(gjh.creation_date,'YYYYMMDD HH24:MI:SS') creation_date , 
             gjh.created_by, 
             gjh.accrual_rev_period_name, 
             gjh.accrual_rev_status, 
             TO_CHAR(gjh.accrual_rev_je_header_id) accrual_rev_je_header_id, 
             REPLACE(REPLACE(REPLACE(REPLACE(REPLACE( replace(gjh.description,'~',' '),',',';'), CHR(13), ' '), CHR(10), ' '),CHR(9), ' '),CHR(160),' ') description ,
             TO_CHAR(gjh.currency_conversion_rate) currency_conversion_rate, 
             gjh.currency_conversion_type, 
             TO_CHAR(gjh.currency_conversion_date,'YYYYMMDD HH24:MI:SS') currency_conversion_date, 
             TO_CHAR(gjh.parent_je_header_id) parent_je_header_id, 
             TO_CHAR(gjh.reversed_je_header_id) reversed_je_header_id, 
             gjh.attribute1, 
             TO_CHAR(gjh.doc_sequence_id) doc_sequence_id, 
             TO_CHAR(gjh.doc_sequence_value) doc_sequence_value
FROM GL_JE_HEADERS gjh
where  trunc(gjh.posted_date) = NVL(:P_DATE,trunc(gjh.posted_date)))