SELECT	RACTL.CUSTOMER_TRX_LINE_ID		LN_CUSTOMER_TRX_LINE_ID,
RACTL.CUSTOMER_TRX_ID LN_CUSTOMER_TRX_ID,
RACTL.tax_rate ABCS,
RACTL.EXTENDED_Amount TEST_TAX,
	RACTL.LINE_NUMBER 			LN_LINE_NUMBER,
                   RACTL.LINE_TYPE				LN_LINE_TYPE_CODE,
	LOOK1.MEANING				LN_LINE_TYPE,
                  	NVL(MTLSITL.DESCRIPTION,
                            RACTL.DESCRIPTION)			LN_DESCRIPTION,
	---commented from past  ITEM_FLEX_ALL_SEG			LN_ITEM_NUMBER,
	RACTL.INVENTORY_ITEM_ID                 INVENTORY_ITEM_ID,
Decode(LINE_TYPE, 'LINE', RACTL.QUANTITY_INVOICED,RACTL.QUANTITY_CREDITED)  LN_Quantity, 
/*	DECODE(:TRANSACTION_TYPE_CODE,
		'CM', 	RACTL.QUANTITY_CREDITED,
			RACTL.QUANTITY_INVOICED)
						LN_QUANTITY, */
-----------------/*  Added 2nd sep night */ 
RACTL.SALES_TAX_ID  Customer_TAX_ID,
RACTL.TAX_INVOICE_DATE  TAX_POINT_DATE,
Round( (SELECT extended_amount
          FROM RA_CUSTOMER_TRX_LINES_ALL
         WHERE customer_trx_id = ractl.customer_trx_id  and customer_trx_line_id=ractl.customer_trx_line_id) * (select nvl(Exchange_rate,1) from RA_CUSTOMER_TRX_ALL where  customer_trx_id = ractl.customer_trx_id  )  ,2) Functional_Entered_Line_Amount,
-------- RACTL.gross_extended_amount   Entered_Gross_Line_Amount,
(  (SELECT extended_amount
          FROM RA_CUSTOMER_TRX_LINES_ALL
         WHERE customer_trx_id = ractl.customer_trx_id  and customer_trx_line_id=ractl.customer_trx_line_id) +  (SELECT nvl(SUM(extended_amount),0)
          FROM RA_CUSTOMER_TRX_LINES_ALL
         WHERE ractl.customer_trx_line_id = LINK_TO_CUST_TRX_LINE_ID ))Entered_Gross_Line_Amount,
/* (SELECT SUM(ACCTD_AMOUNT)
          FROM RA_CUST_TRX_LINE_GL_DIST_ALL
         WHERE customer_trx_id = ractl.customer_trx_id and account_class = 'REC')   */ 
Round(( ((SELECT extended_amount
          FROM RA_CUSTOMER_TRX_LINES_ALL
         WHERE customer_trx_id = ractl.customer_trx_id  and customer_trx_line_id=ractl.customer_trx_line_id) +  (SELECT nvl(SUM(extended_amount),0)
          FROM RA_CUSTOMER_TRX_LINES_ALL
         WHERE ractl.customer_trx_line_id = LINK_TO_CUST_TRX_LINE_ID )) * (select nvl(Exchange_rate,1) from RA_CUSTOMER_TRX_ALL where  customer_trx_id = ractl.customer_trx_id  ) ) ,2) Functional_Gross_Lin_Amount,
RACTL.created_by    LN_created_by,
	MTLUOM.UNIT_OF_MEASURE			LN_UNIT_OF_MEASURE,
	RACTL.UNIT_SELLING_PRICE			LN_NET_SELLING_PRICE,
	RACTL.EXTENDED_AMOUNT			LN_NET_EXTENDED_AMOUNT,
	NVL (RACTL.GROSS_UNIT_SELLING_PRICE,
		RACTL.UNIT_SELLING_PRICE)		LN_GROSS_SELLING_PRICE,
	NVL (RACTL.GROSS_EXTENDED_AMOUNT,
		RACTL.EXTENDED_AMOUNT)		LN_GROSS_EXTENDED_AMOUNT,
	--VAT.TAX_CODE				LN_TAX_CODE,
	/*rchandan for fusion...interim*/
	--ZRB.TAX_RATE_CODE             LN_TAX_CODE,

	LOOK2.MEANING				LN_TAX_INCLUSIVE,
	RACTL.SALES_ORDER			LN_ORDER_NUMBER,
	To_Char(RACTL.SALES_ORDER_DATE,'YYYY-MM-DD')			LN_ORDER_DATE,
	RACTL.SALES_ORDER_REVISION		LN_ORDER_REVISION,
	RACTL.SALES_ORDER_SOURCE		LN_SALES_CHANNEL,
	RACTL.ACCOUNTING_RULE_DURATION		LN_DURATION,
(select nvl(waybill_number,'-') from ra_customer_trx_all where customer_trx_id = RACTL.CUSTOMER_TRX_ID) Shipping_ref,
	RAR.NAME				LN_ACCOUNTING_RULE,
	To_Char(RACTL.RULE_START_DATE,'YYYY-MM-DD')			LN_RULE_START_DATE,
	RACTL.VAT_TAX_ID            VAT_TAX_ID,
	To_Char(RAC.TRX_DATE,'YYYY-MM-DD')                TRX_DATE,
	AR_ARXTDR_XMLP_PKG.Fn_Tax_Code(RACTL.VAT_TAX_ID,RAC.TRX_DATE) VAT_TAX_CODE,
	ROWNUM 				LN_ROWNUM,
RACTL.attribute1  Flexfields81,
RACTL.attribute2  Flexfields2,
RACTL.attribute3  Flexfields3,
RACTL.attribute4  Flexfields4,
RACTL.attribute5  Flexfields5,
RACTL.attribute6  Flexfields6,
RACTL.attribute7  ADN,
RACTL.attribute8  Flexfields8,
ractl.attribute9  Flexfields9,
RACTL.attribute10 Flexfield10,
(select to_number(a.EXTENDED_AMOUNT) from RA_CUSTOMER_TRX_LINES_ALL a where a.LINK_TO_CUST_TRX_LINE_ID= ractl.CUSTOMER_TRX_LINE_ID and  a.LINE_TYPE='TAX' and a.Line_number=1 ) tamt1,
TO_NUMBER((select to_number(a.EXTENDED_AMOUNT) from RA_CUSTOMER_TRX_LINES_ALL a where a.LINK_TO_CUST_TRX_LINE_ID= ractl.CUSTOMER_TRX_LINE_ID and  a.LINE_TYPE='TAX' and a.Line_number=2 )) tamt2,
(select a.tax_rate from RA_CUSTOMER_TRX_LINES_ALL a where a.LINK_TO_CUST_TRX_LINE_ID= ractl.CUSTOMER_TRX_LINE_ID and  a.LINE_TYPE='TAX' and a.Line_number=1 ) trate1,
(select a.tax_rate from RA_CUSTOMER_TRX_LINES_ALL a where a.LINK_TO_CUST_TRX_LINE_ID= ractl.CUSTOMER_TRX_LINE_ID and  a.LINE_TYPE='TAX' and a.Line_number=2 ) trate2,
(Select zb.tax from  RA_CUSTOMER_TRX_LINES_ALL c, zx_rates_b zb
where c.vat_tax_id = zb.TAX_RATE_ID  and  c.LINK_TO_CUST_TRX_LINE_ID= ractl.CUSTOMER_TRX_LINE_ID and  c.LINE_TYPE='TAX' and c.Line_number= '2' ) txregime2,
(Select zb.tax from  RA_CUSTOMER_TRX_LINES_ALL c, zx_rates_b zb
where c.vat_tax_id=zb.TAX_RATE_ID and  c.LINK_TO_CUST_TRX_LINE_ID= ractl.CUSTOMER_TRX_LINE_ID and  c.LINE_TYPE='TAX' and c.Line_number='1' ) taxregime1 
FROM	AR_LOOKUPS		LOOK2,
		AR_LOOKUPS		LOOK1,
		--MTL_SYSTEM_ITEMS_TL           MTLSITL,
		EGP_SYSTEM_ITEMS_TL           MTLSITL,
		--MTL_SYSTEM_ITEMS	MTLSI,
		EGP_SYSTEM_ITEMS 	MTLSI,
--		AR_VAT_TAX		VAT, /*rchandan for fusion...interim*/
       --ZX_RATES_B        ZRB,
		--MTL_UNITS_OF_MEASURE	MTLUOM,
		INV_UNITS_OF_MEASURE 	MTLUOM,
		RA_RULES		                   RAR,
		RA_CUSTOMER_TRX_LINES_ALL    	RACTL,
		 RA_CUSTOMER_TRX_ALL RAC
WHERE	LOOK2.LOOKUP_TYPE(+) = 'YES/NO'
AND	LOOK2.LOOKUP_CODE(+) = RACTL.AMOUNT_INCLUDES_TAX_FLAG
AND	LOOK1.LOOKUP_TYPE(+) = 'STD_LINE_TYPE'
AND	LOOK1.LOOKUP_CODE(+) = RACTL.LINE_TYPE
AND	MTLSI.INVENTORY_ITEM_ID(+) = RACTL.INVENTORY_ITEM_ID
-----------------------------AND	MTLSI.ORGANIZATION_ID(+) = :ITEM_FLEX_STRUCTURE
--AND	ESIB.ORGANIZATION_ID(+) = :ITEM_FLEX_STRUCTURE
AND           MTLSITL.INVENTORY_ITEM_ID(+) = MTLSI.INVENTORY_ITEM_ID
-----------------------------AND           nvl(MTLSITL.LANGUAGE, :p_base_lang) = NVL(USERENV('LANG'),:p_base_lang)
----------------------------------------------------AND           MTLSITL.ORGANIZATION_ID(+)  = :ITEM_FLEX_STRUCTURE
--AND	VAT.VAT_TAX_ID(+) = RACTL.VAT_TAX_ID /*rchandan for fusion...interim*/
AND	MTLUOM.UOM_CODE(+) = RACTL.UOM_CODE
AND	RAR.RULE_ID(+) = RACTL.ACCOUNTING_RULE_ID
---------------------------------------------------AND	RACTL.CUSTOMER_TRX_ID = :CUSTOMER_TRX_ID
AND	RACTL.LINE_TYPE IN ('LINE', 'CHARGES')
AND RAC.CUSTOMER_TRX_ID=RACTL.CUSTOMER_TRX_ID
-------------------------------------------------------AND RACTL.ORG_ID = :P_ORG_ID
--AND ZRB.TAX_RATE_ID=RACTL.VAT_TAX_ID


ORDER BY
	RACTL.lINE_NUMBER