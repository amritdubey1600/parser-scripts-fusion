SELECT flv.meaning
                                                FROM FND_LOOKUP_VALUES     flv
                                                WHERE flv.lookup_type                    	=  'GED_BU_NAMES'
                                                AND LANGUAGE                             	=  'US'
                                                AND flv.enabled_flag                     	=  'Y'
                                                AND UPPER(NVL(flv.description, 'GED')) 		!=  'AVIATION'
                                                AND NVL(flv.start_date_active, SYSDATE) 	<=  SYSDATE
                                                AND NVL(flv.end_date_active, SYSDATE)   	>=  SYSDATE