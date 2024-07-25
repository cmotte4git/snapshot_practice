--Snapshots
--Snapshots are difficult to practice without genuine type 2, slowly changing dimension data. For this exercise, use the following code snippets to practice snapshots. You may need to adjust the duckdb snippets based on your data warehouse.

--(In duckdb) Create a table called mock_orders in your development schema. You will have to replace dbt_kcoapman in the snippet below.

SHOW ALL TABLES;


create or replace table main.mock_orders (
    order_id integer,
    status varchar (100),
    created_at date,
    updated_at date
);

---(In duckdb) Insert values into the mock_orders table in your development schema. You will have to replace dbt_kcoapman in the snippet below.
insert into mock_orders (order_id, status, created_at, updated_at)
values (1, 'delivered', '2020-01-01', '2020-01-04'),
       (2, 'shipped', '2020-01-02', '2020-01-04'),
       (3, 'shipped', '2020-01-03', '2020-01-04'),
       (4, 'processed', '2020-01-04', '2020-01-04');

--(In dbt Cloud) Create a new snapshot in the folder snapshots with the filename mock_orders.sql with the following code snippet. Note: Jinja is being used here to create a new, dedicated schema.
{% snapshot mock_orders %}

{% set new_schema = target.schema + '_snapshot' %}

{{
    config(
      target_database='dbt',
      target_schema=new_schema,
      unique_key='order_id',

      strategy='timestamp',
      updated_at='updated_at'
    )
}}

select * from analytics.{{target.schema}}.mock_orders

{% endsnapshot %}


--(In dbt Cloud) Run snapshots by executing dbt snapshot.
--(In dbt Cloud) Run the following snippet in a statement tab to see the current snapshot table. You will have to replace dbt_kcoapman with your development schema. Take note of how dbt has added three columns.

select * from main_snapshot.mock_orders
--(In duckdb) Recreate a table called mock_orders in your development schema. You will have to replace dbt_kcoapman in the snippet below.
create or replace  table main.mock_orders (
    order_id integer,
    status varchar (100),
    created_at date,
    updated_at date
);
--(In duckdb) Insert these new values into the mock_orders table in your development schema. You will have to replace dbt_kcoapman in the snippet below.
insert into main.mock_orders (order_id, status, created_at, updated_at)
values (1, 'delivered', '2020-01-01', '2020-01-05'),
       (2, 'delivered', '2020-01-02', '2020-01-05'),
       (3, 'delivered', '2020-01-03', '2020-01-05'),
       (4, 'delivered', '2020-01-04', '2020-01-05');

--(In dbt Cloud) Re-run snapshots by executing dbt snapshot.

--(In dbt Cloud) Run the following snippet in a statement tab to see the current snapshot table. You will have to replace dbt_kcoapman with your development schema. Now take note of how dbt has 'snapshotted' the data to capture the changes over time!

select * from main_snapshot.mock_orders
select * from main.mock_orders
--Note: If you want to start this process over, you will need to drop the snapshot table by running the following in duckdb. This will force dbt to create a new snapshot table in step 4. (Again, you will need to swap in your development schema for dbt_kcoapman)

drop table main_snapshot.mock_orders

