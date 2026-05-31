/*--#-----------------------------------------------------------------------------------------------------------------#
--# GECARS Lite Extract for Invoices Bursting Query
--# DESCRIPTION  : This query used to send SFTP the file to GECARS Location
--#                
--# MODIFICATION HISTORY:
--# CR#                 Author            Date                  Description
--# REL-053 			Prasanth Thayi     01-MAY-2021          GEINC9156965 / GERITM21727022 Added logic to send Email attachment
--# ---------------------------------------------------------------------------------------------------------------------
*/
SELECT 'KEY'   as "KEY"
      ,'xml' as "OUTPUT_FORMAT"
      ,'FTP' as "DEL_CHANNEL"
      ,'CCLF_GECARSINV.' || TO_CHAR(SYSDATE, 'MMDDYYYYhh24MISS') || '.xml' as "OUTPUT_NAME"
      ,'true' as "SAVE_OUTPUT"
      --,FND_PROFILE.VALUE('CCLF_BI_SFTP_SERVER') as "PARAMETER1"
      ,(SELECT description
				FROM fnd_lookup_values 
				WHERE lookup_type = 'VER_GS_BURST_PROGS'
				AND lookup_code = 'GECARS_INVOICE_LITE'
				AND enabled_flag = 'Y'
				AND Language = 'US') as "PARAMETER1" /* GlobalScape by GECHG0747561 on Mar.11, 2020 */ --Clone to Convey
      ,null as PARAMETER2
       ,null as PARAMETER3
      ,:P_DEST_DIR as "PARAMETER4"
      --,'CCLF_GECARSINV_' || TO_CHAR(SYSDATE, 'MMDDYYYYhh24MISS') || '.xml'  as "PARAMETER5"
      ,'CCLF_GECARSINV_LITE_' || TO_CHAR(SYSDATE, 'MMDDYYYYhh24MISS') || '.xml'  as "PARAMETER5" /* add "LITE" GECHG0747561 on Mar.11, 2020*/
      ,'true' as "PARAMETER6"
      ,null as PARAMETER7
FROM sys.dual
-- Added below code for  REL-053 GEINC9156965 / GERITM21727022
UNION
SELECT 'KEY'   as "KEY"
      ,'xlsx'as OUTPUT_FORMAT
      ,'EMAIL' as DEL_CHANNEL
      ,'CCLF Invoice Extract GECARS Lite.xlsx' as OUTPUT_NAME
      ,null as SAVE_OUTPUT
      --,'ETL@dandsltd.com' as PARAMETER1
	  ,FND_PROFILE.VALUE('CIRRUS_AR_INV_EMAIL_DANDS') as PARAMETER1
      ,'Carlos.Salvide@ge.com' as PARAMETER2
      ,'bipublisher-report@ge.com' as PARAMETER3
      ,'CCLF Invoice Extract GECARS Lite' PARAMETER4
      ,'Please find attachment for CCLF Invoice Extract GECARS Lite'  as PARAMETER5
      ,'true' as "PARAMETER6"
      ,'bipublisher-report@ge.com'  PARAMETER7
FROM sys.dual