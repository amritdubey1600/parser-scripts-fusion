SELECT  /*+ leading(ract) cradinality(ract 1000) */     
		RACT.CUSTOMER_TRX_ID                    CUSTOMER_TRX_ID,
RACT.TRX_NUMBER Invoice_Nu,
        LOOK1.MEANING                           TRANSACTION_CLASS,
        DECODE(RACT.COMPLETE_FLAG,
                'Y', 'Complete',
                       'Incomplete')                     COMPLETE,
        DECODE(RACTT.POST_TO_GL,
                'Y', 'Posted to GL',
                       'Unposted')                     POSTABLE,
decode(RAC_BILL.customer_type,'R','External','Internal') Customer_type,
--------(select attribute7 from  fnd_flex_values where flex_value =  GLCC_RCVBL.segment1) Functional_Currency,
        LOOK5.MEANING                           CREDIT_METHOD_FOR_RULES,
        LOOK6.MEANING                   CREDIT_METHOD_FOR_INSTALLMENTS,
        RACT.TRX_NUMBER                 INVOICE_NUMBER,
        RACT.BILL_TO_CUSTOMER_ID                BILL_TO_CUSTOMER_ID,
        RAC_BILL.ACCOUNT_NUMBER         BILL_TO_CUSTOMER_NUMBER,
        SUBSTRB(RAC_BILL_PARTY.PARTY_NAME,1,50)         BILL_TO_CUSTOMER_NAME,
        RAAD_BILL_LOC.ADDRESS1                  BILL_TO_ADDRESS1,
        RAAD_BILL_LOC.ADDRESS2                  BILL_TO_ADDRESS2,
        RAAD_BILL_LOC.ADDRESS3                  BILL_TO_ADDRESS3,
        RAAD_BILL_LOC.ADDRESS4                  BILL_TO_ADDRESS4,
        RAAD_BILL_LOC.CITY                              BILL_TO_CITY,
        NVL(RAAD_BILL_LOC.PROVINCE,
                RAAD_BILL_LOC.STATE)                    BILL_TO_STATE,
        TERR_BILL.TERRITORY_SHORT_NAME          BILL_TO_COUNTRY,
        RAAD_BILL_LOC.POSTAL_CODE                       BILL_TO_POSTAL_CODE,
        SUBSTRB(RACO_BILL_PARTY.PERSON_LAST_NAME,1,50)||' '||
                SUBSTRB(RACO_BILL_PARTY.PERSON_FIRST_NAME,1,40)         BILL_TO_CONTACT_NAME,
        RACT.SHIP_TO_CUSTOMER_ID                SHIP_TO_CUSTOMER_ID,
        null         SHIP_TO_CUSTOMER_NUMBER,
        SUBSTRB(RAC_SHIP_PARTY.PARTY_NAME,1,50) SHIP_TO_CUSTOMER_NAME,
        RAAD_SHIP_LOC.ADDRESS1                  SHIP_TO_ADDRESS1,
        RAAD_SHIP_LOC.ADDRESS2                  SHIP_TO_ADDRESS2,
        RAAD_SHIP_LOC.ADDRESS3                  SHIP_TO_ADDRESS3,
        RAAD_SHIP_LOC.ADDRESS4                  SHIP_TO_ADDRESS4,
        RAAD_SHIP_LOC.CITY                              SHIP_TO_CITY,
        NVL(RAAD_SHIP_LOC.PROVINCE,
                RAAD_SHIP_LOC.STATE )                   SHIP_TO_STATE,
        TERR_SHIP.TERRITORY_SHORT_NAME          SHIP_TO_COUNTRY,
        RAAD_SHIP_LOC.POSTAL_CODE                       SHIP_TO_POSTAL_CODE,
        SUBSTRB(RACO_SHIP_PARTY.PERSON_LAST_NAME,1,50)||' '||
                SUBSTRB(RACO_SHIP_PARTY.PERSON_FIRST_NAME,1,40)         SHIP_TO_CONTACT_NAME,
        SUBSTRB(RAC_SOLD_PARTY.PARTY_NAME,1,50)         SOLD_TO_CUSTOMER_NAME,
        null         SOLD_TO_CUSTOMER_NUMBER,
        RACT.SOLD_TO_CUSTOMER_ID                SOLD_TO_CUSTOMER_ID,
        RACT.REMIT_TO_ADDRESS_ID                REMIT_TO_ADDRESS_ID,
        RAAD_REMIT_LOC.ADDRESS1         REMIT_TO_ADDRESS1,
        RAAD_REMIT_LOC.ADDRESS2         REMIT_TO_ADDRESS2,
        RAAD_REMIT_LOC.ADDRESS3         REMIT_TO_ADDRESS3,
        RAAD_REMIT_LOC.ADDRESS4         REMIT_TO_ADDRESS4,
  RAAD_REMIT_LOC.CITY                     REMIT_TO_CITY,
        RAAD_REMIT_LOC.STATE                    REMIT_TO_STATE,
        RAAD_REMIT_LOC.POSTAL_CODE              REMIT_TO_POSTAL_CODE,
        TERR_REMIT.TERRITORY_SHORT_NAME REMIT_TO_COUNTRY,
        RACT.INTERFACE_HEADER_CONTEXT           FLEX_CONTEXT,
        To_Char(RACT.TRX_DATE,'YYYY-MM-DD')                           INVOICE_DATE,
        LOOK3.MEANING                           INVOICE_STATUS,
        To_Char(GL_DIST_DATE.GL_DATE,'YYYY-MM-DD')                    GL_DATE,
        GL_DIST_DATE.AMOUNT                     CREDITED_AMOUNT,
        To_Char(ARPS.DUE_DATE,'YYYY-MM-DD')                           DUE_DATE,
        To_Char(RACT.LAST_UPDATE_DATE,'YYYY-MM-DD')                   LAST_UPDATE_DATE,
        RACT.LAST_UPDATED_BY                    LAST_UPDATED_BY, 
        To_Char(RACT.CREATION_DATE,'YYYY-MM-DD')                      CREATION_DATE,
        RACT.CREATED_BY	                        CREATED_BY,
        RACT.LAST_UPDATE_LOGIN                  LAST_UPDATE_LOGIN,
        To_Char(RACT.START_DATE_COMMITMENT,'YYYY-MM-DD')              START_DATE,
        To_Char(RACT.END_DATE_COMMITMENT,'YYYY-MM-DD')                END_DATE,
        RACT.INVOICE_CURRENCY_CODE              CURRENCY_tr,
        To_Char(RACT.EXCHANGE_DATE,'YYYY-MM-DD')                      EXCHANGE_DATE,
        nvl(RACT.EXCHANGE_RATE,1)                      EXCHANGE_RATE,
        RACT.EXCHANGE_RATE_TYPE                 EXCHANGE_RATE_TYPE,
        DECODE(GL_DIST_DATE.ACCOUNT_SET_FLAG,
                'Y', '', null)    RECEIVABLES_ACCOUNT,
        RACTT.TYPE                              TRANSACTION_TYPE_CODE,
        RACTT.NAME                              TRANSACTION_TYPE_NAME,
Decode(RAC_BILL.customer_type,'R','0',Substr(RAAD_BILL_PS.Party_site_number, 1,6))  TO_BUC,
Decode(RAC_BILL.customer_type,'R','0',substr(RACTT.NAME,1,6))                      From_BUC,
        RABS.NAME                               BATCH_SOURCE_NAME,
        --  SOA.NAME                               AGREEMENT_NAME,
        RAT.NAME                                TERM_NAME,
        RAS.NAME                                PRIMARY_SALESPERSON,
        null                      TERRITORY,
        RACT.PURCHASE_ORDER                     PO_NUMBER,
        RACT.PURCHASE_ORDER_REVISION            PO_REVISION,
        To_Char(RACT.PURCHASE_ORDER_DATE,'YYYY-MM-DD')                PO_DATE,                   
        RACT.INITIAL_CUSTOMER_TRX_ID            COMMITMENT_NUM,
        RACT_COMM.TRX_NUMBER                    COMM_NUMBER,
        LOOK2.MEANING                           PRINTING_OPTION,
        RACT.INTERNAL_NOTES                     SPECIAL_INSTRUCTIONS,
    /*    DECODE(RACTT.ACCOUNTING_AFFECT_FLAG,
                'Y', :YES_MEANING, :NO_MEANING) OPEN_RECEIVABLE,*/
        RACT.COMMENTS                           COMMENTS,
        RACT.DOC_SEQUENCE_VALUE         DOCUMENT_NUMBER,
        RACT.PREVIOUS_CUSTOMER_TRX_ID           REL_RACT,
        RAR.NAME                                INVOICING_RULE,
        ARRM.NAME                               RECEIPT_METHOD,
--decode(apba.instrument_type,'BANKACCOUNT',bk.bank_Account_name,'CREDITCARD',apba.card_issuer_name,'DEBITCARD',apba.card_issuer_name,null) CUSTOMER_BANK_ACCOUNT, -- rrajarap
decode(apba.instrument_type,'BANKACCOUNT',bkt_party.party_name,'CREDITCARD',apba.card_issuer_name,'DEBITCARD',apba.card_issuer_name,null) CUSTOMER_BANK_ACCOUNT,
decode(apba.instrument_type,'BANKACCOUNT',apba.account_number,'CREDITCARD',apba.card_number,'DEBITCARD',apba.card_number,null) CUSTOMER_BANK_NUM,
        RACT1.TRX_NUMBER                        CROSS_REF_NUMBER,
        RACT.PRIMARY_RESOURCE_SALESREP_ID                 PRIMARY_SALESREP_ID,     /*rchandan for fusion*/
        RACT.SHIP_VIA                           SHIP_VIA,
        --ORGF.DESCRIPTION                        FREIGHT_CARRIER,
		null			                        FREIGHT_CARRIER,
        RACT.FOB_POINT                          FOB_POINT,
        LOOK4.MEANING                           FOB_POINT_MEANING,
        RACT.WAYBILL_NUMBER                     Shipping_References,
  To_Char(RACT.SHIP_DATE_ACTUAL,'YYYY-MM-DD')                   SHIP_DATE,
        -----------------------------------------------------lp_query_show_bill cons_bill_number,
	AR_ARXTDR_XMLP_PKG.bill_to_address5formula(RAAD_BILL_LOC.CITY, NVL ( RAAD_BILL_LOC.PROVINCE , RAAD_BILL_LOC.STATE ), RAAD_BILL_LOC.POSTAL_CODE, TERR_BILL.TERRITORY_SHORT_NAME) BILL_TO_ADDRESS5,
	AR_ARXTDR_XMLP_PKG.ship_to_address5formula(RAAD_SHIP_LOC.CITY, NVL ( RAAD_SHIP_LOC.PROVINCE , RAAD_SHIP_LOC.STATE ), RAAD_SHIP_LOC.POSTAL_CODE, TERR_SHIP.TERRITORY_SHORT_NAME) SHIP_TO_ADDRESS5,

	AR_ARXTDR_XMLP_PKG.d_sold_toformula(null,SUBSTRB(RAC_SOLD_PARTY.PARTY_NAME,1,50)) D_SOLD_TO,
	AR_ARXTDR_XMLP_PKG.d_remit_toformula(RAAD_REMIT_LOC.ADDRESS1, RAAD_REMIT_LOC.ADDRESS2, RAAD_REMIT_LOC.ADDRESS3, RAAD_REMIT_LOC.ADDRESS4, RAAD_REMIT_LOC.CITY, RAAD_REMIT_LOC.STATE, RAAD_REMIT_LOC.POSTAL_CODE, TERR_REMIT.TERRITORY_SHORT_NAME) D_REMIT_TO,
	-----------------------------------------------------D_TERRITORY D_TERRITORY,
	-----------------------------------------------------D_RECEIVABLES_ACCOUNT D_RECEIVABLES_ACCOUNT,
	AR_ARXTDR_XMLP_PKG.d_locationformula() D_LOCATION,
	-------- AR_ARXTDR_XMLP_PKG.tr_inv_amountformula(:TR_LN_EXTD_AMOUNT, :TR_TX_EXTD_AMOUNT, :TR_FR_EXTD_AMOUNT) TR_INV_AMOUNT,
	AR_ARXTDR_XMLP_PKG.trx_transaction_flexformula(RACT.CUSTOMER_TRX_ID) TRX_TRANSACTION_FLEX,
/* ----$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$---------  */
(select   (SUM(d.amount) * -1 ) /* cc.segment1||'.'||cc.segment2||'.'||cc.segment3||'.'||cc.segment4||'.'||cc.segment5||'.'||cc.segment6||'.'||cc.segment7||'.'||cc.segment8||'.'||cc.segment9||'.'||cc.segment10||'.'||cc.segment11 */
 from RA_CUST_TRX_LINE_GL_DIST_ALL d, gl_code_combinations cc , RA_customer_TRX_LINES_ALL rctll
 where d.Account_Class = 'REV' and d.CODE_COMBINATION_ID = cc.CODE_COMBINATION_ID  and 
 -------- d.customer_trx_id = ract.customer_trx_id   and  
ract.customer_trx_id= rctll.customer_trx_id and d.CUSTOMER_TRX_line_ID = rctll.customer_trx_line_id  and (  substr(cc.segment2,1,1) = '4' or  substr(cc.segment2,1,1) = '3' ))Revenue_amt2 ,
(select   cc.segment1||'.'||cc.segment2||'.'||cc.segment3||'.'||cc.segment4||'.'||cc.segment5||'.'||cc.segment6||'.'||cc.segment7||'.'||cc.segment8||'.'||cc.segment9||'.'||cc.segment10||'.'||cc.segment11 
 from RA_CUST_TRX_LINE_GL_DIST_ALL d, gl_code_combinations cc , RA_customer_TRX_LINES_ALL rctll
 where d.Account_Class = 'REV' and d.CODE_COMBINATION_ID = cc.CODE_COMBINATION_ID  and 
 -------- d.customer_trx_id = ract.customer_trx_id   and  
ract.customer_trx_id= rctll.customer_trx_id and d.CUSTOMER_TRX_line_ID = rctll.customer_trx_line_id  and (  substr(cc.segment2,1,1) = '4' or  substr(cc.segment2,1,1) = '3' ) and rownum =1) Revenue_acc2 ,
/* ----$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$---------  */
(select   (SUM(d.amount) * -1 ) /* cc.segment1||'.'||cc.segment2||'.'||cc.segment3||'.'||cc.segment4||'.'||cc.segment5||'.'||cc.segment6||'.'||cc.segment7||'.'||cc.segment8||'.'||cc.segment9||'.'||cc.segment10||'.'||cc.segment11 */
 from RA_CUST_TRX_LINE_GL_DIST_ALL d, gl_code_combinations cc , RA_customer_TRX_LINES_ALL rctll
 where d.Account_Class = 'REV' and d.CODE_COMBINATION_ID = cc.CODE_COMBINATION_ID  and 
 -------- d.customer_trx_id = ract.customer_trx_id   and  
ract.customer_trx_id= rctll.customer_trx_id and d.CUSTOMER_TRX_line_ID = rctll.customer_trx_line_id  and (  substr(cc.segment2,1,1) = '1' or  substr(cc.segment2,1,1) = '2' ))Revenue_amt1 ,
(select   cc.segment1||'.'||cc.segment2||'.'||cc.segment3||'.'||cc.segment4||'.'||cc.segment5||'.'||cc.segment6||'.'||cc.segment7||'.'||cc.segment8||'.'||cc.segment9||'.'||cc.segment10||'.'||cc.segment11 
 from RA_CUST_TRX_LINE_GL_DIST_ALL d, gl_code_combinations cc , RA_customer_TRX_LINES_ALL rctll
 where d.Account_Class = 'REV' and d.CODE_COMBINATION_ID = cc.CODE_COMBINATION_ID  and 
 -------- d.customer_trx_id = ract.customer_trx_id   and  
ract.customer_trx_id= rctll.customer_trx_id and d.CUSTOMER_TRX_line_ID = rctll.customer_trx_line_id  and (  substr(cc.segment2,1,1) = '1' or  substr(cc.segment2,1,1) = '2' ) and rownum =1) Revenue_acc1,
/* ----$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$---------  */
(select   (SUM(d.amount) * -1 ) /* cc.segment1||'.'||cc.segment2||'.'||cc.segment3||'.'||cc.segment4||'.'||cc.segment5||'.'||cc.segment6||'.'||cc.segment7||'.'||cc.segment8||'.'||cc.segment9||'.'||cc.segment10||'.'||cc.segment11 */
 from RA_CUST_TRX_LINE_GL_DIST_ALL d, gl_code_combinations cc , RA_customer_TRX_LINES_ALL rctll
 where d.Account_Class = 'REV' and d.CODE_COMBINATION_ID = cc.CODE_COMBINATION_ID  and 
 -------- d.customer_trx_id = ract.customer_trx_id   and  
ract.customer_trx_id= rctll.customer_trx_id and d.CUSTOMER_TRX_line_ID = rctll.customer_trx_line_id  and (  substr(cc.segment2,1,1) = '5' or  substr(cc.segment2,1,1) = '6' ))Revenue_amt3 ,
(select   cc.segment1||'.'||cc.segment2||'.'||cc.segment3||'.'||cc.segment4||'.'||cc.segment5||'.'||cc.segment6||'.'||cc.segment7||'.'||cc.segment8||'.'||cc.segment9||'.'||cc.segment10||'.'||cc.segment11 
 from RA_CUST_TRX_LINE_GL_DIST_ALL d, gl_code_combinations cc , RA_customer_TRX_LINES_ALL rctll
 where d.Account_Class = 'REV' and d.CODE_COMBINATION_ID = cc.CODE_COMBINATION_ID  and 
 -------- d.customer_trx_id = ract.customer_trx_id   and  
ract.customer_trx_id= rctll.customer_trx_id and d.CUSTOMER_TRX_line_ID = rctll.customer_trx_line_id  and (  substr(cc.segment2,1,1) = '5' or  substr(cc.segment2,1,1) = '6' ) and rownum =1) Revenue_acc3 ,
------ GL_DIST_DATE.GL_POSTED_DATE 
trunc(GL_DIST_DATE.GL_POSTED_DATE) GL_POSTED_DATE ,
/* added 29th Oct  */
rabs.name  source_name, GLCC_RCVBL.segment1 Company_code 
FROM    AR_LOOKUPS                      LOOK1,
        AR_LOOKUPS                      LOOK2,
        AR_LOOKUPS                      LOOK3,
        AR_LOOKUPS                      LOOK4,
        AR_LOOKUPS                      LOOK5,
        AR_LOOKUPS                      LOOK6,
        RA_CUST_TRX_TYPES_ALL           RACTT,         -- fusion setid change
        HZ_CUST_ACCOUNTS                RAC_BILL,
        HZ_PARTIES                      RAC_BILL_PARTY,
        HZ_CUST_SITE_USES_ALL           RASU_BILL,     -- fusion setid change
        HZ_CUST_ACCT_SITES_ALL          RAAD_BILL,     -- fusion setid change
        HZ_PARTY_SITES                  RAAD_BILL_PS,
        HZ_LOCATIONS                    RAAD_BILL_LOC,
        FND_TERRITORIES_VL              TERR_BILL,
        HZ_CUST_ACCOUNT_ROLES           RACO_BILL,
        HZ_PARTIES                      RACO_BILL_PARTY,
        HZ_RELATIONSHIPS                        RACO_BILL_REL,
        
        HZ_PARTIES                      RAC_SHIP_PARTY,
        hz_party_site_uses              RASU_SHIP,     -- fusion setid change
        
        HZ_PARTY_SITES                  RAAD_SHIP_PS,
        HZ_LOCATIONS                    RAAD_SHIP_LOC,
        FND_TERRITORIES_VL              TERR_SHIP,
        HZ_PARTIES                      RACO_SHIP_PARTY,
        
        HZ_PARTIES                      RAC_SOLD_PARTY,
        HZ_LOCATIONS                    RAAD_REMIT_LOC,
        FND_TERRITORIES_VL              TERR_REMIT,
        RA_CUST_TRX_LINE_GL_DIST_ALL            GL_DIST_DATE,
        AR_PAYMENT_SCHEDULES_ALL        ARPS,
 --------------------------------- lp_table_show_bill
        GL_CODE_COMBINATIONS            GLCC_RCVBL,
        RA_BATCH_SOURCES_ALL                RABS,  -- fusion setid change
        RA_TERMS                        RAT,
        RA_SALESREPS                    RAS,
        RA_RULES                        RAR,
        AR_RECEIPT_METHODS              ARRM,
        RA_CUSTOMER_TRX_ALL         RACT,
        RA_CUSTOMER_TRX_ALL         RACT1,
        RA_CUSTOMER_TRX_ALL         RACT_COMM,
        IBY_TRXN_EXTENSIONS_V                 extn,
        IBY_FNDCPT_PAYER_ASSGN_INSTR_V        apba,
		IBY_EXT_BANK_ACCOUNTS bkt,   -- rrajarap
		HZ_PARTIES            bkt_party  ,-- rrajarap
		-- 11726735
		AR_REMIT_TO_LOCS_ALL ArRemitToLocsAll
        
WHERE   LOOK1.LOOKUP_TYPE(+)     = 'INV/CM'
AND     LOOK1.LOOKUP_CODE(+)     = RACTT.TYPE
AND     LOOK2.LOOKUP_TYPE(+)     = 'INVOICE_PRINT_OPTIONS'
AND     LOOK2.LOOKUP_CODE(+)     = RACT.PRINTING_OPTION
AND     LOOK3.LOOKUP_TYPE(+)     = 'INVOICE_TRX_STATUS'
--Bug 11726735. Changed this to refer payment schedules.status instead of headers
AND     LOOK3.LOOKUP_CODE(+)     = ARPS.STATUS 
AND     LOOK4.LOOKUP_TYPE(+)     = 'FOB'
AND     LOOK4.LOOKUP_CODE(+)     = RACT.FOB_POINT
AND     LOOK5.LOOKUP_TYPE(+)     = 'CREDIT_METHOD_FOR_RULES'
AND     LOOK5.LOOKUP_CODE(+)     = RACT.CREDIT_METHOD_FOR_RULES
AND     LOOK6.LOOKUP_TYPE(+)     = 'CREDIT_METHOD_FOR_INSTALLMENTS'
AND     LOOK6.LOOKUP_CODE(+)     = RACT.CREDIT_METHOD_FOR_INSTALLMENTS
AND     RACTT.CUST_TRX_TYPE_SEQ_ID   = RACT.CUST_TRX_TYPE_SEQ_ID   --  fusion change RACT.CUST_TRX_TYPE_ID 
AND     RAC_BILL.CUST_ACCOUNT_ID(+)  = RACT.BILL_TO_CUSTOMER_ID
AND     RAC_BILL.PARTY_ID       = RAC_BILL_PARTY.PARTY_ID(+)
AND     RAAD_BILL.CUST_ACCT_SITE_ID(+)  = RASU_BILL.CUST_ACCT_SITE_ID
AND     RAAD_BILL.PARTY_SITE_ID = RAAD_BILL_PS.PARTY_SITE_ID(+)
AND     RAAD_BILL_LOC.LOCATION_ID(+) = RAAD_BILL_PS.LOCATION_ID
AND     RAAD_BILL_LOC.COUNTRY            = TERR_BILL.TERRITORY_CODE(+)
AND     RASU_BILL.SITE_USE_ID(+) = RACT.BILL_TO_SITE_USE_ID
AND     RACO_BILL.CUST_ACCOUNT_ROLE_ID(+)  = RACT.BILL_TO_CONTACT_ID
AND     RACO_BILL.CONTACT_PERSON_ID  = RACO_BILL_REL.SUBJECT_ID(+)  -- fusion TCA change
AND     RACO_BILL_REL.SUBJECT_TABLE_NAME(+) = 'HZ_PARTIES'
AND     RACO_BILL_REL.OBJECT_TABLE_NAME(+) = 'HZ_PARTIES'
AND     RACO_BILL_REL.DIRECTIONAL_FLAG(+) = 'F'
AND     RACO_BILL.ROLE_TYPE(+) = 'CONTACT'
AND     RACO_BILL_REL.SUBJECT_ID = RACO_BILL_PARTY.PARTY_ID(+)

AND     RACT.ship_to_party_id = RAC_SHIP_PARTY.PARTY_ID(+)

AND     RASU_SHIP.PARTY_SITE_ID = RAAD_SHIP_PS.PARTY_SITE_ID(+)
AND     RAAD_SHIP_LOC.LOCATION_ID(+) = RAAD_SHIP_PS.LOCATION_ID
AND     RAAD_SHIP_LOC.COUNTRY           = TERR_SHIP.TERRITORY_CODE(+)
AND     RASU_SHIP.party_SITE_USE_ID(+) = RACT.ship_to_party_site_use_id
AND     RACT.ship_to_party_contact_id =  RACO_SHIP_PARTY.party_id (+)

AND     RAC_SOLD_PARTY.party_id(+)  = RACT.sold_to_party_id 

-- Bug 11726735 commented the following and used remit_to_address_seq_id
AND RACT.Remit_To_Address_Seq_Id  = ArRemitToLocsAll.Address_loc_Seq_Id(+)
AND ArRemitToLocsAll.location_id    = RAAD_REMIT_LOC.location_id(+)
AND     RAAD_REMIT_LOC.COUNTRY           = TERR_REMIT.TERRITORY_CODE(+)
AND     GL_DIST_DATE.CUSTOMER_TRX_ID(+)   = RACT.CUSTOMER_TRX_ID
AND     GL_DIST_DATE.ACCOUNT_CLASS(+)     = 'REC'
AND     GL_DIST_DATE.LATEST_REC_FLAG(+)     = 'Y'
AND     ARPS.CUSTOMER_TRX_ID(+)           = RACT.CUSTOMER_TRX_ID
AND     ARPS.TERMS_SEQUENCE_NUMBER(+)     = 1
AND     GLCC_RCVBL.CODE_COMBINATION_ID(+) = GL_DIST_DATE.CODE_COMBINATION_ID
AND     RABS.BATCH_SOURCE_SEQ_ID(+)           = RACT.BATCH_SOURCE_SEQ_ID  -- fusion setid change

AND     RAT.TERM_ID(+)                    = RACT.TERM_ID
  AND     RAS.RESOURCE_SALESREP_ID(+)                = RACT.PRIMARY_RESOURCE_SALESREP_ID  /*rchandan for fusion*/

AND     RAR.RULE_ID(+)                    = RACT.INVOICING_RULE_ID
AND     ARRM.RECEIPT_METHOD_ID(+)         = RACT.RECEIPT_METHOD_ID
AND    extn.trxn_extension_id(+) = ract.payment_trxn_extension_id
and    extn.instrument_id = apba.instrument_id(+)
AND  extn.instr_assignment_id = apba.instr_assignment_id(+)

and   bkt.ext_bank_account_id(+) = apba.instrument_id -- rrajarap
and    bkt.branch_id = bkt_party.party_id(+) -- rrajarap 
AND     RACT1.CUSTOMER_TRX_ID(+)          = RACT.RELATED_CUSTOMER_TRX_ID
AND     RACT_COMM.CUSTOMER_TRX_ID(+)     = RACT.INITIAL_CUSTOMER_TRX_ID
/* Invoice Number Issue   AND     (RACT.TRX_NUMBER  BETWEEN nvl(:P_INVOICE_NUM_LOW,1) AND  NVL(:P_INVOICE_NUM_HIGH,9999999999999999))  */
and (ract.complete_flag in (:invoice_status))
and RACO_BILL.relationship_id = raco_bill_rel.relationship_id(+)
/* and ARPS.org_id = :P_ORG_ID  */
/*AND     ((RACTT.TYPE = :P_TRANSACTION_TYPE_DUMMY) OR
                        (:P_TRANSACTION_TYPE_DUMMY = 'ALL')) */
--------------------- lp_where_show_bill
/* Transaction Type Parameter Check  */
  AND (RACTT.TYPE  in (:TRANSACTION_TYPE_CODE))  
 AND ( RACT.TRX_DATE Between :Date_From  and  :Date_to)
AND (GL_DIST_DATE.GL_DATE Between :From_GL_Date and :TO_GL_DATE) 
and ( RAC_BILL.customer_type in (:Customer_type))
and (GLCC_RCVBL.segment1  in(:Company_code)) 
 ORDER BY
        RACT.TRX_NUMBER