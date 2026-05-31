/*--#-----------------------------------------------------------------------------------------------------------------#
--# Cirrus AP SOL EPIQ Control Extract DM
--# DESCRIPTION  : This data model query to extract EPIQ Payment details
--#                
--# CREATION DATE     :
--# CREATED BY      : 
--#
--# MODIFICATION HISTORY:
--# CR#                 Author            Date                  Description
--# REL-027	        Vijay Kochhar    28-FEB-2019		data model query EPIQ Payment details
--# ---------------------------------------------------------------------------------------------------------------------
*/

SELECT 
'ENG' AS key,
instruction_id ||','||count_rec||','||total_amount||','|| TO_CHAR(payment_date,'MM/DD/YYYY')  ||','|| filename||','||status AS data  

 FROM
(
SELECT  
TO_CHAR(aa.payment_instruction_id) AS instruction_id,
aa.payment_count AS count_rec , TO_CHAR( SUM( ROUND(apa.payment_amount,2) ),'999999999D99') AS total_amount, apa.payment_date,
'2015_'|| TO_CHAR( apa.payment_date,'MMDDYY') || '_chk'|| :p_payment_instruction_id||'SOLAR'||TO_CHAR( SYSDATE,'MIHHSS')||'_1.ep1' AS filename,
'Success' status

FROM IBY_PAY_INSTRUCTIONS_ALL  aa,
IBY_PAYMENTS_ALL    apa
WHERE 1=1
AND aa.payment_instruction_id =NVL(:p_payment_instruction_id,aa.payment_instruction_id)
AND  apa.payment_instruction_id =aa.payment_instruction_id
GROUP BY  aa.payment_instruction_id, aa.payment_count, apa.payment_date

UNION
SELECT  
:p_payment_instruction_id AS instruction_id,
NULL  count_rec , NULL AS total_amount, NULL AS payment_date,
NULL  AS filename,
'Failure' status

FROM DUAL
WHERE 
NVL(( SELECT COUNT(1) FROM IBY_PAY_INSTRUCTIONS_ALL  aa,
IBY_PAYMENTS_ALL    apa
WHERE 1=1
AND aa.payment_instruction_id =  NVL(:p_payment_instruction_id,aa.payment_instruction_id)
AND  apa.payment_instruction_id =aa.payment_instruction_id
GROUP BY  aa.payment_instruction_id, aa.payment_count),0) =0

 ) AA