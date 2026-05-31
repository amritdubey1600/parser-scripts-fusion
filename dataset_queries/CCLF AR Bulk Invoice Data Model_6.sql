SELECT rct.trx_number  AS "KEY"
            ,'PDF' AS OUTPUT_FORMAT
            ,'FTP' as "DEL_CHANNEL"
            ,'CCLF_CUSTINV_CA_' || rct.trx_number || '_' || TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS') || '.pdf' as "OUTPUT_NAME"
            ,'true' as "SAVE_OUTPUT"
            -- ,FND_PROFILE.VALUE('CCLF_BI_SFTP_SERVER') as "PARAMETER1"  DISABLED -- July 16th, 2020
            ,:P_DEST_DIR as "PARAMETER4"
            ,'CCLF_CUSTINV_CA_' || rct.trx_number || '_' || TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS') || '.pdf' as "PARAMETER5"
            ,'true' as "PARAMETER6"
FROM   ra_customer_trx_all rct