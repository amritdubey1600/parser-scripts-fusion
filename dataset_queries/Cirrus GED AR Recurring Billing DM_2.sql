SELECT fabuv.bu_name
FROM FND_LOOKUP_VALUES flv,
fun_all_business_units_v fabuv
WHERE 1=1
AND flv.lookup_code                      =  fabuv.bu_name
AND flv.lookup_type                      = 'GED_BU_NAMES'
AND LANGUAGE                             = 'US'
AND flv.enabled_flag                     = 'Y'
AND UPPER(NVL(flv.description, 'GED'))  != 'AVIATION'