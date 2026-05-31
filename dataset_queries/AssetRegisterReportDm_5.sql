SELECT BOOKS.ASSET_ID ASSET_ID_BKS,
       BOOKS.BOOK_TYPE_CODE BOOK_TYPE_CODE_BKS,
       TO_CHAR (BOOKS.DATE_PLACED_IN_SERVICE, 'DD-MON-YYYY') DPIS,
       COT.PRORATE_CONVENTION_CODE PRORATE_CONVENTION,
       TO_CHAR (BOOKS.PRORATE_DATE, 'DD-MON-YYYY') PRORATE_DATE,
       TO_CHAR (BOOKS.DEPRN_START_DATE, 'DD-MON-YYYY') DEPRN_START_DATE,
       LU_DF.MEANING DEPRECIATE_FLAG,
       CEIL.CEILING_NAME CEILING_NAME1,
       PD2.PERIOD_NAME PERIOD_FULLY_RSVD,
       PD1.PERIOD_NAME PERIOD_RETIRED,
       METH.METHOD_CODE DEPRN_METHOD_CODE,
       TO_CHAR (
            TRUNC (METH.LIFE_IN_MONTHS / 12)
          + (MOD (METH.LIFE_IN_MONTHS, 12) / 100),
          '9999D00')
          LIFE_IN_MONTHS,
       (BOOKS.REDUCTION_RATE * 100) BASIC_RATE,
       (BOOKS.RATE_ADJUSTMENT_FACTOR * 100) ADJUSTED_RATE,
       BOOKS.PRODUCTION_CAPACITY PRODUCTION_CAPACITY,
       BOOKS.UNIT_OF_MEASURE UNIT_OF_MEASURE,
       BOOKS.ORIGINAL_COST ORIGINAL_COST3,
       BOOKS.COST COST1,
       BOOKS.ADJUSTED_COST ADJUSTED_COST1,
       BOOKS.adjusted_recoverable_cost RECOVERABLE_COST1,
       CEIL.CEILING_NAME CEILING_NAME,
       BOOKS.BONUS_RULE_ID BONUS_RULE,
       BOOKS.SALVAGE_VALUE SALVAGE_VALUE1,
       BOOKS.RATE_ADJUSTMENT_FACTOR RATE_ADJUSTMENT_FACTOR,
       CEIL.CEILING_TYPE CEILING_TYPE,
       BOOKS.ITC_BASIS ITC_BASIS1,
       BOOKS.ITC_AMOUNT ITC_AMOUNT1,
       DECODE (DP_DS.FISCAL_YEAR,
               BC.CURRENT_FISCAL_YEAR, DS.YTD_PRODUCTION,
               NULL)
          YTD_PRODUCTION,
       DS.LTD_PRODUCTION LTD_PRODUCTION,
       LU_LY.MEANING DEPRECIATE_LASTYEAR_FLAG,
       (ITC.BASIS_REDUCTION_RATE * 100) BASIS_REDUCTION_RATE,
       (ITC.ITC_AMOUNT_RATE * 100) ITC_AMOUNT_RATE,
       (ITC.BASIS_REDUCTION_RATE * BOOKS.ORIGINAL_COST) BASIS_REDUCTION1,
       DS.DEPRN_RESERVE DEPRN_RESERVE1,
       DECODE (DP_DS.FISCAL_YEAR, BC.CURRENT_FISCAL_YEAR, DS.YTD_DEPRN, 0)
          YTD_DEPRN1,
       (BOOKS.COST - DS.DEPRN_RESERVE - NVL (DS.IMPAIRMENT_RESERVE, 0))
          NET_BOOK_VALUE1,
       LU_DWA.MEANING DEPR_WHEN_ACQUIRED,
       (CAT.NUMBER_PER_FISCAL_YEAR - CAP.PERIOD_NUM + 1)
          LIFE_HELD_IN_1ST_YEAR,
       NVL (DS.REVAL_RESERVE, 0) REVAL_RESERVE,
       NVL (DS.IMPAIRMENT_RESERVE, 0) IMP_RESERVE,
       BOOKS.ALLOWED_DEPRN_LIMIT_AMOUNT DEPRN_LIMIT,
       PD3.PERIOD_NAME PERIOD_NAME,
       (SELECT GCC.SEGMENT2
          FROM GL_CODE_COMBINATIONS GCC,
               FA_TRANSACTION_HEADERS FTH,
               xla_ae_headers xlah,
               xla_ae_lines xlal,
               xla_distribution_links xdl,
               fa_adjustments fad
         WHERE     fth.asset_id = BOOKS.asset_id
               AND fth.book_type_code = BOOKS.book_type_code
               AND xlah.event_id = fth.event_id
               AND xlal.ae_header_id = xlah.ae_header_id
               AND XLAL.accounting_class_code = 'COST'
               AND gcc.code_combination_id = xlal.code_combination_id
               AND xdl.ae_header_id = xlah.ae_header_id
               AND xdl.ae_line_num = xlal.ae_line_num
               AND xdl.source_distribution_id_num_1 =
                      fad.transaction_header_id
               AND fad.transaction_header_id = FTH.transaction_header_id
               AND ROWNUM = 1)
          cost_account,
       (SELECT ffvv_acc.description
          FROM GL_CODE_COMBINATIONS GCC,
               FA_TRANSACTION_HEADERS FTH,
               xla_ae_headers xlah,
               xla_ae_lines xlal,
               xla_distribution_links xdl,
               fa_adjustments fad,
               fnd_vs_value_sets ffvs_acc,
               fnd_vs_values_vl ffvv_acc
         WHERE     fth.asset_id = BOOKS.asset_id
               AND fth.book_type_code = BOOKS.book_type_code
               AND xlah.event_id = fth.event_id
               AND xlal.ae_header_id = xlah.ae_header_id
               AND XLAL.accounting_class_code = 'COST'
               AND gcc.code_combination_id = xlal.code_combination_id
               AND xdl.ae_header_id = xlah.ae_header_id
               AND xdl.ae_line_num = xlal.ae_line_num
               AND xdl.source_distribution_id_num_1 =
                      fad.transaction_header_id
               AND fad.transaction_header_id = FTH.transaction_header_id
               AND ffvs_acc.value_set_code = 'CCL_ACCOUNTS'
               AND ffvs_acc.value_set_id = ffvv_acc.value_set_id
               AND ffvv_acc.attribute_category = 'CCL_ACCOUNTS'
               AND gcc.segment2 = ffvv_acc.VALUE
               AND ROWNUM = 1)
          cost_account_desc,
       (SELECT GCC.SEGMENT2
          FROM GL_CODE_COMBINATIONS GCC,
               fa_deprn_detail fdd,
               xla_ae_headers xlah,
               xla_ae_lines xlal,
               xla_distribution_links xdl
         WHERE     fdd.asset_id = BOOKS.asset_id
               AND xlal.ae_header_id = xlah.ae_header_id
               AND XLAL.accounting_class_code = 'DEPRECIATION_EXPENSE'
               AND gcc.code_combination_id = xlal.code_combination_id
               AND xdl.ae_header_id = xlah.ae_header_id
               AND xdl.ae_line_num = xlal.ae_line_num
               AND fdd.asset_id = xdl.source_distribution_id_num_1
               AND fdd.period_counter = xdl.source_distribution_id_num_2
               AND fdd.distribution_id = xdl.source_distribution_id_num_5
               AND fdd.book_type_code = BOOKS.book_type_code
               AND fdd.period_counter = PD3.period_counter
               AND ROWNUM = 1)
          expense_account,
       (SELECT GCC.SEGMENT2
          FROM GL_CODE_COMBINATIONS GCC,
               fa_deprn_detail fdd,
               xla_ae_headers xlah,
               xla_ae_lines xlal,
               xla_distribution_links xdl
         WHERE     fdd.asset_id = BOOKS.asset_id
               AND xlal.ae_header_id = xlah.ae_header_id
               AND XLAL.accounting_class_code = 'DEPRECIATION_RESERVE'
               AND gcc.code_combination_id = xlal.code_combination_id
               AND xdl.ae_header_id = xlah.ae_header_id
               AND xdl.ae_line_num = xlal.ae_line_num
               AND fdd.asset_id = xdl.source_distribution_id_num_1
               AND fdd.period_counter = xdl.source_distribution_id_num_2
               AND fdd.distribution_id = xdl.source_distribution_id_num_5
               AND fdd.book_type_code = BOOKS.book_type_code
               AND ROWNUM = 1)
          reserve_account,
       (SELECT DSP.DEPRN_RESERVE
          FROM FA_DEPRN_SUMMARY DSP
         WHERE     DSP.ASSET_ID = DS.ASSET_ID
               AND DSP.BOOK_TYPE_CODE = DS.BOOK_TYPE_CODE
               AND DSP.PERIOD_COUNTER = DS.PERIOD_COUNTER - 1)
          prior_reserve
  FROM &L_BOOKS BOOKS,
       FA_BOOK_CONTROLS BC,
       &L_DEPRN_PERIODS1 PD1,
       &L_DEPRN_PERIODS2 PD2,
       FA_CEILING_TYPES CEIL,
       &L_DEPRN_SUMMARY DS,
       &L_DEPRN_PERIODS3 DP_DS,
       FA_METHODS METH,
       FA_ITC_RATES ITC,
       FA_CONVENTION_TYPES COT,
       FA_CALENDAR_PERIODS CAP,
       FA_CALENDAR_TYPES CAT,
       FND_LOOKUP_VALUES_VL LU_DF,
       FND_LOOKUP_VALUES_VL LU_LY,
       FND_LOOKUP_VALUES_VL LU_DWA,
       FA_DEPRN_PERIODS PD3
 WHERE BOOKS.BOOK_TYPE_CODE = BC.BOOK_TYPE_CODE AND &L_SOB_BOOKS
       BOOKS.DATE_INEFFECTIVE IS NULL
AND    BC.BOOK_CLASS IN ('CORPORATE', 'TAX')
AND    BC.DISTRIBUTION_SOURCE_BOOK = :P_BOOK
AND    PD1.BOOK_TYPE_CODE(+) = BOOKS.BOOK_TYPE_CODE
AND    &L_SOB_DEPRN_PERIODS1
       PD2.BOOK_TYPE_CODE(+) = BOOKS.BOOK_TYPE_CODE
AND    &L_SOB_DEPRN_PERIODS2
       PD1.PERIOD_COUNTER(+) = NVL(BOOKS.PERIOD_COUNTER_FULLY_RETIRED,0)
AND    PD2.PERIOD_COUNTER(+) = NVL(BOOKS.PERIOD_COUNTER_FULLY_RESERVED,0)
AND    CEIL.CEILING_TYPE_ID(+) = BOOKS.CEILING_TYPE_ID
AND    DS.ASSET_ID = BOOKS.ASSET_ID
AND    DS.BOOK_TYPE_CODE = BOOKS.BOOK_TYPE_CODE
AND    &L_SOB_DEPRN_SUMMARY
       DS.PERIOD_COUNTER = (SELECT  /*+ no_unnest */ MAX(DS1.PERIOD_COUNTER)
                              FROM &L_DEPRN_SUMMARY DS1
                             WHERE DS1.ASSET_ID = DS.ASSET_ID
                               AND  &L_SOB_DEPRN_SUMMARY1
                                   DS1.BOOK_TYPE_CODE=
                                       DS.BOOK_TYPE_CODE)
AND   DP_DS.PERIOD_COUNTER = DECODE(BC.INITIAL_PERIOD_COUNTER, DS.PERIOD_COUNTER,
       DS.PERIOD_COUNTER + 1, DS.PERIOD_COUNTER)
AND    DP_DS.BOOK_TYPE_CODE = BOOKS.BOOK_TYPE_CODE
AND    &L_SOB_DEPRN_PERIODS3
     METH.METHOD_ID = BOOKS.METHOD_ID
AND    ITC.ITC_AMOUNT_ID(+) = BOOKS.ITC_AMOUNT_ID
AND    COT.CONVENTION_TYPE_ID = BOOKS.CONVENTION_TYPE_ID
AND    CAP.CALENDAR_TYPE  = BC.PRORATE_CALENDAR
AND    BOOKS.PRORATE_DATE BETWEEN
             CAP.START_DATE AND CAP.END_DATE
AND    CAP.CALENDAR_TYPE = CAT.CALENDAR_TYPE
AND    LU_DF.LOOKUP_CODE = BOOKS.DEPRECIATE_FLAG
AND    LU_DF.LOOKUP_TYPE = 'FA_YESNO'
AND    LU_LY.LOOKUP_CODE = METH.DEPRECIATE_LASTYEAR_FLAG
AND    LU_LY.LOOKUP_TYPE = 'FA_YESNO'
AND    LU_DWA.LOOKUP_CODE = COT.DEPR_WHEN_ACQUIRED_FLAG
AND    LU_DWA.LOOKUP_TYPE = 'FA_YESNO'
AND BOOKS.ASSET_ID=:ASSET_ID_MASTER
AND    PD3.BOOK_TYPE_CODE = BOOKS.BOOK_TYPE_CODE
AND    PD3.PERIOD_COUNTER = DS.PERIOD_COUNTER
ORDER BY
       BC.BOOK_CLASS,
       BOOKS.BOOK_TYPE_CODE