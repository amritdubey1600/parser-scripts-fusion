SELECT 'NEW' Status_Code,
      -- g.ledger_id ledger_id,
        '300000002118105'  ledger_id,
       TO_CHAR (A.default_effective_date, 'YYYY/MM/DD') effective_date,
       'CCL_ASSETS_RC' Journal_Source,
       d.user_je_category_name Journal_Category,
       a.currency_code,
       TO_CHAR (A.default_effective_date, 'YYYY/MM/DD') journal_entry_creation_date,
       'A' Actual_flag,
       f.segment1 company_code,
       f.segment2 account,
       f.segment3 trading_partner,
       f.segment4 cost_center,
       f.segment5 geography,
       f.segment6 project_code,
       f.segment7 reference_code,
       f.segment8 product_line,
       f.segment9 book_type,
       f.segment10 future1,
       f.segment11 future2,
       NULL segment12,
       NULL segment13,
       NULL segment14,
       NULL segment15,
       NULL segment16,
       NULL segment17,
       NULL segment18,
       NULL segment19,
       NULL segment20,
       NULL segment21,
       NULL segment22,
       NULL segment23,
       NULL segment24,
       NULL segment25,
       NULL segment26,
       NULL segment27,
       NULL segment28,
       NULL segment29,
       NULL segment30,
       TO_CHAR (entered_dr) Entered_Debit_Amount,
       TO_CHAR (entered_cr) Entered_Credit_Amount,
       NULL Converted_Debit_Amount,
       NULL Converted_Credit_Amount,
       NULL REFERENCE1_batch_name,
       NULL REFERENCE1_batch_description,
       NULL REFERENCE3,
       a.name reference4,
       NULL REFERENCE5,
       NULL reference6,
       'N' reference7_je_reversal_flag,
       NULL reference8,
       'N' reference9_journal_REVERSAL,
       e.je_batch_id
       || '|'
       || a.je_header_id
       || '| RC of '
       || g.name
       || ':'
       || e.name reference10_JE_line_des,
       NULL reference_column_1,
       NULL reference_column_2,
       NULL reference_column_3,
       NULL reference_column_4,
       NULL reference_column_5,
       NULL reference_column_6,
       NULL reference_column_7,
       NULL reference_column_8,
       NULL reference_column_9,
       NULL reference_column_10,
       NULL statistical_amount,
       'MOR' currency_conversion_type,
       TO_CHAR (A.default_effective_date, 'YYYY/MM/DD')
          currency_conversion_date,
       NULL currency_conversion_rate,
       '222222' interface_group_identifier,
       NULL context_field,
       NULL attribute1,
       NULL attribute2,
       NULL attribute3,
       NULL attribute4,
       NULL attribute5,
       NULL attribute6,
       NULL attribute7,
       NULL attribute8,
       NULL attribute9,
       NULL attribute10,
	   NULL Context_field_for_DFF,
       NULL attribute11,
       NULL attribute12,
       NULL attribute13,
       NULL attribute14,
       NULL attribute15,
       NULL attribute16,
       NULL attribute17,
       NULL attribute18,
       NULL attribute19,
       NULL attribute20,
       NULL average_journal_flag,
       NULL clearing_company
  FROM gl_je_headers a,
       gl_je_lines b,
       gl_je_sources c,
       gl_je_categories d,
       gl_je_batches e,
       gl_code_combinations f,
       gl_ledgers g,
       fnd_flex_values fvv,
       fnd_flex_value_sets fvs
 WHERE A.je_header_id = B.je_header_id
       AND A.je_source = C.je_source_name
       AND A.je_category = D.je_category_name
       AND E.je_batch_id = A.je_batch_id
       AND B.code_combination_id = F.code_combination_id
       AND (g.name LIKE 'CA%PRM' OR g.name LIKE 'CA%FCY')
       AND A.ledger_id = G.ledger_id
       AND UPPER (c.user_je_source_name) = 'ASSETS' 
       AND fvs.flex_value_set_name = 'CCL_COMPANY_CODES'
       AND fvv.flex_value = f.segment1
       AND fvv.attribute5 = a.currency_code  
       AND ((F.segment1 = :P_COMPANY_CODE AND :P_COMPANY_CODE IS NOT NULL) OR
            (1 = 1 AND :P_COMPANY_CODE IS NULL))
       AND ( (b.period_name = :P_PERIOD AND :P_PERIOD IS NOT NULL)
            OR (b.period_name = g.latest_opened_period_name
                AND :P_PERIOD IS NULL))
     AND NOT EXISTS
                  (SELECT (1)
                     FROM gl_je_headers A1,
                          gl_je_lines b1,
                          gl_je_sources c1,
                          gl_je_categories d1,
                          gl_je_batches e1,
                          gl_code_combinations f1,
                          gl_ledgers g1,
                          fnd_flex_values fvv1,
                          fnd_flex_value_sets fvs1
                    WHERE     A1.je_header_id = B1.je_header_id
                          AND A1.je_source = C1.je_source_name
                          AND A1.je_category = D1.je_category_name
                          AND E1.je_batch_id = A1.je_batch_id
                          AND B1.code_combination_id = F1.code_combination_id
                          AND (g1.name LIKE 'CA%RPT')
                          AND A1.ledger_id = G1.ledger_id
                          AND UPPER (c1.user_je_source_name) = 'CCL_ASSETS_RC'
                          AND fvs1.flex_value_set_name = 'CCL_COMPANY_CODES'
                          AND fvv1.flex_value = f1.segment1
                          AND fvv1.attribute5 = a1.currency_code
						  AND ((fvv1.attribute5 = 'USD' AND g1.name LIKE 'CA%FCY') OR  
                               (fvv1.attribute5 = 'CAD' AND g1.name LIKE 'CA%PRM'))
                          AND ((f1.segment1 = :P_COMPANY_CODE AND :P_COMPANY_CODE IS NOT NULL) OR
                                 (1 = 1 AND :P_COMPANY_CODE IS NULL))
                          AND ( (b1.period_name = :P_PERIOD
                                 AND :P_PERIOD IS NOT NULL)
                               OR (b1.period_name =
                                      g1.latest_opened_period_name
                                   AND :P_PERIOD IS NULL))
                          AND A1.NAME LIKE
                                    e1.je_batch_id
                                 || '|'
                                 || a1.je_header_id)