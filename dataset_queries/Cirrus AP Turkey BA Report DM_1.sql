--#-----------------------------------------------------------------------------------------------------#
--# MODIFICATION HISTORY:
--# CR#                       Author             Date                Description
--#-----------------------------------------------------------------------------------------------------#
--# REL-044              siva Kumar  			12-SEP-2020       The purpose of this report is to show count of invoices --#
--#																  above 5K TRY and shows the total number amount for each vendor for that specific month--#
--#-----------------------------------------------------------------------------------------------------#
SELECT
	   organization_id,
       bu_name,
       vendor_name,
       alternate_vendor_name,
       registration_number,
       country,
       COUNT(1)invoice_count,
       SUM(invoice_amount)
  FROM	
	 (SELECT
			 hou.organization_id,
			 hou. name 						AS bu_name,
			 hp.party_name 					AS vendor_name,
			 hp.party_unique_name 			AS alternate_vendor_name,
			 zptp.rep_registration_number 	AS registration_number,
			 hl.country,
			 aia.payment_currency_code,
			 aia.invoice_num,
			(SELECT SUM(aila.amount *
					NVL((SELECT gdr.conversion_rate
						   FROM GL_DAILY_RATES 				gdr
							   ,GL_DAILY_CONVERSION_TYPES 	gdc
						  WHERE 1=1
							AND gdr.conversion_type 	   = gdc.conversion_type
							AND gdr.to_currency	           = 'TRY'
							AND gdc.user_conversion_type   = 'MOR'
							AND gdr.from_currency          = aia.invoice_currency_code
							AND TRUNC(gdr.conversion_date) = TRUNC(aia.invoice_date)),1))	invoice_amount
			  FROM ap_invoice_lines_all aila
			 WHERE aila.invoice_id			  = aia.invoice_id
			   AND aila.line_type_lookup_code != 'TAX')invoice_amount	
	    FROM POZ_SUPPLIERS 			ps,
			 HZ_PARTIES				hp,
			 HZ_PARTY_SITES   		hps,
			 HZ_LOCATIONS     		hl,
			 AP_INVOICES_ALL  		aia,
			 HR_OPERATING_UNITS 	hou,
			 ZX_PARTY_TAX_PROFILE 	zptp
	   WHERE 1=1
		 AND ps.party_id   			 = hp.party_id
		 AND hp.party_id   			 = hps.party_id
		 AND hps.location_id  		 = hl.location_id
		 AND aia.vendor_id 			 = ps.vendor_id
		 AND hp.party_id 			 = zptp.party_id(+)
		 AND zptp.party_type_code(+) = 'THIRD_PARTY'
   		 AND aia.invoice_type_lookup_code = 'STANDARD'
		 AND aia.approval_status	!= 'CANCELLED'
		 AND aia.org_id 			 = hou.organization_id
		 AND hou.name  				 = NVL(:p_buname,hou.name)
		 AND TRUNC(aia.invoice_date) BETWEEN NVL(:p_start_date,SYSDATE-60) AND NVL(:p_end_date,SYSDATE)
		 ORDER BY hou. name 
	 )	
 WHERE 1=1
 GROUP BY 
organization_id,
bu_name,
vendor_name,
alternate_vendor_name,
registration_number,
country 
HAVING SUM(invoice_amount) > :p_inv_amt