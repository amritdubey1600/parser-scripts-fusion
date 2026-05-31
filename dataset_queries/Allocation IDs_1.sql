select rule_id
, rule_name
, ruleset_id
, to_char(creation_date,'DD-MON-RRRR') creation_date
, created_by
, to_char(last_update_date,'DD-MON-RRRR') last_update_date
, last_updated_by
, object_version_number
, alloc_rule_id
from gl_alloc_rules