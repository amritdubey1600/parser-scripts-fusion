select l.name, l.ledger_id, l.chart_of_accounts_id, l.currency_code, cc.segment1 seg1,
    sum(nvl(begin_balance_dr, 0)), sum(nvl(begin_balance_cr, 0)),
    sum(nvl(period_net_dr, 0)), sum(nvl(period_net_cr, 0))
from gl_balances bal,
     gl_code_combinations cc,
     gl_ledgers l,
     gl_period_statuses ps
where bal.period_name = :P_PERIOD_NAME
and bal.ledger_id = l.ledger_id
and bal.code_combination_id = cc.code_combination_id
and bal.actual_flag = 'A'
and bal.template_id is null
and bal.translated_flag is null
and bal.currency_code = l.currency_code
and ps.application_id = 101
and ps.ledger_id = bal.ledger_id
and ps.period_name = bal.period_name
and cc.chart_of_accounts_id = l.chart_of_accounts_id
group by l.name, l.ledger_id, l.chart_of_accounts_id, l.currency_code, cc.segment1, bal.period_name
having sum(nvl(begin_balance_dr, 0) - nvl(begin_balance_cr, 0) + nvl(period_net_dr, 0) - nvl(period_net_cr, 0)) != 0
order by l.name, cc.segment1