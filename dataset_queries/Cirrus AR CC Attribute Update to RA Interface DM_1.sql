--# MODIFICATION HISTORY:
--# CR#                       Author             				Date                Description
--#---------------------------------------------------------------------------------------------------------------------------#
--# REL-037 EMG            Sindhura Puppala(503062518)          28-JAN-2020         Initial Version Created.				  -#
--# REL-039 EMG            Sindhura Puppala(503062518)          10-APR-2020         Added condition for checking the contracts-#
--# BP           																	with '-MS-EXT' for Qatar				  -#
--# REL-058                Vignesh Kumar(503228790)				08-NOV-2021			Update Warehouse code for ORA_Subscriptions 
--#																					Source -#      
--# REL-073                Ramakrishna T(503275407)             18-NOV-2022         Added new logic to update Header_attribute3-#
--#                                                                                                                            -#
--# REL-078				   Damoder Chitti (503356836)			11-Jul-2023			Tier Price and Block Price for Subscription Management --#
--# REL-079				   Damoder Chitti (503356836)			10-Aug-2023			Header_attribute3 update and tier based scenario update --#
--#REL-106 LBR               Keerthana C                        09-Oct-2024         Updated HEADER_ATTRIBUTE5
--#REL-106 (EMG)             Keerthana C                        11-Nov-2024         Updated HEADER_ATTRIBUTE15 and commented code for HEADER_ATTRIBUTE5
--#--------------------------------------------------------------------------------------------------------------------------  -#
DECLARE
  l_return_status         VARCHAR2(30);
  l_msg_count             NUMBER;
  l_msg_data              VARCHAR2(2000);
  msg_rec                 FND_MESSAGE.MSG_REC_TYPE;
  err_count               NUMBER := 0;
  index_count1            NUMBER := 1;
  index_count2           NUMBER := 1;
  msg                     CLOB;
  product_family          VARCHAR2(300);
  product_family_contract VARCHAR2(300);
  -- REL-039 EMG added below code
 owner					  VARCHAR2(300);
  -- REL-039 EMG added above code

  product_family_nurego   VARCHAR2(300);
 
  --REL-058 Added below code
  index_count12     NUMBER := 1;
  --REL-058 Added above code


  intf_lines_rec1 RA_INTERFACE_LINES_ALL%ROWTYPE;
  intf_lines_tbl1 AR_AUTOINV_INTF_PKG.INTF_LINES_TBL_TYPE;
  
  --REL-058 Added below code
  
  intf_lines_rec12 RA_INTERFACE_LINES_ALL%ROWTYPE;
  intf_lines_tbl12 AR_AUTOINV_INTF_PKG.INTF_LINES_TBL_TYPE;
  
  --REL-058 Added above code
  
  --REL-078  Added below code

index_count1a NUMBER := 1;
invoice_description_calu Number :=0;
invoice_description_calu1 number:=0;
invoice_description VARCHAR2(2000) := NULL;

--REL-078  Added above code
  
 -- Added REL-073 below code
  intf_lines_rec4 RA_INTERFACE_LINES_ALL%ROWTYPE;   
  intf_lines_tbl4 AR_AUTOINV_INTF_PKG.INTF_LINES_TBL_TYPE;
  p_cost_center varchar2(300);
  -- Added REL-073 above code 
    product_family2         VARCHAR2(300); -- Added for REL 106 LBR
    intf_lines_rec5 RA_INTERFACE_LINES_ALL%ROWTYPE;  -- Added for REL 106 LBR
--    intf_lines_tb15 AR_AUTOINV_INTF_PKG.INTF_LINES_TBL_TYPE;  -- Added for REL 106 LBR -- commented for REL-106 (EMG)
	intf_lines_tbl5 AR_AUTOINV_INTF_PKG.INTF_LINES_TBL_TYPE; -- Added for REL 106 (EMG)
    index_count5            NUMBER := 1;  -- Added for REL 106 LBR
 
  CURSOR intf_cursor1 IS    
  --deleted distinct since we have only one BU_id for single Bu in VRM_OPERATING_UNITS_V table
    SELECT rila.*  
      FROM RA_INTERFACE_LINES_ALL rila, VRM_OPERATING_UNITS_V bu
     WHERE 1 = 1
       AND bu.org_id = rila.org_id
       AND bu.organization_name = NVL(:org_name, bu.organization_name)
       AND rila.batch_source_name =
           NVL(:transaction_source, rila.batch_source_name)
      AND rila.interface_line_attribute3 IN NVL(:sales_order_num,rila.interface_line_attribute3)
	  AND rila.interface_line_attribute1 IN NVL(:contract,rila.interface_line_attribute1) 
      AND bu.organization_name IN
           (SELECT lookup_code
              FROM FND_LOOKUP_VALUES
             WHERE lookup_type = 'CIRRUS_AUTO_INV_BU_NAMES'
               AND language = 'US'
               AND enabled_flag = 'Y'
			   AND tag IS NULL)
			    AND rila.creation_date BETWEEN NVL(:from_year,rila.creation_date) AND NVL(:to_year,rila.creation_date)
       AND attribute11 IS NULL
     --AND attribute_category IS NULL  Commented due to Brazil context defaulted while importing the invoice
 ;
	 
	 CURSOR intf_cursor2(p_org_id NUMBER,p_order_num VARCHAR2,p_fulfill_line_id NUMBER,p_inventory_item_id NUMBER) IS	 
  SELECT ecb.attribute2||'-'|| hdreff.attribute_char17 p_product_family
    FROM
EGP_CATEGORIES_B ecb,
INV_ORG_PARAMETERS iop,
EGP_CATEGORY_SETS_VL ecst,
EGP_ITEM_CATEGORIES eic,
EGP_SYSTEM_ITEMS_B esib,
DOO_HEADERS_ALL hdr,
DOO_HEADERS_EFF_B hdreff,
DOO_FULFILL_LINES_ALL fla
WHERE 1=1
AND ecb.category_id                  = eic.category_id
AND esib.organization_id             = iop.organization_id
AND iop.organization_code            = 'GED_IMO'
AND ecst.category_set_name           = 'Global_Inv_Default_Catalog'
AND eic.category_set_id              = ecst.category_set_id
AND esib.inventory_item_id           = eic.inventory_item_id
AND esib.organization_id             = eic.organization_id 
AND esib.inventory_item_id           = p_inventory_item_id
AND hdr.header_id = hdreff.header_id
AND UPPER(hdreff.context_code) = 'GED HEADER EFF CONTEXT'
AND fla.inventory_item_id         = esib.inventory_item_id
AND hdr.order_number = p_order_num 
AND fla.fulfill_line_id= p_fulfill_line_id
AND hdr.header_id = fla.header_id
AND hdr.org_id = p_org_id;

--REL-058 Added below code
	 
	CURSOR intf_cursor12 IS
	SELECT rila.* 
	FROM RA_INTERFACE_LINES_ALL rila,fnd_lookup_values flv, hr_operating_units hou,GL_LEDGERS gl
	WHERE 1=1 
	AND flv.lookup_type='CIRRUS_DIGAVN_WAREHOUSE_LKP'
	AND flv.language='US' 
	AND flv.enabled_flag='Y'
	AND rila.batch_source_name='ORA_Subscriptions' 
	AND rila.org_id = flv.meaning
	AND rila.org_id = hou.organization_id
	and gl.ledger_id = hou.set_of_books_id
	AND gl.ledger_id=NVL(rila.set_of_books_id,gl.ledger_id)
	AND gl.name=NVL(:LEDGER_NAME,gl.name)
	AND hou.name=NVL(:ORG_NAME,hou.name)
	AND rila.batch_source_name=NVL(:TRANSACTION_SOURCE,rila.batch_source_name)
	AND rila.interface_line_attribute1=NVL(:SALES_ORDER_NUM,rila.interface_line_attribute1);

--REL-058 Added above code
-- Added REL-073 below code
cursor intf_cursor3 IS
   SELECT count(DESCRIPTION)count_attribute11,interface_line_attribute3,interface_line_attribute1,RECURRING_BILL_FLAG
   from 
   (select  
   --distinct commented for REL-079
   (flv.DESCRIPTION),rila.interface_line_attribute3,rila.interface_line_attribute1,rila.RECURRING_BILL_FLAG
      FROM RA_INTERFACE_LINES_ALL rila, VRM_OPERATING_UNITS_V bu, fnd_lookup_values flv
     WHERE 1 = 1
	 AND rila.attribute11 IS  NOT null	
	 and rila.header_attribute3 is null	
     AND bu.org_id = rila.org_id  	
	 AND bu.organization_name = NVL(:org_name, bu.organization_name)
     AND rila.batch_source_name = NVL(:transaction_source, rila.batch_source_name)
      AND rila.interface_line_attribute3 IN NVL(:sales_order_num,rila.interface_line_attribute3)
	  AND rila.interface_line_attribute1 IN NVL(:contract,rila.interface_line_attribute1) 
     AND bu.organization_name IN
           (SELECT lookup_code
            FROM FND_LOOKUP_VALUES
            WHERE lookup_type = 'CIRRUS_AUTO_INV_BU_NAMES'
            AND language = 'US'
            AND enabled_flag = 'Y'
			AND tag IS NULL
			)		
	--and REGEXP_SUBSTR(rila.attribute11,'[^-]+')= flv.LOOKUP_CODE -- commented for REL-079
	and rila.attribute11 like flv.LOOKUP_CODE||'%'   --Added for REL-079
	and flv.lookup_type= 'CIRRUSAR_COSTCENTER_REC'
    and flv.language='US'	
	and flv.ENABLED_FLAG='Y'  
	--and to_char(rila.creation_date, 'YYYY-MM-DD')>= to_char(to_date('2022-11-14','YYYY-MM-DD'),'YYYY-MM-DD')  -- commented for REL-079
	AND rila.creation_date BETWEEN NVL(:from_year,to_date(trunc(sysdate,'mm'),'yyyy-mm-dd')) AND NVL(:to_year,to_date(last_day(sysdate),'yyyy-mm-dd'))      --Added for REL-079
	group by flv.DESCRIPTION,rila.interface_line_attribute3,rila.interface_line_attribute1,rila.RECURRING_BILL_FLAG
	)
	group by interface_line_attribute3,interface_line_attribute1,RECURRING_BILL_FLAG;

CURSOR intf_cursor4(p_so_num varchar2,p_contract_num varchar2) IS   
    SELECT  rila.* 
      FROM RA_INTERFACE_LINES_ALL rila
     WHERE 1 = 1     
      AND rila.interface_line_attribute3=p_so_num 
	  AND rila.interface_line_attribute1=p_contract_num
	  AND rila.creation_date BETWEEN NVL(:from_year,to_date(trunc(sysdate,'mm'),'yyyy-mm-dd')) AND NVL(:to_year,to_date(last_day(sysdate),'yyyy-mm-dd'))  ;  	 ---Added for REL-079

-- Added REL-073 above code	 

--REL-078 Added below code 
CURSOR intf_cursor1a(p_bill_line_id NUMBER) IS
SELECT 
Distinct   --Added for REL-079
upper(substr(oc.charge_definition, 1, 5)) usage_flag
    ,item.graduated_code
	,item.application_method_code
	,item.PARTIAL_BLOCK_ACTION_CODE   
	,op.inventory_item_id
	,ob.bill_line_id
	,NVL(ob.priced_quantity, 1) priced_quantity
	,op.pricing_term_pricing_method
	,ob.sequence_number
	,op.generate_full_period_yn
	,op.enable_pricing_term_yn
	,op.pricing_term_adjustment_pct
	,to_char(ob.date_billed_from, 'MM/DD/YYYY')
	,to_char(ob.date_billed_to, 'MM/DD/YYYY')
	,ob.amount
	,op.price_as_of
	,(
		SELECT description
		FROM inv_units_of_measure
		WHERE uom_code = op.billing_freq
		) billing_freq
	,op.pricing_term_duration
	,(
		SELECT description
		FROM inv_units_of_measure
		WHERE uom_code = op.pricing_term_period
		) pricing_term_period
	,decode(op.pricing_term_start_date, NULL, NULL, ' From ' || to_char(op.pricing_term_start_date, 'MM/DD/YY')) pricing_term_start_date
	,floor(months_between(ob.date_billed_from, nvl(op.pricing_term_start_date, op.price_as_of)) / (
			CASE 
				WHEN op.pricing_term_period = 'zza'
					THEN 12
				WHEN op.pricing_term_period = 'zzm'
					THEN 1
				WHEN op.pricing_term_period = 'zzX'
					THEN 4
				ELSE NULL
				END
			) + 1) duration_between
	   ,(case when sign (months_between(ob.date_billed_from, nvl(op.pricing_term_start_date, op.price_as_of)))=-1 then
	        trunc(floor(months_between(add_months(nvl(op.pricing_term_start_date, op.price_as_of),CASE 
					WHEN op.pricing_term_period = 'zza'
						THEN 12
					WHEN op.pricing_term_period = 'zzm'
						THEN 1
					WHEN op.pricing_term_period = 'zzX'
						THEN 4
					ELSE 0
					END)
			         , nvl(op.pricing_term_start_date, op.price_as_of)) / (
				CASE 
					WHEN op.pricing_term_period = 'zza'
						THEN 12
					WHEN op.pricing_term_period = 'zzm'
						THEN 1
					WHEN op.pricing_term_period = 'zzX'
						THEN 4
					ELSE NULL
					END
				) + 1) / op.pricing_term_duration)
	--when sign (months_between(ob.date_billed_from, nvl(op.pricing_term_start_date, op.price_as_of))) = 1 then -- commented for REL-079
	when sign (months_between(ob.date_billed_from, nvl(op.pricing_term_start_date, op.price_as_of)))in (0,1) then  --Added for REL-079
    	trunc(floor(months_between(add_months(nvl(op.pricing_term_start_date, op.price_as_of),
		              months_between(ob.date_billed_from, nvl(op.pricing_term_start_date, op.price_as_of)))
			         , nvl(op.pricing_term_start_date, op.price_as_of)) / (
				CASE 
					WHEN op.pricing_term_period = 'zza'
						THEN 12
					WHEN op.pricing_term_period = 'zzm'
						THEN 1
					WHEN op.pricing_term_period = 'zzX'
						THEN 4
					ELSE NULL
					END
				) + 1) / op.pricing_term_duration)
				END) formulae_val
				,0 formulae_val_1
	,decode(OCA.ADJUSTMENT_TYPE, 'ORA_MARKUP_PERCENT', '+MARKUP  ', 'ORA_DISCOUNT_PERCENT', '-MARKDOWN  ', NULL) MARKUP_METHOD 
FROM oss_charges oc
	,oss_subscriptions os
	,oss_products op
	,oss_bill_lines ob
	,oss_charge_adjustments oca
	,(SELECT qth.graduated_code,
        qtl.application_method_code,
		qth.PARTIAL_BLOCK_ACTION_CODE,
		qth.item_id	
	    ,qpli.price_list_id   ---Added for REL-079
		from qp_price_list_items qpli    ---Added for REL-079
     ,qp_tier_headers qth
     ,qp_price_list_charges qplc   ---Added for REL-079
	 ,qp_tier_lines qtl
      where  
	  qth.tiered_pricing_header_id = qtl.tiered_pricing_header_id
	  --Added below for REL-079
      AND qpli.item_level_code = 'ITEM'
      AND qpli.price_list_item_id = qplc.parent_entity_id
      AND  qth.tiered_pricing_header_id = qplc.tiered_pricing_header_id	
      --Added above for REL-079
      --commented below for REL-079	  
      /* group by qth.graduated_code,
        qtl.application_method_code,
		qth.PARTIAL_BLOCK_ACTION_CODE
		,qth.item_id*/
		--commented above for REL-079
		) item     
WHERE 1 = 1
	AND ob.bill_line_id = p_bill_line_id --MAIN
	AND oc.subscription_product_id = op.subscription_product_id
	AND oc.subscription_id = op.subscription_id
	AND op.subscription_id = os.subscription_id
	AND ob.subscription_product_id = op.subscription_product_id
	AND ob.subscription_id = op.subscription_id
	AND oc.charge_id = oca.charge_id(+)
	AND item.item_id(+) = op.inventory_item_id
	AND op.price_list_id=item.price_list_id(+)   --Added for REL-079
	;

CURSOR intf_cursor1b(p_inv_item_id NUMBER) IS
SELECT qtl.tier_line_number tl_tier_line_number
	,qtl.minimum_value tl_minimum_value
	,qtl.maximum_value tl_maximum_value
	,qtl.adjustment_amount tl_adjustment_amount
	,qtl.increment_value
FROM egp_system_items esi
	,inv_org_parameters iop
	,qp_price_list_items qpli
	,qp_price_lists_tl qplt
	,qp_price_list_charges qplc
	,qp_charge_definitions_tl qcdl
	,qp_tier_lines qtl
	,qp_price_lists_all_b qpla    --Added for REL-079
WHERE esi.organization_id = iop.organization_id
	AND iop.organization_code = 'GED_IMO'
	AND qpli.item_id = esi.inventory_item_id
	AND qpli.price_list_item_id = qplc.parent_entity_id
	AND qpli.item_level_code = 'ITEM'
	AND qplt.LANGUAGE = 'US'
	AND qplt.price_list_id = qplc.price_list_id
	AND qplc.charge_definition_id = qcdl.charge_definition_id
	AND qcdl.LANGUAGE = 'US'
	AND qplc.parent_entity_type_code(+) = 'PRICE_LIST_ITEM'
	AND qplt.name LIKE 'DIGAVN-%'
	AND qplc.tiered_pricing_header_id = qtl.tiered_pricing_header_id(+)
	AND qpla.price_list_id = qplc.price_list_id    --Added for REL-079
	and qpla.calculation_method_code is not null    --Added for REL-079
	AND esi.inventory_item_id = p_inv_item_id 
	--Added below for REL-079
	group by     
     qtl.tier_line_number,	
	 qtl.minimum_value 
	,qtl.maximum_value 
	,qtl.adjustment_amount 
	,qtl.increment_value 
	--Added above for REL-079
	ORDER BY qtl.tier_line_number;



--REL-078 Added above code
-- commented below code REL-106 (EMG)
/* --Added below code for ReL 106 LBR

CURSOR intf_cursor5 IS    

    SELECT rila.*  
      FROM RA_INTERFACE_LINES_ALL rila, VRM_OPERATING_UNITS_V bu
     WHERE 1 = 1
       AND bu.org_id = rila.org_id
       AND bu.organization_name = NVL(:org_name, bu.organization_name)
       AND rila.batch_source_name =
           NVL(:transaction_source, rila.batch_source_name)
      AND rila.interface_line_attribute3 IN NVL(:sales_order_num,rila.interface_line_attribute3)
	  AND rila.interface_line_attribute1 IN NVL(:contract,rila.interface_line_attribute1) 
      AND bu.organization_name IN
           (SELECT lookup_code
              FROM FND_LOOKUP_VALUES
             WHERE lookup_type = 'CIRRUS_AUTO_INV_BU_NAMES'
               AND language = 'US'
               AND enabled_flag = 'Y'
			   AND tag IS NULL)
			  
			    AND rila.creation_date BETWEEN NVL(:from_year,to_date(trunc(sysdate,'mm'),'yyyy-mm-dd')) AND NVL(:to_year,to_date(last_day(sysdate),'yyyy-mm-dd'))  
       AND attribute11 IS NOT NULL
    
 ;	
 --Added above code for Rel 106 LBR
 --Added below code for Rel 106 LBR

CURSOR intf_cursor6(contract_num varchar2) IS   
      SELECT attribute11_value
FROM (
  SELECT 
  case  
  WHEN INSTR(rila.ATTRIBUTE11, '-') > 0  
  Then SUBSTR(rila.ATTRIBUTE11, 1, INSTR(rila.ATTRIBUTE11 , '-') - 1)
   ELSE rila.ATTRIBUTE11
    END AS attribute11_value
  FROM RA_INTERFACE_LINES_ALL rila
  WHERE rila.interface_line_attribute1 = contract_num
  AND rila.attribute11 is not null
  ORDER BY rila.interface_line_id asc
)
WHERE ROWNUM = 1;

--Added above code for Rel 106 LBR */
 -- commented above code for REL-106 (EMG)
 -- Added code for REL-106 (EMG)
 CURSOR intf_cursor5 IS    
    SELECT rila.*  
      FROM RA_INTERFACE_LINES_ALL rila, VRM_OPERATING_UNITS_V bu
     WHERE 1 = 1
       AND bu.org_id = rila.org_id
       AND bu.organization_name = NVL(:org_name, bu.organization_name)
      AND rila.interface_line_attribute3 IN NVL(:sales_order_num,rila.interface_line_attribute3)
	  AND rila.interface_line_attribute1 IN NVL(:contract,rila.interface_line_attribute1) 
      AND bu.organization_name IN
           (SELECT lookup_code
              FROM FND_LOOKUP_VALUES
             WHERE lookup_type = 'CIRRUS_AUTO_INV_BU_NAMES'
               AND language = 'US'
               AND enabled_flag = 'Y'
			   AND tag IS NULL)
			    AND rila.creation_date BETWEEN NVL(:from_year,rila.creation_date) AND NVL(:to_year,rila.creation_date)
       AND header_attribute15 IS NULL
	   order by rila.interface_line_attribute1,interface_line_id;
	   -- Added above code for REL-106 (EMG)   
BEGIN

  intf_lines_tbl1 := AR_AUTOINV_INTF_PKG.INTF_LINES_TBL_TYPE();

  OPEN intf_cursor1;
  LOOP
    FETCH intf_cursor1
      INTO intf_lines_rec1;
    EXIT WHEN intf_cursor1%NOTFOUND;
  
    IF intf_lines_rec1.interface_line_context = 'DOO' THEN
	BEGIN
	 
     OPEN intf_cursor2(intf_lines_rec1.org_id,intf_lines_rec1.interface_line_attribute3,intf_lines_rec1.interface_line_attribute6,
					  intf_lines_rec1.inventory_item_id);	 
	 FETCH intf_cursor2 INTO product_family;
    CLOSE intf_cursor2;
		
		EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
      intf_lines_rec1.attribute11        :=  product_family ;   -- 'NULL'; --product_family;
      intf_lines_rec1.attribute_category := 'CCLAR';
	  
    END IF;
      
    IF intf_lines_rec1.interface_line_context IN
       ('CONTRACT INVOICES', 'CONTRACT INTERNAL INVOICES') THEN
     BEGIN
      
-- REL-039 EMG Commented below code

	/*   SELECT (SELECT ecb.attribute2
    FROM
EGP_CATEGORIES_B ecb,
INV_ORG_PARAMETERS iop,
EGP_CATEGORY_SETS_VL ecst,
EGP_ITEM_CATEGORIES eic,
EGP_SYSTEM_ITEMS_B esib
WHERE 1=1
AND ecb.category_id                  = eic.category_id
AND esib.organization_id             = iop.organization_id
AND iop.organization_code            = 'GED_IMO'
AND ecst.category_set_name           = 'Global_Inv_Default_Catalog'
AND eic.category_set_id              = ecst.category_set_id
AND esib.inventory_item_id           = eic.inventory_item_id
AND esib.organization_id             = eic.organization_id 
AND esib.inventory_item_id           = intf_lines_rec1.inventory_item_id) || '-' || hdreff.attribute_char17
        INTO product_family_contract
        FROM DOO_HEADERS_ALL hdr, DOO_HEADERS_EFF_B hdreff
       WHERE 1 = 1
         AND hdr.header_id = hdreff.header_id
         AND UPPER(hdreff.context_code) = 'GED HEADER EFF CONTEXT'
		 AND hdr.order_number || '-EXT'  = intf_lines_rec1.interface_line_attribute3 
	     AND hdr.org_id = intf_lines_rec1.org_id
		 AND hdr.object_version_number   = (SELECT  MAX(oheader1.object_version_number)
                                                              FROM DOO_HEADERS_ALL oheader1
                                                             WHERE hdr.order_number = oheader1.order_number
															 AND oheader1.status_code NOT LIKE '%DOO%') ;	 
 */
	  -- REL-039 EMG Commented above code   
	  
	  -- REL-039 EMG added below code
	  
 SELECT ecb.attribute2 INTO product_family_contract
    FROM
EGP_CATEGORIES_B ecb,
INV_ORG_PARAMETERS iop,
EGP_CATEGORY_SETS_VL ecst,
EGP_ITEM_CATEGORIES eic,
EGP_SYSTEM_ITEMS_B esib
WHERE 1=1
AND ecb.category_id                  = eic.category_id
AND esib.organization_id             = iop.organization_id
AND iop.organization_code            = 'GED_IMO'
AND ecst.category_set_name           = 'Global_Inv_Default_Catalog'
AND eic.category_set_id              = ecst.category_set_id
AND esib.inventory_item_id           = eic.inventory_item_id
AND esib.organization_id             = eic.organization_id 
AND esib.inventory_item_id           = intf_lines_rec1.inventory_item_id ;
      
	  SELECT  hdreff.attribute_char17 INTO owner
        FROM DOO_HEADERS_ALL hdr, DOO_HEADERS_EFF_B hdreff
       WHERE 1 = 1
         AND hdr.header_id = hdreff.header_id
         AND UPPER(hdreff.context_code) = 'GED HEADER EFF CONTEXT'
		 AND to_char(hdr.order_number) = substr(intf_lines_rec1.interface_line_attribute1,1,(instr(intf_lines_rec1.interface_line_attribute1,'-',1)-1)) 
         AND hdr.org_id = intf_lines_rec1.org_id
		 AND hdr.object_version_number   = (SELECT  MAX(oheader1.object_version_number)
                                                              FROM DOO_HEADERS_ALL oheader1
                                                             WHERE hdr.order_number = oheader1.order_number
															 AND oheader1.status_code NOT LIKE '%DOO%') ;
    -- REL-039 EMG added above code   
		   
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
          
     -- REL-039 EMG Commented below code   
     --intf_lines_rec1.attribute11        := product_family_contract;
      -- REL-039 EMG Commented above code   
    
	-- REL-039 EMG added below code   

      intf_lines_rec1.attribute11        := product_family_contract||'-'||owner;
     -- REL-039 EMG added above code   

	  intf_lines_rec1.attribute_category :='CCLAR' ;
    END IF;
  
    IF intf_lines_rec1.interface_line_context NOT IN
       ('DOO', 'CONTRACT INVOICES', 'CONTRACT INTERNAL INVOICES') THEN
    BEGIN
	     -- REL-039 EMG Commented below code   

	/* SELECT (SELECT ecb.attribute2
    FROM
EGP_CATEGORIES_B ecb,
INV_ORG_PARAMETERS iop,
EGP_CATEGORY_SETS_VL ecst,
EGP_ITEM_CATEGORIES eic,
EGP_SYSTEM_ITEMS_B esib
WHERE 1=1
AND ecb.category_id                  = eic.category_id
AND esib.organization_id             = iop.organization_id
AND iop.organization_code            = 'GED_IMO'
AND ecst.category_set_name           = 'Global_Inv_Default_Catalog'
AND eic.category_set_id              = ecst.category_set_id
AND esib.inventory_item_id           = eic.inventory_item_id
AND esib.organization_id             = eic.organization_id 
AND esib.inventory_item_id           = intf_lines_rec1.inventory_item_id) || '-'
 INTO product_family_nurego
        FROM dual;*/
-- REL-039 EMG Commented above code   

	
-- REL-039 EMG added below code   

SELECT ecb.attribute2  INTO product_family_nurego
    FROM
EGP_CATEGORIES_B ecb,
INV_ORG_PARAMETERS iop,
EGP_CATEGORY_SETS_VL ecst,
EGP_ITEM_CATEGORIES eic,
EGP_SYSTEM_ITEMS_B esib
WHERE 1=1
AND ecb.category_id                  = eic.category_id
AND esib.organization_id             = iop.organization_id
AND iop.organization_code            = 'GED_IMO'
AND ecst.category_set_name           = 'Global_Inv_Default_Catalog'
AND eic.category_set_id              = ecst.category_set_id
AND esib.inventory_item_id           = eic.inventory_item_id
AND esib.organization_id             = eic.organization_id 
AND esib.inventory_item_id           = intf_lines_rec1.inventory_item_id;
-- REL-039 EMG added above code   

     EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
     -- REL-039 EMG Commented below code   
     -- intf_lines_rec1.attribute11        := product_family_nurego;

	 -- REL-039 EMG Commented above code   
	 -- REL-039 EMG added below code  
      intf_lines_rec1.attribute11        := product_family_nurego||'-' ;
	 -- REL-039 EMG added above code   

      intf_lines_rec1.attribute_category := 'CCLAR';
    
    END IF;
	
  
    intf_lines_tbl1.extend;
    intf_lines_tbl1(index_count1) := intf_lines_rec1;
    index_count1 := index_count1 + 1;
  
  END LOOP;
  CLOSE intf_cursor1;

  AR_AUTOINV_INTF_PKG.UPDATE_INTERFACE_LINES(intf_lines_tbl1,
                                             l_msg_count,
                                             l_msg_data,
                                             l_return_status);

  COMMIT; 
 --REL-073 commented below code  
/*  IF l_return_status = FND_API.g_ret_sts_error OR
     l_return_status = FND_API.g_ret_sts_unexp_error THEN
  
    FOR i in 1 .. l_msg_count LOOP
    
      FND_MSG_PUB.GET(FND_MSG_PUB.g_first,
                      FND_API.g_true,
                      l_msg_data,
                      l_msg_count);
    
      FND_MESSAGE.SET_ENCODED(l_msg_data);
      msg_rec := FND_MESSAGE.GET_MESSAGE_RECORD;
    
      msg := msg || msg_rec.user_message || '.   ';
    
      FND_MSG_PUB.DELETE_MSG(1);
    END LOOP;
  
    FND_MSG_PUB.DELETE_MSG;
  
  END IF;

  IF l_return_status = FND_API.g_ret_sts_error OR
     l_return_status = FND_API.g_ret_sts_unexp_error THEN
  
    FOR i in 1 .. l_msg_count LOOP
    
      FND_MSG_PUB.GET(FND_MSG_PUB.g_first,
                      FND_API.g_true,
                      l_msg_data,
                      l_msg_count);
    
      FND_MESSAGE.SET_ENCODED(l_msg_data);
      msg_rec := FND_MESSAGE.GET_MESSAGE_RECORD;
    
      msg := msg || msg_rec.user_message || '.   ';
    
      FND_MSG_PUB.DELETE_MSG(1);
    END LOOP;
  
    FND_MSG_PUB.DELETE_MSG;
  
  END IF; */ 
  --REL-073 commented above code
 --REL-058 Added below code 

BEGIN
  
  intf_lines_tbl12 := AR_AUTOINV_INTF_PKG.INTF_LINES_TBL_TYPE();

  OPEN intf_cursor12;
  LOOP
    FETCH intf_cursor12
      INTO intf_lines_rec12;
    EXIT WHEN intf_cursor12%notfound;
	
	IF intf_lines_rec12.warehouse_code is null
	then 
		
	BEGIN
	SELECT DESCRIPTION into intf_lines_rec12.warehouse_code FROM fnd_lookup_values WHERE 
	lookup_type='CIRRUS_DIGAVN_WAREHOUSE_LKP' AND 
	language='US' AND enabled_flag='Y' and 
	MEANING = intf_lines_rec12.org_id;	
		
	EXCEPTION
        WHEN OTHERS THEN
      intf_lines_rec12.warehouse_code:=  NULL;
	  
	SELECT tag into intf_lines_rec12.warehouse_id
	FROM fnd_lookup_values 
	WHERE lookup_type='CIRRUS_DIGAVN_WAREHOUSE_LKP' 
	AND language='US' 
	AND enabled_flag='Y' 
	AND MEANING = intf_lines_rec12.org_id
    AND intf_lines_rec12.warehouse_code = NULL;         
		  
	end;
			
	---end if;	-- commented for REL-078
	if intf_lines_rec12.INVOICING_RULE_ID = -3
	THEN
	
	intf_lines_rec12.GL_DATE := NULL;
	
	end if;   
	
		
	--REL-078 Added below code 
	BEGIN
			invoice_description := NULL;
			
			FOR i IN intf_cursor1a(intf_lines_rec12.interface_line_attribute3) LOOP 
			
			

			IF (
					i.usage_flag = 'USAGE'
					AND i.graduated_code <> 'HIGHEST_TIER'   --Added For REL-079
					AND i.application_method_code = 'PER_UNIT'
					AND i.ENABLE_PRICING_TERM_YN = 'Y'
				) THEN
				
				invoice_description_calu := 0;
				invoice_description_calu1:=0;
				
				invoice_description := 'Total QTY ' || i.PRICED_QUANTITY || ' = ';
				
			BEGIN
			
				FOR j IN intf_cursor1b(i.inventory_item_id) LOOP

				IF i.PRICED_QUANTITY > j.TL_MINIMUM_VALUE THEN 
				
				IF i.PRICING_TERM_PRICING_METHOD = 'ORA_MARKDOWN' THEN
				
				invoice_description := invoice_description ||
				(case when i.PRICED_QUANTITY > j.TL_MAXIMUM_VALUE 
				then (j.TL_MAXIMUM_VALUE-j.TL_MINIMUM_VALUE)||'*'||j.TL_ADJUSTMENT_AMOUNT*POWER((1-(i.pricing_term_adjustment_pct/100)),(case when (i.formulae_val < 0) then '0' else i.formulae_val end))|| ' + '
			when i.PRICED_QUANTITY = j.TL_MAXIMUM_VALUE 
				then (j.TL_MAXIMUM_VALUE-j.TL_MINIMUM_VALUE)||'*'||j.TL_ADJUSTMENT_AMOUNT*POWER((1-(i.pricing_term_adjustment_pct/100)),(case when (i.formulae_val < 0) then '0' else i.formulae_val end))
			 when i.PRICED_QUANTITY between j.TL_MINIMUM_VALUE and j.TL_MAXIMUM_VALUE then (i.PRICED_QUANTITY - j.TL_MINIMUM_VALUE)||'*'||j.TL_ADJUSTMENT_AMOUNT*POWER((1-(i.pricing_term_adjustment_pct/100)),(case when (i.formulae_val < 0) then '0' else i.formulae_val end))
			
			Else '0' end)|| chr(13)||chr(10);
	ELSE
	
			  
			  invoice_description_calu1 :=invoice_description_calu1 +
			  (case when i.PRICED_QUANTITY > j.TL_MAXIMUM_VALUE 
             then 
            ( (j.TL_MAXIMUM_VALUE-j.TL_MINIMUM_VALUE)*j.TL_ADJUSTMENT_AMOUNT*POWER((1+(i.pricing_term_adjustment_pct/100)),( i.formulae_val_1) ))
               
            when i.PRICED_QUANTITY = j.TL_MAXIMUM_VALUE 
            then 
           ( (j.TL_MAXIMUM_VALUE-j.TL_MINIMUM_VALUE)*j.TL_ADJUSTMENT_AMOUNT*POWER((1+(i.pricing_term_adjustment_pct/100)),(i.formulae_val_1)) )
           
          when i.PRICED_QUANTITY between j.TL_MINIMUM_VALUE and j.TL_MAXIMUM_VALUE then ((i.PRICED_QUANTITY - j.TL_MINIMUM_VALUE)*j.TL_ADJUSTMENT_AMOUNT*POWER((1+(i.pricing_term_adjustment_pct/100)),(i.formulae_val_1)))

              else 
              '0' 
              end)
			  ;
			  
			  invoice_description_calu := invoice_description_calu +
			  (case when i.PRICED_QUANTITY > j.TL_MAXIMUM_VALUE 
             then 
            ( (j.TL_MAXIMUM_VALUE-j.TL_MINIMUM_VALUE)*j.TL_ADJUSTMENT_AMOUNT*POWER((1+(i.pricing_term_adjustment_pct/100)),(case when (i.formulae_val < 0) then '0' else i.formulae_val end)) )
               
            when i.PRICED_QUANTITY = j.TL_MAXIMUM_VALUE 
            then 
           ( (j.TL_MAXIMUM_VALUE-j.TL_MINIMUM_VALUE)*j.TL_ADJUSTMENT_AMOUNT*POWER((1+(i.pricing_term_adjustment_pct/100)),(case when (i.formulae_val < 0) then '0' else i.formulae_val end)) )
           
          when i.PRICED_QUANTITY between j.TL_MINIMUM_VALUE and j.TL_MAXIMUM_VALUE then ((i.PRICED_QUANTITY - j.TL_MINIMUM_VALUE)*j.TL_ADJUSTMENT_AMOUNT*POWER((1+(i.pricing_term_adjustment_pct/100)),(case when (i.formulae_val < 0) then 0 else i.formulae_val end)))

              else 
              '0' 
              end)
			  ;

	 END IF;

						
						END IF ;
						
						END LOOP;
						

						
			IF 	i.amount <> invoice_description_calu1 Then 
			    --  IF i.amount = invoice_description_calu THEN  -- commented for REL-079
			
			     IF i.amount= round (invoice_description_calu,2 ) THEN  -- Added for REL-079
					
					FOR j IN intf_cursor1b(i.inventory_item_id) LOOP

				IF i.PRICED_QUANTITY > j.TL_MINIMUM_VALUE THEN 
				
				IF i.PRICING_TERM_PRICING_METHOD = 'ORA_MARKDOWN' THEN
				
				invoice_description := invoice_description ||
				(case when i.PRICED_QUANTITY > j.TL_MAXIMUM_VALUE 
				then (j.TL_MAXIMUM_VALUE-j.TL_MINIMUM_VALUE)||'*'||j.TL_ADJUSTMENT_AMOUNT*POWER((1-(i.pricing_term_adjustment_pct/100)),(case when (i.formulae_val < 0) then '0' else i.formulae_val end))|| ' + '
			when i.PRICED_QUANTITY = j.TL_MAXIMUM_VALUE 
				then (j.TL_MAXIMUM_VALUE-j.TL_MINIMUM_VALUE)||'*'||j.TL_ADJUSTMENT_AMOUNT*POWER((1-(i.pricing_term_adjustment_pct/100)),(case when (i.formulae_val < 0) then '0' else i.formulae_val end))
			 when i.PRICED_QUANTITY between j.TL_MINIMUM_VALUE and j.TL_MAXIMUM_VALUE then (i.PRICED_QUANTITY - j.TL_MINIMUM_VALUE)||'*'||j.TL_ADJUSTMENT_AMOUNT*POWER((1-(i.pricing_term_adjustment_pct/100)),(case when (i.formulae_val < 0) then '0' else i.formulae_val end))
			
			Else '0' 
			end)|| chr(13)||chr(10);
	      ELSE
		  
		  invoice_description := invoice_description||
			  (case when i.PRICED_QUANTITY > j.TL_MAXIMUM_VALUE then (j.TL_MAXIMUM_VALUE-j.TL_MINIMUM_VALUE)||'*'||j.TL_ADJUSTMENT_AMOUNT*POWER((1+(i.pricing_term_adjustment_pct/100)),(case when (i.formulae_val < 0) then '0' else (i.formulae_val) end))|| ' + '
          when i.PRICED_QUANTITY = j.TL_MAXIMUM_VALUE then (j.TL_MAXIMUM_VALUE-j.TL_MINIMUM_VALUE)||'*'||j.TL_ADJUSTMENT_AMOUNT*POWER((1+(i.pricing_term_adjustment_pct/100)),(case when (i.formulae_val < 0) then '0' else (i.formulae_val) end))			  
          when i.PRICED_QUANTITY between j.TL_MINIMUM_VALUE and j.TL_MAXIMUM_VALUE then (i.PRICED_QUANTITY - j.TL_MINIMUM_VALUE)||'*'||j.TL_ADJUSTMENT_AMOUNT*POWER((1+(i.pricing_term_adjustment_pct/100)),(case when (i.formulae_val < 0) then '0' else (i.formulae_val) end))
	
	       

              else 
			--  '0'  commeted for REL-079
              null  --Added for REL-079
              end)|| chr(13)||chr(10);
			END IF;
        ELSE 

        invoice_description := invoice_description||
			  (case when i.PRICED_QUANTITY > j.TL_MAXIMUM_VALUE then (j.TL_MAXIMUM_VALUE-j.TL_MINIMUM_VALUE)||'*'||j.TL_ADJUSTMENT_AMOUNT*POWER((1+(i.pricing_term_adjustment_pct/100)),(case when (i.formulae_val < 0) then '0' else (i.formulae_val_1) end))|| ' + '
          when i.PRICED_QUANTITY = j.TL_MAXIMUM_VALUE then (j.TL_MAXIMUM_VALUE-j.TL_MINIMUM_VALUE)||'*'||j.TL_ADJUSTMENT_AMOUNT*POWER((1+(i.pricing_term_adjustment_pct/100)),(case when (i.formulae_val < 0) then '0' else (i.formulae_val_1) end))			  
          when i.PRICED_QUANTITY between j.TL_MINIMUM_VALUE and j.TL_MAXIMUM_VALUE then (i.PRICED_QUANTITY - j.TL_MINIMUM_VALUE)||'*'||j.TL_ADJUSTMENT_AMOUNT*POWER((1+(i.pricing_term_adjustment_pct/100)),(case when (i.formulae_val < 0) then '0' else (i.formulae_val_1) end))		

              else 
             -- '0'  commeted for REL-079
              null  --Added for REL-079
              end)|| chr(13)||chr(10);

        END IF;			  

						
						END LOOP;
						
		--ELSE Commented For REL-079
	
						
						END IF; --Added for REL-079
						
						END IF ;   --Added for REL-079
						
						IF 	i.amount = invoice_description_calu1 Then    --Added for REL-079
			
			FOR j IN intf_cursor1b(i.inventory_item_id) LOOP
				

				IF i.PRICED_QUANTITY > j.TL_MINIMUM_VALUE THEN 
				
				IF i.PRICING_TERM_PRICING_METHOD = 'ORA_MARKDOWN' THEN
				
				invoice_description := invoice_description ||
				(case when i.PRICED_QUANTITY > j.TL_MAXIMUM_VALUE 
				then (j.TL_MAXIMUM_VALUE-j.TL_MINIMUM_VALUE)||'*'||j.TL_ADJUSTMENT_AMOUNT*POWER((1-(i.pricing_term_adjustment_pct/100)),(case when (i.formulae_val < 0) then '0' else i.formulae_val end))|| ' + '
			when i.PRICED_QUANTITY = j.TL_MAXIMUM_VALUE 
				then (j.TL_MAXIMUM_VALUE-j.TL_MINIMUM_VALUE)||'*'||j.TL_ADJUSTMENT_AMOUNT*POWER((1-(i.pricing_term_adjustment_pct/100)),(case when (i.formulae_val < 0) then '0' else i.formulae_val end))
			 when i.PRICED_QUANTITY between j.TL_MINIMUM_VALUE and j.TL_MAXIMUM_VALUE then (i.PRICED_QUANTITY - j.TL_MINIMUM_VALUE)||'*'||j.TL_ADJUSTMENT_AMOUNT*POWER((1-(i.pricing_term_adjustment_pct/100)),(case when (i.formulae_val < 0) then '0' else i.formulae_val end))
			
			Else 
			 -- '0'  commeted for REL-079
              null  --Added for REL-079
			end)|| chr(13)||chr(10);
	ELSE
	

			invoice_description := invoice_description ||
			   --Added below for REL-079
			(case when i.PRICED_QUANTITY > j.TL_MAXIMUM_VALUE then (j.TL_MAXIMUM_VALUE-j.TL_MINIMUM_VALUE)||'*'||j.TL_ADJUSTMENT_AMOUNT
			|| ' + '
          when i.PRICED_QUANTITY = j.TL_MAXIMUM_VALUE then (j.TL_MAXIMUM_VALUE-j.TL_MINIMUM_VALUE)||'*'||j.TL_ADJUSTMENT_AMOUNT			  
          when i.PRICED_QUANTITY between j.TL_MINIMUM_VALUE and j.TL_MAXIMUM_VALUE then (i.PRICED_QUANTITY - j.TL_MINIMUM_VALUE)||'*'||j.TL_ADJUSTMENT_AMOUNT
		  --Added below for REL-079
	   --Commented Below for REL-079
	   /*
	   (case when i.PRICED_QUANTITY > j.TL_MAXIMUM_VALUE then (j.TL_MAXIMUM_VALUE-j.TL_MINIMUM_VALUE)||'*'||j.TL_ADJUSTMENT_AMOUNT*POWER((1+(i.pricing_term_adjustment_pct/100)),(case when (i.formulae_val < 0) then '0' else (i.formulae_val-1) end))|| ' + '
		   
          when i.PRICED_QUANTITY = j.TL_MAXIMUM_VALUE then (j.TL_MAXIMUM_VALUE-j.TL_MINIMUM_VALUE)||'*'||j.TL_ADJUSTMENT_AMOUNT*POWER((1+(i.pricing_term_adjustment_pct/100)),(case when (i.formulae_val < 0) then '0' else (i.formulae_val-1) end))			  
          when i.PRICED_QUANTITY between j.TL_MINIMUM_VALUE and j.TL_MAXIMUM_VALUE then (i.PRICED_QUANTITY - j.TL_MINIMUM_VALUE)||'*'||j.TL_ADJUSTMENT_AMOUNT*POWER((1+(i.pricing_term_adjustment_pct/100)),(case when (i.formulae_val < 0) then '0' else (i.formulae_val-1) end))
		  
	   */
			--Commented Above for REL-079  
			  else 
			 -- '0'  commeted for REL-079
              null  --Added for REL-079
			  end)||chr(13)||chr(10);
			
			  
			  END IF;

	 END IF;

						
						
						END LOOP;
						
						END IF;
						
					--	END IF ; commeted for REL-079
		
						
			END;
			
			ELSIF (i.USAGE_FLAG = 'USAGE' and i.application_method_code = 'PER_UNIT' 
			AND i.graduated_code <> 'HIGHEST_TIER' --Added for REL-079
			and nvl(i.ENABLE_PRICING_TERM_YN,'N') <> 'Y')
	 THEN 
	  BEGIN
	  
	  invoice_description := 'Total QTY ' || i.PRICED_QUANTITY || ' = '; -- added for REL-079
	 for j in intf_cursor1b(i.inventory_item_id)
	 LOOP
	 
	IF i.PRICED_QUANTITY > j.TL_MINIMUM_VALUE THEN
	   --commented below  for REL-079
	/*invoice_description := invoice_description || 'Tier' || j.TL_TIER_LINE_NUMBER || ': =$'||
																 
				when i.PRICED_QUANTITY between j.TL_MINIMUM_VALUE and j.TL_MAXIMUM_VALUE then 
							  
		  (i.PRICED_QUANTITY - j.TL_MINIMUM_VALUE )*j.TL_ADJUSTMENT_AMOUNT
			  
		 
			  else 0 end) ||chr(13)||chr(10);*/   
			  --commented above  for REL-079
	--Added below for REL-079
	invoice_description := invoice_description ||
			   --Added below for REL-079
			(case when i.PRICED_QUANTITY > j.TL_MAXIMUM_VALUE then (j.TL_MAXIMUM_VALUE-j.TL_MINIMUM_VALUE)||'*'||j.TL_ADJUSTMENT_AMOUNT
			|| ' + '
          when i.PRICED_QUANTITY = j.TL_MAXIMUM_VALUE then (j.TL_MAXIMUM_VALUE-j.TL_MINIMUM_VALUE)||'*'||j.TL_ADJUSTMENT_AMOUNT			  
          when i.PRICED_QUANTITY between j.TL_MINIMUM_VALUE and j.TL_MAXIMUM_VALUE then (i.PRICED_QUANTITY - j.TL_MINIMUM_VALUE)||'*'||j.TL_ADJUSTMENT_AMOUNT
		    else 
              null 
			  end)||chr(13)||chr(10);
	--Added bove for REL-079
	  end if;
	 end loop;
	  
	 
	 end;
			ELSE
				NULL;
		END IF ;
		
		--Added below for REL-079
		-- 'HIGHEST_TIER'
		IF (
					i.usage_flag = 'USAGE'
					AND i.graduated_code = 'HIGHEST_TIER'
					AND i.application_method_code = 'PER_UNIT'
				) THEN
		
		BEGIN
			
			FOR j IN intf_cursor1b(i.inventory_item_id) LOOP

			IF i.PRICED_QUANTITY > j.TL_MINIMUM_VALUE THEN 
			
			invoice_description := 'Total QTY ' || i.PRICED_QUANTITY || ' = '||         
			(CASE 
						WHEN i.PRICED_QUANTITY >= j.TL_MAXIMUM_VALUE
							THEN i.PRICED_QUANTITY || '*'||j.TL_ADJUSTMENT_AMOUNT
						WHEN i.PRICED_QUANTITY = j.TL_MAXIMUM_VALUE
							THEN  i.PRICED_QUANTITY || '*'||j.TL_ADJUSTMENT_AMOUNT
						WHEN i.PRICED_QUANTITY BETWEEN j.TL_MINIMUM_VALUE
								AND j.TL_MAXIMUM_VALUE
							THEN i.PRICED_QUANTITY || '*'||j.TL_ADJUSTMENT_AMOUNT
						ELSE '0'
						END
					);    

			END IF ;
				
			END LOOP;
		END;
		ELSE
			NULL;
    END IF ;
	
	--Added above for REL-079
	
	-----Usage based all tier block method
	
	IF (
				i.usage_flag = 'USAGE'
				AND i.graduated_code <> 'HIGHEST_TIER'
				AND i.application_method_code = 'AS_BLOCK'
				AND i.PARTIAL_BLOCK_ACTION_CODE = 'PARTIAL_BLOCK'
		) THEN

		BEGIN
			
			FOR j IN intf_cursor1b(i.inventory_item_id) LOOP

			IF i.PRICED_QUANTITY > j.TL_MINIMUM_VALUE THEN 
			
                --Added below for REL-079	
            invoice_description := 'Total QTY ' || i.PRICED_QUANTITY || ' = '|| 				
			(CASE 
						WHEN i.PRICED_QUANTITY >= j.TL_MAXIMUM_VALUE
							THEN (j.TL_MINIMUM_VALUE || ' to ' || j.TL_MAXIMUM_VALUE) || ':' || i.amount
						WHEN i.PRICED_QUANTITY = j.TL_MAXIMUM_VALUE
							THEN (j.TL_MINIMUM_VALUE || ' to ' || j.TL_MAXIMUM_VALUE)|| ':' || i.amount
						WHEN i.PRICED_QUANTITY BETWEEN j.TL_MINIMUM_VALUE
								AND j.TL_MAXIMUM_VALUE
							THEN (j.TL_MINIMUM_VALUE || ' to ' || j.TL_MAXIMUM_VALUE) || ':' || i.amount
						ELSE '0'
						END
					);     
					--Added above for REL-079
					--Commented  below for REL-079
					
					/*
					   invoice_description := invoice_description ||
					   (CASE 
						WHEN i.PRICED_QUANTITY >= j.TL_MAXIMUM_VALUE
							THEN (j.TL_MINIMUM_VALUE || '-' || j.TL_MAXIMUM_VALUE) || ':' || j.TL_ADJUSTMENT_AMOUNT*POWER((1+(i.pricing_term_adjustment_pct/100)),(case when (i.formulae_val < 0) then '0' else i.formulae_val_1 end))|| ' + '
						WHEN i.PRICED_QUANTITY = j.TL_MAXIMUM_VALUE
							THEN (j.TL_MINIMUM_VALUE || '-' || j.TL_MAXIMUM_VALUE) || ':' || j.TL_ADJUSTMENT_AMOUNT*POWER((1+(i.pricing_term_adjustment_pct/100)),(case when (i.formulae_val < 0) then '0' else i.formulae_val_1 end))
						WHEN i.PRICED_QUANTITY BETWEEN j.TL_MINIMUM_VALUE
								AND j.TL_MAXIMUM_VALUE
							THEN (j.TL_MINIMUM_VALUE || '-' || j.TL_MAXIMUM_VALUE) || ':' || j.TL_ADJUSTMENT_AMOUNT*POWER((1+(i.pricing_term_adjustment_pct/100)),(case when (i.formulae_val < 0) then '0' else i.formulae_val_1 end))
						ELSE '0'
						END
					);*/      
					--Commented above for REL-079
					
			
		
			END IF ;
				
			END LOOP;
		END;
		ELSE
			NULL;
    END IF ;
-----Usage based highest tier block method


	IF (
			i.usage_flag = 'USAGE'
			AND i.graduated_code = 'HIGHEST_TIER'
			AND i.application_method_code = 'AS_BLOCK'
			AND i.PARTIAL_BLOCK_ACTION_CODE = 'PARTIAL_BLOCK'
			) THEN invoice_description := NULL;
	BEGIN
		FOR j IN intf_cursor1b(i.inventory_item_id) LOOP

		IF i.priced_quantity > j.tl_minimum_value
			AND i.priced_quantity <= j.tl_maximum_value THEN 
			
			invoice_description := 'Total QTY ' || i.PRICED_QUANTITY || ' = ' || j.tl_minimum_value || ' to ' || j.tl_maximum_value || ': ' || i.amount; 
		
			
			END IF ;
			
			END LOOP;
	END;
	ELSE
		NULL;
	
	END IF ;
	
	
	-----Non usage 
	
	
	IF (i.usage_flag <> 'USAGE') THEN 
	
	invoice_description := NULL;
	
	BEGIN
		invoice_description := 'Total QTY ' || i.PRICED_QUANTITY || ' = ' || i.PRICED_QUANTITY || '*'||i.amount ;
	END;
	
	END IF ;
	
	
	
	END LOOP;

intf_lines_rec12.attribute1 := SUBSTR(invoice_description, 1, 150);

intf_lines_rec12.attribute2 := SUBSTR(invoice_description, 151, 150);

intf_lines_rec12.attribute3 := SUBSTR(invoice_description, 301, 150);

intf_lines_rec12.attribute4 := SUBSTR(invoice_description, 451, 150);

intf_lines_rec12.attribute5 := SUBSTR(invoice_description, 601, 150);

EXCEPTION 

WHEN OTHERS THEN 

NULL;

END;

END IF;

	--REL-078 Added above code 
	
	
	
	intf_lines_tbl12.extend;
    intf_lines_tbl12(index_count12) := intf_lines_rec12;
    index_count12 := index_count12 + 1;
		
  END LOOP;
  CLOSE intf_cursor12;  
  
  AR_AUTOINV_INTF_PKG.UPDATE_INTERFACE_LINES(intf_lines_tbl12,
                                             l_msg_count,
                                             l_msg_data,
                                             l_return_status);
		COMMIT;									 
																		 
END;
-- REL-058 Added above code

 -- Added REL-073 below code 
   Begin  
  intf_lines_tbl4 := AR_AUTOINV_INTF_PKG.INTF_LINES_TBL_TYPE();
  
  for i in intf_cursor3
  LOOP 
  open intf_cursor4(i.interface_line_attribute3,i.interface_line_attribute1);
  loop
  fetch intf_cursor4 
     into intf_lines_rec4;  
  exit when intf_cursor4%notfound;
    p_cost_center :=null; 
	if (i.count_attribute11 > 1) THEN
	intf_lines_rec4.header_attribute_category := 'CCLAR';
	intf_lines_rec4.header_attribute3 :=  'DFLT';
	ELSE	
	begin
	select flv.description into p_cost_center
	from fnd_lookup_values flv
	where 1=1
	  and flv.lookup_type= 'CIRRUSAR_COSTCENTER_REC'
	  --and REGEXP_SUBSTR(intf_lines_rec4.attribute11,'[^-]+')= flv.LOOKUP_CODE   --Commented For REL-079
	  and intf_lines_rec4.attribute11 like flv.LOOKUP_CODE||'%'  --Added for REL-079
	  and flv.ENABLED_FLAG='Y'   --Added for REL-079
      and flv.language='US';
	 EXCEPTION WHEN OTHERS THEN
     NULL; 
     end; 
	 intf_lines_rec4.header_attribute3 :=  p_cost_center;	
	 intf_lines_rec4.header_attribute_category := 'CCLAR';
	end if;
	
    intf_lines_tbl4.extend;
    intf_lines_tbl4(index_count2) := intf_lines_rec4;
    index_count2 := index_count2 + 1;  
    
  end loop; 								 
  close intf_cursor4;   											 
  end loop; 	
   AR_AUTOINV_INTF_PKG.UPDATE_INTERFACE_LINES(intf_lines_tbl4,
                                             l_msg_count,
                                             l_msg_data,
                                             l_return_status);
  COMMIT;  
-- commented below code for REL-106 (EMG)
 /*  -- Added below code for REL 106 LBR
  BEGIN

  intf_lines_tb15 := AR_AUTOINV_INTF_PKG.INTF_LINES_TBL_TYPE();

  OPEN intf_cursor5;
  LOOP
    FETCH intf_cursor5
      INTO intf_lines_rec5;
    EXIT WHEN intf_cursor5%NOTFOUND;
  
  
	BEGIN
	 
     OPEN intf_cursor6(intf_lines_rec5.INTERFACE_LINE_ATTRIBUTE1);	 
	 FETCH intf_cursor6 INTO product_family2;
    CLOSE intf_cursor6;
		
		EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
      intf_lines_rec5.HEADER_ATTRIBUTE5       :=  product_family2 ;  
	  
      intf_lines_rec5.attribute_category := 'CCLAR';
	  
  
    intf_lines_tb15.extend;
    intf_lines_tb15(index_count5) := intf_lines_rec5;
    index_count5 := index_count5 + 1;
  
  END LOOP;
  CLOSE intf_cursor5;

  AR_AUTOINV_INTF_PKG.UPDATE_INTERFACE_LINES(intf_lines_tb15,
                                             l_msg_count,
                                             l_msg_data,
                                             l_return_status);

  COMMIT;
  END;
  -- Added above code for REL 106 LBR */
 -- commented above code for REL-106 (EMG)
 -- Added below code for REL-106 (EMG)
	BEGIN

  intf_lines_tbl5 := AR_AUTOINV_INTF_PKG.INTF_LINES_TBL_TYPE();

  OPEN intf_cursor5;
  LOOP
    FETCH intf_cursor5
      INTO intf_lines_rec5;
    EXIT WHEN intf_cursor5%NOTFOUND;
	
	
  
    IF intf_lines_rec5.interface_line_context = 'DOO' THEN
	BEGIN
	  
  SELECT ecb.attribute2 into product_family
    FROM
EGP_CATEGORIES_B ecb,
INV_ORG_PARAMETERS iop,
EGP_CATEGORY_SETS_VL ecst,
EGP_ITEM_CATEGORIES eic,
EGP_SYSTEM_ITEMS_B esib,
DOO_HEADERS_ALL hdr,
DOO_HEADERS_EFF_B hdreff,
DOO_FULFILL_LINES_ALL fla
WHERE 1=1
AND ecb.category_id                  = eic.category_id
AND esib.organization_id             = iop.organization_id
AND iop.organization_code            = 'GED_IMO'
AND ecst.category_set_name           = 'Global_Inv_Default_Catalog'
AND eic.category_set_id              = ecst.category_set_id
AND esib.inventory_item_id           = eic.inventory_item_id
AND esib.organization_id             = eic.organization_id 
AND esib.inventory_item_id           in (select inventory_item_id from ra_interface_lines_all  where INTERFACE_LINE_ID in
                                             (select min(INTERFACE_LINE_ID) 
		                           from ra_interface_lines_all 
								   where INTERFACE_LINE_ATTRIBUTE3= intf_lines_rec5.INTERFACE_LINE_ATTRIBUTE3))
AND hdr.header_id = hdreff.header_id
AND UPPER(hdreff.context_code) = 'GED HEADER EFF CONTEXT'
AND fla.inventory_item_id         = esib.inventory_item_id
AND hdr.order_number = intf_lines_rec5.INTERFACE_LINE_ATTRIBUTE3 
AND fla.fulfill_line_id in (select interface_line_attribute6 from ra_interface_lines_all  where INTERFACE_LINE_ID in
                                             (select min(INTERFACE_LINE_ID) 
		                           from ra_interface_lines_all 
								   where INTERFACE_LINE_ATTRIBUTE3= intf_lines_rec5.INTERFACE_LINE_ATTRIBUTE3))
AND hdr.header_id = fla.header_id
AND hdr.org_id in (select org_id from ra_interface_lines_all  where INTERFACE_LINE_ID in
                                             (select min(INTERFACE_LINE_ID) 
		                           from ra_interface_lines_all 
								   where INTERFACE_LINE_ATTRIBUTE3= intf_lines_rec5.INTERFACE_LINE_ATTRIBUTE3));
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
      intf_lines_rec5.header_attribute15        :=  product_family ;
         
	  
      
	  
    END IF;
	IF intf_lines_rec5.interface_line_context not in ('DOO') THEN
	BEGIN
	   SELECT ecb.attribute2 INTO product_family_contract
    FROM
EGP_CATEGORIES_B ecb,
INV_ORG_PARAMETERS iop,
EGP_CATEGORY_SETS_VL ecst,
EGP_ITEM_CATEGORIES eic,
EGP_SYSTEM_ITEMS_B esib
WHERE 1=1
AND ecb.category_id                  = eic.category_id
AND esib.organization_id             = iop.organization_id
AND iop.organization_code            = 'GED_IMO'
AND ecst.category_set_name           = 'Global_Inv_Default_Catalog'
AND eic.category_set_id              = ecst.category_set_id
AND esib.inventory_item_id           = eic.inventory_item_id
AND esib.organization_id             = eic.organization_id 
AND esib.inventory_item_id   in  (select inventory_item_id from ra_interface_lines_all  where INTERFACE_LINE_ID in
                                             (select min(INTERFACE_LINE_ID) 
		                           from ra_interface_lines_all 
								   where INTERFACE_LINE_ATTRIBUTE1= intf_lines_rec5.INTERFACE_LINE_ATTRIBUTE1));
  

      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;

  
      intf_lines_rec5.header_attribute15         := product_family_contract ;
	 

 

    
    END IF;
	
  
    intf_lines_tbl5.extend;
    intf_lines_tbl5(index_count5) := intf_lines_rec5;
    index_count5 := index_count5 + 1;
  
  END LOOP;
  CLOSE intf_cursor5;

  AR_AUTOINV_INTF_PKG.UPDATE_INTERFACE_LINES(intf_lines_tbl5,
                                             l_msg_count,
                                             l_msg_data,
                                             l_return_status);

  COMMIT;
end; 
-- Added Above code for REL-106 (EMG)
   -- Added in REL-073 above code
 -- Added in REL-073 below code
  IF l_return_status = FND_API.g_ret_sts_error OR
     l_return_status = FND_API.g_ret_sts_unexp_error THEN
  
    FOR i in 1 .. l_msg_count LOOP
    
      FND_MSG_PUB.GET(FND_MSG_PUB.g_first,
                      FND_API.g_true,
                      l_msg_data,
                      l_msg_count);
    
      FND_MESSAGE.SET_ENCODED(l_msg_data);
      msg_rec := FND_MESSAGE.GET_MESSAGE_RECORD;
    
      msg := msg || msg_rec.user_message || '.   ';
    
      FND_MSG_PUB.DELETE_MSG(1);
    END LOOP;
  
    FND_MSG_PUB.DELETE_MSG;
  
  END IF;
  end;
 -- Added in REL-073 above code

  OPEN :xdo_cursor FOR
    SELECT msg FROM DUAL;
  COMMIT;

END;