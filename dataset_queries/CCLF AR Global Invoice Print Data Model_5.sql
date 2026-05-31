select distinct b.bu_name,b.bu_id from gl_ledger_le_v a,fun_all_business_units_v b
where a.ledger_id = b.primary_ledger_id
and a.legal_entity_id = :p_legal_entity