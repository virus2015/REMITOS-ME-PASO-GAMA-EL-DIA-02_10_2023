--3.Cajas de Remitos
--Hoja 1: Resumen de diferencias de remitos
	--	Cuadro 1 
		select
				distinct LD.LOCATION_NAME as  NOMBRE_PORTEO,
				orr.collection_folio_name as Folio_devolucion
			from   DBA_DMS.REMITO_MASTERBOX rm
				inner join REMITO_MASTERBOX_TOTALS tot
					on tot.masterbox_totals_id = rm.masterbox_totals_id
				inner join collection_order orr
					on orr.id_collection_folio = tot.id_collection_folio
				inner join DBA_DMS.ZONE_CAMPAIGNS ZC 
					on tot.ZONE = ZC.ZONE
					and tot.FULL_CAMPAIGN = ZC.FULL_CAMPAIGN
				inner join ldc ld
					on ld.ldc_id = ldw_code
			where
				tot.ID_COLLECTION_FOLIO IS NOT NULL
				and orr.collection_folio_name ='20230824-0121'
		;

	--Cuadro 2 :Orden de Recolecci�n
		---Total de cajas solicitadas 
		select
				count(distinct rm.MASTERBOX_ID) as total_Cajas_solicitadas,
				sum(rr.PRICE*det.items_packed) as monto_total_solicitado
			from DBA_DMS.REMITO_MASTERBOX rm
				inner join REMITO_MASTERBOX_TOTALS tot
					on tot.masterbox_totals_id = rm.masterbox_totals_id
				inner join remito_masterbox_detail det
					on det.MASTERBOX_ID = rm.MASTERBOX_ID
				inner join collection_order orr
					on orr.id_collection_folio = tot.id_collection_folio
				inner join remito rr
					on rr.REMITO_ID = det.REMITO_ID
				where
					tot.ID_COLLECTION_FOLIO IS NOT NULL
					and orr.collection_folio_name ='20230912-0139'
		;

	--Cuadro 3 : Embarque f�sico
		--Total cajas enviadas
		select
				count(distinct rm.MASTERBOX_ID) as bultos_embarque,
				nvl(sum(rr.PRICE*det.items_packed),0) as monto_total_embarque
			from DBA_DMS.REMITO_MASTERBOX rm
				inner join REMITO_MASTERBOX_TOTALS tot
					on tot.masterbox_totals_id = rm.masterbox_totals_id
				inner join remito_masterbox_detail det
					on det.MASTERBOX_ID = rm.MASTERBOX_ID
				inner join remito rr
					on rr.REMITO_ID = det.REMITO_ID
				inner join collection_order orr
					on orr.id_collection_folio = tot.id_collection_folio
			WHERE
				tot.ID_COLLECTION_FOLIO IS NOT NULL
				and orr.collection_folio_name ='20230912-0139'
				and rm.STATUS_MASTER_BOX = 6
		;

	--	Cuadro 4 :Concordante en bultos
		--?	Cajas concordantes 
		select
				count(distinct rm.MASTERBOX_ID) as bultos_concordante,
				nvl(sum(rr.price*det.items_packed),0) as monto_total_concordante
			from DBA_DMS.REMITO_MASTERBOX rm
				inner join REMITO_MASTERBOX_TOTALS tot
					on tot.masterbox_totals_id = rm.masterbox_totals_id
				inner join remito_masterbox_detail det
					on det.MASTERBOX_ID = rm.MASTERBOX_ID
				inner join remito rr
					on rr.REMITO_ID = det.REMITO_ID	
				inner join collection_order orr
					on orr.id_collection_folio = tot.id_collection_folio
			where
				tot.ID_COLLECTION_FOLIO IS NOT NULL
				and orr.collection_folio_name ='20230912-0139'
				and rm.STATUS_MASTER_BOX = 6
		;

	--	Cuadro 5 :Faltantes en bultos
		--?	Cajas Faltantes
		select
				count(distinct rm.MASTERBOX_ID) as bultos_faltantes,
				nvl(sum(rr.price*det.items_packed),0) as monto_total_faltantes
			from DBA_DMS.REMITO_MASTERBOX rm
				inner join REMITO_MASTERBOX_TOTALS tot
					on tot.masterbox_totals_id = rm.masterbox_totals_id
				inner join remito_masterbox_detail det
					on det.MASTERBOX_ID = rm.MASTERBOX_ID
				inner join remito rr
					on rr.REMITO_ID = det.REMITO_ID	
				inner join collection_order orr
					on orr.id_collection_folio = tot.id_collection_folio
			where
				tot.ID_COLLECTION_FOLIO IS NOT NULL
				and orr.collection_folio_name ='20230824-0121'
				and rm.STATUS_MASTER_BOX = 5
		;

	---Cuadro 6 :Total a aclarar
		---RESTA EL EXCEL DE TOTAL DE CAJAS SOLICITADAS - BULTOS FALTANTES  

--	Hoja 2: Cajas a menos.
		select
				rm.BOARDING_FOLIO AS ID_CARTON,
				tot.FULL_CAMPAIGN as full_campaign,
				tot.ZONE as zone,
				nvl(sum(rr.price*det.items_packed),0) as precio_venta_caja
			from DBA_DMS.REMITO_MASTERBOX rm
				inner join REMITO_MASTERBOX_TOTALS tot
					on tot.masterbox_totals_id = rm.masterbox_totals_id
				inner join remito_masterbox_detail det
					on det.MASTERBOX_ID = rm.MASTERBOX_ID
				inner join remito rr
					on rr.REMITO_ID = det.REMITO_ID	
				inner join collection_order orr
					on orr.id_collection_folio = tot.id_collection_folio
			WHERE
				tot.ID_COLLECTION_FOLIO IS NOT NULL
				and orr.collection_folio_name ='20230824-0121'
				AND rm.STATUS_MASTER_BOX = 5
			group by rm.BOARDING_FOLIO,tot.FULL_CAMPAIGN,tot.ZONE
		;

--	Hoja 3: Cajas sobrantes.
		select
				rm.BOARDING_FOLIO AS ID_CARTON,
				tot.FULL_CAMPAIGN,tot.ZONE,
				nvl(sum(rr.price*det.items_packed),0) as precio_venta_caja
			from DBA_DMS.REMITO_MASTERBOX rm
				inner join REMITO_MASTERBOX_TOTALS tot
					on tot.masterbox_totals_id = rm.masterbox_totals_id
				inner join remito_masterbox_detail det
					on det.MASTERBOX_ID = rm.MASTERBOX_ID
				inner join remito rr
					on rr.REMITO_ID = det.REMITO_ID	
				inner join collection_order orr
					on orr.id_collection_folio = tot.id_collection_folio
			where
				tot.ID_COLLECTION_FOLIO IS NOT NULL
				and orr.collection_folio_name ='20230824-0121'
				and rm.STATUS_MASTER_BOX = 6
			group by rm.BOARDING_FOLIO,tot.FULL_CAMPAIGN,tot.ZONE
		;
