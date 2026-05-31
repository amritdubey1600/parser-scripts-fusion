SELECT 'SOURCE' KEY, je_source_name||'~'||language||'~'||source_lang||'~'||last_update_date||'~'||last_updated_by||'~'||override_edits_flag||'~'||user_je_source_name||'~'||
journal_reference_flag||'~'||journal_approval_flag||'~'||import_using_key_flag||'~'||creation_date||'~'||created_by||'~'||description||'~'||attribute1||'~'||attribute2||'~'||attribute3 JE_SOURCES
FROM (
SELECT js.je_source_name, js.language, js.source_lang, TO_CHAR(js.last_update_date,'YYYYMMDD HH24:MI:SS') last_update_date, js.last_updated_by, js.override_edits_flag, js.user_je_source_name, 
js.journal_reference_flag,js.journal_approval_flag, js.import_using_key_flag,TO_CHAR(js.creation_date,'YYYYMMDD HH24:MI:SS') creation_date, js.created_by, js.description, js.attribute1, 
js.attribute2, js.attribute3
FROM
 GL_JE_SOURCES_VL js)