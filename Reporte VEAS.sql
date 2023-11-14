--2.Cajas de VEA

--Hoja 1: Resumen de diferencias

	-- Cuadro 1
		--   Nombre del porteo
		--   Folio de devoluciÃ³n
		SELECT
				distinct LD.LOCATION_NAME AS PORTEO, 
				COR.COLLECTION_FOLIO_NAME AS FOLIO_ORDEN_RECOLECCION
			FROM DBA_DMS.COLLECTION_ORDER  COR
				JOIN DBA_DMS.LDC LD				ON COR.LDC_ID = LD.LDC_ID
				JOIN DBA_DMS.VA_MASTERBOX VSZ	ON COR.ID_COLLECTION_FOLIO = VSZ.ID_COLLECTION_FOLIO
			WHERE
				COR.COLLECTION_FOLIO_NAME = '20230824-0121'
		;

	-- Cuadro 2: 
		-- Orden de RecolecciÃ³n
		-- Total de cajas solicitadas 
		with qa as(
			SELECT
					COR.COLLECTION_FOLIO_NAME,
					VSZ.FOLIO_MASTER_BOX AS FOLIO_MASTER_BOX,
					sum(COLLECTED_QUANTITY*VS.SALE_PRICE) AS PRECIO_VENTA
				FROM DBA_DMS.COLLECTION_ORDER  COR
					JOIN DBA_DMS.LDC LD						ON COR.LDC_ID = LD.LDC_ID
					JOIN DBA_DMS.VA_MASTERBOX VSZ			ON COR.ID_COLLECTION_FOLIO = VSZ.ID_COLLECTION_FOLIO
					JOIN DBA_DMS.VA_MASTERBOX_DETAIL VMD	ON VSZ.ID_FOLIO_MASTERBOX = VMD.ID_FOLIO_MASTERBOX 
					JOIN DBA_DMS.VA_SET VS					ON VMD.SET_VA_ID = VS.SET_VA_ID
				WHERE COR.COLLECTION_FOLIO_NAME = '20230824-0121'-- '20230602-0052'
				GROUP BY
					COR.COLLECTION_FOLIO_NAME,
					VSZ.FOLIO_MASTER_BOX
		)
		select 
				count(FOLIO_MASTER_BOX) as FOLIO_MASTER_BOX,
				NVL(sum(PRECIO_VENTA),0) as PRECIO_VENTA
			from qa
		;

	-- Cuadro 3 Embarque fÃ­sico:  
		-- Total de cajas enviadas (bultos y monto total a precio folleto)
		with qa as(
			SELECT
					VSZ.FOLIO_MASTER_BOX AS FOLIO_MASTER_BOX,
					sum(COLLECTED_QUANTITY * VS.SALE_PRICE) AS  PRECIO_VENTA
				FROM DBA_DMS.COLLECTION_ORDER  COR
					JOIN DBA_DMS.LDC LD						ON COR.LDC_ID = LD.LDC_ID
					JOIN DBA_DMS.VA_MASTERBOX VSZ			ON COR.ID_COLLECTION_FOLIO = VSZ.ID_COLLECTION_FOLIO
					JOIN DBA_DMS.VA_MASTERBOX_DETAIL VMD	ON VSZ.ID_FOLIO_MASTERBOX = VMD.ID_FOLIO_MASTERBOX 
					JOIN DBA_DMS.VA_SET VS					ON VMD.SET_VA_ID = VS.SET_VA_ID
					JOIN DBA_DMS.VA_STATUS_TRACK VST		ON VSZ.ID_FOLIO_MASTERBOX = VST.ID_FOLIO_MASTERBOX
				WHERE
					COR.COLLECTION_FOLIO_NAME = '20230824-0121'-- '20230602-0052'
					AND VST.STATUS_MASTER_BOX = 6
					AND VST.STATUS = 1
				GROUP BY VSZ.FOLIO_MASTER_BOX
		)
		select 
				count(FOLIO_MASTER_BOX) as FOLIO_MASTER_BOX,
				NVL(sum(PRECIO_VENTA),0) as PRECIO_VENTA
			from qa
		;



	-- Cuadro 4: Concordante en bultos
		--  Cajas concordantes (bultos y monto total a precio folleto)
			with qa as(
			SELECT
					VSZ.FOLIO_MASTER_BOX AS FOLIO_MASTER_BOX,
					sum(COLLECTED_QUANTITY * VS.SALE_PRICE) AS  PRECIO_VENTA
				FROM DBA_DMS.COLLECTION_ORDER  COR
					JOIN DBA_DMS.LDC LD						ON COR.LDC_ID = LD.LDC_ID
					JOIN DBA_DMS.VA_MASTERBOX VSZ			ON COR.ID_COLLECTION_FOLIO = VSZ.ID_COLLECTION_FOLIO
					JOIN DBA_DMS.VA_MASTERBOX_DETAIL VMD	ON VSZ.ID_FOLIO_MASTERBOX = VMD.ID_FOLIO_MASTERBOX
					JOIN DBA_DMS.VA_SET VS					ON VMD.SET_VA_ID = VS.SET_VA_ID
					JOIN DBA_DMS.VA_STATUS_TRACK VST		ON VSZ.ID_FOLIO_MASTERBOX = VST.ID_FOLIO_MASTERBOX
				WHERE
					COR.COLLECTION_FOLIO_NAME = '20230824-0121'-- '20230602-0052'
					AND VST.STATUS_MASTER_BOX = 6
					AND VST.STATUS = 1
				GROUP BY VSZ.FOLIO_MASTER_BOX
		)
		select 
				count(FOLIO_MASTER_BOX) as FOLIO_MASTER_BOX,
				NVL(sum(PRECIO_VENTA),0) as PRECIO_VENTA
			from qa
		;


	-- Cuadro 5: Faltante en bultos
		-- Cajas faltantes (bultos y monto total a precio folleto)
		WITH QA AS (
			SELECT
					VST.ID_FOLIO_MASTERBOX,
					VSZ.ID_COLLECTION_FOLIO,
					SUM(COLLECTED_QUANTITY *VS.SALE_PRICE) AS PRECIO_VENTA
				FROM DBA_DMS.COLLECTION_ORDER COR
					JOIN DBA_DMS.LDC LD						ON COR.LDC_ID = LD.LDC_ID
					JOIN DBA_DMS.VA_MASTERBOX VSZ			ON COR.ID_COLLECTION_FOLIO = VSZ.ID_COLLECTION_FOLIO
					JOIN DBA_DMS.VA_STATUS_TRACK VST		ON VSZ.ID_FOLIO_MASTERBOX = VST.ID_FOLIO_MASTERBOX
					JOIN DBA_DMS.VA_MASTERBOX_DETAIL VMD	ON VSZ.ID_FOLIO_MASTERBOX = VMD.ID_FOLIO_MASTERBOX
					JOIN DBA_DMS.VA_SET VS					ON VMD.SET_VA_ID = VS.SET_VA_ID
				WHERE
					COR.COLLECTION_FOLIO_NAME = '20230824-0121'
					AND VST.STATUS_MASTER_BOX = 5 --SUBIDO A CAMION
					AND VST.STATUS = 1
				GROUP BY VSZ.ID_COLLECTION_FOLIO,VST.ID_FOLIO_MASTERBOX
		)
		SELECT
				COUNT(ID_FOLIO_MASTERBOX) AS CAJAS_FALTANTES,
				PRECIO_VENTA
			FROM QA
			GROUP BY
				ID_COLLECTION_FOLIO,
				PRECIO_VENTA
		;

	-- Cuadro 6: Total a aclarar. 
		-- SE HACE RESTA EN EXCEL


-- Hoja 2: Cajas a menos. En esta hoja deberÃ¡n aparecer los siguientes datos por columna:
		SELECT
				VSZ.FOLIO_MASTER_BOX AS ID_CARTON,
				VSZ.ZONE AS ZONA,
				NVL(sum(VS.SALE_PRICE * VMD.COLLECTED_QUANTITY),0) AS  PRECIO_VENTA
			FROM DBA_DMS.COLLECTION_ORDER COR
				JOIN DBA_DMS.LDC LD						ON COR.LDC_ID = LD.LDC_ID
				JOIN DBA_DMS.VA_MASTERBOX VSZ			ON COR.ID_COLLECTION_FOLIO = VSZ.ID_COLLECTION_FOLIO
				JOIN DBA_DMS.VA_STATUS_TRACK VST		ON VSZ.ID_FOLIO_MASTERBOX = VST.ID_FOLIO_MASTERBOX
				JOIN DBA_DMS.VA_MASTERBOX_DETAIL VMD	ON VSZ.ID_FOLIO_MASTERBOX = VMD.ID_FOLIO_MASTERBOX
				JOIN DBA_DMS.VA_SET VS					ON VMD.SET_VA_ID = VS.SET_VA_ID
				JOIN DBA_DMS.VA_PROGRAM VP				ON VS.PROGRAM_VA_ID = VP.PROGRAM_VA_ID
			WHERE
				COR.COLLECTION_FOLIO_NAME = '20230824-0121'
				AND VST.STATUS_MASTER_BOX = 5
				AND VST.STATUS = 1
			group by VSZ.FOLIO_MASTER_BOX, VSZ.ZONE
		;


-- Hoja 3: Cajas concordantes. En esta hoja deberÃ¡n aparecer los siguientes datos por columna:
		SELECT
				VSZ.FOLIO_MASTER_BOX AS ID_CARTON,
				VSZ.ZONE AS ZONA,
				NVL(sum(VS.SALE_PRICE * VMD.COLLECTED_QUANTITY),0) AS PRECIO_VENTA
			FROM DBA_DMS.COLLECTION_ORDER COR
				JOIN DBA_DMS.LDC LD						ON COR.LDC_ID = LD.LDC_ID
				JOIN DBA_DMS.VA_MASTERBOX VSZ			ON COR.ID_COLLECTION_FOLIO = VSZ.ID_COLLECTION_FOLIO
				JOIN DBA_DMS.VA_STATUS_TRACK VST		ON VSZ.ID_FOLIO_MASTERBOX = VST.ID_FOLIO_MASTERBOX
				JOIN DBA_DMS.VA_MASTERBOX_DETAIL VMD	ON VSZ.ID_FOLIO_MASTERBOX = VMD.ID_FOLIO_MASTERBOX
				JOIN DBA_DMS.VA_SET VS					ON VMD.SET_VA_ID = VS.SET_VA_ID
				JOIN DBA_DMS.VA_PROGRAM VP				ON VS.PROGRAM_VA_ID = VP.PROGRAM_VA_ID
			WHERE
				COR.COLLECTION_FOLIO_NAME = '20230824-0121'
				AND VST.STATUS_MASTER_BOX = 6
				AND VST.STATUS = 1
			group by VSZ.FOLIO_MASTER_BOX, VSZ.ZONE
		;