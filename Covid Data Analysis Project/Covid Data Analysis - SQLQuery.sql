select *
from portfolio_project2..CovidDeaths
where continent is not null
order by 3,4

select *
from portfolio_project2..CovidVaccinations
order by 3,4

-- Selecting data that we are going to use

select location, date, total_cases, new_cases, total_deaths, population
from portfolio_project2..CovidDeaths
order by 1,2

-- Total cases  vs. Total deaths (in %)
-- shows the likelihood of dying if you contract covid in your country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from portfolio_project2..CovidDeaths
where location like '%india%'
where continent is not null
order by 1,2

-- Total cases vs. Population
-- shows what percentage of population got covid

select location, date, population, total_cases, (total_cases/population)*100 as Infected_Percentage
from portfolio_project2..CovidDeaths
-- where location like '%india%' (to check according to demographic location)
order by 1,2

-- Countries with highest recorded infection rate compared to population

select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentagePopulationInfection
from portfolio_project2..CovidDeaths
-- where location like '%india%' (to check according to demographic location)
group by location, population
order by PercentagePopulationInfection desc

-- Showing countries with highest death count per population

select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
from portfolio_project2..CovidDeaths
-- where location like '%india%' (to check according to demographic location)
where continent is not null
group by location
order by TotalDeathCount desc

-- Segregating on the basis on continents

select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
from portfolio_project2..CovidDeaths
-- where location like '%india%' (to check according to demographic location)
where continent is not null
group by continent
order by TotalDeathCount desc

-- Showing continents with the highest death count per population

select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
from portfolio_project2..CovidDeaths
-- where location like '%india%' (to check according to demographic location)
where continent is not null
group by location
order by TotalDeathCount desc 



-- GLOBAL NUMBERS

select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Death_Percentage
from portfolio_project2..CovidDeaths
-- where location like '%india%'
where continent is not null
-- group by date
order by 1,2

-- Total population vs. Vaccinations

-- USE CTE

with PopvsVac (Continent, Location, Date, Population, New_Vaccination, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
  dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from portfolio_project2..CovidDeaths dea
join portfolio_project2..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
-- order by 2,3
)
select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac



-- TEMP TABLE
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
  dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from portfolio_project2..CovidDeaths dea
join portfolio_project2..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
-- order by 2,3
Select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac

-- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric, 
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
  dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from portfolio_project2..CovidDeaths dea
join portfolio_project2..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
-- where dea.continent is not null
-- order by 2,3

select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated



-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
  dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from portfolio_project2..CovidDeaths dea
join portfolio_project2..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
-- order by 2,3


select *
from PercentPopulationVaccinated


