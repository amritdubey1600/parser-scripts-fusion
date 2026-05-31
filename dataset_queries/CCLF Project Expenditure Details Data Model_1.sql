select  
PEIA.Expenditure_item_id,
to_char(ppa.project_id) PROJECT_ID
,ptv.BILLABLE_FLAG
,to_char(PPA.SEGMENT1) PROJECT_NUMBER
,PPA.NAME PROJECT_NAME
,PPA.DESCRIPTION
,PPA.START_DATE
,PPA.COMPLETION_DATE
,PPA.CLOSED_DATE
,PTV.TASK_NUMBER
,PTV.TASK_NAME
--,to_char(PTV.TASK_ID) TASK_ID
--,to_Char(PPA.CARRYING_OUT_ORGANIZATION_ID) ORGANIZATION_ID
,HRU.NAME EXPENDITURE_ORG_NAME,
PET.EXPENDITURE_TYPE_NAME,
PEIA.EXPENDITURE_ITEM_DATE,
PPN.DISPLAY_NAME,
PEIA.QUANTITY,
PEIA.UNIT_OF_MEASURE,
PEIA.PROJECT_RAW_COST,
PEIA.PROJECT_BURDENED_COST,
PEIA.DENOM_RAW_COST AS TRANSAC_RAW_COST,
PEIA.DENOM_BURDENED_COST AS TRANSAC_BURDEN_COST,
PEIA.DENOM_CURRENCY_CODE TRANSACTION_CURRENCY,
PEIA.PROJFUNC_CURRENCY_CODE,
PPA.PROJECT_CURRENCY_CODE,
PEIA.CAPITALIZABLE_FLAG,
--PEIA.BILLABLE_FLAg,
PWT.NAME WORK_TYPE,
NVL(XEP.NAME, 'NULL') Provider_Legal_Entity,
XEP_R.NAME Receiver_Legal_Entity,
PEG.USER_BATCH_NAME ,
PU.USERNAME Person_Number,
PPN.FULL_NAME Person_Name,
PJ.NAME Job,
(SELECT DISTINCT PPN.LIST_NAME                                               
                                         FROM PJF_LATESTPROJECTMANAGER_V PLM ,
                                              PER_PERSON_NAMES_F PPN    
                                         WHERE PLM.RESOURCE_SOURCE_ID         = PPN.PERSON_ID(+)
										   AND PLM.PROJECT_ID = PPA.PROJECT_ID
                                           AND PPN.NAME_TYPE                    = 'GLOBAL'
										   AND    TRUNC( SYSDATE ) BETWEEN ppn.effective_start_date
                                       AND NVL( ppn.effective_end_date, SYSDATE + 1 )
										   ) Project_Manager,
 (SELECT (SELECT PERSON_NUMBER FROM PER_ALL_PEOPLE_F WHERE PERSON_ID = PPN.PERSON_ID AND  ROWNUM = 1) Project_Manager_SSO                                            
                                         FROM PJF_LATESTPROJECTMANAGER_V PLM ,
                                              PER_PERSON_NAMES_F PPN    
                                         WHERE PLM.RESOURCE_SOURCE_ID         = PPN.PERSON_ID(+)
										   AND PLM.PROJECT_ID = PPA.PROJECT_ID
                                           AND PPN.NAME_TYPE                    = 'GLOBAL'
										   AND    TRUNC( SYSDATE ) BETWEEN ppn.effective_start_date
                                       AND NVL( ppn.effective_end_date, SYSDATE + 1 )
										   )	Project_Manager_SSO,
TRUNC(PEIA.EXPENDITURE_ITEM_DATE, 'IW')	Week_Start_Date									   
from
PJF_PROJECTS_ALL_VL PPA,
PJF_TASKS_V PTV,
HR_ORGANIZATION_UNITS HRU,
PJC_EXP_ITEMS_ALL PEIA,
PJF_EXP_TYPES_TL PET,
per_person_names_f ppn,
XLE_ENTITY_PROFILES XEP,
XLE_ENTITY_PROFILES XEP_R,
PJF_WORK_TYPES_TL PWT,
PJC_EXP_GROUPS_ALL PEG,
PER_USERS PU,
PER_JOBS PJ
where 1=1
and PPA.PROJECT_ID=PTV.PROJECT_ID
and PEIA.project_id = PPA.project_id
and PEIA.task_id = ptv.task_id
and PEIA.EXPENDITURE_TYPE_ID = pet.EXPENDITURE_TYPE_ID(+)
and NVL(pet.language, 'US') = 'US'
and   PEIA.EXP_GROUP_ID = PEG.EXP_GROUP_ID(+)
--and PET.EXPENDITURE_TYPE_NAME = 'Conversion Labor'
--and PPA.SEGMENT1 = 'PUSAL00317'
--AND ppa.name like '%FA%Delivery%AirAsia%'
--and ppa.project_id = 300000160911847
and PEIA.EXPENDITURE_ORGANIZATION_ID=HRU.ORGANIZATION_ID(+)
AND PEIA.INCURRED_BY_PERSON_ID = ppn.person_id(+)
AND  NVL(ppn.name_type, 'GLOBAL') = 'GLOBAL'
AND PEIA.PRVDR_LEGAL_ENTITY_ID = XEP.LEGAL_ENTITY_ID(+)
AND PEIA.WORK_TYPE_ID = PWT.WORK_TYPE_ID (+)
--AND ppa.org_id in (select a1.BU_ID from  fun_all_business_units_v a1 where  a1.BU_NAME like '%AVID%')
AND NVL(PWT.language,'US') = 'US'
AND PPA.LEGAL_ENTITY_ID = XEP_R.LEGAL_ENTITY_ID(+)
AND PEIA.INCURRED_BY_PERSON_ID = PU.person_id(+)
AND PEIA.PERSON_JOB_ID = PJ.JOB_ID(+)
--AND (ppa.org_id IN (:bu_name) OR 2 IN (:bu_name||2))
AND PPA.org_id = 300000627430622
AND trunc(PEIA.EXPENDITURE_ITEM_DATE) BETWEEN trunc(NVL(:start_date,PEIA.EXPENDITURE_ITEM_DATE)) AND trunc(NVL(:end_date,PEIA.EXPENDITURE_ITEM_DATE))
order by PPA.project_id, PEIA.Expenditure_item_id