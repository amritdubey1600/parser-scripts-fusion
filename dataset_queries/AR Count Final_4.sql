select count(*) from RA_Customer_Trx_all
where
batch_source_seq_id not in ('300000002290003', '300000002290007')
and Trx_Class = 'ONACC'
and Creation_Date < To_Date('25/01/2016', 'dd/mm/yy')