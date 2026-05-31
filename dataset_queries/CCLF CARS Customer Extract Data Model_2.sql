SELECT 'ENG' as "KEY"
      ,'xml' as "OUTPUT_FORMAT"
      ,'FTP' as "DEL_CHANNEL"
      ,'CCLF_GECARSCUST.' || TO_CHAR(SYSDATE, 'MMDDYYYYhh24MISS') || '.xml' as "OUTPUT_NAME"
      ,'true' as "SAVE_OUTPUT"
      --,FND_PROFILE.VALUE('CCLF_BI_SFTP_SERVER') as "PARAMETER1"    DISABLED -- July 16th, 2020
      ,:P_DEST_DIR as "PARAMETER4"
      ,'CCLF_GECARSCUST.' || TO_CHAR(SYSDATE, 'MMDDYYYYhh24MISS') || '.xml'  as "PARAMETER5"
      ,'true' as "PARAMETER6"
FROM sys.dual