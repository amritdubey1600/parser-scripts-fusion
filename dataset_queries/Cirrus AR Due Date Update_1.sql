/*
--#-----------------------------------------------------------------------------------------------------#
--# MODIFICATION HISTORY:
--# CR#              Author               Date        Description
--#-----------------------------------------------------------------------------------------------------#
--# REL-015  		Jepson Erattuparmbil  04-APR-2018 Cirrus AR Due Date Update Report                --#                                                                                  when IME required flag is '%C'.
--#
--#-----------------------------------------------------------------------------------------------------#
*/

SELECT d.name "ledger Name",
       c.bu_name "bu",
       a.trx_number "invoice no",
       TO_CHAR(a.trx_date, 'MM-DD-YYYY') "invoice dt",
       TO_CHAR(a.gl_date, 'MM-DD-YYYY') "gl date",
       e.account_name "customer name",
       a.invoice_currency_code "currency",
       a.amount_due_original "amt original",
       a.amount_applied "amt applied",
       a.amount_due_remaining "amt remaining",
       TO_CHAR(a.due_date, 'MM-DD-YYYY') "due Date",
       b.comments "change comment",
       TO_CHAR(a.last_update_date, 'MM-DD-YYYY') "last update dt",
       a.last_updated_by "last update by",
       a.status "status",
       a.class "class",
       a.payment_schedule_id "schedule id",
       a.term_id "term id",
       a.created_by "created by",
       to_char(a.creation_date, 'MM-DD-YYYY') "creation dt"
  FROM AR_PAYMENT_SCHEDULES_ALL a,
       RA_CUSTOMER_TRX_ALL      b,
       FUN_ALL_BUSINESS_UNITS_V c,
       GL_LEDGERS               d,
       HZ_CUST_ACCOUNTS         e
 WHERE a.trx_number = b.trx_number
   AND a.org_id = c.bu_id
   AND d.ledger_id = c.primary_ledger_id
   AND a.customer_id = e.cust_account_id
   AND b.comments IS NOT NULL
   AND c.bu_name = DECODE(:business_unit, NULL, c.bu_name, :business_unit)
   AND d.name = DECODE(:ledger, NULL, d.name, :ledger)
   AND TRUNC(a.last_update_date) >= TO_DATE(:last_update_date, 'YYYY-MM-DD')