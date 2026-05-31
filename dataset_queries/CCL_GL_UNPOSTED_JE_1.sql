select l.name ledger
, js.user_je_source_name journal_source
, jeb.name batch
, to_char(jeb.creation_date,'DD-MON-RRRR') creation_date
, jeb.created_by
, jeh.name journal
, jeh.period_name period
, jel.je_line_num line_no
, glcc1.segment1 company
, glcc1.segment2 account
, glcc1.segment1||'-'||glcc1.segment2||'-'||glcc1.segment3||'-'||glcc1.segment4||'-'||glcc1.segment5||'-'||glcc1.segment6||'-'||glcc1.segment7||'-'||glcc1.segment8||'-'||glcc1.segment9||'-'||glcc1.segment10||'-'||glcc1.segment11 account_combination
, jel.currency_code currency
, to_char(jel.currency_conversion_date,'DD-MON-RRRR') conversion_date
, jel.currency_conversion_type conversion_type
, jel.currency_conversion_rate  conversion_rate
, jel.entered_dr
, jel.entered_cr
, jel.accounted_dr
, jel.accounted_cr
from gl_je_batches jeb
, gl_je_headers jeh
, gl_je_lines jel
, gl_ledgers l
, gl_code_combinations glcc1
, gl_je_sources_tl js
where jeb.je_batch_id = jeh.je_batch_id
and jeh.je_header_id = jel.je_header_id
and jel.ledger_id = l.ledger_id
and jel.code_combination_id = glcc1.code_combination_id
and jeb.je_source = js.je_source_name
and js.language = 'US'
and jeb.status <> 'P'