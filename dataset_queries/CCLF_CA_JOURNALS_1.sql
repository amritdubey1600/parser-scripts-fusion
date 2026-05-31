SELECT        G.name                  ledger_name,
              TO_CHAR(G.ledger_id)    ledger_id,
              g.short_name            ledger_short_name,
              g.ledger_category_code  ledger_category_code,
              g.currency_code         ledger_currency_code,
              TO_CHAR(E.je_batch_id)  batch_id,
              TO_CHAR(e.group_id)      group_id,
              E.name                  batch_name,
              REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(E.description,',',';'), CHR(13), ' '), CHR(10), ' '),CHR(9), ' '),CHR(160),' ') batch_description ,
              TO_CHAR(A.je_header_id) journal_id,
              A.name                  journal_name,
              REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(a.description,',',';'), CHR(13), ' '), CHR(10), ' '),CHR(9), ' '),CHR(160),' ') journal_description,
              C.user_je_source_name   user_je_source_name,
              d.user_je_category_name user_je_category_name,
              a.period_name           period_name,
              TO_CHAR(A.default_effective_date,'YYYYMMDD HH24:MI:SS') effective_date,
              E.last_updated_by       posted_by,
              TO_CHAR(A.posted_date,'YYYYMMDD HH24:MI:SS') posted_date,
              A.status                status,
              b.currency_code         currency_code,
              DECODE(A.currency_conversion_type,'Corporate', 'Corporate', 'EMU FIXED', 'EMU FIXED','Spot', 'Spot','User', 'User','30000000134004','MOR','30000000134004','GAP') user_currency_conversion_type,
              TO_CHAR(B.je_line_num)  je_line_num,
              TO_CHAR(B.effective_date,'YYYYMMDD HH24:MI:SS') line_effective_date,
              TO_CHAR(B.code_combination_id) code_combination_id,
              REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(B.description,',',';'), CHR(13), ' '), CHR(10), ' '),CHR(9), ' '),CHR(160),' ') line_description,
              F.segment1  company_code,
              F.segment2  account,
              F.segment3  trading_partner,
              F.segment4  cost_center,
              F.segment5  geography,
              F.segment6  project_code,
              F.segment7  reference_code,
              F.segment8  product_line,
              F.segment9  book_type,
              F.segment10 future1,
              F.segment11 future2,
              TO_CHAR(entered_dr)                            entered_debit,
              TO_CHAR(entered_cr)                            entered_credit,
              TO_CHAR(accounted_dr)                          accounted_debit,
              TO_CHAR(accounted_cr)                          accounted_credit,
              TO_CHAR(NVL(entered_dr,0) - NVL(entered_cr,0)) entered_amount,
              TO_CHAR(NVL(accounted_dr,0) - NVL(accounted_cr,0)) accounted_amount,
              B.attribute1,
              B.attribute2,
              B.attribute3,
              B.attribute4,
              B.attribute5,
              B.attribute6,
              B.attribute7,
              B.attribute8,
              B.attribute9,
              B.attribute10,
              B.attribute11,
              B.attribute12,
              B.attribute13,
              B.attribute14,
              B.attribute15,
              B.attribute16,
              B.attribute17,
              B.attribute18,
              B.attribute19,
              B.attribute20, 
              A.created_by              created_by, 
              TO_CHAR(A.creation_date,'YYYYMMDD HH24:MI:SS') creation_date,
              B.last_updated_by         last_updated_by,
              TO_CHAR(E.last_update_date,'YYYYMMDD HH24:MI:SS') last_update_date
     FROM     gl_je_headers a,
              gl_je_lines b,
              gl_je_sources c,
              gl_je_categories d,
              gl_je_batches e,
              gl_code_combinations f,
              gl_ledgers g,
              fnd_flex_values fvv,          
              fnd_flex_value_sets fvs
              --,gl_lookups k
    WHERE     A.je_header_id          = B.je_header_id
      AND     fvv.flex_value_set_id   =  fvs.flex_value_set_id
      AND     fvs.flex_value_set_name = 'CCL_COMPANY_CODES'  
      AND     fvv.flex_value          = f.segment1
      AND     A.je_source             = C.je_source_name
      AND     A.je_category           = D.je_category_name
      AND     E.je_batch_id           = A.je_batch_id
      AND     B.code_combination_id   = F.code_combination_id
      AND     g.name LIKE '%PRM'
      AND     :P_TYPE ='P'
      AND  ((b.period_name = :P_PERIOD AND :P_PERIOD IS NOT NULL) OR
            (b.period_name = g.latest_opened_period_name AND :P_PERIOD IS NULL))
      AND  ((F.segment1 = :P_COMPANY AND :P_COMPANY IS NOT NULL) OR
            (1 = 1 AND :P_COMPANY IS NULL))
      AND  ((C.user_je_source_name  = :P_JE_SOURCE AND :P_JE_SOURCE IS NOT NULL) OR
            (1 = 1 AND :P_JE_SOURCE IS NULL))
      AND     A.ledger_id             = G.ledger_id
--      AND     K.lookup_code           = E.approval_status_code
--      AND     e.status                = 'P'
--      AND     K.lookup_type           = 'JE_BATCH_APPROVAL_STATUS'
    UNION ALL
SELECT        G.name                  ledger_name,
              TO_CHAR(G.ledger_id)    ledger_id,
              g.short_name            ledger_short_name,
              g.ledger_category_code  ledger_category_code,
              g.currency_code         ledger_currency_code,
              TO_CHAR(E.je_batch_id)  batch_id,
              TO_CHAR(e.group_id)      group_id,
              E.name                  batch_name,
              REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(E.description,',',';'), CHR(13), ' '), CHR(10), ' '),CHR(9), ' '),CHR(160),' ') batch_description ,
              TO_CHAR(A.je_header_id) journal_id,
              A.name                  journal_name,
              REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(a.description,',',';'), CHR(13), ' '), CHR(10), ' '),CHR(9), ' '),CHR(160),' ') journal_description,
              C.user_je_source_name   user_je_source_name,
              d.user_je_category_name user_je_category_name,
              a.period_name           period_name,
              TO_CHAR(A.default_effective_date,'YYYYMMDD HH24:MI:SS') effective_date,
              E.last_updated_by       posted_by,
              TO_CHAR(A.posted_date,'YYYYMMDD HH24:MI:SS') posted_date,
              A.status                status,
              b.currency_code         currency_code,
              DECODE(A.currency_conversion_type,'Corporate', 'Corporate', 'EMU FIXED', 'EMU FIXED','Spot', 'Spot','User', 'User','30000000134004','MOR','30000000134004','GAP') user_currency_conversion_type,
              TO_CHAR(B.je_line_num)  je_line_num,
              TO_CHAR(B.effective_date,'YYYYMMDD HH24:MI:SS') line_effective_date,
              TO_CHAR(B.code_combination_id) code_combination_id,
              REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(B.description,',',';'), CHR(13), ' '), CHR(10), ' '),CHR(9), ' '),CHR(160),' ') line_description,
              F.segment1  company_code,
              F.segment2  account,
              F.segment3  trading_partner,
              F.segment4  cost_center,
              F.segment5  geography,
              F.segment6  project_code,
              F.segment7  reference_code,
              F.segment8  product_line,
              F.segment9  book_type,
              F.segment10 future1,
              F.segment11 future2,
              TO_CHAR(entered_dr)                            entered_debit,
              TO_CHAR(entered_cr)                            entered_credit,
              TO_CHAR(accounted_dr)                          accounted_debit,
              TO_CHAR(accounted_cr)                          accounted_credit,
              TO_CHAR(NVL(entered_dr,0) - NVL(entered_cr,0)) entered_amount,
              TO_CHAR(NVL(accounted_dr,0) - NVL(accounted_cr,0)) accounted_amount,
              B.attribute1,
              B.attribute2,
              B.attribute3,
              B.attribute4,
              B.attribute5,
              B.attribute6,
              B.attribute7,
              B.attribute8,
              B.attribute9,
              B.attribute10,
              B.attribute11,
              B.attribute12,
              B.attribute13,
              B.attribute14,
              B.attribute15,
              B.attribute16,
              B.attribute17,
              B.attribute18,
              B.attribute19,
              B.attribute20, 
              A.created_by              created_by, 
              TO_CHAR(A.creation_date,'YYYYMMDD HH24:MI:SS') creation_date,
              B.last_updated_by         last_updated_by,
              TO_CHAR(E.last_update_date,'YYYYMMDD HH24:MI:SS') last_update_date
     FROM     gl_je_headers a,
              gl_je_lines b,
              gl_je_sources c,
              gl_je_categories d,
              gl_je_batches e,
              gl_code_combinations f,
              gl_ledgers g,
              fnd_flex_values fvv,          
              fnd_flex_value_sets fvs
              --,gl_lookups k
    WHERE     A.je_header_id          = B.je_header_id
      AND     fvv.flex_value_set_id   =  fvs.flex_value_set_id
      AND     fvs.flex_value_set_name = 'CCL_COMPANY_CODES'  
      AND     fvv.flex_value          = f.segment1
      AND     A.je_source             = C.je_source_name
      AND     A.je_category           = D.je_category_name
      AND     E.je_batch_id           = A.je_batch_id
      AND     B.code_combination_id   = F.code_combination_id
      AND     g.name LIKE '%FCY' 
      AND   :P_TYPE ='F'
      AND  ((b.period_name = :P_PERIOD AND :P_PERIOD IS NOT NULL) OR
            (b.period_name = g.latest_opened_period_name AND :P_PERIOD IS NULL))
      AND  ((F.segment1 = :P_COMPANY AND :P_COMPANY IS NOT NULL) OR
            (1 = 1 AND :P_COMPANY IS NULL))
      AND  ((C.user_je_source_name  = :P_JE_SOURCE AND :P_JE_SOURCE IS NOT NULL) OR
            (1 = 1 AND :P_JE_SOURCE IS NULL))
      AND     A.ledger_id             = G.ledger_id    
    UNION ALL
     SELECT   G.name                  ledger_name,
              TO_CHAR(G.ledger_id)    ledger_id,
              g.short_name            ledger_short_name,
              g.ledger_category_code  ledger_category_code,
              g.currency_code         ledger_currency_code,
              TO_CHAR(E.je_batch_id)  batch_id,
              TO_CHAR(e.group_id)      group_id,
              E.name                  batch_name,
              REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(E.description,',',';'), CHR(13), ' '), CHR(10), ' '),CHR(9), ' '),CHR(160),' ') batch_description ,
              TO_CHAR(A.je_header_id) journal_id,
              A.name                  journal_name,
              REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(a.description,',',';'), CHR(13), ' '), CHR(10), ' '),CHR(9), ' '),CHR(160),' ') journal_description,
              C.user_je_source_name   user_je_source_name,
              d.user_je_category_name user_je_category_name,
              a.period_name           period_name,
              TO_CHAR(A.default_effective_date,'YYYYMMDD HH24:MI:SS') effective_date,
              E.last_updated_by       posted_by,
              TO_CHAR(A.posted_date,'YYYYMMDD HH24:MI:SS') posted_date,
              A.status                status,
              b.currency_code         currency_code,
              DECODE(A.currency_conversion_type,'Corporate', 'Corporate', 'EMU FIXED', 'EMU FIXED','Spot', 'Spot','User', 'User','30000000134004','MOR','30000000134004','GAP') user_currency_conversion_type,
              TO_CHAR(B.je_line_num)  je_line_num,
              TO_CHAR(B.effective_date,'YYYYMMDD HH24:MI:SS') line_effective_date,
              TO_CHAR(B.code_combination_id) code_combination_id,
              REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(B.description,',',';'), CHR(13), ' '), CHR(10), ' '),CHR(9), ' '),CHR(160),' ') line_description,
              F.segment1  company_code,
              F.segment2  account,
              F.segment3  trading_partner,
              F.segment4  cost_center,
              F.segment5  geography,
              F.segment6  project_code,
              F.segment7  reference_code,
              F.segment8  product_line,
              F.segment9  book_type,
              F.segment10 future1,
              F.segment11 future2,
              TO_CHAR(entered_dr)                            entered_debit,
              TO_CHAR(entered_cr)                            entered_credit,
              TO_CHAR(accounted_dr)                          accounted_debit,
              TO_CHAR(accounted_cr)                          accounted_credit,
              TO_CHAR(NVL(entered_dr,0) - NVL(entered_cr,0)) entered_amount,
              TO_CHAR(NVL(accounted_dr,0) - NVL(accounted_cr,0)) accounted_amount,
              B.attribute1,
              B.attribute2,
              B.attribute3,
              B.attribute4,
              B.attribute5,
              B.attribute6,
              B.attribute7,
              B.attribute8,
              B.attribute9,
              B.attribute10,
              B.attribute11,
              B.attribute12,
              B.attribute13,
              B.attribute14,
              B.attribute15,
              B.attribute16,
              B.attribute17,
              B.attribute18,
              B.attribute19,
              B.attribute20, 
              A.created_by              created_by, 
              TO_CHAR(A.creation_date,'YYYYMMDD HH24:MI:SS') creation_date,
              B.last_updated_by         last_updated_by,
              TO_CHAR(E.last_update_date,'YYYYMMDD HH24:MI:SS') last_update_date
     FROM     gl_je_headers a,
              gl_je_lines b,
              gl_je_sources c,
              gl_je_categories d,
              gl_je_batches e,
              gl_code_combinations f,
              gl_ledgers g
              --,gl_lookups k
     WHERE    A.je_header_id         = B.je_header_id
       AND    A.je_source            = C.je_source_name
       AND    A.je_category          = D.je_category_name
       AND    E.je_batch_id          = A.je_batch_id
       AND    B.code_combination_id  = F.code_combination_id
       AND    g.name like '%RPT'
       AND    g.currency_code        = 'USD'
       AND    g.ledger_category_code =   'ALC' 
       AND   :P_TYPE ='R'
       AND    upper(g.description) LIKE '%REPORTING%'		
      AND  ((b.period_name = :P_PERIOD AND :P_PERIOD IS NOT NULL) OR
            (b.period_name = g.latest_opened_period_name AND :P_PERIOD IS NULL))
      AND  ((F.segment1 = :P_COMPANY AND :P_COMPANY IS NOT NULL) OR
            (1 = 1 AND :P_COMPANY IS NULL))
      AND  ((C.user_je_source_name  = :P_JE_SOURCE AND :P_JE_SOURCE IS NOT NULL) OR
            (1 = 1 AND :P_JE_SOURCE IS NULL))
       AND    A.ledger_id            = G.ledger_id
--       AND    K.lookup_code          = E.approval_status_code
--       AND    e.status               = 'P'
--       AND    K.lookup_type          = 'JE_BATCH_APPROVAL_STATUS'
    UNION ALL
     SELECT   G.name                  ledger_name,
              TO_CHAR(G.ledger_id)    ledger_id,
              g.short_name            ledger_short_name,
              g.ledger_category_code  ledger_category_code,
              g.currency_code         ledger_currency_code,
              TO_CHAR(E.je_batch_id)  batch_id,
              TO_CHAR(e.group_id)      group_id,
              E.name                  batch_name,
              REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(E.description,',',';'), CHR(13), ' '), CHR(10), ' '),CHR(9), ' '),CHR(160),' ') batch_description ,
              TO_CHAR(A.je_header_id) journal_id,
              A.name                  journal_name,
              REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(a.description,',',';'), CHR(13), ' '), CHR(10), ' '),CHR(9), ' '),CHR(160),' ') journal_description,
              C.user_je_source_name   user_je_source_name,
              d.user_je_category_name user_je_category_name,
              a.period_name           period_name,
              TO_CHAR(A.default_effective_date,'YYYYMMDD HH24:MI:SS') effective_date,
              E.last_updated_by       posted_by,
              TO_CHAR(A.posted_date,'YYYYMMDD HH24:MI:SS') posted_date,
              A.status                status,
              b.currency_code         currency_code,
              DECODE(A.currency_conversion_type,'Corporate', 'Corporate', 'EMU FIXED', 'EMU FIXED','Spot', 'Spot','User', 'User','30000000134004','MOR','30000000134004','GAP') user_currency_conversion_type,
              TO_CHAR(B.je_line_num)  je_line_num,
              TO_CHAR(B.effective_date,'YYYYMMDD HH24:MI:SS') line_effective_date,
              TO_CHAR(B.code_combination_id) code_combination_id,
              REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(B.description,',',';'), CHR(13), ' '), CHR(10), ' '),CHR(9), ' '),CHR(160),' ') line_description,
              F.segment1  company_code,
              F.segment2  account,
              F.segment3  trading_partner,
              F.segment4  cost_center,
              F.segment5  geography,
              F.segment6  project_code,
              F.segment7  reference_code,
              F.segment8  product_line,
              F.segment9  book_type,
              F.segment10 future1,
              F.segment11 future2,
              TO_CHAR(entered_dr)                            entered_debit,
              TO_CHAR(entered_cr)                            entered_credit,
              TO_CHAR(accounted_dr)                          accounted_debit,
              TO_CHAR(accounted_cr)                          accounted_credit,
              TO_CHAR(NVL(entered_dr,0) - NVL(entered_cr,0)) entered_amount,
              TO_CHAR(NVL(accounted_dr,0) - NVL(accounted_cr,0)) accounted_amount,
              B.attribute1,
              B.attribute2,
              B.attribute3,
              B.attribute4,
              B.attribute5,
              B.attribute6,
              B.attribute7,
              B.attribute8,
              B.attribute9,
              B.attribute10,
              B.attribute11,
              B.attribute12,
              B.attribute13,
              B.attribute14,
              B.attribute15,
              B.attribute16,
              B.attribute17,
              B.attribute18,
              B.attribute19,
              B.attribute20, 
              A.created_by              created_by, 
              TO_CHAR(A.creation_date,'YYYYMMDD HH24:MI:SS') creation_date,
              B.last_updated_by         last_updated_by,
              TO_CHAR(E.last_update_date,'YYYYMMDD HH24:MI:SS') last_update_date
     FROM     gl_je_headers a,
              gl_je_lines b,
              gl_je_sources c,
              gl_je_categories d,
              gl_je_batches e,
              gl_code_combinations f,
              gl_ledgers g
              --,gl_lookups k
     WHERE    A.je_header_id           = B.je_header_id
      AND     A.je_source              = C.je_source_name
      AND     A.je_category            = D.je_category_name
      AND     E.je_batch_id            = A.je_batch_id
      AND     B.code_combination_id    = F.code_combination_id
      AND     g.name like '%STA'
      AND   :P_TYPE ='S'
      AND     g.ledger_category_code   =   'SECONDARY' 
      AND     upper(g.description)   LIKE '%STATUTORY%'		
      AND  ((b.period_name = :P_PERIOD AND :P_PERIOD IS NOT NULL) OR
            (b.period_name = g.latest_opened_period_name AND :P_PERIOD IS NULL))
      AND  ((F.segment1 = :P_COMPANY AND :P_COMPANY IS NOT NULL) OR
            (1 = 1 AND :P_COMPANY IS NULL))
      AND  ((C.user_je_source_name  = :P_JE_SOURCE AND :P_JE_SOURCE IS NOT NULL) OR
            (1 = 1 AND :P_JE_SOURCE IS NULL))
      AND     A.ledger_id              = G.ledger_id
--      AND     K.lookup_code            = E.approval_status_code
--      AND     e.status                 = 'P'
--      AND     K.lookup_type            = 'JE_BATCH_APPROVAL_STATUS'
ORDER BY 10 desc