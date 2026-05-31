select COMPANY,  
       minor_category,
      MAJOR_CATEGORY,
	--  ASSET_NUMBER,
	  CCA_CLASS,
	  sum(COST_RETIRED) COST_RETIRED,
	  sum(TRANSFER_COST) TRANSFER_COST,
	  sum(NBV_RETIRED) NBV_RETIRED,
	sum(Current_balance) Current_balance,
	sum(ACCUM_DEPRN) ACCUM_DEPRN,
	sum(YTD_DEPRN) YTD_DEPRN,
	sum(ACCUM_DEPRN_USD) ACCUM_DEPRN_USD,
	sum(YTD_DEPRN_USD) YTD_DEPRN_USD,
	SUM(CURRENT_COST) CURRENT_COST,
	
	-- Current_balance,
sum(Begin_balance) Begin_balance,
SUM(BEGIN_BAL_USD) BEGIN_BAL_USD,
sum(begin_reserve) begin_reserve,
sum(addition_DEP_reserve) addition_DEP_reserve,
sum(DEP_TRANSFER) DEP_TRANSFER,
SUM(ADDITION_COST) ADDITION_COST,
SUM(ADDITION_COST_USD) ADDITION_COST_USD,
SUM(TRANSFER_COST_USD) TRANSFER_COST_USD,
SUM(COST_RETIRED_USD) COST_RETIRED_USD,
SUM(COST_BEGIN_RESERVE_USD) COST_BEGIN_RESERVE_USD,
SUM(ADDITION_DEP_RESERVE_USD) ADDITION_DEP_RESERVE_USD,
SUM(DEP_TRANSFER_USD) DEP_TRANSFER_USD,
SUM(NBV_RETIRED_USD) NBV_RETIRED_USD
from (SELECT  distinct 
e.segment2 minor_category,

FADD.ASSET_NUMBER, 
 
G.SEGMENT1 COMPANY,
FADD.ATTRIBUTE3 CCA_CLASS,
E.SEGMENT1 MAJOR_CATEGORY,
((NVL((SELECT SUM (FAR.COST_RETIRED)
FROM FA_RETIREMENTS FAR
WHERE FAR.book_type_code = :P_BOOK_TYPE_CODE
AND FAR.date_retired<= (SELECT (CALENDAR_PERIOD_CLOSE_DATE) FROM FA_DEPRN_PERIODS FDP1 
where FDP1.book_type_code = :P_BOOK_TYPE_CODE  -- add to handle multiple books
and period_name= :P_ACC_PERIOD)
AND FAR.asset_id = A.ASSET_ID
AND FAR.status = 'PROCESSED'),0)*f.units_assigned)/FADD.current_units)AS COST_RETIRED,
((NVL((SELECT SUM (FAR.COST_RETIRED)
FROM FA_RETIREMENTS FAR
WHERE FAR.book_type_code = :P_BOOK_TYPE_CODE
AND FAR.date_retired<= (SELECT (CALENDAR_PERIOD_CLOSE_DATE) FROM FA_DEPRN_PERIODS FDP1 
where FDP1.book_type_code = :P_BOOK_TYPE_CODE  -- add to handle multiple books
and period_name= :P_ACC_PERIOD)
AND FAR.asset_id = A.ASSET_ID
AND FAR.status = 'PROCESSED'),0)*f.units_assigned)/FADD.current_units)*(CASE 
				 WHEN 
				 (select nvl(FMBR.AVG_EXCHANGE_RATE,0) 
				  from  FA_MC_BOOKS_RATES FMBR
				  where FMBR.ASSET_ID = a.ASSET_ID 
				  and   FMBR.transaction_header_id = a.transaction_header_id_in) > 0 THEN
				 (select nvl(FMBR.AVG_EXCHANGE_RATE,0) 
				  from  FA_MC_BOOKS_RATES FMBR
				  where FMBR.ASSET_ID = a.ASSET_ID 
				  and   FMBR.transaction_header_id = a.transaction_header_id_in)
				  WHEN a.original_cost < 0 or a.original_cost > 0 THEN
				  (select nvl((FMBR.original_cost/a.original_cost),0) 
					from  FA_MC_BOOKS FMBR
					where FMBR.ASSET_ID = a.ASSET_ID 
					and   FMBR.transaction_header_id_in = a.transaction_header_id_in) 
				  WHEN a.COST < 0 or a.COST > 0 THEN
				  (select nvl((FMBR.COST/a.COST),0) 
					from  FA_MC_BOOKS FMBR
					where FMBR.ASSET_ID = a.ASSET_ID 
					and   FMBR.transaction_header_id_in = a.transaction_header_id_in)	
				ELSE 0
				END) AS COST_RETIRED_USD,
NVL((SELECT NVL(XAL.ACCOUNTED_DR,XAL.ACCOUNTED_CR) 
FROM FA_TRANSACTION_HEADERS FTH,
XLA_AE_HEADERS XAH,
XLA_AE_LINES XAL ,fa_deprn_periods dp
WHERE XAH.EVENT_TYPE_CODE='CIP_TRANSFERS'
AND FADD.ASSET_ID=FTH.ASSET_ID
AND XAH.EVENT_ID= FTH.EVENT_ID
AND FTH.TRANSACTION_TYPE_CODE ='TRANSFER' 
and dp.period_name =:P_ACC_PERIOD
AND XAH.AE_HEADER_ID=XAL.AE_HEADER_ID
and fth.date_effective  between dp.period_open_date    and nvl(dp.period_close_date, sysdate)
and fth.book_type_code = dp.book_type_code
AND ROWNUM=1
AND XAL.ACCOUNTING_CLASS_CODE='CIP_COST'
AND XAL.CURRENCY_CODE='CAD'
AND FADD.ASSET_TYPE='CAPITALIZED'),0) TRANSFER_COST,/*
NVL((SELECT NVL(XAL.ACCOUNTED_DR,XAL.ACCOUNTED_CR) 
FROM FA_TRANSACTION_HEADERS FTH,
XLA_AE_HEADERS XAH,
XLA_AE_LINES XAL ,fa_deprn_periods dp
WHERE XAH.EVENT_TYPE_CODE='CIP_TRANSFERS'
AND FADD.ASSET_ID=FTH.ASSET_ID
AND XAH.EVENT_ID= FTH.EVENT_ID
AND FTH.TRANSACTION_TYPE_CODE ='TRANSFER' 
and dp.period_name =:P_ACC_PERIOD
AND XAH.AE_HEADER_ID=XAL.AE_HEADER_ID
and fth.date_effective  between dp.period_open_date    and nvl(dp.period_close_date, sysdate)
and fth.book_type_code = dp.book_type_code
AND ROWNUM=1
AND XAL.ACCOUNTING_CLASS_CODE='CIP_COST'
AND XAL.CURRENCY_CODE='CAD'
AND FADD.ASSET_TYPE='CAPITALIZED'),0)*(CASE 
				 WHEN 
				 (select nvl(FMBR.AVG_EXCHANGE_RATE,0) 
				  from  FA_MC_BOOKS_RATES FMBR
				  where FMBR.ASSET_ID = a.ASSET_ID 
				  and   FMBR.transaction_header_id = a.transaction_header_id_in) > 0 THEN
				 (select nvl(FMBR.AVG_EXCHANGE_RATE,0) 
				  from  FA_MC_BOOKS_RATES FMBR
				  where FMBR.ASSET_ID = a.ASSET_ID 
				  and   FMBR.transaction_header_id = a.transaction_header_id_in)
				  WHEN a.original_cost < 0 or a.original_cost > 0 THEN
				  (select nvl((FMBR.original_cost/a.original_cost),0) 
					from  FA_MC_BOOKS FMBR
					where FMBR.ASSET_ID = a.ASSET_ID 
					and   FMBR.transaction_header_id_in = a.transaction_header_id_in) 
				  WHEN a.COST < 0 or a.COST > 0 THEN
				  (select nvl((FMBR.COST/a.COST),0) 
					from  FA_MC_BOOKS FMBR
					where FMBR.ASSET_ID = a.ASSET_ID 
					and   FMBR.transaction_header_id_in = a.transaction_header_id_in)	
				ELSE 0
				END)*/ NVL((SELECT NVL(XAL.ACCOUNTED_DR,XAL.ACCOUNTED_CR) 
FROM FA_TRANSACTION_HEADERS FTH,
XLA_AE_HEADERS XAH,
XLA_AE_LINES XAL ,fa_deprn_periods dp
WHERE XAH.EVENT_TYPE_CODE='CIP_TRANSFERS'
AND FADD.ASSET_ID=FTH.ASSET_ID
AND XAH.EVENT_ID= FTH.EVENT_ID
AND FTH.TRANSACTION_TYPE_CODE ='TRANSFER' 
and dp.period_name =:P_ACC_PERIOD
AND XAH.AE_HEADER_ID=XAL.AE_HEADER_ID
and fth.date_effective  between dp.period_open_date    and nvl(dp.period_close_date, sysdate)
and fth.book_type_code = dp.book_type_code
AND ROWNUM=1
AND XAL.ACCOUNTING_CLASS_CODE='CIP_COST'
AND XAL.CURRENCY_CODE='CAD'
AND FADD.ASSET_TYPE='CAPITALIZED'),0) * (CASE 
				 WHEN 
				 (select nvl(FMBR.AVG_EXCHANGE_RATE,0) 
				  from  FA_MC_BOOKS_RATES FMBR
				  where FMBR.ASSET_ID = a.ASSET_ID 
				  and   FMBR.transaction_header_id = a.transaction_header_id_in) > 0 THEN
				 (select nvl(FMBR.AVG_EXCHANGE_RATE,0) 
				  from  FA_MC_BOOKS_RATES FMBR
				  where FMBR.ASSET_ID = a.ASSET_ID 
				  and   FMBR.transaction_header_id = a.transaction_header_id_in)
				  WHEN a.original_cost < 0 or a.original_cost > 0 THEN
				  (select nvl((FMBR.original_cost/a.original_cost),0) 
					from  FA_MC_BOOKS FMBR
					where FMBR.ASSET_ID = a.ASSET_ID 
					and   FMBR.transaction_header_id_in = a.transaction_header_id_in) 
				  WHEN a.COST < 0 or a.COST > 0 THEN
				  (select nvl((FMBR.COST/a.COST),0) 
					from  FA_MC_BOOKS FMBR
					where FMBR.ASSET_ID = a.ASSET_ID 
					and   FMBR.transaction_header_id_in = a.transaction_header_id_in)	
				ELSE 0
				END) TRANSFER_COST_USD,
((NVL((SELECT SUM (FAR.nbv_retired)
                       FROM FA_RETIREMENTS FAR
                       WHERE FAR.book_type_code = :P_BOOK_TYPE_CODE
                       AND FAR.date_retired<= (SELECT (CALENDAR_PERIOD_CLOSE_DATE) FROM FA_DEPRN_PERIODS FDP2
													   where FDP2.book_type_code = :P_BOOK_TYPE_CODE  -- add to handle multiple books
													   and period_name= :P_ACC_PERIOD)
                       AND FAR.asset_id = A.ASSET_ID
                       AND FAR.status = 'PROCESSED'),0)*f.units_assigned)/FADD.current_units) AS NBV_RETIRED
					   ,
					   ((NVL((SELECT SUM (FAR.nbv_retired)
                       FROM FA_RETIREMENTS FAR
                       WHERE FAR.book_type_code = :P_BOOK_TYPE_CODE
                       AND FAR.date_retired<= (SELECT (CALENDAR_PERIOD_CLOSE_DATE) FROM FA_DEPRN_PERIODS FDP2
													   where FDP2.book_type_code = :P_BOOK_TYPE_CODE  -- add to handle multiple books
													   and period_name= :P_ACC_PERIOD)
                       AND FAR.asset_id = A.ASSET_ID
                       AND FAR.status = 'PROCESSED'),0)*f.units_assigned)/FADD.current_units)*(CASE 
				 WHEN 
				 (select nvl(FMBR.AVG_EXCHANGE_RATE,0) 
				  from  FA_MC_BOOKS_RATES FMBR
				  where FMBR.ASSET_ID = a.ASSET_ID 
				  and   FMBR.transaction_header_id = a.transaction_header_id_in) > 0 THEN
				 (select nvl(FMBR.AVG_EXCHANGE_RATE,0) 
				  from  FA_MC_BOOKS_RATES FMBR
				  where FMBR.ASSET_ID = a.ASSET_ID 
				  and   FMBR.transaction_header_id = a.transaction_header_id_in)
				  WHEN a.original_cost < 0 or a.original_cost > 0 THEN
				  (select nvl((FMBR.original_cost/a.original_cost),0) 
					from  FA_MC_BOOKS FMBR
					where FMBR.ASSET_ID = a.ASSET_ID 
					and   FMBR.transaction_header_id_in = a.transaction_header_id_in) 
				  WHEN a.COST < 0 or a.COST > 0 THEN
				  (select nvl((FMBR.COST/a.COST),0) 
					from  FA_MC_BOOKS FMBR
					where FMBR.ASSET_ID = a.ASSET_ID 
					and   FMBR.transaction_header_id_in = a.transaction_header_id_in)	
				ELSE 0
				END) AS NBV_RETIRED_USD,
					 
decode(
sign( 

nvl(( select  max( trunc(A.date_effective)) from fa_asset_history A,  fa_additions_b B 
where A.asset_id= B.asset_id
and A.asset_id= FADD.asset_id
and A.ASSET_TYPE ='CAPITALIZED'
),(to_date ( decode (  (select  fiscal_year from FA_DEPRN_PERIODS
where period_name=:P_ACC_PERIOD
and book_type_code=:P_BOOK_TYPE_CODE),'2016', '2016-01-21', ( (select  fiscal_year from FA_DEPRN_PERIODS
where period_name=:P_ACC_PERIOD
and book_type_code=:P_BOOK_TYPE_CODE)||'-01-01')) 
,'YYYY-MM-DD')))
-
(to_date ( decode (  (select  fiscal_year from FA_DEPRN_PERIODS
where period_name=:P_ACC_PERIOD
and book_type_code=:P_BOOK_TYPE_CODE),'2016', '2016-01-21', ( (select  fiscal_year from FA_DEPRN_PERIODS
where period_name=:P_ACC_PERIOD
and book_type_code=:P_BOOK_TYPE_CODE)||'-01-01')) 
,'YYYY-MM-DD'))


),-1,to_number(a.original_cost) *(f.units_assigned)/FADD.current_units,0,to_number(a.original_cost) *(f.units_assigned)/FADD.current_units,0)
  Begin_balance,
decode(
sign( 

nvl(( select  max( trunc(A.date_effective)) from fa_asset_history A,  fa_additions_b B 
where A.asset_id= B.asset_id
and A.asset_id= FADD.asset_id
and A.ASSET_TYPE ='CAPITALIZED'
),(to_date ( decode (  (select  fiscal_year from FA_DEPRN_PERIODS
where period_name=:P_ACC_PERIOD
and book_type_code=:P_BOOK_TYPE_CODE),'2016', '2016-01-21', ( (select  fiscal_year from FA_DEPRN_PERIODS
where period_name=:P_ACC_PERIOD
and book_type_code=:P_BOOK_TYPE_CODE)||'-01-01')) 
,'YYYY-MM-DD')))
-
(to_date ( decode (  (select  fiscal_year from FA_DEPRN_PERIODS
where period_name=:P_ACC_PERIOD
and book_type_code=:P_BOOK_TYPE_CODE),'2016', '2016-01-21', ( (select  fiscal_year from FA_DEPRN_PERIODS
where period_name=:P_ACC_PERIOD
and book_type_code=:P_BOOK_TYPE_CODE)||'-01-01')) 
,'YYYY-MM-DD'))),-1,to_number(a.original_cost) *(f.units_assigned)/FADD.current_units,0,to_number(a.original_cost) *(f.units_assigned)/FADD.current_units,0)*(CASE 
				 WHEN 
				 (select nvl(FMBR.AVG_EXCHANGE_RATE,0) 
				  from  FA_MC_BOOKS_RATES FMBR
				  where FMBR.ASSET_ID = a.ASSET_ID 
				  and   FMBR.transaction_header_id = a.transaction_header_id_in) > 0 THEN
				 (select nvl(FMBR.AVG_EXCHANGE_RATE,0) 
				  from  FA_MC_BOOKS_RATES FMBR
				  where FMBR.ASSET_ID = a.ASSET_ID 
				  and   FMBR.transaction_header_id = a.transaction_header_id_in)
				  WHEN a.original_cost < 0 or a.original_cost > 0 THEN
				  (select nvl((FMBR.original_cost/a.original_cost),0) 
					from  FA_MC_BOOKS FMBR
					where FMBR.ASSET_ID = a.ASSET_ID 
					and   FMBR.transaction_header_id_in = a.transaction_header_id_in) 
				  WHEN a.COST < 0 or a.COST > 0 THEN
				  (select nvl((FMBR.COST/a.COST),0) 
					from  FA_MC_BOOKS FMBR
					where FMBR.ASSET_ID = a.ASSET_ID 
					and   FMBR.transaction_header_id_in = a.transaction_header_id_in)	
				ELSE 0
				END)  BEGIN_BAL_USD,

decode(
sign( 
nvl(( select  max( trunc(A.date_effective)) from fa_asset_history A,  fa_additions_b B 
where A.asset_id= B.asset_id
and A.asset_id= FADD.asset_id
and A.ASSET_TYPE ='CAPITALIZED'
),(to_date ( decode (  (select  fiscal_year from FA_DEPRN_PERIODS
where period_name=:P_ACC_PERIOD
and book_type_code=:P_BOOK_TYPE_CODE),'2016', '2016-01-21', ( (select  fiscal_year from FA_DEPRN_PERIODS
where period_name=:P_ACC_PERIOD
and book_type_code=:P_BOOK_TYPE_CODE)||'-01-01')) 
,'YYYY-MM-DD')))
-
(to_date ( decode (  (select  fiscal_year from FA_DEPRN_PERIODS
where period_name=:P_ACC_PERIOD
and book_type_code=:P_BOOK_TYPE_CODE),'2016', '2016-01-21', ( (select  fiscal_year from FA_DEPRN_PERIODS
where period_name=:P_ACC_PERIOD
and book_type_code=:P_BOOK_TYPE_CODE)||'-01-01')) 
,'YYYY-MM-DD'))),-1,0,0,0,
((NVL((SELECT  to_number(fb1.cost)
                       FROM FA_BOOKS fb1, 
                            FA_DEPRN_PERIODS fdp
                       WHERE fb1.asset_id =a.asset_id 
                             AND fdp.period_name = :P_ACC_PERIOD
                             AND fdp.book_type_code = fb1.book_type_code
                             AND fb1.book_type_code = :P_BOOK_TYPE_CODE
                             AND  fb1.transaction_header_id_in =(SELECT MAX(fb2.transaction_header_id_in) 
                                                                  FROM FA_BOOKS fb2 
				                                  WHERE fb2.asset_id = fb1.asset_id 
                                                                        AND fb2.book_type_code = fb1.book_type_code
                                                                        AND NVL (fb2.date_ineffective, SYSDATE) > = fdp.period_open_date
                              AND NVL (fdp.period_close_date, SYSDATE) > =fb2.date_effective )),0) *(f.units_assigned))/FADD.current_units) )  Current_balance,
							  
							  
				  ((NVL((SELECT  to_number(fb1.cost)
                       FROM FA_BOOKS fb1, 
                            FA_DEPRN_PERIODS fdp
                       WHERE fb1.asset_id =a.asset_id 
                             AND fdp.period_name = :P_ACC_PERIOD
                             AND fdp.book_type_code = fb1.book_type_code
                             AND fb1.book_type_code = :P_BOOK_TYPE_CODE
                             AND  fb1.transaction_header_id_in =(SELECT MAX(fb2.transaction_header_id_in) 
                                                                  FROM FA_BOOKS fb2 
				                                  WHERE fb2.asset_id = fb1.asset_id 
                                                                        AND fb2.book_type_code = fb1.book_type_code
                                                                        AND NVL (fb2.date_ineffective, SYSDATE) > = fdp.period_open_date
                              AND NVL (fdp.period_close_date, SYSDATE) > =fb2.date_effective )),0) *(f.units_assigned))/FADD.current_units)  ADD_BAL,
							  sign( 
nvl(( select  max( trunc(A.date_effective)) from fa_asset_history A,  fa_additions_b B 
where A.asset_id= B.asset_id
and A.asset_id= FADD.asset_id
and A.ASSET_TYPE ='CAPITALIZED'
),(to_date ( decode (  (select  fiscal_year from FA_DEPRN_PERIODS
where period_name=:P_ACC_PERIOD
and book_type_code=:P_BOOK_TYPE_CODE),'2016', '2016-01-21', ( (select  fiscal_year from FA_DEPRN_PERIODS
where period_name=:P_ACC_PERIOD
and book_type_code=:P_BOOK_TYPE_CODE)||'-01-01')) 
,'YYYY-MM-DD')))
-
(to_date ( decode (  (select  fiscal_year from FA_DEPRN_PERIODS
where period_name=:P_ACC_PERIOD
and book_type_code=:P_BOOK_TYPE_CODE),'2016', '2016-01-21', ( (select  fiscal_year from FA_DEPRN_PERIODS
where period_name=:P_ACC_PERIOD
and book_type_code=:P_BOOK_TYPE_CODE)||'-01-01')) 
,'YYYY-MM-DD'))
) SIGN_ADD,
decode(
sign( 
nvl(( select  max( trunc(A.date_effective)) from fa_asset_history A,  fa_additions_b B 
where A.asset_id= B.asset_id
and A.asset_id= FADD.asset_id
and A.ASSET_TYPE ='CAPITALIZED'
),(to_date ( decode (  (select  fiscal_year from FA_DEPRN_PERIODS
where period_name=:P_ACC_PERIOD
and book_type_code=:P_BOOK_TYPE_CODE),'2016', '2016-01-21', ( (select  fiscal_year from FA_DEPRN_PERIODS
where period_name=:P_ACC_PERIOD
and book_type_code=:P_BOOK_TYPE_CODE)||'-01-01')) 
,'YYYY-MM-DD')))
-
(to_date ( decode (  (select  fiscal_year from FA_DEPRN_PERIODS
where period_name=:P_ACC_PERIOD
and book_type_code=:P_BOOK_TYPE_CODE),'2016', '2016-01-21', ( (select  fiscal_year from FA_DEPRN_PERIODS
where period_name=:P_ACC_PERIOD
and book_type_code=:P_BOOK_TYPE_CODE)||'-01-01')) 
,'YYYY-MM-DD'))
),-1,0,0,0,((NVL((SELECT to_number(fb1.cost)
                       FROM FA_BOOKS fb1, 
                            FA_DEPRN_PERIODS fdp
                       WHERE fb1.asset_id =a.asset_id 
                             AND fdp.period_name = :P_ACC_PERIOD
                             AND fdp.book_type_code = fb1.book_type_code
                             AND fb1.book_type_code = :P_BOOK_TYPE_CODE
                             AND  fb1.transaction_header_id_in =(SELECT MAX(fb2.transaction_header_id_in) 
                                                                  FROM FA_BOOKS fb2 
				                                  WHERE fb2.asset_id = fb1.asset_id 
                                                                        AND fb2.book_type_code = fb1.book_type_code
                                                                        AND NVL (fb2.date_ineffective, SYSDATE) > = fdp.period_open_date
                              AND NVL (fdp.period_close_date, SYSDATE) > =fb2.date_effective )),0) *(f.units_assigned))/FADD.current_units)) ADDITION_COST,
decode(
sign( 
nvl(( select  max( trunc(A.date_effective)) from fa_asset_history A,  fa_additions_b B 
where A.asset_id= B.asset_id
and A.asset_id= FADD.asset_id
and A.ASSET_TYPE ='CAPITALIZED'
),(to_date ( decode (  (select  fiscal_year from FA_DEPRN_PERIODS
where period_name=:P_ACC_PERIOD
and book_type_code=:P_BOOK_TYPE_CODE),'2016', '2016-01-21', ( (select  fiscal_year from FA_DEPRN_PERIODS
where period_name=:P_ACC_PERIOD
and book_type_code=:P_BOOK_TYPE_CODE)||'-01-01')) 
,'YYYY-MM-DD')))
-
(to_date ( decode (  (select  fiscal_year from FA_DEPRN_PERIODS
where period_name=:P_ACC_PERIOD
and book_type_code=:P_BOOK_TYPE_CODE),'2016', '2016-01-21', ( (select  fiscal_year from FA_DEPRN_PERIODS
where period_name=:P_ACC_PERIOD
and book_type_code=:P_BOOK_TYPE_CODE)||'-01-01')) 
,'YYYY-MM-DD'))
),-1,0,0,0,((NVL((SELECT to_number(fb1.cost)
                       FROM FA_BOOKS fb1, 
                            FA_DEPRN_PERIODS fdp
                       WHERE fb1.asset_id =a.asset_id 
                             AND fdp.period_name = :P_ACC_PERIOD
                             AND fdp.book_type_code = fb1.book_type_code
                             AND fb1.book_type_code = :P_BOOK_TYPE_CODE
                             AND  fb1.transaction_header_id_in =(SELECT MAX(fb2.transaction_header_id_in) 
                                                                  FROM FA_BOOKS fb2 
				                                  WHERE fb2.asset_id = fb1.asset_id 
                                                                        AND fb2.book_type_code = fb1.book_type_code
                                                                        AND NVL (fb2.date_ineffective, SYSDATE) > = fdp.period_open_date
                              AND NVL (fdp.period_close_date, SYSDATE) > =fb2.date_effective )),0) *(f.units_assigned))/FADD.current_units))*(CASE 
				 WHEN 
				 (select nvl(FMBR.AVG_EXCHANGE_RATE,0) 
				  from  FA_MC_BOOKS_RATES FMBR
				  where FMBR.ASSET_ID = a.ASSET_ID 
				  and   FMBR.transaction_header_id = a.transaction_header_id_in) > 0 THEN
				 (select nvl(FMBR.AVG_EXCHANGE_RATE,0) 
				  from  FA_MC_BOOKS_RATES FMBR
				  where FMBR.ASSET_ID = a.ASSET_ID 
				  and   FMBR.transaction_header_id = a.transaction_header_id_in)
				  WHEN a.original_cost < 0 or a.original_cost > 0 THEN
				  (select nvl((FMBR.original_cost/a.original_cost),0) 
					from  FA_MC_BOOKS FMBR
					where FMBR.ASSET_ID = a.ASSET_ID 
					and   FMBR.transaction_header_id_in = a.transaction_header_id_in) 
				  WHEN a.COST < 0 or a.COST > 0 THEN
				  (select nvl((FMBR.COST/a.COST),0) 
					from  FA_MC_BOOKS FMBR
					where FMBR.ASSET_ID = a.ASSET_ID 
					and   FMBR.transaction_header_id_in = a.transaction_header_id_in)	
				ELSE 0
				END) ADDITION_COST_USD,
NVL((select SUM(ua.deprn_reserve) from FA_DEPRN_DETAIL ua
				where ua.asset_id=a.asset_id
					and ua.DEPRN_SOURCE_CODE='D'
                    and ua.DEPRN_RUN_DATE<=(to_date ( decode (  (select  fiscal_year from FA_DEPRN_PERIODS
where period_name=:P_ACC_PERIOD
and book_type_code=:P_BOOK_TYPE_CODE),'2016', '01-01-2016', ( '01-01-'||(select  fiscal_year from FA_DEPRN_PERIODS
where period_name=:P_ACC_PERIOD
and book_type_code=:P_BOOK_TYPE_CODE))) 
,'DD-MM-YYYY'))),0)  begin_reserve ,
NVL((select SUM(ua.deprn_reserve) from FA_DEPRN_DETAIL ua
				where ua.asset_id=a.asset_id
					and ua.DEPRN_SOURCE_CODE='D'
                    and ua.DEPRN_RUN_DATE<=(to_date ( decode (  (select  fiscal_year from FA_DEPRN_PERIODS
where period_name=:P_ACC_PERIOD
and book_type_code=:P_BOOK_TYPE_CODE),'2016', '01-01-2016', ( '01-01-'||(select  fiscal_year from FA_DEPRN_PERIODS
where period_name=:P_ACC_PERIOD
and book_type_code=:P_BOOK_TYPE_CODE))) 
,'DD-MM-YYYY'))),0)*(CASE 
				 WHEN 
				 (select nvl(FMBR.AVG_EXCHANGE_RATE,0) 
				  from  FA_MC_BOOKS_RATES FMBR
				  where FMBR.ASSET_ID = a.ASSET_ID 
				  and   FMBR.transaction_header_id = a.transaction_header_id_in) > 0 THEN
				 (select nvl(FMBR.AVG_EXCHANGE_RATE,0) 
				  from  FA_MC_BOOKS_RATES FMBR
				  where FMBR.ASSET_ID = a.ASSET_ID 
				  and   FMBR.transaction_header_id = a.transaction_header_id_in)
				  WHEN a.original_cost < 0 or a.original_cost > 0 THEN
				  (select nvl((FMBR.original_cost/a.original_cost),0) 
					from  FA_MC_BOOKS FMBR
					where FMBR.ASSET_ID = a.ASSET_ID 
					and   FMBR.transaction_header_id_in = a.transaction_header_id_in) 
				  WHEN a.COST < 0 or a.COST > 0 THEN
				  (select nvl((FMBR.COST/a.COST),0) 
					from  FA_MC_BOOKS FMBR
					where FMBR.ASSET_ID = a.ASSET_ID 
					and   FMBR.transaction_header_id_in = a.transaction_header_id_in)	
				ELSE 0
				END)  COST_BEGIN_RESERVE_USD ,
NVL((select sum(deprn_reserve) from FA_DEPRN_DETAIL ua
				where ua.asset_id=a.asset_id
					and ua.DEPRN_SOURCE_CODE='D'
                    and ua.DEPRN_RUN_DATE>(to_date ( decode (  (select  fiscal_year from FA_DEPRN_PERIODS
where period_name=:P_ACC_PERIOD
and book_type_code=:P_BOOK_TYPE_CODE),'2016', '01-01-2016', ( '01-01-'||(select  fiscal_year from FA_DEPRN_PERIODS
where period_name=:P_ACC_PERIOD
and book_type_code=:P_BOOK_TYPE_CODE))) 
,'DD-MM-YYYY'))),0) addition_DEP_reserve,
NVL((select sum(deprn_reserve) from FA_DEPRN_DETAIL ua
				where ua.asset_id=a.asset_id
					and ua.DEPRN_SOURCE_CODE='D'
                    and ua.DEPRN_RUN_DATE>(to_date ( decode (  (select  fiscal_year from FA_DEPRN_PERIODS
where period_name=:P_ACC_PERIOD
and book_type_code=:P_BOOK_TYPE_CODE),'2016', '01-01-2016', ( '01-01-'||(select  fiscal_year from FA_DEPRN_PERIODS
where period_name=:P_ACC_PERIOD
and book_type_code=:P_BOOK_TYPE_CODE))) 
,'DD-MM-YYYY'))),0)*(CASE 
				 WHEN 
				 (select nvl(FMBR.AVG_EXCHANGE_RATE,0) 
				  from  FA_MC_BOOKS_RATES FMBR
				  where FMBR.ASSET_ID = a.ASSET_ID 
				  and   FMBR.transaction_header_id = a.transaction_header_id_in) > 0 THEN
				 (select nvl(FMBR.AVG_EXCHANGE_RATE,0) 
				  from  FA_MC_BOOKS_RATES FMBR
				  where FMBR.ASSET_ID = a.ASSET_ID 
				  and   FMBR.transaction_header_id = a.transaction_header_id_in)
				  WHEN a.original_cost < 0 or a.original_cost > 0 THEN
				  (select nvl((FMBR.original_cost/a.original_cost),0) 
					from  FA_MC_BOOKS FMBR
					where FMBR.ASSET_ID = a.ASSET_ID 
					and   FMBR.transaction_header_id_in = a.transaction_header_id_in) 
				  WHEN a.COST < 0 or a.COST > 0 THEN
				  (select nvl((FMBR.COST/a.COST),0) 
					from  FA_MC_BOOKS FMBR
					where FMBR.ASSET_ID = a.ASSET_ID 
					and   FMBR.transaction_header_id_in = a.transaction_header_id_in)	
				ELSE 0
				END) ADDITION_DEP_RESERVE_USD,
nvl((SELECT NVL(XAL.ACCOUNTED_DR,XAL.ACCOUNTED_CR)
---ad.asset_id, ad.asset_number, adtl.description, de.book_type_code, de.period_counter, dp.period_name, de.deprn_run_id, de.event_id, de.reversal_event_id 
 from fa_deprn_events de, fa_additions_b ad, fa_additions_tl adtl, fa_deprn_periods dp ,XLA_AE_HEADERS XAH, XLA_AE_LINES XAL
WHERE ad.asset_id = de.asset_id and adtl.asset_id = ad.asset_id and adtl.language = USERENV('LANG') 
 and de.book_type_code = dp.book_type_code and de.period_counter = dp.period_counter
and ad.asset_id =FADD.ASSET_ID
----  (select asset_id  from FA_additions_b where asset_number='7423')
and de.book_type_code= dp.book_type_code
AND XAH.AE_HEADER_ID=XAL.AE_HEADER_ID
AND XAH.APPLICATION_ID='140'
AND XAH.EVENT_ID= de.EVENT_ID
and   dp.period_name =:P_ACC_PERIOD
and rownum <2
),0) DEP_TRANSFER,
(nvl((SELECT NVL(XAL.ACCOUNTED_DR,XAL.ACCOUNTED_CR)
---ad.asset_id, ad.asset_number, adtl.description, de.book_type_code, de.period_counter, dp.period_name, de.deprn_run_id, de.event_id, de.reversal_event_id 
 from fa_deprn_events de, fa_additions_b ad, fa_additions_tl adtl, fa_deprn_periods dp ,XLA_AE_HEADERS XAH, XLA_AE_LINES XAL
WHERE ad.asset_id = de.asset_id and adtl.asset_id = ad.asset_id and adtl.language = USERENV('LANG') 
 and de.book_type_code = dp.book_type_code and de.period_counter = dp.period_counter
and ad.asset_id =FADD.ASSET_ID
----  (select asset_id  from FA_additions_b where asset_number='7423')
and de.book_type_code= dp.book_type_code
AND XAH.AE_HEADER_ID=XAL.AE_HEADER_ID
AND XAH.APPLICATION_ID='140'
AND XAH.EVENT_ID= de.EVENT_ID
and   dp.period_name =:P_ACC_PERIOD
and rownum <2
),0))*((CASE 
				 WHEN 
				 (select nvl(FMBR.AVG_EXCHANGE_RATE,0) 
				  from  FA_MC_BOOKS_RATES FMBR
				  where FMBR.ASSET_ID = a.ASSET_ID 
				  and   FMBR.transaction_header_id = a.transaction_header_id_in) > 0 THEN
				 (select nvl(FMBR.AVG_EXCHANGE_RATE,0) 
				  from  FA_MC_BOOKS_RATES FMBR
				  where FMBR.ASSET_ID = a.ASSET_ID 
				  and   FMBR.transaction_header_id = a.transaction_header_id_in)
				  WHEN a.original_cost < 0 or a.original_cost > 0 THEN
				  (select nvl((FMBR.original_cost/a.original_cost),0) 
					from  FA_MC_BOOKS FMBR
					where FMBR.ASSET_ID = a.ASSET_ID 
					and   FMBR.transaction_header_id_in = a.transaction_header_id_in) 
				  WHEN a.COST < 0 or a.COST > 0 THEN
				  (select nvl((FMBR.COST/a.COST),0) 
					from  FA_MC_BOOKS FMBR
					where FMBR.ASSET_ID = a.ASSET_ID 
					and   FMBR.transaction_header_id_in = a.transaction_header_id_in)	
				ELSE 0
				END)) DEP_TRANSFER_USD,
( select  min( trunc(A.date_effective)) from fa_asset_history A,  fa_additions_b B 
where A.asset_id= B.asset_id
and A.asset_id= FADD.ASSET_ID
and A.ASSET_TYPE ='CAPITALIZED'
AND A.date_effective<= (SELECT NVL(period_close_date, SYSDATE) FROM FA_DEPRN_PERIODS WHERE period_name in( :P_ACC_PERIOD)
                                     AND book_type_code = :P_BOOK_TYPE_CODE) 

) Capitalized_date ,
  (CASE
				WHEN 
				(nvl((((SELECT ua1.deprn_reserve
                     FROM FA_DEPRN_SUMMARY ua1,FA_DEPRN_PERIODS kc4
                     WHERE ua1.asset_id=a.asset_id
                           AND ua1.book_type_code=:P_BOOK_TYPE_CODE
                           AND kc4.PERIOD_NAME= :P_ACC_PERIOD
						   AND kc4.book_type_code = ua1.book_type_code -- Add to handle multiple books
                           AND ua1.period_counter = kc4.period_counter) * (f.units_assigned))/ FADD.current_units),0) = 0)
				THEN
				nvl((((SELECT ua1.deprn_reserve
                     FROM FA_DEPRN_SUMMARY ua1
					 --,FA_DEPRN_PERIODS kc4
                     WHERE ua1.asset_id=a.asset_id
                     AND ua1.book_type_code=:P_BOOK_TYPE_CODE
                     --AND kc4.PERIOD_NAME= :P_ACC_PERIOD
                     --AND ua1.period_counter = kc4.period_counter) * (f.units_assigned))/ FADD.current_units),0)
					 AND ua1.period_counter = (select max(FDS3.period_counter) from FA_DEPRN_SUMMARY FDS3 where FDS3.asset_id=a.asset_id and FDS3.book_type_code=:P_BOOK_TYPE_CODE)) * (f.units_assigned))/ FADD.current_units),0)
				ELSE
				nvl((((SELECT ua1.deprn_reserve
                     FROM FA_DEPRN_SUMMARY ua1,FA_DEPRN_PERIODS kc4
                     WHERE ua1.asset_id=a.asset_id
                           AND ua1.book_type_code=:P_BOOK_TYPE_CODE
                           AND kc4.PERIOD_NAME= :P_ACC_PERIOD
						   AND kc4.book_type_code = ua1.book_type_code -- Add to handle multiple books
                           AND ua1.period_counter = kc4.period_counter) * (f.units_assigned))/ FADD.current_units),0)
				END	)					   AS ACCUM_DEPRN,
				
				
				
				 (CASE
				WHEN 
				(nvl((((SELECT ua1.deprn_reserve
                     FROM FA_DEPRN_SUMMARY ua1,FA_DEPRN_PERIODS kc4
                     WHERE ua1.asset_id=a.asset_id
                           AND ua1.book_type_code=:P_BOOK_TYPE_CODE
                           AND kc4.PERIOD_NAME= :P_ACC_PERIOD
						   AND kc4.book_type_code = ua1.book_type_code -- Add to handle multiple books
                           AND ua1.period_counter = kc4.period_counter) * (f.units_assigned))/ FADD.current_units),0) = 0)
				THEN
				nvl((((SELECT ua1.deprn_reserve
                     FROM FA_DEPRN_SUMMARY ua1
					 --,FA_DEPRN_PERIODS kc4
                     WHERE ua1.asset_id=a.asset_id
                     AND ua1.book_type_code=:P_BOOK_TYPE_CODE
                     --AND kc4.PERIOD_NAME= :P_ACC_PERIOD
                     --AND ua1.period_counter = kc4.period_counter) * (f.units_assigned))/ FADD.current_units),0)
					 AND ua1.period_counter = (select max(FDS3.period_counter) from FA_DEPRN_SUMMARY FDS3 where FDS3.asset_id=a.asset_id and FDS3.book_type_code=:P_BOOK_TYPE_CODE)) * (f.units_assigned))/ FADD.current_units),0)
				ELSE
				nvl((((SELECT ua1.deprn_reserve
                     FROM FA_DEPRN_SUMMARY ua1,FA_DEPRN_PERIODS kc4
                     WHERE ua1.asset_id=a.asset_id
                           AND ua1.book_type_code=:P_BOOK_TYPE_CODE
                           AND kc4.PERIOD_NAME= :P_ACC_PERIOD
						   AND kc4.book_type_code = ua1.book_type_code -- Add to handle multiple books
                           AND ua1.period_counter = kc4.period_counter) * (f.units_assigned))/ FADD.current_units),0)
				END	)*(CASE 
				 WHEN 
				 (select nvl(FMBR.AVG_EXCHANGE_RATE,0) 
				  from  FA_MC_BOOKS_RATES FMBR
				  where FMBR.ASSET_ID = a.ASSET_ID 
				  and   FMBR.transaction_header_id = a.transaction_header_id_in) > 0 THEN
				 (select nvl(FMBR.AVG_EXCHANGE_RATE,0) 
				  from  FA_MC_BOOKS_RATES FMBR
				  where FMBR.ASSET_ID = a.ASSET_ID 
				  and   FMBR.transaction_header_id = a.transaction_header_id_in)
				  WHEN a.original_cost < 0 or a.original_cost > 0 THEN
				  (select nvl((FMBR.original_cost/a.original_cost),0) 
					from  FA_MC_BOOKS FMBR
					where FMBR.ASSET_ID = a.ASSET_ID 
					and   FMBR.transaction_header_id_in = a.transaction_header_id_in) 
				  WHEN a.COST < 0 or a.COST > 0 THEN
				  (select nvl((FMBR.COST/a.COST),0) 
					from  FA_MC_BOOKS FMBR
					where FMBR.ASSET_ID = a.ASSET_ID 
					and   FMBR.transaction_header_id_in = a.transaction_header_id_in)	
				ELSE 0
				END) AS ACCUM_DEPRN_USD,
					 (CASE
				WHEN 
				(nvl((((SELECT sa1.ytd_deprn
                     FROM FA_DEPRN_SUMMARY sa1,FA_DEPRN_PERIODS kc2
                     WHERE sa1.asset_id=a.asset_id
                           AND sa1.book_type_code=:P_BOOK_TYPE_CODE
                           AND kc2.PERIOD_NAME= :P_ACC_PERIOD
						   AND kc2.book_type_code = sa1.book_type_code -- Add to handle multiple books
                           AND sa1.period_counter = kc2.period_counter) * (f.units_assigned))/ FADD.current_units),0) = 0)
				THEN
				nvl((((SELECT sa1.ytd_deprn
                     FROM FA_DEPRN_SUMMARY sa1
					 --,FA_DEPRN_PERIODS kc4
                     WHERE sa1.asset_id=a.asset_id
                     AND sa1.book_type_code=:P_BOOK_TYPE_CODE
                     --AND kc4.PERIOD_NAME= :P_ACC_PERIOD
                     --AND ua1.period_counter = kc4.period_counter) * (f.units_assigned))/ FADD.current_units),0)
					 AND sa1.period_counter = (select max(FDS5.period_counter) from FA_DEPRN_SUMMARY FDS5 where FDS5.asset_id=a.asset_id and FDS5.book_type_code=:P_BOOK_TYPE_CODE)) * (f.units_assigned))/ FADD.current_units),0)
				ELSE
				nvl((((SELECT sa1.ytd_deprn
                     FROM FA_DEPRN_SUMMARY sa1,FA_DEPRN_PERIODS kc2
                     WHERE sa1.asset_id=a.asset_id
                           AND sa1.book_type_code=:P_BOOK_TYPE_CODE
                           AND kc2.PERIOD_NAME= :P_ACC_PERIOD
						   AND kc2.book_type_code = sa1.book_type_code -- Add to handle multiple books
                           AND sa1.period_counter = kc2.period_counter) * (f.units_assigned))/ FADD.current_units),0)
				END	)					   AS YTD_DEPRN,
				
				(CASE
				WHEN 
				(nvl((((SELECT sa1.ytd_deprn
                     FROM FA_DEPRN_SUMMARY sa1,FA_DEPRN_PERIODS kc2
                     WHERE sa1.asset_id=a.asset_id
                           AND sa1.book_type_code=:P_BOOK_TYPE_CODE
                           AND kc2.PERIOD_NAME= :P_ACC_PERIOD
						   AND kc2.book_type_code = sa1.book_type_code -- Add to handle multiple books
                           AND sa1.period_counter = kc2.period_counter) * (f.units_assigned))/ FADD.current_units),0) = 0)
				THEN
				nvl((((SELECT sa1.ytd_deprn
                     FROM FA_DEPRN_SUMMARY sa1
					 --,FA_DEPRN_PERIODS kc4
                     WHERE sa1.asset_id=a.asset_id
                     AND sa1.book_type_code=:P_BOOK_TYPE_CODE
                     --AND kc4.PERIOD_NAME= :P_ACC_PERIOD
                     --AND ua1.period_counter = kc4.period_counter) * (f.units_assigned))/ FADD.current_units),0)
					 AND sa1.period_counter = (select max(FDS5.period_counter) from FA_DEPRN_SUMMARY FDS5 where FDS5.asset_id=a.asset_id and FDS5.book_type_code=:P_BOOK_TYPE_CODE)) * (f.units_assigned))/ FADD.current_units),0)
				ELSE
				nvl((((SELECT sa1.ytd_deprn
                     FROM FA_DEPRN_SUMMARY sa1,FA_DEPRN_PERIODS kc2
                     WHERE sa1.asset_id=a.asset_id
                           AND sa1.book_type_code=:P_BOOK_TYPE_CODE
                           AND kc2.PERIOD_NAME= :P_ACC_PERIOD
						   AND kc2.book_type_code = sa1.book_type_code -- Add to handle multiple books
                           AND sa1.period_counter = kc2.period_counter) * (f.units_assigned))/ FADD.current_units),0)
				END	)	*(CASE 
				 WHEN 
				 (select nvl(FMBR.AVG_EXCHANGE_RATE,0) 
				  from  FA_MC_BOOKS_RATES FMBR
				  where FMBR.ASSET_ID = a.ASSET_ID 
				  and   FMBR.transaction_header_id = a.transaction_header_id_in) > 0 THEN
				 (select nvl(FMBR.AVG_EXCHANGE_RATE,0) 
				  from  FA_MC_BOOKS_RATES FMBR
				  where FMBR.ASSET_ID = a.ASSET_ID 
				  and   FMBR.transaction_header_id = a.transaction_header_id_in)
				  WHEN a.original_cost < 0 or a.original_cost > 0 THEN
				  (select nvl((FMBR.original_cost/a.original_cost),0) 
					from  FA_MC_BOOKS FMBR
					where FMBR.ASSET_ID = a.ASSET_ID 
					and   FMBR.transaction_header_id_in = a.transaction_header_id_in) 
				  WHEN a.COST < 0 or a.COST > 0 THEN
				  (select nvl((FMBR.COST/a.COST),0) 
					from  FA_MC_BOOKS FMBR
					where FMBR.ASSET_ID = a.ASSET_ID 
					and   FMBR.transaction_header_id_in = a.transaction_header_id_in)	
				ELSE 0
				END)			   AS YTD_DEPRN_USD,
				((NVL((SELECT to_number(fb1.cost)
                       FROM FA_BOOKS fb1, 
                            FA_DEPRN_PERIODS fdp
                       WHERE fb1.asset_id =a.asset_id 
                             AND fdp.period_name = :P_ACC_PERIOD
                             AND fdp.book_type_code = fb1.book_type_code
                             AND fb1.book_type_code = :P_BOOK_TYPE_CODE
                             AND  fb1.transaction_header_id_in =(SELECT MAX(fb2.transaction_header_id_in) 
                                                                  FROM FA_BOOKS fb2 
				                                  WHERE fb2.asset_id = fb1.asset_id 
                                                                        AND fb2.book_type_code = fb1.book_type_code
                                                                        AND NVL (fb2.date_ineffective, SYSDATE) > = fdp.period_open_date
                              AND NVL (fdp.period_close_date, SYSDATE) > =fb2.date_effective )),0) *(f.units_assigned))/FADD.current_units) CURRENT_COST


FROM fa_books a,
FA_ADDITIONS_B FADD,     
FA_ADDITIONS_TL FADDT,
fa_categories_b e,
FA_DEPRN_SUMMARY S,
FA_CATEGORY_BOOK_DEFAULTS E1,                
fa_distribution_history f,
gl_code_combinations g,
fa_locations h,
fa_book_controls i,
gl_ledgers j,  
fa_impairments n,              
FA_METHODS FM,
FA_CONVENTION_TYPES FCT,
FA_CONVENTION_TYPES RFCT,
fa_retirements Fr/*,
(SELECT A.ASSET_ID,

(CASE 
				 WHEN 
				 (select nvl(FMBR.AVG_EXCHANGE_RATE,0) 
				  from  FA_MC_BOOKS_RATES FMBR
				  where FMBR.ASSET_ID = a.ASSET_ID 
				  and   FMBR.transaction_header_id = a.transaction_header_id_in) > 0 THEN
				 (select nvl(FMBR.AVG_EXCHANGE_RATE,0) 
				  from  FA_MC_BOOKS_RATES FMBR
				  where FMBR.ASSET_ID = a.ASSET_ID 
				  and   FMBR.transaction_header_id = a.transaction_header_id_in)
				  WHEN a.original_cost < 0 or a.original_cost > 0 THEN
				  (select nvl((FMBR.original_cost/a.original_cost),0) 
					from  FA_MC_BOOKS FMBR
					where FMBR.ASSET_ID = a.ASSET_ID 
					and   FMBR.transaction_header_id_in = a.transaction_header_id_in) 
				  WHEN a.COST < 0 or a.COST > 0 THEN
				  (select nvl((FMBR.COST/a.COST),0) 
					from  FA_MC_BOOKS FMBR
					where FMBR.ASSET_ID = a.ASSET_ID 
					and   FMBR.transaction_header_id_in = a.transaction_header_id_in)	
				ELSE 0
				END)as BLENDED_RATE
				FROM 
				FA_BOOKS A)BA*/
			
--GL_DAILY_RATES GDR,
--GL_DAILY_CONVERSION_TYPES GDCT 
WHERE
A.ASSET_ID = FADD.ASSET_ID
--AND FADD.ASSET_ID =BA.ASSET_ID(+)
AND FADD.ASSET_ID = FADDT.ASSET_ID
AND fadd.asset_category_id = e.category_id
AND A.ASSET_ID = S.ASSET_ID
AND a.book_type_code = s.book_type_code
AND a.book_type_code = e1.book_type_code
AND e.category_id = e1.category_id
AND f.location_id = h.location_id
AND A.ASSET_ID = F.ASSET_ID
AND f.code_combination_id = g.code_combination_id
AND a.book_type_code = i.book_type_code
AND i.set_of_books_id = j.ledger_id
AND a.asset_id = n.asset_id(+)
AND A.BOOK_TYPE_CODE = N.BOOK_TYPE_CODE(+)
AND E1.METHOD_ID=FM.METHOD_ID(+)
AND E1.CONVENTION_TYPE_ID=FCT.CONVENTION_TYPE_ID            
AND FR.RETIREMENT_CONVENTION_TYPE_ID=RFCT.CONVENTION_TYPE_ID(+)
AND F.RETIREMENT_ID=FR.RETIREMENT_ID(+)
AND f.transaction_header_id_out IS NULL
AND a.transaction_header_id_out IS NULL
AND f.date_ineffective IS NULL
AND a.date_ineffective IS NULL
AND a.transaction_header_id_out IS NULL 
AND FADDT.LANGUAGE= userenv('LANG')
--AND GDR.FROM_CURRENCY='CAD' 
--AND GDR.TO_CURRENCY='USD' 
--AND GDR.CONVERSION_TYPE=GDCT.CONVERSION_TYPE
--AND GDCT.USER_CONVERSION_TYPE='MOR'
--AND TRUNC(GDR.CONVERSION_DATE)=TRUNC(A.DATE_PLACED_IN_SERVICE)
--AND FADD.ASSET_NUMBER=NVL(:P_ASSET_NUMBER,FADD.ASSET_NUMBER)
AND (FADD.ASSET_NUMBER IN  (:P_ASSET_NUMBER) OR 2 IN :P_ASSET_NUMBER||2)
--AND G.SEGMENT1 in(:P_SEGMENT1,G.SEGMENT1)
AND FADD.creation_date <= (SELECT NVL(period_close_date, SYSDATE) FROM FA_DEPRN_PERIODS WHERE period_name in( :P_ACC_PERIOD)
AND book_type_code = :P_BOOK_TYPE_CODE) 
---  AND (A.DATE_PLACED_IN_SERVICE)<=(SELECT calendar_period_close_date
/*AND ( trunc(A.date_Effective))<=(SELECT calendar_period_close_date
FROM FA_DEPRN_PERIODS
WHERE period_name in(:P_ACC_PERIOD)
AND book_type_code = :P_BOOK_TYPE_CODE)
*/
AND A.BOOK_TYPE_CODE= :P_BOOK_TYPE_CODE
--AND FADD.ASSET_NUMBER in ('7442','7688')
--and FADD.ATTRIBUTE3='Class 1'
--and e.segment2='207-4'
--AND FADD.ASSET_NUMBER IN  (:P_ASSET_NUMBER,FADD.ASSET_NUMBER)
AND (FADD.ASSET_NUMBER IN  (:P_ASSET_NUMBER) OR 2 IN :P_ASSET_NUMBER||2)
--AND G.SEGMENT1  in (:P_SEGMENT1)
AND (G.SEGMENT1 IN  (:P_SEGMENT1) OR 2 IN :P_SEGMENT1||2)
AND FADD.ASSET_TYPE='CAPITALIZED'
AND FADD.ATTRIBUTE3 IS NOT NULL)
group by 
CCA_CLASS,
COMPANY,      
      MAJOR_CATEGORY,
	  minor_category