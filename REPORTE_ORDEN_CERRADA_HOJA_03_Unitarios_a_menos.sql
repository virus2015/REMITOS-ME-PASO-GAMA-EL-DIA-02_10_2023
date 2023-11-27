with datas as(

    select
        it.fsc,
        count(*) as quantity,
        nvl(pck.package_cost,0) as precio_De_venta,
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
                    gt.collection_folio_name = '20231121-0223'
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
                        gt.collection_folio_name = '20231121-0223'
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


