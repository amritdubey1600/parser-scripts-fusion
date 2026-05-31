SELECT 'SOURCE_LEDGER' as "KEY"
      ,'text' as "OUTPUT_FORMAT"
      ,'FTP' as "DEL_CHANNEL"
      ,'CCLF_DL_GL_LEDGER_RELATIONSHIPS'||'.txt.'||TO_CHAR(SYSDATE, 'mmddyyyyhh24miss') as "OUTPUT_NAME"
      ,'true' as "SAVE_OUTPUT"
    --  , FND_PROFILE.VALUE('CCLF_BI_SFTP_SERVER') as "PARAMETER1"  --Disabled on Apr 24, 2019
      ,:P_DEST_DIR as "PARAMETER4"
      ,'CCLF_DL_GL_LEDGER_RELATIONSHIPS'||'.txt.'||TO_CHAR(SYSDATE, 'mmddyyyyhh24miss') as "PARAMETER5"
      ,'true' as "PARAMETER6"
FROM sys.dual