SELECT 'BOOKTYPE' as "KEY"
      ,'text' as "OUTPUT_FORMAT"
      ,'FTP' as "DEL_CHANNEL"
      ,'CCLF_FI_BOOKTYPES'||'.txt.'||TO_CHAR(SYSDATE, 'mmddyyyyhh24miss') as "OUTPUT_NAME"
      ,'true' as "SAVE_OUTPUT"
     -- , FND_PROFILE.VALUE('CCLF_BI_SFTP_SERVER') as "PARAMETER1"   DISABLED -- July 16th, 2020
      ,:P_DEST_DIR as "PARAMETER4"
      ,'CCLF_FI_BOOKTYPES'||'.txt.'||TO_CHAR(SYSDATE, 'mmddyyyyhh24miss') as "PARAMETER5"
       ,'true' as "PARAMETER6"
FROM sys.dual