-- VIX BTPN SYARIAH JUNI 2023
-- Author: Faiz Naida Salimah
-- Tools: DBeaver, Postgres


-- Cek kelengkapan data
select count(*)
from history;

select count(distinct(client_num))
from history;
-- Jumlah record dengan jumlah nilai unik paka nomor client sama, 10127


-- -------------------------------------------------
-- Membuat datamart
-- -------------------------------------------------

create table datamart_history as
	select
		client_num, 
		status, 
		case
			when age <= 30 then '21 - 30'
			when age <= 40 then '31 - 40'
			when age <= 50 then '41 - 50'
			when age <= 60 then '51 - 60'
			when age <= 70 then '61 - 70'
			when age > 70 then '70+'
		end as age_category,
		gender, 
		education_level, 
		marital_status,
		dependent_count, 
		income_category, 
		card_category,
		case
			when months_on_book <= 24 then '1 - 2'
			when months_on_book <= 36 then '2 - 3'
			when months_on_book <= 48 then '3 - 4'
			when months_on_book <= 60 then '4 - 5'
			when months_on_book <= 72 then '6 - 7'
		end as years_on_book,
		total_relationship_count,
		months_inactive_12_mon,
		contacts_count_12_mon,
		credit_limit,
		total_revolving_bal,
		avg_open_to_buy,
		total_trans_amt,
		total_trans_ct,
		avg_utilization_ratio
	from history h 
		left join status_db sd 
			on h.status_id = sd.status_id
		left join education_db ed
			on h.education_id = ed.education_level_id
		left join marital_db md 
			on h.marital_id  = md.marital_status_id
		left join category_db cd
			on h.card_category_id  = cd.card_category_id 
;

-- -------------------------------------------------
-- Berapa persen customer yang churn?
-- -------------------------------------------------
select 
	status,
	count(status),
	round(count(status) * 100.0 /
		(select count(*) from datamart_history),2) 
		as percentage
from datamart_history
group by 1;


-- -------------------------------------------------
-- Profil Demografi Customer
-- -------------------------------------------------

-- Analis customer churn berdasarkan kategori usia
select 
	age_category,
	count(age_category) as customer_total,
	count(case when status = 'Attrited Customer' then 1 end) as attrited_customer,
	round(count(case when status = 'Attrited Customer' then 1 end) * 100.0 / 
		count(age_category),2) as ratio
from datamart_history
group by 1
order by 1


-- Analis customer churn berdasarkan kategori gender
select 
	gender,
	count(gender) as customer_total,
	count(case when status = 'Attrited Customer' then 1 end) as attrited_customer_total,
	round(count(case when status = 'Attrited Customer' then 1 end) * 100.0 / 
		count(gender),2) as ratio
from datamart_history
group by 1
order by 3 desc 


-- Analis customer churn berdasarkan tingkat pendidikan
select 
	education_level ,
	count(education_level) as customer_total,
	count(case when status = 'Attrited Customer' then 1 end) as attrited_customer_total,
	round(count(case when status = 'Attrited Customer' then 1 end) * 100.0 / 
		count(education_level),2) as ratio
from datamart_history
group by 1
order by 3 desc


-- Analis customer churn berdasarkan status pernikahan
select 
	marital_status,
	--dependent_count,
	count(marital_status) as customer_total,
	count(case when status = 'Attrited Customer' then 1 end) as attrited_customer_total,
	round(count(case when status = 'Attrited Customer' then 1 end) * 100.0 / 
		count(marital_status),2) as ratio
from datamart_history
group by 1
order by 3 desc


-- Analis customer churn berdasarkan jumlah tanggungan
select 
	dependent_count,
	count(dependent_count) as customer_total,
	count(case when status = 'Attrited Customer' then 1 end) as attrited_customer_total,
	round(count(case when status = 'Attrited Customer' then 1 end) * 100.0 / 
		count(dependent_count),2) as ratio
from datamart_history
group by 1
order by 1


-- Analis customer churn berdasarkan kategori income
select 
	income_category  ,
	count(income_category) as customer_total,
	count(case when status = 'Attrited Customer' then 1 end) as attrited_customer_total,
	round(count(case when status = 'Attrited Customer' then 1 end) * 100.0 / 
		count(income_category),2) as ratio
from datamart_history
group by 1
order by 3 desc 



-- -------------------------------------------------
-- Informasi Kartu Credit Customer
-- -------------------------------------------------

-- Analis customer churn berdasarkan jenis kartu
select 
	card_category,
	-- income_category,
	count(card_category) as customer_total,
	count(case when status = 'Attrited Customer' then 1 end) as attrited_customer_total,
	round(count(case when status = 'Attrited Customer' then 1 end) * 100.0 / 
		count(card_category),2) as ratio
from datamart_history
group by 1 --,2
order by 3 desc


-- Analis customer churn berdasarkan rata-rata limit 
select
	status,
	round(avg(credit_limit),2) as mean_limit_total,
	percentile_cont(0.5) within group (order by credit_limit) as median_limit_total
from datamart_history
group by 1


-- Analis customer churn berdasarkan jumlah produk yang dipegang
select 
	total_relationship_count,
	count(total_relationship_count) as customer_total,
	count(case when status = 'Attrited Customer' then 1 end) as attrited_customer_total,
	round(count(case when status = 'Attrited Customer' then 1 end) * 100.0 / 
		count(total_relationship_count),2) as ratio
from datamart_history
group by 1
order by 1


-- Analis customer churn berdasarkan lama hubungan customer dengan bank
select 
	years_on_book,
	count(years_on_book) as customer_total,
	count(case when status = 'Attrited Customer' then 1 end) as attrited_customer_total,
	round(count(case when status = 'Attrited Customer' then 1 end) * 100.0 / 
		count(years_on_book),2) as ratio
from datamart_history
group by 1
order by 1


-- Analis customer churn berdasarkan jumlah panggilan bank 12 bulan terakhir
select 
	contacts_count_12_mon,
	count(contacts_count_12_mon) as customer_total,
	count(case when status = 'Attrited Customer' then 1 end) as attrited_customer_total,
	round(count(case when status = 'Attrited Customer' then 1 end) * 100.0 / 
		count(contacts_count_12_mon),2) as ratio
from datamart_history
group by 1
order by 1


-- Analis customer churn berdasarkan jumlah transaksi tidak aktif 12 bulan terakhir
select 
	months_inactive_12_mon,
	count(months_inactive_12_mon) as customer_total,
	count(case when status = 'Attrited Customer' then 1 end) as attrited_customer_total,
	round(count(case when status = 'Attrited Customer' then 1 end) * 100.0 / 
		count(months_inactive_12_mon),2) as ratio
from datamart_history
group by 1
order by 1

-- Analis customer churn berdasarkan revolving balance
select
	status,
	round(avg(total_revolving_bal),2) as mean_rev,
	percentile_cont(0.50) within group (order by total_revolving_bal) as median_rev
from datamart_history
group by 1


-- -------------------------------------------------
-- Histori Transaksi
-- -------------------------------------------------
select
	status,
	-- round(avg(avg_open_to_buy),2) as mean_open_to_buy,
	-- percentile_cont(0.50) within group (order by avg_open_to_buy) as median_open_to_buy,
	
	round(avg(total_trans_amt),2) as mean_total_trans_amt,
	percentile_cont(0.50) within group (order by total_trans_amt) as median_total_trans_amt,
	
	round(avg(total_trans_ct ),2) as mean_total_trans_ct ,
	percentile_cont(0.50) within group (order by total_trans_ct ) as median_total_trans_ct 
from datamart_history
group by 1
