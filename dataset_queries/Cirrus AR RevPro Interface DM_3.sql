SELECT 1 AS "KEY"
       ,'GED AR Revpro' AS "TEMPLATE"
       ,'text' AS "OUTPUT_FORMAT"
       ,'FTP' AS "DEL_CHANNEL"
       ,'GED_RevPro_AR_' || to_char(SYSDATE
                                  ,'YYYYMMDDHH24MISS') || '.csv' AS "OUTPUT_NAME"
       ,'true' AS "SAVE_OUTPUT"
       ,fnd_profile.value('MFT_ICS_SFTP') AS "PARAMETER1"
       ,:P_DEST_DIR AS "PARAMETER4"
       ,'GED_RevPro_AR_' || to_char(SYSDATE
                                  ,'YYYYMMDDHH24MISS') || '.csv' AS "PARAMETER5"
       ,'true' AS "PARAMETER6"
FROM   dual
UNION
SELECT 1 AS "KEY"
       ,'GED AR Revpro Trigger' AS "TEMPLATE"
       ,'text' AS "OUTPUT_FORMAT"
       ,'FTP' AS "DEL_CHANNEL"
       ,'GED_RevPro_AR_' || to_char(SYSDATE
                                  ,'YYYYMMDDHH24MISS') || '.TRG' AS "OUTPUT_NAME"
       ,'true' AS "SAVE_OUTPUT"
       ,fnd_profile.value('MFT_ICS_SFTP') AS "PARAMETER1"
       ,:P_DEST_DIR AS "PARAMETER4"
       ,'GED_RevPro_AR_' || to_char(SYSDATE
                                  ,'YYYYMMDDHH24MISS') || '.TRG' AS "PARAMETER5"
       ,'true' AS "PARAMETER6"
FROM   dual