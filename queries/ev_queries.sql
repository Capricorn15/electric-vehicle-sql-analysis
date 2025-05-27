create table ev_sales_table ("VIN (1-10)" VARCHAR,
county VARCHAR, city VARCHAR, state VARCHAR, postal_code VARCHAR, model_year CHAR(4), make VARCHAR, model VARCHAR,
electric_vehicle_type VARCHAR, clean_alternative_fuel_vehicle_CAFV VARCHAR,
electric_range INT, base_msr INT, electric_utility VARCHAR)

copy ev_sales_table
FROM 'C:/Program Files/PostgreSQL/17/data/SQL_Practical Task 3/Electric_Vehicle_Population_Data.csv'
WITH (FORMAT csv, HEADER true);

select * from ev_sales_table

-- Duplicate rows
SELECT "VIN (1-10)", COUNT(*) AS occurrences
FROM ev_sales_table
GROUP BY "VIN (1-10)"
HAVING COUNT(*) > 1;

-- Q1
select state, count(*) as Total_no_of_ev
from ev_sales_table
group by state

-- Q2
select count(*) as Total_no_of_ev
from ev_sales_table
where city = 'Seattle'

-- Q3
select county, count(*) as Total_no_of_ev
from ev_sales_table
group by county
order by Total_no_of_ev desc

-- Q4
select "VIN (1-10)", base_msr
from ev_sales_table
where base_msr > (select avg(base_msr) from ev_sales_table)

-- Q5
select * 
from ev_sales_table
where county = 'King' and electric_vehicle_type = 'Plug-in Hybrid Electric Vehicle (PHEV)'
and electric_range > 50 

-- Q6
select city, count(*) as total_ev
from ev_sales_table
group by city
having count(*) > 100

-- Q7
select "VIN (1-10)", make, model
from ev_sales_table
where county in
	(select county from ev_sales_table
	group by county
	having avg(electric_range) > 150)

-- Q8
select
	case 
		when base_msr <= 40000 then 'Affordable' 
		when base_msr > 40000 then 'Expensive'
		else 'Not Available'
	end as ev_cost_category,
	count(*) as total_no_of_ev
from ev_sales_table
group by ev_cost_category

select 
count(case when base_msr <= 40000 then 1 end) as Affordable,
count(case when base_msr > 40000 then 1 end) as Expensive
from ev_sales_table

-- Q9
select county, make, model, electric_range,
rank () over (partition by county order by electric_range desc) as rank_within_county
from ev_sales_table

-- Q10
with vehicle_count as (
	select 
		state,
		count(*) as total_no_ev,
		sum(case when clean_alternative_fuel_vehicle_CAFV = 'Clean Alternative Fuel Vehicle Eligible' then 1 else 0 end ) as total_no_CAFV 
	from ev_sales_table
	group by state
)
select *, (total_no_cafv::float /total_no_ev)*100 as perc_of_cafv
from vehicle_count