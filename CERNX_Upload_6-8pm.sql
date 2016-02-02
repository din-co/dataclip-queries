SELECT
  spree_orders.number,
  CONCAT(spree_addresses.firstname, ' ', spree_addresses.lastname) AS recipient_name,
  spree_addresses.phone AS recipient_phone,
  spree_orders.special_instructions AS recipient_notes,
  spree_addresses.address1 AS address_line1,
  spree_addresses.address2 AS address_line2,
  spree_addresses.city AS city,
  'CA' AS state,
  spree_addresses.zipcode AS postal_code,
  'USA' AS country,
  ' ' AS latitude,
  ' ' AS longitude,
  ' ' AS task_details,
  COALESCE(
    CASE
      CONCAT(spree_delivery_windows.start_hour,'-',spree_delivery_windows.start_hour + spree_delivery_windows.duration)
      WHEN '13-17'
      THEN '1-5pm'
      ELSE NULL
    END,
    CASE
      CONCAT(spree_delivery_windows.start_hour,'-',spree_delivery_windows.start_hour + spree_delivery_windows.duration)
      WHEN '18-19'
      THEN '6-7pm'
      ELSE NULL
    END,
    CASE
      CONCAT(spree_delivery_windows.start_hour,'-',spree_delivery_windows.start_hour + spree_delivery_windows.duration)
      WHEN '19-20'
      THEN '7-8pm'
      ELSE NULL
    END,
    CASE
      CONCAT(spree_delivery_windows.start_hour,'-',spree_delivery_windows.start_hour + spree_delivery_windows.duration)
      WHEN '18-20'
      THEN '6-8pm'
      ELSE NULL
    END
  ) AS delivery_window,
  CONCAT(DATE(spree_orders.completed_at AT TIME ZONE 'UTC' AT TIME ZONE 'PST8PDT'),' ',spree_delivery_windows.start_hour,':00:00') AS complete_after,
  CONCAT(DATE(spree_orders.completed_at AT TIME ZONE 'UTC' AT TIME ZONE 'PST8PDT'),' ',spree_delivery_windows.start_hour + spree_delivery_windows.duration,':00:00') AS complete_before,
  'CERNX' AS organization
FROM spree_shipments
LEFT JOIN spree_orders ON spree_shipments.order_id=spree_orders.id
LEFT JOIN spree_users ON spree_users.id=spree_orders.user_id
LEFT JOIN spree_addresses ON spree_addresses.id=spree_orders.ship_address_id
LEFT JOIN spree_delivery_windows ON spree_delivery_windows.id=spree_shipments.delivery_window_id

WHERE
  spree_orders.state='complete' AND
  spree_shipments.state='ready' AND
  DATE(spree_orders.completed_at AT TIME ZONE 'UTC' AT TIME ZONE 'PST8PDT')>=DATE(current_date) AND
  CONCAT(spree_delivery_windows.start_hour,'-',spree_delivery_windows.start_hour + spree_delivery_windows.duration)<>'13-17'
