SELECT MAX(erh.processstart)
FROM   ESS_REQUEST_HISTORY erh
WHERE  definition =
'JobDefinition://oracle/apps/ess/custom/AP/Payments/CirrusWebcashPaymentReconExtract'
AND    executable_status = 'SUCCEEDED'