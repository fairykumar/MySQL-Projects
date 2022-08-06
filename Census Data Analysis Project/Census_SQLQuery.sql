select * from portfolio_project.dbo.Data1;

select * from portfolio_project.dbo.Data2;

-- number of rows into our dataset

select count(*) from portfolio_project..Data1
select count(*) from portfolio_project..Data2

-- dataset for Jharkhand and Bihar

select * from portfolio_project..Data1 where state in ('Jharkhand','Bihar')

-- total population India

select sum(population) as Population from portfolio_project..Data2; 

-- average growth of India

select avg(growth)*100 avg_growth from portfolio_project..Data1; -- in percentage 

-- average growth percentage state wise

select state, avg(growth)*100 avg_growth from portfolio_project..Data1 group by state;

-- average sex ratio in number in descending order

select state, round(avg(sex_ratio),0) avg_sex_ratio from portfolio_project..Data1 group by state order by avg_sex_ratio desc;

-- average literacy rate

select state, round(avg(literacy),0) avg_literacy_ratio from portfolio_project..Data1
group by state having round(avg(literacy),0)>90 order by avg_literacy_ratio desc;

-- top 3 states showing highest growth ratio

select top 3 state, avg(growth)*100 avg_growth from portfolio_project..Data1 group by state order by avg_growth desc;

-- or the above query can also be written as below to limit the result to 3 rows:
select state, avg(growth)*100 avg_growth from portfolio_project..Data1 group by state order by avg_growth desc limit 3;

-- buttom 3 states showing lowest sex ratio

select top 3 state, round(avg(sex_ratio),0) avg_sex_ratio from portfolio_project..Data1 group by state order by avg_sex_ratio asc;

-- top 3 states in literacy state

drop table if exists #topstates;
create table #topstates
( state nvarchar(225),
  topstates float

  )

  insert into #topstates
  select state, round(avg(literacy),0) avg_literacy_ratio from portfolio_project..Data1
  group by state order by avg_literacy_ratio desc;

  select top 3 * from #topstates order by #topstates.topstates desc; 

-- buttom 3 most states in literacy state

  drop table if exists #buttomstates;
create table #buttomstates
( state nvarchar(225),
  buttomstates float

  )

  insert into #buttomstates
  select state, round(avg(literacy),0) avg_literacy_ratio from portfolio_project..Data1
  group by state order by avg_literacy_ratio desc;

  select top 3 * from #buttomstates order by #buttomstates.buttomstates asc; 

-- top 3 and buttom 3 states in literacy state together by using "union operator"

select * from (
select top 3 * from #topstates order by #topstates.topstates desc) a 

union

select * from (
select top 3 * from #buttomstates order by #buttomstates.buttomstates asc) b; 

-- states starting with letter a

select distinct state from portfolio_project..Data1 where lower(state) like 'a%' or lower(state) like 'b%'

-- states starting with letter a and ending with d

select distinct state from portfolio_project..Data1 where lower(state) like 'a%' and lower(state) like '%d'

-- states starting with letter a and ending with m

select distinct state from portfolio_project..Data1 where lower(state) like 'a%' and lower(state) like '%m'

-- joining both the tables

select d.State, sum(d.Males) total_males, sum(d.Females) total_females from
(select c.District, c.State, round(c.population/(c.sex_ratio+1),0) Males, round((population*sex_ratio)/(sex_ratio+1),0) Females from
(select a.District, a.state, a.Sex_Ratio/1000 sex_ratio, b.Population from portfolio_project..Data1 a 
inner join portfolio_project..Data2 b on a.District=b.District) c) d
group by d.State;

-- total literacy rate

select c.State, sum(literate_people) total_literate_pop, sum(illiterate_people) total_illiterate_pop from
(select d.District, d.State, round(d.literacy_ratio*d.Population,0) literate_people, 
round((1-d.literacy_ratio)*d.Population,0) illiterate_people from
(select a.District, a.State, a.literacy/100 literacy_ratio, b.Population from portfolio_project..Data1 a 
inner join portfolio_project..Data2 b on a.District=b.District) d) c
group by c.State;

-- population in previous census

select sum(m.previous_census_population) previous_census_population, sum(m.current_census_population) current_census_population from(
select e.state, sum(e.previous_census_population) previous_census_population, sum(e.current_census_population) current_census_population from 
(select d.District, d.State, round(d.Population/(1+d.growth),0) previous_census_population, d.Population current_census_population from
(select a.District, a.State, a.growth growth, b.Population from portfolio_project..Data1 a inner join portfolio_project..Data2 b on a.District=b.District) d) e
group by e.state)m

-- population vs. area

select (g.total_area/g.previous_census_population) as previous_census_population_vs_area, (g.total_area/g.current_census_population) as current_census_population_vs_area from
(select q.*, r.total_area from (

select '1' as keyy, n.* from
(select sum(m.previous_census_population) previous_census_population, sum(m.current_census_population) current_census_population from(
select e.state, sum(e.previous_census_population) previous_census_population, sum(e.current_census_population) current_census_population from 
(select d.District, d.State, round(d.Population/(1+d.growth),0) previous_census_population, d.Population current_census_population from
(select a.District, a.State, a.growth growth, b.Population from portfolio_project..Data1 a inner join portfolio_project..Data2 b on a.District=b.District) d) e
group by e.state)m) n) q inner join (

select '1' as keyy, z.* from (
select sum(area_km2) total_area from portfolio_project..Data2)z) r on q.keyy=r.keyy) g

-- window

-- output top 3 districts from each state with highest literacy rate

select a.*from
(select District, State, literacy, rank() over(partition by state order by literacy desc) rnk from portfolio_project..Data1) a

where a.rnk in (1,2,3) order by state