SELECT DISTINCT SYSDATE report_date,
  a.complete_flag,
  a.attribute4 attribute4_null,
  a.to_buc to_buc,
  a.source invoice_source,
  a.operating_unit business_unit,
  a.ct_reference,
  a.transaction_type,
  DECODE ( a.transaction_type, 'Credit Memo',
  (SELECT trx_number
  FROM RA_CUSTOMER_TRX_ALL
  WHERE customer_trx_id = a.previous_customer_trx_id
  ),
  (SELECT rct.trx_number
  FROM AR_RECEIVABLE_APPLICATIONS_ALL ara ,
    RA_CUSTOMER_TRX_ALL rct ,
    RA_CUST_TRX_TYPES_ALL c
  WHERE ara.status='APP'
  AND ara.applied_customer_trx_id=rct.customer_trx_id
  AND rct.cust_trx_type_seq_id   = c.cust_trx_type_seq_id
  AND c.name                     ='Credit Memo'
  AND ara.customer_trx_id       = a.customer_trx_id
  AND rownum                     <2
  )) previous_trx_number,
  (SELECT ABS(SUM(rctl.extended_amount))
  FROM RA_CUSTOMER_TRX_ALL rct,
    RA_CUSTOMER_TRX_LINES_ALL rctl
  WHERE a.customer_trx_id = rct.customer_trx_id
  AND rct.customer_trx_id = rctl.customer_trx_id
  ) invoice_amount,
  (SELECT rct1.trx_number
  FROM RA_CUSTOMER_TRX_ALL rct,
    RA_CUSTOMER_TRX_ALL rct1
  WHERE rct.previous_customer_trx_id = rct1.customer_trx_id
  AND rct.trx_class                  = 'CM'
  AND rct1.trx_class                 = 'INV'
  AND rct.org_id                     = rct1.org_id
  AND rct.customer_trx_id            = a.customer_trx_id
  ) offset_invoice,
  DECODE(a.source,'CONTRACT INVOICES',
  (SELECT DISTINCT c.cust_po_number
  FROM OKC_K_HEADERS_ALL_B c,
    PJB_CNTRCT_PROJ_LINKS a ,
    PJF_PROJECTS_ALL_B b,
    RA_CUSTOMER_TRX_ALL rct
  WHERE a.project_id = b.Project_id
  AND a.contract_id  = c.id
  AND c.major_version=
    (SELECT MAX(a1.major_version)
    FROM OKC_K_HEADERS_ALL_B a1
    WHERE rct.interface_header_attribute1=a1.contract_number
    )
  AND rct.customer_trx_id            = a.customer_trx_id
  AND rct.interface_header_attribute1=c.contract_number
  ),a.purchase_order) con_inv_po,
  (trim( RPAD( DECODE(a.source,'CONTRACT INVOICES',
  (SELECT DISTINCT c.attribute8
  FROM OKC_K_HEADERS_ALL_B c,
    PJB_CNTRCT_PROJ_LINKS a1,
    PJF_PROJECTS_ALL_B b,
    ra_customer_trx_all rct
  WHERE a1.project_id= b.Project_id
  AND a1.contract_id = c.id
  AND c.major_version=
    (SELECT MAX(a1.major_version)
    FROM OKC_K_HEADERS_ALL_B a1
    WHERE rct.interface_header_attribute1=a1.contract_number
    )
  AND c.attribute8                  IS NOT NULL
  AND ROWNUM                         <2
  AND a.customer_trx_id              =rct.customer_trx_id
  AND rct.interface_header_attribute1=c.contract_number
  ),'Distributed Order Orchestration',
  (SELECT dlfeb.attribute_char2
  FROM DOO_HEADERS_ALL a1,
    DOO_LINES_ALL b,
    RA_CUSTOMER_TRX_LINES_ALL rctla,
    DOO_FULFILL_LINES_ALL c,
    DOO_FULFILL_LINES_EFF_B dlfeb
  WHERE a1.header_id   =b.header_id
  AND b.line_id        =c.line_id
  AND c.fulfill_line_id=dlfeb.fulfill_line_id
  AND a1.status_code NOT LIKE 'DOO_REFERENCE'
  AND TO_CHAR (c.fulfill_line_id) =rctla.INTERFACE_LINE_ATTRIBUTE5
  AND ROWNUM                      <2
  AND a.customer_trx_id           = rctla.customer_trx_id
  AND dlfeb.attribute_char2 IS NOT NULL
  ),
  (SELECT DISTINCT ral.attribute7
  FROM RA_CUSTOMER_TRX_LINES_ALL ral
  WHERE ral.customer_trx_id = a.customer_trx_id
  AND ral.attribute7       IS NOT NULL
  AND ROWNUM                <2
  AND ral.line_type         = 'LINE'
  )),75)) ) doo_adn,
  c.segment1 company_code,
  c.segment2 rec_account,
  a.trx_number,
  a.purchase_order,
  a.customer_trx_id,
  a.operating_unit,
  a.bill_to_site_use_id,
  a.ship_to_site_use_id,
  a.invoice_currency_code,
  d.precision invoice_currency_precision,
  a.functional_currency_code,
  a.functional_currency_precision,
  a.exchange_rate,
  a.exchange_date,
  a.trx_date,
  a.attribute2 unallowable,
  a.attribute3 profit,
  a.attribute9 from_buc_not_null,
  NVL(a.meaning_new, SUBSTR(a.transaction_type,1,6)) from_BUC,
  tax_adn,
  a.buc_currency_code,
  a.source,
  a.gl_transfer_date,
  a.ibs_flag,
  a.Account_new
FROM
  (SELECT a.customer_trx_id,
    a.bill_to_site_use_id,
    (SELECT DECODE(REGEXP_SUBSTR(hps.party_site_name,'BUC',1,1),'BUC',SUBSTR(hps.party_site_name,1,6),hzca.attribute3)
    FROM HZ_CUST_ACCT_SITES_ALL hzca,
      HZ_PARTY_SITES hps,
      HZ_CUST_SITE_USES_ALL hcs
    WHERE 1                    =1
    AND hzca.party_site_id     = hps.party_site_id
    AND hzca.cust_acct_site_id = hcs.cust_acct_site_id
    AND hcs.site_use_code      = 'BILL_TO'
    AND hcs.site_use_id        = a.bill_to_site_use_id
    ) to_buc,
    (SELECT RPAD(NVL(hzca.attribute2,' '),64)
    FROM HZ_CUST_ACCT_SITES_ALL hzca,
      HZ_CUST_SITE_USES_ALL hcs
    WHERE 1                    =1
    AND hzca.cust_acct_site_id = hcs.cust_acct_site_id
    AND hcs.site_use_code      = 'BILL_TO'
    AND hcs.site_use_id        = a.bill_to_site_use_id
    ) tax_adn,
    a.ship_to_site_use_id,
    a.trx_number,
    b.name source,
    c.name transaction_type,
    NVL(m.tag, c.attribute2) buc_currency_code,
    f.name operating_unit,
    f.organization_id,
    a.trx_date,
    a.purchase_order,
    a.invoice_currency_code,
    a.complete_flag,
    i.currency_code functional_currency_code,
    k.precision functional_currency_precision,
    a.exchange_date,
    a.exchange_rate,
    a.attribute_category,
    a.attribute1,
    a.attribute2,
    a.attribute3,
    a.attribute4,
    a.attribute9,
    g.amount_due_original ,
    m.meaning meaning_new ,
    n.customer_type,
    xah.gl_transfer_date,
    a.ct_reference,
    a.PREVIOUS_CUSTOMER_TRX_ID,
    c.attribute1 IBS_Flag,
    (    SELECT  
           gcc.segment2
    FROM 
         XLA_TRANSACTION_ENTITIES ent, 
         XLA_AE_HEADERS           aeh, 
         XLA_AE_LINES             ael  ,
    GL_CODE_COMBINATIONS gcc
    WHERE ent.application_id = 222 
      AND ent.source_id_int_1  = a.customer_trx_id
      AND ent.entity_code    = 'TRANSACTIONS' 
      AND ent.entity_id      = aeh.entity_id 
      AND aeh.ae_header_id   = ael.ae_header_id 
      AND ael.accounting_class_code ='RECEIVABLE'  
    AND ent.security_id_int_1    =a.org_id
    AND aeh.legal_entity_id IS NOT NULL
AND gcc.code_combination_id= ael.code_combination_id
AND ROWNUM <2) Account_new

  FROM RA_CUSTOMER_TRX_ALL a,
    RA_BATCH_SOURCES_ALL b,
    RA_CUST_TRX_TYPES_ALL c,
    XLE_ENTITY_PROFILES d,
    RA_TERMS_TL e,
    HR_ALL_ORGANIZATION_UNITS f,
    AR_PAYMENT_SCHEDULES_ALL g,
    HR_ORGANIZATION_INFORMATION h,
    GL_LEDGERS i,
    GL_DAILY_CONVERSION_TYPES j,
    FND_CURRENCIES k,
    RA_CUST_TRX_LINE_GL_DIST_ALL rctlg,
    XLA_AE_HEADERS xah,
    FND_LOOKUP_VALUES m,
    HZ_CUST_ACCOUNTS N
  WHERE b.batch_source_seq_id = a.batch_source_seq_id
  AND m.lookup_type (+)       ='GED IBS EXTRACT LOOKUP'
  AND f.name                  = m.lookup_code(+)
  AND m.ENABLED_FLAG (+)     ='Y'
  AND n.cust_account_id      =a.bill_to_customer_id 
  AND c.CUST_TRX_TYPE_SEQ_ID = a.cust_trx_type_seq_id
  AND d.legal_entity_id              = a.legal_entity_id
  AND e.term_id(+)                   = a.term_id
  AND e.language(+)                  = 'US'
  AND f.organization_id              = a.org_id
  AND g.customer_trx_id(+)           = a.customer_trx_id
  AND h.org_information_context      = 'FUN_BUSINESS_UNIT'
  AND h.organization_id              = a.org_id -- OU join
  AND TO_NUMBER (h.org_information3) = i.ledger_id
  AND j.conversion_type(+)           = a.exchange_rate_type
  AND i.currency_code                = k.currency_code
  AND rctlg.account_class            = 'REC'
  AND rctlg.customer_trx_id          = a.customer_trx_id
  AND rctlg.event_id                 =xah.event_id
  AND xah.gl_transfer_date          IS NOT NULL
  AND ( ( :P_INVOICE_NUM IS NOT NULL
  AND :P_BU_NAME         IS NULL
  AND :P_FROM_DATE       IS NULL
  AND :P_TO_DATE         IS NULL
  AND a.trx_number       IN
    (SELECT REGEXP_SUBSTR(:P_INVOICE_NUM,'[^\,]+', 1, LEVEL)
    FROM DUAL
      CONNECT BY REGEXP_SUBSTR(:P_INVOICE_NUM, '[^\,]+', 1, LEVEL) IS NOT NULL
    ) )
  OR ( :P_INVOICE_NUM IS NULL
  AND :P_FROM_DATE    IS NULL
  AND :P_TO_DATE      IS NULL
  AND :P_BU_NAME      IS NOT NULL
  AND a.org_id         =
    (SELECT organization_id
    FROM HR_ALL_ORGANIZATION_UNITS
    WHERE name = :P_BU_NAME
    ) )
  OR ( :P_INVOICE_NUM IS NULL
  AND :P_BU_NAME      IS NULL
  AND :P_FROM_DATE    IS NOT NULL
  AND :P_TO_DATE      IS NOT NULL
  AND TRUNC(xah.gl_transfer_date) BETWEEN :P_FROM_DATE AND :P_TO_DATE
    )
  OR ( :P_INVOICE_NUM IS NULL
  AND :P_FROM_DATE    IS NULL
  AND :P_TO_DATE      IS NULL
  AND :P_BU_NAME      IS NULL
  AND ( TRUNC(xah.gl_transfer_date) = TRUNC(SYSDATE -1)) ) )
  ) a,
  RA_CUST_TRX_LINE_GL_DIST_ALL b,
  GL_CODE_COMBINATIONS c,
  FND_CURRENCIES d
WHERE 1 = 1
AND UPPER(a.source) NOT LIKE '%CONV%' 
AND b.customer_trx_id      = a.customer_trx_id
AND b.account_class        = 'REC'
AND c.code_combination_id  = b.code_combination_id
AND d.currency_code        = a.invoice_currency_code
AND a.amount_due_original <> 0
AND a.customer_type = 'I'
MINUS
SELECT DISTINCT SYSDATE report_date,
  a.complete_flag,
  a.attribute4 attribute4_null ,
  a.to_buc to_buc,
  a.source invoice_source,
  a.operating_unit business_unit,
  a.ct_reference,
  a.transaction_type,
  DECODE ( a.transaction_type, 'Credit Memo',
  (SELECT trx_number
  FROM RA_CUSTOMER_TRX_ALL
  WHERE customer_trx_id = a.previous_customer_trx_id
  ),
  (SELECT rct.trx_number
  FROM AR_RECEIVABLE_APPLICATIONS_ALL ara ,
    RA_CUSTOMER_TRX_ALL rct ,
    RA_CUST_TRX_TYPES_ALL c
  WHERE ara.status='APP'
  AND ara.applied_customer_trx_id=rct.customer_trx_id
  AND rct.cust_trx_type_seq_id   = c.cust_trx_type_seq_id
  AND c.name                     ='Credit Memo'
  AND ara.customer_trx_id       = a.customer_trx_id
  AND ROWNUM                     <2
  )) previous_trx_number,
  (SELECT ABS(SUM(rctl.extended_amount))
  FROM RA_CUSTOMER_TRX_ALL rct,
    RA_CUSTOMER_TRX_LINES_ALL rctl
  WHERE a.customer_trx_id = rct.customer_trx_id
  AND rct.customer_trx_id = rctl.customer_trx_id
  ) invoice_amount,
  (SELECT rct1.trx_number
  FROM RA_CUSTOMER_TRX_ALL rct,
    RA_CUSTOMER_TRX_ALL rct1
  WHERE rct.previous_customer_trx_id = rct1.customer_trx_id
  AND rct.trx_class                  = 'CM'
  AND rct1.trx_class                 = 'INV'
  AND rct.org_id                     = rct1.org_id
  AND rct.customer_trx_id            = a.customer_trx_id
  ) offset_invoice,
  DECODE(a.source,'CONTRACT INVOICES',
  (SELECT DISTINCT c.cust_po_number
  FROM OKC_K_HEADERS_ALL_B c,
    PJB_CNTRCT_PROJ_LINKS a ,
    PJF_PROJECTS_ALL_B b,
    RA_CUSTOMER_TRX_ALL rct
  WHERE a.project_id = b.Project_id
  AND a.contract_id  = c.id
  AND c.major_version=
    (SELECT MAX(a1.major_version)
    FROM OKC_K_HEADERS_ALL_B a1
    WHERE rct.interface_header_attribute1=a1.contract_number
    )
  AND rct.customer_trx_id            = a.customer_trx_id
  AND rct.interface_header_attribute1=c.contract_number
  ),a.purchase_order) con_inv_po,
  (trim( RPAD( DECODE(a.source,'CONTRACT INVOICES',
  (SELECT DISTINCT c.attribute8
  FROM OKC_K_HEADERS_ALL_B c,
    PJB_CNTRCT_PROJ_LINKS a1,
    PJF_PROJECTS_ALL_B b,
    ra_customer_trx_all rct
  WHERE A1.project_id= b.Project_id
  AND A1.contract_id = C.id
  AND c.major_version=
    (SELECT MAX(a1.major_version)
    FROM OKC_K_HEADERS_ALL_B a1
    WHERE rct.interface_header_attribute1=a1.contract_number
    )
  AND c.attribute8                  IS NOT NULL
  AND ROWNUM                         <2
  AND a.customer_trx_id              =rct.customer_trx_id
  AND rct.interface_header_attribute1=c.contract_number
  ),'Distributed Order Orchestration',
  (SELECT dlfeb.attribute_char2
  FROM DOO_HEADERS_ALL a1,
    DOO_LINES_ALL b,
    RA_CUSTOMER_TRX_LINES_ALL rctla,
    DOO_FULFILL_LINES_ALL c,
    DOO_FULFILL_LINES_EFF_B dlfeb
  WHERE a1.header_id   =b.header_id
  AND b.line_id        =c.line_id
  AND c.fulfill_line_id=dlfeb.fulfill_line_id
  AND a1.status_code NOT LIKE 'DOO_REFERENCE'
  AND TO_CHAR (c.fulfill_line_id) =rctla.interface_line_attribute5
  AND ROWNUM                      <2
  AND a.customer_trx_id           = rctla.customer_trx_id
  AND dlfeb.attribute_char2 IS NOT NULL
  ),
  (SELECT DISTINCT ral.attribute7
  FROM RA_CUSTOMER_TRX_LINES_ALL ral
  WHERE ral.customer_trx_id = a.customer_trx_id
  AND ral.attribute7       IS NOT NULL
  AND ROWNUM                <2
  AND ral.line_type         = 'LINE'
  )),75)) ) doo_adn,
  c.segment1 company_code,
  c.segment2 rec_account,
  a.trx_number,
  a.purchase_order,
  a.customer_trx_id,
  a.operating_unit,
  a.bill_to_site_use_id,
  a.ship_to_site_use_id,
  a.invoice_currency_code,
  d.precision invoice_currency_precision,
  a.functional_currency_code,
  a.functional_currency_precision,
  a.exchange_rate,
  a.exchange_date,
  a.trx_date,
  a.attribute2 unallowable,
  a.attribute3 profit,
  a.attribute9 from_buc_not_null,
  NVL(a.meaning_new, SUBSTR(a.transaction_type,1,6)) from_BUC,
  tax_adn,
  a.buc_currency_code,
  a.source,
  a.gl_transfer_date,
  a.ibs_flag,
  a.Account_new
FROM
  (SELECT a.customer_trx_id,
    a.bill_to_site_use_id,
    (SELECT DECODE(REGEXP_SUBSTR(hps.party_site_name,'BUC',1,1),'BUC',SUBSTR(hps.party_site_name,1,6),hzca.attribute3)
    FROM HZ_CUST_ACCT_SITES_ALL hzca,
      HZ_PARTY_SITES hps,
      HZ_CUST_SITE_USES_ALL hcs
    WHERE 1                    =1
    AND hzca.party_site_id     = hps.party_site_id
    AND hzca.cust_acct_site_id = hcs.cust_acct_site_id
    AND hcs.site_use_code      = 'BILL_TO'
    AND hcs.site_use_id        = a.bill_to_site_use_id
    ) to_buc,
    (SELECT RPAD(NVL(hzca.attribute2,' '),64)
    FROM HZ_CUST_ACCT_SITES_ALL hzca,
      HZ_CUST_SITE_USES_ALL hcs
    WHERE 1                    =1
    AND hzca.cust_acct_site_id = hcs.cust_acct_site_id
    AND hcs.site_use_code      = 'BILL_TO'
    AND hcs.site_use_id        = a.bill_to_site_use_id
    ) tax_adn,
    a.ship_to_site_use_id,
    a.trx_number,
    b.name source,
    c.name transaction_type,
    NVL(m.tag, c.attribute2) buc_currency_code,
    f.name operating_unit,
    f.organization_id,
    a.trx_date,
    a.purchase_order,
    a.invoice_currency_code,
    a.complete_flag,
    i.currency_code functional_currency_code,
    k.precision functional_currency_precision,
    a.exchange_date,
    a.exchange_rate,
    a.attribute_category,
    a.attribute1,
    a.attribute2,
    a.attribute3,
    a.attribute4,
    a.attribute9,
    g.amount_due_original ,
    m.meaning meaning_new ,
    n.customer_type,
    xah.gl_transfer_date,
    a.ct_reference,
    a.PREVIOUS_CUSTOMER_TRX_ID,
    c.attribute1 IBS_Flag,
      (    SELECT  
               gcc.segment2
        FROM 
             XLA_TRANSACTION_ENTITIES ent, 
             XLA_AE_HEADERS           aeh, 
             XLA_AE_LINES             ael  ,
        GL_CODE_COMBINATIONS gcc
        WHERE ent.application_id = 222 
          AND ent.source_id_int_1  = a.customer_trx_id
          AND ent.entity_code    = 'TRANSACTIONS' 
          AND ent.entity_id      = aeh.entity_id 
          AND aeh.ae_header_id   = ael.ae_header_id 
          AND ael.accounting_class_code ='RECEIVABLE'  
        AND ent.security_id_int_1    =a.org_id
        AND aeh.legal_entity_id IS NOT NULL
    AND gcc.code_combination_id= ael.code_combination_id
AND ROWNUM <2) Account_new
  FROM RA_CUSTOMER_TRX_ALL a,
    RA_BATCH_SOURCES_ALL b,
    RA_CUST_TRX_TYPES_ALL c,
    XLE_ENTITY_PROFILES d,
    RA_TERMS_TL e,
    HR_ALL_ORGANIZATION_UNITS f,
    AR_PAYMENT_SCHEDULES_ALL g,
    HR_ORGANIZATION_INFORMATION h,
    GL_LEDGERS i,
    GL_DAILY_CONVERSION_TYPES j,
    FND_CURRENCIES k,
    RA_CUST_TRX_LINE_GL_DIST_ALL rctlg,
    xla_ae_headers xah,
    FND_LOOKUP_VALUES m,
    HZ_CUST_ACCOUNTS n
  WHERE b.batch_source_seq_id = a.batch_source_seq_id
  AND m.lookup_type (+)       ='GED IBS EXTRACT LOOKUP'
  AND f.name                  = m.lookup_code(+)
  AND m.ENABLED_FLAG (+)             ='Y'
  AND n.cust_account_id              =a.bill_to_customer_id 
  AND c.CUST_TRX_TYPE_SEQ_ID         = a.cust_trx_type_seq_id
  AND c.attribute1                   = 'Y'
  AND d.legal_entity_id              = a.legal_entity_id
  AND e.term_id(+)                   = a.term_id
  AND e.language(+)                  = 'US'
  AND f.organization_id              = a.org_id
  AND g.customer_trx_id(+)           = a.customer_trx_id
  AND h.org_information_context      = 'FUN_BUSINESS_UNIT'
  AND h.organization_id              = a.org_id 
  AND TO_NUMBER (h.org_information3) = i.ledger_id
  AND j.conversion_type(+)           = a.exchange_rate_type
  AND i.currency_code                = k.currency_code
  AND rctlg.account_class            = 'REC'
  AND rctlg.customer_trx_id          = a.customer_trx_id
  AND rctlg.event_id                 =xah.event_id
  AND xah.gl_transfer_date          IS NOT NULL
  AND ( ( :P_INVOICE_NUM IS NOT NULL
  AND :P_BU_NAME         IS NULL
  AND :P_FROM_DATE       IS NULL
  AND :P_TO_DATE         IS NULL
  AND a.trx_number       IN
    (SELECT REGEXP_SUBSTR(:P_INVOICE_NUM,'[^\,]+', 1, level)
    FROM DUAL
      CONNECT BY REGEXP_SUBSTR(:P_INVOICE_NUM, '[^\,]+', 1, level) IS NOT NULL
    ) )
  OR ( :P_INVOICE_NUM IS NULL
  AND :P_FROM_DATE    IS NULL
  AND :P_TO_DATE      IS NULL
  AND :P_BU_NAME      IS NOT NULL
  AND a.org_id         =
    (SELECT organization_id
    FROM HR_ALL_ORGANIZATION_UNITS
    WHERE name = :P_BU_NAME
    ) )
  OR ( :P_INVOICE_NUM IS NULL
  AND :P_BU_NAME      IS NULL
  AND :P_FROM_DATE    IS NOT NULL
  AND :P_TO_DATE      IS NOT NULL
  AND TRUNC(xah.gl_transfer_date) BETWEEN :P_FROM_DATE AND :P_TO_DATE
    )
  OR ( :P_INVOICE_NUM IS NULL
  AND :P_FROM_DATE    IS NULL
  AND :P_TO_DATE      IS NULL
  AND :P_BU_NAME      IS NULL
  AND ( TRUNC(xah.gl_transfer_date) = TRUNC(SYSDATE -1 )) ) )
  ) a,
  RA_CUST_TRX_LINE_GL_DIST_ALL b,
  GL_CODE_COMBINATIONS c,
  FND_CURRENCIES d
WHERE 1             =1
AND a.complete_flag = 'Y' 
AND a.to_buc IS NOT NULL
AND UPPER(a.source) NOT LIKE '%CONV%' 
AND b.customer_trx_id      = a.customer_trx_id
AND b.account_class        = 'REC'
AND c.code_combination_id  = b.code_combination_id
AND d.currency_code        = a.invoice_currency_code
AND a.amount_due_original <> 0
AND a.customer_type   = 'I'
AND ((a.operating_unit='CA_CAD_BU')
OR ((A.OPERATING_UNIT!= 'CA_CAD_BU')
AND ( DECODE(a.source,'CONTRACT INVOICES',
  (SELECT DISTINCT c.cust_po_number
  FROM OKC_K_HEADERS_ALL_B c,
    PJB_CNTRCT_PROJ_LINKS a ,
    PJF_PROJECTS_ALL_B b,
    RA_CUSTOMER_TRX_ALL rct
  WHERE a.project_id = b.Project_id
  AND a.contract_id  = c.id
  AND c.major_version=
    (SELECT MAX(a1.major_version)
    FROM OKC_K_HEADERS_ALL_B a1
    WHERE rct.interface_header_attribute1=a1.contract_number
    )
  AND rct.customer_trx_id            = a.customer_trx_id
  AND rct.interface_header_attribute1=c.contract_number
  ),a.purchase_order)               IS NOT NULL
OR (trim( RPAD( DECODE(a.source,'CONTRACT INVOICES',
  (SELECT DISTINCT c.attribute8
  FROM OKC_K_HEADERS_ALL_B C,
    PJB_CNTRCT_PROJ_LINKS A1,
    PJF_PROJECTS_ALL_B B,
    RA_CUSTOMER_TRX_ALL rct
  WHERE A1.project_id= b.Project_id
  AND A1.contract_id = C.id
  AND c.major_version=
    (SELECT MAX(a1.major_version)
    FROM OKC_K_HEADERS_ALL_B a1
    WHERE rct.interface_header_attribute1=a1.contract_number
    )
  AND c.attribute8                  IS NOT NULL
  AND ROWNUM                         <2
  AND a.customer_trx_id              =rct.customer_trx_id
  AND rct.interface_header_attribute1=c.contract_number
  ),'Distributed Order Orchestration',
  (SELECT dlfeb.attribute_char2
  FROM DOO_HEADERS_ALL a1,
    DOO_LINES_ALL b,
    RA_CUSTOMER_TRX_LINES_ALL rctla,
    DOO_FULFILL_LINES_ALL c,
    DOO_FULFILL_LINES_EFF_B dlfeb
  WHERE a1.header_id   =b.header_id
  AND b.line_id        =c.line_id
  AND c.fulfill_line_id=dlfeb.fulfill_line_id
  AND A1.status_code NOT LIKE 'DOO_REFERENCE'
  AND TO_CHAR (c.fulfill_line_id) =rctla.interface_line_attribute5
  AND rownum                      <2
  AND a.customer_trx_id           = rctla.customer_trx_id
  AND dlfeb.attribute_char2 IS NOT NULL
  ),
  (SELECT DISTINCT ral.attribute7
  FROM RA_CUSTOMER_TRX_LINES_ALL ral
  WHERE ral.customer_trx_id = a.customer_trx_id
  AND ral.attribute7       IS NOT NULL
  AND ROWNUM                <2
  AND ral.line_type         = 'LINE'
  )),75)) )                IS NOT NULL)))