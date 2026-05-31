/*--#-----------------------------------------------------------------------------------------------------------------#
--# GECARS Lite Extract for Invoices Bursting Query
--# DESCRIPTION  : This query used to send SFTP the file to GECARS Location
--#                
--# MODIFICATION HISTORY:
--# CR#                 Author            Date                  Description
--# REL-055		Prasanth Thayi     11-AUG-2021          GEINC9156965/GERITM21727117 Added logic to send Email attachment
--# REL-077     Amjad Mohd         11-JUN-2023          GERITM40213390: need to stop sending email to 'ETL@dandsltd.com'
--# ---------------------------------------------------------------------------------------------------------------------
*/
SELECT 'ENG' as "KEY"
      ,'xml' as "OUTPUT_FORMAT"
      ,'FTP' as "DEL_CHANNEL"
      ,'CCLF_GECARSCUST.' || TO_CHAR(SYSDATE, 'MMDDYYYYhh24MISS') || '.xml' as "OUTPUT_NAME"
      ,'true' as "SAVE_OUTPUT"
      --,FND_PROFILE.VALUE('CCLF_BI_SFTP_SERVER') as "PARAMETER1"
      --,FND_PROFILE.VALUE('GLOBALSCAPE_MFT') as "PARAMETER1"  /* GlobalScape by GECHG0735613 on Mar.11, 2020 */ 
      ,(SELECT description
				FROM fnd_lookup_values 
				WHERE lookup_type = 'VER_GS_BURST_PROGS'
				AND lookup_code = 'GECARS_CUSTOMER'
				AND enabled_flag = 'Y'
				AND language = 'US') as "PARAMETER1" -- Fusion Clone and Convey
      ,null as PARAMETER2  -- Added for REL-055 GEINC9156965/GERITM21727117
	  ,null as PARAMETER3  -- Added for REL-055 GEINC9156965/GERITM21727117 
      ,:P_DEST_DIR as "PARAMETER4"
      ,'CCLF_GECARSCUST.' || TO_CHAR(SYSDATE, 'MMDDYYYYhh24MISS') || '.xml'  as "PARAMETER5"
      ,'true' as "PARAMETER6"
FROM sys.dual
--Added below for REL-055 GEINC9156965/GERITM21727117
UNION 
SELECT
	'ENG' KEY,
	'xlsx' as OUTPUT_FORMAT,
	'EMAIL' DEL_CHANNEL,
	'CCLF_GECARSCUST.' || TO_CHAR(SYSDATE, 'MMDDYYYYhh24MISS') || '.xml' as OUTPUT_NAME
	,'true' as "SAVE_OUTPUT",
	-- commented for REL-077 GERITM40213390 'ETL@dandsltd.com' PARAMETER1,
	-- commented for REL-077 GERITM40213390 'scott.sandlin@ge.com' PARAMETER2,
	--'Carlos.Salvide@ge.com' as PARAMETER1, --  Added for REL-077 GERITM40213390  --Clone and Convey
	'VernovaERPCloudNonProd@ge.com' as PARAMETER1,
	 --NULL  		           as PARAMETER2, --  Added for REL-077 GERITM40213390
	--'bipublisher-report@ge.com' as PARAMETER3,
	'VernovaERPCloudNonProd@ge.com' as PARAMETER2,
	'VernovaERPCloudNonProd@ge.com' as PARAMETER3,
	:P_DEST_DIR PARAMETER4,
	'PFA Customer Extract for your review. Thanks' PARAMETER5,
	'true' PARAMETER6
FROM dual
-- Added above for REL-055 GEINC9156965/GERITM21727117