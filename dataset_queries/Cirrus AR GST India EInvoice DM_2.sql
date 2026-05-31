SELECT 'ENG' as KEY
            ,'Cirrus AR GST India Einvoice Layout' as TEMPLATE
            ,'text' as "OUTPUT_FORMAT"
            ,'FTP' as "DEL_CHANNEL"
            ,'IRN_Details@SAP@' || TO_CHAR(SYSDATE, 'YYYYMMDDHHMMSS') || '.csv' as "OUTPUT_NAME"
            ,'true' as "SAVE_OUTPUT"
             ,FND_PROFILE.VALUE('CIRRUS_SFTP_EINV_PRD') as "PARAMETER1"
           -- ,'/data/pwc-meridium/Einvoice/meridium_To_Pwc/' as "PARAMETER4" --Removed for REL-103
			,'/meridium_to_pwc/' as "PARAMETER4" --Added for REL-103
            ,'IRN_Details@SAP@' || TO_CHAR(SYSDATE, 'YYYYMMDDHHMMSS') ||  '.csv' as "PARAMETER5"
            ,'true' as "PARAMETER6"
FROM SYS.dual