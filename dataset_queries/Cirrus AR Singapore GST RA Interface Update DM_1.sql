/*
--#-----------------------------------------------------------------------------------------------------#
--# DESCRIPTION :Cirrus AR Singapore GST RA Interface Update Report 
--# CREATION DATE: 02-JUL-19
--# CREATED BY: siva kumar Dandu
--# REL-30 
--# MODIFICATION HISTORY:
--# CR#              Author               Date        Description
--#-----------------------------------------------------------------------------------------------------#
--#1			siva kumar Dandu		02-JUL-19		Developed code to update RA_INTERFACE_LINES_ALL Table based on some conditions.--#
--#REL-041       Sindhura Puppala		19-MAY-20       Updated Tax_Code in RA_INTERFACE_LINES_ALL Table based on some conditions.--#
--#-----------------------------------------------------------------------------------------------------#
*/
DECLARE
  l_return_status  VARCHAR2(30);
  l_msg_count      NUMBER;
  l_msg_data       VARCHAR2(2000);
  l_sg_tax         NUMBER;
  l_lines_tot      NUMBER;
  msg_rec          FND_MESSAGE.MSG_REC_TYPE;
  err_count        NUMBER := 0;
  index_count1     NUMBER := 1;
  index_count2     NUMBER := 1;
  msg              CLOB;

 intf_lines_tbl1 AR_AUTOINV_INTF_PKG.INTF_LINES_TBL_TYPE; 

  TYPE refcursor IS REF CURSOR;
  xdo_cursor refcursor;
  
  CURSOR intf_cursor1 IS
   (SELECT rila.*
     FROM HZ_PARTIES                hp
         ,HZ_PARTY_SITES            hps
         ,HZ_CUST_ACCOUNTS          hca
	     ,HZ_CUST_ACCT_SITES_ALL    hcasa
		 ,HZ_CUST_SITE_USES_ALL     hcsua
	     ,HZ_LOCATIONS              hl
		 ,ZX_PARTY_TAX_PROFILE      zptp
	     ,RA_INTERFACE_LINES_ALL    rila
		 ,VRM_OPERATING_UNITS_V     bu
    WHERE 1=1
      AND hp.party_id                 = hps.party_id
      AND hps.party_site_id           = hcasa.party_site_id
      AND hcasa.cust_account_id       = hca.cust_account_id
      AND hps.location_id             = hl.location_id
      AND hcasa.party_site_id         = rila.orig_sys_ship_party_site_id
	  AND hcasa.cust_acct_site_id     = hcsua.cust_acct_site_id
	  AND zptp.party_id               = hps.party_site_id
	  AND rila.org_id                 = bu.org_id
      AND zptp.party_type_code        = 'THIRD_PARTY_SITE'
	  --AND zptp.rep_registration_number is NOT NULL commented as per GERITM8515598
	  AND zptp.country_code           ='SG'
	  AND hcsua.SITE_USE_CODE         = 'SHIP_TO'
	  AND hl.country                  = 'SG'
	  AND EXISTS(SELECT 1 FROM RA_INTERFACE_LINES_ALL rila2
						 WHERE rila.sales_order                   =  rila2.sales_order
						   AND NVL(rila.trx_date, SYSDATE)         = NVL(rila2.trx_date, SYSDATE)
				           AND NVL(rila.gl_date, SYSDATE)          = NVL(rila2.gl_date, SYSDATE)
				           AND rila.org_id                         = rila2.org_id
				           AND rila.batch_source_name              = rila2.batch_source_name
				           AND NVL(rila.cust_trx_type_name,'X')    = NVL(rila2.cust_trx_type_name, 'X')
				           AND NVL(rila.orig_system_bill_customer_id,-1) = NVL(rila2.orig_system_bill_customer_id,-1)
				           AND NVL(rila.trx_number,-1)             = NVL(rila2.trx_number,-1)
				  GROUP BY rila2.trx_date,
				           rila2.gl_date,
						   rila2.org_id,
				           rila2.batch_source_name,
						   rila2.cust_trx_type_name,
						   rila2.orig_system_bill_customer_id,
				           rila2.sales_order,
						   rila2.trx_number
				HAVING SUM(CASE 
		                     WHEN rila2.currency_code<>'SGD'
                             THEN (ABS(rila2.amount)*(SELECT conversion_rate
                                                        FROM GL_DAILY_RATES
                                                       WHERE to_currency(+)  = 'SGD'
                                                         AND conversion_type = '300000002138002'
                                                         AND from_currency   = rila2.currency_code
							                             AND TRUNC(conversion_date) = TRUNC(NVL(rila2.ship_date_actual,SYSDATE))))
  -- Added the below code for REL-41 for updating Tax Classification Code by Sindhura Puppala	
							ELSE 
							 rila2.amount
  -- Added the above code for REL-41 for updating Tax Classification Code by Sindhura Puppala
			                     


						 END
						  )>10000
				)
				  
	  AND EXISTS (SELECT 1 
	               FROM EGP_CATEGORIES_TL         ect
                       ,EGP_ITEM_CAT_ASSIGNMENTS  eica
                       ,EGP_SYSTEM_ITEMS_B        esib
					   ,RA_INTERFACE_LINES_ALL    rila1
			      WHERE  1=1
				    AND ect.category_id                = eica.category_id
                    AND eica.inventory_item_id         = esib.inventory_item_id
	                AND esib.inventory_item_id         = rila1.inventory_item_id
					AND ect.category_name              ='SG_ZERO_TAX_ITEM'
					AND rila1.sales_order              = rila.sales_order
					AND NVL(rila.trx_date, SYSDATE)    = NVL(rila1.trx_date, SYSDATE)
				    AND NVL(rila.gl_date, SYSDATE)     = NVL(rila1.gl_date, SYSDATE)
				    AND rila.org_id                    = rila1.org_id
				    AND rila.batch_source_name         = rila1.batch_source_name
				    AND NVL(rila.cust_trx_type_name,'X')    = NVL(rila1.cust_trx_type_name, 'X')
				    AND NVL(rila.orig_system_bill_customer_id,-1) = NVL(rila1.orig_system_bill_customer_id,-1)
				    AND NVL(rila.trx_number,-1)        = NVL(rila1.trx_number,-1)
				   )
      AND bu.organization_name                = NVL(:Business_Unit,bu.organization_name)
	  AND rila.batch_source_name              = NVL(:Transaction_Source,rila.batch_source_name)
	  AND rila.sales_order                    = NVL(:Sales_Order,rila.sales_order)
	  AND rila.orig_system_bill_customer_id   = NVL(:Customer_Number,rila.orig_system_bill_customer_id)
	  );
			   
	intf_lines_rec1 ra_interface_lines_all%ROWTYPE;
	 
  BEGIN 
        intf_lines_tbl1 := AR_AUTOINV_INTF_PKG.INTF_LINES_TBL_TYPE();
   
  OPEN intf_cursor1;
  LOOP
     FETCH intf_cursor1
      INTO intf_lines_rec1;
    EXIT WHEN intf_cursor1%notfound;
	
	  	BEGIN
	       SELECT meaning 
	         INTO l_sg_tax  
	         FROM FND_LOOKUP_VALUES
	        WHERE lookup_type  ='CIRRUSAR_SG_CUST_ACCOUNTING'
	          AND enabled_flag ='Y'
              AND lookup_code  like 'SG_TAX_RATE%'
		      AND language     ='US';
	    EXCEPTION 
		    WHEN OTHERS THEN
			  l_sg_tax :=0;
	    END;

	       intf_lines_rec1.attribute_category       := 'CCLAR';
	       intf_lines_rec1.attribute10              := ROUND(TO_CHAR(intf_lines_rec1.amount*l_sg_tax),2);
	
	--Commented the below code for REL-41 for updating Tax Classification Code by Sindhura Puppala
    --  intf_lines_rec1.document_sub_type        := 'SG_ZERO_TAX';
	--Commented the above code for REL-41 for updating Tax Classification Code by Sindhura Puppala

    -- Added the below code for REL-41 for updating Tax Classification Code by Sindhura Puppala
		   intf_lines_rec1.tax_code			        := 'SG_GST_EXEMPT';  
	-- Added the above code for REL-41 for updating Tax Classification Code by Sindhura Puppala

           intf_lines_tbl1.extend;
           intf_lines_tbl1(index_count1)            := intf_lines_rec1;
           index_count1                             := index_count1 + 1;
  END LOOP;
  CLOSE intf_cursor1;
  
  AR_AUTOINV_INTF_PKG.UPDATE_INTERFACE_LINES(intf_lines_tbl1,
                                             l_msg_count,
                                             l_msg_data,
                                             l_return_status);

		COMMIT;									 
																		 
	 IF l_return_status = FND_API.g_ret_sts_error OR
        l_return_status = FND_API.g_ret_sts_unexp_error
	 THEN
  
        FOR i in 1 .. l_msg_count
	    LOOP
            FND_MSG_PUB.GET(FND_MSG_PUB.g_first,
                                FND_API.g_true,
                                    l_msg_data,
                                   l_msg_count
					        );
    
            FND_MESSAGE.SET_ENCODED(l_msg_data);
            msg_rec := FND_MESSAGE.GET_MESSAGE_RECORD;
            msg := msg || msg_rec.user_message || '.   ';
            FND_MSG_PUB.DELETE_MSG(1);
        END LOOP;
          FND_MSG_PUB.DELETE_MSG;
     END IF;											 
  OPEN :xdo_cursor FOR
    SELECT msg FROM DUAL;
  COMMIT;
END;