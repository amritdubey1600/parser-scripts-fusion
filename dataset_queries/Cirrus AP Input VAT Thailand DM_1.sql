--#-----------------------------------------------------------------------------------------------------#
--# MODIFICATION HISTORY:
--# CR#                       Author             Date                Description
--#-----------------------------------------------------------------------------------------------------#
--# REL-047   				  S Karthik  		09-Dec-2020  	Initial Version - AP VAT Details		--#                                                                                 

--#-----------------------------------------------------------------------------------------------------#


SELECT DISTINCT  'General Electric International Operations Co, Inc.'													vat_registrant_name
			    ,'Head Office'																													branch_code
				,'9th Capital Tower, All Seasons Place, 87/1 Wireless Road, Lumpini, Phatumwan, Bangkok 10330, Thailand'						le_address
			    ,'0100522000419'																												tax_id_of_purchaser
				,DECODE(SUBSTR((TO_CHAR(:p_end_date,'MON')),1,2),'01','JAN','02','FEB','03','MAR','04','APR','05','MAY','06','JUN','07','JUL',
							'08','AUG','09','SEP','10','OCT','11','NOV','12','DEC')																current_month
				,TO_CHAR(:p_end_date,'YYYY')																									current_year
				FROM 
				HR_ORGANIZATION_UNITS hou
				WHERE 1=1
				AND hou.name = NVL(:p_buname,hou.name)