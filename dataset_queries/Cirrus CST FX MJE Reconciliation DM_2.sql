SELECT gp.period_name 
  FROM  gl_periods gp
 WHERE gp.start_date <= (SELECT MAX(start_date)
						   FROM gl_period_statuses gps
						  WHERE gps.closing_status NOT IN ('F','N')
                            AND gps.application_id = 200)
   AND gp.PERIOD_NAME NOT LIKE '%ADJ%'
   AND gp.PERIOD_SET_NAME = 'CCL CALENDAR' 
ORDER BY gp.start_date desc