--#-----------------------------------------------------------------------------------------#
--# MODIFICATION HISTORY: 
--# CR#          Author             Date                Description 
--#-----------------------------------------------------------------------------------------#
--# REL-067  Nagendra Naidu  	19-May-2021   Added time stamp to the output file name and also extension (.txt) removed from the output file name #GERITM32225829 
--# REL-085	Vignesh Kumar		17-Feb-2024		Bursting logic change, output file name change for vernova
--#-----------------------------------------------------------------------------------------#
SELECT 'CCLFGL' as "KEY"
      ,'text' as "OUTPUT_FORMAT"
      ,'FTP' as "DEL_CHANNEL"
	 -- ,'BILCCL.CCLFGL.CCLJEBILEXES.txt' as "OUTPUT_NAME" -- Commented REL-067:GERITM32225829 
     --,'BILCCL.CCLFGL.CCLJEBILEXES.' || TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS')  as "OUTPUT_NAME" -- Added REL-067:GERITM32225829
     ,'BILVNF.CCLFGL.CCLJEBILEXES.' || TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS')  as "OUTPUT_NAME" -- REL-085
	 -- , FND_PROFILE.VALUE('CCLF_BI_SFTP_SERVER') as "PARAMETER1"
     -- , FND_PROFILE.VALUE('GLOBALSCAPE_MFT') as "PARAMETER1"  -- JP 20191120
      ,(SELECT description
				FROM fnd_lookup_values 
				WHERE lookup_type = 'VER_GS_BURST_PROGS'
				AND lookup_code = 'CCLF_BILLER_EXTRACT'
				AND enabled_flag = 'Y'
				AND Language = 'US') as "PARAMETER1" -- REL-085
	  ,:P_DEST_DIR as "PARAMETER4"
     --,'BILCCL.CCLFGL.CCLJEBILEXES.txt' as "PARAMETER5" -- Commented REL-067:GERITM32225829 
     --,'BILCCL.CCLFGL.CCLJEBILEXES.' || TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS')  as "PARAMETER5" -- Added REL-067:GERITM32225829 
      ,'BILVNF.CCLFGL.CCLJEBILEXES.' || TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS')  as "PARAMETER5" -- REL-085
	  ,'true' AS "PARAMETER6"
FROM sys.dual