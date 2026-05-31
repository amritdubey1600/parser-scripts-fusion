/*--#-----------------------------------------------------------------------------------------------------------------#
--# CCL FA Assignment Report
--# DESCRIPTION  : This data model query to fetch asset details 
--#                
--# CREATION DATE     :
--# CREATED BY      : 
--#
--# MODIFICATION HISTORY:
--# CR#                 Author            Date                  Description
--# REL-023	          Nuri Chetia       22-Nov-2018       Changed current cost USD and NBV_USD
--# REL-058	          Nuri Chetia       11-Nov-2021       GERITM24893534 made ytd depreciation changes for BR_BRL_CORP, 
--#                                                       BR_BRL_TAX_IF and BR_BRL_TAX_FSC
--# REL-060	          Nuri Chetia       03-DEC-2021       GERITM27046260 bug fix to restrict duplicate line by adding book type code 
--# ---------------------------------------------------------------------------------------------------------------------
*/
SELECT DISTINCT FADD.ASSET_TYPE,
                FADD.ASSET_NUMBER, 
                FADDT.DESCRIPTION ASSET_DESC,
                (CASE
                   WHEN FADD.SERIAL_NUMBER IS NOT NULL
                   THEN
                      '''' || FADD.SERIAL_NUMBER
                   ELSE
                      FADD.SERIAL_NUMBER
                END) AS SERIAL_NUMBER,
                FADD.TAG_NUMBER,
                ( SELECT LISTAGG (b1.invoice_number, ',')
                             WITHIN GROUP (ORDER BY b1.invoice_number)
                             invoice_number
                     FROM FA_ASSET_INVOICES b1
                    WHERE     a.asset_id = b1.asset_id(+)
                          AND b1.date_ineffective IS NULL
                          AND b1.invoice_transaction_id_out IS NULL
                 GROUP BY b1.asset_id) INVOICE_NUMBER,
                ( SELECT LISTAGG (b2.po_number, ',')
                             WITHIN GROUP (ORDER BY b2.po_number)
                             po_number
                     FROM FA_ASSET_INVOICES b2
                    WHERE     a.asset_id = b2.asset_id(+)
                          AND b2.date_ineffective IS NULL
                          AND b2.invoice_transaction_id_out IS NULL
                 GROUP BY b2.asset_id) PO_NUMBER,
                FADD.MODEL_NUMBER,
                FADD.MANUFACTURER_NAME,
                E.SEGMENT1 MAJOR_CATEGORY,
                e.segment2 minor_category,
                E.SEGMENT3 SUB_CATEGORY,
                H.SEGMENT1 COUNTRY,
                H.SEGMENT2 STATE,
                H.SEGMENT3 CITY,
                H.SEGMENT4 BUILDING,
                H.SEGMENT5 BUILDING_ID,
                to_char(FADD.CREATION_DATE,'MM/DD/YYYY') CREATION_DATE,
                TO_CHAR(A.DATE_PLACED_IN_SERVICE,'MM/DD/YYYY') DATE_PLACED_IN_SERVICE,
                F.UNITS_ASSIGNED UNITS,
                FCT.PRORATE_CONVENTION_CODE PRORATE_CONVENTION,
                RFCT.PRORATE_CONVENTION_CODE RETIREMENT_PRORATE_CONVENTION,
                NULL BUSINESS_UNIT,
                G.SEGMENT1 COMPANY,
                G.SEGMENT2 ACCOUNT,
                G.SEGMENT3 TRADING_PARTNER,
                G.SEGMENT4 COST_CENTER,
                G.SEGMENT5 GEOGRAPHY,
                G.SEGMENT6 PROJECT_CODE,
                G.SEGMENT7 REF_CODE,
                G.SEGMENT8 PRODUCT_LINE,
                G.SEGMENT9 BOOK_TYPE,
                G.SEGMENT10 FUTURE1,
                G.SEGMENT11 FUTURE2,
                to_number(((NVL(a.original_cost, 0) * (f.units_assigned))/ FADD.current_units)) FIRST_COST, --A.ORIGINAL_COST, 
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
                              AND NVL (fdp.period_close_date, SYSDATE) > =fb2.date_effective )),0) *(f.units_assigned))/FADD.current_units) CURRENT_COST,
                --REL023 GEINC1741241 added below code
                ((NVL((SELECT TO_NUMBER(fb1.cost)
                       FROM FA_MC_BOOKS fb1, 
                            FA_DEPRN_PERIODS fdp
                       WHERE fb1.asset_id =a.asset_id 
                             AND fdp.period_name = :P_ACC_PERIOD
                             AND fdp.book_type_code = fb1.book_type_code
                             AND fb1.book_type_code = :P_BOOK_TYPE_CODE
                             AND  fb1.transaction_header_id_in =(SELECT MAX(fb2.transaction_header_id_in) 
                                                                  FROM FA_MC_BOOKS fb2 
                                                                  WHERE fb2.asset_id = fb1.asset_id 
                                                                    AND fb2.book_type_code = fb1.book_type_code
                                                                    AND NVL (fb2.date_ineffective, SYSDATE) > = fdp.period_open_date
                                                                    AND NVL (fdp.period_close_date, SYSDATE) > =fb2.date_effective )),0) *(f.units_assigned))/FADD.current_units) Current_Cost_USD,
                --REL023 GEINC1741241 added above code
                NULL ASSET_COST_ACCOUNT,
               to_number(((NVL((SELECT deprn_amount
                     FROM FA_DEPRN_SUMMARY Kb, 
                          FA_DEPRN_PERIODS kc
                     WHERE kb.asset_id = a.asset_id
                           AND   kb.book_type_code = a.book_type_code
                           AND   kb.book_type_code = :P_BOOK_TYPE_CODE
						   AND   kb.book_type_code = kc.book_type_code -- Add to handle multiple books
                           AND   kb.period_counter = kc.period_counter
                           AND   kc.period_name = :P_ACC_PERIOD),0)*(f.units_assigned)) / FADD.current_units)) CORRENT_DEPRN_AMOUNT,
            
            to_number(((NVL((SELECT deprn_amount
                     FROM FA_MC_DEPRN_SUMMARY Kb, 
                          FA_DEPRN_PERIODS kc
                     WHERE kb.asset_id = a.asset_id
                           AND   kb.book_type_code = a.book_type_code
                           AND   kb.book_type_code = :P_BOOK_TYPE_CODE
						   AND   kb.book_type_code = kc.book_type_code -- Add to handle multiple books
                           AND   kb.period_counter = kc.period_counter
                           AND   kc.period_name = :P_ACC_PERIOD),0)*(f.units_assigned)) / FADD.current_units)) CURRENT_DEPR_AMOUNT_USD,
						   
						   
              /* NVL(((SELECT sa1.ytd_deprn
                      FROM FA_DEPRN_SUMMARY sa1,FA_DEPRN_PERIODS kc2
                      WHERE sa1.asset_id=a.asset_id
                            AND sa1.book_type_code=:P_BOOK_TYPE_CODE
                            AND sa1.period_counter = kc2.period_counter
                            AND kc2.PERIOD_NAME=:P_ACC_PERIOD) * (f.units_assigned) / FADD.current_units),0) AS YTD_DEPRN,*/
               --REL058 GERITM24893534 added below               
			   CASE WHEN (a.book_type_code in ('BR_BRL_CORP','BR_BRL_TAX_IF','BR_BRL_TAX_FSC') 
                and 
                (TO_CHAR(TO_DATE((SELECT MAX (b3.date_retired)
                   FROM FA_RETIREMENTS b3
                  WHERE     b3.asset_id = a.asset_id
                        AND b3.book_type_code = a.book_type_code
                        AND b3.status = 'PROCESSED')),'YY')<>substr(:P_ACC_PERIOD,7)))
				THEN 0
				WHEN (a.book_type_code in ('BR_BRL_CORP','BR_BRL_TAX_IF','BR_BRL_TAX_FSC') 
                and 
                (SELECT fdp.fiscal_year
                   FROM fa_deprn_summary fds, fa_deprn_periods fdp
                  WHERE    fds.book_type_code = fdp.book_type_code
                    AND    fds.period_counter = fdp.period_counter
                    AND fds.book_type_code = a.book_type_code
			        AND fds.asset_id = a.asset_id
                    AND fdp.period_counter=(SELECT  max(fdp1.period_counter) FROM fa_deprn_summary fds1, fa_deprn_periods fdp1
                                             WHERE fds1.book_type_code = fdp1.book_type_code
                                               AND fds1.period_counter = fdp1.period_counter
                                               AND fds1.book_type_code=a.book_type_code
                                               AND fds1.asset_id = a.asset_id))<>substr(:P_ACC_PERIOD,5))
				THEN 0
                ELSE
                (
				--REL058 GERITM24893534 added above
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
				END	)
				) END --REL058 GERITM24893534 added 
                 AS YTD_DEPRN,		
                                   (CASE
				WHEN 
				(nvl((((SELECT sa1.ytd_deprn
                     FROM FA_MC_DEPRN_SUMMARY sa1,FA_DEPRN_PERIODS kc2
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
					 AND sa1.period_counter = (select max(FDS5.period_counter) from FA_MC_DEPRN_SUMMARY FDS5 where FDS5.asset_id=a.asset_id and FDS5.book_type_code=:P_BOOK_TYPE_CODE)) * (f.units_assigned))/ FADD.current_units),0)
				ELSE
				nvl((((SELECT sa1.ytd_deprn
                     FROM FA_MC_DEPRN_SUMMARY sa1,FA_DEPRN_PERIODS kc2
                     WHERE sa1.asset_id=a.asset_id
                           AND sa1.book_type_code=:P_BOOK_TYPE_CODE
                           AND kc2.PERIOD_NAME= :P_ACC_PERIOD
						   AND kc2.book_type_code = sa1.book_type_code -- Add to handle multiple books
                           AND sa1.period_counter = kc2.period_counter) * (f.units_assigned))/ FADD.current_units),0)
				END	)					   AS YTD_DEPR_USD,
							
							
							
							
							
							
                
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
                     FROM FA_MC_DEPRN_SUMMARY ua1,FA_DEPRN_PERIODS kc4
                     WHERE ua1.asset_id=a.asset_id
                           AND ua1.book_type_code=:P_BOOK_TYPE_CODE
                           AND kc4.PERIOD_NAME= :P_ACC_PERIOD
						   AND kc4.book_type_code = ua1.book_type_code -- Add to handle multiple books
                           AND ua1.period_counter = kc4.period_counter) * (f.units_assigned))/ FADD.current_units),0) = 0)
				THEN
				nvl((((SELECT ua1.deprn_reserve
                     FROM FA_MC_DEPRN_SUMMARY ua1
					 --,FA_DEPRN_PERIODS kc4
                     WHERE ua1.asset_id=a.asset_id
                     AND ua1.book_type_code=:P_BOOK_TYPE_CODE
                     --AND kc4.PERIOD_NAME= :P_ACC_PERIOD
                     --AND ua1.period_counter = kc4.period_counter) * (f.units_assigned))/ FADD.current_units),0)
					 AND ua1.period_counter = (select max(FDS3.period_counter) from FA_MC_DEPRN_SUMMARY FDS3 where FDS3.asset_id=a.asset_id and FDS3.book_type_code=:P_BOOK_TYPE_CODE)) * (f.units_assigned))/ FADD.current_units),0)
				ELSE
				nvl((((SELECT ua1.deprn_reserve
                     FROM FA_MC_DEPRN_SUMMARY ua1,FA_DEPRN_PERIODS kc4
                     WHERE ua1.asset_id=a.asset_id
                           AND ua1.book_type_code=:P_BOOK_TYPE_CODE
                           AND kc4.PERIOD_NAME= :P_ACC_PERIOD
						   AND kc4.book_type_code = ua1.book_type_code -- Add to handle multiple books
                           AND ua1.period_counter = kc4.period_counter) * (f.units_assigned))/ FADD.current_units),0)
				END	)					   AS ACCUM_DEPRN_USD,
                
               /*NVL(((((SELECT ua4.deprn_reserve
                     FROM FA_DEPRN_SUMMARY ua4,FA_DEPRN_PERIODS kc9
                     WHERE ua4.asset_id=a.asset_id
                           AND ua4.book_type_code=:P_BOOK_TYPE_CODE
                           AND kc9.PERIOD_NAME=:P_ACC_PERIOD
                           AND ua4.period_counter = kc9.period_counter) * (f.units_assigned))/ FADD.current_units) - ((SELECT sa5.ytd_deprn
                      FROM FA_DEPRN_SUMMARY sa5,FA_DEPRN_PERIODS FDP2
                      WHERE sa5.asset_id=a.asset_id
                            AND sa5.book_type_code=:P_BOOK_TYPE_CODE
                            AND sa5.period_counter = FDP2.period_counter
                            AND FDP2.PERIOD_NAME=:P_ACC_PERIOD) * (f.units_assigned) / FADD.current_units)),0) PREVIOUS_YEAR_DEPRN_CAL,*/
                NULL DEPRN_RESERVE_ACCT,
                /*To_number(ROUND((nvl((((NVL((SELECT fb1.cost
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
                              AND NVL (fdp.period_close_date, SYSDATE) > =fb2.date_effective )),0) *(f.units_assigned))/FADD.current_units)- (((SELECT 

ua1.deprn_reserve
                     FROM FA_DEPRN_SUMMARY ua1,FA_DEPRN_PERIODS kc8
                     WHERE ua1.asset_id=a.asset_id
                           AND ua1.book_type_code=:P_BOOK_TYPE_CODE
                           AND ua1.period_counter =kc8.period_counter
                            AND kc8.PERIOD_NAME=:P_ACC_PERIOD)) * (f.units_assigned))/ FADD.current_units)),0)* (f.units_assigned) /
FADD.current_units),2)) NET_BOOK_VALUE,*/
                (NVL (a.salvage_value, 0) * (f.units_assigned))/FADD.current_units SALVAGE_VALUE,
                FM.METHOD_CODE DEPRICIATION_METHOD,
                NULL CATEGORY_DEPRN_METHOD,
                TO_CHAR(A.PRORATE_DATE,'MM/DD/YYYY') PRORATE_DATE,
                 nvl((select mth.life_in_months from fa_methods mth where mth.method_id=a.method_id),0) as LIFE_IN_MONTHS,
                                      /*(DECODE(NVL(a.conversion_date,SYSDATE),SYSDATE,
                                                    TO_NUMBER (FLOOR(MONTHS_BETWEEN ((SELECT Rb.calendar_period_close_date
                   			            FROM FA_DEPRN_PERIODS Rb
                                                    WHERE Rb.book_type_code = :P_BOOK_TYPE_CODE
                        		            AND Rb.period_counter = (SELECT MAX (rc.period_counter)
                                  				  FROM FA_DEPRN_PERIODS rc
                                 				  WHERE rc.book_type_code = :P_BOOK_TYPE_CODE)),a.prorate_date))),                            
                                                  TO_NUMBER (FLOOR(MONTHS_BETWEEN ((SELECT Rb1.calendar_period_close_date
                   			          FROM FA_DEPRN_PERIODS Rb1
                                                 WHERE Rb1.book_type_code = a.book_type_code
                        		           AND Rb1.period_counter = (SELECT MAX (rc1.period_counter)
                                  				  FROM FA_DEPRN_PERIODS rc1
                                 				  WHERE rc1.book_type_code = :P_BOOK_TYPE_CODE)),a.deprn_start_date)))))AS NUMBER_OF_MONTHS_DEP,*/
												  
(CASE
 WHEN 
(DECODE(NVL(a.conversion_date,SYSDATE),SYSDATE,TO_NUMBER (FLOOR(MONTHS_BETWEEN ((SELECT Rb.calendar_period_close_date
																				  FROM FA_DEPRN_PERIODS Rb
																				  WHERE Rb.book_type_code = :P_BOOK_TYPE_CODE
																				  AND Rb.period_counter = (SELECT MAX (rc.period_counter)
																										   FROM FA_DEPRN_PERIODS rc
																										   WHERE rc.book_type_code = :P_BOOK_TYPE_CODE)),a.deprn_start_date))),                            
                                                  TO_NUMBER (FLOOR(MONTHS_BETWEEN ((SELECT Rb1.calendar_period_close_date
                   			          FROM FA_DEPRN_PERIODS Rb1
                                                 WHERE Rb1.book_type_code = a.book_type_code
                        		           AND Rb1.period_counter = (SELECT MAX (rc1.period_counter)
                                  				  FROM FA_DEPRN_PERIODS rc1
                                 				  WHERE rc1.book_type_code = :P_BOOK_TYPE_CODE)),a.deprn_start_date))))) > 
nvl((select mth.life_in_months from fa_methods mth where mth.method_id=a.method_id),0)
THEN 
nvl((select mth.life_in_months from fa_methods mth where mth.method_id=a.method_id),0)
ELSE
(DECODE(NVL(a.conversion_date,SYSDATE),SYSDATE,TO_NUMBER (FLOOR(MONTHS_BETWEEN ((SELECT Rb.calendar_period_close_date
																				  FROM FA_DEPRN_PERIODS Rb
																				  WHERE Rb.book_type_code = :P_BOOK_TYPE_CODE
																				  AND Rb.period_counter = (SELECT MAX (rc.period_counter)
																										   FROM FA_DEPRN_PERIODS rc
																										   WHERE rc.book_type_code = :P_BOOK_TYPE_CODE)),a.deprn_start_date))),                            
                                                  TO_NUMBER (FLOOR(MONTHS_BETWEEN ((SELECT Rb1.calendar_period_close_date
                   			          FROM FA_DEPRN_PERIODS Rb1
                                                 WHERE Rb1.book_type_code = a.book_type_code
                        		           AND Rb1.period_counter = (SELECT MAX (rc1.period_counter)
                                  				  FROM FA_DEPRN_PERIODS rc1
                                 				  WHERE rc1.book_type_code = :P_BOOK_TYPE_CODE)),a.deprn_start_date)))))
END) AS NUMBER_OF_MONTHS_DEP,

                    TO_CHAR(TO_DATE((SELECT MAX (b3.date_retired)
                   FROM FA_RETIREMENTS b3
                  WHERE     b3.asset_id = a.asset_id
                        AND b3.book_type_code = a.book_type_code
                        AND b3.status = 'PROCESSED')),'MM/DD/YYYY') AS RETIREMENT_DATE,
                J.CURRENCY_CODE,
                A.BOOK_TYPE_CODE,
                FADD.PROPERTY_TYPE_CODE,   
                NULL FULL_NAME,
                NULL USER_NAME,
				
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
				END)as BLENDED_RATE, 
				
                TO_CHAR(A.DATE_PLACED_IN_SERVICE,'YYYY') PERIOD_YEAR,
                TO_CHAR(A.DATE_PLACED_IN_SERVICE,'MON-YY') PERIOD_NAME,
                NULL IMPAIRMENT_RESERVE, --S.IMPAIRMENT_RESERVE IMPAIRMENT_RESERVE,
                NULL YTD_IMPAIRMENT,--S.YTD_IMPAIRMENT YTD_IMPAIRMENT,
                NULL IMPAIRMENT_LOSS,--S.IMPAIR_LOSS_BALANCE IMPAIRMENT_LOSS,
                                           
                --FADDT.DESCRIPTION Retirement_DESC,
				
				decode(((NVL((SELECT distinct '1'
                       FROM FA_RETIREMENTS FAR
                       WHERE FAR.book_type_code = :P_BOOK_TYPE_CODE
                       AND FAR.date_retired<= (SELECT (CALENDAR_PERIOD_CLOSE_DATE) 
											   FROM FA_DEPRN_PERIODS FDP4
											   where FDP4.book_type_code = :P_BOOK_TYPE_CODE  -- add to handle multiple books
											   and period_name= :P_ACC_PERIOD)
                       AND FAR.asset_id = A.ASSET_ID
                       AND FAR.status = 'PROCESSED'),0)*f.units_assigned)/FADD.current_units),'1',FADDT.DESCRIPTION,NULL) AS Retirement_DESC,
				
                ((NVL((SELECT SUM (FAR.COST_RETIRED)
                       FROM FA_RETIREMENTS FAR
                       WHERE FAR.book_type_code = :P_BOOK_TYPE_CODE
                       AND FAR.date_retired<= (SELECT (CALENDAR_PERIOD_CLOSE_DATE) FROM FA_DEPRN_PERIODS FDP1 
												where FDP1.book_type_code = :P_BOOK_TYPE_CODE  -- add to handle multiple books
												and period_name= :P_ACC_PERIOD)
                       AND FAR.asset_id = A.ASSET_ID
                       AND FAR.status = 'PROCESSED'),0)*f.units_assigned)/FADD.current_units)AS COST_RETIRED,
                ((NVL((SELECT SUM (FAR.nbv_retired)
                       FROM FA_RETIREMENTS FAR
                       WHERE FAR.book_type_code = :P_BOOK_TYPE_CODE
                       AND FAR.date_retired<= (SELECT (CALENDAR_PERIOD_CLOSE_DATE) FROM FA_DEPRN_PERIODS FDP2
													   where FDP2.book_type_code = :P_BOOK_TYPE_CODE  -- add to handle multiple books
													   and period_name= :P_ACC_PERIOD)
                       AND FAR.asset_id = A.ASSET_ID
                       AND FAR.status = 'PROCESSED'),0)*f.units_assigned)/FADD.current_units) AS NBV_RETIRED,
                ((NVL((SELECT SUM (FAR.PROCEEDS_OF_SALE)
                       FROM FA_RETIREMENTS FAR
                       WHERE FAR.book_type_code = :P_BOOK_TYPE_CODE
                       AND FAR.date_retired<= (SELECT (CALENDAR_PERIOD_CLOSE_DATE) 
											   FROM FA_DEPRN_PERIODS FDP3
											   where FDP3.book_type_code = :P_BOOK_TYPE_CODE  -- add to handle multiple books
											   and period_name= :P_ACC_PERIOD)
                       AND FAR.asset_id = A.ASSET_ID
                       AND FAR.status = 'PROCESSED'),0)*f.units_assigned)/FADD.current_units) as PROCEEDS_OF_SALE,
                NULL DEPRN_VAR,
                 DECODE(NVL((SELECT SUM (FR.PROCEEDS_OF_SALE)
                       FROM FA_RETIREMENTS FAR
                       WHERE FAR.book_type_code = :P_BOOK_TYPE_CODE
                       AND FAR.date_retired<= (SELECT (CALENDAR_PERIOD_CLOSE_DATE) 
											    FROM FA_DEPRN_PERIODS FDp5 
												where FDP5.book_type_code = :P_BOOK_TYPE_CODE  -- add to handle multiple books
												and period_name= :P_ACC_PERIOD)
                       AND FAR.asset_id = A.ASSET_ID
                       AND FAR.status = 'PROCESSED'),0),0,0,DECODE(SIGN(((NVL((SELECT SUM (FR.PROCEEDS_OF_SALE)
                       FROM FA_RETIREMENTS FAR
                       WHERE FAR.book_type_code = :P_BOOK_TYPE_CODE
                       AND FAR.date_retired<= (SELECT (CALENDAR_PERIOD_CLOSE_DATE) 
					                           FROM FA_DEPRN_PERIODS FDP6
											   where FDP6.book_type_code = :P_BOOK_TYPE_CODE  -- add to handle multiple books
											   and period_name= :P_ACC_PERIOD)
                       AND FAR.asset_id = A.ASSET_ID
                       AND FAR.status = 'PROCESSED'),0)*f.units_assigned)/FADD.current_units)-((NVL(a.original_cost, 0) * (f.units_assigned))/ FADD.current_units)),-

1,0,(((NVL((SELECT SUM (FR.PROCEEDS_OF_SALE)
                       FROM FA_RETIREMENTS FAR
                       WHERE FAR.book_type_code = :P_BOOK_TYPE_CODE
                       AND FAR.date_retired<= (SELECT (CALENDAR_PERIOD_CLOSE_DATE) 
					                           FROM FA_DEPRN_PERIODS FDP7
											   where FDP7.book_type_code = :P_BOOK_TYPE_CODE  -- add to handle multiple books
											   and period_name= :P_ACC_PERIOD)
                       AND FAR.asset_id = A.ASSET_ID
                       AND FAR.status = 'PROCESSED'),0)*f.units_assigned)/FADD.current_units)-((NVL(a.original_cost, 0) * (f.units_assigned))/ FADD.current_units))))


CAPTIAL_GAIN_OR_LOSS,

                fadd.attribute1 AR,
                FADD.ATTRIBUTE2 EQUIPMENT,
                FADD.ATTRIBUTE3 CCA_CLASS,
                TO_CHAR(FADD.ATTRIBUTE_DATE1,'MM/DD/YYYY') ESTIMATION_COMPLETION_DATE,
                FADD.ATTRIBUTE4 BUDGET_AMOUNT,
                FADD.ATTRIBUTE5 IDLE_ASSET_IDENTIFIER,
                FADD.ATTRIBUTE6 IDLE_ASSET_DESCRIPTION,
                TO_CHAR(FADD.ATTRIBUTE_DATE2,'MM/DD/YYYY') PHYSICAL_INVENTORY_DATE,
                to_char(FADD.ATTRIBUTE7) PROJECT_CATEGORY,
                TO_CHAR(FADD.ATTRIBUTE_DATE3,'MM/DD/YYYY') PAR_APPROVAL_DATE,
                FADD.ATTRIBUTE8 AMENDED_BUDGET_AMOUNT,
                '''' || FADD.ATTRIBUTE9 LEGACY_ASSET_NUMBER,
                FADD.ATTRIBUTE10 REGIONAL_INFORMATION,
                FADD.ATTRIBUTE11 BUILDING_A,
				
				(CASE WHEN FADD.ASSET_TYPE ='CIP' THEN
(select CC_ACC.SEGMENT2   
FROM   FA_CATEGORY_BOOKS CB,
	   GL_CODE_COMBINATIONS CC_ACC
WHERE  CB.book_type_code = a.book_type_code
AND    CB.category_id   = fadd.asset_category_id
AND    CB. WIP_COST_ACCOUNT_CCID = CC_ACC.code_combination_id) 
ELSE 
(select CC_ACC.SEGMENT2   
FROM   FA_CATEGORY_BOOKS CB,
	   GL_CODE_COMBINATIONS CC_ACC
WHERE  CB.book_type_code = a.book_type_code
AND    CB.category_id   = fadd.asset_category_id
AND    CB.ASSET_COST_ACCOUNT_CCID = CC_ACC.code_combination_id)
END) as FIRST_COST_ACC,	
				
				

(select CC_ACC1.SEGMENT2   
FROM   FA_CATEGORY_BOOKS CB1,
	   GL_CODE_COMBINATIONS CC_ACC1
WHERE  CB1.book_type_code = a.book_type_code
AND    CB1.category_id   = fadd.asset_category_id
AND    CB1. RESERVE_ACCOUNT_CCID = CC_ACC1.code_combination_id) ACC_DEP_ACC
                
                
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
                fa_retirements Fr
              --GL_DAILY_RATES GDR,
              --GL_DAILY_CONVERSION_TYPES GDCT 
          WHERE
                A.ASSET_ID = FADD.ASSET_ID
            AND FADD.ASSET_ID = FADDT.ASSET_ID
            AND fadd.asset_category_id = e.category_id
            AND A.ASSET_ID = S.ASSET_ID
            AND a.book_type_code = s.book_type_code
            AND a.book_type_code = e1.book_type_code
           AND a.book_type_code = f.book_type_code --REL060 GERITM27046260  Added
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
            AND FADD.ASSET_NUMBER=NVL(:P_ASSET_NUMBER,FADD.ASSET_NUMBER)
           -- AND G.SEGMENT1=NVL(:P_SEGMENT1,G.SEGMENT1)
            AND FADD.creation_date BETWEEN (SELECT MIN (period_open_date) 
			                                FROM FA_DEPRN_PERIODS WHERE book_type_code = :P_BOOK_TYPE_CODE)  
                                AND (SELECT NVL(period_close_date, SYSDATE) FROM FA_DEPRN_PERIODS WHERE period_name = :P_ACC_PERIOD
                                     AND book_type_code = :P_BOOK_TYPE_CODE) 
            AND (A.DATE_PLACED_IN_SERVICE) <= (SELECT calendar_period_close_date
                                FROM FA_DEPRN_PERIODS
                                WHERE period_name = :P_ACC_PERIOD
                                AND book_type_code = :P_BOOK_TYPE_CODE)
            AND A.BOOK_TYPE_CODE= :P_BOOK_TYPE_CODE
            AND FADD.ASSET_NUMBER = NVL(:P_ASSET_NUMBER,FADD.ASSET_NUMBER)
            AND G.SEGMENT1= nvl(:P_SEGMENT1,G.SEGMENT1)
          /*CHANGE TO ALLOW MULTIPLE SELECTION OF COMPANY CODE*/
		  /*AND ((G.SEGMENT1 IN(:P_SEGMENT1) AND :P_SEGMENT1 IS NOT NULL)
		         OR  (G.SEGMENT1=G.SEGMENT1 AND :P_SEGMENT1 IS NULL   ))
				 
			AND G.SEGMENT1 IN(SELECT NVL(:P_SEGMENT1,G.SEGMENT1) FROM DUAL)*/	 
		  
     ORDER BY FADD.ASSET_NUMBER