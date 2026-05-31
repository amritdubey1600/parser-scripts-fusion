SELECT 
     del.customer_trx_id || '_' ||  del.payment_schedule_id  as "KEY",
     null TEMPLATE,
     'RTF' TEMPLATE_FORMAT,
     'PDF' OUTPUT_FORMAT,
     del.trx_number || '_' || del.terms_sequence_number output_name,
      del.delivery_method_code DEL_CHANNEL,
     --del.contact_email_address PARAMETER1,
	 'VernovaERPCloudNonProd@ge.com' As PARAMETER1,
     null   PARAMETER2,
     del.from_email_name || '<' ||del.from_email_address || '>'  PARAMETER3,
     del.email_subject  PARAMETER4,
     del.email_body PARAMETER5,
     'true' PARAMETER6,
     --del.reply_to_email_address  PARAMETER7
	 'VernovaERPCloudNonProd@ge.com' As PARAMETER7
FROM 
  AR_BPA_DELIVERY_DETAILS  del