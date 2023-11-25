--Hoja 1: Resumen de diferencias

	--Cuadro 1 : 
		--Nombre del porteo(LDC)
		--Folio de devolución

		select
				ld.LOCATION_NAME as NOMBRE_DEL_PORTEO,
				orr.collection_folio_name AS FOLIO_DEVOLUCION
			from collection_order orr
				inner join ldc ld on orr.LDC_ID = ld.ldc_id
			where orr.collection_folio_name = '20230824-0121'
		;


	--Cuadro 2: Orden de Recolección
		--Total de cajas solicitadas
		select
				count(pck.PACKAGE_TYPE) as CAJAS_SOLICITADAS,
				NVL(sum(package_cost),0) as costo
			from packages pck
			where
				pck.ID_COLLECTION_FOLIO in (
					select gt.ID_COLLECTION_FOLIO
						from collection_order gt
						where
							gt.collection_folio_name = '20230824-0121'
				)
				and pck.PACKAGE_TYPE not in('H')
		;

		--Total de unitarios solicitados
		select
				count(pck.PACKAGE_TYPE) as UNITARIOS_SOLICITADOS,
				NVL(sum(package_cost),0) as costo
			from packages pck
			where
				pck.ID_COLLECTION_FOLIO in (
					select gt.ID_COLLECTION_FOLIO
						from collection_order gt
						where gt.collection_folio_name = '20230824-0121'
				)
				and pck.PACKAGE_TYPE  ='H'
		;

		--Total de bultos solicitados
		select
			count(pck.PACKAGE_TYPE)  as TOTAL_BULTOS,
			NVL(sum(pck.package_cost),0) as costo
			from packages pck
				left join packages pck2
					on pck.package_id = pck2.package_id 
					and pck.PACKAGE_TYPE not in('H')
					and pck2.PACKAGE_TYPE  ='H'
			where pck.ID_COLLECTION_FOLIO in (
					select gt.ID_COLLECTION_FOLIO
						from collection_order gt
						where gt.collection_folio_name = '20230824-0121'
				)
		;


	----Cuadro 3: Embarque fisico
		--Total de cajas enviadas
		select
				count(pck.PACKAGE_ID) as CAJAS_RECIBIDOS,
				NVL(sum(package_cost),0) as costo
			from packages pck
				inner join package_statuses pc
					on pc.package_id = pck.package_id
			where
				pck.ID_COLLECTION_FOLIO in (
					select gt.ID_COLLECTION_FOLIO
						from collection_order gt
						where gt.collection_folio_name = '20230824-0121'
				)
				and status = 29
				and PACKAGE_TYPE <>'H'
		;

		--Total de unitarios enviados
		select
				count(pck.PACKAGE_ID) UNITARIOS_RECIBIDOS,
				NVL(sum(package_cost),0) as costo
			from packages pck
				inner join package_statuses pc
					on pc.package_id = pck.package_id
			where
				pck.ID_COLLECTION_FOLIO in (
					select gt.ID_COLLECTION_FOLIO
						from collection_order gt
						where gt.collection_folio_name = '20230824-0121'
				)
				and status = 29
				and PACKAGE_TYPE ='H'
		;

		--Total de bultos enviados
		select
				count( pck.PACKAGE_ID) as BULTOS_RECIBIDOS,
				NVL(sum(pck.package_cost),0) as costo
			from packages pck
				inner join package_statuses pc
					on pc.package_id = pck.package_id
					and pc.status  = 29
				left join packages pck2
					on pck2.package_id = pck.package_id
					and pck2.PACKAGE_TYPE ='H'
					and pck.PACKAGE_TYPE <>'H'
			where
				pck.ID_COLLECTION_FOLIO in (
					select gt.ID_COLLECTION_FOLIO
						from collection_order gt
						where gt.collection_folio_name = '20230824-0121'
				)
		;


	----Cuadro 4: Concordante en bultos
		---Concordante en bultos
		select
				count(pck.PACKAGE_ID) as CAJAS_CONCORDANTES,
				NVL(sum(package_cost),0) as costo
			from packages pck
				inner join package_statuses pc
					on pc.package_id = pck.package_id
			where
				pck.ID_COLLECTION_FOLIO in (
					select gt.ID_COLLECTION_FOLIO
						from collection_order gt
						where gt.collection_folio_name = '20230824-0121'
				)
				and status = 29
				and PACKAGE_TYPE <>'H'
		;

		--Unitarios concordantes
		select
				count(pck.PACKAGE_ID) as  UNITARIOS_CONCORDANTES,
				NVL(sum(package_cost),0) as costo
			from packages pck
				inner join package_statuses pc
					on pc.package_id = pck.package_id
			where
				pck.ID_COLLECTION_FOLIO in (
					select gt.ID_COLLECTION_FOLIO
						from collection_order gt
						where gt.collection_folio_name = '20230824-0121'
				)
				and status = 29
				and PACKAGE_TYPE ='H'
		;


	---CUADRO 5: Sobrante en bultos
		---Cajas a mas
		SELECT
				count(*) as cajas_a_mas,
				NVL(sum(pck.PACKAGE_COST),0) as costo
			FROM package_leftover fr
				inner join packages pck
					on pck.PACKAGE_ID = fr.PACKAGE_ID
				inner join collection_order od
					on od.ID_COLLECTION_FOLIO = fr.ID_COLLECTION_FOLIO
			where
				od.collection_folio_name = '20230912-0139'
				and pck.PACKAGE_TYPE !='H'
		;


		--UNITARIOS A MAS
		SELECT
				NVL(sum(collected_quantity),0) as unitarios_a_mas,
				NVL(sum(it.ITEM_PRICE * collected_quantity),0) as costo
			FROM package_leftover fr
				left join DBA_SCPI.ITEM_DATA it
					on it.fsc = fr.fsc
				inner join collection_order od
					on od.ID_COLLECTION_FOLIO = fr.ID_COLLECTION_FOLIO
			where od.COLLECTION_FOLIO_NAME ='20230912-0139'
				and it.YEAR in (
					select
						max(itm.YEAR)
						from DBA_SCPI.ITEM_DATA itm
						where itm.LINNO = it.LINNO
				)
				and it.CAMPAIGN in (
					select max(ie.CAMPAIGN)
						from DBA_SCPI.ITEM_DATA ie
						where
							ie.YEAR in (
								select max(ie.YEAR)
									from DBA_SCPI.ITEM_DATA dd
							)
							and ie.linno = it.linno
				)
		;



	--Cuadro 6: Faltantes en bultos
		--Cajas faltantes
		select
				count( pck.PACKAGE_ID) as CAJAS_A_MENOS,
				NVL(sum(package_cost),0) as costo
			from packages pck
				inner join package_statuses pc
					on pc.package_id = pck.package_id
			where pck.ID_COLLECTION_FOLIO in (
					select gt.ID_COLLECTION_FOLIO
						from collection_order gt
						where gt.collection_folio_name = '20230824-0121'
				)
				and status = 28
				and PACKAGE_TYPE <>'H'
				and pck.PACKAGE_ID not in (
					select pck.PACKAGE_ID
						from packages pck
							inner join package_statuses pc
								on pc.package_id = pck.package_id
						where pck.ID_COLLECTION_FOLIO in (
								select gt.ID_COLLECTION_FOLIO
									from collection_order gt
									where gt.collection_folio_name = '20230824-0121'
							)
							and status = 29
							and PACKAGE_TYPE <>'H'
				)
		;

		--V2
		with datos as (
			select
					p.PACKAGE_ID,
					package_cost as costo,
					ps.status
				from packages p
					inner join package_statuses ps
						on ps.package_id = p.package_id
					inner join collection_order co
						on p.ID_COLLECTION_FOLIO = co.ID_COLLECTION_FOLIO
				where
					co.collection_folio_name = '20230824-0121'
					and PACKAGE_TYPE <>'H'
					and (ps.status = 28 or ps.status = 29)
		)
		select
				count( d.PACKAGE_ID) as CAJAS_A_MENOS,
				nvl(sum(d.costo),0) as COSTO
			from datos d
			where d.status = 28
				and d.PACKAGE_ID not in (select PACKAGE_ID from datos where status = 29)
		;


		--Unitarios faltantes
		select
				count(pck.PACKAGE_ID) as UNITARIOS_A_MENOS,
				NVL(sum(package_cost),0) as costo
			from packages pck
				inner join package_statuses pc
					on pc.package_id = pck.package_id
			where pck.ID_COLLECTION_FOLIO in (
					select
							gt.ID_COLLECTION_FOLIO
						from collection_order gt
						where gt.collection_folio_name = '20230824-0121'
				)
				and status = 28
				and PACKAGE_TYPE = 'H'
				and pck.PACKAGE_ID not in (
					select pck.PACKAGE_ID
						from packages pck
							inner join package_statuses pc
								on pc.package_id = pck.package_id
						where pck.ID_COLLECTION_FOLIO in (
								select gt.ID_COLLECTION_FOLIO
									from collection_order gt
									where gt.collection_folio_name = '20230824-0121'
							)
							and status = 29
							and PACKAGE_TYPE = 'H'
				)
		;

		--V2
		with datos as (
			select
					p.PACKAGE_ID,
					package_cost as costo,
					ps.status
				from packages p
					inner join package_statuses ps
						on ps.package_id = p.package_id
					inner join collection_order co
						on p.ID_COLLECTION_FOLIO = co.ID_COLLECTION_FOLIO
				where
					co.collection_folio_name ='20230824-0121'
					and (ps.status = 28 or ps.status = 29)
					and PACKAGE_TYPE ='H'
		)
		select
				count( d.PACKAGE_ID) as UNITARIOS_A_MENOS,
				NVL(sum(d.costo),0) as COSTO
			from datos d
			where
				d.status = 28
				and d.PACKAGE_ID not in ( select PACKAGE_ID from datos where status = 29 )
		;


	--Cuadro 8: Total a aclarar. Suma de bultos (Total a aclarar)
		select
				count( pck.PACKAGE_ID) as UNITARIOS_FALTANTES,
				NVL(sum(package_cost),0) as costo
			from packages pck
				inner join package_statuses pc
					on pc.package_id = pck.package_id
			where pck.ID_COLLECTION_FOLIO in (
					select gt.ID_COLLECTION_FOLIO
						from collection_order gt
						where gt.collection_folio_name = '20230524-0020'
				)
				and status = 28 
				and pck.PACKAGE_ID not in (
					select pck.PACKAGE_ID
						from packages pck
							inner join package_statuses pc
								on pc.package_id = pck.package_id
						where pck.ID_COLLECTION_FOLIO in (
								select gt.ID_COLLECTION_FOLIO
									from collection_order gt
									where gt.collection_folio_name = '20230524-0020'
							)
							and status = 29 
				)
		;


--Hoja 2: Cajas a menos
		select
				pck.BARCODE as id_carton,
				hs.full_campaign as campaña,
				hs.account,
				hs.zone,
				hs.order_number,
				pck.package_cost as precio_de_venta
			from packages pck
				inner join package_statuses pc
					on pc.package_id = pck.package_id
				inner join scpi_order_headers hs
					on hs.order_id= pck.order_id
			where
				pck.ID_COLLECTION_FOLIO in (
					select gt.ID_COLLECTION_FOLIO
						from collection_order gt
						where gt.collection_folio_name = '20230524-0020'
				)
				and status = 28
				and PACKAGE_TYPE <>'H'
				and pck.PACKAGE_ID not in (
					select pck.PACKAGE_ID
						from packages pck
							inner join package_statuses pc
								on pc.package_id = pck.package_id
						where
							pck.ID_COLLECTION_FOLIO in (
								select gt.ID_COLLECTION_FOLIO
									from collection_order gt
									where
										gt.collection_folio_name = '20230824-0121'
							)
							and status = 29
							and PACKAGE_TYPE <>'H'
				)
		;

--Hoja 3: Unitarios a menos
with datas as(

select
				it.fsc,
				count(*) as quantity,
				nvl(sum(pck.package_cost),0) as precio_De_venta,
				nvl(sum(pck.package_cost),0) as total,
				it.description
			from packages pck
				inner join package_statuses pc
					on pc.package_id = pck.package_id
				inner join items it
					on it.order_id = pck.order_id
					and it.package_id = pck.package_id
			where
				pck.ID_COLLECTION_FOLIO in (
					select gt.ID_COLLECTION_FOLIO
						from collection_order gt
						where
							gt.collection_folio_name = '20230524-0020'
				)
				and status = 28
				and PACKAGE_TYPE ='H'
				and pck.PACKAGE_ID not in (
					select pck.PACKAGE_ID
						from packages pck
							inner join package_statuses pc
								on pc.package_id = pck.package_id
						where
							pck.ID_COLLECTION_FOLIO in (
								select gt.ID_COLLECTION_FOLIO
									from collection_order gt
									where
										gt.collection_folio_name = '20230524-0020'
							)
							and status = 29
							and PACKAGE_TYPE ='H'
				)
			group by
				it.fsc,
				pck.package_cost,
				pck.package_cost,
				it.description
			order by fsc
		) select  dd.fsc,dd.quantity,dd.precio_De_venta ,dd.quantity*dd.precio_De_venta as total from datas dd

--Hoja 4: Cajas concordantes
		select
				pck.BARCODE as IDCARTON,
				hs.FULL_CAMPAIGN as CAMPANIA,
				hs.account as REGISTRO, 
				hs.zone as ZONA,
				hs.order_number,
				pck.package_cost as PRECIO_DE_VENTA
			from packages pck
				inner join package_statuses pc
					on pc.package_id = pck.package_id
				inner join scpi_order_headers hs
					on hs.order_id= pck.order_id
			where
				pck.ID_COLLECTION_FOLIO in (
					select gt.ID_COLLECTION_FOLIO
						from collection_order gt
						where gt.collection_folio_name = '20230524-0020'
				)
				and status = 29
				and PACKAGE_TYPE <>'H'
		;


--Hoja 5: Unitarios concordantes
-- UPDATE
		with detalle as (
			select
					i.FSC as FSC,
					count(*) as quantity,
					nvl(pck.package_cost,0) as precio_De_venta,
					i.DESCRIPTION
				from packages pck
					inner join package_statuses pc
						on pc.package_id = pck.package_id
					inner join scpi_order_headers hs
						on hs.order_id= pck.order_id
					inner join items i
						on i.PACKAGE_ID = pck.PACKAGE_ID
				where
					pck.ID_COLLECTION_FOLIO in (
						select gt.ID_COLLECTION_FOLIO
							from collection_order gt
							where gt.collection_folio_name = '20230912-0139'
					)
					and status = 29
					and PACKAGE_TYPE ='H'
			group by i.FSC ,pck.package_cost,i.DESCRIPTION
		)
		select
				FSC,
				sum(quantity),
				max(precio_De_venta),
				max(precio_De_venta)*sum(quantity) as total,
				DESCRIPTION
			from detalle
			group by FSC,DESCRIPTION
		;


------HOJA 6: CAJAS A MAS
		SELECT
				--fr.ID_PACKAGE_LEFTOVER,
				pck.BARCODE AS ID_CARTON,
				hr.ACCOUNT,
				--fr.PACKAGE_ID,
				pck.package_cost,
				hr.ZONE,
				hr.FULL_CAMPAIGN
			FROM package_leftover fr
				inner join packages pck
					on pck.PACKAGE_ID = fr.PACKAGE_ID
				inner join scpi_order_headers hr
					on hr.ORDER_ID = pck.ORDER_ID
				inner join collection_order od
					on od.ID_COLLECTION_FOLIO = fr.ID_COLLECTION_FOLIO
			where
				od.COLLECTION_FOLIO_NAME ='20230824-0121'
				and pck.PACKAGE_TYPE !='H'
		;

--HOJA 7: UNITARIOS A MAS
		SELECT
				fr.fsc,
				nvl(sum(collected_quantity),0) as CANTIDAD,
				nvl(it.ITEM_PRICE,0) as PRECIO_VENTA,
				nvl(sum(it.ITEM_PRICE * collected_quantity),0) as TOTAL,
				it.DESC1 as DESCRIPCION
			FROM package_leftover fr
				left join DBA_SCPI.ITEM_DATA it
					on it.fsc = fr.fsc
				inner join collection_order od
					on od.ID_COLLECTION_FOLIO = fr.ID_COLLECTION_FOLIO
			where od.COLLECTION_FOLIO_NAME ='20230912-0139'
				and it.YEAR in (
					select
						max(itm.YEAR)
						from DBA_SCPI.ITEM_DATA itm
						where itm.LINNO = it.LINNO
				)
				and it.CAMPAIGN in (
					select  max(ie.CAMPAIGN) from DBA_SCPI.ITEM_DATA ie
						where
							ie.YEAR in (select  max(ie.YEAR) from DBA_SCPI.ITEM_DATA dd)
							and ie.linno = it.linno  )
				group by fr.fsc,DESC1,it.ITEM_PRICE
		;