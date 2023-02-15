SELECT	
	cqd.cqd_auto_key,
	cqs.STATUS_TYPE,
	CASE
		WHEN sod.QTY_INVOICED > 0 THEN 1
		ELSE 0
	END is_sold,
	CASE
		WHEN TRIM(UPPER(sdf_cqh_010)) = 'HIGH' THEN 1
    	ELSE 0
	END AS "LIKELIHOOD_IS_HIGH",
	CASE
		WHEN cmp.CV_UDF_003 = 'T' THEN 1
		ELSE 0
	END as "OEM",
	CASE
		WHEN cmp.CV_UDF_004 = 'T' THEN 1
		ELSE 0
	END as "Operator",
	CASE
		WHEN cmp.CV_UDF_005 = 'T' THEN 1
		ELSE 0
	END as "MRO",
	CASE
		WHEN cmp.CV_UDF_003 = 'T' THEN 0
		WHEN cmp.CV_UDF_004 = 'T' THEN 0
		WHEN cmp.CV_UDF_005 = 'T' THEN 0
		ELSE 1
	END as "Broker",
	CASE WHEN pcc_cqd.CONDITION_CODE IN('NE','NS','FN') THEN 1
	ELSE 0
END AS "NE",
CASE
	WHEN pcc_cqd.CONDITION_CODE = 'CAL' THEN 1
	WHEN pcc_cqd.CONDITION_CODE = 'CI' THEN 1
	WHEN pcc_cqd.CONDITION_CODE = 'BT' THEN 1
	WHEN pcc_cqd.CONDITION_CODE = 'INSP' THEN 1
	WHEN pcc_cqd.CONDITION_CODE = 'INSP/TEST' THEN 1
	WHEN pcc_cqd.CONDITION_CODE = 'MOD' THEN 1
	WHEN pcc_cqd.CONDITION_CODE = 'SV' THEN 1
	WHEN pcc_cqd.CONDITION_CODE = 'REPAIRED' THEN 1
	WHEN pcc_cqd.CONDITION_CODE = 'MO' THEN 1
	WHEN pcc_cqd.CONDITION_CODE = 'EX' THEN 1
	ELSE 0
END AS "SV",
CASE
	WHEN pcc_cqd.CONDITION_CODE = 'OH' THEN 1
	ELSE 0
END AS "OH",
CASE
	WHEN pcc_cqd.CONDITION_CODE = 'AR' THEN 1
	WHEN pcc_cqd.CONDITION_CODE = 'AI' THEN 1
	WHEN pcc_cqd.CONDITION_CODE = 'RP' THEN 1
	WHEN pcc_cqd.CONDITION_CODE = 'D' THEN 1
	WHEN pcc_cqd.CONDITION_CODE = 'BER' THEN 1
	WHEN pcc_cqd.CONDITION_CODE = 'NR' THEN 1
	WHEN pcc_cqd.CONDITION_CODE = 'SC' THEN 1
	WHEN pcc_cqd.CONDITION_CODE = '_' THEN 1
	WHEN pcc_cqd.CONDITION_CODE = ' ' THEN 1
	WHEN pcc_cqd.CONDITION_CODE = 'NQ' THEN 1
	ELSE 0
END AS "AR",
	CASE
		WHEN cqd.STM_AUTO_KEY IS NOT NULL THEN 1
		ELSE 0
	END is_quoted_from_stock,
	CASE
		WHEN pcc_stm.condition_code IN('BT', 'INSP', 'INSP/TEST', 'MOD', 'SV', 'REPAIRED', 'OH', 'NS', 'NE', 'FN')
		AND cqd.stm_auto_key IS NOT NULL THEN 1
		ELSE 0
	END is_ready_from_stock,
	CASE WHEN (SELECT count(*)
	FROM cla_prod.quantum_prod_qctl.SO_DETAIL SOD
	LEFT JOIN cla_prod.quantum_prod_qctl.SO_HEADER SOH ON SOH.SOH_AUTO_KEY = SOD.SOH_AUTO_KEY
	WHERE SOH.ENTRY_DATE < CQD.ENTRY_DATE
	AND SOH.ENTRY_DATE >= to_date(CQD.ENTRY_DATE) - 365
	AND SOD.PNM_AUTO_KEY = CQD.PNM_AUTO_KEY
	AND SOH.CMP_AUTO_KEY = CQH.CMP_AUTO_KEY) > 0 THEN 1 ELSE 0 END WAS_SOLD_WITHIN_YEAR,
	CASE WHEN (SELECT count(*)
	FROM cla_prod.quantum_prod_qctl.SO_DETAIL SOD
	LEFT JOIN cla_prod.quantum_prod_qctl.SO_HEADER SOH ON SOH.SOH_AUTO_KEY = SOD.SOH_AUTO_KEY
	WHERE SOH.ENTRY_DATE < CQD.ENTRY_DATE
	AND SOH.ENTRY_DATE >= to_date(CQD.ENTRY_DATE) - 365 * 2
	AND SOD.PNM_AUTO_KEY = CQD.PNM_AUTO_KEY
	AND SOH.CMP_AUTO_KEY = CQH.CMP_AUTO_KEY) > 0 THEN 1 ELSE 0 END WAS_SOLD_WITHIN_2_YEAR,
	CASE WHEN (SELECT count(*)
	FROM cla_prod.quantum_prod_qctl.SO_DETAIL SOD
	LEFT JOIN cla_prod.quantum_prod_qctl.SO_HEADER SOH ON SOH.SOH_AUTO_KEY = SOD.SOH_AUTO_KEY
	WHERE SOH.ENTRY_DATE < CQD.ENTRY_DATE
	AND SOH.ENTRY_DATE >= to_date(CQD.ENTRY_DATE) - 365 * 5
	AND SOD.PNM_AUTO_KEY = CQD.PNM_AUTO_KEY
	AND SOH.CMP_AUTO_KEY = CQH.CMP_AUTO_KEY) > 0 THEN 1 ELSE 0 END WAS_SOLD_WITHIN_5_YEAR,
	CASE
		WHEN whs.WAREHOUSE_CODE
 IN ('APL-INV', 'CAP-FLL', 'CAP-PRE-FLL', 'CAP-PRE-TUC', 'CASC-INV',
      'CATHAY-FLL', 'CATHAY-TUC', 'COP', 'COP-1',
      'COP-PM3', 'CRG ', 'CRG-FLL', 'CRG-SE-FLL', 'CROSSIRON',
      'EASTERN AIRLINE', 'FHP-FLL', 'FLL', 'FLL-CE', 'FLL-EXPOOL.',
      'FLL-GATES', 'FLL-GATES-HOLD', 'FLL-HAZ', 'FLL-I/R',
      'FLL-IR RLS', 'FLL-QEC', 'GAT-CONS', 'GATES-FLL', 'HOLD', 'HOLD-INV',
      'INV-BLOCK', 'ONTIC', 'QUAR', 'TD-HOLD-FLL') THEN 
      CASE
			WHEN cmp.site_code IN ('NA', 'LA') THEN 1
			ELSE 0
		END
		WHEN whs.WAREHOUSE_CODE
  IN ('CAP-PRE-UK', 'CAP-UK', 'CATHAY-UK',
      'COP-UK', 'FHP-UK', 'GATES', 'GATES-BONDED',
      'GATES-QEC-PROGR', 'GATES-RLS', 'GATES-UK', 'GATES-VIRTUAL',
      'QATAR-INV', 'SCRAP-WHS-UK', 'TD-INPS-UK',
      'TD-INSP-UK', 'UK', 'UK-CW', 'UK-EXPOOL', 'UK-GATES', 'UK-HOLD',
      'UK-I/R', 'UK-IR RLS') THEN
      CASE
			WHEN cmp.site_code IN ('UK', 'IST') THEN 1
			ELSE 0
		END
		ELSE 0
	END is_same_location
--------------------------------------------------------
-- TABLE SOURCES ---------------------------------------
--------------------------------------------------------
FROM cla_prod.quantum_prod_qctl.CQ_DETAIL cqd
LEFT JOIN cla_prod.quantum_prod_qctl.CQ_HEADER cqh ON
	cqh.CQH_AUTO_KEY = cqd.CQH_AUTO_KEY
LEFT JOIN cla_prod.quantum_prod_qctl.COMPANIES cmp ON
	cmp.CMP_AUTO_KEY = cqh.CMP_AUTO_KEY
LEFT JOIN cla_prod.quantum_prod_qctl.PART_CONDITION_CODES pcc_cqd ON
	PCC_CQD.pcc_auto_key = cqd.PCC_AUTO_KEY
LEFT JOIN (
	SELECT
		sum(qty_invoiced) qty_invoiced,
		cqd_auto_key
	FROM
		cla_prod.quantum_prod_qctl.SO_DETAIL
	GROUP BY
		cqd_auto_key) sod ON
	sod.CQD_AUTO_KEY = cqd.CQD_AUTO_KEY
LEFT JOIN cla_prod.quantum_prod_qctl.SYS_USERS sysur ON
	sysur.SYSUR_AUTO_KEY = cqh.SYSUR_AUTO_KEY
LEFT JOIN cla_prod.quantum_prod_qctl.DELIVERY_CODES dvc ON
	dvc.DVC_AUTO_KEY = cqd.DVC_AUTO_KEY
LEFT JOIN cla_prod.quantum_prod_qctl.PARTS_MASTER pm ON
	pm.PNM_AUTO_KEY = cqd.PNM_AUTO_KEY
LEFT JOIN cla_prod.quantum_prod_qctl.stock stm ON
	stm.STM_AUTO_KEY = cqd.STM_AUTO_KEY
LEFT JOIN cla_prod.quantum_prod_qctl.PART_CONDITION_CODES pcc_stm ON
	pcc_stm.pcc_auto_key = stm.PCC_AUTO_KEY
LEFT JOIN cla_prod.quantum_prod_qctl.CERT_SOURCE cts ON
	cts.CTS_AUTO_KEY = stm.CTS_AUTO_KEY
LEFT JOIN cla_prod.quantum_prod_qctl.WAREHOUSE whs ON
	whs.WHS_AUTO_KEY = stm.WHS_AUTO_KEY
LEFT JOIN cla_prod.quantum_prod_qctl.GEO_CODES geo ON
	geo.GEO_AUTO_KEY = whs.GEO_AUTO_KEY
LEFT JOIN cla_prod.quantum_prod_qctl.PN_TYPE_CODES ptc ON
	ptc.PTC_AUTO_KEY = pm.PTC_AUTO_KEY
LEFT JOIN cla_prod.quantum_prod_qctl.APPLICATION_CODES apc ON
	apc.APC_AUTO_KEY = pm.APC_AUTO_KEY
LEFT JOIN cla_prod.quantum_prod_qctl.PN_GROUPS png ON
	png.PNG_AUTO_KEY = pm.PNG_AUTO_KEY
LEFT JOIN cla_prod.quantum_prod_qctl.cq_status cqs ON
	cqs.CQS_AUTO_KEY = cqh.CQS_AUTO_KEY
WHERE
	to_date(cqd.ENTRY_DATE) > TO_DATE('2016-01-01')
	AND cqd.ROUTE_DESC IN ('Part Sale')
	AND cqd.CQD_AUTO_KEY IS NOT NULL
	AND cqd.QTY_QUOTED > 0
	AND pcc_cqd.COND_LEVEL > 0
	AND cqd.NO_QUOTE_FLAG = 'F'
	AND pcc_cqd.condition_code <> 'NQ'
	AND cqd.QTY_QUOTED > 0
	AND cqd.UNIT_PRICE > 0
	