SELECT DISTINCT
       AD.ASSET_ID ASSET_ID_MASTER,
       AD.ASSET_NUMBER,
       AD2.DESCRIPTION,
       &d_category_segs D_CATEGORY_SEGS1,
       CAT.DESCRIPTION CATEGORY_DESC,
       &d_asset_key_segs D_ASSET_KEY,
       AD.MANUFACTURER_NAME,
       AD.TAG_NUMBER,
       AD.SERIAL_NUMBER,
       AD.MODEL_NUMBER,
       NVL(LOOKUPS_PT.MEANING, AD.PROPERTY_TYPE_CODE) PROPERTY_TYPE,
       LOOKUPS_12.MEANING PROPERTY_1245_1250,
       LOOKUPS_IU.MEANING IN_USE_FLAG,
       LOOKUPS_OL.MEANING OWNED_LEASED,
       LOOKUPS_NU.MEANING NEW_USED,
       LOOKUPS_INV.MEANING PHYSICAL_INV,
       NULL PARENT_ASSET_NUMBER,
       NULL PARENT_ASSET_DESC,
       LOOKUPS_AT.MEANING ASSET_TYPE,
       AD.CURRENT_UNITS,
       CAT.SEGMENT1 major_category,
       CAT.SEGMENT2 minor_category,
       CAT.SEGMENT3 sub_category,
       AK.SEGMENT1 future_asset_key,
       AD.attribute_category_code,
       DECODE (ad.context, 'GED', ad.attribute1, NULL)
          appropriation_request_no,
       DECODE (ad.context, 'GED', ad.attribute2, NULL)
          equipment_no,
       DECODE (ad.context, 'GED', ad.attribute9, NULL)
          legacy_asset_no,
       DECODE (ad.context, 'GED', TO_CHAR (ad.attribute_date1, 'DD-MON-YYYY'), NULL)
          estimated_in_service_date,
       DECODE (ad.context, 'GED', ad.attribute10, NULL)
          legacy_cost,
       DECODE (ad.context, 'GED', ad.attribute3, NULL)
          legacy_parent_asset_no,
       DECODE (ad.context, 'GED', ad.attribute4, NULL)
          legacy_inv_no,
       DECODE (ad.context, 'GED', ad.attribute5, NULL)
          legacy_project_no,
       DECODE (ad.context, 'GED', ad.attribute6, NULL)
          legacy_product_line,
       DECODE (ad.context, 'GED', ad.attribute_number1, NULL)
          Historical_FX_Rate
  FROM FA_ASSET_HISTORY AH,
       FA_BOOKS BK,
       FA_CATEGORIES_VL CAT,
       FA_ASSET_KEYWORDS AK,
       FND_LOOKUP_VALUES_VL LOOKUPS_AT,
       FND_LOOKUP_VALUES_VL LOOKUPS_NU,
       FND_LOOKUP_VALUES_VL LOOKUPS_OL,
       FND_LOOKUP_VALUES_VL LOOKUPS_IU,
       FND_LOOKUP_VALUES_VL LOOKUPS_PT,
       FND_LOOKUP_VALUES_VL LOOKUPS_12,
       FND_LOOKUP_VALUES_VL LOOKUPS_INV,
       FA_ADDITIONS_TL AD2,
       FA_ADDITIONS_B AD,
       GL_CODE_COMBINATIONS DHCC,
       FA_DISTRIBUTION_HISTORY DH
 WHERE     :P_START_ASSET IS NOT NULL
       AND :P_END_ASSET IS NOT NULL
       AND AD.ASSET_NUMBER BETWEEN :P_START_ASSET AND :P_END_ASSET
       AND DH.DATE_EFFECTIVE <= NVL (:PERIOD_PCD, SYSDATE)
       AND AD.ASSET_ID = AD2.ASSET_ID
       AND AD.PARENT_ASSET_ID IS NULL
       AND AD2.LANGUAGE = USERENV ('LANG')
       AND AH.ASSET_ID = AD.ASSET_ID
       AND AH.DATE_EFFECTIVE <= SYSDATE
       AND NVL (AH.DATE_INEFFECTIVE, SYSDATE + 1) > SYSDATE
       AND AH.CATEGORY_ID = CAT.CATEGORY_ID
       AND AH.BOOK_TYPE_CODE = :P_BOOK
       AND AD.ASSET_KEY_CCID = AK.CODE_COMBINATION_ID(+)
       AND BK.ASSET_ID = AD.ASSET_ID
       AND BK.BOOK_TYPE_CODE = :P_BOOK
       AND BK.DATE_INEFFECTIVE IS NULL
       AND AD.ASSET_TYPE = NVL (:P_ASSET_TYPE_CODE, AD.ASSET_TYPE)
       AND LOOKUPS_AT.LOOKUP_CODE = AD.ASSET_TYPE
       AND LOOKUPS_AT.LOOKUP_TYPE = 'FA_ASSET_TYPE'
       AND LOOKUPS_NU.LOOKUP_CODE = AD.NEW_USED
       AND LOOKUPS_NU.LOOKUP_TYPE = 'FA_NEWUSE'
       AND LOOKUPS_OL.LOOKUP_CODE = AD.OWNED_LEASED
       AND LOOKUPS_OL.LOOKUP_TYPE = 'FA_OWNLEASE'
       AND LOOKUPS_IU.LOOKUP_CODE = AD.IN_USE_FLAG
       AND LOOKUPS_IU.LOOKUP_TYPE = 'FA_YESNO'
       AND LOOKUPS_PT.LOOKUP_CODE(+) = AD.PROPERTY_TYPE_CODE
       AND LOOKUPS_PT.LOOKUP_TYPE(+) = 'PROPERTY TYPE'
       AND LOOKUPS_12.LOOKUP_CODE(+) = AD.PROPERTY_1245_1250_CODE
       AND LOOKUPS_12.LOOKUP_TYPE(+) = 'FA_1245_1250_PROPERTY'
       AND LOOKUPS_INV.LOOKUP_CODE(+) = AD.INVENTORIAL
       AND LOOKUPS_INV.LOOKUP_TYPE = 'FA_YESNO'
       AND &C_DYNAMIC_DHCC_WHERE
       AND DHCC.CODE_COMBINATION_ID = DH.CODE_COMBINATION_ID
       AND DH.BOOK_TYPE_CODE = BK.BOOK_TYPE_CODE
       AND DH.ASSET_ID = AD.ASSET_ID
UNION ALL
SELECT DISTINCT
       AD.ASSET_ID ASSET_ID_MASTER,
       AD.ASSET_NUMBER,
       AD2.DESCRIPTION,
       &d_category_segs D_CATEGORY_SEGS1,
       CAT.DESCRIPTION CATEGORY_DESC,
       &d_asset_key_segs D_ASSET_KEY,
       AD.MANUFACTURER_NAME,
       AD.TAG_NUMBER,
       AD.SERIAL_NUMBER,
       AD.MODEL_NUMBER,
       NVL(LOOKUPS_PT.MEANING, AD.PROPERTY_TYPE_CODE) PROPERTY_TYPE,
       LOOKUPS_12.MEANING PROPERTY_1245_1250,
       LOOKUPS_IU.MEANING IN_USE_FLAG,
       LOOKUPS_OL.MEANING OWNED_LEASED,
       LOOKUPS_NU.MEANING NEW_USED,
       LOOKUPS_INV.MEANING PHYSICAL_INV,
       NULL PARENT_ASSET_NUMBER,
       NULL PARENT_ASSET_DESC,
       LOOKUPS_AT.MEANING ASSET_TYPE,
       AD.CURRENT_UNITS,
       CAT.SEGMENT1 major_category,
       CAT.SEGMENT2 minor_category,
       CAT.SEGMENT3 sub_category,
       AK.SEGMENT1 future_asset_key,
       AD.attribute_category_code,
       DECODE (ad.context, 'GED', ad.attribute1, NULL)
          appropriation_request_no,
       DECODE (ad.context, 'GED', ad.attribute2, NULL)
          equipment_no,
       DECODE (ad.context, 'GED', ad.attribute9, NULL)
          legacy_asset_no,
       DECODE (ad.context, 'GED', TO_CHAR (ad.attribute_date1, 'DD-MON-YYYY'), NULL)
          estimated_in_service_date,
       DECODE (ad.context, 'GED', ad.attribute10, NULL)
          legacy_cost,
       DECODE (ad.context, 'GED', ad.attribute3, NULL)
          legacy_parent_asset_no,
       DECODE (ad.context, 'GED', ad.attribute4, NULL)
          legacy_inv_no,
       DECODE (ad.context, 'GED', ad.attribute5, NULL)
          legacy_project_no,
       DECODE (ad.context, 'GED', ad.attribute6, NULL)
          legacy_product_line,
       DECODE (ad.context, 'GED', ad.attribute_number1, NULL)
          Historical_FX_Rate
  FROM FA_ASSET_HISTORY AH,
       FA_BOOKS BK,
       FA_CATEGORIES_VL CAT,
       FA_ASSET_KEYWORDS AK,
       FND_LOOKUP_VALUES_VL LOOKUPS_AT,
       FND_LOOKUP_VALUES_VL LOOKUPS_NU,
       FND_LOOKUP_VALUES_VL LOOKUPS_OL,
       FND_LOOKUP_VALUES_VL LOOKUPS_IU,
       FND_LOOKUP_VALUES_VL LOOKUPS_PT,
       FND_LOOKUP_VALUES_VL LOOKUPS_12,
       FND_LOOKUP_VALUES_VL LOOKUPS_INV,
       FA_ADDITIONS_TL AD2,
       FA_ADDITIONS_B AD,
       GL_CODE_COMBINATIONS DHCC,
       FA_DISTRIBUTION_HISTORY DH
 WHERE     :P_START_ASSET IS NULL
       AND :P_END_ASSET IS NOT NULL
       AND AD.ASSET_NUMBER BETWEEN AD.ASSET_NUMBER AND :P_END_ASSET
       AND DH.DATE_EFFECTIVE <= NVL (:PERIOD_PCD, SYSDATE)
       AND AD.ASSET_ID = AD2.ASSET_ID
       AND AD.PARENT_ASSET_ID IS NULL
       AND AD2.LANGUAGE = USERENV ('LANG')
       AND AH.ASSET_ID = AD.ASSET_ID
       AND AH.DATE_EFFECTIVE <= SYSDATE
       AND NVL (AH.DATE_INEFFECTIVE, SYSDATE + 1) > SYSDATE
       AND AH.CATEGORY_ID = CAT.CATEGORY_ID
       AND AH.BOOK_TYPE_CODE = :P_BOOK
       AND AD.ASSET_KEY_CCID = AK.CODE_COMBINATION_ID(+)
       AND BK.ASSET_ID = AD.ASSET_ID
       AND BK.BOOK_TYPE_CODE = :P_BOOK
       AND BK.DATE_INEFFECTIVE IS NULL
       AND AD.ASSET_TYPE = NVL (:P_ASSET_TYPE_CODE, AD.ASSET_TYPE)
       AND LOOKUPS_AT.LOOKUP_CODE = AD.ASSET_TYPE
       AND LOOKUPS_AT.LOOKUP_TYPE = 'FA_ASSET_TYPE'
       AND LOOKUPS_NU.LOOKUP_CODE = AD.NEW_USED
       AND LOOKUPS_NU.LOOKUP_TYPE = 'FA_NEWUSE'
       AND LOOKUPS_OL.LOOKUP_CODE = AD.OWNED_LEASED
       AND LOOKUPS_OL.LOOKUP_TYPE = 'FA_OWNLEASE'
       AND LOOKUPS_IU.LOOKUP_CODE = AD.IN_USE_FLAG
       AND LOOKUPS_IU.LOOKUP_TYPE = 'FA_YESNO'
       AND LOOKUPS_PT.LOOKUP_CODE(+) = AD.PROPERTY_TYPE_CODE
       AND LOOKUPS_PT.LOOKUP_TYPE(+) = 'PROPERTY TYPE'
       AND LOOKUPS_12.LOOKUP_CODE(+) = AD.PROPERTY_1245_1250_CODE
       AND LOOKUPS_12.LOOKUP_TYPE(+) = 'FA_1245_1250_PROPERTY'
       AND LOOKUPS_INV.LOOKUP_CODE(+) = AD.INVENTORIAL
       AND LOOKUPS_INV.LOOKUP_TYPE = 'FA_YESNO'
       AND &C_DYNAMIC_DHCC_WHERE
       AND DHCC.CODE_COMBINATION_ID = DH.CODE_COMBINATION_ID
       AND DH.BOOK_TYPE_CODE = BK.BOOK_TYPE_CODE
       AND DH.ASSET_ID = AD.ASSET_ID
UNION ALL
SELECT DISTINCT
       AD.ASSET_ID ASSET_ID_MASTER,
       AD.ASSET_NUMBER,
       AD2.DESCRIPTION,
       &d_category_segs D_CATEGORY_SEGS1,
       CAT.DESCRIPTION CATEGORY_DESC,
       &d_asset_key_segs D_ASSET_KEY,
       AD.MANUFACTURER_NAME,
       AD.TAG_NUMBER,
       AD.SERIAL_NUMBER,
       AD.MODEL_NUMBER,
       NVL(LOOKUPS_PT.MEANING, AD.PROPERTY_TYPE_CODE) PROPERTY_TYPE,
       LOOKUPS_12.MEANING PROPERTY_1245_1250,
       LOOKUPS_IU.MEANING IN_USE_FLAG,
       LOOKUPS_OL.MEANING OWNED_LEASED,
       LOOKUPS_NU.MEANING NEW_USED,
       LOOKUPS_INV.MEANING PHYSICAL_INV,
       NULL PARENT_ASSET_NUMBER,
       NULL PARENT_ASSET_DESC,
       LOOKUPS_AT.MEANING ASSET_TYPE,
       AD.CURRENT_UNITS,
       CAT.SEGMENT1 major_category,
       CAT.SEGMENT2 minor_category,
       CAT.SEGMENT3 sub_category,
       AK.SEGMENT1 future_asset_key,
       AD.attribute_category_code,
       DECODE (ad.context, 'GED', ad.attribute1, NULL)
          appropriation_request_no,
       DECODE (ad.context, 'GED', ad.attribute2, NULL)
          equipment_no,
       DECODE (ad.context, 'GED', ad.attribute9, NULL)
          legacy_asset_no,
       DECODE (ad.context, 'GED', TO_CHAR (ad.attribute_date1, 'DD-MON-YYYY'), NULL)
          estimated_in_service_date,
       DECODE (ad.context, 'GED', ad.attribute10, NULL)
          legacy_cost,
       DECODE (ad.context, 'GED', ad.attribute3, NULL)
          legacy_parent_asset_no,
       DECODE (ad.context, 'GED', ad.attribute4, NULL)
          legacy_inv_no,
       DECODE (ad.context, 'GED', ad.attribute5, NULL)
          legacy_project_no,
       DECODE (ad.context, 'GED', ad.attribute6, NULL)
          legacy_product_line,
       DECODE (ad.context, 'GED', ad.attribute_number1, NULL)
          Historical_FX_Rate
  FROM FA_ASSET_HISTORY AH,
       FA_BOOKS BK,
       FA_CATEGORIES_VL CAT,
       FA_ASSET_KEYWORDS AK,
       FND_LOOKUP_VALUES_VL LOOKUPS_AT,
       FND_LOOKUP_VALUES_VL LOOKUPS_NU,
       FND_LOOKUP_VALUES_VL LOOKUPS_OL,
       FND_LOOKUP_VALUES_VL LOOKUPS_IU,
       FND_LOOKUP_VALUES_VL LOOKUPS_PT,
       FND_LOOKUP_VALUES_VL LOOKUPS_12,
       FND_LOOKUP_VALUES_VL LOOKUPS_INV,
       FA_ADDITIONS_TL AD2,
       FA_ADDITIONS_B AD,
       GL_CODE_COMBINATIONS DHCC,
       FA_DISTRIBUTION_HISTORY DH
 WHERE     :P_START_ASSET IS NOT NULL
       AND :P_END_ASSET IS NULL
       AND AD.ASSET_NUMBER BETWEEN :P_START_ASSET AND AD.ASSET_NUMBER
       AND DH.DATE_EFFECTIVE <= NVL (:PERIOD_PCD, SYSDATE)
       AND AD.ASSET_ID = AD2.ASSET_ID
       AND AD.PARENT_ASSET_ID IS NULL
       AND AD2.LANGUAGE = USERENV ('LANG')
       AND AH.ASSET_ID = AD.ASSET_ID
       AND AH.DATE_EFFECTIVE <= SYSDATE
       AND NVL (AH.DATE_INEFFECTIVE, SYSDATE + 1) > SYSDATE
       AND AH.CATEGORY_ID = CAT.CATEGORY_ID
       AND AH.BOOK_TYPE_CODE = :P_BOOK
       AND AD.ASSET_KEY_CCID = AK.CODE_COMBINATION_ID(+)
       AND BK.ASSET_ID = AD.ASSET_ID
       AND BK.BOOK_TYPE_CODE = :P_BOOK
       AND BK.DATE_INEFFECTIVE IS NULL
       AND AD.ASSET_TYPE = NVL (:P_ASSET_TYPE_CODE, AD.ASSET_TYPE)
       AND LOOKUPS_AT.LOOKUP_CODE = AD.ASSET_TYPE
       AND LOOKUPS_AT.LOOKUP_TYPE = 'FA_ASSET_TYPE'
       AND LOOKUPS_NU.LOOKUP_CODE = AD.NEW_USED
       AND LOOKUPS_NU.LOOKUP_TYPE = 'FA_NEWUSE'
       AND LOOKUPS_OL.LOOKUP_CODE = AD.OWNED_LEASED
       AND LOOKUPS_OL.LOOKUP_TYPE = 'FA_OWNLEASE'
       AND LOOKUPS_IU.LOOKUP_CODE = AD.IN_USE_FLAG
       AND LOOKUPS_IU.LOOKUP_TYPE = 'FA_YESNO'
       AND LOOKUPS_PT.LOOKUP_CODE(+) = AD.PROPERTY_TYPE_CODE
       AND LOOKUPS_PT.LOOKUP_TYPE(+) = 'PROPERTY TYPE'
       AND LOOKUPS_12.LOOKUP_CODE(+) = AD.PROPERTY_1245_1250_CODE
       AND LOOKUPS_12.LOOKUP_TYPE(+) = 'FA_1245_1250_PROPERTY'
       AND LOOKUPS_INV.LOOKUP_CODE(+) = AD.INVENTORIAL
       AND LOOKUPS_INV.LOOKUP_TYPE = 'FA_YESNO'
       AND &C_DYNAMIC_DHCC_WHERE
       AND DHCC.CODE_COMBINATION_ID = DH.CODE_COMBINATION_ID
       AND DH.BOOK_TYPE_CODE = BK.BOOK_TYPE_CODE
       AND DH.ASSET_ID = AD.ASSET_ID
UNION ALL
SELECT DISTINCT
       AD.ASSET_ID ASSET_ID_MASTER,
       AD.ASSET_NUMBER,
       AD2.DESCRIPTION,
       &d_category_segs D_CATEGORY_SEGS1,
       CAT.DESCRIPTION CATEGORY_DESC,
       &d_asset_key_segs D_ASSET_KEY,
       AD.MANUFACTURER_NAME,
       AD.TAG_NUMBER,
       AD.SERIAL_NUMBER,
       AD.MODEL_NUMBER,
       NVL(LOOKUPS_PT.MEANING, AD.PROPERTY_TYPE_CODE) PROPERTY_TYPE,
       LOOKUPS_12.MEANING PROPERTY_1245_1250,
       LOOKUPS_IU.MEANING IN_USE_FLAG,
       LOOKUPS_OL.MEANING OWNED_LEASED,
       LOOKUPS_NU.MEANING NEW_USED,
       LOOKUPS_INV.MEANING PHYSICAL_INV,
       NULL PARENT_ASSET_NUMBER,
       NULL PARENT_ASSET_DESC,
       LOOKUPS_AT.MEANING ASSET_TYPE,
       AD.CURRENT_UNITS,
       CAT.SEGMENT1 major_category,
       CAT.SEGMENT2 minor_category,
       CAT.SEGMENT3 sub_category,
       AK.SEGMENT1 future_asset_key,
       AD.attribute_category_code,
       DECODE (ad.context, 'GED', ad.attribute1, NULL)
          appropriation_request_no,
       DECODE (ad.context, 'GED', ad.attribute2, NULL)
          equipment_no,
       DECODE (ad.context, 'GED', ad.attribute9, NULL)
          legacy_asset_no,
       DECODE (ad.context, 'GED', TO_CHAR (ad.attribute_date1, 'DD-MON-YYYY'), NULL)
          estimated_in_service_date,
       DECODE (ad.context, 'GED', ad.attribute10, NULL)
          legacy_cost,
       DECODE (ad.context, 'GED', ad.attribute3, NULL)
          legacy_parent_asset_no,
       DECODE (ad.context, 'GED', ad.attribute4, NULL)
          legacy_inv_no,
       DECODE (ad.context, 'GED', ad.attribute5, NULL)
          legacy_project_no,
       DECODE (ad.context, 'GED', ad.attribute6, NULL)
          legacy_product_line,
       DECODE (ad.context, 'GED', ad.attribute_number1, NULL)
          Historical_FX_Rate
  FROM FA_ASSET_HISTORY AH,
       FA_BOOKS BK,
       FA_CATEGORIES_VL CAT,
       FA_ASSET_KEYWORDS AK,
       FND_LOOKUP_VALUES_VL LOOKUPS_AT,
       FND_LOOKUP_VALUES_VL LOOKUPS_NU,
       FND_LOOKUP_VALUES_VL LOOKUPS_OL,
       FND_LOOKUP_VALUES_VL LOOKUPS_IU,
       FND_LOOKUP_VALUES_VL LOOKUPS_PT,
       FND_LOOKUP_VALUES_VL LOOKUPS_12,
       FND_LOOKUP_VALUES_VL LOOKUPS_INV,
       FA_ADDITIONS_TL AD2,
       FA_ADDITIONS_B AD,
       GL_CODE_COMBINATIONS DHCC,
       FA_DISTRIBUTION_HISTORY DH
 WHERE     :P_START_ASSET IS NULL
       AND :P_END_ASSET IS NULL
       AND DH.DATE_EFFECTIVE <= NVL (:PERIOD_PCD, SYSDATE)
       AND AD.ASSET_ID = AD2.ASSET_ID
       AND AD2.LANGUAGE = USERENV ('LANG')
       AND AD.PARENT_ASSET_ID IS NULL
       AND AH.ASSET_ID = AD.ASSET_ID
       AND AH.DATE_EFFECTIVE <= SYSDATE
       AND NVL (AH.DATE_INEFFECTIVE, SYSDATE + 1) > SYSDATE
       AND AH.CATEGORY_ID = CAT.CATEGORY_ID
       AND AH.BOOK_TYPE_CODE = :P_BOOK
       AND AD.ASSET_KEY_CCID = AK.CODE_COMBINATION_ID(+)
       AND BK.ASSET_ID = AD.ASSET_ID
       AND BK.BOOK_TYPE_CODE = :P_BOOK
       AND BK.DATE_INEFFECTIVE IS NULL
       AND AD.ASSET_TYPE = NVL (:P_ASSET_TYPE_CODE, AD.ASSET_TYPE)
       AND LOOKUPS_AT.LOOKUP_CODE = AD.ASSET_TYPE
       AND LOOKUPS_AT.LOOKUP_TYPE = 'FA_ASSET_TYPE'
       AND LOOKUPS_NU.LOOKUP_CODE = AD.NEW_USED
       AND LOOKUPS_NU.LOOKUP_TYPE = 'FA_NEWUSE'
       AND LOOKUPS_OL.LOOKUP_CODE = AD.OWNED_LEASED
       AND LOOKUPS_OL.LOOKUP_TYPE = 'FA_OWNLEASE'
       AND LOOKUPS_IU.LOOKUP_CODE = AD.IN_USE_FLAG
       AND LOOKUPS_IU.LOOKUP_TYPE = 'FA_YESNO'
       AND LOOKUPS_PT.LOOKUP_CODE(+) = AD.PROPERTY_TYPE_CODE
       AND LOOKUPS_PT.LOOKUP_TYPE(+) = 'PROPERTY TYPE'
       AND LOOKUPS_12.LOOKUP_CODE(+) = AD.PROPERTY_1245_1250_CODE
       AND LOOKUPS_12.LOOKUP_TYPE(+) = 'FA_1245_1250_PROPERTY'
       AND LOOKUPS_INV.LOOKUP_CODE(+) = AD.INVENTORIAL
       AND LOOKUPS_INV.LOOKUP_TYPE = 'FA_YESNO'
       AND &C_DYNAMIC_DHCC_WHERE
       AND DHCC.CODE_COMBINATION_ID = DH.CODE_COMBINATION_ID
       AND DH.BOOK_TYPE_CODE = BK.BOOK_TYPE_CODE
       AND DH.ASSET_ID = AD.ASSET_ID
UNION ALL
SELECT DISTINCT
       AD.ASSET_ID ASSET_ID_MASTER,
       AD.ASSET_NUMBER,
       AD2.DESCRIPTION,
       &d_category_segs D_CATEGORY_SEGS1,
       CAT.DESCRIPTION CATEGORY_DESC,
       &d_asset_key_segs D_ASSET_KEY,
       AD.MANUFACTURER_NAME,
       AD.TAG_NUMBER,
       AD.SERIAL_NUMBER,
       AD.MODEL_NUMBER,
       NVL(LOOKUPS_PT.MEANING, AD.PROPERTY_TYPE_CODE) PROPERTY_TYPE,
       LOOKUPS_12.MEANING PROPERTY_1245_1250,
       LOOKUPS_IU.MEANING IN_USE_FLAG,
       LOOKUPS_OL.MEANING OWNED_LEASED,
       LOOKUPS_NU.MEANING NEW_USED,
       LOOKUPS_INV.MEANING PHYSICAL_INV,
       P_AD.ASSET_NUMBER PARENT_ASSET_NUMBER,
       P_AD2.DESCRIPTION PARENT_ASSET_DESC,
       LOOKUPS_AT.MEANING ASSET_TYPE,
       AD.CURRENT_UNITS,
       CAT.SEGMENT1 major_category,
       CAT.SEGMENT2 minor_category,
       CAT.SEGMENT3 sub_category,
       AK.SEGMENT1 future_asset_key,
       AD.attribute_category_code,
       DECODE (ad.context, 'GED', ad.attribute1, NULL)
          appropriation_request_no,
       DECODE (ad.context, 'GED', ad.attribute2, NULL)
          equipment_no,
       DECODE (ad.context, 'GED', ad.attribute9, NULL)
          legacy_asset_no,
       DECODE (ad.context, 'GED', TO_CHAR (ad.attribute_date1, 'DD-MON-YYYY'), NULL)
          estimated_in_service_date,
       DECODE (ad.context, 'GED', ad.attribute10, NULL)
          legacy_cost,
       DECODE (ad.context, 'GED', ad.attribute3, NULL)
          legacy_parent_asset_no,
       DECODE (ad.context, 'GED', ad.attribute4, NULL)
          legacy_inv_no,
       DECODE (ad.context, 'GED', ad.attribute5, NULL)
          legacy_project_no,
       DECODE (ad.context, 'GED', ad.attribute6, NULL)
          legacy_product_line,
       DECODE (ad.context, 'GED', ad.attribute_number1, NULL)
          Historical_FX_Rate
  FROM FA_ASSET_HISTORY AH,
       FA_BOOKS BK,
       FA_CATEGORIES_VL CAT,
       FA_ASSET_KEYWORDS AK,
       FND_LOOKUP_VALUES_VL LOOKUPS_AT,
       FND_LOOKUP_VALUES_VL LOOKUPS_NU,
       FND_LOOKUP_VALUES_VL LOOKUPS_OL,
       FND_LOOKUP_VALUES_VL LOOKUPS_IU,
       FND_LOOKUP_VALUES_VL LOOKUPS_PT,
       FND_LOOKUP_VALUES_VL LOOKUPS_12,
       FND_LOOKUP_VALUES_VL LOOKUPS_INV,
       FA_ADDITIONS_TL P_AD2,
       FA_ADDITIONS_B P_AD,
       FA_ADDITIONS_TL AD2,
       FA_ADDITIONS_B AD,
       GL_CODE_COMBINATIONS DHCC,
       FA_DISTRIBUTION_HISTORY DH
 WHERE     :P_START_ASSET IS NOT NULL
       AND :P_END_ASSET IS NOT NULL
       AND AD.ASSET_NUMBER BETWEEN :P_START_ASSET AND :P_END_ASSET
       AND DH.DATE_EFFECTIVE <= NVL (:PERIOD_PCD, SYSDATE)
       AND AD.ASSET_ID = AD2.ASSET_ID
       AND AD2.LANGUAGE = USERENV ('LANG')
       AND AD.PARENT_ASSET_ID = P_AD.ASSET_ID
       AND P_AD.ASSET_ID = P_AD2.ASSET_ID
       AND P_AD2.LANGUAGE = USERENV ('LANG')
       AND AH.ASSET_ID = AD.ASSET_ID
       AND AH.DATE_EFFECTIVE <= SYSDATE
       AND NVL (AH.DATE_INEFFECTIVE, SYSDATE + 1) > SYSDATE
       AND AH.CATEGORY_ID = CAT.CATEGORY_ID
       AND AH.BOOK_TYPE_CODE = :P_BOOK
       AND AD.ASSET_KEY_CCID = AK.CODE_COMBINATION_ID(+)
       AND BK.ASSET_ID = AD.ASSET_ID
       AND BK.BOOK_TYPE_CODE = :P_BOOK
       AND BK.DATE_INEFFECTIVE IS NULL
       AND AD.ASSET_TYPE = NVL (:P_ASSET_TYPE_CODE, AD.ASSET_TYPE)
       AND LOOKUPS_AT.LOOKUP_CODE = AD.ASSET_TYPE
       AND LOOKUPS_AT.LOOKUP_TYPE = 'FA_ASSET_TYPE'
       AND LOOKUPS_NU.LOOKUP_CODE = AD.NEW_USED
       AND LOOKUPS_NU.LOOKUP_TYPE = 'FA_NEWUSE'
       AND LOOKUPS_OL.LOOKUP_CODE = AD.OWNED_LEASED
       AND LOOKUPS_OL.LOOKUP_TYPE = 'FA_OWNLEASE'
       AND LOOKUPS_IU.LOOKUP_CODE = AD.IN_USE_FLAG
       AND LOOKUPS_IU.LOOKUP_TYPE = 'FA_YESNO'
       AND LOOKUPS_PT.LOOKUP_CODE(+) = AD.PROPERTY_TYPE_CODE
       AND LOOKUPS_PT.LOOKUP_TYPE(+) = 'PROPERTY TYPE'
       AND LOOKUPS_12.LOOKUP_CODE(+) = AD.PROPERTY_1245_1250_CODE
       AND LOOKUPS_12.LOOKUP_TYPE(+) = 'FA_1245_1250_PROPERTY'
       AND LOOKUPS_INV.LOOKUP_CODE(+) = AD.INVENTORIAL
       AND LOOKUPS_INV.LOOKUP_TYPE = 'FA_YESNO'
       AND &C_DYNAMIC_DHCC_WHERE
       AND DHCC.CODE_COMBINATION_ID = DH.CODE_COMBINATION_ID
       AND DH.BOOK_TYPE_CODE = BK.BOOK_TYPE_CODE
       AND DH.ASSET_ID = AD.ASSET_ID
UNION ALL
SELECT DISTINCT
       AD.ASSET_ID ASSET_ID_MASTER,
       AD.ASSET_NUMBER,
       AD2.DESCRIPTION,
       &d_category_segs D_CATEGORY_SEGS1,
       CAT.DESCRIPTION CATEGORY_DESC,
       &d_asset_key_segs D_ASSET_KEY,
       AD.MANUFACTURER_NAME,
       AD.TAG_NUMBER,
       AD.SERIAL_NUMBER,
       AD.MODEL_NUMBER,
       NVL(LOOKUPS_PT.MEANING, AD.PROPERTY_TYPE_CODE) PROPERTY_TYPE,
       LOOKUPS_12.MEANING PROPERTY_1245_1250,
       LOOKUPS_IU.MEANING IN_USE_FLAG,
       LOOKUPS_OL.MEANING OWNED_LEASED,
       LOOKUPS_NU.MEANING NEW_USED,
       LOOKUPS_INV.MEANING PHYSICAL_INV,
       P_AD.ASSET_NUMBER PARENT_ASSET_NUMBER,
       P_AD2.DESCRIPTION PARENT_ASSET_DESC,
       LOOKUPS_AT.MEANING ASSET_TYPE,
       AD.CURRENT_UNITS,
       CAT.SEGMENT1 major_category,
       CAT.SEGMENT2 minor_category,
       CAT.SEGMENT3 sub_category,
       AK.SEGMENT1 future_asset_key,
       AD.attribute_category_code,
       DECODE (ad.context, 'GED', ad.attribute1, NULL)
          appropriation_request_no,
       DECODE (ad.context, 'GED', ad.attribute2, NULL)
          equipment_no,
       DECODE (ad.context, 'GED', ad.attribute9, NULL)
          legacy_asset_no,
       DECODE (ad.context, 'GED', TO_CHAR (ad.attribute_date1, 'DD-MON-YYYY'), NULL)
          estimated_in_service_date,
       DECODE (ad.context, 'GED', ad.attribute10, NULL)
          legacy_cost,
       DECODE (ad.context, 'GED', ad.attribute3, NULL)
          legacy_parent_asset_no,
       DECODE (ad.context, 'GED', ad.attribute4, NULL)
          legacy_inv_no,
       DECODE (ad.context, 'GED', ad.attribute5, NULL)
          legacy_project_no,
       DECODE (ad.context, 'GED', ad.attribute6, NULL)
          legacy_product_line,
       DECODE (ad.context, 'GED', ad.attribute_number1, NULL)
          Historical_FX_Rate
  FROM FA_ASSET_HISTORY AH,
       FA_BOOKS BK,
       FA_CATEGORIES_VL CAT,
       FA_ASSET_KEYWORDS AK,
       FND_LOOKUP_VALUES_VL LOOKUPS_AT,
       FND_LOOKUP_VALUES_VL LOOKUPS_NU,
       FND_LOOKUP_VALUES_VL LOOKUPS_OL,
       FND_LOOKUP_VALUES_VL LOOKUPS_IU,
       FND_LOOKUP_VALUES_VL LOOKUPS_PT,
       FND_LOOKUP_VALUES_VL LOOKUPS_12,
       FND_LOOKUP_VALUES_VL LOOKUPS_INV,
       FA_ADDITIONS_TL P_AD2,
       FA_ADDITIONS_B P_AD,
       FA_ADDITIONS_TL AD2,
       FA_ADDITIONS_B AD,
       GL_CODE_COMBINATIONS DHCC,
       FA_DISTRIBUTION_HISTORY DH
 WHERE     :P_START_ASSET IS NULL
       AND :P_END_ASSET IS NOT NULL
       AND AD.ASSET_NUMBER BETWEEN AD.ASSET_NUMBER AND :P_END_ASSET
       AND DH.DATE_EFFECTIVE <= NVL (:PERIOD_PCD, SYSDATE)
       AND AD.ASSET_ID = AD2.ASSET_ID
       AND AD2.LANGUAGE = USERENV ('LANG')
       AND AD.PARENT_ASSET_ID = P_AD.ASSET_ID
       AND P_AD.ASSET_ID = P_AD2.ASSET_ID
       AND P_AD2.LANGUAGE = USERENV ('LANG')
       AND AH.ASSET_ID = AD.ASSET_ID
       AND AH.DATE_EFFECTIVE <= SYSDATE
       AND NVL (AH.DATE_INEFFECTIVE, SYSDATE + 1) > SYSDATE
       AND AH.CATEGORY_ID = CAT.CATEGORY_ID
       AND AH.BOOK_TYPE_CODE = :P_BOOK
       AND AD.ASSET_KEY_CCID = AK.CODE_COMBINATION_ID(+)
       AND BK.ASSET_ID = AD.ASSET_ID
       AND BK.BOOK_TYPE_CODE = :P_BOOK
       AND BK.DATE_INEFFECTIVE IS NULL
       AND AD.ASSET_TYPE = NVL (:P_ASSET_TYPE_CODE, AD.ASSET_TYPE)
       AND LOOKUPS_AT.LOOKUP_CODE = AD.ASSET_TYPE
       AND LOOKUPS_AT.LOOKUP_TYPE = 'FA_ASSET_TYPE'
       AND LOOKUPS_NU.LOOKUP_CODE = AD.NEW_USED
       AND LOOKUPS_NU.LOOKUP_TYPE = 'FA_NEWUSE'
       AND LOOKUPS_OL.LOOKUP_CODE = AD.OWNED_LEASED
       AND LOOKUPS_OL.LOOKUP_TYPE = 'FA_OWNLEASE'
       AND LOOKUPS_IU.LOOKUP_CODE = AD.IN_USE_FLAG
       AND LOOKUPS_IU.LOOKUP_TYPE = 'FA_YESNO'
       AND LOOKUPS_PT.LOOKUP_CODE(+) = AD.PROPERTY_TYPE_CODE
       AND LOOKUPS_PT.LOOKUP_TYPE(+) = 'PROPERTY TYPE'
       AND LOOKUPS_12.LOOKUP_CODE(+) = AD.PROPERTY_1245_1250_CODE
       AND LOOKUPS_12.LOOKUP_TYPE(+) = 'FA_1245_1250_PROPERTY'
       AND LOOKUPS_INV.LOOKUP_CODE(+) = AD.INVENTORIAL
       AND LOOKUPS_INV.LOOKUP_TYPE = 'FA_YESNO'
       AND &C_DYNAMIC_DHCC_WHERE
       AND DHCC.CODE_COMBINATION_ID = DH.CODE_COMBINATION_ID
       AND DH.BOOK_TYPE_CODE = BK.BOOK_TYPE_CODE
       AND DH.ASSET_ID = AD.ASSET_ID
UNION ALL
SELECT DISTINCT
       AD.ASSET_ID ASSET_ID_MASTER,
       AD.ASSET_NUMBER,
       AD2.DESCRIPTION,
       &d_category_segs D_CATEGORY_SEGS1,
       CAT.DESCRIPTION CATEGORY_DESC,
       &d_asset_key_segs D_ASSET_KEY,
       AD.MANUFACTURER_NAME,
       AD.TAG_NUMBER,
       AD.SERIAL_NUMBER,
       AD.MODEL_NUMBER,
       NVL(LOOKUPS_PT.MEANING, AD.PROPERTY_TYPE_CODE) PROPERTY_TYPE,
       LOOKUPS_12.MEANING PROPERTY_1245_1250,
       LOOKUPS_IU.MEANING IN_USE_FLAG,
       LOOKUPS_OL.MEANING OWNED_LEASED,
       LOOKUPS_NU.MEANING NEW_USED,
       LOOKUPS_INV.MEANING PHYSICAL_INV,
       P_AD.ASSET_NUMBER PARENT_ASSET_NUMBER,
       P_AD2.DESCRIPTION PARENT_ASSET_DESC,
       LOOKUPS_AT.MEANING ASSET_TYPE,
       AD.CURRENT_UNITS,
       CAT.SEGMENT1 major_category,
       CAT.SEGMENT2 minor_category,
       CAT.SEGMENT3 sub_category,
       AK.SEGMENT1 future_asset_key,
       AD.attribute_category_code,
       DECODE (ad.context, 'GED', ad.attribute1, NULL)
          appropriation_request_no,
       DECODE (ad.context, 'GED', ad.attribute2, NULL)
          equipment_no,
       DECODE (ad.context, 'GED', ad.attribute9, NULL)
          legacy_asset_no,
       DECODE (ad.context, 'GED', TO_CHAR (ad.attribute_date1, 'DD-MON-YYYY'), NULL)
          estimated_in_service_date,
       DECODE (ad.context, 'GED', ad.attribute10, NULL)
          legacy_cost,
       DECODE (ad.context, 'GED', ad.attribute3, NULL)
          legacy_parent_asset_no,
       DECODE (ad.context, 'GED', ad.attribute4, NULL)
          legacy_inv_no,
       DECODE (ad.context, 'GED', ad.attribute5, NULL)
          legacy_project_no,
       DECODE (ad.context, 'GED', ad.attribute6, NULL)
          legacy_product_line,
       DECODE (ad.context, 'GED', ad.attribute_number1, NULL)
          Historical_FX_Rate
  FROM FA_ASSET_HISTORY AH,
       FA_BOOKS BK,
       FA_CATEGORIES_VL CAT,
       FA_ASSET_KEYWORDS AK,
       FND_LOOKUP_VALUES_VL LOOKUPS_AT,
       FND_LOOKUP_VALUES_VL LOOKUPS_NU,
       FND_LOOKUP_VALUES_VL LOOKUPS_OL,
       FND_LOOKUP_VALUES_VL LOOKUPS_IU,
       FND_LOOKUP_VALUES_VL LOOKUPS_PT,
       FND_LOOKUP_VALUES_VL LOOKUPS_12,
       FND_LOOKUP_VALUES_VL LOOKUPS_INV,
       FA_ADDITIONS_TL P_AD2,
       FA_ADDITIONS_B P_AD,
       FA_ADDITIONS_TL AD2,
       FA_ADDITIONS_B AD,
       GL_CODE_COMBINATIONS DHCC,
       FA_DISTRIBUTION_HISTORY DH
 WHERE     :P_START_ASSET IS NOT NULL
       AND :P_END_ASSET IS NULL
       AND AD.ASSET_NUMBER BETWEEN :P_START_ASSET AND AD.ASSET_NUMBER
       AND DH.DATE_EFFECTIVE <= NVL (:PERIOD_PCD, SYSDATE)
       AND AD.ASSET_ID = AD2.ASSET_ID
       AND AD2.LANGUAGE = USERENV ('LANG')
       AND AD.PARENT_ASSET_ID = P_AD.ASSET_ID
       AND P_AD.ASSET_ID = P_AD2.ASSET_ID
       AND P_AD2.LANGUAGE = USERENV ('LANG')
       AND AH.ASSET_ID = AD.ASSET_ID
       AND AH.DATE_EFFECTIVE <= SYSDATE
       AND NVL (AH.DATE_INEFFECTIVE, SYSDATE + 1) > SYSDATE
       AND AH.CATEGORY_ID = CAT.CATEGORY_ID
       AND AH.BOOK_TYPE_CODE = :P_BOOK
       AND AD.ASSET_KEY_CCID = AK.CODE_COMBINATION_ID(+)
       AND BK.ASSET_ID = AD.ASSET_ID
       AND BK.BOOK_TYPE_CODE = :P_BOOK
       AND BK.DATE_INEFFECTIVE IS NULL
       AND AD.ASSET_TYPE = NVL (:P_ASSET_TYPE_CODE, AD.ASSET_TYPE)
       AND LOOKUPS_AT.LOOKUP_CODE = AD.ASSET_TYPE
       AND LOOKUPS_AT.LOOKUP_TYPE = 'FA_ASSET_TYPE'
       AND LOOKUPS_NU.LOOKUP_CODE = AD.NEW_USED
       AND LOOKUPS_NU.LOOKUP_TYPE = 'FA_NEWUSE'
       AND LOOKUPS_OL.LOOKUP_CODE = AD.OWNED_LEASED
       AND LOOKUPS_OL.LOOKUP_TYPE = 'FA_OWNLEASE'
       AND LOOKUPS_IU.LOOKUP_CODE = AD.IN_USE_FLAG
       AND LOOKUPS_IU.LOOKUP_TYPE = 'FA_YESNO'
       AND LOOKUPS_PT.LOOKUP_CODE(+) = AD.PROPERTY_TYPE_CODE
       AND LOOKUPS_PT.LOOKUP_TYPE(+) = 'PROPERTY TYPE'
       AND LOOKUPS_12.LOOKUP_CODE(+) = AD.PROPERTY_1245_1250_CODE
       AND LOOKUPS_12.LOOKUP_TYPE(+) = 'FA_1245_1250_PROPERTY'
       AND LOOKUPS_INV.LOOKUP_CODE(+) = AD.INVENTORIAL
       AND LOOKUPS_INV.LOOKUP_TYPE = 'FA_YESNO'
       AND &C_DYNAMIC_DHCC_WHERE
       AND DHCC.CODE_COMBINATION_ID = DH.CODE_COMBINATION_ID
       AND DH.BOOK_TYPE_CODE = BK.BOOK_TYPE_CODE
       AND DH.ASSET_ID = AD.ASSET_ID
UNION ALL
SELECT DISTINCT
       AD.ASSET_ID ASSET_ID_MASTER,
       AD.ASSET_NUMBER,
       AD2.DESCRIPTION,
       &d_category_segs D_CATEGORY_SEGS1,
       CAT.DESCRIPTION CATEGORY_DESC,
       &d_asset_key_segs D_ASSET_KEY,
       AD.MANUFACTURER_NAME,
       AD.TAG_NUMBER,
       AD.SERIAL_NUMBER,
       AD.MODEL_NUMBER,
       NVL(LOOKUPS_PT.MEANING, AD.PROPERTY_TYPE_CODE) PROPERTY_TYPE,
       LOOKUPS_12.MEANING PROPERTY_1245_1250,
       LOOKUPS_IU.MEANING IN_USE_FLAG,
       LOOKUPS_OL.MEANING OWNED_LEASED,
       LOOKUPS_NU.MEANING NEW_USED,
       LOOKUPS_INV.MEANING PHYSICAL_INV,
       P_AD.ASSET_NUMBER PARENT_ASSET_NUMBER,
       P_AD2.DESCRIPTION PARENT_ASSET_DESC,
       LOOKUPS_AT.MEANING ASSET_TYPE,
       AD.CURRENT_UNITS,
       CAT.SEGMENT1 major_category,
       CAT.SEGMENT2 minor_category,
       CAT.SEGMENT3 sub_category,
       AK.SEGMENT1 future_asset_key,
       AD.attribute_category_code,
       DECODE (ad.context, 'GED', ad.attribute1, NULL)
          appropriation_request_no,
       DECODE (ad.context, 'GED', ad.attribute2, NULL)
          equipment_no,
       DECODE (ad.context, 'GED', ad.attribute9, NULL)
          legacy_asset_no,
       DECODE (ad.context, 'GED', TO_CHAR (ad.attribute_date1, 'DD-MON-YYYY'), NULL)
          estimated_in_service_date,
       DECODE (ad.context, 'GED', ad.attribute10, NULL)
          legacy_cost,
       DECODE (ad.context, 'GED', ad.attribute3, NULL)
          legacy_parent_asset_no,
       DECODE (ad.context, 'GED', ad.attribute4, NULL)
          legacy_inv_no,
       DECODE (ad.context, 'GED', ad.attribute5, NULL)
          legacy_project_no,
       DECODE (ad.context, 'GED', ad.attribute6, NULL)
          legacy_product_line,
       DECODE (ad.context, 'GED', ad.attribute_number1, NULL)
          Historical_FX_Rate
  FROM FA_ASSET_HISTORY AH,
       FA_BOOKS BK,
       FA_CATEGORIES_VL CAT,
       FA_ASSET_KEYWORDS AK,
       FND_LOOKUP_VALUES_VL LOOKUPS_AT,
       FND_LOOKUP_VALUES_VL LOOKUPS_NU,
       FND_LOOKUP_VALUES_VL LOOKUPS_OL,
       FND_LOOKUP_VALUES_VL LOOKUPS_IU,
       FND_LOOKUP_VALUES_VL LOOKUPS_PT,
       FND_LOOKUP_VALUES_VL LOOKUPS_12,
       FND_LOOKUP_VALUES_VL LOOKUPS_INV,
       FA_ADDITIONS_TL P_AD2,
       FA_ADDITIONS_B P_AD,
       FA_ADDITIONS_TL AD2,
       FA_ADDITIONS_B AD,
       GL_CODE_COMBINATIONS DHCC,
       FA_DISTRIBUTION_HISTORY DH
 WHERE     :P_START_ASSET IS NULL
       AND :P_END_ASSET IS NULL
       AND DH.DATE_EFFECTIVE <= NVL (:PERIOD_PCD, SYSDATE)
       AND AD.ASSET_ID = AD2.ASSET_ID
       AND AD2.LANGUAGE = USERENV ('LANG')
       AND AD.PARENT_ASSET_ID = P_AD.ASSET_ID
       AND P_AD.ASSET_ID = P_AD2.ASSET_ID
       AND P_AD2.LANGUAGE = USERENV ('LANG')
       AND AH.ASSET_ID = AD.ASSET_ID
       AND AH.DATE_EFFECTIVE <= SYSDATE
       AND NVL (AH.DATE_INEFFECTIVE, SYSDATE + 1) > SYSDATE
       AND AH.CATEGORY_ID = CAT.CATEGORY_ID
       AND AH.BOOK_TYPE_CODE = :P_BOOK
       AND AD.ASSET_KEY_CCID = AK.CODE_COMBINATION_ID(+)
       AND BK.ASSET_ID = AD.ASSET_ID
       AND BK.BOOK_TYPE_CODE = :P_BOOK
       AND BK.DATE_INEFFECTIVE IS NULL
       AND AD.ASSET_TYPE = NVL (:P_ASSET_TYPE_CODE, AD.ASSET_TYPE)
       AND LOOKUPS_AT.LOOKUP_CODE = AD.ASSET_TYPE
       AND LOOKUPS_AT.LOOKUP_TYPE = 'FA_ASSET_TYPE'
       AND LOOKUPS_NU.LOOKUP_CODE = AD.NEW_USED
       AND LOOKUPS_NU.LOOKUP_TYPE = 'FA_NEWUSE'
       AND LOOKUPS_OL.LOOKUP_CODE = AD.OWNED_LEASED
       AND LOOKUPS_OL.LOOKUP_TYPE = 'FA_OWNLEASE'
       AND LOOKUPS_IU.LOOKUP_CODE = AD.IN_USE_FLAG
       AND LOOKUPS_IU.LOOKUP_TYPE = 'FA_YESNO'
       AND LOOKUPS_PT.LOOKUP_CODE(+) = AD.PROPERTY_TYPE_CODE
       AND LOOKUPS_PT.LOOKUP_TYPE(+) = 'PROPERTY TYPE'
       AND LOOKUPS_12.LOOKUP_CODE(+) = AD.PROPERTY_1245_1250_CODE
       AND LOOKUPS_12.LOOKUP_TYPE(+) = 'FA_1245_1250_PROPERTY'
       AND LOOKUPS_INV.LOOKUP_CODE(+) = AD.INVENTORIAL
       AND LOOKUPS_INV.LOOKUP_TYPE = 'FA_YESNO'
       AND &C_DYNAMIC_DHCC_WHERE
       AND DHCC.CODE_COMBINATION_ID = DH.CODE_COMBINATION_ID
       AND DH.BOOK_TYPE_CODE = BK.BOOK_TYPE_CODE
       AND DH.ASSET_ID = AD.ASSET_ID
ORDER BY 2