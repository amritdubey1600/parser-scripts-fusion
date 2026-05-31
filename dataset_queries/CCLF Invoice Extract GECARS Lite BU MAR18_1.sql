/*--#-----------------------------------------------------------------------------------------------------------------#
--# GECARS Invoice Extract data model
--# DESCRIPTION  : This data model query used to get the GECARS invoice extract
--#                
--# CREATION DATE     :
--# CREATED BY      : 
--#
--# MODIFICATION HISTORY:
--# CR#                 Author             Date                 Description
--# REL-028             Kishore            22-APR-2019          Excluding the mentioned transaction types through lookup
--# REL-030             Karun              25-JUN-2019          Added Purchase Order Column
--# REL-037             Raghunath Balaji   27-JAN-2020			Added a logic to extract the entire characters of 
--#                                                             Business customer number for Indonesia BU
--# ---------------------------------------------------------------------------------------------------------------------
*/

select (Select (select TO_CHAR(count(*))  KEY
from 
(SELECT DISTINCT
       'KEY' KEY,
       FVV.ATTRIBUTE7 INVOICEBCO,
       (CASE
           WHEN LENGTH (HPS.PARTY_SITE_NUMBER) <= 12
           THEN
              HPS.PARTY_SITE_NUMBER
           WHEN     LENGTH (HPS.PARTY_SITE_NUMBER) > 12
                --AND C.BU_NAME NOT IN ('JP_AVI_V834_BU', 'JP_AVI_V833_BU')						--Commented as part of Rel-037
				--Added the below code as part of Rel-037
				AND C.BU_NAME NOT IN (SELECT lookup_code 
									    FROM FND_LOOKUP_VALUES
									   WHERE lookup_type='CIRRUSAR_GECARS_BUEXCEPTIONS'
										 AND language='US'
										 AND TRUNC (SYSDATE) BETWEEN NVL (start_date_active, TRUNC (SYSDATE)) AND NVL (end_date_active, TRUNC (SYSDATE))
										 AND enabled_flag = 'Y')
				--Added the above code as part of Rel-037
           THEN
              SUBSTR (HPS.PARTY_SITE_NUMBER, -12)
           WHEN C.BU_NAME = 'JP_AVI_V834_BU'
           THEN
                 SUBSTR (HPS.PARTY_SITE_NUMBER, 1, 4)
              || SUBSTR (HPS.PARTY_SITE_NUMBER, -5)
           WHEN C.BU_NAME = 'JP_AVI_V833_BU'
           THEN
                 SUBSTR (HPS.PARTY_SITE_NUMBER, 1, 4)
              || SUBSTR (HPS.PARTY_SITE_NUMBER, -5)
           ELSE
              HPS.PARTY_SITE_NUMBER
        END)
          INVOICEBUSINESSCUSTOMERNUMBER,
       DECODE (RCTT.ATTRIBUTE3, 'Y', '101', '30') INVOICEARTYPE,
       DECODE (APS.CLASS,
               'INV', '010',
               'DM', '010',
               'CM', '012',
               'PMT', '013')
          INVOICETC,
       RCT.TRX_DATE INVOICEDATE,
       RCT.TRX_NUMBER INVOICENO,
       NULL INVOICEPROJECTNO,
       APS.DUE_DATE INVOICEDUEDATE,
       '814' INVOICEINITTERM,
       APS.AMOUNT_DUE_REMAINING INVOICEAMOUNT,
       --aps.ACCTD_AMOUNT_DUE_REMAINING  InvoiceTransAmount,
       CASE
          WHEN APS.INVOICE_CURRENCY_CODE <> FVV.ATTRIBUTE5
          THEN
             (SELECT ROUND (GDR.CONVERSION_RATE * APS.AMOUNT_DUE_REMAINING,
                            2)
                FROM GL_DAILY_RATES GDR, GL_DAILY_CONVERSION_TYPES GDCT
               WHERE     1 = 1
                     AND TRUNC (GDR.CONVERSION_DATE) = TRUNC (APS.GL_DATE)
                     AND GDR.CONVERSION_TYPE = GDCT.CONVERSION_TYPE
                     AND GDCT.USER_CONVERSION_TYPE = 'MOR'
                     AND GDCT.PIVOT_CURRENCY_CODE = 'USD'
                     AND GDR.TO_CURRENCY = FVV.ATTRIBUTE5
                     AND GDR.FROM_CURRENCY = APS.INVOICE_CURRENCY_CODE)
          WHEN FVV.ATTRIBUTE5 IS NULL
          THEN
             APS.ACCTD_AMOUNT_DUE_REMAINING
          ELSE
             APS.AMOUNT_DUE_REMAINING
       END
          INVOICETRANSAMOUNT,
       NULL INVOICEMEMOAMT,
       RCT.INVOICE_CURRENCY_CODE INVOICECURRENCY,
       --gll.currency_code InvoiceBaseCurrency,
       NVL (FVV.ATTRIBUTE5, GLL.CURRENCY_CODE) INVOICEBASECURRENCY,
       NULL INVOICEMEMOCURRENCY,
       NULL INVOICEARCNO,
       NULL INVOICEDRMEMO,
       NULL INVOICEREFNO,
       RCT.ORG_ID INVOICEDEPTNO,
       SUBSTR (HZP.PARTY_NAME, 1, 9) INVOICESALESMAN,
       FVV.ATTRIBUTE7 INVOICEBILLICNO,
       NULL INVOICEREQNO,
       NULL INVOICEBILLLADING,
	   -- REL-030  commented out -- NULL INVOICEPONUMBER,
       rct.purchase_order  INVOICEPONUMBER, -- REL-030 added
       NULL INVOICENOTIFYDATE,
       NULL INVOICECIEDATE,
       NULL INVOICEORDERSORID,
       '1' INVOICEITEMNO,
       FVV.ATTRIBUTE2 INVOICEIC,
       '111111' INVOICEITEMCOSTCENTER,
       NULL INVOICEITEMAMOUNT,
       NULL INVOICEITEMTRANAMOUNT,
       0 INVOICEVATAMOUNT,
       TRIM (SUBSTR (HL.COUNTRY, 1, 2)) INVOICESHIPCOUNTRY,
       TRIM (SUBSTR (DECODE (HL.STATE, 'PR', 'PR', HL.COUNTRY), 1, 2))
          INVOICEBILLCOUNTRY,
       RCT.CUSTOMER_TRX_ID INVOICEBUSINESSSYTEMINVOICEID,
       APS.PAYMENT_SCHEDULE_ID INVOICEPAYMENT_SCHEDULE, ----aps.payment_schedule_id
       NULL FLEXFIELD1,
       SUBSTR (RCTT.NAME, 1, 15) FLEXFIELD2,
       (SELECT TO_CHAR (SALES_ORDER_DATE, 'DD-MON-YYYY')
          FROM RA_CUSTOMER_TRX_LINES_ALL
         WHERE ROWNUM = 1 AND CUSTOMER_TRX_ID = RCT.CUSTOMER_TRX_ID)
          FLEXFIELD3,
       NULL FLEXFIELD4,
       NULL FLEXFIELD5,
       NULL FLEXFIELD6,
       NULL FLEXFIELD7,
       NULL FLEXFIELD8,
       NULL FLEXFIELD9,
       NULL FLEXFIELD10,
       NULL FLEXFIELD11,
       NULL FLEXFIELD12,
       NULL LINEFLEXFIELD1,
       NULL LINEFLEXFIELD2,
       NULL LINEFLEXFIELD3,
       NULL LINEFLEXFIELD4,
       NULL LINEFLEXFIELD5,
       NULL LINEFLEXFIELD6,
       NULL LINEFLEXFIELD7,
       NULL LINEFLEXFIELD8,
       NULL LINEFLEXFIELD9,
       NULL LINEFLEXFIELD10,
       NULL LINEFLEXFIELD11,
       NULL LINEFLEXFIELD12,
       TRIM (
          SUBSTR (REPLACE (REPLACE ( (HL1.ADDRESS1), '"', NULL), ',', NULL),
                  1,
                  48))
          INVOICESHIPADDR1,
       TRIM (
          SUBSTR (REPLACE (REPLACE ( (HL1.ADDRESS2), '"', NULL), ',', NULL),
                  1,
                  48))
          INVOICESHIPADDR2,
       TRIM (
          SUBSTR (REPLACE (REPLACE ( (HL1.ADDRESS3), '"', NULL), ',', NULL),
                  1,
                  48))
          INVOICESHIPADDR3,
       TRIM (
          SUBSTR (REPLACE (REPLACE ( (HL1.ADDRESS4), '"', NULL), ',', NULL),
                  1,
                  48))
          INVOICESHIPADDR4,
       NULL INVOICESHIPADDR5,
       --hl1.CITY  InvoiceShipCity,
       (CASE
           WHEN     HL1.CITY IS NULL
                AND C.BU_NAME IN ('JP_AVI_V834_BU', 'JP_AVI_V833_BU')
           THEN
              'Tokyo'
           ELSE
              TRIM (
                 SUBSTR (
                    REPLACE (REPLACE ( (HL1.CITY), '"', NULL), ',', NULL),
                    1,
                    48))
        END)
          INVOICESHIPCITY,
       HL1.COUNTRY INVOICESHIPPROV,
       HL1.POSTAL_CODE INVOICESHIPPOSTALCODE,
       NULL INVOICECIG,
       NULL INVOICECUP,
       NULL INVOICECASHCODE,
       NULL INVOICECASHCOMMENT,
       NULL DBINVOICESHIPADDR1,
       NULL DBINVOICESHIPADDR2,
       NULL DBINVOICESHIPADDR3,
       NULL DBINVOICESHIPADDR4,
       NULL DBINVOICESHIPADDR5,
       NULL DBINVOICESHIPCITY,
       NULL DBINVOICESHIPPROVINCE,
       NULL DBINVOICESHIPPOSTALCODE
  FROM RA_CUSTOMER_TRX_ALL RCT,
       ---PER_ALL_PEOPLE_F papf, COMMENTED AS PER REQUIREMENT
       AR_PAYMENT_SCHEDULES_ALL APS,
       RA_CUST_TRX_TYPES_ALL RCTT,
       (  SELECT COUNT (1) CNT, ID_FLEX_NUM COA_ID
            FROM FND_ID_FLEX_SEGMENTS
           WHERE ID_FLEX_CODE = 'GL#'
        GROUP BY ID_FLEX_NUM) FLEX,
       RA_BATCH_SOURCES_ALL RBS,
       GL_LEDGERS GLL,
       HZ_CUST_ACCT_SITES_ALL HCAS,
       HZ_CUST_ACCOUNTS HCA,
       HZ_PARTY_SITES HPS,
       HZ_PARTIES HZP,
       HZ_LOCATIONS HL,
       HZ_CUST_SITE_USES_ALL HCSU,
       RA_CUST_TRX_LINE_GL_DIST_ALL RCTLG,
       ---  hz_parties hp1, commented as per required changes
       ---  hz_party_sites hps1, commented as per required changes
       --- hz_party_site_uses hpsu, commented as per required changes
       HZ_PARTIES HZP1,                                         ---Newly added
       HZ_PARTY_SITES HPS1,                                      --newly added
       HZ_CUST_ACCOUNTS HCA1,                                    --newly added
       HZ_CUST_ACCT_SITES_ALL HCAS1,                            -- newly added
       HZ_CUST_SITE_USES_ALL HCSU1,                              --newly added
       HZ_LOCATIONS HL1,                                        ---newly added
       GL_CODE_COMBINATIONS GCC,
       FND_FLEX_VALUE_SETS FVS,
       FND_FLEX_VALUES FVV,
       XLA_AE_HEADERS XAH,
       FUN_ALL_BUSINESS_UNITS_V C
WHERE     HCA.CUST_ACCOUNT_ID = RCT.BILL_TO_CUSTOMER_ID
       AND RCTLG.EVENT_ID = XAH.EVENT_ID
       AND C.BU_ID = RCT.ORG_ID
       --AND  GCC.segment1         IN ('V833', 'V834')
       AND FVV.FLEX_VALUE_SET_ID = FVS.FLEX_VALUE_SET_ID
       AND FVS.FLEX_VALUE_SET_NAME = 'CCL_COMPANY_CODES'
       AND FVV.FLEX_VALUE = GCC.SEGMENT1
       AND FVV.ATTRIBUTE9 IS NOT NULL                              --BU_Number
       AND FVV.ATTRIBUTE7 IS NOT NULL                               -- BCOCODE
       AND FVV.ATTRIBUTE2 IS NOT NULL                             -- GECARS_IC
       AND FVV.ATTRIBUTE1 = 'Y'                 -- GECARS_Extract enabled flag
       AND FVV.ATTRIBUTE8 = 'L' -- GECARS type 'L' = 'Lite', 'C'= 'Classic', 'P' = 'Prime'
       AND XAH.GL_TRANSFER_DATE IS NOT NULL
       AND HZP.PARTY_ID = HCA.PARTY_ID
       AND HZP.PARTY_ID = HPS.PARTY_ID
       AND HPS.PARTY_SITE_ID = HCAS.PARTY_SITE_ID
       AND HCAS.CUST_ACCOUNT_ID = HCA.CUST_ACCOUNT_ID
       AND HPS.LOCATION_ID = HL.LOCATION_ID
       AND HCAS.CUST_ACCT_SITE_ID = HCSU.CUST_ACCT_SITE_ID
       AND HCSU.SET_ID = HCAS.SET_ID
       AND HCSU.SITE_USE_CODE = 'BILL_TO'
       AND HCA.CUSTOMER_TYPE = 'R'
       AND HCAS.STATUS = 'A'
       AND APS.CUSTOMER_TRX_ID = RCT.CUSTOMER_TRX_ID
       AND RCTT.CUST_TRX_TYPE_SEQ_ID = RCT.CUST_TRX_TYPE_SEQ_ID
       AND HCA1.CUST_ACCOUNT_ID = RCT.BILL_TO_CUSTOMER_ID
       AND FLEX.COA_ID = GLL.CHART_OF_ACCOUNTS_ID
       AND GLL.LEDGER_ID = RCT.SET_OF_BOOKS_ID
       AND GCC.CODE_COMBINATION_ID = RCTLG.CODE_COMBINATION_ID
       AND RCTLG.ACCOUNT_CLASS = 'REC'
       AND RCTLG.CUSTOMER_TRX_ID = RCT.CUSTOMER_TRX_ID
       AND GLL.LEDGER_ID = RCT.SET_OF_BOOKS_ID
       AND RBS.BATCH_SOURCE_SEQ_ID = RCT.BATCH_SOURCE_SEQ_ID
       --AND hps1.location_id        =hl1.location_id     commented as per required changes
       --AND hpsu.site_use_type      = 'SHIP_TO'         commented as per required changes
       --AND hpsu.party_site_use_id  =rct.ship_to_party_site_use_id  commented as per required changes
       --AND hps1.party_site_id      = hpsu.party_site_id     commented as per required changes
       --AND hps1.party_id           =hp1.party_id            commented as per required changes
       -------- and hcas.CUST_ACCT_SITE_ID = rct.bill_to_address_id    commented as per required changes
       ---AND hcsu.site_use_id=rct.bill_to_site_use_id
       AND HZP1.PARTY_ID = HCA1.PARTY_ID                         --NEWLY ADDED
       AND HZP1.PARTY_ID = HPS1.PARTY_ID                         --NEWLY ADDED
       AND HPS1.PARTY_SITE_ID = HCAS1.PARTY_SITE_ID             ---NEWLY ADDED
       AND HCAS1.CUST_ACCOUNT_ID = HCA1.CUST_ACCOUNT_ID          --NEWLY ADDED
       AND HPS1.LOCATION_ID = HL1.LOCATION_ID                    --NEWLY ADDED
       AND HCAS1.CUST_ACCT_SITE_ID = HCSU1.CUST_ACCT_SITE_ID     --NEWLY ADDED
       AND HCSU1.SET_ID = HCAS1.SET_ID                           --NEWLY ADDED
       AND HCSU1.SITE_USE_CODE = 'SHIP_TO'                       --NEWLY ADDED
       AND HCA1.CUSTOMER_TYPE = 'R'                              --NEWLY ADDED
       AND HCAS1.STATUS = 'A'                                    --NEWLY ADDED
       AND NVL (RCT.ATTRIBUTE1, 'Y') != 'N'
       AND APS.ACCTD_AMOUNT_DUE_REMAINING <> 0
       and  hcsu.PRIMARY_FLAG = 'Y'  --- COMMENTED AS PER REQUIREMENT
       AND HCSU1.PRIMARY_FLAG = 'Y'                 --ADDED AS PER REQUIREMENT
--Added below code for REL-028								
       AND rctt.name NOT IN (SELECT lookup_code FROM FND_LOOKUP_VALUES
                                    WHERE lookup_type='CIRRUSAR_GECARS_TRX_EXCLUDE'
									AND language='US'
									AND TRUNC (SYSDATE) BETWEEN NVL (start_date_active, TRUNC (SYSDATE)) AND NVL (end_date_active, TRUNC (SYSDATE))
                                    AND enabled_flag = 'Y')
--Added above code for REL-028
	union
SELECT DISTINCT 'KEY' KEY, 
  fvv.ATTRIBUTE7 InvoiceBCO,
  (CASE
    WHEN LENGTH(hps.PARTY_SITE_NUMBER) <=12     THEN hps.PARTY_SITE_NUMBER
    --WHEN LENGTH(hps.PARTY_SITE_NUMBER) >12 and c.BU_NAME not in ('JP_AVI_V834_BU' , 'JP_AVI_V833_BU')  THEN SUBSTR(hps.PARTY_SITE_NUMBER,-12)						--Commented as part of Rel-037
	--Added the below code as part of Rel-037
	WHEN LENGTH(hps.PARTY_SITE_NUMBER) >12 and c.BU_NAME not in ( SELECT lookup_code 
																	FROM FND_LOOKUP_VALUES
																   WHERE lookup_type='CIRRUSAR_GECARS_BUEXCEPTIONS'
																	 AND language='US'
																	 AND TRUNC (SYSDATE) BETWEEN NVL (start_date_active, TRUNC (SYSDATE)) AND NVL (end_date_active, TRUNC (SYSDATE))
																	 AND enabled_flag = 'Y')
    THEN SUBSTR(hps.PARTY_SITE_NUMBER,-12)
	--Added the above code as part of Rel-037
	WHEN c.BU_NAME  = 'JP_AVI_V834_BU' THEN  SUBSTR(hps.PARTY_SITE_NUMBER,1,4)||SUBSTR(hps.PARTY_SITE_NUMBER,-5)
	WHEN c.BU_NAME  = 'JP_AVI_V833_BU' THEN  SUBSTR(hps.PARTY_SITE_NUMBER,1,4)||SUBSTR(hps.PARTY_SITE_NUMBER,-5)
    ELSE hps.PARTY_SITE_NUMBER
  END) InvoiceBusinessCustomerNumber,
  DECODE(rctt.attribute3,'Y','101','30') InvoiceARType,
   DECODE(APS.CLASS, 'INV', '010', 'DM', '010', 'CM', '012', 'PMT', '013') InvoiceTC,
   aps.trx_date InvoiceDate,
     to_char(RCT.CASH_RECEIPT_ID) InvoiceNO, --  RCT.RECEIPT_NUMBER  - To avoid dupicate adde CASH_RECEIPT_ID,
  NULL InvoiceProjectNo,
 aps.DUE_DATE InvoiceDueDate,
  '814' InvoiceInitTerm,
  aps.AMOUNT_DUE_REMAINING      InvoiceAmount,
  --aps.ACCTD_AMOUNT_DUE_REMAINING  InvoiceTransAmount,
  CASE 
	WHEN aps.INVOICE_CURRENCY_CODE <>  fvv.ATTRIBUTE5 then
		(select ROUND(GDR.CONVERSION_RATE*aps.AMOUNT_DUE_REMAINING ,2) 
			from GL_DAILY_RATES GDR,
				GL_DAILY_CONVERSION_TYPES GDCT
			where 1=1 
			and trunc(GDR.CONVERSION_DATE ) =   trunc(aps.GL_DATE)
			AND GDR.CONVERSION_TYPE = GDCT.CONVERSION_TYPE
			AND GDCT.USER_CONVERSION_TYPE = 'MOR'
			AND GDCT.PIVOT_CURRENCY_CODE = 'USD'
			AND GDR.TO_CURRENCY = fvv.ATTRIBUTE5
			AND GDR.FROM_CURRENCY=  aps.INVOICE_CURRENCY_CODE) 
	WHEN fvv.ATTRIBUTE5 is null then aps.ACCTD_AMOUNT_DUE_REMAINING
	else aps.AMOUNT_DUE_REMAINING 
End InvoiceTransAmount,
  NULL InvoiceMemoAmt,
  APS.INVOICE_CURRENCY_CODE InvoiceCurrency,  
  --gll.currency_code InvoiceBaseCurrency,
  nvl(fvv.ATTRIBUTE5,gll.currency_code)InvoiceBaseCurrency,
  NULL InvoiceMemoCurrency,
  NULL InvoiceARCNO,
  NULL InvoiceDRMemo,
  NULL InvoiceRefNo,
  rct.org_id InvoiceDeptNo,
  SUBSTR(hp.party_name,1,9) InvoiceSalesMan,
  fvv.ATTRIBUTE7 InvoiceBillICNO,
  NULL InvoiceReqNO,
  NULL InvoiceBillLading,
  NULL InvoicePONumber,
  NULL InvoiceNotifyDate,
  NULL InvoiceCIEDate,
  NULL InvoiceOrderSORID,
  '1' InvoiceItemNO,
  fvv.attribute2 InvoiceIC,
  '111111' InvoiceItemCostCenter,
  NULL InvoiceItemAmount, 
  NULL InvoiceItemTRANAmount,
  0 InvoiceVATAmount,
  TRIM(SUBSTR(hl.COUNTRY,1,2)) InvoiceShipCountry,
  TRIM(SUBSTR(DECODE(hl.STATE,'PR','PR',hl.COUNTRY),1,2)) InvoiceBILLCountry,
  RCT.CASH_RECEIPT_ID InvoiceBusinessSytemInvoiceID,
  aps.payment_schedule_id InvoicePayment_Schedule,
   NULL FlexField1,
  SUBSTR(rctt.name,1,15) FlexField2,
  Null  FlexField3,
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
  TRIM(SUBSTR(REPLACE(REPLACE((hl.ADDRESS1),'"',NULL),',',NULL),1,48)) InvoiceShipAddr1,
  TRIM(SUBSTR(REPLACE(REPLACE((hl.ADDRESS2),'"',NULL),',',NULL),1,48)) InvoiceShipAddr2,
  TRIM(SUBSTR(REPLACE(REPLACE((hl.ADDRESS3),'"',NULL),',',NULL),1,48)) InvoiceShipAddr3,
  TRIM(SUBSTR(REPLACE(REPLACE((hl.ADDRESS4),'"',NULL),',',NULL),1,48)) InvoiceShipAddr4,
  NULL InvoiceShipAddr5,
  --hl.CITY InvoiceShipCity,
  (CASE 
       WHEN hl.CITY is null and  c.BU_NAME  in ('JP_AVI_V834_BU' , 'JP_AVI_V833_BU') then 'Tokyo'
	   else TRIM(SUBSTR(REPLACE(REPLACE((hl.CITY),'"',NULL),',',NULL),1,48))
	   End) InvoiceShipCity,
  hl.COUNTRY InvoiceShipProv,
  hl.POSTAL_CODE InvoiceShipPostalCode,
  NULL InvoiceCIG,
  NULL InvoiceCUP,  
  NULL InvoiceCashCode,
  NULL InvoiceCashComment,
  NULL DBInvoiceShipAddr1,
  NULL DBInvoiceShipAddr2,
  NULL DBInvoiceShipAddr3,
  NULL DBInvoiceShipAddr4,
  NULL DBInvoiceShipAddr5,
  NULL DBInvoiceShipCity,
  NULL DBInvoiceShipProvince,
  NULL DBInvoiceShipPostalCode
FROM AR_CASH_RECEIPTS_ALL RCT,
  HZ_CUST_ACCOUNTS hca,
  HZ_PARTIES HP,
  HZ_PARTY_SITES hps,
  HZ_CUST_ACCT_SITES_ALL hcas,
  HZ_LOCATIONS hl,
  HZ_CUST_SITE_USES_ALL hcsu,
  AR_PAYMENT_SCHEDULES_ALL APS,
  AR_CASH_RECEIPT_HISTORY_ALL HIST,
  --XLA_AE_HEADERS XAH ,
  --XLA_AE_LINES XAL
  fun_all_business_units_v c,
  GL_CODE_COMBINATIONS gcc,
  fnd_flex_value_sets fvs,
  fnd_flex_values fvv,
  (SELECT COUNT(1) cnt,
    id_flex_num coa_id
  FROM FND_ID_FLEX_SEGMENTS
  WHERE id_flex_code = 'GL#'
  GROUP BY id_flex_num
  ) flex,
  GL_LEDGERS gll,
  RA_CUST_TRX_TYPES_ALL rctt
WHERE 1=1
  -- and  RCT.RECEIPT_NUMBER  ='ANA-Unapplied Receipt'
AND RCT.PAY_FROM_CUSTOMER = HCA.CUST_ACCOUNT_ID
AND HCA.PARTY_ID          = HP.PARTY_ID
AND APS.CASH_RECEIPT_ID   = RCT.CASH_RECEIPT_ID
AND APS.ORG_ID            = RCT.ORG_ID
AND HIST.CASH_RECEIPT_ID  = RCT.CASH_RECEIPT_ID
AND HIST.ORG_ID           = RCT.ORG_ID
  --AND HIST.EVENT_ID = XAH.EVENT_ID
  --AND XAH.AE_HEADER_ID = XAL.AE_HEADER_ID
  --AND XAL.ACCOUNTING_CLASS_CODE = 'CASH'
AND HIST.CURRENT_RECORD_FLAG = 'Y'
  --- AND RCT.CUSTOMER_SITE_USE_ID IS NULL
AND APS.AMOUNT_DUE_REMAINING != 0
AND APS.STATUS                = 'OP'
AND HCA.CUSTOMER_TYPE         = 'R'
  --AND xah.gl_transfer_date IS NOT NULL
AND c.bu_id                 = rct.org_id
AND gcc.code_combination_id = HIST.ACCOUNT_CODE_COMBINATION_ID
--AND  GCC.segment1         IN ('V833', 'V834')
AND fvv.flex_value_set_id   = fvs.flex_value_set_id
AND fvs.flex_value_set_name = 'CCL_COMPANY_CODES'
AND fvv.flex_value          = gcc.segment1
and  fvv.ATTRIBUTE9 is not null --BU_Number
and  fvv.ATTRIBUTE7 is not null -- BCOCODE
and  fvv.ATTRIBUTE2 is not null -- GECARS_IC
and fvv.ATTRIBUTE1 = 'Y'  -- GECARS_Extract enabled flag	
and  fvv.ATTRIBUTE8  = 'L' -- GECARS type 'L' = 'Lite', 'C'= 'Classic', 'P' = 'Prime'
AND flex.coa_id                  = gll.chart_of_accounts_id
AND gll.ledger_id                = rct.set_of_books_id
AND rctt.CUST_TRX_TYPE_SEQ_ID(+) = aps.CUST_TRX_TYPE_SEQ_ID
AND hp.party_id                  = hca.party_id
AND hp.party_id                  = hps.party_id
AND hps.party_site_id            = hcas.party_site_id
AND hcas.CUST_ACCOUNT_ID         = HCA.CUST_ACCOUNT_ID
AND hps.location_id              = hl.location_id
AND hCaS.CUST_ACCT_SITE_ID       = hcsu.CUST_ACCT_SITE_ID
AND hcsU.set_id                  = hCaS.set_id
AND hcsU.SITE_USE_CODE           = 'BILL_TO'
AND hCA.customer_type            = 'R'
AND hCaS.status                  ='A'
AND aps.ACCTD_AMOUNT_DUE_REMAINING <> 0
and  hcsu.PRIMARY_FLAG = 'Y'
--Added below code for REL-028	added nvl by om on 16 mar 2020							
       AND nvl(rctt.name,1) NOT IN (SELECT lookup_code FROM FND_LOOKUP_VALUES
                                    WHERE lookup_type='CIRRUSAR_GECARS_TRX_EXCLUDE'
									AND language='US'
									AND TRUNC (SYSDATE) BETWEEN NVL (start_date_active, TRUNC (SYSDATE)) AND NVL (end_date_active, TRUNC (SYSDATE))
                                    AND enabled_flag = 'Y')
--Added above code for REL-028
)) KEY from dual) GECARS_Count, 
   KEY,
   InvoiceBCO,
	InvoiceBusinessCustomerNumber,
	InvoiceARType,
	InvoiceTC,
	InvoiceDate,
	InvoiceNO,
	InvoiceProjectNo, 
	InvoiceDueDate, 
	InvoiceInitTerm,
    InvoiceAmount,
	InvoiceTransAmount,
	InvoiceMemoAmt,
	InvoiceCurrency,
	InvoiceBaseCurrency,
	InvoiceMemoCurrency,
	InvoiceARCNO,
	InvoiceDRMemo, 
	InvoiceRefNo,
	InvoiceDeptNo,
	InvoiceSalesMan,
	InvoiceBillICNO, 
	InvoiceReqNO,
	InvoiceBillLading, 
	InvoicePONumber,
	InvoiceNotifyDate,
	InvoiceCIEDate,
	InvoiceOrderSORID,
	InvoiceItemNO, 
	InvoiceIC, 
	InvoiceItemCostCenter,
	InvoiceItemAmount,
	InvoiceItemTRANAmount,
	InvoiceVATAmount,
	InvoiceShipCountry,
	InvoiceBILLCountry,
	InvoiceBusinessSytemInvoiceID,
	InvoicePayment_Schedule, ----aps.payment_schedule_id
	FlexField1,
	FlexField2,
	FlexField3,
	FlexField4,
	FlexField5,
	FlexField6,
	FlexField7,
	FlexField8,
	FlexField9,
	FlexField10,
	FlexField11,
	FlexField12,
	LineFlexField1,
	LineFlexField2,
	LineFlexField3,
	LineFlexField4,
	LineFlexField5,
	LineFlexField6,
	LineFlexField7,
	LineFlexField8,
	LineFlexField9,
	LineFlexField10,
	LineFlexField11,
	LineFlexField12,
	InvoiceShipAddr1,
	InvoiceShipAddr2,
	InvoiceShipAddr3,
	InvoiceShipAddr4,
	InvoiceShipAddr5,
	InvoiceShipCity,
	InvoiceShipProv,
	InvoiceShipPostalCode,
	InvoiceCIG,
	InvoiceCUP,
	InvoiceCashCode,
	InvoiceCashComment,
	DBInvoiceShipAddr1,
	DBInvoiceShipAddr2,
	DBInvoiceShipAddr3,
	DBInvoiceShipAddr4,
	DBInvoiceShipAddr5,
	DBInvoiceShipCity,
	DBInvoiceShipProvince,
	DBInvoiceShipPostalCode
	from
(SELECT DISTINCT
       'KEY' KEY,
       FVV.ATTRIBUTE7 INVOICEBCO,
       (CASE
           WHEN LENGTH (HPS.PARTY_SITE_NUMBER) <= 12
           THEN
              HPS.PARTY_SITE_NUMBER
           WHEN     LENGTH (HPS.PARTY_SITE_NUMBER) > 12
                --AND C.BU_NAME NOT IN ('JP_AVI_V834_BU', 'JP_AVI_V833_BU')						--Commented as part of REL-037
				--Added the below code as part of REL-037
				AND C.BU_NAME NOT IN (SELECT lookup_code 
										FROM FND_LOOKUP_VALUES
									   WHERE lookup_type='CIRRUSAR_GECARS_BUEXCEPTIONS'
										 AND language='US'
										 AND TRUNC (SYSDATE) BETWEEN NVL (start_date_active, TRUNC (SYSDATE)) AND NVL (end_date_active, TRUNC (SYSDATE))
										 AND enabled_flag = 'Y')
				--Added the above code as part of REL-037
           THEN
              SUBSTR (HPS.PARTY_SITE_NUMBER, -12)
           WHEN C.BU_NAME = 'JP_AVI_V834_BU'
           THEN
                 SUBSTR (HPS.PARTY_SITE_NUMBER, 1, 4)
              || SUBSTR (HPS.PARTY_SITE_NUMBER, -5)
           WHEN C.BU_NAME = 'JP_AVI_V833_BU'
           THEN
                 SUBSTR (HPS.PARTY_SITE_NUMBER, 1, 4)
              || SUBSTR (HPS.PARTY_SITE_NUMBER, -5)
           ELSE
              HPS.PARTY_SITE_NUMBER
        END)
          INVOICEBUSINESSCUSTOMERNUMBER,
       DECODE (RCTT.ATTRIBUTE3, 'Y', '101', '30') INVOICEARTYPE,
       DECODE (APS.CLASS,
               'INV', '010',
               'DM', '010',
               'CM', '012',
               'PMT', '013')
          INVOICETC,
       RCT.TRX_DATE INVOICEDATE,
       RCT.TRX_NUMBER INVOICENO,
       NULL INVOICEPROJECTNO,
       APS.DUE_DATE INVOICEDUEDATE,
       '814' INVOICEINITTERM,
       APS.AMOUNT_DUE_REMAINING INVOICEAMOUNT,
       --aps.ACCTD_AMOUNT_DUE_REMAINING  InvoiceTransAmount,
       CASE
          WHEN APS.INVOICE_CURRENCY_CODE <> FVV.ATTRIBUTE5
          THEN
             (SELECT ROUND (GDR.CONVERSION_RATE * APS.AMOUNT_DUE_REMAINING,
                            2)
                FROM GL_DAILY_RATES GDR, GL_DAILY_CONVERSION_TYPES GDCT
               WHERE     1 = 1
                     AND TRUNC (GDR.CONVERSION_DATE) = TRUNC (APS.GL_DATE)
                     AND GDR.CONVERSION_TYPE = GDCT.CONVERSION_TYPE
                     AND GDCT.USER_CONVERSION_TYPE = 'MOR'
                     AND GDCT.PIVOT_CURRENCY_CODE = 'USD'
                     AND GDR.TO_CURRENCY = FVV.ATTRIBUTE5
                     AND GDR.FROM_CURRENCY = APS.INVOICE_CURRENCY_CODE)
          WHEN FVV.ATTRIBUTE5 IS NULL
          THEN
             APS.ACCTD_AMOUNT_DUE_REMAINING
          ELSE
             APS.AMOUNT_DUE_REMAINING
       END
          INVOICETRANSAMOUNT,
       NULL INVOICEMEMOAMT,
       RCT.INVOICE_CURRENCY_CODE INVOICECURRENCY,
       --gll.currency_code InvoiceBaseCurrency,
       NVL (FVV.ATTRIBUTE5, GLL.CURRENCY_CODE) INVOICEBASECURRENCY,
       NULL INVOICEMEMOCURRENCY,
       NULL INVOICEARCNO,
       NULL INVOICEDRMEMO,
       NULL INVOICEREFNO,
       RCT.ORG_ID INVOICEDEPTNO,
       SUBSTR (HZP.PARTY_NAME, 1, 9) INVOICESALESMAN,
       FVV.ATTRIBUTE7 INVOICEBILLICNO,
       NULL INVOICEREQNO,
       NULL INVOICEBILLLADING,
	   -- REL-030  commented out -- NULL INVOICEPONUMBER,
       rct.purchase_order  INVOICEPONUMBER, -- REL-030 added
       NULL INVOICENOTIFYDATE,
       NULL INVOICECIEDATE,
       NULL INVOICEORDERSORID,
       '1' INVOICEITEMNO,
       FVV.ATTRIBUTE2 INVOICEIC,
       '111111' INVOICEITEMCOSTCENTER,
       NULL INVOICEITEMAMOUNT,
       NULL INVOICEITEMTRANAMOUNT,
       0 INVOICEVATAMOUNT,
       TRIM (SUBSTR (HL.COUNTRY, 1, 2)) INVOICESHIPCOUNTRY,
       TRIM (SUBSTR (DECODE (HL.STATE, 'PR', 'PR', HL.COUNTRY), 1, 2))
          INVOICEBILLCOUNTRY,
       RCT.CUSTOMER_TRX_ID INVOICEBUSINESSSYTEMINVOICEID,
       APS.PAYMENT_SCHEDULE_ID INVOICEPAYMENT_SCHEDULE, ----aps.payment_schedule_id
       NULL FLEXFIELD1,
       SUBSTR (RCTT.NAME, 1, 15) FLEXFIELD2,
       (SELECT TO_CHAR (SALES_ORDER_DATE, 'DD-MON-YYYY')
          FROM RA_CUSTOMER_TRX_LINES_ALL
         WHERE ROWNUM = 1 AND CUSTOMER_TRX_ID = RCT.CUSTOMER_TRX_ID)
          FLEXFIELD3,
       NULL FLEXFIELD4,
       NULL FLEXFIELD5,
       NULL FLEXFIELD6,
       NULL FLEXFIELD7,
       NULL FLEXFIELD8,
       NULL FLEXFIELD9,
       NULL FLEXFIELD10,
       NULL FLEXFIELD11,
       NULL FLEXFIELD12,
       NULL LINEFLEXFIELD1,
       NULL LINEFLEXFIELD2,
       NULL LINEFLEXFIELD3,
       NULL LINEFLEXFIELD4,
       NULL LINEFLEXFIELD5,
       NULL LINEFLEXFIELD6,
       NULL LINEFLEXFIELD7,
       NULL LINEFLEXFIELD8,
       NULL LINEFLEXFIELD9,
       NULL LINEFLEXFIELD10,
       NULL LINEFLEXFIELD11,
       NULL LINEFLEXFIELD12,
       TRIM (
          SUBSTR (REPLACE (REPLACE ( (HL1.ADDRESS1), '"', NULL), ',', NULL),
                  1,
                  48))
          INVOICESHIPADDR1,
       TRIM (
          SUBSTR (REPLACE (REPLACE ( (HL1.ADDRESS2), '"', NULL), ',', NULL),
                  1,
                  48))
          INVOICESHIPADDR2,
       TRIM (
          SUBSTR (REPLACE (REPLACE ( (HL1.ADDRESS3), '"', NULL), ',', NULL),
                  1,
                  48))
          INVOICESHIPADDR3,
       TRIM (
          SUBSTR (REPLACE (REPLACE ( (HL1.ADDRESS4), '"', NULL), ',', NULL),
                  1,
                  48))
          INVOICESHIPADDR4,
       NULL INVOICESHIPADDR5,
       --hl1.CITY  InvoiceShipCity,
       (CASE
           WHEN     HL1.CITY IS NULL
                AND C.BU_NAME IN ('JP_AVI_V834_BU', 'JP_AVI_V833_BU')
           THEN
              'Tokyo'
           ELSE
              TRIM (
                 SUBSTR (
                    REPLACE (REPLACE ( (HL1.CITY), '"', NULL), ',', NULL),
                    1,
                    48))
        END)
          INVOICESHIPCITY,
       HL1.COUNTRY INVOICESHIPPROV,
       HL1.POSTAL_CODE INVOICESHIPPOSTALCODE,
       NULL INVOICECIG,
       NULL INVOICECUP,
       NULL INVOICECASHCODE,
       NULL INVOICECASHCOMMENT,
       NULL DBINVOICESHIPADDR1,
       NULL DBINVOICESHIPADDR2,
       NULL DBINVOICESHIPADDR3,
       NULL DBINVOICESHIPADDR4,
       NULL DBINVOICESHIPADDR5,
       NULL DBINVOICESHIPCITY,
       NULL DBINVOICESHIPPROVINCE,
       NULL DBINVOICESHIPPOSTALCODE
  FROM RA_CUSTOMER_TRX_ALL RCT,
       ---PER_ALL_PEOPLE_F papf, COMMENTED AS PER REQUIREMENT
       AR_PAYMENT_SCHEDULES_ALL APS,
       RA_CUST_TRX_TYPES_ALL RCTT,
       (  SELECT COUNT (1) CNT, ID_FLEX_NUM COA_ID
            FROM FND_ID_FLEX_SEGMENTS
           WHERE ID_FLEX_CODE = 'GL#'
        GROUP BY ID_FLEX_NUM) FLEX,
       RA_BATCH_SOURCES_ALL RBS,
       GL_LEDGERS GLL,
       HZ_CUST_ACCT_SITES_ALL HCAS,
       HZ_CUST_ACCOUNTS HCA,
       HZ_PARTY_SITES HPS,
       HZ_PARTIES HZP,
       HZ_LOCATIONS HL,
       HZ_CUST_SITE_USES_ALL HCSU,
       RA_CUST_TRX_LINE_GL_DIST_ALL RCTLG,
       ---  hz_parties hp1, commented as per required changes
       ---  hz_party_sites hps1, commented as per required changes
       --- hz_party_site_uses hpsu, commented as per required changes
       HZ_PARTIES HZP1,                                         ---Newly added
       HZ_PARTY_SITES HPS1,                                      --newly added
       HZ_CUST_ACCOUNTS HCA1,                                    --newly added
       HZ_CUST_ACCT_SITES_ALL HCAS1,                            -- newly added
       HZ_CUST_SITE_USES_ALL HCSU1,                              --newly added
       HZ_LOCATIONS HL1,                                        ---newly added
       GL_CODE_COMBINATIONS GCC,
       FND_FLEX_VALUE_SETS FVS,
       FND_FLEX_VALUES FVV,
       XLA_AE_HEADERS XAH,
       FUN_ALL_BUSINESS_UNITS_V C
WHERE     HCA.CUST_ACCOUNT_ID = RCT.BILL_TO_CUSTOMER_ID
       AND RCTLG.EVENT_ID = XAH.EVENT_ID
       AND C.BU_ID = RCT.ORG_ID
       --AND  GCC.segment1         IN ('V833', 'V834')
       AND FVV.FLEX_VALUE_SET_ID = FVS.FLEX_VALUE_SET_ID
       AND FVS.FLEX_VALUE_SET_NAME = 'CCL_COMPANY_CODES'
       AND FVV.FLEX_VALUE = GCC.SEGMENT1
       AND FVV.ATTRIBUTE9 IS NOT NULL                              --BU_Number
       AND FVV.ATTRIBUTE7 IS NOT NULL                               -- BCOCODE
       AND FVV.ATTRIBUTE2 IS NOT NULL                             -- GECARS_IC
       AND FVV.ATTRIBUTE1 = 'Y'                 -- GECARS_Extract enabled flag
       AND FVV.ATTRIBUTE8 = 'L' -- GECARS type 'L' = 'Lite', 'C'= 'Classic', 'P' = 'Prime'
       AND XAH.GL_TRANSFER_DATE IS NOT NULL
       AND HZP.PARTY_ID = HCA.PARTY_ID
       AND HZP.PARTY_ID = HPS.PARTY_ID
       AND HPS.PARTY_SITE_ID = HCAS.PARTY_SITE_ID
       AND HCAS.CUST_ACCOUNT_ID = HCA.CUST_ACCOUNT_ID
       AND HPS.LOCATION_ID = HL.LOCATION_ID
       AND HCAS.CUST_ACCT_SITE_ID = HCSU.CUST_ACCT_SITE_ID
       AND HCSU.SET_ID = HCAS.SET_ID
       AND HCSU.SITE_USE_CODE = 'BILL_TO'
       AND HCA.CUSTOMER_TYPE = 'R'
       AND HCAS.STATUS = 'A'
       AND APS.CUSTOMER_TRX_ID = RCT.CUSTOMER_TRX_ID
       AND RCTT.CUST_TRX_TYPE_SEQ_ID = RCT.CUST_TRX_TYPE_SEQ_ID
       AND HCA1.CUST_ACCOUNT_ID = RCT.BILL_TO_CUSTOMER_ID
       AND FLEX.COA_ID = GLL.CHART_OF_ACCOUNTS_ID
       AND GLL.LEDGER_ID = RCT.SET_OF_BOOKS_ID
       AND GCC.CODE_COMBINATION_ID = RCTLG.CODE_COMBINATION_ID
       AND RCTLG.ACCOUNT_CLASS = 'REC'
       AND RCTLG.CUSTOMER_TRX_ID = RCT.CUSTOMER_TRX_ID
       AND GLL.LEDGER_ID = RCT.SET_OF_BOOKS_ID
       AND RBS.BATCH_SOURCE_SEQ_ID = RCT.BATCH_SOURCE_SEQ_ID
       --AND hps1.location_id        =hl1.location_id     commented as per required changes
       --AND hpsu.site_use_type      = 'SHIP_TO'         commented as per required changes
       --AND hpsu.party_site_use_id  =rct.ship_to_party_site_use_id  commented as per required changes
       --AND hps1.party_site_id      = hpsu.party_site_id     commented as per required changes
       --AND hps1.party_id           =hp1.party_id            commented as per required changes
       -------- and hcas.CUST_ACCT_SITE_ID = rct.bill_to_address_id    commented as per required changes
       ---AND hcsu.site_use_id=rct.bill_to_site_use_id
       AND HZP1.PARTY_ID = HCA1.PARTY_ID                         --NEWLY ADDED
       AND HZP1.PARTY_ID = HPS1.PARTY_ID                         --NEWLY ADDED
       AND HPS1.PARTY_SITE_ID = HCAS1.PARTY_SITE_ID             ---NEWLY ADDED
       AND HCAS1.CUST_ACCOUNT_ID = HCA1.CUST_ACCOUNT_ID          --NEWLY ADDED
       AND HPS1.LOCATION_ID = HL1.LOCATION_ID                    --NEWLY ADDED
       AND HCAS1.CUST_ACCT_SITE_ID = HCSU1.CUST_ACCT_SITE_ID     --NEWLY ADDED
       AND HCSU1.SET_ID = HCAS1.SET_ID                           --NEWLY ADDED
       AND HCSU1.SITE_USE_CODE = 'SHIP_TO'                       --NEWLY ADDED
       AND HCA1.CUSTOMER_TYPE = 'R'                              --NEWLY ADDED
       AND HCAS1.STATUS = 'A'                                    --NEWLY ADDED
       AND NVL (RCT.ATTRIBUTE1, 'Y') != 'N'
       AND APS.ACCTD_AMOUNT_DUE_REMAINING <> 0
       and  hcsu.PRIMARY_FLAG = 'Y' ---COMMENTED AS PER REQUIREMENT
       AND HCSU1.PRIMARY_FLAG = 'Y'                 --ADDED AS PER REQUIREMENT
--Added below code for REL-028								
       AND rctt.name NOT IN (SELECT lookup_code FROM FND_LOOKUP_VALUES
                                    WHERE lookup_type='CIRRUSAR_GECARS_TRX_EXCLUDE'
									AND language='US'
									AND TRUNC (SYSDATE) BETWEEN NVL (start_date_active, TRUNC (SYSDATE)) AND NVL (end_date_active, TRUNC (SYSDATE))
                                    AND enabled_flag = 'Y')
--Added above code for REL-028
union 
SELECT DISTINCT 'KEY' KEY, 
  fvv.ATTRIBUTE7 InvoiceBCO,
  (CASE
    WHEN LENGTH(hps.PARTY_SITE_NUMBER) <=12     THEN hps.PARTY_SITE_NUMBER
    --WHEN LENGTH(hps.PARTY_SITE_NUMBER) >12 and c.BU_NAME not in ('JP_AVI_V834_BU' , 'JP_AVI_V833_BU')  THEN SUBSTR(hps.PARTY_SITE_NUMBER,-12)						--Commented as part of REL-037
	--Added the below code as part of Rel-037
	WHEN LENGTH(hps.PARTY_SITE_NUMBER) >12 and c.BU_NAME not in ( SELECT lookup_code 
																	FROM FND_LOOKUP_VALUES
																   WHERE lookup_type='CIRRUSAR_GECARS_BUEXCEPTIONS'
																	 AND language='US'
																	 AND TRUNC (SYSDATE) BETWEEN NVL (start_date_active, TRUNC (SYSDATE)) AND NVL (end_date_active, TRUNC (SYSDATE))
																	 AND enabled_flag = 'Y')
	THEN SUBSTR(hps.PARTY_SITE_NUMBER,-12)
	--Added the above code as part of Rel-037
	WHEN c.BU_NAME  = 'JP_AVI_V834_BU' THEN  SUBSTR(hps.PARTY_SITE_NUMBER,1,4)||SUBSTR(hps.PARTY_SITE_NUMBER,-5)
	WHEN c.BU_NAME  = 'JP_AVI_V833_BU' THEN  SUBSTR(hps.PARTY_SITE_NUMBER,1,4)||SUBSTR(hps.PARTY_SITE_NUMBER,-5)
    ELSE hps.PARTY_SITE_NUMBER
  END) InvoiceBusinessCustomerNumber,
  DECODE(rctt.attribute3,'Y','101','30') InvoiceARType,
   DECODE(APS.CLASS, 'INV', '010', 'DM', '010', 'CM', '012', 'PMT', '013') InvoiceTC,
   aps.trx_date InvoiceDate,
     to_char(RCT.CASH_RECEIPT_ID) InvoiceNO, --  RCT.RECEIPT_NUMBER  - To avoid dupicate adde CASH_RECEIPT_ID,
  NULL InvoiceProjectNo,
 aps.DUE_DATE InvoiceDueDate,
  '814' InvoiceInitTerm,
  aps.AMOUNT_DUE_REMAINING      InvoiceAmount,
  --aps.ACCTD_AMOUNT_DUE_REMAINING  InvoiceTransAmount,
  CASE 
	WHEN aps.INVOICE_CURRENCY_CODE <>  fvv.ATTRIBUTE5 then
		(select ROUND(GDR.CONVERSION_RATE*aps.AMOUNT_DUE_REMAINING ,2) 
			from GL_DAILY_RATES GDR,
				GL_DAILY_CONVERSION_TYPES GDCT
			where 1=1 
			and trunc(GDR.CONVERSION_DATE ) =   trunc(aps.GL_DATE)
			AND GDR.CONVERSION_TYPE = GDCT.CONVERSION_TYPE
			AND GDCT.USER_CONVERSION_TYPE = 'MOR'
			AND GDCT.PIVOT_CURRENCY_CODE = 'USD'
			AND GDR.TO_CURRENCY = fvv.ATTRIBUTE5
			AND GDR.FROM_CURRENCY=  aps.INVOICE_CURRENCY_CODE) 
	WHEN fvv.ATTRIBUTE5 is null then aps.ACCTD_AMOUNT_DUE_REMAINING
	else aps.AMOUNT_DUE_REMAINING 
End InvoiceTransAmount,
  NULL InvoiceMemoAmt,
  APS.INVOICE_CURRENCY_CODE InvoiceCurrency,  
  --gll.currency_code InvoiceBaseCurrency,
  nvl(fvv.ATTRIBUTE5,gll.currency_code) InvoiceBaseCurrency,
  NULL InvoiceMemoCurrency,
  NULL InvoiceARCNO,
  NULL InvoiceDRMemo,
  NULL InvoiceRefNo,
  rct.org_id InvoiceDeptNo,
  SUBSTR(hp.party_name,1,9) InvoiceSalesMan,
  fvv.ATTRIBUTE7 InvoiceBillICNO,
  NULL InvoiceReqNO,
  NULL InvoiceBillLading,
  NULL InvoicePONumber,
  NULL InvoiceNotifyDate,
  NULL InvoiceCIEDate,
  NULL InvoiceOrderSORID,
  '1' InvoiceItemNO,
  fvv.attribute2 InvoiceIC,
  '111111' InvoiceItemCostCenter,
  NULL InvoiceItemAmount, 
  NULL InvoiceItemTRANAmount,
  0 InvoiceVATAmount,
  TRIM(SUBSTR(hl.COUNTRY,1,2)) InvoiceShipCountry,
  TRIM(SUBSTR(DECODE(hl.STATE,'PR','PR',hl.COUNTRY),1,2)) InvoiceBILLCountry,
  RCT.CASH_RECEIPT_ID InvoiceBusinessSytemInvoiceID,
  aps.payment_schedule_id InvoicePayment_Schedule,
   NULL FlexField1,
  SUBSTR(rctt.name,1,15) FlexField2,
  Null  FlexField3,
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
  TRIM(SUBSTR(REPLACE(REPLACE((hl.ADDRESS1),'"',NULL),',',NULL),1,48)) InvoiceShipAddr1,
  TRIM(SUBSTR(REPLACE(REPLACE((hl.ADDRESS2),'"',NULL),',',NULL),1,48)) InvoiceShipAddr2,
  TRIM(SUBSTR(REPLACE(REPLACE((hl.ADDRESS3),'"',NULL),',',NULL),1,48)) InvoiceShipAddr3,
  TRIM(SUBSTR(REPLACE(REPLACE((hl.ADDRESS4),'"',NULL),',',NULL),1,48)) InvoiceShipAddr4,
  NULL InvoiceShipAddr5,
  --hl.CITY InvoiceShipCity,
  (CASE 
       WHEN hl.CITY is null and  c.BU_NAME  in ('JP_AVI_V834_BU' , 'JP_AVI_V833_BU') then 'Tokyo'
	   else TRIM(SUBSTR(REPLACE(REPLACE((hl.CITY),'"',NULL),',',NULL),1,48))
	   End) InvoiceShipCity,
  hl.COUNTRY InvoiceShipProv,
  hl.POSTAL_CODE InvoiceShipPostalCode,
  NULL InvoiceCIG,
  NULL InvoiceCUP,  
  NULL InvoiceCashCode,
  NULL InvoiceCashComment,
  NULL DBInvoiceShipAddr1,
  NULL DBInvoiceShipAddr2,
  NULL DBInvoiceShipAddr3,
  NULL DBInvoiceShipAddr4,
  NULL DBInvoiceShipAddr5,
  NULL DBInvoiceShipCity,
  NULL DBInvoiceShipProvince,
  NULL DBInvoiceShipPostalCode
FROM AR_CASH_RECEIPTS_ALL RCT,
  HZ_CUST_ACCOUNTS hca,
  HZ_PARTIES HP,
  HZ_PARTY_SITES hps,
  HZ_CUST_ACCT_SITES_ALL hcas,
  HZ_LOCATIONS hl,
  HZ_CUST_SITE_USES_ALL hcsu,
  AR_PAYMENT_SCHEDULES_ALL APS,
  AR_CASH_RECEIPT_HISTORY_ALL HIST,
  --XLA_AE_HEADERS XAH ,
  --XLA_AE_LINES XAL
  fun_all_business_units_v c,
  GL_CODE_COMBINATIONS gcc,
  fnd_flex_value_sets fvs,
  fnd_flex_values fvv,
  (SELECT COUNT(1) cnt,
    id_flex_num coa_id
  FROM FND_ID_FLEX_SEGMENTS
  WHERE id_flex_code = 'GL#'
  GROUP BY id_flex_num
  ) flex,
  GL_LEDGERS gll,
  RA_CUST_TRX_TYPES_ALL rctt
WHERE 1=1
  -- and  RCT.RECEIPT_NUMBER  ='ANA-Unapplied Receipt'
AND RCT.PAY_FROM_CUSTOMER = HCA.CUST_ACCOUNT_ID
AND HCA.PARTY_ID          = HP.PARTY_ID
AND APS.CASH_RECEIPT_ID   = RCT.CASH_RECEIPT_ID
AND APS.ORG_ID            = RCT.ORG_ID
AND HIST.CASH_RECEIPT_ID  = RCT.CASH_RECEIPT_ID
AND HIST.ORG_ID           = RCT.ORG_ID
  --AND HIST.EVENT_ID = XAH.EVENT_ID
  --AND XAH.AE_HEADER_ID = XAL.AE_HEADER_ID
  --AND XAL.ACCOUNTING_CLASS_CODE = 'CASH'
AND HIST.CURRENT_RECORD_FLAG = 'Y'
  --- AND RCT.CUSTOMER_SITE_USE_ID IS NULL
AND APS.AMOUNT_DUE_REMAINING != 0
AND APS.STATUS                = 'OP'
AND HCA.CUSTOMER_TYPE         = 'R'
  --AND xah.gl_transfer_date IS NOT NULL
AND c.bu_id                 = rct.org_id
AND gcc.code_combination_id = HIST.ACCOUNT_CODE_COMBINATION_ID
--AND  GCC.segment1         IN ('V833', 'V834')
AND fvv.flex_value_set_id   = fvs.flex_value_set_id
AND fvs.flex_value_set_name = 'CCL_COMPANY_CODES'
AND fvv.flex_value          = gcc.segment1
and  fvv.ATTRIBUTE9 is not null --BU_Number
and  fvv.ATTRIBUTE7 is not null -- BCOCODE
and  fvv.ATTRIBUTE2 is not null -- GECARS_IC
and fvv.ATTRIBUTE1 = 'Y'  -- GECARS_Extract enabled flag	
and  fvv.ATTRIBUTE8  = 'L' -- GECARS type 'L' = 'Lite', 'C'= 'Classic', 'P' = 'Prime'
AND flex.coa_id                  = gll.chart_of_accounts_id
AND gll.ledger_id                = rct.set_of_books_id
AND rctt.CUST_TRX_TYPE_SEQ_ID(+) = aps.CUST_TRX_TYPE_SEQ_ID
AND hp.party_id                  = hca.party_id
AND hp.party_id                  = hps.party_id
AND hps.party_site_id            = hcas.party_site_id
AND hcas.CUST_ACCOUNT_ID         = HCA.CUST_ACCOUNT_ID
AND hps.location_id              = hl.location_id
AND hCaS.CUST_ACCT_SITE_ID       = hcsu.CUST_ACCT_SITE_ID
AND hcsU.set_id                  = hCaS.set_id
AND hcsU.SITE_USE_CODE           = 'BILL_TO'
AND hCA.customer_type            = 'R'
AND hCaS.status                  ='A'
AND aps.ACCTD_AMOUNT_DUE_REMAINING <> 0
and  hcsu.PRIMARY_FLAG = 'Y'
--Added below code for REL-028								
       AND nvl(rctt.name,1) NOT IN (SELECT lookup_code FROM FND_LOOKUP_VALUES
                                    WHERE lookup_type='CIRRUSAR_GECARS_TRX_EXCLUDE'
									AND language='US'
									AND TRUNC (SYSDATE) BETWEEN NVL (start_date_active, TRUNC (SYSDATE)) AND NVL (end_date_active, TRUNC (SYSDATE))
                                    AND enabled_flag = 'Y')
--Added above code for REL-028
)