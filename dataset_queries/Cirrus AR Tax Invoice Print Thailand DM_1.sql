--#-----------------------------------------------------------------------------------------------------#
--# MODIFICATION HISTORY:
--# CR#                       	Author             Date                Description
--#-----------------------------------------------------------------------------------------------------#
--# REL-046   					Sowndarya Perumal  	02-NOV-2020  Receipt Query - Initial Version           --#
--# REL-064- GERITM30408706   	Akash Mohanty		20-APR-2022  Exchange rate based on one day before receipt date --#
--#
--#-----------------------------------------------------------------------------------------------------#
SELECT
    NVL( (
        SELECT
            description
        FROM
            FND_LOOKUP_VALUES_VL
        WHERE
            lookup_type = 'CIRRUS_AR_NEW_LE_DETAILS'
            AND meaning = 'LE_NAME_' || hou.name
            AND enabled_flag = 'Y'
            AND ROWNUM = 1
            AND TRUNC(SYSDATE) BETWEEN NVL(start_date_active,TRUNC(SYSDATE) ) AND NVL(end_date_active,TRUNC(SYSDATE) )
    ),xle.name) legal_entity_name,
    (
        SELECT
            REPLACE(description,'~',CHR(13) )
        FROM
            FND_LOOKUP_VALUES_VL
        WHERE
            lookup_type = 'XXAR_INV_CONTACT'
            AND lookup_code = 'SUPPLIER_ADDRESS_' || hou.name
            AND enabled_flag = 'Y'
            AND ROWNUM = 1
            AND TRUNC(SYSDATE) BETWEEN NVL(start_date_active,TRUNC(SYSDATE) ) AND NVL(end_date_active,TRUNC(SYSDATE) )
    ) sender_Address,
    arca.receipt_number,
    arca.doc_sequence_value,
    arca.receipt_Date,
    hca.account_number,
    hp.party_name,
hl.ADDRESS1||'/'||hl.ADDRESS2||'/'||hl.ADDRESS3||'/'||hl.STATE||' '||hl.POSTAL_CODE||'/'||(select TERRITORY_SHORT_NAME from fnd_territories_vl where territory_code=hl.COUNTRY) 
customer_address,
   -- HZ_FORMAT_PUB.format_address(hl.location_id) customer_address,
    arca.currency_code,
    (
        SELECT
            currency_code
        FROM
            GL_LEDGERS gl
        WHERE
            gl.ledger_id = arca.set_of_books_id
    ) func_curr,
    ( DECODE(arca.currency_code, (
        SELECT
            currency_code
        FROM
            GL_LEDGERS gl
        WHERE
            gl.ledger_id = arca.set_of_books_id
    ),'N','Y') ) curr_conv,
    (
        SELECT
            gld.conversion_Rate
        FROM
            GL_DAILY_RATES gld
        WHERE
            -- TRUNC(gld.conversion_date) = TRUNC(arca.exchange_date) -- Commented for REL-064 -GERITM30408706 
			TRUNC(gld.conversion_date) = TRUNC(arca.receipt_Date)-1 -- Added for REL-064  -GERITM30408706 
            AND gld.from_currency = arca.currency_code
            AND gld.to_currency = (
                SELECT
                    gll.currency_code
                FROM
                    GL_LEDGERS gll
                WHERE
                    gll.ledger_id = hou.set_of_books_id
            )
            AND gld.conversion_type = (
                SELECT
                    flv.meaning
                FROM
                    FND_LOOKUP_VALUES_VL flv
                WHERE
                    flv.lookup_type = 'CIRRUSAR_INVPRINT_DAILYRATE'
                    AND flv.enabled_flag = 'Y'
                    AND flv.lookup_code = hou.name
                    AND TRUNC(SYSDATE) BETWEEN NVL(start_date_active,TRUNC(SYSDATE) ) AND NVL(end_date_active,TRUNC(SYSDATE) )
            )
    ) exchange_rate,
    TO_CHAR(NVL( (
        SELECT
            SUM(extended_amount)
        FROM
            RA_CUSTOMER_TRX_LINES_ALL lines
        WHERE
            lines.customer_trx_id = rcta.customer_trx_id
            AND lines.line_type = 'LINE'
            AND UPPER(description) NOT LIKE '%WURLDTECH%TAX%LINE%'
            AND UPPER(description) NOT LIKE '%WT%GST/HST%TAX%'
            AND UPPER(description) NOT LIKE '%WT%PST%TAX%'
    ),TO_NUMBER(0) ),fnd_currency.get_format_mask(rcta.invoice_currency_code,40) ) LINE_AMOUNT,
    TO_CHAR(NVL( (
        SELECT
            SUM(tax_amt)
        FROM
            ZX_LINES_V zlv
        WHERE
            zlv.trx_id = rcta.customer_trx_id
            AND zlv.APPLICATION_ID = 222 
    ),TO_NUMBER(0) ),fnd_currency.get_format_mask(rcta.invoice_currency_code,40) ) tax_amount,
    TO_CHAR(NVL( (
        SELECT
            SUM(extended_amount)
        FROM
            RA_CUSTOMER_TRX_LINES_ALL lines
        WHERE
            lines.customer_trx_id = rcta.customer_trx_id
            AND lines.line_type = 'LINE'
            AND UPPER(description) NOT LIKE '%WURLDTECH%TAX%LINE%'
            AND UPPER(description) NOT LIKE '%WT%GST/HST%TAX%'
            AND UPPER(description) NOT LIKE '%WT%PST%TAX%'
    ),TO_NUMBER(0) )
     + NVL( (
        SELECT
            SUM(extended_amount)
        FROM
            RA_CUSTOMER_TRX_LINES_ALL lines
        WHERE
            lines.customer_trx_id = rcta.customer_trx_id
            AND lines.line_type = 'FREIGHT'
    ),TO_NUMBER(0) ) + NVL( (
        SELECT
            SUM(extended_amount)
        FROM
            RA_CUSTOMER_TRX_LINES_ALL lines
        WHERE
            lines.customer_trx_id = rcta.customer_trx_id
            AND lines.line_type = 'CHARGES'
    ),TO_NUMBER(0) )
     + NVL( (
        SELECT
            SUM(tax_amt)
        FROM
            ZX_LINES_V zlv
        WHERE
            zlv.trx_id = rcta.customer_trx_id
            AND zlv.APPLICATION_ID = 222 -- In some Invoices/CM application ID is NULL so hard coding to 222 which is for Receivables Added by MEHUL
    ),TO_NUMBER(0) ),fnd_currency.get_format_mask(rcta.invoice_currency_code,40) ) TOTAL_AMOUNT,
    arca.cash_receipt_id,
    NVL( (
        SELECT
            description
        FROM
            FND_LOOKUP_VALUES_VL
        WHERE
            lookup_type = 'XXAR_INV_CONTACT'
            AND meaning = 'SUPPLIER_VAT_NUM_' || hou.name
            AND enabled_flag = 'Y'
            AND ROWNUM = 1
            AND TRUNC(SYSDATE) BETWEEN NVL(start_date_active,TRUNC(SYSDATE) ) AND NVL(end_date_active,TRUNC(SYSDATE) )
    ),xle.registration_number) AS vat_reg_no_germany,
    NVL( (
        SELECT
            rep_registration_number
        FROM
            ZX_PARTY_TAX_PROFILE
        WHERE
            party_id = hps.party_site_id
            AND party_type_code = 'THIRD_PARTY_SITE'
    ), (
        SELECT
            rep_registration_number
        FROM
            ZX_PARTY_TAX_PROFILE
        WHERE
            party_id = hp.party_id
            AND party_type_code = 'THIRD_PARTY'
    ) ) bill_tax_reg_no,
    rcta.customer_trx_id
FROM
    AR_CASH_RECEIPTS_ALL arca,
    XLE_FIRSTPARTY_INFORMATION_V xle,
    HR_OPERATING_UNITS hou,
    HZ_CUST_ACCOUNTS hca,
    HZ_PARTIES hp,
    HZ_CUST_SITE_USES_ALL hcsu,
    HZ_CUST_ACCT_SITES_ALL hcas,
    HZ_PARTY_SITES hps,
    HZ_LOCATIONS hl,
    AR_RECEIVABLE_APPLICATIONS_ALL araa,
    RA_CUSTOMER_TRX_ALL rcta
WHERE
    1 = 1
    AND xle.legal_entity_id = arca.legal_entity_id
    AND hou.organization_id = arca.org_id
    AND arca.doc_sequence_value BETWEEN NVL(:p_from_inv,arca.doc_sequence_value) AND NVL(:p_to_inv,arca.doc_sequence_value)
    AND arca.receipt_Date BETWEEN NVL(:p_from_date,arca.receipt_Date) AND NVL(:p_to_Date,arca.receipt_Date)
    AND arca.receipt_number = NVL(:p_receipt_num,arca.receipt_number)
	AND (
        (
            :p_from_inv IS NOT NULL
            AND :p_to_inv IS NOT NULL
        )
        OR (
            :p_from_date IS NOT NULL
            AND :p_to_Date IS NOT NULL
        )
		OR :p_receipt_num IS NOT NULL
    )
    AND hou.NAME = NVL(:p_bu_name,hou.name)
    AND hca.cust_account_id = arca.pay_from_customer
    AND hca.party_id = hca.party_id
    AND hcsu.site_use_id = arca.customer_site_use_id
    AND hcsu.cust_acct_Site_id = hcas.cust_Acct_site_id
    AND hca.cust_account_id = hcas.cust_account_id
    AND hcas.party_site_id = hps.party_site_id
    AND hp.party_id = hps.party_id
    AND hps.location_id = hl.location_id
    AND rcta.customer_TRX_ID (+) = araa.applied_customer_TRX_ID
    AND araa.CASH_RECEIPT_ID = arca.cash_receipt_id
    AND araa.display = 'Y'