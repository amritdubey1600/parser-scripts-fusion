SELECT 'BOOKTYPE' KEY,a.flex_value||'~'||c.Description||'~'||a.Enabled_Flag||'~'||a.Summary_Flag||'~'||TO_CHAR(a.end_date_active,'YYYYMMDD HH24:MI:SS')
||'~'||TO_CHAR(a.creation_date,'YYYYMMDD HH24:MI:SS')||'~'||TO_CHAR(c.last_update_date,'YYYYMMDD HH24:MI:SS') BOOKTYPE 
FROM 
  fnd_flex_values a, 
  fnd_flex_value_sets b, 
  fnd_flex_values_tl c 
WHERE 
  a.flex_value_set_id = b.flex_value_set_id  AND 
  b.flex_value_set_name = 'CCL_BOOK_TYPES'  AND 
  a.flex_value_id = c.flex_value_id  AND 
  c.language = 'US'