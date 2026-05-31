--# --------------------------------------------------------------------------------------------------------------#
--# DESCRIPTION     : Send file to GS server
--# CREATION DATE   : 22-MAR-2022
--#
--# MODIFICATION HISTORY:
--# CR#           Author              Date              Description
--# REL063    Nuri Chetia    22-MAR-22       GERITM29897336 changed filename format
--# REL067    Nuri Chetia    12-AUG-22       GERITM32336826  added .txt to filename
--# ---------------------------------------------------------------------------------------------------------------------#
SELECT 'CCLFST' as "KEY"
      ,'text' as "OUTPUT_FORMAT"
      ,'FTP' as "DEL_CHANNEL"
   --  ,'GBSIMT.CCLFST.CCLBALEXFCES.txt.'||TO_CHAR(SYSDATE,'MMDDYYYYhh24MISS') as "OUTPUT_NAME" --REL063 GERITM29897336 Commented 
     --,'a_STCOCFHFM_ACTUAL_AP'||TO_CHAR(TO_DATE(substr(:P_PERIOD,1,3),'Mon','NLS_DATE_LANGUAGE=ENGLISH'),'MM','NLS_DATE_LANGUAGE=ENGLISH')||'-20'||substr(:P_PERIOD,5)||'_RR'  as "OUTPUT_NAME" --REL063 GERITM29897336 Added  --REL067  GERITM32336826 commented
      ,'a_STCOCFHFM_ACTUAL_AP'||TO_CHAR(TO_DATE(substr(:P_PERIOD,1,3),'Mon','NLS_DATE_LANGUAGE=ENGLISH'),'MM','NLS_DATE_LANGUAGE=ENGLISH')||'-20'||substr(:P_PERIOD,5)||'_RR.txt'  as "OUTPUT_NAME" --REL067  GERITM32336826 Added
	  ,'true' as "SAVE_OUTPUT"
     -- , FND_PROFILE.VALUE('CCLF_BI_SFTP_SERVER') as "PARAMETER1"
    --, FND_PROFILE.VALUE('GLOBALSCAPE_MFT') as "PARAMETER1"  -- 20191219 GECHG0669282
	  ,(SELECT description
				FROM fnd_lookup_values 
				WHERE lookup_type = 'VER_GS_BURST_PROGS'
				AND lookup_code = 'CCLF_STATHFM_EXTRACT'
				AND enabled_flag = 'Y'
				AND Language = 'US') as "PARAMETER1"  -- Added by Vignesh
      ,:P_DEST_DIR as "PARAMETER4"
     --,'GBSIMT.CCLFST.CCLBALEXFCES.txt.'||TO_CHAR(SYSDATE,'MMDDYYYYhh24MISS') as "PARAMETER5" --REL063 GERITM29897336 Commented 
      -- ,'a_STCOCFHFM_ACTUAL_AP'||TO_CHAR(TO_DATE(substr(:P_PERIOD,1,3),'Mon','NLS_DATE_LANGUAGE=ENGLISH'),'MM','NLS_DATE_LANGUAGE=ENGLISH')||'-20'||substr(:P_PERIOD,5)||'_RR'  as "PARAMETER5" --REL063 GERITM29897336 Added  --REL067  GERITM32336826 commented
       ,'a_STCOCFHFM_ACTUAL_AP'||TO_CHAR(TO_DATE(substr(:P_PERIOD,1,3),'Mon','NLS_DATE_LANGUAGE=ENGLISH'),'MM','NLS_DATE_LANGUAGE=ENGLISH')||'-20'||substr(:P_PERIOD,5)||'_RR.txt'  as "PARAMETER5"  --REL067  GERITM32336826 Added
	  ,'true' as "PARAMETER6"
FROM sys.dual