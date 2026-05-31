select distinct  FISCAL_YEAR_NUMBER  from GL_FISCAL_DAY_V where trunc(REPORT_DATE) < trunc(sysdate) 
order by FISCAL_YEAR_NUMBER   desc