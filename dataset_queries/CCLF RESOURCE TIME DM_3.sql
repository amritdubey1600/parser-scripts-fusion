SELECT DISTINCT ppn.list_name ,
    ppn.person_id
  FROM pjf_latestprojectmanager_v plm ,
    pjf_projects_all_vl ppa ,
    per_person_names_f ppn ,
    hr_organization_v hov ,
    fun_all_business_units_v fab
  WHERE plm.resource_source_id         = ppn.person_id(+)
  AND ppa.project_id                   = plm.project_id(+)
  AND ppa.org_id                       = fab.bu_id
  AND ppa.carrying_out_organization_id = hov.organization_id
  AND hov.classification_code          = 'PA_PROJECT_ORG'
  AND ppn.name_type                    = 'GLOBAL'
  AND TRUNC( SYSDATE ) BETWEEN hov.effective_start_date AND NVL( hov.effective_end_date, SYSDATE + 1)