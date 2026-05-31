SELECT distinct bu.bu_name
FROM   FND_LOOKUP_VALUES_VL flvl, 
       FUN_ALL_BUSINESS_UNITS_V bu
WHERE  flvl.lookup_type = 'GED_BU_NAMES' 
AND flvl.meaning = bu.bu_name
AND UPPER(NVL(flvl.description, 'GED')) != 'AVIATION'
ORDER BY bu_name