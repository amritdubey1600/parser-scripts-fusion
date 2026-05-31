SELECT 
1 AS "KEY"
       ,'CIRRUS Dive Payment' AS "TEMPLATE"
       ,'text' AS "OUTPUT_FORMAT"
       ,'FTP' AS "DEL_CHANNEL"
       ,'CIRRUS_TRAX_Payment_Recon_Extract_Daily_Load' || TO_CHAR(SYSDATE,'YYYYMMDDHH24MISS') || '.csv' AS "OUTPUT_NAME"
       ,'true' AS "SAVE_OUTPUT"
       ,FND_PROFILE.VALUE('MFT_ICS_SFTP') AS "PARAMETER1"
       ,:p_dest_dir AS "PARAMETER4"
       ,'CIRRUS_TRAX_Payment_Recon_Extract_Daily_Load' || TO_CHAR(SYSDATE,'YYYYMMDDHH24MISS') || '.csv' AS "PARAMETER5"
       ,'true' AS "PARAMETER6"
FROM   DUAL