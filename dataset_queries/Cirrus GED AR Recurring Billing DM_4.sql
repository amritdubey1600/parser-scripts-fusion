select NVL(attribute_char1,'NULL')
from doo_headers_eff_b 
where context_code = 'GED HEADER EFF CONTEXT'
group by attribute_char1