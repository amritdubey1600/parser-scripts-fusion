--#-----------------------------------------------------------------------------------------------------#
--# MODIFICATION HISTORY:
--# CR#                       Author             Date                Description
--#-----------------------------------------------------------------------------------------------------#
--# REL-046   			Sowndarya Perumal  02-NOV-2020  	Invoice Lines Query - Initial Version     --#
--#
--#-----------------------------------------------------------------------------------------------------#
SELECT
    ract.trx_number,
    ract.customer_trx_id,
    araa.cash_receipt_id,
    TO_CHAR(DECODE(c2.line_number,NULL,ractl.line_number,NULL) ) line_number,
    DECODE(NVL(eitem.item_number,ar_bpa_utils_pkg.fn_get_line_description(ractl.customer_trx_line_id) ),DECODE(ractl.interface_line_context
,'CONTRACT INVOICES',DECODE(EITEM.ITEM_NUMBER,ar_bpa_utils_pkg.fn_get_line_description(ractl.customer_trx_line_id),NULL,ar_bpa_utils_pkg
.fn_get_line_description(ractl.customer_trx_line_id) ), (
        SELECT
            SUBSTR(attribute_char13,1,150)
        FROM
            DOO_FULFILL_LINES_EFF_B
        WHERE
            fulfill_line_id = ractl.interface_line_attribute5
            AND ATTRIBUTE_CHAR13 IS NOT NULL
            AND ROWNUM = 1
    ) ),NULL,DECODE(ractl.interface_line_context,'CONTRACT INVOICES',DECODE(EITEM.ITEM_NUMBER,ar_bpa_utils_pkg.fn_get_line_description
(ractl.customer_trx_line_id),NULL,ar_bpa_utils_pkg.fn_get_line_description(ractl.customer_trx_line_id) ), (
        SELECT
            SUBSTR(attribute_char13,1,150)
        FROM
            DOO_FULFILL_LINES_EFF_B
        WHERE
            fulfill_line_id = ractl.interface_line_attribute5
            AND ATTRIBUTE_CHAR13 IS NOT NULL
            AND ROWNUM = 1
    ) ) ) smart_part_number_desc,
    (
        CASE
            WHEN ractl.org_id NOT IN (
                SELECT
                    hou.organization_id
                FROM
                    FND_LOOKUP_VALUES flv,
                    HR_OPERATING_UNITS hou
                WHERE
                    flv.lookup_type = 'GED_BU_NAMES'
                    AND LANGUAGE = 'US'
                    AND flv.enabled_flag = 'Y'
                    AND UPPER(flv.description) = 'AVIATION'
                    AND NVL(flv.start_date_active,SYSDATE) <= SYSDATE
                    AND NVL(flv.end_date_active,SYSDATE) >= SYSDATE
                    AND flv.lookup_code = hou.short_code
            ) THEN (
                CASE
                    WHEN ( (
                        SELECT DISTINCT
                            petv.expenditure_type_name
                        FROM
                            PJB_INVOICE_HEADERS pih,
                            PJB_INVOICE_LINES pil,
                            RA_CUSTOMER_TRX_ALL trx,
                            RA_CUSTOMER_TRX_LINES_ALL rct,
                            PJF_EXP_TYPES_VL petv,
                            PJC_EXP_ITEMS_ALL pei,
                            PJB_INV_LINE_DISTS pild
                        WHERE
                            pih.invoice_id = pil.invoice_id
                            AND pih.ra_invoice_number = trx.trx_number
                            AND rct.customer_trx_id = trx.customer_trx_id
                            AND rct.interface_line_attribute2 = TO_CHAR(pih.contract_id)
                            AND rct.interface_line_attribute5 = TO_CHAR(pil.invoice_line_id)
                            AND petv.expenditure_type_id = pei.expenditure_type_id
                            AND pild.transaction_id = pei.expenditure_item_id
                            AND pild.transaction_project_id = pei.project_id
                            AND pild.transaction_task_id = pei.task_id
                            AND pild.transaction_project_id = pei.project_id
                            AND trx.customer_trx_id = ract.customer_trx_id
                            AND rct.customer_trx_line_id = ractl.customer_trx_line_id
                            AND pih.invoice_id = pild.invoice_id
                            AND pil.invoice_line_id = pild.invoice_line_id
                    ) IN (
                        'Labor',
                        'Contractor Labor'
                    ) ) THEN TO_CHAR( (
                        SELECT
                            SUM(pei.quantity)
                        FROM
                            PJB_INVOICE_HEADERS pih,
							PJB_INVOICE_LINES pil,
							RA_CUSTOMER_TRX_ALL trx,
							RA_CUSTOMER_TRX_LINES_ALL rct,
							PJF_EXP_TYPES_VL petv,
							PJC_EXP_ITEMS_ALL pei,
							PJB_INV_LINE_DISTS pild
                        WHERE
                            pih.invoice_id = pil.invoice_id
                            AND pih.ra_invoice_number = trx.trx_number
                            AND rct.customer_trx_id = trx.customer_trx_id
                            AND rct.interface_line_attribute2 = TO_CHAR(pih.contract_id)
                            AND rct.interface_line_attribute5 = TO_CHAR(pil.invoice_line_id)
                            AND petv.expenditure_type_id = pei.expenditure_type_id
                            AND pild.transaction_id = pei.expenditure_item_id
                            AND pild.transaction_project_id = pei.project_id
                            AND trx.customer_trx_id = ract.customer_trx_id
                            AND rct.customer_trx_line_id = ractl.customer_trx_line_id
                            AND pild.transaction_task_id = pei.task_id
                            AND pild.transaction_project_id = pei.project_id
                            AND pih.invoice_id = pild.invoice_id
                            AND pil.invoice_line_id = pild.invoice_line_id
                        GROUP BY
                            pild.invoice_line_id
                    ) )
                    ELSE ( DECODE(ractl.line_type,'TAX',NULL,TO_CHAR(NVL(ractl.quantity_invoiced,ractl.quantity_credited) ) ) )
                END
            )
            ELSE ( DECODE(ractl.line_type,'TAX',NULL,TO_CHAR(NVL(ractl.quantity_invoiced,ractl.quantity_credited) ) ) )
        END
    ) AS quantity,
    (
        CASE
            WHEN ractl.org_id NOT IN (
                SELECT
                    hou.organization_id
                FROM
                    FND_LOOKUP_VALUES flv,
                    HR_OPERATING_UNITS hou
                WHERE
                    flv.lookup_type = 'GED_BU_NAMES'
                    AND LANGUAGE = 'US'
                    AND flv.enabled_flag = 'Y'
                    AND UPPER(flv.description) = 'AVIATION'
                    AND NVL(flv.start_date_active,SYSDATE) <= SYSDATE
                    AND NVL(flv.end_date_active,SYSDATE) >= SYSDATE
                    AND flv.lookup_code = hou.short_code
            ) THEN (
                CASE
                    WHEN ( (
                        SELECT DISTINCT
                            petv.expenditure_type_name
                        FROM
                            PJB_INVOICE_HEADERS pih,
                            PJB_INVOICE_LINES pil,
                            RA_CUSTOMER_TRX_ALL trx,
                            RA_CUSTOMER_TRX_LINES_ALL rct,
                            PJF_EXP_TYPES_VL petv,
                            PJC_EXP_ITEMS_ALL pei,
                            PJB_INV_LINE_DISTS pild
                        WHERE
                            pih.invoice_id = pil.invoice_id
                            AND pih.ra_invoice_number = trx.trx_number
                            AND rct.customer_trx_id = trx.customer_trx_id
                            AND rct.interface_line_attribute2 = TO_CHAR(pih.contract_id)
                            AND rct.interface_line_attribute5 = TO_CHAR(pil.invoice_line_id)
                            AND petv.expenditure_type_id = pei.expenditure_type_id
                            AND pild.transaction_id = pei.expenditure_item_id
                            AND pild.transaction_project_id = pei.project_id
                            AND pild.transaction_task_id = pei.task_id
                            AND pild.transaction_project_id = pei.project_id
                            AND pih.invoice_id = pild.invoice_id
                            AND pil.invoice_line_id = pild.invoice_line_id
                            AND rct.customer_trx_line_id = ractl.customer_trx_line_id
                            AND rct.customer_trx_id = ract.customer_trx_id
                    ) IN (
                        'Labor',
                        'Contractor Labor'
                    ) ) THEN TO_CHAR( (
                        SELECT DISTINCT
                            pild.bill_rate
                        FROM
                            PJB_INVOICE_HEADERS pih,
							PJB_INVOICE_LINES pil,
							RA_CUSTOMER_TRX_ALL trx,
							RA_CUSTOMER_TRX_LINES_ALL rct,
							PJF_EXP_TYPES_VL petv,
							PJC_EXP_ITEMS_ALL pei,
							PJB_INV_LINE_DISTS pild
                        WHERE
                            1 = 1
                            AND pih.invoice_id = pil.invoice_id
                            AND pih.ra_invoice_number = trx.trx_number
                            AND rct.customer_trx_id = trx.customer_trx_id
                            AND rct.interface_line_attribute2 = TO_CHAR(pih.contract_id)
                            AND rct.interface_line_attribute5 = TO_CHAR(pil.invoice_line_id)
                            AND petv.expenditure_type_id = pei.expenditure_type_id
                            AND pild.transaction_id = pei.expenditure_item_id
                            AND pild.transaction_project_id = pei.project_id
                            AND pild.transaction_task_id = pei.task_id
                            AND pild.transaction_project_id = pei.project_id
                            AND pih.invoice_id = pild.invoice_id
                            AND pil.invoice_line_id = pild.invoice_line_id
                            AND rct.customer_trx_line_id = ractl.customer_trx_line_id
                            AND rct.customer_trx_id = ract.customer_trx_id
                    ) )
                    ELSE ( TO_CHAR(DECODE(ractl.unit_selling_price,0,NVL( (
                        SELECT
                            NVL(SUM(a.extended_amount),0) amt
                        FROM
                            RA_CUSTOMER_TRX_LINES_ALL a,
							DOO_FULFILL_LINES_ALL b
                        WHERE
                            1 = 1
                            AND a.inventory_item_id = b.inventory_item_id
                            AND a.interface_line_attribute5 = TO_CHAR(b.fulfill_line_id)
                            AND a.line_type = 'LINE'
                            AND b.root_parent_fulfill_line_id = osp.root_parent_fulfill_line_id
                            AND a.customer_trx_id = ractl.customer_trx_id -- REL-020 Service Now Case GEINC1703061 added
                        GROUP BY
                            b.root_parent_fulfill_line_id
                    ),0),ractl.unit_selling_price),FND_CURRENCY.GET_FORMAT_MASK(ract.invoice_currency_code,40) ) )
                END
            )
            ELSE ( TO_CHAR(DECODE(ractl.unit_selling_price,0,NVL( (
                SELECT
                    NVL(SUM(a.extended_amount),0) amt
                FROM
                    RA_CUSTOMER_TRX_LINES_ALL a,
					DOO_FULFILL_LINES_ALL b
                WHERE
                    1 = 1
                    AND a.inventory_item_id = b.inventory_item_id
                    AND a.interface_line_attribute5 = TO_CHAR(b.fulfill_line_id)
                    AND a.line_type = 'LINE'
                    AND b.root_parent_fulfill_line_id = osp.root_parent_fulfill_line_id
                    AND a.customer_trx_id = ractl.customer_trx_id -- REL-020 Service Now Case GEINC1703061 added
                GROUP BY
                    b.root_parent_fulfill_line_id
            ),0),ractl.unit_selling_price),FND_CURRENCY.GET_FORMAT_MASK(ract.invoice_currency_code,40) ) )
        END
    ) AS unit_price,
    TO_CHAR(DECODE( (
        SELECT
            NVL(SUM(extended_amount),0)
        FROM
            RA_CUSTOMER_TRX_LINES_ALL lines
        WHERE
            lines.customer_trx_line_id = ractl.customer_trx_line_id
            AND lines.line_type = 'LINE'
            AND UPPER(description) NOT LIKE '%WURLDTECH%TAX%LINE%'
            AND UPPER(description) NOT LIKE '%WT%GST/HST%TAX%'
            AND UPPER(description) NOT LIKE '%WT%PST%TAX%'
    ),0,NVL( (
        SELECT
            NVL(SUM(a.extended_amount),0) amt
        FROM
            RA_CUSTOMER_TRX_LINES_ALL a,
			DOO_FULFILL_LINES_ALL b
        WHERE
            1 = 1
            AND a.inventory_item_id = b.inventory_item_id
            AND a.interface_line_attribute5 = TO_CHAR(b.fulfill_line_id)
            AND a.line_type = 'LINE'
            AND b.root_parent_fulfill_line_id = osp.root_parent_fulfill_line_id
            AND a.customer_trx_id = ractl.customer_trx_id -- REL-020 Service Now Case GEINC1703061 added
        GROUP BY
            b.root_parent_fulfill_line_id
    ),0), (
        SELECT
            NVL(SUM(extended_amount),0)
        FROM
            RA_CUSTOMER_TRX_LINES_ALL lines
        WHERE
            lines.customer_trx_line_id = ractl.customer_trx_line_id
            AND lines.line_type = 'LINE'
            AND UPPER(description) NOT LIKE '%WURLDTECH%TAX%LINE%'
            AND UPPER(description) NOT LIKE '%WT%GST/HST%TAX%'
            AND UPPER(description) NOT LIKE '%WT%PST%TAX%'
    ) ),FND_CURRENCY.GET_FORMAT_MASK(ract.invoice_currency_code,40) ) extended_amount,
    CASE
            WHEN (
                osp.root_parent_fulfill_line_id IS NOT NULL
                AND osp.attribute24 = 'Y'
            ) THEN 'Y'
            WHEN ( osp.root_parent_fulfill_line_id IS NULL ) THEN 'Y'
            ELSE 'N'
        END
    AS OSP_FLAG,
    (
        CASE
            WHEN (
                SELECT
                    COUNT(1)
                FROM
                    FND_LOOKUP_VALUES_VL flv,
                    HR_ORGANIZATION_UNITS hou
                WHERE
                    lookup_type = 'CIRRUSAR_AED_AE_CM_LAYOUT'
                    AND flv.meaning = hou.name
                    AND hou.organization_id = ract.org_id
                    AND enabled_flag = 'Y'
                    AND TRUNC(SYSDATE) BETWEEN NVL(start_date_active,TRUNC(SYSDATE) ) AND NVL(end_date_active,TRUNC(SYSDATE) )
            ) > 0 THEN ( eitem.item_number
                         || '-'
                         || AR_BPA_UTILS_PKG.FN_GET_LINE_DESCRIPTION(ractl.customer_trx_line_id) )
            ELSE NVL(eitem.item_number,AR_BPA_UTILS_PKG.FN_GET_LINE_DESCRIPTION(ractl.customer_trx_line_id) )
        END
    ) AS item_number,
    (
        SELECT
            zl.tax_rate
        FROM
            ZX_LINES zl
        WHERE
            zl.trx_id = ract.customer_trx_id
            AND zl.trx_line_id = ractl.customer_trx_line_id
            AND ROWNUM = 1
    ) tax_rate,
    ract.invoice_currency_code currency_code
FROM
    RA_CUSTOMER_TRX_ALL ract,
    AR_RECEIVABLE_APPLICATIONS_all araa,
    RA_CUSTOMER_TRX_LINES_ALL ractl,
    RA_CUSTOMER_TRX_LINES_ALL c2,
    EGP_SYSTEM_ITEMS_B eitem,
    AR_SYSTEM_PARAMETERS_ALL sysp,
    (
        SELECT
            NVL(SUM(a.extended_amount),0) amt,
            b.root_parent_fulfill_line_id,
            c.attribute24,
            a.customer_trx_id,
            a.customer_trx_line_id,
            a.line_type
        FROM
            RA_CUSTOMER_TRX_LINES_ALL a,
            DOO_FULFILL_LINES_ALL b,
            EGP_SYSTEM_ITEMS_B c
        WHERE
            1 = 1
            AND a.inventory_item_id = b.inventory_item_id
            AND a.interface_line_attribute5 = TO_CHAR(b.fulfill_line_id)
            AND b.inventory_organization_id = c.organization_id
            AND b.inventory_item_id = c.inventory_item_id
            AND a.line_type = 'LINE'
        GROUP BY
            b.root_parent_fulfill_line_id,
            c.attribute24,
            a.customer_trx_id,
            a.customer_trx_line_id,
            a.line_type
    ) osp
WHERE
    ract.customer_trx_id (+) = araa.applied_customer_trx_id
    AND ract.customer_trx_id = ractl.customer_trx_id
    AND ractl.inventory_item_id = eitem.inventory_item_id (+)
    AND ractl.customer_trx_id = osp.customer_trx_id (+)
    AND ractl.customer_trx_line_id = osp.customer_trx_line_id (+)
    AND araa.display = 'Y'
    AND ractl.line_type = 'LINE'
    AND ractl.link_to_cust_trx_line_id = c2.customer_trx_line_id (+)
    AND ractl.org_id = sysp.org_id
    AND (
        (
            ractl.inventory_item_id IS NOT NULL
            AND sysp.item_validation_org_id = eitem.organization_id
        )
        OR ractl.inventory_item_id IS NULL
    )