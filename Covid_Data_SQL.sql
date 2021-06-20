select *
from PortfolioProjects..CovidDeaths$
where continent is not null
order by 3,4

--select *
--from PortfolioProjects..CovidVacc$
--order by 3,4

-- select data to use

select Location, date, total_cases, new_cases, total_deaths,population
from PortfolioProjects..CovidDeaths$
order by 1,2

-- Total cases vs total deaths
-- likelihood of death from contracting covid

select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProjects..CovidDeaths$
where location like '%nigeria%'
order by 1,2

-- Total cases vs Population
-- population percentage with covid

select Location, date, population, total_cases,  (total_cases/population)*100 as PopInfected
From PortfolioProjects..CovidDeaths$
where location like '%nigeria%'
order by 1,2

-- Countries with highest infection rate vs their population

select Location, population, MAX(total_cases) as HighestInfectionRate,  Max ((total_cases/population))*100 as PercentagePopulationInfected
From PortfolioProjects..CovidDeaths$
--where location like '%nigeria%'
group by Location, population
order by PercentagePopulationInfected desc

--Countries with Highest death count

select Location,  MAX(cast(total_deaths as int)) as TotalDeathRate 
From PortfolioProjects..CovidDeaths$
--where location like '%nigeria%'
where continent is not null
group by Location, population
order by TotalDeathRate desc


-- ORDER BY CONTINENT
-- CONTINENTS WITH HIGHEST DEATH COUNTS

select continent,  MAX(cast(total_deaths as int)) as TotalDeathRate 
From PortfolioProjects..CovidDeaths$
--where location like '%nigeria%'
where continent is not null
group by continent
order by TotalDeathRate desc


--GLOBAL NUMBERS

select date, sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as GlobalDeathPercent
From PortfolioProjects..CovidDeaths$
--where location like '%nigeria%'
where continent is not null
group by date
order by 1,2
-------------------------------------------
select sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as GlobalDeathPercent
From PortfolioProjects..CovidDeaths$
--where location like '%nigeria%'
where continent is not null
--group by date
order by 1,2


--COVID VACCINATIONS
-- Total population vs Vaccinations

select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingNumbersVaccinated
From PortfolioProjects..CovidDeaths$ dea
join PortfolioProjects..CovidVacc$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--CTE

with Popvsvac (continent, location, date, population, New_Vaccinations, RollingNumbersVaccinated)
as 
(
select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingNumbersVaccinated
From PortfolioProjects..CovidDeaths$ dea
join PortfolioProjects..CovidVacc$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingNumbersVaccinated/population)/100
From Popvsvac


-- TEMP TABLE

DROP table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingNumbersVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingNumbersVaccinated
From PortfolioProjects..CovidDeaths$ dea
join PortfolioProjects..CovidVacc$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3
select *, (RollingNumbersVaccinated/population)/100
From #PercentPopulationVaccinated



--CREATE VIEW FOR VISUALIZATION
Create view PercentPopulationVaccinated as
select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingNumbersVaccinated
From PortfolioProjects..CovidDeaths$ dea
join PortfolioProjects..CovidVacc$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
