select d.CODE_COMBINATION_ID, d.CUSTOMER_TRX_ID, cc.segment1||'.'||cc.segment2||'.'||cc.segment3||'.'||cc.segment4||'.'||cc.segment5||'.'||cc.segment6||'.'||cc.segment7||'.'||cc.segment8||'.'||cc.segment9||'.'||cc.segment10||'.'||cc.segment11 REC_ACCOUNT , d.amount recamount
from RA_CUST_TRX_LINE_GL_DIST_ALL d, gl_code_combinations cc
where Account_Class = 'REC'
and d.CODE_COMBINATION_ID = cc.CODE_COMBINATION_ID