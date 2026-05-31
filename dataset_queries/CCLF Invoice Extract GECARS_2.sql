SELECT --'BCOCANCCL'   as "KEY" --REL-007 This can also be used by CA_CAD_PGS_BU
      'KEY'   as "KEY"                    
      ,'xml' as "OUTPUT_FORMAT"
      ,'FTP' as "DEL_CHANNEL"
      ,'CCLF_GECARSINV.' || TO_CHAR(SYSDATE, 'MMDDYYYYhh24MISS') || '.xml' as "OUTPUT_NAME"
      ,'true' as "SAVE_OUTPUT"
      --,FND_PROFILE.VALUE('CCLF_BI_SFTP_SERVER') as "PARAMETER1"
      --,FND_PROFILE.VALUE('GLOBALSCAPE_MFT') as "PARAMETER1" /* GlobalScape by GECHG0747543 on Mar.11, 2020 */
    ,(SELECT description
				FROM fnd_lookup_values 
				WHERE lookup_type = 'VER_GS_BURST_PROGS'
				AND lookup_code = 'GECARS_INVOICES'
				AND enabled_flag = 'Y'
				AND language = 'US') as "PARAMETER1" -- Fusion Clone and Convey
      ,:P_DEST_DIR as "PARAMETER4"
      ,'CCLF_GECARSINV_' || TO_CHAR(SYSDATE, 'MMDDYYYYhh24MISS') || '.xml'  as "PARAMETER5"
      ,'true' as "PARAMETER6"
FROM sys.dual