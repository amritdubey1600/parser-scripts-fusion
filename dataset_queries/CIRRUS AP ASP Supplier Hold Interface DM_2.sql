SELECT aia.invoice_num AS "KEY"
       ,'text' AS "OUTPUT_FORMAT"
       ,'FTP' AS "DEL_CHANNEL"
       ,'GED_RECPT_CONFIRM.' || aia.invoice_num || '.' ||
       to_char(SYSDATE, 'MMDDYYYYhh24MISS') || '.txt' AS "OUTPUT_NAME"
       ,'true' AS "SAVE_OUTPUT"
       --,fnd_profile.value('MFT_ICS_SFTP') AS "PARAMETER1"
	   ,(SELECT description
				FROM fnd_lookup_values 
				WHERE lookup_type = 'VER_MFT_ICS_BURST_PROGS'
				AND lookup_code = 'VNF_GED_RECPT_CONFIRM'
				AND enabled_flag = 'Y'
				AND Language = 'US') as "PARAMETER1"  -- fusion clone and convey to vernova
       ,:P_DEST_DIR AS "PARAMETER4"
       	-- REL027 GERITM2630995-commented --,'GED_RECPT_CONFIRM.' || aia.invoice_num || '.' ||
	,'GED_RECPT_CONFIRM.' || REPLACE(aia.invoice_num, '/', '.') || '.' || -- REL027 GERITM2630995-added
       to_char(SYSDATE, 'MMDDYYYYhh24MISS') || '.txt' AS "PARAMETER5"
       ,'true' AS "PARAMETER6"
FROM   ap_invoices_all aia