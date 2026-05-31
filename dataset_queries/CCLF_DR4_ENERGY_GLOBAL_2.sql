--#------------------------------------------------------------------------------------------------------------------------#
--# MODIFICATION HISTORY:
--# CR#                       Author             Date                Description
--#------------------------------------------------------------------------------------------------------------------------#
--# REL-58 EMG              Prasanth Thayi       15-Nov-2021        GERITM26184397 Code Remediated for DXL Removal --#
--#------------------------------------------------------------------------------------------------------------------------#
SELECT 'CCLFGL' as "KEY"
      ,'text' as "OUTPUT_FORMAT"
      ,'FTP' as "DEL_CHANNEL"
     --,'GBSIMT.CCLFGL.CCLJEEXIES.txt' as "OUTPUT_NAME"  -- Commented for REL-58 EMG  GERITM26184397
	 ,'PWRODI.CCLFGL.CCLJEEXIES.'||TO_CHAR(SYSDATE, 'YYYYMMDDhh24MISS')||'.txt' as "OUTPUT_NAME"  -- Added for REL-58 EMG  GERITM26184397
      ,'true' as "SAVE_OUTPUT"
     -- , FND_PROFILE.VALUE('CCLF_BI_SFTP_SERVER') as "PARAMETER1"
     --  , FND_PROFILE.VALUE('GLOBALSCAPE_MFT') as "PARAMETER1"  -- 20191219 GECHG0669294
	   ,(SELECT description
				FROM fnd_lookup_values 
				WHERE lookup_type = 'VER_GS_BURST_PROGS'
				AND lookup_code = 'CCLF_DR4_ENERGY_GLOBAL_EXTRACT'
				AND enabled_flag = 'Y'
				AND Language = 'US') as "PARAMETER1" -- Fusion clone and Convey to Vernova
      ,:P_DEST_DIR as "PARAMETER4" 
     --,'GBSIMT.CCLFGL.CCLJEEXIES.txt' as "PARAMETER5"  -- Commented for REL-58 EMG  GERITM26184397 
	 ,'PWRODI.CCLFGL.CCLJEEXIES.'||TO_CHAR(SYSDATE, 'YYYYMMDDhh24MISS')||'.txt' as "PARAMETER5" -- Added for REL-58 EMG  GERITM26184397
      ,'true' as "PARAMETER6"
FROM sys.dual