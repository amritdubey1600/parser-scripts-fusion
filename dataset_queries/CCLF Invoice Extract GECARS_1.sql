/*--#-----------------------------------------------------------------------------------------------------------------#
--# GECARS Invoice Classic Extract datamodel
--# DESCRIPTION  : This data model query used to get the GECARS invoice classic extract
--#                
--# CREATION DATE     :
--# CREATED BY      : 
--#
--# MODIFICATION HISTORY:
--# CR#                 Author            Date                  Description
--# ----------------------------------------------------------------------------------------------------------------------------------------------------------------#
--# REL-007           Shankar U        07-Aug-2017              Modified InvoiceBCO, InvoiceBillICNO logic should come from Company code DFF, BU_ID join. 
--#                                                             Added 'KEY' column for bursting as earlier it was hard coded as 'BCOCANCCL'. Other support request
--# REL-007           Goplakrishnan    07-Aug-2017              Case #15654861 changes.            
--# REL-071           Venkatesh S      12-Dec-2022              Included new BU in condition to get 	InvoiceBCO				
--# REL-075           Hussain Basha    01-Apr-2023              Stop sending Empty Record file to GS /TC server 	RITM#GERITM37484124 		
--# ----------------------------------------------------------------------------------------------------------------------------------------------------------------#*/
SELECT DISTINCT NULL FlexField1,
  rctt.name FlexField2,
  NULL FlexField3,
  NULL FlexField4,
  NULL FlexField5,
  NULL FlexField6,
  NULL FlexField7,
  NULL FlexField8,
  NULL FlexField9,
  NULL FlexField10,
  NULL FlexField11,
  NULL FlexField12,
  NULL LineFlexField1,
  NULL LineFlexField2,
  NULL LineFlexField3,
  NULL LineFlexField4,
  NULL LineFlexField5,
  NULL LineFlexField6,
  NULL LineFlexField7,
  NULL LineFlexField8,
  NULL LineFlexField9,
  NULL LineFlexField10,
  NULL LineFlexField11,
  NULL LineFlexField12,
  ----'BCOCANCCL' InvoiceBCO, removed hardcoding
   CASE WHEN C.BU_NAME in ('CA_CAD_BU', 'CA_CC2107_CAD_BU')  THEN    --REL-007 Added--added REL071--new BU
		  (SELECT a4.attribute1
            FROM AR_SYSTEM_PARAMETERS_ALL a4
           WHERE a4.attribute_category = 'CCLAR'
		     AND a4.org_id = c.bu_id  --REL-007 Added
				 ) 
--REL-007 Added 	 
	ELSE  
             (SELECT fvv.ATTRIBUTE7
                FROM FND_FLEX_VALUE_SETS fvs, FND_FLEX_VALUES fvv
               WHERE     fvv.flex_value_set_id = fvs.flex_value_set_id
                     AND fvs.flex_value_set_name = 'CCL_COMPANY_CODES'
                     AND fvv.ATTRIBUTE9 IS NOT NULL                --BU_Number
                     AND fvv.ATTRIBUTE7 IS NOT NULL                 -- BCOCODE
                     AND fvv.ATTRIBUTE2 IS NOT NULL               -- GECARS_IC
                     AND fvv.ATTRIBUTE1 IS NOT NULL -- GECARS_Extract enabled flag
                     AND fvv.ATTRIBUTE8 IS NOT NULL -- = 'C' -- GECARS type 'L' = 'Lite', 'C'= 'Classic', 'P' = 'Prime'
                     AND TO_NUMBER (fvv.ATTRIBUTE9) = c.bu_id
                     AND fvv.flex_value = gcc.segment1
                     AND ROWNUM = 1)
     END 
--REL-007 Adding ends here
  InvoiceBCO,
  /*  rct.trx_number   Invoice_Number, */
  rct.trx_number InvoiceLineNO,
  '1' InvoiceItemNO,
  ---------'CCLCACORP' InvoiceIC,
  /* (select attribute2 from  fnd_flex_values where flex_value =  gcc.segment1 and attribute1='Y') InvoiceIC, */
  (
  SELECT DISTINCT ffv.attribute2
  FROM fnd_flex_values ffv,
    fnd_flex_value_sets ffvs ,
    FND_FLEX_VALUES_TL FFVT
  where rownum =1
  AND flex_value           = gcc.segment1
  AND attribute1             ='Y'
  AND ffvs.flex_value_set_id = ffv.flex_value_set_id
  AND ffv.flex_value_id      = ffvt.flex_value_id
  AND flex_value_set_name LIKE '%CCL_COMPANY%'
  ) InvoiceIC,
  ------ gcc.segment1 InvoiceIC,
  (
  SELECT SUM(extended_amount)
  FROM RA_CUSTOMER_TRX_LINES_ALL
  WHERE customer_trx_id = rct.customer_trx_id
  ) InvoiceItemAmount,
  0 InvoiceVATAmount,
  sysdate InvoiceItemSentDate,
  sysdate InvoiceItemProcessDate,
  'N' InvoiceProcessFlag,
  sySdate InvoiceItemTIMESTAMP,
  '111111' InvoiceItemCostCenter,
  sysdate WM_TIMESTAMP,
  NULL InvoiceCustomerNumber, -- Changed as per GECARS team
  ---------hcas.orig_system_reference InvoiceBusinessCustomerNumber,  --- 26-08-2015 that was the issue
  SUBSTR(hps.party_site_number, 1, 12) InvoiceBusinessCustomerNumber,--Has to be GECARS customer number not HCa.ACCOUNT_NUMBER testing
  ---'30' InvoiceARType,
  DECODE(rctt.attribute3,'Y','101','30') InvoiceARType,
  ---'10' InvoiceTC,
  DECODE(rctt.type,'CM','12','10') InvoiceTC,
  rct.trx_date InvoiceDate,
  rct.trx_number InvoiceNO, --- earlier it was id
  null INVOICEPROJECTNO,
   APS.DUE_DATE INVOICEDUEDATE, -- Added for REL#007 - 502616078 - Case #15654861
  '814' INVOICEINITTERM, -- Added for REL#007 - 502616078 - Case #15654861
/* -- Removed for REL#007 - 502616078 - Case #15654861
sysdate InvoiceDueDate,
  ----------'814' InvoiceInitTerm,
  DECODE(rctt.type,'CM','814',DECODE(flex.cnt,13,'816',
  (SELECT attribute1 FROM RA_TERMS_B WHERE term_id = rct.term_id
  ))) InvoiceInitTerm,
*/ -- Removed for REL#007 - 502616078 - Case #15654861
  (SELECT SUM(extended_amount)
  FROM RA_CUSTOMER_TRX_LINES_ALL
  WHERE customer_trx_id = rct.customer_trx_id
  ) InvoiceAmount,
  /* (SELECT SUM(extended_amount)
  FROM RA_CUSTOMER_TRX_LINES_ALL
  WHERE customer_trx_id = rct.customer_trx_id) InvoiceTransAmount, */
  (
  SELECT SUM(ACCTD_AMOUNT)
  FROM RA_CUST_TRX_LINE_GL_DIST_ALL
  where customer_trx_id = rct.customer_trx_id
  AND account_class     = 'REC'
  ) InvoiceTransAmount,
  NULL InvoiceMemoAmt,
  rct.invoice_currency_code InvoiceCurrency,
  gll.currency_code InvoiceBaseCurrency,
  NULL InvoiceMemoCurrency,
  NULL InvoiceARCNO,
  NULL InvoiceDRMemo,
  NULL InvoiceRefNo,
  rct.org_id InvoiceDeptNo,
  SUBSTR(hzp.party_name,1,9) InvoiceSalesMan,
 CASE WHEN C.BU_NAME in ('CA_CAD_BU', 'CA_CC2107_CAD_BU')  THEN    --REL-007 Added--REL--071 added new BU
             (SELECT a4.attribute1
                FROM AR_SYSTEM_PARAMETERS_ALL a4
               WHERE a4.attribute_category = 'CCLAR'
			     AND a4.org_id = c.bu_id  --REL-007 Added
				 ) 
	--REL-007 Adding starts here
	 ELSE 
             (SELECT fvv.ATTRIBUTE7
                FROM FND_FLEX_VALUE_SETS fvs, FND_FLEX_VALUES fvv
               WHERE     fvv.flex_value_set_id = fvs.flex_value_set_id
                     AND fvs.flex_value_set_name = 'CCL_COMPANY_CODES'
                     AND fvv.ATTRIBUTE9 IS NOT NULL                --BU_Number
                     AND fvv.ATTRIBUTE7 IS NOT NULL                 -- BCOCODE
                     AND fvv.ATTRIBUTE2 IS NOT NULL               -- GECARS_IC
                     AND fvv.ATTRIBUTE1 IS NOT NULL -- GECARS_Extract enabled flag
                     AND fvv.ATTRIBUTE8 IS NOT NULL -- = 'C' -- GECARS type 'L' = 'Lite', 'C'= 'Classic', 'P' = 'Prime'
                     AND TO_NUMBER (fvv.ATTRIBUTE9) = c.bu_id
                     AND fvv.flex_value = gcc.segment1
                     AND ROWNUM = 1)

 END  ----REL-007 Adding ends here
 InvoiceBillICNO, --- Earlier it was CCLCACORP
  NULL InvoiceReqNO,
  NULL InvoiceBillLading,
  NULL InvoicePONumber,
  SYSDATE InvoiceSentDate,
  sysdate InvoiceProcessdate,
  'N' LINEINVOICEPROCESSFLAG,
  NULL InvoiceNotifyDate,
  NULL InvoiceCIEDate,
  NULL InvoiceOrderSORID,
  SYSDATE InvoiceBusiness_TIMESTAMP,
  rct.customer_trx_id InvoiceBusinessSytemInvoiceID, ---------------------------------------
  NULL InvoicePayment_Schedule,                                                         ----aps.payment_schedule_id
  TRIM(SUBSTR(hl.COUNTRY,1,2)) InvoiceShipCountry,
  TRIM(SUBSTR(DECODE(hl.STATE,'PR','PR',hl.COUNTRY),1,2)) InvoiceBILLCountry,
  NULL InvoiceDraftFlag,
  NULL InvoiceCONO,
  NULL InvoiceBankCode,
  NULL InvoiceBankAcct,
  NULL InvoiceDiscRec,
  NULL InvoiceShipAddr1,
  NULL InvoiceShipAddr2,
  NULL InvoiceShipAddr3,
  NULL InvoiceShipAddr4,
  NULL InvoiceShipAddr5,
  NULL InvoiceShipCity,
  NULL InvoiceShipProv,
  NULL InvoiceShipPostalCode,
  NULL InvoiceCIG,
  NULL InvoiceCUP,
  NULL InvoiceSequenceNo,
  NULL InvoiceFailuerReasonCode,
  'KEY' "KEY"               --REL-007 Added
FROM RA_CUSTOMER_TRX_ALL rct,
  PER_ALL_PEOPLE_F papf,
  AR_PAYMENT_SCHEDULES_ALL aps,
  RA_CUST_TRX_TYPES_ALL rctt,
  (SELECT COUNT(1) cnt,
    id_flex_num coa_id
  from FND_ID_FLEX_SEGMENTS
  where rownum=1
  AND id_flex_code = 'GL#'
  GROUP BY id_flex_num
  ) flex,
  RA_BATCH_SOURCES_ALL rbs,
  GL_LEDGERS gll,
  HZ_CUST_ACCT_SITES_ALL hcas,
  HZ_CUST_ACCOUNTS hca,
  HZ_PARTY_SITES hps,
  HZ_PARTIES hzp,
  HZ_LOCATIONS hl,
  HZ_LOCATIONS hl1,
  HZ_CUST_SITE_USES_ALL hcsu,
  RA_CUST_TRX_LINE_GL_DIST_ALL rctlg,
  hz_parties hp1,
  hz_party_sites hps1,
  hz_party_site_uses hpsu,
  GL_CODE_COMBINATIONS gcc,
  xla_ae_headers xah ,
  fun_all_business_units_v c
WHERE hca.cust_account_id = rct.bill_to_customer_id
AND rctlg.event_id        = xah.event_id
AND c.bu_id               = rct.org_id
  -- added condition for LE.
AND c.bu_name IN
  (SELECT fab.bu_name
  FROM ar_system_parameters_all ASPA,
    fun_all_business_units_v FAB ,
    hr_all_organization_units ha
  WHERE ha.organization_id    = fab.bu_id
  AND ASPA.attribute_category = 'CCLAR'
  AND ASPA.attribute1        IS NOT NULL
  AND ha.organization_id      = aspa.org_id
  )
AND xah.gl_transfer_date IS NOT NULL
AND --  addded by Vijay
  hzp.party_id                = hca.party_id
AND hzp.party_id              = hps.party_id
AND hps.party_site_id         = hcas.party_site_id
AND hcas.CUST_ACCOUNT_ID      = HCA.CUST_ACCOUNT_ID
AND hps.location_id           = hl.location_id
AND hCaS.CUST_ACCT_SITE_ID    = hcsu.CUST_ACCT_SITE_ID
AND hcsU.set_id               = hCaS.set_id
AND hcsU.SITE_USE_CODE        = 'BILL_TO'
AND hCA.customer_type         = 'R'
AND hCaS.status               ='A'
AND aps.customer_trx_id       = rct.customer_trx_id
AND rctt.CUST_TRX_TYPE_SEQ_ID = rct.CUST_TRX_TYPE_SEQ_ID
AND flex.coa_id               = gll.chart_of_accounts_id
AND gll.ledger_id             = rct.set_of_books_id
AND gcc.code_combination_id   = rctlg.code_combination_id
AND
  /* Only if its posted */
  ---- rctlg.gl_posted_date IS NOT NULL and
  rctlg.account_class     = 'REC'
AND rctlg.customer_trx_id = rct.customer_trx_id
AND gll.ledger_id         = rct.set_of_books_id
--AND c.bu_name = 'CA_CAD_PGS_BU'
  /* ADDED -100 FOR TESTING ONLY */
  -- (RCTLG.CREATION_DATE > NVL( (SELECT MAX(ERH.processstart-10)
AND  (xah.gl_transfer_date > NVL(
  (SELECT MAX(ERH.processstart) -- changed condition by Vijay
  FROM ess_request_history ERH ,
    ess_request_property ERP1 ,
    ess_request_property ERP2
  WHERE ERH.requestid       = ERP1.requestid
  AND ERH.requestid         = ERP2.requestid
  AND ERH.definition        = 'JobDefinition://oracle/apps/ess/custom/AR/CCLF_CAR_INV_EXTRACT'
  AND ERH.executable_status = 'SUCCEEDED'
  AND ERP1.name             = 'submit.argument1'
  AND ERP1.value           IS NULL
  AND ERP2.name             = 'submit.argument2'
  AND ERP2.value           IS NULL
  ), rctlg.CREATION_DATE-1) )  
AND rbs.batch_source_seq_id = rct.batch_source_seq_id
AND hps1.location_id        =hl1.location_id
AND hpsu.site_use_type      = 'SHIP_TO'
AND hpsu.party_site_use_id  =rct.ship_to_party_site_use_id
AND hps1.party_site_id      = hpsu.party_site_id
AND hps1.party_id           =hp1.party_id
  -------- and hcas.CUST_ACCT_SITE_ID = rct.bill_to_address_id
AND hcsu.site_use_id=rct.bill_to_site_use_id
  /* Added on 8th Sep just to take invoice posted today
  and     ((RCTLG.LAST_UPDATE_DATE> ('2015/09/01',')) OR
  (RCTLG.CREATION_DATE =('2015/09/01'')) )
  -------and rctt.name  NOT IN ('V068 EXT In','V360 EXT In')
  */
AND NVL(rct.attribute1,'Y') !='N'
AND NVL(:P_INVOICENO,rct.trx_number) = rct.trx_number --added by Bela
UNION
SELECT NULL FlexField1,
  NULL FlexField2,
  NULL FlexField3,
  NULL FlexField4,
  NULL FlexField5,
  NULL FlexField6,
  NULL FlexField7,
  NULL FlexField8,
  NULL FlexField9,
  NULL FlexField10,
  NULL FlexField11,
  NULL FlexField12,
  NULL LineFlexField1,
  NULL LineFlexField2,
  NULL LineFlexField3,
  NULL LineFlexField4,
  NULL LineFlexField5,
  NULL LineFlexField6,
  NULL LineFlexField7,
  NULL LineFlexField8,
  NULL LineFlexField9,
  NULL LineFlexField10,
  NULL LineFlexField11,
  NULL LineFlexField12,
  ' ' InvoiceBCO,
  --NULL InvoiceBCO,
  NULL InvoiceLineNO,
  NULL InvoiceItemNO,
  NULL InvoiceIC,
  ------ gcc.segment1 InvoiceIC,
  NULL InvoiceItemAmount,
  NULL InvoiceVATAmount,
  NULL InvoiceItemSentDate,
  NULL InvoiceItemProcessDate,
  NULL InvoiceProcessFlag,
  NULL InvoiceItemTIMESTAMP,
  NULL InvoiceItemCostCenter,
  NULL WM_TIMESTAMP,
  NULL InvoiceCustomerNumber,
  NULL InvoiceBusinessCustomerNumber,
  ---'30' InvoiceARType,
  NULL InvoiceARType,
  ---'10' InvoiceTC,
  NULL InvoiceTC,
  NULL InvoiceDate,
  NULL InvoiceNO, --- earlier it was id
  NULL InvoiceProjectNo,
  NULL InvoiceDueDate,
  NULL InvoiceInitTerm,
  NULL InvoiceAmount,
  NULL InvoiceTransAmount,
  NULL InvoiceMemoAmt,
  NULL InvoiceCurrency,
  NULL InvoiceBaseCurrency,
  NULL InvoiceMemoCurrency,
  NULL InvoiceARCNO,
  NULL InvoiceDRMemo,
  NULL InvoiceRefNo,
  NULL InvoiceDeptNo,
  NULL InvoiceSalesMan,
  NULL InvoiceBillICNO, --- Earlier it was CCLCACORP
  NULL InvoiceReqNO,
  NULL InvoiceBillLading,
  NULL InvoicePONumber,
  NULL InvoiceSentDate,
  NULL InvoiceProcessdate,
  NULL LINEINVOICEPROCESSFLAG,
  NULL InvoiceNotifyDate,
  NULL InvoiceCIEDate,
  NULL InvoiceOrderSORID,
  NULL InvoiceBusiness_TIMESTAMP,
  NULL InvoiceBusinessSytemInvoiceID,
  NULL InvoicePayment_Schedule,
  NULL InvoiceShipCountry,
  NULL InvoiceBILLCountry,
  NULL InvoiceDraftFlag,
  NULL InvoiceCONO,
  NULL InvoiceBankCode,
  NULL InvoiceBankAcct,
  NULL InvoiceDiscRec,
  NULL InvoiceShipAddr1,
  NULL InvoiceShipAddr2,
  NULL InvoiceShipAddr3,
  NULL InvoiceShipAddr4,
  NULL InvoiceShipAddr5,
  NULL InvoiceShipCity,
  NULL InvoiceShipProv,
  NULL InvoiceShipPostalCode,
  NULL InvoiceCIG,
  NULL InvoiceCUP,
  NULL InvoiceSequenceNo,
  null INVOICEFAILUERREASONCODE,
  --'KEY' "KEY"             ----REL-007 Added, Commented in REL-075-Apr-2023 RITM#GERITM37484124 							
  'KEY1' "KEY"              ----Added REL-075-Apr-2023 RITM#GERITM37484124 
FROM sys.dual