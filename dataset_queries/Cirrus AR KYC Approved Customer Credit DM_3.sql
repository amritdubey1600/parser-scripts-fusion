SELECT 1 AS "KEY",
       'GED KYC Approved Customer Credit Report' AS "TEMPLATE",
       'text' AS "OUTPUT_FORMAT",
       'FTP' AS "DEL_CHANNEL",
       'CUSTPROFILEDET_' || TO_CHAR (SYSDATE, 'mmddyyyyhh24miss') || '.txt'
          AS "OUTPUT_NAME",
       'true' AS "SAVE_OUTPUT",
       --FND_PROFILE.VALUE('MFT_ICS_SFTP') AS "PARAMETER1",
	   (SELECT flv.description 
		FROM 
		FND_LOOKUP_VALUES flv
		WHERE flv.lookup_type				=		'VER_MFT_ICS_BURST_PROGS'
		AND flv.LANGUAGE					=		'US'
		AND flv.lookup_code=		'VNF_CIR_ARKYC_Apprvd_CustExt'
		AND flv.enabled_flag				=		'Y') AS "PARAMETER1", --Fusion Clone and Convey
	  
       :p_dest_dir AS "PARAMETER4",
       'CUSTPROFILEDET_' || TO_CHAR (SYSDATE, 'mmddyyyyhh24miss') || '.txt'
          AS "PARAMETER5",
       'true' AS "PARAMETER6"
  FROM DUAL
UNION
SELECT 1 AS "KEY",
       'Trigger Template' AS "TEMPLATE",
       'text' AS "OUTPUT_FORMAT",
       'FTP' AS "DEL_CHANNEL",
       'CUSTPROFILEDET_' || TO_CHAR (SYSDATE, 'mmddyyyyhh24miss') || '.trg' 
          AS "OUTPUT_NAME",
       'true' AS "SAVE_OUTPUT",
       --FND_PROFILE.VALUE('MFT_ICS_SFTP') AS "PARAMETER1",
	   
	    (SELECT flv.description 
		FROM 
		FND_LOOKUP_VALUES flv
		WHERE flv.lookup_type				=		'VER_MFT_ICS_BURST_PROGS'
		AND flv.LANGUAGE					=		'US'
		AND flv.lookup_code=		'VNF_CIR_ARKYC_Apprvd_CustExt'
		AND flv.enabled_flag				=		'Y') AS "PARAMETER1", --Fusion Clone and Convey
       :p_dest_dir AS "PARAMETER4",
       'CUSTPROFILEDET_' || TO_CHAR (SYSDATE, 'mmddyyyyhh24miss') || '.trg' 
          AS "PARAMETER5",
       'true' AS "PARAMETER6"
  FROM DUAL