SELECT '' imp_batch_number
      ,t.imp_key_number
      ,t.record_name
      ,t.record_company
      ,t.product_type
      ,t.amount
      ,t.client_id
      ,t.contract_id
      ,t.contract_type contract_type
      ,'' pay_source
      ,t.gb_project_id
      ,t.group_id
      ,t.city_id
      ,'' cash_to
      ,t.payment_account payment_account
      ,'' payment_name
      ,'' payment_bank
      ,'' payment_date
	  ,t.event_date
      ,t.payment_type payment_type
      ,t.payment_method payment_method
      ,t.receipt_account receipt_account
      ,t.receipt_name receipt_name
      ,t.receipt_bank receipt_bank
      ,'' mis_type
      ,'' sales_price
      ,'' buy_price
      ,'' quantity_saled
      ,'' quantity_used
      ,'' amount_used
      ,'' quantity_unused
      ,'' quantity_refund
      ,'' amount_refund
      ,'' quantity_cash
      ,t.payment_ticket_id payment_ticket_id
      ,'' chain_id
      ,'' chain_name
      ,'' hotel_id
      ,'' hotel_name
      ,'' ticketing_system
      ,'' room_number
      ,'' category_name
      ,'' process_status
      ,'' creation_date
      ,t.comments comments
      ,'' attribute1
      ,'' attribute2
      ,'' attribute3
      ,'' attribute4
      ,'' attribute5
      ,'' attribute6
      ,'' attribute7
      ,'' attribute8
      ,'' attribute9
      ,'' attribute10
      ,'' attribute11
      ,'' attribute12
      ,'' attribute13
      ,'' attribute14
      ,'' attribute15
      ,t.record_date
      ,t.source_system
      ,t.business_type
  FROM (SELECT imp_key_number
              ,record_name
              ,record_company
              ,'' product_type
              ,amount
              ,'' client_id
              ,'' contract_id
              ,'' gb_project_id
              ,'' group_id
              ,payment_account
              ,payment_type
              ,payment_method
              ,'' payment_ticket_id
              ,'' receipt_account
              ,'' receipt_name
              ,'' receipt_bank
              ,'' city_id
              ,record_date
              ,source_system
              ,business_type
              ,event_date
              ,'' contract_type
              ,comments
          FROM ba_finance.cux_mis_new_withdraw
        UNION ALL
        SELECT imp_key_number
              ,record_name
              ,record_company
              ,'' product_type
              ,amount
              ,'' client_id
              ,'' contract_id
              ,'' gb_project_id
              ,'' group_id
              ,payment_account
              ,'' payment_type
              ,payment_method
              ,'' payment_ticket_id
              ,'' receipt_account
              ,'' receipt_name
              ,'' receipt_bank
              ,'' city_id
              ,record_date
              ,source_system
              ,business_type
              ,event_date
              ,'' contract_type
              ,'' comments
          FROM ba_finance.cux_mis_new_receipt
        UNION ALL
        SELECT imp_key_number
              ,record_name
              ,record_company
              ,product_type
              ,amount
              ,client_id
              ,contract_id
              ,gb_project_id
              ,'' group_id
              ,'' payment_account
              ,'' payment_type
              ,'' payment_method
              ,'' payment_ticket_id
              ,'' receipt_account
              ,'' receipt_name
              ,'' receipt_bank
              ,'' city_id
              ,record_date
              ,source_system
              ,business_type
              ,event_date
              ,contract_type
              ,comments
          FROM ba_finance.cux_mis_new_chasefail
        UNION ALL
        SELECT imp_key_number
              ,record_name
              ,record_company
              ,product_type
              ,amount
              ,client_id
              ,contract_id
              ,gb_project_id
              ,'' group_id
              ,'' payment_account
              ,'' payment_type
              ,'' payment_method
              ,'' payment_ticket_id
              ,'' receipt_account
              ,'' receipt_name
              ,'' receipt_bank
              ,'' city_id
              ,record_date
              ,source_system
              ,business_type
              ,event_date
              ,contract_type
              ,comments
          FROM ba_finance.cux_mis_new_score
        UNION ALL
        SELECT imp_key_number
              ,record_name
              ,record_company
              ,'' product_type
              ,amount
              ,'' client_id
              ,'' contract_id
              ,'' gb_project_id
              ,'' group_id
              ,'' payment_account
              ,'' payment_type
              ,'' payment_method
              ,'' payment_ticket_id
              ,'' receipt_account
              ,'' receipt_name
              ,'' receipt_bank
              ,'' city_id
              ,record_date
              ,source_system
              ,business_type
              ,event_date
              ,'' contract_type
              ,comments
          FROM ba_finance.cux_mis_dk_ml
        UNION ALL
        SELECT imp_key_number
              ,record_name
              ,record_company
              ,'' product_type
              ,amount
              ,client_id client_id
              ,'' contract_id
              ,'' gb_project_id
              ,'' group_id
              ,'' payment_account
              ,'' payment_type
              ,'' payment_method
              ,'' payment_ticket_id
              ,'' receipt_account
              ,'' receipt_name
              ,'' receipt_bank
              ,'' city_id
              ,record_date
              ,source_system
              ,business_type
              ,event_date
              ,'' contract_type
              ,comments
          FROM ba_finance.cux_sytyx_yxzf
        UNION ALL
        SELECT imp_key_number
              ,record_name
              ,record_company
              ,'' product_type
              ,amount
              ,client_id client_id
              ,'' contract_id
              ,'' gb_project_id
              ,'' group_id
              ,'' payment_account
              ,'' payment_type
              ,'' payment_method
              ,'' payment_ticket_id
              ,'' receipt_account
              ,'' receipt_name
              ,'' receipt_bank
              ,'' city_id
              ,record_date
              ,source_system
              ,business_type
              ,event_date
              ,'' contract_type
              ,comments
          FROM ba_finance.cux_sytyx_yxtk 
        UNION ALL
        SELECT imp_key_number
              ,record_name
              ,record_company
              ,product_type
              ,amount
              ,client_id client_id
              ,contract_id
              ,gb_project_id
              ,group_id
              ,'' payment_account
              ,'' payment_type
              ,'' payment_method
              ,'' payment_ticket_id
              ,'' receipt_account
              ,'' receipt_name
              ,'' receipt_bank
              ,city_id
              ,record_date
              ,source_system
              ,business_type
              ,event_date
              ,contract_type
              ,comments
          FROM ba_finance.cux_mis_merge_consume   
        UNION ALL
        SELECT imp_key_number
              ,record_name
              ,record_company
              ,product_type
              ,amount
              ,client_id client_id
              ,contract_id
              ,gb_project_id
              ,group_id
              ,'' payment_account
              ,'' payment_type
              ,'' payment_method
              ,'' payment_ticket_id
              ,'' receipt_account
              ,'' receipt_name
              ,'' receipt_bank
              ,city_id
              ,record_date
              ,source_system
              ,business_type
              ,event_date
              ,contract_type
              ,comments
        FROM ba_finance.cux_mis_merge_refund                              
   UNION ALL
        SELECT imp_key_number
              ,record_name
              ,record_company
              ,product_type
              ,amount
              ,client_id client_id
              ,contract_id
              ,gb_project_id
              ,group_id
              ,'' payment_account
              ,'' payment_type
              ,'' payment_method
              ,'' payment_ticket_id
              ,'' receipt_account
              ,'' receipt_name
              ,'' receipt_bank
              ,city_id
              ,record_date
              ,source_system
              ,business_type
              ,event_date
              ,'' contract_type
              ,comments
        FROM ba_finance.cux_mis_merge_income) t
 WHERE t.record_date BETWEEN '$now.month_begin_date.datekey' AND '$now.month_end_date.datekey'
 distribute by `record_date`,`source_system`, `business_type`