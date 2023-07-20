use projects;
select * from human_resources;

select count(*) from human_resources hr ;
select  birthdate from human_resources hr ;

--data cleansing:
--update date format in the birthdate column
UPDATE human_resources 
SET birthdate = CASE
	WHEN birthdate LIKE '%/%' THEN to_char(to_date(birthdate, 'MM/DD/YYYY'), 'YYYY-MM-DD')
    WHEN birthdate LIKE '%-%' THEN to_char(to_date(birthdate, 'MM-DD-YYYY'), 'YYYY-MM-DD')
    ELSE NULL
END;

select birthdate from human_resources hr ;

--change data type in the birthdate colum (varchar to date type)
alter table human_resources 
alter column birthdate type date
using to_date(birthdate, 'YYYY-MM-DD');

--update date format in the hiredate column
UPDATE human_resources 
SET hire_date  = CASE
	WHEN hire_date LIKE '%/%' THEN to_char(to_date(hire_date, 'MM/DD/YYYY'), 'YYYY-MM-DD')
    WHEN hire_date LIKE '%-%' THEN to_char(to_date(hire_date, 'MM-DD-YYYY'), 'YYYY-MM-DD')
    ELSE NULL
END;

--change data type in the hire_date colum (varchar to date type)
alter table human_resources 
alter column hire_date type date
using to_date(hire_date,'YYYY-MM-DD');

--update date format in the termdate column
UPDATE human_resources 
SET termdate = to_timestamp(termdate, 'YYYY-MM-DD HH24:MI:SS')
WHERE termdate IS NOT NULL AND termdate != ' ';

---change data type in the termdate colum (varchar to date type)
alter table human_resources 
alter column termdate type date 
using to_date(termdate,'YYYY-MM-DD');

--add age column in the existing table
alter table human_resources 
add column age int;

--calculate age using birthdate column
UPDATE human_resources 
SET age = EXTRACT(YEAR FROM AGE(CURRENT_DATE, birthdate));

select birthdate, age from human_resources hr 

--fetch youngest and oldest employee in the hr table
select min(age),
       max(age)
       from human_resources hr ;

--count the employees who are all below 18
select count(*) from human_resources hr where age < 18; 

--how many emp are currently working gender vise
SELECT gender, COUNT(*) 
FROM human_resources hr
WHERE age >= 18 
GROUP BY gender;

--What is the race/ethnicity breakdown of employees in the company?
select race,count(*) as count from human_resources hr 
where age>=18
group by race 
order by count(*) desc; 

--What is the age distribution of employees in the company?
select min(age)as youngest,
max(age) as oldest
from human_resources hr
where age >= 18;

--fetch age_group
select 
case 
	when age >=18 and age <=24 then '18-24'
	when age >=25 and age <=34 then '25-34'
	when age >=35 and age <=44 then '35-44'
	when age >=45 and age <=54 then  '45-54'
	when age >=55 and age <=64 then '55-64'
	else '65+'
end as Age_group,
count(*) as count
from human_resources hr 
where age >=18 
group by Age_group
order by Age_group;

select 
case 
	when age >=18 and age <=24 then '18-24'
	when age >=25 and age <=34 then '25-34'
	when age >=35 and age <=44 then '35-44'
	when age >=45 and age <=54 then  '45-54'
	when age >=55 and age <=64 then '55-64'
	else '65+'
end as Age_group,gender,
count(*) as count
from human_resources hr 
where age >=18 
group by Age_group,gender 
order by Age_group,gender;

-- How many employees work at headquarters versus remote locations?
select * from human_resources hr ;
select location,count(*)
from human_resources hr 
where age >= 18
group by location ;

--What is the average length of employment for employees who have been terminated?
SELECT AVG(EXTRACT(day FROM AGE(termdate, hire_date)) / 365) AS Avg_length_employment
FROM human_resources hr
WHERE termdate <= CURRENT_DATE  AND age >= 18;

SELECT
  AVG(
    CASE
      WHEN termdate <= CURRENT_DATE THEN
        EXTRACT(day FROM AGE(termdate, hire_date)) / 365.0
      ELSE
        EXTRACT(day FROM AGE(CURRENT_DATE, hire_date)) / 365.0
    END
  ) AS Avg_length_employment
FROM
  human_resources hr
WHERE
  age >= 18;
 
 --How does the gender distribution vary across departments and job titles?
 
 select department,gender,count(*) as count
 from human_resources hr 
 where age >=18
 group by department,gender 
 order by department, gender ;

--What is the distribution of job titles across the company?
select jobtitle,count(*) as count
from human_resources hr 
where age>=18 
group by jobtitle 
order by jobtitle desc;

--Which department has the highest turnover rate?
select * from human_resources hr ;
select department,total_count,terminated_count,
terminated_count/total_count as termination_rate
from (
select department,count(*)as total_count,
sum(case when termdate <= current_date
then 1
else 0 end) as terminated_count
from human_resources hr 
where age >=18
group by department 
) as subquery
order by termination_rate desc;

--What is the distribution of employees across locations by city and state?
select location_state,count(*) as count
from human_resources hr 
where age >= 18
group by location_state 
order by count;

--How has the company's employee count changed over time based on hire and term dates?
SELECT 
  year,
  hires,
  terminations,
  ROUND((hires - terminations) / CAST(hires AS NUMERIC) * 100, 2) AS net_change_percent
FROM 
(
  SELECT 
    EXTRACT(YEAR FROM hire_date) AS year,
    COUNT(*) AS hires,
    SUM(CASE WHEN termdate <= CURRENT_DATE THEN 1 ELSE 0 END) AS terminations
  FROM 
    human_resources hr 
  WHERE 
    age >= 18
  GROUP BY 
    EXTRACT(YEAR FROM hire_date)
) AS subquery
order by year asc;

--What is the tenure distribution for each department?
SELECT 
  department,
  ROUND(AVG(EXTRACT(DAY FROM AGE(termdate, hire_date)) / 365), 0) AS avg_tenure
FROM 
  human_resources hr 
WHERE 
  termdate <= CURRENT_DATE AND age >= 18
GROUP BY 
  department;

