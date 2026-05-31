SELECT /*+ MATERIALIZE */
sysdate last_extract_date,
Res_Utl.project_id,
Res_Utl.project_name,
Res_Utl.project_number,
Res_Utl.project_status_code,
Res_Utl.week_day,
Res_Utl.cal_hours,
Res_Utl.resource_id,
(SELECT PERSON_NUMBER FROM PER_ALL_PEOPLE_F WHERE PERSON_ID = Res_Utl.PERSON_ID AND  ROWNUM = 1) Resource_SSO,
Res_Utl.resource_name,
Res_Utl.resource_type,
(SELECT name FROM PJT_PROJECT_ROLES_VL WHERE  project_role_id = Res_Utl.project_role_id and ROWNUM = 1 )  Role_Name,
Res_Utl.res_start_date ,
Res_Utl.resource_request_id,
Res_Utl.res_end_date,
Res_Utl.Manager_Name Project_Manager_Name,
Res_Utl.Manager_id,
Res_Utl.Manager_SSO Project_Manager_SSO,
Res_Utl.resource_pool_id,
Res_Utl.resource_pool_name,
Res_Utl.resource_pool_owner,
Res_Utl.Pool_Owner_SSO,
Res_Utl.STATUS_CODE,
Res_Utl.TYPE_CODE,
Res_Utl.allocation,
Res_Utl.planned_hour,
Res_Utl.Bill_Per,
Res_Utl.Non_Bill_Per,
((Res_Utl.planned_hour*Res_Utl.Bill_Per)/100) Billable_Hour,
((Res_Utl.planned_hour*Res_Utl.Non_Bill_Per)/100) Non_Bill_Hour,
Res_Utl.Request_Name,
Res_Utl.Assigned_Resource,
Res_Utl.Staffing_Owner,  
Res_Utl.Staffing_Owner_SSO,  
Res_Utl.REQUESTER,  
Res_Utl.REQUESTER_ID_SSO ,  
Res_Utl.SPECIAL_INSTRUCTIONS, 
Res_Utl.STAFFING_REMARKS, 	
Res_Utl.TARGET_COST_RATE,
Res_Utl.TARGET_COST_RATE_CURR_CODE TARGET_COST_RATE_CURRENCY,
Res_Utl.TARGET_BILL_RATE,
Res_Utl.TARGET_BILL_RATE_CURR_CODE TARGET_BILL_RATE_CURRENCY,
Res_Utl.RESOURCE_COST_RATE,
Res_Utl.RESOURCE_COST_RATE_CURR_CODE RESOURCE_COST_RATE_CURRENCY,
Res_Utl.RESOURCE_BILL_RATE,
Res_Utl.RESOURCE_BILL_RATE_CURR_CODE RESOURCE_BILL_RATE_CURRENCY,
Res_Utl.ADJUSTMENT_REASON,
Res_Utl.ADJUSTMENT_COMMENT, 
Res_Utl.FULFILLED_DATE,
Res_Utl.SUBMITTED_DATE, 
Res_Utl.RESOURCE_PROPOSED_DATE,
Res_Utl.Resource_Manager_id,
Res_Utl.Resource_Manager,
Res_Utl.Resource_Manager_SSO,
Res_Utl.Assign_Res_Manager_id,
Res_Utl.Assign_Resource_Manager,
Res_Utl.Assign_Res_Manager_SSO
FROM
(SELECT --DISTINCT 
prj_hr.project_id,
prj_hr.project_name,
prj_hr.Project_Number,
prj_hr.project_status_code,
prj_hr.person_id,
prj_hr.week_start_date week_day,
prj_hr.hours cal_hours,
prj_hr.resource_id resource_id,
prj_hr.display_name resource_name,
prj_hr.res_start_date ,
prj_hr.res_end_date,
prj_hr.project_role_id,
prj_hr.resource_request_id,
--DECODE(pptym.system_person_type,'CWK','Contractor','EMP','Employee',pptym.system_person_type) resource_type,
(Select a.user_person_type from PER_PERSON_TYPES_TL a, PER_PERSON_TYPES b, per_person_type_usages_m pptym
where a.PERSON_TYPE_ID = b.PERSON_TYPE_ID
and  a.language = 'US'
and b.SYSTEM_PERSON_TYPE = pptym.system_person_type
and pptym.person_id = prj_hr.person_id 
AND trunc(prj_hr.week_start_date) between trunc(pptym.EFFECTIVE_START_DATE)  AND  trunc(pptym.EFFECTIVE_END_DATE)
and rownum =1 
) resource_type,
PM.LIST_NAME Manager_Name,
PM.PERSON_ID Manager_id,
PM.SSO Manager_SSO,
--res_pool_name.pool_id resource_pool_id,
--res_pool_name.name resource_pool_name,


(SELECT prpa.pool_id
FROM pjr_resource_pool_assignments prpa,
     pjr_resource_pools_vl prpv
WHERE  prpa.pool_id = prpv.pool_id 
AND prpa.resource_id  = prj_hr.resource_id
AND ( TRUNC( SYSDATE ) BETWEEN NVL(prpa.from_date,SYSDATE) AND NVL(prpa.to_date,SYSDATE))
and rownum =1) resource_pool_id,


 
(SELECT prpv.name
FROM pjr_resource_pool_assignments prpa,
     pjr_resource_pools_vl prpv
WHERE  prpa.pool_id = prpv.pool_id 
AND prpa.resource_id  = prj_hr.resource_id
AND ( TRUNC( SYSDATE ) BETWEEN NVL(prpa.from_date,SYSDATE) AND NVL(prpa.to_date,SYSDATE))
and rownum =1) resource_pool_name,



(Select pasf.manager_id
FROM PER_ASSIGNMENT_SUPERVISORS_F pasf,
     PER_PERSON_NAMES_F ppnf
WHERE 1 = 1
AND pasf.manager_id = ppnf.person_id
AND NVL(ppnf.name_type,'GLOBAL') = 'GLOBAL'
AND pasf.person_id = prj_hr.person_id
AND ( TRUNC(prj_hr.week_start_date) BETWEEN NVL(pasf.effective_start_date,SYSDATE) AND NVL(pasf.effective_end_date,SYSDATE))
AND rownum = 1) Resource_Manager_id,


(Select  NVL(ppnf.display_name,ppnf.first_name||' '||ppnf.last_name)
FROM PER_ASSIGNMENT_SUPERVISORS_F pasf,
     PER_PERSON_NAMES_F ppnf
WHERE 1 = 1
AND pasf.manager_id = ppnf.person_id
AND NVL(ppnf.name_type,'GLOBAL') = 'GLOBAL'
AND pasf.person_id = prj_hr.person_id
AND ( TRUNC(prj_hr.week_start_date) BETWEEN NVL(pasf.effective_start_date,SYSDATE) AND NVL(pasf.effective_end_date,SYSDATE))
AND rownum = 1) Resource_Manager,


(SELECT PERSON_NUMBER FROM PER_ALL_PEOPLE_F WHERE PERSON_ID = (Select pasf.manager_id
FROM PER_ASSIGNMENT_SUPERVISORS_F pasf,
     PER_PERSON_NAMES_F ppnf
WHERE 1 = 1
AND pasf.manager_id = ppnf.person_id
AND NVL(ppnf.name_type,'GLOBAL') = 'GLOBAL'
AND pasf.person_id = prj_hr.person_id
AND ( TRUNC(prj_hr.week_start_date) BETWEEN NVL(pasf.effective_start_date,SYSDATE) AND NVL(pasf.effective_end_date,SYSDATE))
AND rownum = 1) AND  ROWNUM = 1) Resource_Manager_SSO,




(Select pasf.manager_id
FROM PER_ASSIGNMENT_SUPERVISORS_F pasf,
     PER_PERSON_NAMES_F ppnf
WHERE 1 = 1
AND pasf.manager_id = ppnf.person_id
AND NVL(ppnf.name_type,'GLOBAL') = 'GLOBAL'
AND pasf.person_id = prj_hr.Assigned_Res_person_id
AND ( TRUNC(prj_hr.week_start_date) BETWEEN NVL(pasf.effective_start_date,SYSDATE) AND NVL(pasf.effective_end_date,SYSDATE))
AND rownum = 1) Assign_Res_Manager_id,


(Select  NVL(ppnf.display_name,ppnf.first_name||' '||ppnf.last_name)
FROM PER_ASSIGNMENT_SUPERVISORS_F pasf,
     PER_PERSON_NAMES_F ppnf
WHERE 1 = 1
AND pasf.manager_id = ppnf.person_id
AND NVL(ppnf.name_type,'GLOBAL') = 'GLOBAL'
AND pasf.person_id = prj_hr.Assigned_Res_person_id
AND ( TRUNC(prj_hr.week_start_date) BETWEEN NVL(pasf.effective_start_date,SYSDATE) AND NVL(pasf.effective_end_date,SYSDATE))
AND rownum = 1) Assign_Resource_Manager,


(SELECT PERSON_NUMBER FROM PER_ALL_PEOPLE_F WHERE PERSON_ID = (Select pasf.manager_id
FROM PER_ASSIGNMENT_SUPERVISORS_F pasf,
     PER_PERSON_NAMES_F ppnf
WHERE 1 = 1
AND pasf.manager_id = ppnf.person_id
AND NVL(ppnf.name_type,'GLOBAL') = 'GLOBAL'
AND pasf.person_id = prj_hr.Assigned_Res_person_id
AND ( TRUNC(prj_hr.week_start_date) BETWEEN NVL(pasf.effective_start_date,SYSDATE) AND NVL(pasf.effective_end_date,SYSDATE))
AND rownum = 1) AND  ROWNUM = 1) Assign_Res_Manager_SSO,



(SELECT DISTINCT pperv.display_name 
FROM
PJR_RESOURCE_POOL_ASSIGNMENTS prpa,
PJR_RESOURCE_POOLS_VL prpv,
PJT_PRJ_ENTERPRISE_RESOURCE_VL pperv
WHERE  prpa.resource_id = prj_hr.resource_id
AND prpa.pool_id = prpv.pool_id
AND prpv.resource_id = pperv.resource_id
AND ( TRUNC( SYSDATE ) BETWEEN NVL(prpa.from_date,SYSDATE) AND NVL(prpa.to_date,SYSDATE))
and rownum = 1) resource_pool_owner,

(SELECT PERSON_NUMBER FROM PER_ALL_PEOPLE_F WHERE PERSON_ID = ((SELECT DISTINCT pperv.person_id 
FROM
PJR_RESOURCE_POOL_ASSIGNMENTS prpa,
PJR_RESOURCE_POOLS_VL prpv,
PJT_PRJ_ENTERPRISE_RESOURCE_VL pperv
WHERE  prpa.resource_id = prj_hr.resource_id
AND prpa.pool_id = prpv.pool_id
AND prpv.resource_id = pperv.resource_id
AND ( TRUNC( SYSDATE ) BETWEEN NVL(prpa.from_date,SYSDATE) AND NVL(prpa.to_date,SYSDATE)))) AND  ROWNUM = 1) Pool_Owner_SSO,

prj_hr.allocation,
prj_hr.allocated_hours planned_hour,
prj_hr.Bill_Per, 
prj_hr.Non_Bill_Per,
prj_hr.STATUS_CODE,
prj_hr.TYPE_CODE,
prj_hr.Request_Name,
prj_hr.Assigned_Resource,
prj_hr.Assigned_Res_person_id,
prj_hr.Staffing_Owner,  
prj_hr.Staffing_Owner_SSO,  
prj_hr.REQUESTER,  
prj_hr.REQUESTER_ID_SSO ,  
prj_hr.SPECIAL_INSTRUCTIONS, 
prj_hr.STAFFING_REMARKS, 	
prj_hr.TARGET_COST_RATE,
prj_hr.TARGET_COST_RATE_CURR_CODE,
prj_hr.TARGET_BILL_RATE,
prj_hr.TARGET_BILL_RATE_CURR_CODE,
prj_hr.RESOURCE_COST_RATE,
prj_hr.RESOURCE_COST_RATE_CURR_CODE,
prj_hr.RESOURCE_BILL_RATE,
prj_hr.RESOURCE_BILL_RATE_CURR_CODE,
prj_hr.ADJUSTMENT_REASON,
prj_hr.ADJUSTMENT_COMMENT, 
prj_hr.FULFILLED_DATE,
prj_hr.SUBMITTED_DATE,
prj_hr.RESOURCE_PROPOSED_DATE
FROM
(SELECT  /*+ MATERIALIZE */ a.resource_id ,
a.project_id ,
a.Project_Name,
a.Project_Number,
a.project_status_code,
a.project_role_id ,
a.res_start_date ,
a.Bill_Per, 
a.Non_Bill_Per,
a.STATUS_CODE,
a.TYPE_CODE,
a.res_end_date,
a.resource_request_id,
TRUNC(dlyhrs.start_date , 'iw')  week_start_date ,
ROUND(SUM(DECODE(SIGN(a.res_end_date-dlyhrs.start_date), -1, 0, dlyhrs.hours)*a.allocation/100),2) allocated_hours,
a.display_name,
a.person_id,
a.allocation,
a.org_id,
SUM(DECODE(SIGN(a.res_end_date-dlyhrs.start_date), -1, 0, dlyhrs.hours)) hours,
a.Request_Name,
a.Assigned_Resource,
a.Assigned_Res_person_id,
a.Staffing_Owner,  
a.Staffing_Owner_SSO,  
a.REQUESTER,  
a.REQUESTER_ID_SSO ,  
a.SPECIAL_INSTRUCTIONS, 
a.STAFFING_REMARKS, 	
a.TARGET_COST_RATE,
a.TARGET_COST_RATE_CURR_CODE,
a.TARGET_BILL_RATE,
a.TARGET_BILL_RATE_CURR_CODE,
a.RESOURCE_COST_RATE,
a.RESOURCE_COST_RATE_CURR_CODE,
a.RESOURCE_BILL_RATE,
a.RESOURCE_BILL_RATE_CURR_CODE,
a.ADJUSTMENT_REASON,
a.ADJUSTMENT_COMMENT, 
a.FULFILLED_DATE,
a.SUBMITTED_DATE, 
a.RESOURCE_PROPOSED_DATE
FROM
( SELECT  NVL(prr.resource_id,prr.ORIG_REQUESTED_RESOURCEID) resource_id ,
(Select res.person_id from pjt_prj_enterprise_resource_vl res
where  res.resource_id = NVL(prr.resource_id,prr.ORIG_REQUESTED_RESOURCEID)
AND res.resource_class = 'PEOPLE') person_id,
(Select res.display_name from pjt_prj_enterprise_resource_vl res
where  res.resource_id = NVL(prr.resource_id,prr.ORIG_REQUESTED_RESOURCEID)
AND res.resource_class = 'PEOPLE') display_name,
NVL(prj.project_calendar_id, -99) AS schedule_id ,
prj.project_id ,
prj.Name Project_Name,
prj.segment1 Project_Number,
 (select PROJECT_STATUS_NAME from PJF_PROJECT_STATUSES_VL where PROJECT_STATUS_CODE = prj.project_status_code and rownum=1) project_status_code,
prj.org_id,

prr.name Request_Name,
(Select res.display_name from PJR_ASSIGNMENT pa, pjt_prj_enterprise_resource_vl res
where pa.resource_id =  res.resource_id
and pa.ASSIGN_ID  = prr.ASSIGN_ID ) Assigned_Resource,

(Select res.person_id from PJR_ASSIGNMENT pa, pjt_prj_enterprise_resource_vl res
where pa.resource_id =  res.resource_id
and pa.ASSIGN_ID  = prr.ASSIGN_ID ) Assigned_Res_person_id,

(Select display_name from pjt_prj_enterprise_resource_vl 
  where resource_id  = prr.STAFFING_OWNER_ID ) Staffing_Owner,  
(Select papf.PERSON_NUMBER from pjt_prj_enterprise_resource_vl pperv, PER_ALL_PEOPLE_F papf
  where pperv.person_id = papf.person_id 
  and   pperv.resource_id  = prr.STAFFING_OWNER_ID 
  and rownum = 1  ) Staffing_Owner_SSO,  
 (Select display_name from pjt_prj_enterprise_resource_vl 
  where resource_id  = prr.REQUESTER_ID ) REQUESTER,  
(Select papf.PERSON_NUMBER from pjt_prj_enterprise_resource_vl pperv, PER_ALL_PEOPLE_F papf
  where pperv.person_id = papf.person_id 
  and   pperv.resource_id  = prr.REQUESTER_ID 
  and rownum = 1  ) REQUESTER_ID_SSO ,  
 prr.SPECIAL_INSTRUCTIONS, 
 prr.STAFFING_REMARKS, 	
prr.TARGET_COST_RATE,
prr.TARGET_COST_RATE_CURR_CODE,
prr.TARGET_BILL_RATE,
prr.TARGET_BILL_RATE_CURR_CODE,
prr.RESOURCE_COST_RATE,
prr.RESOURCE_COST_RATE_CURR_CODE,
prr.RESOURCE_BILL_RATE,
prr.RESOURCE_BILL_RATE_CURR_CODE,
prr.ADJUSTMENT_REASON,
prr.ADJUSTMENT_COMMENT, 
prr.FULFILLED_DATE,
prr.SUBMITTED_DATE, 
prr.RESOURCE_PROPOSED_DATE,
prr.project_role_id ,
prj.start_date Prj_start_date,
TRUNC(prr.start_date) res_start_date ,
TRUNC(prr.finish_date) res_end_date ,
prr.resource_request_id resource_request_id,
NVL(prr.ATTRIBUTE_NUMBER1,0) Bill_Per, 
NVL(prr.ATTRIBUTE_NUMBER2,0) Non_Bill_Per,
prr.STATUS_CODE,
prr.TYPE_CODE,
ROUND((((DECODE(prr.USE_PROJ_CALENDAR_HOUR_FLAG,'Y',8, prr.HOURS_PER_DAY))/8)*100),2) allocation
FROM PJR_RESOURCE_REQUESTS  prr,
pjf_projects_all_vl prj
WHERE 1 =1
AND prr.project_id = prj.project_id
and ((prr.current_flag = 'Y') OR (prr.status_code IN ('PENDING_ADJUST','REJECTED_ADJUST','CANCELED_ADJUST') ))
)a,
 ((SELECT     -99 schedule_id,    
FiscalDay.REPORT_DATE start_date
, decode(rtrim(UPPER(TO_CHAR (FiscalDay.REPORT_DATE, 'FmDay', 'nls_date_language=english'))), 'MONDAY', 8, 'TUESDAY', 8, 'WEDNESDAY', 8, 'THURSDAY', 8, 'FRIDAY', 8, 'SATURDAY', 0, 'SUNDAY', 0) hours
,FiscalDay.REPORT_DATE
                FROM GL_FISCAL_DAY_V FiscalDay
    WHERE  FiscalDay.FISCAL_PERIOD_SET_NAME =  'CCL CALENDAR'
AND fiscalday.fiscal_period_number <> '13'
--and FiscalDay.FISCAL_YEAR_NUMBER in (:P_Year)
AND extract (year from FiscalDay.REPORT_DATE) in (:P_Year)
))dlyhrs
WHERE a.schedule_id = dlyhrs.schedule_id
AND trunc(dlyhrs.start_date) between trunc(a.res_start_date)  AND  trunc(a.res_end_date)

GROUP BY a.resource_id ,
a.project_id ,
a.project_name,
a.Project_Number,
a.project_status_code,
a.org_id,
a.display_name,
a.project_role_id ,
a.Prj_start_date,
a.person_id,
a.allocation,
a.resource_request_id,
a.res_start_date ,
a.res_end_date,
a.Bill_Per, 
a.Non_Bill_Per,
a.STATUS_CODE,
a.TYPE_CODE,
a.Request_Name,
a.Assigned_Resource,
a.Assigned_Res_person_id,
a.Staffing_Owner,  
a.Staffing_Owner_SSO,  
a.REQUESTER,  
a.REQUESTER_ID_SSO ,  
a.SPECIAL_INSTRUCTIONS, 
a.STAFFING_REMARKS, 	
a.TARGET_COST_RATE,
a.TARGET_COST_RATE_CURR_CODE,
a.TARGET_BILL_RATE,
a.TARGET_BILL_RATE_CURR_CODE,
a.RESOURCE_COST_RATE,
a.RESOURCE_COST_RATE_CURR_CODE,
a.RESOURCE_BILL_RATE,
a.RESOURCE_BILL_RATE_CURR_CODE,
a.ADJUSTMENT_REASON,
a.ADJUSTMENT_COMMENT, 
a.FULFILLED_DATE,
a.SUBMITTED_DATE, 
a.RESOURCE_PROPOSED_DATE,
TRUNC(dlyhrs.start_date , 'iw') 
) prj_hr,
--per_person_type_usages_m pptym,
 (SELECT DISTINCT PPN.LIST_NAME ,
							                  PPN.PERSON_ID,
											  (SELECT PERSON_NUMBER FROM PER_ALL_PEOPLE_F WHERE PERSON_ID = PPN.PERSON_ID AND  ROWNUM = 1) SSO,
                                              PLM.PROJECT_ID PROJECT_ID
                                         FROM PJF_LATESTPROJECTMANAGER_V PLM ,
                                              PER_PERSON_NAMES_F PPN    
                                         WHERE PLM.RESOURCE_SOURCE_ID         = PPN.PERSON_ID(+)
                                           AND PPN.NAME_TYPE                    = 'GLOBAL'
										   AND NVL(TRUNC(PPN.EFFECTIVE_END_DATE),SYSDATE) >= TRUNC(SYSDATE)) PM,
(SELECT a.bu_id, a.bu_name FROM fun_all_business_units_v A
	WHERE 1=1
	--AND a.bu_name IN(SELECT meaning FROM FND_LOOKUP_VALUES WHERE lookup_type LIKE 'GED%BU%NAME%')
	--AND  NOT EXISTS(SELECT 1 FROM FUN_ALL_BUSINESS_UNITS_V B
		--		WHERE 1=1
			--	AND b.bu_name IN(SELECT meaning FROM fnd_lookup_values WHERE lookup_type LIKE 'AVD%BU%NAME%')
				--AND b.bu_id=a.bu_id )
	) bu_details
WHERE 1 = 1
AND prj_hr.project_id = pm.project_id(+)
AND prj_hr.org_id = bu_details.bu_id
AND prj_hr.org_id = 300000627430622
AND extract(year from prj_hr.week_start_date) in (:P_Year)
--AND trunc(prj_hr.week_start_date) between trunc(pptym.EFFECTIVE_START_DATE)  AND  trunc(pptym.EFFECTIVE_END_DATE)
) Res_Utl