--#-----------------------------------------------------------------------------------------------------#
--# MODIFICATION HISTORY:                                                                           -#
--# CREATION DATE : 30-AUG-2020                                                                       -#
--# CR#                         Author             Date                Description                     -#
--#-----------------------------------------------------------------------------------------------------#
--# REL-044                  siva kumar dandu    04-SEP-2020           The purpose of this report is to detail the requirements related to the    --#
--#																	   India GST Input report to be developed to meet GST requirements in India  --#
--# REL-053                  Amjad Mohd          25-May-2021           GEINC9369134/GERITM22477600 Report is erroring out due to multiple Tax Rates --#
--# REL-074                  Amjad Mohd          10-Mar-2023           GEINC12919296: Report is erroring out in Feb-23 Period
--#-------------------------------------------------------------------------------------------------------#

SELECT DISTINCT xep.name 							legalentityname,
         glcc_liab.segment1 						legalentitycode,
         hou.name 									businessunitcode,
         TO_CHAR ( :p_start_date, 'DD-MM-YYYY') 	reportingperiodbegindate,
         TO_CHAR ( :p_end_date, 'DD-MM-YYYY') 		reportingperiodenddate,
         apla.product_type,
         ps.vendor_type_lookup_code 				suppliertype,
         hp.party_name 								suppliername,
         ps.segment1 								supplieraccountnumber,
		 apa.invoice_id,
		 apla.line_number,
		NVL((SELECT zr.registration_number
			   FROM ZX_REGISTRATIONS zr,
					ZX_PARTY_TAX_PROFILE zptn
			  WHERE 1=1
				AND zr.party_tax_profile_id = zptn.party_tax_profile_id
				AND SYSDATE  BETWEEN NVL(zr.effective_from,SYSDATE) AND NVL(zr.effective_to,SYSDATE+1)
				AND zptn.party_id = (SELECT DISTINCT hps.party_site_id 
									   FROM HZ_PARTY_SITES hps
									  WHERE hps.party_id = hp.party_id
										AND hps.party_site_id = poss.party_site_id
										)
			),
			NVL((SELECT zpt.rep_registration_number 
			   FROM ZX_PARTY_TAX_PROFILE zpt
			  WHERE 1=1
				AND zpt.party_id = (SELECT DISTINCT hps.party_site_id 
									  FROM HZ_PARTY_SITES hps
									 WHERE hps.party_id = hp.party_id
									   AND hps.party_site_id = poss.party_site_id
							           ))
			,NVL((SELECT zr.registration_number
			   FROM ZX_REGISTRATIONS zr,
					ZX_PARTY_TAX_PROFILE zptn
			  WHERE 1=1
				AND zr.party_tax_profile_id = zptn.party_tax_profile_id
				AND SYSDATE  BETWEEN NVL(zr.effective_from,SYSDATE) AND NVL(zr.effective_to,SYSDATE+1)
				AND zptn.party_id = hp.party_id
				),
				(SELECT zpt.rep_registration_number 
				   FROM ZX_PARTY_TAX_PROFILE zpt
				   WHERE 1=1
					 AND zpt.party_id = hp.party_id
					 )))
		)											supplieritxregistrationnumber,
         hl.country 								suppliercountrycode,
         COALESCE (poss.vat_registration_num, poss.vat_code)	suppbilltxregnumber,
         hl.address1 								supplierbillingaddress1,
         hl.address2 								supplierbillingaddress2,
         hl.city 									supplierbillingcity,
         COALESCE (hl.state, hl.province) 			supplierbillingstateprovince,
         hl.postal_code 							supplierbillingpostalcode,
         hl.county 									supplierbillingregion,
         hl.country 								supplierbillingcountrycode,
         NULL 										suppshipitxregnumber,
         NVL (hl_ship_from.address1, hl.address1) 	suppliershippingaddress1,
         NVL (hl_ship_from.address2, hl.address2) 	suppliershippingaddress2,
         NVL (hl_ship_from.city, hl.city) 			suppliershippingcity,
         COALESCE (hl_ship_from.state,
                   hl_ship_from.province,
                   hl.state,
                   hl.province)							suppliershippingstateprovince,
         NVL (hl_ship_from.postal_code, hl.postal_code)	suppliershippingpostalcode,
         NVL (hl_ship_from.county, hl.county) 		suppliershippingregion,
         NVL (hl_ship_from.country, hl.country) 	suppliershippingcountrycode,
         hl_ship_to.country 						suppliershiptocountrycode,
         NULL 										transactioncode,
	    (SELECT z.tax_rate_code 
		   FROM ZX_LINES_V z 
		  WHERE z.tax_full_name='IN_CGST'
            AND z.trx_id   		=	apa.invoice_id
			and z.CANCEL_FLAG='N'-- Added for REL-053 GEINC9369134/GERITM22477600
            AND z.trx_line_id 	=	apla.line_number)  				cgsttaxcode ,
		 (SELECT z.tax_rate_code 
		    FROM ZX_LINES_V z 
		   WHERE z.tax_full_name='IN_SGST'
             AND apa.invoice_id = z.trx_id
			 and z.CANCEL_FLAG='N' -- Added for REL-053 GEINC9369134/GERITM22477600
             AND apla.line_number = z.trx_line_id)  				sgsttaxcode,
		 (SELECT z.tax_rate_code 
		    FROM ZX_LINES_V z 
		   WHERE z.tax_full_name='IN_IGST'
             AND apa.invoice_id = z.trx_id
			 and z.CANCEL_FLAG='N'-- Added for REL-053 GEINC9369134/GERITM22477600
             AND apla.line_number = z.trx_line_id)  				igsttaxcode,
		 (SELECT z.tax_rate_code 
		    FROM ZX_LINES_V z 
		   WHERE z.tax_full_name='IN_GST_COMPENSATION_CESS'
             AND apa.invoice_id = z.trx_id
			 and z.CANCEL_FLAG='N'-- Added for REL-053 GEINC9369134/GERITM22477600
             AND apla.line_number = z.trx_line_id)  			 	cesstaxcode,
         TO_CHAR (zl.tax_date, 'DD-MM-YYYY') 						taxpoint,
		(SELECT z.tax_amt 
		   FROM ZX_LINES_V z 
		  WHERE z.tax_full_name='IN_CGST'
            AND apa.invoice_id = z.trx_id
			and z.CANCEL_FLAG='N'-- Added for REL-053 GEINC9369134/GERITM22477600
            AND apla.line_number = z.trx_line_id)  					cgst_amt,
		 (SELECT z.tax_amt 
		    FROM ZX_LINES_V z 
		   WHERE z.tax_full_name='IN_SGST'
			 AND apa.invoice_id = z.trx_id
			 and z.CANCEL_FLAG='N'-- Added for REL-053 GEINC9369134/GERITM22477600
			 AND apla.line_number = z.trx_line_id)  				sgst_amt,
		 (SELECT z.tax_amt 
		    FROM ZX_LINES_V z 
		   WHERE z.tax_full_name='IN_IGST'
             AND apa.invoice_id = z.trx_id
			 and z.CANCEL_FLAG='N'-- Added for REL-053 GEINC9369134/GERITM22477600
             AND apla.line_number = z.trx_line_id)  				igst_amt,
		 (SELECT z.tax_amt 
		   FROM ZX_LINES_V z 
		  WHERE z.tax_full_name='IN_GST_COMPENSATION_CESS'
            AND apa.invoice_id = z.trx_id
			and z.CANCEL_FLAG='N'-- Added for REL-053 GEINC9369134/GERITM22477600
            AND apla.line_number = z.trx_line_id)  					cess_amt,
		 (SELECT z.tax_rate 
		    FROM ZX_LINES_V z 
		   WHERE z.tax_full_name='IN_CGST'
             AND apa.invoice_id = z.trx_id
			 and z.CANCEL_FLAG='N'-- Added for REL-053 GEINC9369134/GERITM22477600
             AND apla.line_number = z.trx_line_id)  				cgst_rate,
		 (SELECT z.tax_rate 
		    FROM ZX_LINES_V z 
		   WHERE z.tax_full_name='IN_SGST'
             AND apa.invoice_id = z.trx_id
			 and z.CANCEL_FLAG='N'-- Added for REL-053 GEINC9369134/GERITM22477600
             AND apla.line_number = z.trx_line_id)  				sgst_rate,
		 (SELECT z.tax_rate 
		   FROM ZX_LINES_V z 
		  WHERE z.tax_full_name='IN_IGST'
            AND apa.invoice_id = z.trx_id
			and z.CANCEL_FLAG='N'-- Added for REL-053 GEINC9369134/GERITM22477600
            AND apla.line_number = z.trx_line_id)  					igst_rate,
		 (SELECT z.tax_rate 
		    FROM ZX_LINES_V z 
		   WHERE z.tax_full_name='IN_GST_COMPENSATION_CESS'
             AND apa.invoice_id = z.trx_id
			 and z.CANCEL_FLAG='N'-- Added for REL-053 GEINC9369134/GERITM22477600
             AND apla.line_number = z.trx_line_id)  				cess_rate,
		(SELECT intl.unit_of_measure
		  FROM INV_UNITS_OF_MEASURE_B inb,
		       INV_UNITS_OF_MEASURE_TL intl
		 WHERE inb.unit_of_measure_id = intl.unit_of_measure_id
		   AND intl.language='US'
		   AND inb.uom_code = apla.unit_meas_lookup_code) 		AS units,
		 apla.quantity_invoiced 				 	 AS quantity,
         alc.displayed_field 							documenttype,
         apa.invoice_num 								invoicenumber,
         TO_CHAR (apa.invoice_date, 'DD-MM-YYYY') 		invoicedate,
         TO_CHAR (aida.accounting_date, 'DD-MM-YYYY') 	postingdate,
         apla.line_number 								invoicelinenumber,
         COALESCE (apa.description, apla.description) 	invoicedescription,
         poss.fob_lookup_code 							deliveryterm,
         DECODE (apa.payment_status_flag,
                 'P', 'Partial Paid',
                 'N', 'UnPaid',
                 'Y', 'Paid',
                 apa.payment_status_flag)				paymentstatus,
         (SELECT MAX(TO_CHAR (aipa.accounting_date, 'DD-MM-YYYY')) -- Added for REL-074 GEINC12919296  
            FROM AP_INVOICE_PAYMENTS_ALL aipa
           WHERE     aipa.invoice_id = apa.invoice_id
             AND NVL (aipa.reversal_flag, 'N') = 'N')	paymentdate,
         NULL 											discountpercent,
         NULL 											discountamount,
         NULL 											referencetootherdocuments,    
         apa.invoice_currency_code 						transactioncurrencycode,
         TO_CHAR (NVL (DECODE (zl.offset_flag, 'Y', 0, aida.amount), 0),
                  fnd_currency.get_format_mask (apa.invoice_currency_code, 40))transactioncurrencybaseamount,
         TO_CHAR (
            NVL (
               (SELECT SUM (amount)
                  FROM AP_INVOICE_DISTRIBUTIONS_ALL aida_tax
                 WHERE  line_type_lookup_code = 'REC_TAX'
				   AND aida_tax.invoice_line_number=aida.invoice_line_number
				   AND aida_tax.charge_applicable_to_dist_id =aida.invoice_distribution_id
                   AND aida_tax.invoice_id = aida.invoice_id
                   AND aida_tax.summary_tax_line_id =zl.summary_tax_line_id),0),
            fnd_currency.get_format_mask (apa.invoice_currency_code, 40))trancurrrectaxamount,
        TO_CHAR (
            NVL (
               (SELECT SUM (amount)
                  FROM AP_INVOICE_DISTRIBUTIONS_ALL aida_tax
                 WHERE  line_type_lookup_code = 'NONREC_TAX'
       			   AND aida_tax.invoice_line_number=aida.invoice_line_number
                   AND aida_tax.charge_applicable_to_dist_id =aida.invoice_distribution_id
                   AND aida_tax.invoice_id = aida.invoice_id
                   AND aida_tax.summary_tax_line_id =zl.summary_tax_line_id),0),
            fnd_currency.get_format_mask (apa.invoice_currency_code, 40))trancurrnonrectaxamount,
         TO_CHAR (
            NVL (
               (SELECT SUM (amount)
                  FROM AP_INVOICE_DISTRIBUTIONS_ALL aida_tax
                 WHERE     line_type_lookup_code LIKE '%TAX'
      		     AND aida_tax.invoice_line_number=aida.invoice_line_number
				 AND aida_tax.charge_applicable_to_dist_id =    aida.invoice_distribution_id
                       AND aida_tax.invoice_id = aida.invoice_id
                       AND aida_tax.summary_tax_line_id =zl.summary_tax_line_id),0),
            fnd_currency.get_format_mask (apa.invoice_currency_code, 40))trancurrrectotaltaxamount,
         TO_CHAR (
            NVL (
               (SELECT SUM (tax_amt)
                  FROM ZX_WITHHOLDING_LINES
                 WHERE     application_id = 200
                       AND trx_id = apla.invoice_id
                       AND trx_line_id = apla.line_number),
               0),
            fnd_currency.get_format_mask (apa.invoice_currency_code, 40))trancurrothertaxamount,
         TO_CHAR (
              NVL (
                 (SELECT SUM (amount)
                    FROM AP_INVOICE_DISTRIBUTIONS_ALL aida_tax
                   WHERE     line_type_lookup_code LIKE '%TAX'
				     AND aida_tax.invoice_line_number=aida.invoice_line_number
					 AND aida_tax.charge_applicable_to_dist_id = aida.invoice_distribution_id
                     AND aida_tax.invoice_id = aida.invoice_id
                     AND aida_tax.summary_tax_line_id = zl.summary_tax_line_id),0)
            + DECODE (zl.offset_flag, 'Y', 0, aida.amount),
            fnd_currency.get_format_mask (apa.invoice_currency_code, 40))transactioncurrencytotalamount,
         SUBSTR (gps.period_name, 1, 3) gldeclaredreturnmonth,
         gps.period_year gldeclaredreturnyear,
         glcc_dist.segment2 glaccountspayablenumber,
         ffvv_nom.description glaccountspayabledescription,
         gsob.currency_code reportingcurrencycode,
         (SELECT conversion_rate
            FROM GL_DAILY_RATES gdr
           WHERE     conversion_type = apa.exchange_rate_type
             AND gdr.conversion_date = apa.exchange_date
             AND gdr.from_currency = apa.invoice_currency_code
             AND gdr.to_currency = gsob.currency_code)exchange_rate,
         NULL basesumbaseamount,
         NULL basesumrectaxamount,
         NULL basesumnonrectaxamount,
         NULL basesumtotaltaxamount,
         NULL basesumothertaxamount,
         NULL basesumtotalamount,
         TO_CHAR (
              NVL (DECODE (zl.offset_flag, 'Y', 0, aida.amount), 0)
            * NVL (
                 (SELECT conversion_rate
                    FROM GL_DAILY_RATES gdr
                   WHERE     conversion_type = apa.exchange_rate_type
                         AND gdr.conversion_date = apa.exchange_date
                         AND gdr.from_currency = apa.invoice_currency_code
                         AND gdr.to_currency = gsob.currency_code),1),
            fnd_currency.get_format_mask (gsob.currency_code, 40))reportingcurrencybaseamount,
         TO_CHAR (
              NVL (
                 (SELECT SUM (amount)
                    FROM AP_INVOICE_DISTRIBUTIONS_ALL aida_tax
                   WHERE     line_type_lookup_code = 'REC_TAX'
				   		  AND aida_tax.invoice_line_number=aida.invoice_line_number
                          AND aida_tax.charge_applicable_to_dist_id =aida.invoice_distribution_id
                         AND aida_tax.invoice_id = aida.invoice_id
                         AND aida_tax.summary_tax_line_id =zl.summary_tax_line_id),0)
            * NVL (
                 (SELECT conversion_rate
                    FROM GL_DAILY_RATES gdr
                   WHERE     conversion_type = apa.exchange_rate_type
                         AND gdr.conversion_date = apa.exchange_date
                         AND gdr.from_currency = apa.invoice_currency_code
                         AND gdr.to_currency = gsob.currency_code),1),
            fnd_currency.get_format_mask (gsob.currency_code, 40))repcurrectaxamount,
         TO_CHAR (
              NVL (
                 (SELECT SUM (amount)
                    FROM AP_INVOICE_DISTRIBUTIONS_ALL aida_tax
                   WHERE     line_type_lookup_code = 'NONREC_TAX'
				   	 AND aida_tax.invoice_line_number=aida.invoice_line_number
                     AND aida_tax.charge_applicable_to_dist_id =aida.invoice_distribution_id
                     AND aida_tax.invoice_id = aida.invoice_id
                     AND aida_tax.summary_tax_line_id =zl.summary_tax_line_id),0)
            * NVL (
                 (SELECT conversion_rate
                    FROM GL_DAILY_RATES gdr
                   WHERE     conversion_type = apa.exchange_rate_type
                         AND gdr.conversion_date = apa.exchange_date
                         AND gdr.from_currency = apa.invoice_currency_code
                         AND gdr.to_currency = gsob.currency_code),1),
            fnd_currency.get_format_mask (gsob.currency_code, 40))repcurnonrectaxamount,
         TO_CHAR (
              NVL (
                 (SELECT SUM (amount)
                    FROM AP_INVOICE_DISTRIBUTIONS_ALL aida_tax
                   WHERE     line_type_lookup_code LIKE '%TAX'
		 				AND aida_tax.invoice_line_number=aida.invoice_line_number
                         AND aida_tax.charge_applicable_to_dist_id =aida.invoice_distribution_id
                         AND aida_tax.invoice_id = aida.invoice_id
                         AND aida_tax.summary_tax_line_id =zl.summary_tax_line_id),0)
            * NVL (
                 (SELECT conversion_rate
                    FROM GL_DAILY_RATES gdr
                   WHERE     conversion_type = apa.exchange_rate_type
                         AND gdr.conversion_date = apa.exchange_date
                         AND gdr.from_currency = apa.invoice_currency_code
                         AND gdr.to_currency = gsob.currency_code),1),
            fnd_currency.get_format_mask (gsob.currency_code, 40))repcurtotaltaxamount,
         TO_CHAR (
              NVL (
                 (SELECT SUM (tax_amt)
                    FROM ZX_WITHHOLDING_LINES
                   WHERE     application_id = 200
                         AND trx_id = apla.invoice_id
                         AND trx_line_id = apla.line_number),
                 0)
            * NVL (
                 (SELECT conversion_rate
                    FROM GL_DAILY_RATES gdr
                   WHERE     conversion_type = apa.exchange_rate_type
                         AND gdr.conversion_date = apa.exchange_date
                         AND gdr.from_currency = apa.invoice_currency_code
                         AND gdr.to_currency = gsob.currency_code),
                 1),
            fnd_currency.get_format_mask (gsob.currency_code, 40))repcurothertaxamount,
         TO_CHAR (
              NVL (
                 (SELECT SUM (amount)
                    FROM ap_invoice_distributions_all aida_tax
                   WHERE     line_type_lookup_code LIKE '%TAX'
				     AND aida_tax.invoice_line_number=aida.invoice_line_number
				     AND aida_tax.charge_applicable_to_dist_id = aida.invoice_distribution_id
                     AND aida_tax.invoice_id = aida.invoice_id
                     AND aida_tax.summary_tax_line_id = zl.summary_tax_line_id),0)
            +   DECODE (zl.offset_flag, 'Y', 0, aida.amount)
              * NVL (
                   (SELECT conversion_rate
                      FROM GL_DAILY_RATES gdr
                     WHERE     conversion_type = apa.exchange_rate_type
                           AND gdr.conversion_date = apa.exchange_date
                           AND gdr.from_currency = apa.invoice_currency_code
                           AND gdr.to_currency = gsob.currency_code),1),
            fnd_currency.get_format_mask (gsob.currency_code, 40))repcurtotalamount,
			NVL((SELECT DISTINCT category_code 
				   FROM EGP_CATEGORIES_B 
				  WHERE category_id = apla.Purchasing_category_id),
			NVL(apla.Product_category,apla.description)) hsn,
			(SELECT SUM(z.tax_amt) 
			   FROM ZX_LINES_V z 
			  WHERE z.tax_full_name LIKE 'IN%GST%'
                AND apa.invoice_id = z.trx_id
                AND apla.line_number = z.trx_line_id)total_gst_amount
    FROM AP_INVOICES_ALL 				apa,
         AP_INVOICE_LINES_ALL 			apla,
         ZX_LINES_V 					zl,
         AP_INVOICE_DISTRIBUTIONS_ALL 	aida,
         POZ_SUPPLIERS 					ps,
         POZ_SUPPLIER_SITES_ALL_M 		poss,
         HZ_PARTIES 					hp,
         GL_CODE_COMBINATIONS 			glcc_dist,
         GL_CODE_COMBINATIONS 			glcc_liab,
         XLE_ENTITY_PROFILES 			xep,
         GL_PERIOD_STATUSES 			gps,
         HZ_LOCATIONS 					hl,
         HR_LOCATIONS 					hl_ship_to,
         HZ_LOCATIONS 					hl_ship_from,
         AP_LOOKUP_codes 				alc,
         FND_VS_VALUE_SETS 				ffvs_nom,
         FND_VS_VALUES_VL 				ffvv_nom,
         GL_SETS_OF_BOOKS 				gsob,
         ZX_PARTY_TAX_PROFILE 			zptp,
         HR_ORGANIZATION_UNITS 			hou
   WHERE     apa.invoice_id 				= apla.invoice_id
         AND apa.cancelled_by 				IS NULL
         AND apa.org_id 					= hou.organization_id
         AND apla.line_number 				= aida.invoice_line_number
         AND NVL (apla.cancelled_flag, 'N') = 'N'
         AND aida.invoice_id 				= apa.invoice_id
         AND NVL (aida.reversal_flag, 'N') 	= 'N'
         AND apla.org_id 					= aida.org_id
         AND apa.org_id 					= apla.org_id
         AND apa.vendor_id 					= ps.vendor_id
         AND apa.vendor_site_id 			= poss.vendor_site_id
         AND ps.party_id 					= hp.party_id
         AND hp.party_id 					= zptp.party_id(+)
         AND zptp.party_type_code(+) 		= 'THIRD_PARTY'
         AND aida.dist_code_combination_id 	= glcc_dist.code_combination_id
         AND apa.legal_entity_id 			= xep.legal_entity_id
         AND gps.application_id 			= (SELECT application_id
												 FROM FND_APPLICATION
												WHERE application_short_name = 'AP')
         AND gps.set_of_books_id 			= aida.set_of_books_id
         AND gps.period_name 				= aida.period_name
         AND poss.location_id 				= hl.location_id
         AND alc.lookup_type 				= 'INVOICE TYPE'
         AND alc.lookup_code 				= apa.invoice_type_lookup_code
         AND apla.ship_from_location_id 	= hl_ship_from.location_id(+)
         AND apla.ship_to_location_id 		= hl_ship_to.location_id(+)
         AND apla.line_type_lookup_code IN ('ITEM', 'FREIGHT', 'MISCELLANEOUS')
         AND glcc_dist.segment2 			= ffvv_nom.VALUE
         AND glcc_dist.segment2 			= ffvv_nom.VALUE
         AND ffvs_nom.value_set_code 		= 'CCL_ACCOUNTS'
         AND ffvs_nom.value_set_id 			= ffvv_nom.value_set_id
         AND apa.set_of_books_id 			= gsob.set_of_books_id
         AND zl.application_id(+) 			= 200
         AND apla.invoice_id 				= zl.trx_id(+)
         AND apla.line_number 				= zl.trx_line_id(+)
         AND zl.cancel_flag(+) 				= 'N'
         AND glcc_liab.code_combination_id 	= apa.accts_pay_code_combination_id
         AND AP_INVOICES_UTILITY_PKG.get_approval_status (apa.invoice_id,
                                                          NULL,
                                                          NULL,
                                                          NULL) = 'APPROVED'
        AND TRUNC (apa.creation_date) BETWEEN NVL(:p_start_date,TRUNC(apa.creation_date))  AND NVL(:p_end_date,TRUNC(apa.creation_date))
		AND hou.name 						= NVL(:p_buname,hou.name)
        AND TRUNC(aida.accounting_date) BETWEEN NVL(:p_acc_start_date,TRUNC(aida.accounting_date)) AND NVL(:p_acc_end_date,TRUNC(aida.accounting_date))
ORDER BY businessunitcode,
	     cgsttaxcode,
		 sgsttaxcode,
		 igsttaxcode,
		 cesstaxcode,
         postingdate,
         suppliername,
         invoicenumber