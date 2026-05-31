--# MODIFICATION HISTORY:
   --# CR#             Author              Date             Description
   --# --------------------------------------------------------------------------------------------------------------------------------------------------------#
   --# REL-78          Nagendra         13-MAR-2023        GERITM37807779 modified the out going file name in parameter5
  --# ---------------------------------------------------------------------------------------------------------------------------------------------------------#
SELECT 'PWHFM' as "KEY"
      ,'text' as "OUTPUT_FORMAT"
      ,'FTP' as "DEL_CHANNEL"
      ,'CCLF_PWHFM_EXTRACT_'||NVL(:P_PERIOD,LATEST_OPENED_PERIOD_NAME)||'.csv' as "OUTPUT_NAME"
      ,'true' as "SAVE_OUTPUT"
      --, FND_PROFILE.VALUE('CCLF_BI_SFTP_SERVER') as "PARAMETER1"
      --, FND_PROFILE.VALUE('GLOBALSCAPE_MFT') as "PARAMETER1"  /* GlobalScape GECHG0716574 on 20200214 */
     ,(SELECT description
				FROM fnd_lookup_values 
				WHERE lookup_type = 'VER_GS_BURST_PROGS'
				AND lookup_code = 'PWHFM_EXTRACT'
				AND enabled_flag = 'Y'
				AND Language = 'US') as "PARAMETER1" -- Added by Vignesh - Fusion Clone and Convey
	 ,:P_DEST_DIR as "PARAMETER4"
     -- ,TO_CHAR(SYSDATE, 'YYMMDDhh24MISS')||'_CCLF_PWHFM_EXTRACT_'||NVL(:P_PERIOD,LATEST_OPENED_PERIOD_NAME)||'.csv' as "PARAMETER5" /* GlobalScape GECHG0716574 on 20200214 */ Commented as per REL-78 GERITM37807779
	  ,TO_CHAR(SYSDATE, 'YYYYMMDDHHMISS')||'_GEVCORPFSN_Actual_'||
	  (select SUBSTR(period_name,1,3)||'-'||a.period_year
				FROM gl_period_statuses a
				WHERE 1=1                                        
				AND a.ledger_id = gl.ledger_id				
				AND a.application_id=101
				AND a.period_name = :P_PERIOD)  
		||'_RR'||'.txt' as "PARAMETER5"  --Added as per REL-78 GERITM37807779
      ,'true' as "PARAMETER6"
FROM gl_ledgers gl
WHERE NAME ='CA_CAD_PRM'